import { z } from 'zod';
import { financialsSchema } from './validators/financials';
import { medicalHistorySchema } from './validators/medicalHistory';
import { socialStatusSchema } from './validators/socialStatus';

const phone = z.string().regex(/^\+?[0-9]{8,15}$/, 'Invalid phone number');

const crn = z
  .string()
  .trim()
  .regex(/^[A-Za-z0-9-]{1,32}$/, 'Invalid CRN');

// Clinical enums mirror the Prisma enums in schema.prisma. Kept as string
// literals (like `gender`) to avoid coupling validation to the generated client.
const menopausalStatus = z.enum(['PRE_MENOPAUSAL', 'PERI_MENOPAUSAL', 'POST_MENOPAUSAL']);
const stageAtDiagnosis = z.enum(['STAGE_0', 'STAGE_I', 'STAGE_II', 'STAGE_III', 'STAGE_IV']);
const diseaseStatus = z.enum([
  'NEWLY_DIAGNOSED',
  'ACTIVE_TREATMENT',
  'FOLLOW_UP',
  'RECURRENCE',
  'METASTATIC',
]);
const tumorBiology = z.enum(['LUMINAL_A', 'LUMINAL_B', 'HER2_ENRICHED', 'TNBC']);
const surgery = z.enum(['NONE', 'BREAST_CONSERVATIVE', 'MASTECTOMY']);
const chemotherapy = z.enum(['NO', 'NEOADJUVANT', 'ADJUVANT', 'METASTATIC']);

const bmi = z.number().min(5, 'BMI too low').max(100, 'BMI too high');

const dateOnly = z
  .string()
  .datetime({ offset: true })
  .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
  .transform((value) => new Date(value))
  .refine((value) => !Number.isNaN(value.getTime()), 'Invalid date');

const dateOfBirth = dateOnly
  .refine((value) => value.getTime() < Date.now() + 86400000, 'Date of birth must be in the past')
  .refine((value) => {
    const oldest = new Date();
    oldest.setFullYear(oldest.getFullYear() - 130);
    return value >= oldest;
  }, 'Date of birth must be within the last 130 years');

const dateOfDiagnosis = dateOnly.refine(
  (value) => value.getTime() <= Date.now() + 86400000,
  'Date of diagnosis cannot be in the future'
);

// Query-string booleans: z.coerce.boolean treats "false" as true, so parse the
// literal "true"/"false" instead.
const queryBoolean = z.enum(['true', 'false']).transform((value) => value === 'true');

// Clinical fields shared between create and patch (typed columns).
const clinicalCreateFields = {
  bmi: bmi.optional(),
  menopausalStatus: menopausalStatus.optional(),
  dateOfDiagnosis: dateOfDiagnosis.optional(),
  stageAtDiagnosis: stageAtDiagnosis.optional(),
  diseaseStatus: diseaseStatus.optional(),
  tumorBiology: tumorBiology.optional(),
  surgery: surgery.optional(),
  chemotherapy: chemotherapy.optional(),
  radiotherapy: z.boolean().optional(),
  hormonalTherapy: z.boolean().optional(),
  targetedTherapy: z.boolean().optional(),
  immunotherapy: z.boolean().optional(),
};

const clinicalPatchFields = {
  bmi: bmi.nullable().optional(),
  menopausalStatus: menopausalStatus.nullable().optional(),
  dateOfDiagnosis: dateOfDiagnosis.nullable().optional(),
  stageAtDiagnosis: stageAtDiagnosis.nullable().optional(),
  diseaseStatus: diseaseStatus.nullable().optional(),
  tumorBiology: tumorBiology.nullable().optional(),
  surgery: surgery.nullable().optional(),
  chemotherapy: chemotherapy.nullable().optional(),
  radiotherapy: z.boolean().nullable().optional(),
  hormonalTherapy: z.boolean().nullable().optional(),
  targetedTherapy: z.boolean().nullable().optional(),
  immunotherapy: z.boolean().nullable().optional(),
};

export const createPatientSchema = z
  .object({
    fullName: z.string().trim().min(2, 'Full name too short').max(120),
    email: z.string().email('Invalid email').max(254).toLowerCase(),
    password: z.string().min(8, 'Password must be at least 8 characters').max(128),
    crn,
    phone,
    dateOfBirth: dateOfBirth.optional(),
    gender: z.enum(['MALE', 'FEMALE', 'OTHER']).optional(),
    address: z.string().trim().min(1).optional(),
    emergencyContactName: z.string().trim().min(1).optional(),
    emergencyContactPhone: phone.optional(),
    medicalHistory: medicalHistorySchema.optional(),
    socialStatus: socialStatusSchema.optional(),
    financials: financialsSchema.optional(),
    ...clinicalCreateFields,
  })
  .strict();

export const patchPatientSchema = z
  .object({
    crn: crn.optional(),
    phone: phone.optional(),
    dateOfBirth: dateOfBirth.nullable().optional(),
    gender: z.enum(['MALE', 'FEMALE', 'OTHER']).nullable().optional(),
    address: z.string().trim().min(1).nullable().optional(),
    emergencyContactName: z.string().trim().min(1).nullable().optional(),
    emergencyContactPhone: phone.nullable().optional(),
    medicalHistory: medicalHistorySchema.optional(),
    socialStatus: socialStatusSchema.optional(),
    financials: financialsSchema.optional(),
    ...clinicalPatchFields,
  })
  .strict();

export const queryPatientsSchema = z
  .object({
    q: z.string().trim().min(1).optional(),
    phone: phone.optional(),
    surgery: surgery.optional(),
    chemotherapy: chemotherapy.optional(),
    tumorBiology: tumorBiology.optional(),
    diseaseStatus: diseaseStatus.optional(),
    radiotherapy: queryBoolean.optional(),
    hormonalTherapy: queryBoolean.optional(),
    targetedTherapy: queryBoolean.optional(),
    immunotherapy: queryBoolean.optional(),
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export const listPatientOptionsQuerySchema = z
  .object({
    q: z.string().trim().min(1).max(120).optional(),
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export const patientTimelineQuerySchema = z
  .object({
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export const patientIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export type CreatePatientInput = z.infer<typeof createPatientSchema>;
export type PatchPatientInput = z.infer<typeof patchPatientSchema>;
export type QueryPatientsInput = z.infer<typeof queryPatientsSchema>;
export type ListPatientOptionsQuery = z.infer<typeof listPatientOptionsQuerySchema>;
export type PatientTimelineQuery = z.infer<typeof patientTimelineQuerySchema>;
export type PatientIdParam = z.infer<typeof patientIdParamSchema>;
