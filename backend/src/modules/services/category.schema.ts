import { z } from 'zod';

const serviceKind = z.enum(['EDUCATIONAL', 'TRIP', 'SUPPORT', 'OTHER']);
const color = z.string().regex(/^#[0-9A-Fa-f]{6}$/, 'Invalid category color');

export const createCategorySchema = z
  .object({
    name: z.string().trim().min(1).max(80),
    kind: serviceKind,
    iconKey: z.string().trim().min(1).max(80),
    color,
  })
  .strict();

export const updateCategorySchema = z
  .object({
    name: z.string().trim().min(1).max(80).optional(),
    kind: serviceKind.optional(),
    iconKey: z.string().trim().min(1).max(80).optional(),
    color: color.optional(),
  })
  .strict();

export const categoryStatusSchema = z
  .object({
    isActive: z.boolean(),
  })
  .strict();

export const listCategoriesQuerySchema = z
  .object({
    kind: serviceKind.optional(),
    isActive: z
      .enum(['true', 'false'])
      .transform((value) => value === 'true')
      .optional(),
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export const categoryIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export type CreateCategoryInput = z.infer<typeof createCategorySchema>;
export type UpdateCategoryInput = z.infer<typeof updateCategorySchema>;
export type CategoryStatusInput = z.infer<typeof categoryStatusSchema>;
export type ListCategoriesQuery = z.infer<typeof listCategoriesQuerySchema>;
export type CategoryIdParam = z.infer<typeof categoryIdParamSchema>;
