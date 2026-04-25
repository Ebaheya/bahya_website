import type { Request } from 'express';
import { prisma } from '../config/prisma';
import { logger } from '../config/logger';

export type AuditActionType =
  | 'LOGIN'
  | 'LOGIN_FAIL'
  | 'LOGOUT'
  | 'REFRESH'
  | 'CREATE'
  | 'UPDATE'
  | 'DELETE';

export interface AuditPayload {
  userId?: string | null;
  actionType: AuditActionType;
  entity?: string;
  entityId?: string;
  oldValues?: unknown;
  newValues?: unknown;
  req?: Request;
}

export async function writeAudit(payload: AuditPayload): Promise<void> {
  try {
    await prisma.auditLog.create({
      data: {
        userId: payload.userId ?? null,
        actionType: payload.actionType,
        entity: payload.entity ?? null,
        entityId: payload.entityId ?? null,
        oldValues: payload.oldValues as never,
        newValues: payload.newValues as never,
        ip: payload.req ? getClientIp(payload.req) : null,
        userAgent: payload.req ? payload.req.get('user-agent') ?? null : null,
      },
    });
  } catch (err) {
    logger.error({ err, payload: { ...payload, oldValues: undefined, newValues: undefined } }, 'audit log failed');
  }
}

// Use Express's req.ip which respects the `trust proxy` setting in app.ts.
// Manual X-Forwarded-For parsing is removed: it can be spoofed by clients
// and produces a different value than what express-rate-limit uses, making
// audit logs and rate-limit identities inconsistent.
export function getClientIp(req: Request): string | null {
  return req.ip ?? null;
}
