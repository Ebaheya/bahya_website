import { Schema, model, models } from 'mongoose';
import { AUDIT_ACTIONS, type AuditAction } from './audit.actions';

export interface AuditLogDoc {
  actorId: string | null;
  action: AuditAction;
  entityType: string | null;
  entityId: string | null;
  oldValues: Record<string, unknown> | null;
  newValues: Record<string, unknown> | null;
  ipAddress: string | null;
  userAgent: string | null;
  createdAt: Date;
  legacyPgId?: string;
}

const AuditLogSchema = new Schema<AuditLogDoc>(
  {
    actorId: { type: String, default: null },
    action: { type: String, enum: AUDIT_ACTIONS, required: true },
    entityType: { type: String, default: null },
    entityId: { type: String, default: null },
    oldValues: { type: Schema.Types.Mixed, default: null },
    newValues: { type: Schema.Types.Mixed, default: null },
    ipAddress: { type: String, default: null },
    userAgent: { type: String, default: null },
    createdAt: { type: Date, required: true },
    legacyPgId: { type: String, required: false },
  },
  { collection: 'audit_logs', versionKey: false, strict: 'throw' }
);

AuditLogSchema.index({ actorId: 1, createdAt: -1 });
AuditLogSchema.index({ action: 1, createdAt: -1 });
// Unfiltered newest-first scans (dashboard activity feed) can't use the
// compound indexes above because those are prefixed by actorId/action, so
// back the bare `.sort({ createdAt: -1 })` with its own index.
AuditLogSchema.index({ createdAt: -1 });
AuditLogSchema.index(
  { legacyPgId: 1 },
  {
    unique: true,
    partialFilterExpression: { legacyPgId: { $exists: true } },
    name: 'idx_legacyPgId_partial_unique',
  }
);

/**
 * Module-private Mongoose model for the `audit_logs` collection.
 *
 * INVARIANT: only `audit.service.ts` (this module) is permitted to import
 * `AuditLogModel`. External callers — including the legacy migration script —
 * MUST go through the helpers exported from `./audit.service` so the
 * append-only invariant (FR-002) and the audit vocabulary remain enforced
 * at a single boundary. Adding a new direct import elsewhere is a review
 * blocker, not a style nit.
 */
export const AuditLogModel =
  models.AuditLog ?? model<AuditLogDoc>('AuditLog', AuditLogSchema);
