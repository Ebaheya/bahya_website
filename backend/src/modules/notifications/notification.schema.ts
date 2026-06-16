import { z } from 'zod';

const notificationStatus = z.enum(['UNREAD', 'READ', 'DONE']);
const notificationSeverity = z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']);
const devicePlatform = z.enum(['ANDROID', 'IOS', 'WEB']);

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

export const registerDeviceSchema = z
  .object({
    token: z.string().trim().min(1),
    platform: devicePlatform,
  })
  .strict();

export const unregisterDeviceSchema = z
  .object({
    token: z.string().trim().min(1),
  })
  .strict();

export type RegisterDeviceBody = z.infer<typeof registerDeviceSchema>;
export type UnregisterDeviceBody = z.infer<typeof unregisterDeviceSchema>;
