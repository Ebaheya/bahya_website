import { z } from 'zod';

export const userIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export const patchUserSchema = z
  .object({
    fullName: z.string().trim().min(2, 'Full name too short').max(120).optional(),
  })
  .strict();

export const patchUserStatusSchema = z
  .object({
    isActive: z.boolean(),
  })
  .strict();

export const listUsersQuerySchema = z
  .object({
    q: z.string().trim().min(1).optional(),
    role: z.enum(['ADMIN', 'DOCTOR', 'VOLUNTEER', 'CALL_CENTER', 'PATIENT']).optional(),
    isActive: z
      .enum(['true', 'false'])
      .transform((value) => value === 'true')
      .optional(),
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export type UserIdParam = z.infer<typeof userIdParamSchema>;
export type PatchUserInput = z.infer<typeof patchUserSchema>;
export type PatchUserStatusInput = z.infer<typeof patchUserStatusSchema>;
export type ListUsersQuery = z.infer<typeof listUsersQuerySchema>;
