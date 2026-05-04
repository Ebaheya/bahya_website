import { Prisma, type Role } from '@prisma/client';
import type { Request } from 'express';
import mongoose from 'mongoose';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import { hashPassword } from '../../utils/passwords';
import type {
  CreatePatientInput,
  PatchPatientInput,
  QueryPatientsInput,
} from './patient.schema';

const patientInclude = {
  user: {
    select: {
      id: true,
      email: true,
      fullName: true,
      role: true,
      isActive: true,
    },
  },
} as const;

type PatientWithUser = Prisma.PatientGetPayload<{ include: typeof patientInclude }>;

interface TimelineItem {
  kind: 'ASSESSMENT' | 'INTERVENTION';
  id: string;
  timestamp: Date;
  summary: string;
}

interface AssessmentDelegate {
  findMany(args: {
    where: { patientId: string };
    orderBy: { createdAt: 'desc' };
    take: number;
  }): Promise<Array<Record<string, unknown>>>;
  count(args: { where: { patientId: string } }): Promise<number>;
}

export function sanitizePatientResponse(patient: PatientWithUser) {
  const { user, ...patientFields } = patient;

  return {
    ...patientFields,
    userId: user.id,
    fullName: user.fullName,
    email: user.email,
    role: user.role,
    isActive: user.isActive,
  };
}

export function projectForRole<T extends Record<string, unknown>>(
  patient: T,
  role: Role
): T {
  if (role !== 'VOLUNTEER') return patient;
  const copy: Record<string, unknown> = { ...patient };
  delete copy.financials;
  return copy as T;
}

function isUniqueConstraintError(err: unknown): err is Prisma.PrismaClientKnownRequestError {
  return err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002';
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function normalizeJsonBlock(value: Prisma.JsonValue | null): Record<string, unknown> | null {
  if (!isRecord(value)) return null;
  return Object.keys(value).length > 0 ? { ...value } : null;
}

function mergeJsonBlock(
  current: Prisma.JsonValue | null,
  patch: Record<string, unknown>
): Record<string, unknown> | null {
  const merged = normalizeJsonBlock(current) ?? {};

  for (const [key, value] of Object.entries(patch)) {
    if (value === null) {
      delete merged[key];
    } else {
      merged[key] = value;
    }
  }

  return Object.keys(merged).length > 0 ? merged : null;
}

function jsonForPrisma(value: Record<string, unknown> | null) {
  return value === null ? Prisma.JsonNull : (value as Prisma.InputJsonValue);
}

function stableJson(value: unknown): string {
  return JSON.stringify(value ?? null);
}

function asDate(value: unknown): Date {
  if (value instanceof Date) return value;
  if (typeof value === 'string' || typeof value === 'number') {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) return parsed;
  }
  return new Date(0);
}

function asId(value: unknown): string {
  if (value === null || value === undefined) return '';
  return String(value);
}

function asSummary(value: Record<string, unknown>, fallback: string): string {
  if (typeof value.summary === 'string' && value.summary.trim()) return value.summary;
  if (typeof value.notes === 'string' && value.notes.trim()) return value.notes;
  if (typeof value.type === 'string' && value.type.trim()) return value.type;
  return fallback;
}

async function getAssessmentTimelineItems(
  patientId: string,
  limit: number
): Promise<{ data: TimelineItem[]; total: number }> {
  const assessmentDelegate = (prisma as unknown as { assessment?: AssessmentDelegate })
    .assessment;

  if (!assessmentDelegate) return { data: [], total: 0 };

  const [rows, total] = await Promise.all([
    assessmentDelegate.findMany({
      where: { patientId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    }),
    assessmentDelegate.count({ where: { patientId } }),
  ]);

  return {
    data: rows.map((row) => ({
      kind: 'ASSESSMENT',
      id: asId(row.id),
      timestamp: asDate(row.createdAt),
      summary: asSummary(row, 'Assessment'),
    })),
    total,
  };
}

async function getInterventionTimelineItems(
  patientId: string,
  limit: number
): Promise<{ data: TimelineItem[]; total: number }> {
  if (mongoose.connection.readyState !== 1) {
    throw new AppError(
      503,
      'DEPENDENCY_FAILURE',
      'MongoDB is unavailable for patient timeline'
    );
  }

  const interventions = mongoose.connection.collection('interventions');
  const query = { patientId };
  const [rows, total] = await Promise.all([
    interventions.find(query).sort({ createdAt: -1 }).limit(limit).toArray(),
    interventions.countDocuments(query),
  ]);

  return {
    data: rows.map((row) => ({
      kind: 'INTERVENTION',
      id: asId(row._id),
      timestamp: asDate(row.createdAt),
      summary: asSummary(row, 'Intervention'),
    })),
    total,
  };
}

export async function createPatient(
  input: CreatePatientInput,
  actorId: string,
  req?: Request
) {
  const passwordHash = await hashPassword(input.password);

  let patient: PatientWithUser;
  try {
    patient = await prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          email: input.email,
          fullName: input.fullName,
          passwordHash,
          role: 'PATIENT',
        },
        select: { id: true },
      });

      return tx.patient.create({
        data: {
          userId: user.id,
          phone: input.phone,
          dateOfBirth: input.dateOfBirth,
          gender: input.gender,
          address: input.address,
          emergencyContactName: input.emergencyContactName,
          emergencyContactPhone: input.emergencyContactPhone,
          medicalHistory: input.medicalHistory ?? Prisma.JsonNull,
          socialStatus: input.socialStatus ?? Prisma.JsonNull,
          financials: input.financials ?? Prisma.JsonNull,
        },
        include: patientInclude,
      });
    });
  } catch (err) {
    if (isUniqueConstraintError(err)) {
      throw AppError.conflict('Email already registered');
    }
    throw err;
  }

  const response = sanitizePatientResponse(patient);

  await writeAudit({
    actorId,
    action: 'USER_CREATED',
    entityType: 'PATIENT',
    entityId: patient.id,
    newValues: {
      email: response.email,
      role: response.role,
      fullName: response.fullName,
    },
    req,
  });

  return response;
}

export async function getPatientById(patientId: string) {
  const patient = await prisma.patient.findUnique({
    where: { id: patientId },
    include: patientInclude,
  });

  return patient ? sanitizePatientResponse(patient) : null;
}

export async function listPatients(query: QueryPatientsInput) {
  const where: Prisma.PatientWhereInput = {};

  if (query.q) {
    where.OR = [
      { user: { fullName: { contains: query.q, mode: 'insensitive' } } },
      { user: { email: { contains: query.q, mode: 'insensitive' } } },
    ];
  }
  if (query.phone) where.phone = query.phone;

  const skip = (query.page - 1) * query.pageSize;
  const take = query.pageSize;

  const [patients, total] = await prisma.$transaction([
    prisma.patient.findMany({
      where,
      include: patientInclude,
      orderBy: { createdAt: 'desc' },
      skip,
      take,
    }),
    prisma.patient.count({ where }),
  ]);

  return {
    data: patients.map(sanitizePatientResponse),
    page: query.page,
    pageSize: query.pageSize,
    total,
  };
}

export async function patchPatient(
  patientId: string,
  data: PatchPatientInput,
  actorId: string,
  req?: Request
) {
  const patient = await prisma.patient.findUnique({
    where: { id: patientId },
    include: patientInclude,
  });
  if (!patient) throw AppError.notFound('Patient not found');

  const updateData: Prisma.PatientUpdateInput = {};
  const oldValues: Record<string, unknown> = {};
  const newValues: Record<string, unknown> = {};

  const setScalar = <K extends keyof Pick<
    PatchPatientInput,
    | 'phone'
    | 'gender'
    | 'address'
    | 'emergencyContactName'
    | 'emergencyContactPhone'
  >>(
    key: K,
    current: PatientWithUser[K],
    next: PatchPatientInput[K]
  ) => {
    if (next === undefined || current === next) return;

    updateData[key] = next as never;
    oldValues[key] = current;
    newValues[key] = next;
  };

  setScalar('phone', patient.phone, data.phone);
  setScalar('gender', patient.gender, data.gender);
  setScalar('address', patient.address, data.address);
  setScalar('emergencyContactName', patient.emergencyContactName, data.emergencyContactName);
  setScalar('emergencyContactPhone', patient.emergencyContactPhone, data.emergencyContactPhone);

  if (data.dateOfBirth !== undefined) {
    const next = data.dateOfBirth;
    const currentTime = patient.dateOfBirth?.getTime() ?? null;
    const nextTime = next?.getTime() ?? null;

    if (currentTime !== nextTime) {
      updateData.dateOfBirth = next;
      oldValues.dateOfBirth = patient.dateOfBirth;
      newValues.dateOfBirth = next;
    }
  }

  const setJsonBlock = (
    key: 'medicalHistory' | 'socialStatus' | 'financials',
    patch: Record<string, unknown> | undefined
  ) => {
    if (patch === undefined) return;

    const current = normalizeJsonBlock(patient[key]);
    const next = mergeJsonBlock(patient[key], patch);
    if (stableJson(current) === stableJson(next)) return;

    updateData[key] = jsonForPrisma(next);
    oldValues[key] = current;
    newValues[key] = next;
  };

  setJsonBlock('medicalHistory', data.medicalHistory);
  setJsonBlock('socialStatus', data.socialStatus);
  setJsonBlock('financials', data.financials);

  if (Object.keys(updateData).length === 0) {
    return sanitizePatientResponse(patient);
  }

  const updated = await prisma.patient.update({
    where: { id: patientId },
    data: updateData,
    include: patientInclude,
  });

  await writeAudit({
    actorId,
    action: 'PATIENT_UPDATED',
    entityType: 'PATIENT',
    entityId: patientId,
    oldValues,
    newValues,
    req,
  });

  return sanitizePatientResponse(updated);
}

export async function getPatientTimeline(
  patientId: string,
  page: number,
  pageSize: number
) {
  const limit = page * pageSize;
  const skip = (page - 1) * pageSize;

  const [assessments, interventions] = await Promise.all([
    getAssessmentTimelineItems(patientId, limit),
    getInterventionTimelineItems(patientId, limit),
  ]);

  const data = [...assessments.data, ...interventions.data]
    .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
    .slice(skip, skip + pageSize)
    .map((item) => ({
      ...item,
      timestamp: item.timestamp.toISOString(),
    }));

  return {
    data,
    page,
    pageSize,
    total: assessments.total + interventions.total,
  };
}
