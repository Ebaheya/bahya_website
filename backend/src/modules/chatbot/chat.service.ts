import type { Role } from '@prisma/client';
import { Types } from 'mongoose';
import { logger } from '../../config/logger';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import {
  emitCallCenterAlert,
  emitHighRiskAlert,
} from '../notifications/notification.service';
import { chatErrors } from './chat.errors';
import {
  CHAT_RISK_LEVELS,
  ChatMessageModel,
  ChatSessionModel,
  type ChatMessageDoc,
  type ChatRiskLevel,
  type ChatSessionDoc,
} from './chat.model';
import { infer, type AiHistoryTurn, type AiInferResponse } from './ai.client';
import { buildPatientProfile } from './chat.profile';

const SESSION_INACTIVITY_MS = 24 * 60 * 60 * 1000;

type ChatSessionRecord = ChatSessionDoc & { _id: Types.ObjectId };
type ChatSessionListRecord = Pick<
  ChatSessionDoc,
  'status' | 'maxRiskLevel' | 'lastEmotion' | 'startedAt' | 'endedAt'
> & { _id: Types.ObjectId };
type ChatMessageRecord = Pick<
  ChatMessageDoc,
  'sender' | 'message' | 'emotion' | 'riskLevel' | 'createdAt'
>;
type ChatReadableMessageRecord = {
  _id: Types.ObjectId;
  sender: ChatMessageDoc['sender'] | string;
  message: string;
  lang?: ChatMessageDoc['lang'] | string | null;
  emotion?: string | null;
  emotionConfidence?: number | null;
  intent?: ChatMessageDoc['intent'] | string | null;
  riskLevel?: ChatRiskLevel | string | null;
  crisisProbability?: number | null;
  crisis?: boolean | null;
  crisisSignalType?: ChatMessageDoc['crisisSignalType'] | string | null;
  flaggedPhrases?: string[];
  phq9Score?: number | null;
  createdAt: Date;
};

export interface HandlePatientMessageInput {
  patientId: string;
  sessionId?: string;
  message: string;
}

export interface PatientChatReply {
  sessionId: string;
  patientMessageId: string;
  botMessageId: string;
  reply: string;
}

export interface EscalationInput {
  patientId: string;
  sessionId: string;
  inf: AiInferResponse;
}

export interface ChatReadActor {
  id: string;
  role: Role;
}

export interface PaginationInput {
  page: number;
  pageSize: number;
}

export interface SessionsListInput extends PaginationInput {
  patientId?: string;
}

export interface ChatSessionSummary {
  id: string;
  status: ChatSessionDoc['status'];
  startedAt: Date;
  endedAt: Date | null;
  // Risk/emotion signals are returned to Doctor/Admin only (FR-019).
  maxRiskLevel?: ChatRiskLevel | null;
  lastEmotion?: string | null;
}

export interface PaginatedResult<T> {
  data: T[];
  page: number;
  pageSize: number;
  total: number;
}

export interface ChatTurnRead {
  id: string;
  sender: string;
  message: string;
  createdAt: Date;
  lang?: string | null;
  emotion?: string | null;
  emotionConfidence?: number | null;
  intent?: string | null;
  riskLevel?: string | null;
  crisisProbability?: number | null;
  crisis?: boolean | null;
  crisisSignalType?: string | null;
  flaggedPhrases?: string[];
  phq9Score?: number | null;
}

export interface SessionMessagesResult extends PaginatedResult<ChatTurnRead> {
  sessionId: string;
}

const riskRank: Record<ChatRiskLevel, number> = {
  LOW: 0,
  MEDIUM: 1,
  HIGH: 2,
  CRITICAL: 3,
};

function now(): Date {
  return new Date();
}

function toObjectId(id: string | Types.ObjectId): Types.ObjectId {
  return typeof id === 'string' ? new Types.ObjectId(id) : id;
}

function isClinicalReader(role: Role): boolean {
  return role === 'DOCTOR' || role === 'ADMIN';
}

function resolveReadablePatientId(actor: ChatReadActor, patientId?: string): string {
  if (actor.role === 'PATIENT') {
    if (patientId && patientId !== actor.id) {
      throw AppError.forbidden('Patients can only read their own chat sessions');
    }
    return actor.id;
  }

  if (isClinicalReader(actor.role)) {
    if (!patientId) {
      throw AppError.badRequest('patientId is required');
    }
    return patientId;
  }

  throw AppError.forbidden();
}

function paginationOffset(input: PaginationInput): number {
  return (input.page - 1) * input.pageSize;
}

function isStale(lastActivityAt: Date, at: Date): boolean {
  return at.getTime() - lastActivityAt.getTime() > SESSION_INACTIVITY_MS;
}

// Atomically raise a session's max risk, never lowering it. Concurrent turns
// read the same maxRiskLevel snapshot before their AI calls, so a JS-side
// `$set` could overwrite a CRITICAL rollup with a later LOW one. The conditional
// filter (only overwrite when the stored value is null or strictly lower) makes
// the rollup monotonic regardless of commit order.
async function raiseSessionMaxRisk(
  sessionId: Types.ObjectId,
  riskLevel: ChatRiskLevel
): Promise<void> {
  const lowerOrNull: (ChatRiskLevel | null)[] = [
    null,
    ...CHAT_RISK_LEVELS.filter((level) => riskRank[level] < riskRank[riskLevel]),
  ];
  await ChatSessionModel.updateOne(
    { _id: sessionId, maxRiskLevel: { $in: lowerOrNull } },
    { $set: { maxRiskLevel: riskLevel } }
  );
}

function isDuplicateKeyError(err: unknown): boolean {
  return Boolean(
    err && typeof err === 'object' && 'code' in err && (err as { code?: number }).code === 11000
  );
}

async function closeSession(id: Types.ObjectId, at: Date): Promise<void> {
  await ChatSessionModel.updateOne(
    { _id: id },
    { $set: { status: 'CLOSED', endedAt: at, lastActivityAt: at } }
  );
}

async function createSession(patientId: string, at: Date): Promise<ChatSessionRecord> {
  return ChatSessionModel.create({
    patientId,
    status: 'ACTIVE',
    maxRiskLevel: null,
    lastEmotion: null,
    summary: null,
    startedAt: at,
    endedAt: null,
    lastActivityAt: at,
  }) as unknown as Promise<ChatSessionRecord>;
}

// Resume a session referenced explicitly by id. Only an ACTIVE, non-stale
// session owned by the patient can be resumed; a missing/closed/expired id is an
// explicit error rather than a silently-created new session.
async function resumeExplicitSession(
  patientId: string,
  sessionId: string,
  at: Date
): Promise<ChatSessionRecord> {
  const existing = (await ChatSessionModel.findOne({
    _id: toObjectId(sessionId),
    patientId,
  }).exec()) as ChatSessionRecord | null;

  if (!existing || existing.status !== 'ACTIVE' || isStale(existing.lastActivityAt, at)) {
    if (existing && existing.status === 'ACTIVE') {
      await closeSession(existing._id, at); // retire the expired record
    }
    throw chatErrors.sessionNotFound();
  }

  await ChatSessionModel.updateOne({ _id: existing._id }, { $set: { lastActivityAt: at } });
  existing.lastActivityAt = at;
  return existing;
}

// Resume the patient's single open session, or open a new one. The create is
// guarded against the concurrent-double-send race by the partial unique index:
// a loser re-reads the winner's session instead of failing the message.
async function getOrCreateOpenSession(
  patientId: string,
  at: Date
): Promise<ChatSessionRecord> {
  const existing = (await ChatSessionModel.findOne({ patientId, status: 'ACTIVE' })
    .sort({ lastActivityAt: -1 })
    .exec()) as ChatSessionRecord | null;

  if (existing && !isStale(existing.lastActivityAt, at)) {
    await ChatSessionModel.updateOne({ _id: existing._id }, { $set: { lastActivityAt: at } });
    existing.lastActivityAt = at;
    return existing;
  }

  if (existing) {
    await closeSession(existing._id, at);
  }

  try {
    return await createSession(patientId, at);
  } catch (err) {
    if (isDuplicateKeyError(err)) {
      const winner = (await ChatSessionModel.findOne({ patientId, status: 'ACTIVE' })
        .sort({ lastActivityAt: -1 })
        .exec()) as ChatSessionRecord | null;
      if (winner) return winner;
    }
    throw err;
  }
}

export async function getOrCreateSession(
  patientId: string,
  sessionId?: string
): Promise<ChatSessionRecord> {
  const at = now();
  return sessionId
    ? resumeExplicitSession(patientId, sessionId, at)
    : getOrCreateOpenSession(patientId, at);
}

export async function getRecentTurns(
  sessionId: string | Types.ObjectId,
  limit = 10
): Promise<AiHistoryTurn[]> {
  const objectId = toObjectId(sessionId);
  const rows = (await ChatMessageModel.find({ sessionId: objectId })
    // _id tie-breaks turns written in the same millisecond (patient + bot),
    // keeping history order deterministic.
    .sort({ createdAt: -1, _id: -1 })
    .limit(limit)
    .exec()) as ChatMessageRecord[];

  return rows.reverse().map((turn) => ({
    sender: turn.sender,
    text: turn.message,
    emotion: turn.emotion,
    riskLevel: turn.riskLevel,
    createdAt: turn.createdAt.toISOString(),
  }));
}

export async function listSessions(
  actor: ChatReadActor,
  input: SessionsListInput
): Promise<PaginatedResult<ChatSessionSummary>> {
  const patientId = resolveReadablePatientId(actor, input.patientId);
  const filter = { patientId };
  const rows = (await ChatSessionModel.find(filter)
    .sort({ startedAt: -1 })
    .skip(paginationOffset(input))
    .limit(input.pageSize)
    .lean()) as unknown as ChatSessionListRecord[];
  const total = await ChatSessionModel.countDocuments(filter);
  const clinical = isClinicalReader(actor.role);

  return {
    data: rows.map((session) => ({
      id: session._id.toString(),
      status: session.status,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      // Patients never receive risk/emotion signals (FR-019).
      ...(clinical
        ? { maxRiskLevel: session.maxRiskLevel, lastEmotion: session.lastEmotion }
        : {}),
    })),
    page: input.page,
    pageSize: input.pageSize,
    total,
  };
}

export function projectTurnForRole(
  turn: ChatReadableMessageRecord,
  role: Role
): ChatTurnRead {
  const projected: ChatTurnRead = {
    id: turn._id.toString(),
    sender: turn.sender,
    message: turn.message,
    createdAt: turn.createdAt,
  };

  if (!isClinicalReader(role)) {
    return projected;
  }

  return {
    ...projected,
    lang: turn.lang,
    emotion: turn.emotion,
    emotionConfidence: turn.emotionConfidence,
    intent: turn.intent,
    riskLevel: turn.riskLevel,
    crisisProbability: turn.crisisProbability,
    crisis: turn.crisis,
    crisisSignalType: turn.crisisSignalType,
    flaggedPhrases: turn.flaggedPhrases,
    phq9Score: turn.phq9Score,
  };
}

export async function getSessionMessages(
  actor: ChatReadActor,
  sessionId: string,
  input: PaginationInput
): Promise<SessionMessagesResult> {
  if (actor.role !== 'PATIENT' && !isClinicalReader(actor.role)) {
    throw AppError.forbidden();
  }

  const objectId = toObjectId(sessionId);
  const session = (await ChatSessionModel.findOne({ _id: objectId }).lean()) as
    | (Pick<ChatSessionDoc, 'patientId'> & { _id: Types.ObjectId })
    | null;

  if (!session) throw chatErrors.sessionNotFound();

  if (actor.role === 'PATIENT' && session.patientId !== actor.id) {
    throw AppError.forbidden();
  }

  const filter = { sessionId: objectId };
  const rows = (await ChatMessageModel.find(filter)
    // _id tie-breaks same-millisecond turns so pagination/order is stable.
    .sort({ createdAt: 1, _id: 1 })
    .skip(paginationOffset(input))
    .limit(input.pageSize)
    .lean()) as unknown as ChatReadableMessageRecord[];
  const total = await ChatMessageModel.countDocuments(filter);

  return {
    sessionId: objectId.toString(),
    data: rows.map((turn) => projectTurnForRole(turn, actor.role)),
    page: input.page,
    pageSize: input.pageSize,
    total,
  };
}

function botTurnFromInference(
  sessionId: Types.ObjectId,
  patientId: string,
  inf: AiInferResponse,
  at: Date
) {
  return {
    sessionId,
    patientId,
    sender: 'BOT',
    message: inf.reply,
    lang: inf.lang,
    emotion: inf.emotion?.label ?? null,
    emotionConfidence: inf.emotion?.confidence ?? null,
    intent: inf.intent,
    riskLevel: inf.riskLevel,
    crisisProbability: inf.crisisProbability ?? null,
    crisis: inf.crisis,
    crisisSignalType: inf.crisisSignalType ?? null,
    flaggedPhrases: inf.flaggedPhrases ?? [],
    phq9Score: inf.phq9Score ?? null,
    createdAt: at,
  };
}

function isUrgentSignal(inf: AiInferResponse): boolean {
  return inf.riskLevel === 'CRITICAL' || (inf.crisis && inf.crisisSignalType === 'direct');
}

export async function escalateIfNeeded(input: EscalationInput): Promise<void> {
  const riskLevel = input.inf.riskLevel;
  const urgent = isUrgentSignal(input.inf);
  // A direct crisis must escalate even if the AI also (contradictorily) labelled
  // the turn LOW — never silently drop it.
  if (riskLevel === 'LOW' && !urgent) return;

  // For that contradictory LOW + direct-crisis case, treat the crisis as
  // authoritative and escalate at the highest severity.
  const severity: Extract<ChatRiskLevel, 'MEDIUM' | 'HIGH' | 'CRITICAL'> =
    riskLevel === 'LOW' ? 'CRITICAL' : riskLevel;

  const flaggedPhrases = input.inf.flaggedPhrases ?? [];
  const failed: string[] = [];

  // 1) Write the durable safety record FIRST, so a notification-store outage can
  //    never erase the fact that a crisis was detected. Its own failure is
  //    captured (not allowed to drop the alerts below).
  try {
    await writeAudit({
      actorId: null,
      action: 'HIGH_RISK_ALERT_CREATED',
      entityType: 'CHAT_SESSION',
      entityId: input.sessionId,
      newValues: {
        riskLevel,
        crisisProbability: input.inf.crisisProbability ?? null,
        crisis: input.inf.crisis,
        flaggedPhrases,
      },
    });
  } catch {
    failed.push('audit');
  }

  // 2) Notify the care team. Each emitter reports success; a dropped alert is a
  //    safety event, surfaced below rather than swallowed.
  const doctorOk = await emitHighRiskAlert({
    patientId: input.patientId,
    severity,
    reason: `AI risk level ${riskLevel}`,
    flaggedPhrases,
  }).catch(() => false);
  if (!doctorOk) failed.push('doctor');

  if (urgent) {
    const callCenterOk = await emitCallCenterAlert({
      patientId: input.patientId,
      severity,
      reason: 'AI urgent crisis signal',
      flaggedPhrases,
    }).catch(() => false);
    if (!callCenterOk) failed.push('callCenter');
  }

  if (failed.length > 0) {
    // error level (pageable) — a crisis alert was not fully delivered and needs
    // manual follow-up; the patient already received their reply regardless.
    logger.error(
      {
        metric: 'chat_escalation_failure',
        patientId: input.patientId,
        sessionId: input.sessionId,
        riskLevel,
        failed,
      },
      'chat escalation failed'
    );
  }
}

export async function handlePatientMessage(
  input: HandlePatientMessageInput
): Promise<PatientChatReply> {
  const session = await getOrCreateSession(input.patientId, input.sessionId);
  const sessionObjectId = toObjectId(session._id);

  // Build context from PRIOR turns BEFORE persisting the current message, so the
  // AI history does not double-count the message it also receives as `message`.
  const [patientProfile, history] = await Promise.all([
    buildPatientProfile(input.patientId, session.maxRiskLevel),
    getRecentTurns(sessionObjectId, 10),
  ]);

  // Persist the patient turn BEFORE the AI call so it is never lost on failure.
  const patientTurnAt = now();
  const patientTurn = await ChatMessageModel.create({
    sessionId: sessionObjectId,
    patientId: input.patientId,
    sender: 'PATIENT',
    message: input.message,
    createdAt: patientTurnAt,
  });

  const inf = await infer({
    version: 1,
    sessionId: sessionObjectId.toString(),
    message: input.message,
    langHint: patientProfile.languagePref,
    patient: patientProfile,
    history,
  });

  const botTurnAt = now();
  const botTurn = await ChatMessageModel.create(
    botTurnFromInference(sessionObjectId, input.patientId, inf, botTurnAt)
  );

  await ChatSessionModel.updateOne(
    { _id: sessionObjectId },
    { $set: { lastEmotion: inf.emotion?.label ?? null, lastActivityAt: botTurnAt } }
  );
  // Raise (never lower) the session's max risk atomically — see raiseSessionMaxRisk.
  await raiseSessionMaxRisk(sessionObjectId, inf.riskLevel);

  const sessionIdString = sessionObjectId.toString();
  void escalateIfNeeded({
    patientId: input.patientId,
    sessionId: sessionIdString,
    inf,
  }).catch((err) => {
    logger.error(
      {
        metric: 'chat_escalation_failure',
        patientId: input.patientId,
        sessionId: sessionIdString,
        riskLevel: inf.riskLevel,
        err: err instanceof Error ? { name: err.name, message: err.message } : String(err),
      },
      'chat escalation failed'
    );
  });

  return {
    sessionId: sessionIdString,
    patientMessageId: patientTurn._id.toString(),
    botMessageId: botTurn._id.toString(),
    reply: inf.reply,
  };
}
