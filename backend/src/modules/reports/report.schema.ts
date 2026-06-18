import { z } from 'zod';

const reportStatusSchema = z.enum(['PENDING', 'INVESTIGATING', 'RESOLVED']);

export const reportIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export const createReportSchema = z
  .object({
    title: z.string().trim().min(1).max(200),
    body: z.string().trim().min(1).max(5000),
  })
  .strict();

export const listReportsQuerySchema = z
  .object({
    status: reportStatusSchema.optional(),
    q: z.string().trim().min(1).max(200).optional(),
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export const changeReportStatusSchema = z
  .object({
    status: reportStatusSchema,
  })
  .strict();

export type ReportIdParam = z.infer<typeof reportIdParamSchema>;
export type CreateReportInput = z.infer<typeof createReportSchema>;
export type ListReportsQuery = z.infer<typeof listReportsQuerySchema>;
export type ChangeReportStatusInput = z.infer<typeof changeReportStatusSchema>;
