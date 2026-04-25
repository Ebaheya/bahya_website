import { z } from 'zod';

const password = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .max(128, 'Password too long');

const email = z.string().email('Invalid email').max(254).toLowerCase();

const fullName = z.string().trim().min(2, 'Full name too short').max(120);

export const registerStaffSchema = z.object({
  email,
  password,
  fullName,
  role: z.enum(['ADMIN', 'DOCTOR', 'VOLUNTEER', 'CALL_CENTER']),
});

export const registerPatientSchema = z.object({
  email,
  password,
  fullName,
});

export const loginSchema = z.object({
  email,
  password: z.string().min(1, 'Password required').max(128),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

export const logoutSchema = z.object({
  refreshToken: z.string().min(1),
});

export type RegisterStaffInput = z.infer<typeof registerStaffSchema>;
export type RegisterPatientInput = z.infer<typeof registerPatientSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshInput = z.infer<typeof refreshSchema>;
export type LogoutInput = z.infer<typeof logoutSchema>;
