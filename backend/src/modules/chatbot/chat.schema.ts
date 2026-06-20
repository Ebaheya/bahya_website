import { z } from 'zod';

const objectId = z.string().regex(/^[a-f\d]{24}$/i, 'Invalid ObjectId');

const paginationSchema = z
  .object({
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export const messageBodySchema = z
  .object({
    sessionId: objectId.optional().nullable().transform((value) => value ?? undefined),
    message: z.string().trim().min(1).max(4000),
  })
  .strict();

export const sessionIdParamSchema = z
  .object({
    id: objectId,
  })
  .strict();

export const sessionsListQuerySchema = paginationSchema.extend({
  patientId: z.string().uuid().optional(),
});

export const messagesQuerySchema = paginationSchema;

export type MessageBody = z.infer<typeof messageBodySchema>;
export type SessionIdParam = z.infer<typeof sessionIdParamSchema>;
export type SessionsListQuery = z.infer<typeof sessionsListQuerySchema>;
export type MessagesQuery = z.infer<typeof messagesQuerySchema>;
