import { z } from 'zod';

export const createAssessmentSchema = z
  .object({
    patientId: z.string().uuid(),
    submissionId: z.string().uuid().nullish(),
    templateKey: z.string().trim().min(1).max(100),
    score: z.number().int().nonnegative().nullish(),
    status: z.enum(['NORMAL', 'MILD', 'MODERATE', 'SEVERE', 'CRITICAL']),
    doctorNote: z.string().trim().max(5000).nullish(),
  })
  .strict();

export const assessmentIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export const submissionIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export const assessmentPatientIdParamSchema = z
  .object({
    patientId: z.string().uuid(),
  })
  .strict();

export type CreateAssessmentInput = z.infer<typeof createAssessmentSchema>;
