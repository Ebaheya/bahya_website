import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { emitFormAssigned } from '../notifications/notification.service';
import { setFormStatusSchema } from './form.schema';
import * as formService from './form.service';
import { publishFormSchema } from './publish.schema';
import * as publishService from './publish.service';
import * as submissionService from './submission.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    $transaction: jest.fn(),
    formTemplate: {
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    formAssignment: {
      findUnique: jest.fn(),
    },
  },
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

jest.mock('../notifications/notification.service', () => ({
  emitFormAssigned: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  $transaction: jest.Mock;
  formTemplate: { findUnique: jest.Mock; update: jest.Mock };
  formAssignment: { findUnique: jest.Mock };
};
const writeAuditMock = writeAudit as jest.Mock;
const emitFormAssignedMock = emitFormAssigned as jest.Mock;

function template(isActive: boolean) {
  return {
    id: 'form-1',
    key: 'PHQ9',
    name: 'PHQ-9',
    isActive,
    currentVersion: {
      id: 'version-1',
      status: 'PUBLISHED',
      questions: [{ id: 'question-1' }],
      scoreRanges: [],
    },
  };
}

function publishTransaction(isActive: boolean) {
  return {
    formTemplate: { findUnique: jest.fn().mockResolvedValue(template(isActive)) },
    patient: {
      findUnique: jest.fn().mockResolvedValue({ id: 'patient-1', userId: 'patient-user-1' }),
      findMany: jest.fn(),
    },
    user: { findUnique: jest.fn() },
    formAssignment: {
      createManyAndReturn: jest.fn().mockResolvedValue([
        {
          id: 'assignment-1',
          patientId: 'patient-1',
          assignedToUserId: null,
          target: 'SINGLE_PATIENT',
        },
      ]),
    },
  };
}

describe('form status lifecycle', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    writeAuditMock.mockResolvedValue(undefined);
    emitFormAssignedMock.mockResolvedValue(undefined);
  });

  it('validates the status request shape', () => {
    expect(setFormStatusSchema.parse({ isActive: false })).toEqual({ isActive: false });
    expect(setFormStatusSchema.safeParse({ isActive: 'false' }).success).toBe(false);
  });

  it('deactivates a template, audits the transition, blocks publishing, and preserves detail reads', async () => {
    prismaMock.formTemplate.findUnique.mockResolvedValue({ id: 'form-1', isActive: true });
    prismaMock.formTemplate.update.mockResolvedValue(template(false));

    await expect(formService.setStatus('form-1', false, 'doctor-1')).resolves.toMatchObject({
      id: 'form-1',
      isActive: false,
    });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: 'doctor-1',
        action: 'FORM_DEACTIVATED',
        entityId: 'form-1',
        oldValues: { isActive: true },
        newValues: { isActive: false },
      })
    );

    const publishTx = publishTransaction(false);
    prismaMock.$transaction.mockImplementation(async (callback) => callback(publishTx));
    await expect(
      publishService.publishForm(
        'form-1',
        publishFormSchema.parse({ target: 'ALL_PATIENTS' }),
        'doctor-1'
      )
    ).rejects.toMatchObject({ statusCode: 409, code: 'FORM_NOT_PUBLISHABLE' });

    const historicAssignment = {
      id: 'assignment-1',
      template: { id: 'form-1', key: 'PHQ9', name: 'PHQ-9' },
      formVersion: { id: 'version-1', questions: [{ id: 'question-1' }], scoreRanges: [] },
    };
    prismaMock.formAssignment.findUnique.mockResolvedValue(historicAssignment);
    await expect(
      submissionService.getAssignmentDetail('assignment-1', 'doctor-1', 'DOCTOR')
    ).resolves.toEqual(historicAssignment);
  });

  it('reactivates a form, audits the activation, and allows publishing again', async () => {
    prismaMock.formTemplate.findUnique.mockResolvedValue({ id: 'form-1', isActive: false });
    prismaMock.formTemplate.update.mockResolvedValue(template(true));

    await expect(formService.setStatus('form-1', true, 'admin-1')).resolves.toMatchObject({
      isActive: true,
    });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: 'admin-1',
        action: 'FORM_ACTIVATED',
        entityId: 'form-1',
        oldValues: { isActive: false },
        newValues: { isActive: true },
      })
    );

    const publishTx = publishTransaction(true);
    prismaMock.$transaction.mockImplementation(async (callback) => callback(publishTx));
    await expect(
      publishService.publishForm(
        'form-1',
        publishFormSchema.parse({
          target: 'SINGLE_PATIENT',
          patientId: 'e2108357-5e7d-49d5-aad1-d6b0914e7cf7',
        }),
        'admin-1'
      )
    ).resolves.toEqual({ assignmentsCreated: 1, assignmentIds: ['assignment-1'] });
  });

  it('is a no-op when the status is already at the requested value', async () => {
    prismaMock.formTemplate.findUnique.mockResolvedValue({ id: 'form-1', isActive: true });

    await formService.setStatus('form-1', true, 'doctor-1');

    expect(prismaMock.formTemplate.update).not.toHaveBeenCalled();
    expect(writeAuditMock).not.toHaveBeenCalled();
  });
});
