import type { Request } from 'express';
import { logger } from '../../config/logger';
import { AppError } from '../../utils/httpError';
import {
  AUDIT_ACTIONS,
  isStrictAuditAction,
  type AuditAction,
} from './audit.actions';
import { AuditLogModel } from './audit.model';

export interface AuditInput {
  actorId?: string | null;
  action: AuditAction;
  entityType?: string | null;
  entityId?: string | null;
  oldValues?: Record<string, unknown> | null;
  newValues?: Record<string, unknown> | null;
  req?: Request;
}

const DENY = /(password|token|secret|jwt)/i;
const REDACTED = '[REDACTED]';
const SANITIZER_MAX_DEPTH = 1;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

// Walk one nested level into objects AND into arrays, so a deny-list key
// inside an array-of-objects (e.g. `{ items: [{ password: 'x' }] }`) still
// gets redacted. Beyond `SANITIZER_MAX_DEPTH` the value is passed through
// verbatim — callers should not nest secrets deeper than one level.
function sanitizeRecord(
  values: Record<string, unknown>,
  depth: number
): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(values).map(([key, value]) => {
      if (DENY.test(key)) return [key, REDACTED];
      if (depth >= SANITIZER_MAX_DEPTH) return [key, value];
      if (isRecord(value)) return [key, sanitizeRecord(value, depth + 1)];
      if (Array.isArray(value)) {
        return [
          key,
          value.map((item) =>
            isRecord(item) ? sanitizeRecord(item, depth + 1) : item
          ),
        ];
      }
      return [key, value];
    })
  );
}

function sanitizeValues(
  values: Record<string, unknown> | null | undefined
): Record<string, unknown> | null {
  if (!values) return null;
  return sanitizeRecord(values, 0);
}

function isKnownAuditAction(action: unknown): action is AuditAction {
  return typeof action === 'string' && AUDIT_ACTIONS.includes(action as AuditAction);
}

export async function writeAudit(input: AuditInput): Promise<void> {
  if (!isKnownAuditAction(input.action)) {
    throw new Error('UNKNOWN_AUDIT_ACTION');
  }

  const oldValues = sanitizeValues(input.oldValues);
  const newValues = sanitizeValues(input.newValues);
  const ipAddress = input.req?.ip ?? null;
  const userAgent = input.req?.get('user-agent') ?? null;

  try {
    await AuditLogModel.create({
      actorId: input.actorId ?? null,
      action: input.action,
      entityType: input.entityType ?? null,
      entityId: input.entityId ?? null,
      oldValues,
      newValues,
      ipAddress,
      userAgent,
      createdAt: new Date(),
    });
  } catch (err) {
    if (isStrictAuditAction(input.action)) {
      logger.error(
        { metric: 'audit_write_failure', action: input.action, tier: 'strict', err },
        'audit write failed'
      );
      throw new AppError(
        503,
        'AUDIT_UNAVAILABLE',
        'Audit log write failed; request rejected'
      );
    }

    // Best-effort tier: log structured fields only. Do NOT spread `input` —
    // that would serialize the raw Express Request (headers, cookies, body)
    // into the log line.
    logger.warn(
      {
        metric: 'audit_write_failure',
        action: input.action,
        tier: 'best_effort',
        err,
        actorId: input.actorId ?? null,
        entityType: input.entityType ?? null,
        entityId: input.entityId ?? null,
      },
      'audit write failed'
    );
  }
}

// ---------------------------------------------------------------------------
// Legacy migration helpers
// ---------------------------------------------------------------------------
// These exist solely so `scripts/migrate-audit-to-mongo.ts` can backfill
// historical PostgreSQL `AuditLog` rows without importing `AuditLogModel`
// directly, preserving the module-private invariant on the model.
// They are NOT part of the runtime audit path. Do not call them from
// request handlers, middleware, or business services.
// ---------------------------------------------------------------------------

export interface LegacyAuditMigrationDoc {
  legacyPgId: string;
  actorId: string | null;
  action: string;
  entityType: string | null;
  entityId: string | null;
  oldValues: unknown;
  newValues: unknown;
  ipAddress: string | null;
  userAgent: string | null;
  createdAt: Date;
}

export type LegacyMigrationStatus = 'inserted' | 'skipped';

function isDuplicateKeyError(err: unknown): boolean {
  return (
    typeof err === 'object' &&
    err !== null &&
    'code' in err &&
    (err as { code?: unknown }).code === 11000
  );
}

export async function __migrationSyncAuditIndexes(): Promise<void> {
  await AuditLogModel.syncIndexes();
}

export async function __migrationFindByLegacyPgId(
  legacyPgId: string
): Promise<boolean> {
  const existing = await AuditLogModel.collection.findOne(
    { legacyPgId },
    { projection: { _id: 1 } }
  );
  return existing !== null;
}

// Inserts a historical row with `legacyPgId`. Bypasses Mongoose schema
// validation deliberately: legacy `actionType` values may be outside the
// new vocabulary (the migration script reports them via `non_vocab_actions`),
// and the partial unique index on `legacyPgId` is the safety net for
// concurrent reruns.
export async function __migrationInsertLegacyAudit(
  doc: LegacyAuditMigrationDoc
): Promise<LegacyMigrationStatus> {
  try {
    await AuditLogModel.collection.insertOne({ ...doc });
    return 'inserted';
  } catch (err) {
    if (isDuplicateKeyError(err)) return 'skipped';
    throw err;
  }
}
