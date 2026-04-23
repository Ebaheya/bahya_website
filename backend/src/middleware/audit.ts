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

export function getClientIp(req: Request): string | null {
  const xff = req.headers['x-forwarded-for'];
  if (typeof xff === 'string' && xff.length > 0) {
    return xff.split(',')[0].trim();
  }
  return req.ip ?? req.socket?.remoteAddress ?? null;
}
