import { z } from 'zod';

// Optional ISO datetime (with offset) transformed to a Date. Reused for both the
// scheduled publish time and the optional due/expiry time.
const optionalDateTimeSchema = z
  .string()
  .datetime({ offset: true })
  .transform((value) => new Date(value))
  .nullable()
  .optional();

const publishAtSchema = optionalDateTimeSchema;
// When set, the assignment can no longer be filled after this instant. The
// relationship to publishAt (must be later) is validated in the service.
const dueAtSchema = optionalDateTimeSchema;

export const publishFormSchema = z.discriminatedUnion('target', [
  z
    .object({
      target: z.literal('SINGLE_PATIENT'),
      patientId: z.string().uuid(),
      publishAt: publishAtSchema,
      dueAt: dueAtSchema,
    })
    .strict(),
  z
    .object({
      target: z.literal('ALL_PATIENTS'),
      publishAt: publishAtSchema,
      dueAt: dueAtSchema,
    })
    .strict(),
  z
    .object({
      target: z.literal('SELECTED_PATIENTS'),
      patientIds: z.array(z.string().uuid()).min(1).max(200),
      publishAt: publishAtSchema,
      dueAt: dueAtSchema,
    })
    .strict(),
  z
    .object({
      target: z.literal('VOLUNTEER_FOR_PATIENT'),
      patientId: z.string().uuid(),
      volunteerId: z.string().uuid(),
      publishAt: publishAtSchema,
      dueAt: dueAtSchema,
    })
    .strict(),
]);

export const assignmentIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export const listAssignmentsQuerySchema = z
  .object({
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export type PublishFormInput = z.infer<typeof publishFormSchema>;
export type ListAssignmentsQuery = z.infer<typeof listAssignmentsQuerySchema>;
