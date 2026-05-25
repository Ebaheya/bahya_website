import { Prisma } from '@prisma/client';
import { prisma } from '../../config/prisma';
import { AppError } from '../../utils/httpError';
import { writeAudit } from '../../middleware/audit';
import { emitHighRiskAlert } from '../notifications/notification.service';
import { submitAssignmentSchema } from './submission.schema';
import * as submissionService from './submission.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    $transaction: jest.fn(),
    formAssignment: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
  },
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

jest.mock('../notifications/notification.service', () => ({
  emitHighRiskAlert: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  $transaction: jest.Mock;
  formAssignment: {
    findMany: jest.Mock;
    findUnique: jest.Mock;
  };
};
const writeAuditMock = writeAudit as jest.Mock;
const emitHighRiskAlertMock = emitHighRiskAlert as jest.Mock;

function assignment(overrides: Record<string, unknown> = {}) {
  return {
    id: 'assignment-1',
    formVersionId: 'version-1',
    patientId: 'patient-1',
    assignedToUserId: null,
    target: 'SINGLE_PATIENT',
    status: 'PUBLISHED',
    publishAt: null,
    template: {
      id: 'form-1',
      key: 'CLINIC',
      name: 'Clinic Form',
      scoringType: 'SUM',
      interpretationMode: 'RANGE',
    },
    patient: { id: 'patient-1', userId: 'patient-user-1', user: { isActive: true } },
    assignedTo: null,
    formVersion: {
      id: 'version-1',
      questions: [
        {
          id: 'question-select',
          order: 1,
          text: 'Symptoms',
          type: 'MULTI_SELECT',
          subscale: null,
          required: true,
          scaleMin: null,
          scaleMax: null,
          scaleStep: null,
          choices: [
            { id: 'choice-1', order: 1, label: 'Fatigue', score: 2 },
            { id: 'choice-2', order: 2, label: 'Insomnia', score: 3 },
          ],
        },
        {
          id: 'question-scale',
          order: 2,
          text: 'Distress',
          type: 'SCALE',
          subscale: null,
          required: true,
          scaleMin: 0,
          scaleMax: 10,
          scaleStep: 2,
          choices: [],
        },
      ],
      scoreRanges: [
        { subscale: null, label: 'Low', minScore: 0, maxScore: 9, note: null },
        { subscale: null, label: 'Critical', minScore: 10, maxScore: 15, note: null },
      ],
    },
    submission: null,
    ...overrides,
  };
}

function submitTx(existing = assignment()) {
  return {
    formAssignment: {
      findUnique: jest.fn().mockResolvedValue(existing),
      updateMany: jest.fn().mockResolvedValue({ count: 1 }),
    },
    formSubmission: {
      create: jest.fn().mockResolvedValue({
        id: 'submission-1',
        submittedAt: new Date('2026-05-25T12:00:00Z'),
      }),
    },
  };
}

describe('submit assignment request validation', () => {
  it('rejects duplicate questions and invalid answer shapes', () => {
    const questionId = 'e2108357-5e7d-49d5-aad1-d6b0914e7cf7';
    expect(
      submitAssignmentSchema.safeParse({
        answers: [
          { questionId, choiceIds: ['57a9983a-ae0a-4e58-89cb-53ee15bb0f57'] },
          { questionId, value: 3 },
        ],
      }).success
    ).toBe(false);
    expect(
      submitAssignmentSchema.safeParse({
        answers: [{ questionId, choiceIds: [], value: 3 }],
      }).success
    ).toBe(false);
  });
});

describe('submission visibility and detail', () => {
  beforeEach(() => jest.clearAllMocks());

  it('lists only visible patient-owned assignments using an active-patient filter', async () => {
    prismaMock.formAssignment.findMany.mockResolvedValue([{ id: 'assignment-1' }]);
    const now = new Date('2026-05-25T12:00:00Z');

    await expect(
      submissionService.getMyAssignments('patient-user-1', 'PATIENT', now)
    ).resolves.toEqual([{ id: 'assignment-1' }]);
    expect(prismaMock.formAssignment.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          status: 'PUBLISHED',
          OR: [{ publishAt: null }, { publishAt: { lte: now } }],
          patient: {
            user: { is: { id: 'patient-user-1', role: 'PATIENT', isActive: true } },
          },
          target: { in: ['SINGLE_PATIENT', 'ALL_PATIENTS'] },
        }),
      })
    );
  });

  it('returns pinned filler detail without choice scores or interpretation ranges', async () => {
    prismaMock.formAssignment.findUnique.mockResolvedValue(assignment());

    const detail = await submissionService.getAssignmentDetail(
      'assignment-1',
      'patient-user-1',
      'PATIENT'
    );

    expect(detail.formVersion.scoreRanges).toEqual([]);
    expect(detail.formVersion.questions[0].choices[0]).not.toHaveProperty('score');
  });

  it('hides another patient assignment and inactive volunteer-linked patient as not found', async () => {
    prismaMock.formAssignment.findUnique.mockResolvedValueOnce(assignment()).mockResolvedValueOnce(
      assignment({
        target: 'VOLUNTEER_FOR_PATIENT',
        assignedToUserId: 'volunteer-1',
        patient: { id: 'patient-1', userId: 'patient-user-1', user: { isActive: false } },
      })
    );

    await expect(
      submissionService.getAssignmentDetail('assignment-1', 'patient-user-2', 'PATIENT')
    ).rejects.toMatchObject({ statusCode: 404 });
    await expect(
      submissionService.getAssignmentDetail('assignment-1', 'volunteer-1', 'VOLUNTEER')
    ).rejects.toMatchObject({ statusCode: 404 });
  });
});

describe('submit', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    writeAuditMock.mockResolvedValue(undefined);
    emitHighRiskAlertMock.mockResolvedValue(undefined);
  });

  it('stores server-computed totals, escalates the top band, and returns confirmation only', async () => {
    const tx = submitTx();
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));
    const input = {
      answers: [
        { questionId: 'question-select', choiceIds: ['choice-1', 'choice-2'] },
        { questionId: 'question-scale', value: 10 },
      ],
    };

    const result = await submissionService.submit(
      'assignment-1',
      input,
      'patient-user-1',
      'PATIENT',
      undefined,
      new Date('2026-05-25T12:00:00Z')
    );

    expect(tx.formSubmission.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          totalScore: 15,
          interpretation: { label: 'Critical', subscales: [] },
        }),
      })
    );
    expect(emitHighRiskAlertMock).toHaveBeenCalledWith(
      expect.objectContaining({ submissionId: 'submission-1', severity: 'CRITICAL' })
    );
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'HIGH_RISK_ALERT_CREATED' })
    );
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'FORM_SUBMITTED' })
    );
    expect(result).toEqual({
      submissionId: 'submission-1',
      status: 'SUBMITTED',
      submittedAt: new Date('2026-05-25T12:00:00Z'),
    });
    expect(result).not.toHaveProperty('totalScore');
    expect(result).not.toHaveProperty('interpretation');
  });

  it('still returns confirmation when post-commit high-risk escalation fails', async () => {
    const tx = submitTx();
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));
    // HIGH_RISK_ALERT_CREATED is strict-tier and writeAudit throws 503 on an
    // audit-store outage. The submission is already committed, so submit must
    // not fail and must not leak the high-risk outcome to the filler.
    writeAuditMock.mockImplementation(async ({ action }: { action: string }) => {
      if (action === 'HIGH_RISK_ALERT_CREATED') {
        throw new AppError(503, 'AUDIT_UNAVAILABLE', 'Audit store unavailable');
      }
    });

    const result = await submissionService.submit(
      'assignment-1',
      {
        answers: [
          { questionId: 'question-select', choiceIds: ['choice-1', 'choice-2'] },
          { questionId: 'question-scale', value: 10 },
        ],
      },
      'patient-user-1',
      'PATIENT',
      undefined,
      new Date('2026-05-25T12:00:00Z')
    );

    expect(result).toEqual({
      submissionId: 'submission-1',
      status: 'SUBMITTED',
      submittedAt: new Date('2026-05-25T12:00:00Z'),
    });
    expect(tx.formSubmission.create).toHaveBeenCalled();
  });

  it('validates but does not automatically score a manual form', async () => {
    const manual = assignment({
      template: {
        id: 'form-manual',
        key: 'QOL',
        name: 'Quality of Life',
        scoringType: 'MANUAL',
        interpretationMode: 'MANUAL',
      },
      formVersion: {
        id: 'version-manual',
        questions: [
          {
            id: 'question-select',
            order: 1,
            text: 'Activity',
            type: 'SINGLE_SELECT',
            subscale: null,
            required: true,
            scaleMin: null,
            scaleMax: null,
            scaleStep: null,
            choices: [{ id: 'choice-1', order: 1, label: 'Some', score: 2 }],
          },
        ],
        scoreRanges: [],
      },
    });
    const tx = submitTx(manual);
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await submissionService.submit(
      'assignment-1',
      { answers: [{ questionId: 'question-select', choiceIds: ['choice-1'] }] },
      'patient-user-1',
      'PATIENT'
    );

    expect(tx.formSubmission.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          totalScore: null,
          subscaleScores: Prisma.JsonNull,
          interpretation: Prisma.JsonNull,
        }),
      })
    );
    expect(emitHighRiskAlertMock).not.toHaveBeenCalled();
  });

  it('rejects invalid scale values and answers for questions outside the pinned version', async () => {
    const txForScale = submitTx();
    const txForStep = submitTx();
    const txForQuestion = submitTx();
    prismaMock.$transaction
      .mockImplementationOnce(async (callback) => callback(txForScale))
      .mockImplementationOnce(async (callback) => callback(txForStep))
      .mockImplementationOnce(async (callback) => callback(txForQuestion));

    await expect(
      submissionService.submit(
        'assignment-1',
        {
          answers: [
            { questionId: 'question-select', choiceIds: ['choice-1'] },
            { questionId: 'question-scale', value: 11 },
          ],
        },
        'patient-user-1',
        'PATIENT'
      )
    ).rejects.toMatchObject({ statusCode: 400, code: 'FORM_SCALE_OUT_OF_RANGE' });

    await expect(
      submissionService.submit(
        'assignment-1',
        {
          answers: [
            { questionId: 'question-select', choiceIds: ['choice-1'] },
            { questionId: 'question-scale', value: 3 },
          ],
        },
        'patient-user-1',
        'PATIENT'
      )
    ).rejects.toMatchObject({ statusCode: 400, code: 'FORM_SCALE_OUT_OF_RANGE' });

    await expect(
      submissionService.submit(
        'assignment-1',
        { answers: [{ questionId: 'question-unknown', value: 1 }] },
        'patient-user-1',
        'PATIENT'
      )
    ).rejects.toMatchObject({ statusCode: 400, code: 'FORM_INVALID_QUESTION' });
  });

  it('rejects an already submitted assignment without persisting another record', async () => {
    const tx = submitTx(assignment({ status: 'SUBMITTED', submission: { id: 'submission-1' } }));
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(
      submissionService.submit(
        'assignment-1',
        { answers: [{ questionId: 'question-select', choiceIds: ['choice-1'] }] },
        'patient-user-1',
        'PATIENT'
      )
    ).rejects.toMatchObject({ statusCode: 409, code: 'FORM_ALREADY_SUBMITTED' });
    expect(tx.formSubmission.create).not.toHaveBeenCalled();
  });

  it('rejects non-filler roles before accessing assignment data', async () => {
    await expect(
      submissionService.submit(
        'assignment-1',
        { answers: [{ questionId: 'question-select', choiceIds: ['choice-1'] }] },
        'doctor-1',
        'DOCTOR'
      )
    ).rejects.toMatchObject({ statusCode: 403 });
    expect(prismaMock.$transaction).not.toHaveBeenCalled();
  });
});
