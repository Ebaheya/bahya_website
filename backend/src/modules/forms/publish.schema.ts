import { z } from 'zod';

const publishAtSchema = z
  .string()
  .datetime({ offset: true })
  .transform((value) => new Date(value))
  .nullable()
  .optional();

export const publishFormSchema = z.discriminatedUnion('target', [
  z
    .object({
      target: z.literal('SINGLE_PATIENT'),
      patientId: z.string().uuid(),
      publishAt: publishAtSchema,
    })
    .strict(),
  z
    .object({
      target: z.literal('ALL_PATIENTS'),
      publishAt: publishAtSchema,
    })
    .strict(),
  z
    .object({
      target: z.literal('VOLUNTEER_FOR_PATIENT'),
      patientId: z.string().uuid(),
      volunteerId: z.string().uuid(),
      publishAt: publishAtSchema,
    })
    .strict(),
]);

export const assignmentIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export type PublishFormInput = z.infer<typeof publishFormSchema>;
