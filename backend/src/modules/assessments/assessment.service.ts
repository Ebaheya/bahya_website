import { Prisma, type Role } from '@prisma/client';
import type { Request } from 'express';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import type { CreateAssessmentInput } from './assessment.schema';

const submissionDetailInclude = {
  assignment: {
    include: {
      template: {
        select: { id: true, key: true, name: true, scoringType: true, interpretationMode: true },
      },
    },
  },
  patient: { select: { id: true, userId: true } },
  submittedBy: { select: { id: true, role: true } },
  formVersion: {
    include: {
      questions: {
        orderBy: { order: 'asc' },
        include: { choices: { orderBy: { order: 'asc' } } },
      },
      scoreRanges: { orderBy: [{ subscale: 'asc' }, { minScore: 'asc' }] },
    },
  },
  assessment: true,
} satisfies Prisma.FormSubmissionInclude;

function ensureReviewerReadRole(role: Role): void {
  if (role !== 'DOCTOR' && role !== 'ADMIN') {
    throw AppError.forbidden('Insufficient role');
  }
}

function ensureAssessmentReadAccess(patientUserId: string, actorId: string, role: Role): void {
  if (role === 'DOCTOR' || role === 'ADMIN') return;
  if (role === 'PATIENT' && patientUserId === actorId) return;
  throw AppError.notFound('Assessment not found');
}

export async function listPendingSubmissions(role: Role) {
  ensureReviewerReadRole(role);
  return prisma.formSubmission.findMany({
    where: {
      assessment: null,
      assignment: { status: 'SUBMITTED' },
    },
    include: {
      assignment: {
        include: {
          template: { select: { id: true, key: true, name: true, scoringType: true } },
        },
      },
      patient: { select: { id: true, userId: true } },
    },
    orderBy: { submittedAt: 'asc' },
  });
}

export async function getSubmission(submissionId: string, role: Role) {
  ensureReviewerReadRole(role);
  const submission = await prisma.formSubmission.findUnique({
    where: { id: submissionId },
    include: submissionDetailInclude,
  });
  if (!submission) throw AppError.notFound('Form submission not found');
  return submission;
}

export async function createAssessment(
  input: CreateAssessmentInput,
  doctorId: string,
  role: Role,
  req?: Request
) {
  if (role !== 'DOCTOR') {
    throw AppError.forbidden('Only doctors can create an assessment');
  }

  const assessment = await prisma.$transaction(async (tx) => {
    if (!input.submissionId) {
      const patient = await tx.patient.findUnique({
        where: { id: input.patientId },
        select: { id: true },
      });
      if (!patient) throw AppError.notFound('Patient not found');
      return tx.assessment.create({
        data: {
          patientId: input.patientId,
          doctorId,
          submissionId: null,
          templateKey: input.templateKey,
          score: input.score ?? null,
          status: input.status,
          doctorNote: input.doctorNote ?? null,
        },
      });
    }

    const submission = await tx.formSubmission.findUnique({
      where: { id: input.submissionId },
      include: {
        assessment: { select: { id: true } },
        assignment: {
          include: {
            template: { select: { key: true, scoringType: true } },
          },
        },
      },
    });
    if (!submission) throw AppError.notFound('Form submission not found');
    if (submission.assessment || submission.assignment.status === 'REVIEWED') {
      throw new AppError(409, 'ASSESSMENT_ALREADY_CREATED', 'Submission has already been reviewed');
    }
    if (
      submission.patientId !== input.patientId ||
      submission.assignment.template.key !== input.templateKey
    ) {
      throw new AppError(
        400,
        'ASSESSMENT_SUBMISSION_MISMATCH',
        'Assessment does not match the source submission'
      );
    }

    const manual = submission.assignment.template.scoringType === 'MANUAL';
    if (manual && input.score == null) {
      throw new AppError(
        400,
        'ASSESSMENT_SCORE_REQUIRED',
        'Manual submissions require a doctor-assigned score'
      );
    }
    if (!manual && submission.totalScore == null) {
      throw AppError.internal('Scored submission has no computed score');
    }

    const claimed = await tx.formAssignment.updateMany({
      where: { id: submission.assignmentId, status: 'SUBMITTED' },
      data: { status: 'REVIEWED' },
    });
    if (claimed.count !== 1) {
      throw new AppError(409, 'ASSESSMENT_ALREADY_CREATED', 'Submission has already been reviewed');
    }

    return tx.assessment.create({
      data: {
        patientId: input.patientId,
        doctorId,
        submissionId: input.submissionId,
        templateKey: input.templateKey,
        score: manual ? input.score! : submission.totalScore,
        status: input.status,
        doctorNote: input.doctorNote ?? null,
      },
    });
  });

  await writeAudit({
    actorId: doctorId,
    action: 'ASSESSMENT_CREATED',
    entityType: 'Assessment',
    entityId: assessment.id,
    newValues: {
      patientId: assessment.patientId,
      submissionId: assessment.submissionId,
      templateKey: assessment.templateKey,
      status: assessment.status,
    },
    req,
  });

  return assessment;
}

export async function listByPatient(patientId: string, actorId: string, role: Role) {
  if (role === 'PATIENT') {
    const patient = await prisma.patient.findUnique({
      where: { id: patientId },
      select: { userId: true },
    });
    if (!patient || patient.userId !== actorId) {
      throw AppError.notFound('Patient not found');
    }
  } else if (role !== 'DOCTOR' && role !== 'ADMIN') {
    throw AppError.forbidden('Insufficient role');
  }

  return prisma.assessment.findMany({
    where: { patientId },
    include: {
      doctor: { select: { id: true, fullName: true } },
      submission: { select: { id: true, submittedAt: true } },
    },
    orderBy: { createdAt: 'desc' },
  });
}

export async function getById(assessmentId: string, actorId: string, role: Role) {
  const assessment = await prisma.assessment.findUnique({
    where: { id: assessmentId },
    include: {
      patient: { select: { id: true, userId: true } },
      doctor: { select: { id: true, fullName: true } },
      submission: { select: { id: true, submittedAt: true } },
    },
  });
  if (!assessment) throw AppError.notFound('Assessment not found');
  ensureAssessmentReadAccess(assessment.patient.userId, actorId, role);
  return assessment;
}
