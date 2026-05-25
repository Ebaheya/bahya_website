import { prisma } from '../../config/prisma';
import { AppError } from '../../utils/httpError';
import { writeAudit } from '../../middleware/audit';
import * as assessmentService from './assessment.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    $transaction: jest.fn(),
    formSubmission: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
    patient: {
      findUnique: jest.fn(),
    },
    assessment: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
  },
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  $transaction: jest.Mock;
  formSubmission: {
    findMany: jest.Mock;
    findUnique: jest.Mock;
  };
  patient: {
    findUnique: jest.Mock;
  };
  assessment: {
    findMany: jest.Mock;
    findUnique: jest.Mock;
  };
};
const writeAuditMock = writeAudit as jest.Mock;

function submittedForm(scoringType = 'SUM', overrides: Record<string, unknown> = {}) {
  return {
    id: 'submission-1',
    assignmentId: 'assignment-1',
    patientId: 'patient-1',
    totalScore: scoringType === 'MANUAL' ? null : 12,
    assessment: null,
    assignment: {
      id: 'assignment-1',
      status: 'SUBMITTED',
      template: { key: scoringType === 'MANUAL' ? 'QOL' : 'PHQ9', scoringType },
    },
    ...overrides,
  };
}

function transactionFor(submission = submittedForm(), claimedCount = 1) {
  return {
    patient: {
      findUnique: jest.fn().mockResolvedValue({ id: 'patient-1' }),
    },
    formSubmission: {
      findUnique: jest.fn().mockResolvedValue(submission),
    },
    formAssignment: {
      updateMany: jest.fn().mockResolvedValue({ count: claimedCount }),
    },
    assessment: {
      create: jest.fn().mockImplementation(({ data }) =>
        Promise.resolve({
          id: 'assessment-1',
          ...data,
        })
      ),
    },
  };
}

describe('assessment review queue and access', () => {
  beforeEach(() => jest.clearAllMocks());

  it('lists only submitted records without an official assessment', async () => {
    prismaMock.formSubmission.findMany.mockResolvedValue([{ id: 'submission-1' }]);

    await expect(assessmentService.listPendingSubmissions('ADMIN')).resolves.toEqual([
      { id: 'submission-1' },
    ]);
    expect(prismaMock.formSubmission.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          assessment: null,
          assignment: { status: 'SUBMITTED' },
        },
      })
    );
  });

  it('allows a patient to read only assessments belonging to their patient record', async () => {
    prismaMock.assessment.findUnique
      .mockResolvedValueOnce({ id: 'assessment-1', patient: { userId: 'patient-user-1' } })
      .mockResolvedValueOnce({ id: 'assessment-2', patient: { userId: 'patient-user-2' } });

    await expect(
      assessmentService.getById('assessment-1', 'patient-user-1', 'PATIENT')
    ).resolves.toMatchObject({ id: 'assessment-1' });
    await expect(
      assessmentService.getById('assessment-2', 'patient-user-1', 'PATIENT')
    ).rejects.toMatchObject({ statusCode: 404 });
  });
});

describe('createAssessment', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    writeAuditMock.mockResolvedValue(undefined);
  });

  it('uses the stored automatic score, marks the source reviewed, and audits creation', async () => {
    const tx = transactionFor();
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    const result = await assessmentService.createAssessment(
      {
        patientId: 'patient-1',
        submissionId: 'submission-1',
        templateKey: 'PHQ9',
        score: 999,
        status: 'MODERATE',
        doctorNote: 'Review complete',
      },
      'doctor-1',
      'DOCTOR'
    );

    expect(tx.formAssignment.updateMany).toHaveBeenCalledWith({
      where: { id: 'assignment-1', status: 'SUBMITTED' },
      data: { status: 'REVIEWED' },
    });
    expect(tx.assessment.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ score: 12, submissionId: 'submission-1' }),
      })
    );
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'ASSESSMENT_CREATED', entityId: 'assessment-1' })
    );
    expect(result).toMatchObject({ id: 'assessment-1', score: 12 });
  });

  it('uses doctor-assigned score for a manual submission', async () => {
    const tx = transactionFor(submittedForm('MANUAL'));
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await assessmentService.createAssessment(
      {
        patientId: 'patient-1',
        submissionId: 'submission-1',
        templateKey: 'QOL',
        score: 7,
        status: 'SEVERE',
      },
      'doctor-1',
      'DOCTOR'
    );

    expect(tx.assessment.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ score: 7, status: 'SEVERE' }),
      })
    );
  });

  it('creates a direct assessment without changing an assignment', async () => {
    const tx = transactionFor();
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await assessmentService.createAssessment(
      {
        patientId: 'patient-1',
        templateKey: 'CLINICAL_REVIEW',
        score: 4,
        status: 'MILD',
      },
      'doctor-1',
      'DOCTOR'
    );

    expect(tx.patient.findUnique).toHaveBeenCalledWith({
      where: { id: 'patient-1' },
      select: { id: true },
    });
    expect(tx.assessment.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ submissionId: null, score: 4, status: 'MILD' }),
      })
    );
    expect(tx.formAssignment.updateMany).not.toHaveBeenCalled();
  });

  it('rejects manual review without a doctor score and concurrent repeated review', async () => {
    const manualTx = transactionFor(submittedForm('MANUAL'));
    const lostClaimTx = transactionFor(submittedForm(), 0);
    prismaMock.$transaction
      .mockImplementationOnce(async (callback) => callback(manualTx))
      .mockImplementationOnce(async (callback) => callback(lostClaimTx));

    await expect(
      assessmentService.createAssessment(
        {
          patientId: 'patient-1',
          submissionId: 'submission-1',
          templateKey: 'QOL',
          status: 'MODERATE',
        },
        'doctor-1',
        'DOCTOR'
      )
    ).rejects.toMatchObject({ statusCode: 400, code: 'ASSESSMENT_SCORE_REQUIRED' });

    await expect(
      assessmentService.createAssessment(
        {
          patientId: 'patient-1',
          submissionId: 'submission-1',
          templateKey: 'PHQ9',
          status: 'MODERATE',
        },
        'doctor-1',
        'DOCTOR'
      )
    ).rejects.toMatchObject({ statusCode: 409, code: 'ASSESSMENT_ALREADY_CREATED' });
    expect(lostClaimTx.assessment.create).not.toHaveBeenCalled();
  });

  it('rejects an assessment whose patient or templateKey does not match the submission', async () => {
    const mismatchPatientTx = transactionFor();
    const mismatchTemplateTx = transactionFor();
    prismaMock.$transaction
      .mockImplementationOnce(async (callback) => callback(mismatchPatientTx))
      .mockImplementationOnce(async (callback) => callback(mismatchTemplateTx));

    // submission belongs to patient-1 / PHQ9; doctor passes a different patient
    await expect(
      assessmentService.createAssessment(
        {
          patientId: 'patient-2',
          submissionId: 'submission-1',
          templateKey: 'PHQ9',
          status: 'MODERATE',
        },
        'doctor-1',
        'DOCTOR'
      )
    ).rejects.toMatchObject({ statusCode: 400, code: 'ASSESSMENT_SUBMISSION_MISMATCH' });
    expect(mismatchPatientTx.formAssignment.updateMany).not.toHaveBeenCalled();
    expect(mismatchPatientTx.assessment.create).not.toHaveBeenCalled();

    // ...or a templateKey that does not match the submission's template
    await expect(
      assessmentService.createAssessment(
        {
          patientId: 'patient-1',
          submissionId: 'submission-1',
          templateKey: 'GAD7',
          status: 'MODERATE',
        },
        'doctor-1',
        'DOCTOR'
      )
    ).rejects.toMatchObject({ statusCode: 400, code: 'ASSESSMENT_SUBMISSION_MISMATCH' });
    expect(mismatchTemplateTx.assessment.create).not.toHaveBeenCalled();
  });

  it('returns the created assessment even when the post-commit audit fails', async () => {
    const tx = transactionFor();
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));
    writeAuditMock.mockRejectedValue(new AppError(503, 'AUDIT_UNAVAILABLE', 'Audit store down'));

    await expect(
      assessmentService.createAssessment(
        {
          patientId: 'patient-1',
          submissionId: 'submission-1',
          templateKey: 'PHQ9',
          status: 'MODERATE',
        },
        'doctor-1',
        'DOCTOR'
      )
    ).resolves.toMatchObject({ id: 'assessment-1', score: 12 });
    // the source assignment was still flipped to REVIEWED inside the committed tx
    expect(tx.formAssignment.updateMany).toHaveBeenCalled();
  });

  it.each(['ADMIN', 'VOLUNTEER', 'PATIENT'] as const)(
    'rejects %s as an official assessment author',
    async (role) => {
      await expect(
        assessmentService.createAssessment(
          {
            patientId: 'patient-1',
            templateKey: 'PHQ9',
            status: 'MODERATE',
          },
          'user-1',
          role
        )
      ).rejects.toMatchObject({ statusCode: 403 });
      expect(prismaMock.$transaction).not.toHaveBeenCalled();
    }
  );
});
