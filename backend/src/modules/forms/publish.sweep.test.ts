import { prisma } from '../../config/prisma';
import { emitFormAssigned } from '../notifications/notification.service';
import { runDueAssignmentsSweep } from './publish.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    formAssignment: {
      findMany: jest.fn(),
      updateMany: jest.fn(),
    },
  },
}));

jest.mock('../notifications/notification.service', () => ({
  emitFormAssigned: jest.fn(),
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  formAssignment: {
    findMany: jest.Mock;
    updateMany: jest.Mock;
  };
};
const emitFormAssignedMock = emitFormAssigned as jest.Mock;

const dueAssignment = {
  id: 'assignment-1',
  patientId: 'patient-1',
  assignedToUserId: null,
  target: 'SINGLE_PATIENT',
  patient: { userId: 'patient-user-1' },
  template: { name: 'PHQ-9' },
};

describe('runDueAssignmentsSweep', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    emitFormAssignedMock.mockResolvedValue(undefined);
  });

  it('promotes only scheduled assignments due by the sweep time and emits after claiming', async () => {
    const now = new Date('2026-06-01T08:00:00Z');
    prismaMock.formAssignment.findMany.mockResolvedValue([dueAssignment]);
    prismaMock.formAssignment.updateMany.mockResolvedValue({ count: 1 });

    await expect(runDueAssignmentsSweep(now)).resolves.toBe(1);

    expect(prismaMock.formAssignment.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          status: 'SCHEDULED',
          publishAt: { lte: now },
          template: { is: { isActive: true } },
        },
      })
    );
    expect(prismaMock.formAssignment.updateMany).toHaveBeenCalledWith({
      where: {
        id: 'assignment-1',
        status: 'SCHEDULED',
        publishAt: { lte: now },
        template: { is: { isActive: true } },
      },
      data: { status: 'PUBLISHED' },
    });
    expect(emitFormAssignedMock).toHaveBeenCalledWith(
      expect.objectContaining({
        assignmentId: 'assignment-1',
        recipientRole: 'PATIENT',
        recipientUserId: 'patient-user-1',
      })
    );
  });

  it('emits once when repeated sweeps observe the same candidate', async () => {
    prismaMock.formAssignment.findMany.mockResolvedValue([dueAssignment]);
    prismaMock.formAssignment.updateMany
      .mockResolvedValueOnce({ count: 1 })
      .mockResolvedValueOnce({ count: 0 });

    await expect(runDueAssignmentsSweep()).resolves.toBe(1);
    await expect(runDueAssignmentsSweep()).resolves.toBe(0);

    expect(emitFormAssignedMock).toHaveBeenCalledTimes(1);
  });

  it('does not promote or notify when a template is deactivated before the claim', async () => {
    prismaMock.formAssignment.findMany.mockResolvedValue([dueAssignment]);
    prismaMock.formAssignment.updateMany.mockResolvedValue({ count: 0 });

    await expect(runDueAssignmentsSweep()).resolves.toBe(0);

    expect(prismaMock.formAssignment.updateMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ template: { is: { isActive: true } } }),
      })
    );
    expect(emitFormAssignedMock).not.toHaveBeenCalled();
  });
});
