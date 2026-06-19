import { z } from 'zod';

export const socialStatusSchema = z
  .object({
    maritalStatus: z.string().nullable().optional(),
    familySupport: z.string().nullable().optional(),
    notes: z.string().nullable().optional(),
  })
  .strict();
