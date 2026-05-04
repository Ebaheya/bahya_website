import { z } from 'zod';

export const financialsSchema = z
  .object({
    incomeBracket: z.string().nullable().optional(),
    notes: z.string().nullable().optional(),
  })
  .strict();
