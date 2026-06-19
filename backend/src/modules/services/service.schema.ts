import { z } from 'zod';

const dateOnly = z
  .string()
  .datetime({ offset: true })
  .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
  .transform((value) => new Date(value))
  .refine((value) => !Number.isNaN(value.getTime()), 'Invalid date');

const optionalDateOnly = dateOnly.nullable().optional();
const optionalText = z.string().trim().min(1).max(500).nullable().optional();
const startTime = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'Invalid start time');

export const createServiceSchema = z
  .object({
    categoryId: z.string().uuid(),
    name: z.string().trim().min(1).max(120),
    locationBranch: z.string().trim().min(1).max(200),
    startDate: dateOnly,
    startTime,
    endDate: optionalDateOnly,
    departureTime: optionalText,
    meetingPlace: optionalText,
    capacity: z.number().int().min(1),
  })
  .strict();

export const updateServiceSchema = z
  .object({
    categoryId: z.string().uuid().optional(),
    name: z.string().trim().min(1).max(120).optional(),
    locationBranch: z.string().trim().min(1).max(200).optional(),
    startDate: dateOnly.optional(),
    startTime: startTime.optional(),
    endDate: optionalDateOnly,
    departureTime: optionalText,
    meetingPlace: optionalText,
    capacity: z.number().int().min(1).optional(),
    status: z.enum(['ACTIVE', 'CLOSED']).optional(),
  })
  .strict();

export const listServicesQuerySchema = z
  .object({
    kind: z.enum(['EDUCATIONAL', 'TRIP', 'SUPPORT', 'OTHER']).optional(),
    categoryId: z.string().uuid().optional(),
    q: z.string().trim().min(1).max(120).optional(),
    status: z.enum(['ACTIVE', 'CLOSED']).optional(),
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export const serviceIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export type CreateServiceInput = z.infer<typeof createServiceSchema>;
export type UpdateServiceInput = z.infer<typeof updateServiceSchema>;
export type ListServicesQuery = z.infer<typeof listServicesQuerySchema>;
export type ServiceIdParam = z.infer<typeof serviceIdParamSchema>;
