import { Prisma, type Role } from '@prisma/client';
import type { Request } from 'express';
import mongoose from 'mongoose';
import { prisma } from '../../config/prisma';
import { logger } from '../../config/logger';
import { writeAudit, type AuditInput } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import { hashPassword } from '../../utils/passwords';
import type {
  CreatePatientInput,
  ListPatientOptionsQuery,
  PatchPatientInput,
  QueryPatientsInput,
} from './patient.schema';

// USER_CREATED and PATIENT_CREATED are strict-tier, but createPatient writes
// them after both rows have committed. A 503 here would surface the create as
// failed even though it succeeded; client retries would then trip the email
// uniqueness constraint and report the patient as un-creatable.
async function writeCommittedPatientCreatedAudit(input: AuditInput): Promise<void> {
  try {
    await writeAudit(input);
  } catch (err) {
    if (err instanceof AppError && err.code === 'AUDIT_UNAVAILABLE') {
      logger.error(
        {
          err,
          metric: 'audit_write_failure',
          action: input.action,
          tier: 'strict_post_commit',
          actorId: input.actorId ?? null,
          entityType: input.entityType ?? null,
          entityId: input.entityId ?? null,
        },
        'post-commit patient-created audit failed; preserving successful response'
      );
      return;
    }
    throw err;
  }
}

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

const maxTimelineMergeWindow = 1000;

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

type TimelineSourceResult = { data: TimelineItem[]; total: number };

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

// Volunteers see only basic identity/contact info — none of the clinical record,
// medical history, social status, or financials.
const VOLUNTEER_RESTRICTED_FIELDS = [
  'financials',
  'socialStatus',
  'medicalHistory',
  'bmi',
  'menopausalStatus',
  'dateOfDiagnosis',
  'stageAtDiagnosis',
  'diseaseStatus',
  'tumorBiology',
  'surgery',
  'chemotherapy',
  'radiotherapy',
  'hormonalTherapy',
  'targetedTherapy',
  'immunotherapy',
] as const;

export function projectForRole<T extends Record<string, unknown>>(
  patient: T,
  role: Role
): T {
  // Fast path: clinical/admin roles see the full record (incl. assessment scores).
  if (role === 'DOCTOR' || role === 'ADMIN') return patient;

  const copy: Record<string, unknown> = { ...patient };
  if (role === 'VOLUNTEER') {
    for (const field of VOLUNTEER_RESTRICTED_FIELDS) delete copy[field];
  }
  // Latest assessment scores are clinical data — restrict to DOCTOR/ADMIN.
  delete copy.latestAssessments;
  return copy as T;
}

function isUniqueConstraintError(err: unknown): err is Prisma.PrismaClientKnownRequestError {
  return err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002';
}

function uniqueConstraintTargets(
  err: Prisma.PrismaClientKnownRequestError
): string[] {
  const target = err.meta?.target;
  if (Array.isArray(target)) return target.map(String);
  if (typeof target === 'string') return [target];
  return [];
}

// Maps a P2002 to the field that actually collided. CRN and email are both
// unique on the patient-creation path, so the message must tell them apart.
function conflictForUniqueError(err: Prisma.PrismaClientKnownRequestError): AppError {
  const targets = uniqueConstraintTargets(err);
  if (targets.some((field) => field.toLowerCase().includes('crn'))) {
    return AppError.conflict('CRN already in use');
  }
  return AppError.conflict('Email already registered');
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

function canonicalizeJson(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(canonicalizeJson);

  if (isRecord(value)) {
    return Object.keys(value)
      .sort()
      .reduce<Record<string, unknown>>((result, key) => {
        result[key] = canonicalizeJson(value[key]);
        return result;
      }, {});
  }

  return value ?? null;
}

function stableJson(value: unknown): string {
  return JSON.stringify(canonicalizeJson(value));
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

function isAssessmentDelegate(value: unknown): value is AssessmentDelegate {
  return (
    isRecord(value) &&
    typeof value.findMany === 'function' &&
    typeof value.count === 'function'
  );
}

function getAssessmentDelegate(): AssessmentDelegate | null {
  const delegate = Reflect.get(prisma, 'assessment');
  return isAssessmentDelegate(delegate) ? delegate : null;
}

async function getAssessmentTimelineItems(
  patientId: string,
  limit: number
): Promise<TimelineSourceResult> {
  const assessmentDelegate = getAssessmentDelegate();
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
): Promise<TimelineSourceResult> {
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
  let patient: PatientWithUser;
  try {
    patient = await prisma.$transaction(async (tx) => {
      // Pre-check inside the tx to surface email collisions before paying the
      // bcrypt cost (~200ms) on every conflicting submission. The unique
      // constraint on User.email remains the authoritative backstop for the
      // race window between this check and the create.
      const existing = await tx.user.findUnique({
        where: { email: input.email },
        select: { id: true },
      });
      if (existing) throw AppError.conflict('Email already registered');

      const passwordHash = await hashPassword(input.password);

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
          crn: input.crn,
          phone: input.phone,
          dateOfBirth: input.dateOfBirth,
          gender: input.gender,
          address: input.address,
          emergencyContactName: input.emergencyContactName,
          emergencyContactPhone: input.emergencyContactPhone,
          medicalHistory: input.medicalHistory ?? Prisma.JsonNull,
          socialStatus: input.socialStatus ?? Prisma.JsonNull,
          financials: input.financials ?? Prisma.JsonNull,
          bmi: input.bmi,
          menopausalStatus: input.menopausalStatus,
          dateOfDiagnosis: input.dateOfDiagnosis,
          stageAtDiagnosis: input.stageAtDiagnosis,
          diseaseStatus: input.diseaseStatus,
          tumorBiology: input.tumorBiology,
          surgery: input.surgery,
          chemotherapy: input.chemotherapy,
          radiotherapy: input.radiotherapy,
          hormonalTherapy: input.hormonalTherapy,
          targetedTherapy: input.targetedTherapy,
          immunotherapy: input.immunotherapy,
        },
        include: patientInclude,
      });
    });
  } catch (err) {
    if (isUniqueConstraintError(err)) {
      throw conflictForUniqueError(err);
    }
    throw err;
  }

  const response = sanitizePatientResponse(patient);

  await writeCommittedPatientCreatedAudit({
    actorId,
    action: 'USER_CREATED',
    entityType: 'USER',
    entityId: patient.user.id,
    newValues: {
      email: response.email,
      role: response.role,
      fullName: response.fullName,
    },
    req,
  });

  await writeCommittedPatientCreatedAudit({
    actorId,
    action: 'PATIENT_CREATED',
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
    // The list-screen search box matches by name, email, or file number (CRN).
    where.OR = [
      { user: { fullName: { contains: query.q, mode: 'insensitive' } } },
      { user: { email: { contains: query.q, mode: 'insensitive' } } },
      { crn: { contains: query.q, mode: 'insensitive' } },
    ];
  }
  if (query.phone) where.phone = query.phone;
  if (query.surgery) where.surgery = query.surgery;
  if (query.chemotherapy) where.chemotherapy = query.chemotherapy;
  if (query.tumorBiology) where.tumorBiology = query.tumorBiology;
  if (query.diseaseStatus) where.diseaseStatus = query.diseaseStatus;
  if (query.radiotherapy !== undefined) where.radiotherapy = query.radiotherapy;
  if (query.hormonalTherapy !== undefined) where.hormonalTherapy = query.hormonalTherapy;
  if (query.targetedTherapy !== undefined) where.targetedTherapy = query.targetedTherapy;
  if (query.immunotherapy !== undefined) where.immunotherapy = query.immunotherapy;

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

  const latestByPatient = await getLatestAssessmentsByPatient(
    patients.map((patient) => patient.id)
  );

  return {
    data: patients.map((patient) => ({
      ...sanitizePatientResponse(patient),
      latestAssessments: latestByPatient.get(patient.id) ?? [],
    })),
    page: query.page,
    pageSize: query.pageSize,
    total,
  };
}

interface LatestAssessment {
  templateKey: string;
  score: number | null;
  status: string;
  createdAt: Date;
}

// Most recent official assessment per templateKey for each patient, so the
// patient list can surface scores (e.g. PHQ-9, PHQ-4) and a diagnosis label
// (`status`) without an extra round-trip per row. Rows come back newest-first,
// so the first occurrence of each (patientId, templateKey) pair is the latest.
async function getLatestAssessmentsByPatient(
  patientIds: string[]
): Promise<Map<string, LatestAssessment[]>> {
  const result = new Map<string, LatestAssessment[]>();
  if (patientIds.length === 0) return result;

  const rows = await prisma.assessment.findMany({
    where: { patientId: { in: patientIds } },
    select: { patientId: true, templateKey: true, score: true, status: true, createdAt: true },
    orderBy: { createdAt: 'desc' },
  });

  for (const row of rows) {
    let perKey = result.get(row.patientId);
    if (!perKey) {
      perKey = [];
      result.set(row.patientId, perKey);
    }
    if (perKey.some((item) => item.templateKey === row.templateKey)) continue;
    perKey.push({
      templateKey: row.templateKey,
      score: row.score,
      status: row.status,
      createdAt: row.createdAt,
    });
  }

  return result;
}

export async function listPatientOptions(query: ListPatientOptionsQuery) {
  const where: Prisma.PatientWhereInput = {
    user: {
      is: {
        role: 'PATIENT',
        isActive: true,
        ...(query.q
          ? {
              fullName: { contains: query.q, mode: 'insensitive' },
            }
          : {}),
      },
    },
  };
  const skip = (query.page - 1) * query.pageSize;

  const [patients, total] = await prisma.$transaction([
    prisma.patient.findMany({
      where,
      select: { id: true, user: { select: { fullName: true } } },
      orderBy: { user: { fullName: 'asc' } },
      skip,
      take: query.pageSize,
    }),
    prisma.patient.count({ where }),
  ]);

  return {
    data: patients.map((patient) => ({ id: patient.id, fullName: patient.user.fullName })),
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
    | 'crn'
    | 'phone'
    | 'gender'
    | 'address'
    | 'emergencyContactName'
    | 'emergencyContactPhone'
    | 'bmi'
    | 'menopausalStatus'
    | 'stageAtDiagnosis'
    | 'diseaseStatus'
    | 'tumorBiology'
    | 'surgery'
    | 'chemotherapy'
    | 'radiotherapy'
    | 'hormonalTherapy'
    | 'targetedTherapy'
    | 'immunotherapy'
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

  setScalar('crn', patient.crn, data.crn);
  setScalar('phone', patient.phone, data.phone);
  setScalar('gender', patient.gender, data.gender);
  setScalar('address', patient.address, data.address);
  setScalar('emergencyContactName', patient.emergencyContactName, data.emergencyContactName);
  setScalar('emergencyContactPhone', patient.emergencyContactPhone, data.emergencyContactPhone);
  setScalar('bmi', patient.bmi, data.bmi);
  setScalar('menopausalStatus', patient.menopausalStatus, data.menopausalStatus);
  setScalar('stageAtDiagnosis', patient.stageAtDiagnosis, data.stageAtDiagnosis);
  setScalar('diseaseStatus', patient.diseaseStatus, data.diseaseStatus);
  setScalar('tumorBiology', patient.tumorBiology, data.tumorBiology);
  setScalar('surgery', patient.surgery, data.surgery);
  setScalar('chemotherapy', patient.chemotherapy, data.chemotherapy);
  setScalar('radiotherapy', patient.radiotherapy, data.radiotherapy);
  setScalar('hormonalTherapy', patient.hormonalTherapy, data.hormonalTherapy);
  setScalar('targetedTherapy', patient.targetedTherapy, data.targetedTherapy);
  setScalar('immunotherapy', patient.immunotherapy, data.immunotherapy);

  const setDate = (
    key: 'dateOfBirth' | 'dateOfDiagnosis',
    next: Date | null | undefined
  ) => {
    if (next === undefined) return;
    const currentTime = patient[key]?.getTime() ?? null;
    const nextTime = next?.getTime() ?? null;
    if (currentTime === nextTime) return;

    updateData[key] = next;
    oldValues[key] = patient[key];
    newValues[key] = next;
  };

  setDate('dateOfBirth', data.dateOfBirth);
  setDate('dateOfDiagnosis', data.dateOfDiagnosis);

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

  let updated: PatientWithUser;
  try {
    updated = await prisma.patient.update({
      where: { id: patientId },
      data: updateData,
      include: patientInclude,
    });
  } catch (err) {
    if (isUniqueConstraintError(err)) {
      throw conflictForUniqueError(err);
    }
    throw err;
  }

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
  if (limit > maxTimelineMergeWindow) {
    throw AppError.badRequest(
      `Timeline pagination window cannot exceed ${maxTimelineMergeWindow} items`
    );
  }

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
