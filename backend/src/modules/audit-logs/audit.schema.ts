import { z } from 'zod';
import { AUDIT_ACTIONS, type AuditAction } from './audit.actions';

const auditActionValues = AUDIT_ACTIONS as unknown as [AuditAction, ...AuditAction[]];

const isoDateSchema = z
  .string()
  .refine((value) => !Number.isNaN(Date.parse(value)), 'Invalid ISO date')
  .transform((value) => new Date(value));

export const auditIdParamSchema = z
  .object({
    id: z.string().regex(/^[a-fA-F0-9]{24}$/, 'Invalid audit id'),
  })
  .strict();

export const listAuditLogsQuerySchema = z
  .object({
    action: z.enum(auditActionValues).optional(),
    actorId: z.string().uuid().optional(),
    from: isoDateSchema.optional(),
    to: isoDateSchema.optional(),
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export type AuditIdParam = z.infer<typeof auditIdParamSchema>;
export type ListAuditLogsQuery = z.infer<typeof listAuditLogsQuerySchema>;
