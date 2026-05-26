import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { emitFormAssigned } from '../notifications/notification.service';
import { publishFormSchema } from './publish.schema';
import * as publishService from './publish.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    $transaction: jest.fn(),
    formTemplate: { findUnique: jest.fn() },
    formAssignment: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
      count: jest.fn(),
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
  formTemplate: { findUnique: jest.Mock };
  formAssignment: {
    findMany: jest.Mock;
    findUnique: jest.Mock;
    update: jest.Mock;
    updateMany: jest.Mock;
    count: jest.Mock;
  };
};
const writeAuditMock = writeAudit as jest.Mock;
const emitFormAssignedMock = emitFormAssigned as jest.Mock;

const template = {
  id: 'form-1',
  name: 'PHQ-9',
  isActive: true,
  currentVersion: {
    id: 'version-1',
    status: 'PUBLISHED',
    questions: [{ id: 'question-1' }],
  },
};

function transactionTx() {
  return {
    formTemplate: { findUnique: jest.fn().mockResolvedValue(template) },
    patient: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
    },
    user: { findUnique: jest.fn() },
    formAssignment: { createManyAndReturn: jest.fn() },
  };
}

describe('publish request validation', () => {
  it('requires target-specific identifiers and transforms scheduled dates', () => {
    expect(
      publishFormSchema.parse({
        target: 'ALL_PATIENTS',
        publishAt: '2026-06-01T08:00:00Z',
      }).publishAt
    ).toEqual(new Date('2026-06-01T08:00:00Z'));

    expect(
      publishFormSchema.safeParse({
        target: 'VOLUNTEER_FOR_PATIENT',
        patientId: 'e2108357-5e7d-49d5-aad1-d6b0914e7cf7',
      }).success
    ).toBe(false);
  });
});

describe('publishForm', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    writeAuditMock.mockResolvedValue(undefined);
    emitFormAssignedMock.mockResolvedValue(undefined);
  });

  it('publishes immediately to one patient, pins the version, notifies, and audits', async () => {
    const tx = transactionTx();
    tx.patient.findUnique.mockResolvedValue({
      id: 'patient-1',
      userId: 'patient-user-1',
      user: { isActive: true },
    });
    tx.formAssignment.createManyAndReturn.mockResolvedValue([
      { id: 'assignment-1', patientId: 'patient-1', assignedToUserId: null, target: 'SINGLE_PATIENT' },
    ]);
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(
      publishService.publishForm(
        'form-1',
        publishFormSchema.parse({
          target: 'SINGLE_PATIENT',
          patientId: 'e2108357-5e7d-49d5-aad1-d6b0914e7cf7',
        }),
        'doctor-1',
        undefined,
        new Date('2026-05-25T12:00:00Z')
      )
    ).resolves.toEqual({ assignmentsCreated: 1, assignmentIds: ['assignment-1'] });

    expect(tx.formAssignment.createManyAndReturn).toHaveBeenCalledWith({
      data: [
        expect.objectContaining({
          templateId: 'form-1',
          formVersionId: 'version-1',
          patientId: 'patient-1',
          assignedById: 'doctor-1',
          target: 'SINGLE_PATIENT',
          status: 'PUBLISHED',
          publishAt: null,
        }),
      ],
      select: { id: true, patientId: true, assignedToUserId: true, target: true },
    });
    expect(emitFormAssignedMock).toHaveBeenCalledWith({
      assignmentId: 'assignment-1',
      patientId: 'patient-1',
      recipientRole: 'PATIENT',
      recipientUserId: 'patient-user-1',
      formName: 'PHQ-9',
    });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: 'doctor-1',
        action: 'FORM_PUBLISHED',
        entityId: 'form-1',
      })
    );
  });

  it('fans out only the active patient snapshot returned by the transaction', async () => {
    const tx = transactionTx();
    tx.patient.findMany.mockResolvedValue([
      { id: 'patient-1', userId: 'user-1' },
      { id: 'patient-2', userId: 'user-2' },
    ]);
    tx.formAssignment.createManyAndReturn.mockResolvedValue([
      { id: 'assignment-1', patientId: 'patient-1', assignedToUserId: null, target: 'ALL_PATIENTS' },
      { id: 'assignment-2', patientId: 'patient-2', assignedToUserId: null, target: 'ALL_PATIENTS' },
    ]);
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(
      publishService.publishForm(
        'form-1',
        publishFormSchema.parse({ target: 'ALL_PATIENTS' }),
        'doctor-1'
      )
    ).resolves.toEqual({
      assignmentsCreated: 2,
      assignmentIds: ['assignment-1', 'assignment-2'],
    });

    expect(tx.patient.findMany).toHaveBeenCalledWith({
      where: { user: { is: { role: 'PATIENT', isActive: true } } },
      select: { id: true, userId: true },
    });
    expect(tx.formAssignment.createManyAndReturn).toHaveBeenCalledTimes(1);
    expect(tx.formAssignment.createManyAndReturn).toHaveBeenCalledWith(
      expect.objectContaining({
        data: [
          expect.objectContaining({ patientId: 'patient-1', target: 'ALL_PATIENTS' }),
          expect.objectContaining({ patientId: 'patient-2', target: 'ALL_PATIENTS' }),
        ],
      })
    );
    expect(emitFormAssignedMock).toHaveBeenCalledTimes(2);
  });

  it('returns no assignments when there are no active patients to publish to', async () => {
    const tx = transactionTx();
    tx.patient.findMany.mockResolvedValue([]);
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(
      publishService.publishForm(
        'form-1',
        publishFormSchema.parse({ target: 'ALL_PATIENTS' }),
        'doctor-1'
      )
    ).resolves.toEqual({ assignmentsCreated: 0, assignmentIds: [] });

    expect(tx.formAssignment.createManyAndReturn).not.toHaveBeenCalled();
    expect(emitFormAssignedMock).not.toHaveBeenCalled();
  });

  it('schedules a volunteer assignment without notifying before visibility', async () => {
    const tx = transactionTx();
    tx.patient.findUnique.mockResolvedValue({
      id: 'patient-1',
      userId: 'patient-user-1',
      user: { isActive: true },
    });
    tx.user.findUnique.mockResolvedValue({ id: 'volunteer-1', role: 'VOLUNTEER', isActive: true });
    tx.formAssignment.createManyAndReturn.mockResolvedValue([
      {
        id: 'assignment-1',
        patientId: 'patient-1',
        assignedToUserId: 'volunteer-1',
        target: 'VOLUNTEER_FOR_PATIENT',
      },
    ]);
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));
    const publishAt = '2026-06-01T08:00:00Z';

    await publishService.publishForm(
      'form-1',
      publishFormSchema.parse({
        target: 'VOLUNTEER_FOR_PATIENT',
        patientId: 'e2108357-5e7d-49d5-aad1-d6b0914e7cf7',
        volunteerId: '57a9983a-ae0a-4e58-89cb-53ee15bb0f57',
        publishAt,
      }),
      'doctor-1',
      undefined,
      new Date('2026-05-25T12:00:00Z')
    );

    expect(tx.formAssignment.createManyAndReturn).toHaveBeenCalledWith({
      data: [
        expect.objectContaining({
          assignedToUserId: 'volunteer-1',
          target: 'VOLUNTEER_FOR_PATIENT',
          status: 'SCHEDULED',
          publishAt: new Date(publishAt),
        }),
      ],
      select: { id: true, patientId: true, assignedToUserId: true, target: true },
    });
    expect(emitFormAssignedMock).not.toHaveBeenCalled();
  });

  it('rejects a direct assignment to an inactive patient', async () => {
    const tx = transactionTx();
    tx.patient.findUnique.mockResolvedValue({
      id: 'patient-1',
      userId: 'patient-user-1',
      user: { isActive: false },
    });
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(
      publishService.publishForm(
        'form-1',
        publishFormSchema.parse({
          target: 'SINGLE_PATIENT',
          patientId: 'e2108357-5e7d-49d5-aad1-d6b0914e7cf7',
        }),
        'doctor-1'
      )
    ).rejects.toMatchObject({ statusCode: 404, code: 'NOT_FOUND' });

    expect(tx.formAssignment.createManyAndReturn).not.toHaveBeenCalled();
  });

  it('rejects a delegated assignment to an inactive volunteer', async () => {
    const tx = transactionTx();
    tx.patient.findUnique.mockResolvedValue({
      id: 'patient-1',
      userId: 'patient-user-1',
      user: { isActive: true },
    });
    tx.user.findUnique.mockResolvedValue({
      id: 'volunteer-1',
      role: 'VOLUNTEER',
      isActive: false,
    });
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(
      publishService.publishForm(
        'form-1',
        publishFormSchema.parse({
          target: 'VOLUNTEER_FOR_PATIENT',
          patientId: 'e2108357-5e7d-49d5-aad1-d6b0914e7cf7',
          volunteerId: '57a9983a-ae0a-4e58-89cb-53ee15bb0f57',
        }),
        'doctor-1'
      )
    ).rejects.toMatchObject({ statusCode: 400, code: 'FORM_INVALID_VOLUNTEER' });

    expect(tx.formAssignment.createManyAndReturn).not.toHaveBeenCalled();
  });

  it('rejects an inactive or unpublished form', async () => {
    const tx = transactionTx();
    tx.formTemplate.findUnique.mockResolvedValue({ ...template, isActive: false });
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(
      publishService.publishForm(
        'form-1',
        publishFormSchema.parse({ target: 'ALL_PATIENTS' }),
        'doctor-1'
      )
    ).rejects.toMatchObject({ statusCode: 409, code: 'FORM_NOT_PUBLISHABLE' });
    expect(tx.formAssignment.createManyAndReturn).not.toHaveBeenCalled();
  });
});

describe('cancelAssignment', () => {
  beforeEach(() => jest.clearAllMocks());

  it('cancels a published assignment atomically and rejects a submitted assignment', async () => {
    const txCancel = {
      formAssignment: {
        findUnique: jest.fn().mockResolvedValue({ id: 'assignment-1', status: 'PUBLISHED' }),
        updateMany: jest.fn().mockResolvedValue({ count: 1 }),
      },
    };
    const txSubmitted = {
      formAssignment: {
        findUnique: jest.fn().mockResolvedValue({ id: 'assignment-2', status: 'SUBMITTED' }),
        updateMany: jest.fn(),
      },
    };
    prismaMock.$transaction
      .mockImplementationOnce(async (callback) => callback(txCancel))
      .mockImplementationOnce(async (callback) => callback(txSubmitted));

    await expect(publishService.cancelAssignment('assignment-1')).resolves.toMatchObject({
      status: 'CANCELLED',
    });
    await expect(publishService.cancelAssignment('assignment-2')).rejects.toMatchObject({
      statusCode: 409,
      code: 'FORM_ASSIGNMENT_FINALIZED',
    });
    expect(txCancel.formAssignment.updateMany).toHaveBeenCalledWith({
      where: { id: 'assignment-1', status: { in: ['SCHEDULED', 'PUBLISHED'] } },
      data: { status: 'CANCELLED' },
    });
    expect(txSubmitted.formAssignment.updateMany).not.toHaveBeenCalled();
  });

  it('rejects when the row is finalized between read and guarded write', async () => {
    const tx = {
      formAssignment: {
        findUnique: jest.fn().mockResolvedValue({ id: 'assignment-3', status: 'PUBLISHED' }),
        updateMany: jest.fn().mockResolvedValue({ count: 0 }),
      },
    };
    prismaMock.$transaction.mockImplementationOnce(async (callback) => callback(tx));

    await expect(publishService.cancelAssignment('assignment-3')).rejects.toMatchObject({
      statusCode: 409,
      code: 'FORM_ASSIGNMENT_FINALIZED',
    });
  });
});
