import { Prisma, type Role } from '@prisma/client';
import type { Request } from 'express';
import { logger } from '../../config/logger';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import { emitHighRiskAlert } from '../notifications/notification.service';
import {
  mapScoreRange,
  scoreFormSubmission,
  ScoringValidationError,
  type ScoreRange,
  type ScoringQuestion,
} from './scoring';
import type { SubmitAssignmentInput } from './submission.schema';

const visibleAssignmentInclude = {
  template: {
    select: {
      id: true,
      key: true,
      name: true,
      scoringType: true,
      interpretationMode: true,
    },
  },
  patient: { select: { id: true, userId: true, user: { select: { isActive: true } } } },
  assignedTo: { select: { id: true, role: true } },
  formVersion: {
    include: {
      questions: {
        orderBy: { order: 'asc' },
        include: { choices: { orderBy: { order: 'asc' } } },
      },
      scoreRanges: { orderBy: [{ subscale: 'asc' }, { minScore: 'asc' }] },
    },
  },
  submission: { select: { id: true } },
} satisfies Prisma.FormAssignmentInclude;

type AssignmentDetail = Prisma.FormAssignmentGetPayload<{
  include: typeof visibleAssignmentInclude;
}>;

function isVisible(assignment: AssignmentDetail, now: Date): boolean {
  return (
    assignment.status === 'PUBLISHED' &&
    (assignment.publishAt === null || assignment.publishAt.getTime() <= now.getTime())
  );
}

function canFill(assignment: AssignmentDetail, actorId: string, role: Role): boolean {
  if (!assignment.patient.user.isActive) return false;
  if (role === 'PATIENT') {
    return (
      assignment.patient.userId === actorId &&
      (assignment.target === 'SINGLE_PATIENT' || assignment.target === 'ALL_PATIENTS')
    );
  }
  if (role === 'VOLUNTEER') {
    return assignment.assignedToUserId === actorId && assignment.target === 'VOLUNTEER_FOR_PATIENT';
  }
  return false;
}

function ensureFillerAccess(
  assignment: AssignmentDetail,
  actorId: string,
  role: Role,
  now: Date
): void {
  if (assignment.submission || assignment.status === 'SUBMITTED') {
    throw new AppError(409, 'FORM_ALREADY_SUBMITTED', 'This form has already been submitted');
  }
  if (!isVisible(assignment, now) || !canFill(assignment, actorId, role)) {
    throw AppError.notFound('Form assignment not found');
  }
}

function asScoringQuestions(assignment: AssignmentDetail): ScoringQuestion[] {
  return assignment.formVersion.questions.map((question) => ({
    id: question.id,
    type: question.type,
    subscale: question.subscale,
    required: question.required,
    scaleMin: question.scaleMin,
    scaleMax: question.scaleMax,
    scaleStep: question.scaleStep,
    choices: question.choices.map((choice) => ({ id: choice.id, score: choice.score })),
  }));
}

function asScoreRanges(assignment: AssignmentDetail): ScoreRange[] {
  return assignment.formVersion.scoreRanges.map((range) => ({
    subscale: range.subscale,
    label: range.label,
    minScore: range.minScore,
    maxScore: range.maxScore,
    note: range.note,
  }));
}

function findTopBand(
  totalScore: number,
  subscaleScores: Record<string, number>,
  ranges: ScoreRange[]
): ScoreRange | null {
  const candidates = [
    mapScoreRange(totalScore, ranges, null),
    ...Object.entries(subscaleScores).map(([subscale, score]) =>
      mapScoreRange(score, ranges, subscale)
    ),
  ].filter((range): range is ScoreRange => range !== null);

  return (
    candidates.find((candidate) => {
      const sameGroup = ranges.filter(
        (range) => (range.subscale ?? null) === (candidate.subscale ?? null)
      );
      // A single-band group is a catch-all, not a high-risk threshold — every
      // score lands in it, so it must not escalate. Only the highest band of a
      // group with more than one band counts as the top (high-risk) band.
      return (
        sameGroup.length > 1 &&
        candidate.maxScore === Math.max(...sameGroup.map((range) => range.maxScore))
      );
    }) ?? null
  );
}

function safeDetailForFiller(assignment: AssignmentDetail) {
  return {
    ...assignment,
    formVersion: {
      ...assignment.formVersion,
      scoreRanges: [],
      questions: assignment.formVersion.questions.map((question) => ({
        ...question,
        choices: question.choices.map(({ score: _score, ...choice }) => choice),
      })),
    },
  };
}

export async function getMyAssignments(actorId: string, role: Role, now = new Date()) {
  if (role !== 'PATIENT' && role !== 'VOLUNTEER') throw AppError.forbidden('Insufficient role');

  const where: Prisma.FormAssignmentWhereInput = {
    status: 'PUBLISHED',
    OR: [{ publishAt: null }, { publishAt: { lte: now } }],
    ...(role === 'PATIENT'
      ? {
          patient: { user: { is: { id: actorId, role: 'PATIENT', isActive: true } } },
          target: { in: ['SINGLE_PATIENT', 'ALL_PATIENTS'] },
        }
      : {
          patient: { user: { is: { role: 'PATIENT', isActive: true } } },
          assignedToUserId: actorId,
          target: 'VOLUNTEER_FOR_PATIENT',
        }),
  };

  return prisma.formAssignment.findMany({
    where,
    include: {
      template: { select: { id: true, key: true, name: true } },
      patient: { select: { id: true, userId: true } },
    },
    orderBy: { createdAt: 'desc' },
  });
}

export async function getAssignmentDetail(
  assignmentId: string,
  actorId: string,
  role: Role,
  now = new Date()
) {
  const assignment = await prisma.formAssignment.findUnique({
    where: { id: assignmentId },
    include: visibleAssignmentInclude,
  });
  if (!assignment) throw AppError.notFound('Form assignment not found');

  if (role === 'PATIENT' || role === 'VOLUNTEER') {
    ensureFillerAccess(assignment, actorId, role, now);
    return safeDetailForFiller(assignment);
  }
  if (role === 'DOCTOR' || role === 'ADMIN') return assignment;
  throw AppError.forbidden('Insufficient role');
}

export async function submit(
  assignmentId: string,
  input: SubmitAssignmentInput,
  actorId: string,
  role: Role,
  req?: Request,
  now = new Date()
) {
  if (role !== 'PATIENT' && role !== 'VOLUNTEER') {
    throw AppError.forbidden('Insufficient role');
  }

  const committed = await prisma.$transaction(async (tx) => {
    const assignment = await tx.formAssignment.findUnique({
      where: { id: assignmentId },
      include: visibleAssignmentInclude,
    });
    if (!assignment) throw AppError.notFound('Form assignment not found');
    ensureFillerAccess(assignment, actorId, role, now);

    const questions = asScoringQuestions(assignment);
    const ranges = asScoreRanges(assignment);
    const questionIds = new Set(questions.map((question) => question.id));
    if (input.answers.some((answer) => !questionIds.has(answer.questionId))) {
      throw new AppError(400, 'FORM_INVALID_QUESTION', 'Answer references an unknown question');
    }
    let scoring;
    try {
      scoring = scoreFormSubmission(questions, input.answers, ranges);
    } catch (err) {
      if (err instanceof ScoringValidationError) {
        throw new AppError(400, err.code, err.message);
      }
      throw err;
    }

    const scored = assignment.template.scoringType === 'SUM';
    const topBand = scored ? findTopBand(scoring.totalScore, scoring.subscaleScores, ranges) : null;

    const claimed = await tx.formAssignment.updateMany({
      where: { id: assignmentId, status: 'PUBLISHED' },
      data: { status: 'SUBMITTED' },
    });
    if (claimed.count !== 1) {
      throw new AppError(409, 'FORM_ALREADY_SUBMITTED', 'This form has already been submitted');
    }

    const submission = await tx.formSubmission.create({
      data: {
        assignmentId,
        formVersionId: assignment.formVersionId,
        patientId: assignment.patientId,
        submittedByUserId: actorId,
        answers: input.answers as Prisma.InputJsonValue,
        totalScore: scored ? scoring.totalScore : null,
        subscaleScores: scored
          ? (scoring.subscaleScores as Prisma.InputJsonObject)
          : Prisma.JsonNull,
        interpretation:
          scored && scoring.interpretation
            ? (scoring.interpretation as unknown as Prisma.InputJsonObject)
            : Prisma.JsonNull,
        submittedAt: now,
      },
      select: { id: true, submittedAt: true },
    });

    return {
      submission,
      patientId: assignment.patientId,
      templateKey: assignment.template.key,
      topBand,
    };
  });

  // Post-commit escalation. The submission is already persisted and the
  // assignment is SUBMITTED, so this MUST NOT fail the request — including when
  // the strict-tier HIGH_RISK_ALERT_CREATED audit throws on an audit-store
  // outage (T025/FR-034a). A thrown 503 here would also indirectly leak the
  // high-risk outcome to the filler, breaking the confirmation-only contract
  // (FR-034b). Swallow and log instead.
  if (committed.topBand) {
    try {
      await emitHighRiskAlert({
        patientId: committed.patientId,
        submissionId: committed.submission.id,
        // The top band is the highest-risk band by construction; the alert
        // severity is fixed rather than guessed from the free-form band label.
        severity: 'CRITICAL',
        templateKey: committed.templateKey,
      });
      await writeAudit({
        actorId,
        action: 'HIGH_RISK_ALERT_CREATED',
        entityType: 'FormSubmission',
        entityId: committed.submission.id,
        newValues: { templateKey: committed.templateKey, band: committed.topBand.label },
        req,
      });
    } catch (err) {
      logger.error(
        { metric: 'high_risk_escalation_failure', submissionId: committed.submission.id, err },
        'high-risk escalation failed after submission commit'
      );
    }
  }

  await writeAudit({
    actorId,
    action: 'FORM_SUBMITTED',
    entityType: 'FormSubmission',
    entityId: committed.submission.id,
    newValues: { assignmentId, templateKey: committed.templateKey },
    req,
  });

  return {
    submissionId: committed.submission.id,
    status: 'SUBMITTED' as const,
    submittedAt: committed.submission.submittedAt,
  };
}
