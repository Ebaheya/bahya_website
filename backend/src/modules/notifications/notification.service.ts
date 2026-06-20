import type { FilterQuery } from 'mongoose';
import { Types } from 'mongoose';
import type { Role } from '@prisma/client';
import { logger } from '../../config/logger';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import { NotificationErrors } from './notification.errors';
import {
  NotificationModel,
  type NotificationDoc,
  type NotificationRecipientRole,
  type NotificationSeverity,
  type NotificationStatus,
} from './notification.model';
import { pushForNotification } from './push.service';

export interface FormAssignedNotificationInput {
  patientId: string;
  recipientRole: Extract<NotificationRecipientRole, 'PATIENT' | 'VOLUNTEER'>;
  recipientUserId: string;
  assignmentId?: string;
  formName?: string;
}

export interface HighRiskAlertInput {
  patientId: string;
  submissionId?: string;
  severity: Extract<NotificationSeverity, 'MEDIUM' | 'HIGH' | 'CRITICAL'>;
  templateKey?: string;
  reason?: string;
  flaggedPhrases?: string[];
}

export interface CallCenterAlertInput {
  patientId: string;
  severity: Extract<NotificationSeverity, 'MEDIUM' | 'HIGH' | 'CRITICAL'>;
  reason?: string;
  flaggedPhrases?: string[];
}

export interface ServiceRequestSubmittedInput {
  patientId: string;
}

export interface ServiceRequestDecidedInput {
  patientId: string;
  recipientUserId: string;
  approved: boolean;
  serviceName: string;
}

export interface RequestBookingInput {
  patientId: string;
  doctorNote?: string;
}

function loggableError(err: unknown): { name?: string; message: string } {
  if (err instanceof Error) return { name: err.name, message: err.message };
  return { message: String(err) };
}

async function pushBestEffort(doc: NotificationDoc & { _id: unknown }, type: string): Promise<void> {
  try {
    await pushForNotification(doc);
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_push_failure',
        type,
        notificationId: String(doc._id),
        err: loggableError(err),
      },
      'notification push failed'
    );
  }
}

export async function emitFormAssigned(input: FormAssignedNotificationInput): Promise<void> {
  try {
    const doc = await NotificationModel.create({
      recipientRole: input.recipientRole,
      recipientUserId: input.recipientUserId,
      patientId: input.patientId,
      type: 'FORM_ASSIGNED',
      title: 'Assessment form assigned',
      message: input.formName ? `A new form is available: ${input.formName}` : 'A new form is available.',
      severity: 'LOW',
      reason: input.assignmentId ?? null,
      doctorNote: null,
      status: 'UNREAD',
      claimedAt: null,
      readAt: null,
      doneAt: null,
      pushedAt: null,
      createdAt: new Date(),
    });
    await pushBestEffort(doc, 'FORM_ASSIGNED');
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_emit_failure',
        type: 'FORM_ASSIGNED',
        patientId: input.patientId,
        recipientRole: input.recipientRole,
        recipientUserId: input.recipientUserId,
        err: loggableError(err),
      },
      'notification emit failed'
    );
  }
}

export async function emitHighRiskAlert(input: HighRiskAlertInput): Promise<void> {
  try {
    const doc = await NotificationModel.create({
      recipientRole: 'DOCTOR',
      recipientUserId: null,
      patientId: input.patientId,
      type: 'HIGH_RISK',
      title: 'High-risk assessment submitted',
      message: input.templateKey
        ? `A high-risk ${input.templateKey} submission needs review.`
        : 'A high-risk chatbot conversation needs review.',
      severity: input.severity,
      reason: input.reason ?? input.submissionId ?? null,
      flaggedPhrases: input.flaggedPhrases ?? null,
      doctorNote: null,
      status: 'UNREAD',
      claimedAt: null,
      readAt: null,
      doneAt: null,
      pushedAt: null,
      createdAt: new Date(),
    });
    if (input.severity === 'HIGH' || input.severity === 'CRITICAL') {
      await pushBestEffort(doc, 'HIGH_RISK');
    }
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_emit_failure',
        type: 'HIGH_RISK',
        patientId: input.patientId,
        severity: input.severity,
        err: loggableError(err),
      },
      'notification emit failed'
    );
  }
}

export async function emitCallCenterAlert(input: CallCenterAlertInput): Promise<void> {
  try {
    const doc = await NotificationModel.create({
      recipientRole: 'CALL_CENTER',
      recipientUserId: null,
      patientId: input.patientId,
      type: 'HIGH_RISK',
      title: 'Urgent chatbot crisis signal',
      message: 'A patient chatbot conversation needs urgent call-center follow-up.',
      severity: input.severity,
      reason: input.reason ?? null,
      flaggedPhrases: input.flaggedPhrases ?? null,
      doctorNote: null,
      status: 'UNREAD',
      claimedAt: null,
      readAt: null,
      doneAt: null,
      pushedAt: null,
      createdAt: new Date(),
    });
    await pushBestEffort(doc, 'HIGH_RISK');
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_emit_failure',
        type: 'HIGH_RISK',
        patientId: input.patientId,
        recipientRole: 'CALL_CENTER',
        severity: input.severity,
        err: loggableError(err),
      },
      'notification emit failed'
    );
  }
}

export async function emitServiceRequestSubmitted(
  input: ServiceRequestSubmittedInput
): Promise<void> {
  try {
    const createdAt = new Date();
    const docs = await NotificationModel.insertMany(
      (['ADMIN', 'DOCTOR'] as const).map((recipientRole) => ({
        recipientRole,
        recipientUserId: null,
        patientId: input.patientId,
        type: 'SERVICE_REQUEST_SUBMITTED',
        title: 'Service request submitted',
        message: 'A patient submitted a new service join request.',
        severity: 'MEDIUM',
        reason: null,
        doctorNote: null,
        status: 'UNREAD',
        claimedAt: null,
        readAt: null,
        doneAt: null,
        pushedAt: null,
        createdAt,
      }))
    );
    for (const doc of docs) {
      await pushBestEffort(doc, 'SERVICE_REQUEST_SUBMITTED');
    }
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_emit_failure',
        type: 'SERVICE_REQUEST_SUBMITTED',
        err: loggableError(err),
      },
      'notification emit failed'
    );
  }
}

export async function emitServiceRequestDecided(
  input: ServiceRequestDecidedInput
): Promise<void> {
  try {
    const doc = await NotificationModel.create({
      recipientRole: 'PATIENT',
      recipientUserId: input.recipientUserId,
      patientId: input.patientId,
      type: 'SERVICE_REQUEST_DECIDED',
      title: input.approved ? 'Service request approved' : 'Service request rejected',
      message: input.approved
        ? `Your request for ${input.serviceName} was approved.`
        : `Your request for ${input.serviceName} was rejected.`,
      severity: 'LOW',
      reason: null,
      doctorNote: null,
      status: 'UNREAD',
      claimedAt: null,
      readAt: null,
      doneAt: null,
      pushedAt: null,
      createdAt: new Date(),
    });
    await pushBestEffort(doc, 'SERVICE_REQUEST_DECIDED');
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_emit_failure',
        type: 'SERVICE_REQUEST_DECIDED',
        approved: input.approved,
        err: loggableError(err),
      },
      'notification emit failed'
    );
  }
}

// ---------------------------------------------------------------------------
// Recipient-facing read surface (US1)
// ---------------------------------------------------------------------------

export interface NotificationListActor {
  id: string;
  role: Role;
}

export interface ListMyNotificationsQuery {
  status?: NotificationStatus;
  severity?: NotificationSeverity;
  page: number;
  pageSize: number;
}

type LeanNotification = NotificationDoc & { _id: Types.ObjectId };

interface PatientContact {
  id: string;
  fullName: string;
  phone: string;
}

function toNotificationCore(doc: LeanNotification) {
  return {
    id: String(doc._id),
    type: doc.type,
    severity: doc.severity,
    status: doc.status,
    title: doc.title,
    message: doc.message,
    doctorNote: doc.doctorNote,
    claimedAt: doc.claimedAt,
    readAt: doc.readAt,
    doneAt: doc.doneAt,
    createdAt: doc.createdAt,
  };
}

function toListItem(doc: LeanNotification, patientById: Map<string, PatientContact>) {
  return {
    ...toNotificationCore(doc),
    // Live patient contact (FR-004); degrades to null when the patient can no
    // longer be read, rather than failing the whole list.
    patient: patientById.get(doc.patientId) ?? null,
  };
}

// Lists the notifications addressed to the caller: those personally assigned
// to them, plus unclaimed role-broadcasts to their role (FR-001). A patient
// only ever matches the personal branch, so cross-patient leakage is impossible
// (FR-015). Patient name/phone are read live from PostgreSQL (FR-004).
export async function listMyNotifications(
  actor: NotificationListActor,
  query: ListMyNotificationsQuery
) {
  const filter: FilterQuery<NotificationDoc> = {
    $or: [
      { recipientUserId: actor.id },
      { recipientRole: actor.role as NotificationRecipientRole, recipientUserId: null },
    ],
  };
  if (query.status) filter.status = query.status;
  if (query.severity) filter.severity = query.severity;

  const skip = (query.page - 1) * query.pageSize;

  const [docs, total] = await Promise.all([
    NotificationModel.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(query.pageSize)
      .lean<LeanNotification[]>(),
    NotificationModel.countDocuments(filter),
  ]);

  const patientIds = [...new Set(docs.map((d) => d.patientId).filter(Boolean))];
  const patients = patientIds.length
    ? await prisma.patient.findMany({
        where: { id: { in: patientIds } },
        select: { id: true, phone: true, user: { select: { fullName: true } } },
      })
    : [];
  const patientById = new Map<string, PatientContact>(
    patients.map((p) => [p.id, { id: p.id, fullName: p.user.fullName, phone: p.phone }])
  );

  return {
    data: docs.map((d) => toListItem(d, patientById)),
    page: query.page,
    pageSize: query.pageSize,
    total,
  };
}

// ---------------------------------------------------------------------------
// Claim a role-broadcast notification (US2)
// ---------------------------------------------------------------------------

// Atomically assigns an unclaimed role-broadcast notification to the caller.
// The single findOneAndUpdate is the authoritative guard: of two concurrent
// claimers, exactly one matches `recipientUserId: null` and wins; the other
// gets null and is classified below (FR-006). On a null result we read the doc
// once to return an accurate status: 404 missing / 403 wrong role / 409 already
// claimed.
export async function claimNotification(actor: NotificationListActor, id: string) {
  const claimed = await NotificationModel.findOneAndUpdate(
    {
      _id: id,
      recipientUserId: null,
      recipientRole: actor.role as NotificationRecipientRole,
    },
    { $set: { recipientUserId: actor.id, claimedAt: new Date() } },
    { new: true }
  ).lean<LeanNotification | null>();

  if (claimed) return toNotificationCore(claimed);

  const existing = await NotificationModel.findById(id).lean<LeanNotification | null>();
  if (!existing) throw AppError.notFound('Notification not found');
  if (existing.recipientRole !== actor.role) throw NotificationErrors.notRecipient();
  throw NotificationErrors.claimConflict();
}

// ---------------------------------------------------------------------------
// Notification lifecycle transitions (US3)
// ---------------------------------------------------------------------------

async function classifyTransitionMiss(actor: NotificationListActor, id: string): Promise<never> {
  const existing = await NotificationModel.findById(id).lean<LeanNotification | null>();
  if (!existing) throw AppError.notFound('Notification not found');
  if (existing.recipientUserId !== actor.id) throw NotificationErrors.notRecipient();
  throw NotificationErrors.illegalTransition();
}

export async function markRead(actor: NotificationListActor, id: string) {
  const updated = await NotificationModel.findOneAndUpdate(
    { _id: id, recipientUserId: actor.id, status: 'UNREAD' },
    { $set: { status: 'READ', readAt: new Date() } },
    { new: true }
  ).lean<LeanNotification | null>();

  if (!updated) return classifyTransitionMiss(actor, id);

  await writeAudit({
    actorId: actor.id,
    action: 'NOTIFICATION_READ',
    entityType: 'NOTIFICATION',
    entityId: id,
    oldValues: { status: 'UNREAD' },
    newValues: { status: 'READ' },
  });

  return toNotificationCore(updated);
}

export async function markDone(actor: NotificationListActor, id: string) {
  const updated = await NotificationModel.findOneAndUpdate(
    { _id: id, recipientUserId: actor.id, status: { $in: ['UNREAD', 'READ'] } },
    { $set: { status: 'DONE', doneAt: new Date() } },
    { new: true }
  ).lean<LeanNotification | null>();

  if (!updated) return classifyTransitionMiss(actor, id);

  await writeAudit({
    actorId: actor.id,
    action: 'NOTIFICATION_DONE',
    entityType: 'NOTIFICATION',
    entityId: id,
    oldValues: { status: 'UNREAD_OR_READ' },
    newValues: { status: 'DONE' },
  });

  return toNotificationCore(updated);
}

// ---------------------------------------------------------------------------
// Doctor requests a Call Center booking (US4)
// ---------------------------------------------------------------------------

export async function requestBooking(actor: NotificationListActor, input: RequestBookingInput) {
  const patient = await prisma.patient.findUnique({
    where: { id: input.patientId },
    select: { id: true },
  });
  if (!patient) throw AppError.notFound('Patient not found');

  const doc = await NotificationModel.create({
    recipientRole: 'CALL_CENTER',
    recipientUserId: null,
    patientId: input.patientId,
    type: 'BOOKING_REQUIRED',
    title: 'Doctor booking required',
    message: 'Patient needs a doctor appointment.',
    severity: 'MEDIUM',
    reason: actor.id,
    doctorNote: input.doctorNote ?? null,
    status: 'UNREAD',
    claimedAt: null,
    readAt: null,
    doneAt: null,
    pushedAt: null,
    createdAt: new Date(),
  });

  await pushBestEffort(doc, 'BOOKING_REQUIRED');
  return toNotificationCore(doc as LeanNotification);
}
