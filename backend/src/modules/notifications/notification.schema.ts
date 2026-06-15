import { z } from 'zod';

const notificationStatus = z.enum(['UNREAD', 'READ', 'DONE']);
const notificationSeverity = z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']);

// GET /notifications/my — list filters + pagination (newest-first).
export const listMyNotificationsQuerySchema = z
  .object({
    status: notificationStatus.optional(),
    severity: notificationSeverity.optional(),
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export type ListMyNotificationsQuery = z.infer<typeof listMyNotificationsQuerySchema>;

// MongoDB ObjectId (24 hex chars) — notifications live in MongoDB, not PostgreSQL,
// so the id is an ObjectId rather than a UUID.
export const notificationIdParamSchema = z
  .object({
    id: z.string().regex(/^[a-fA-F0-9]{24}$/, 'Invalid notification id'),
  })
  .strict();

export type NotificationIdParam = z.infer<typeof notificationIdParamSchema>;
