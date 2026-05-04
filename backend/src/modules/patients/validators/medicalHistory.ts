import { z } from 'zod';

export const medicalHistorySchema = z
  .object({
    allergies: z.array(z.string()).nullable().optional(),
    conditions: z.array(z.string()).nullable().optional(),
    notes: z.string().nullable().optional(),
  })
  .strict();
