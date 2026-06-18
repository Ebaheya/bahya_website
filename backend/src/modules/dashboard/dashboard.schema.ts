import { z } from 'zod';

export const activityQuerySchema = z
  .object({
    limit: z.coerce.number().int().min(1).max(50).default(10),
  })
  .strict();

export type ActivityQuery = z.infer<typeof activityQuerySchema>;
