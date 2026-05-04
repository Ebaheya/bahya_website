import { z } from 'zod';
import { financialsSchema } from './validators/financials';
import { medicalHistorySchema } from './validators/medicalHistory';
import { socialStatusSchema } from './validators/socialStatus';

const phone = z.string().regex(/^\+?[0-9]{8,15}$/, 'Invalid phone number');

const dateOfBirth = z
  .string()
  .datetime({ offset: true })
  .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
  .transform((value) => new Date(value))
  .refine((value) => !Number.isNaN(value.getTime()), 'Invalid date of birth')
  .refine((value) => value.getTime() < Date.now(), 'Date of birth must be in the past')
  .refine((value) => {
    const oldest = new Date();
    oldest.setFullYear(oldest.getFullYear() - 130);
    return value >= oldest;
  }, 'Date of birth must be within the last 130 years');

export const createPatientSchema = z
  .object({
    fullName: z.string().trim().min(2, 'Full name too short').max(120),
    email: z.string().email('Invalid email').max(254).toLowerCase(),
    password: z.string().min(8, 'Password must be at least 8 characters').max(128),
    phone,
    dateOfBirth: dateOfBirth.optional(),
    gender: z.enum(['MALE', 'FEMALE', 'OTHER']).optional(),
    address: z.string().trim().min(1).optional(),
    emergencyContactName: z.string().trim().min(1).optional(),
    emergencyContactPhone: phone.optional(),
    medicalHistory: medicalHistorySchema.optional(),
    socialStatus: socialStatusSchema.optional(),
    financials: financialsSchema.optional(),
  })
  .strict();

export const patchPatientSchema = z
  .object({
    phone: phone.optional(),
    dateOfBirth: dateOfBirth.nullable().optional(),
    gender: z.enum(['MALE', 'FEMALE', 'OTHER']).nullable().optional(),
    address: z.string().trim().min(1).nullable().optional(),
    emergencyContactName: z.string().trim().min(1).nullable().optional(),
    emergencyContactPhone: phone.nullable().optional(),
    medicalHistory: medicalHistorySchema.optional(),
    socialStatus: socialStatusSchema.optional(),
    financials: financialsSchema.optional(),
  })
  .strict();

export const queryPatientsSchema = z
  .object({
    q: z.string().trim().min(1).optional(),
    phone: phone.optional(),
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
export type PatientTimelineQuery = z.infer<typeof patientTimelineQuerySchema>;
export type PatientIdParam = z.infer<typeof patientIdParamSchema>;
