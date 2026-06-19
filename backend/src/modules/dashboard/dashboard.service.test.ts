import { prisma } from '../../config/prisma';
import { NotificationModel } from '../notifications/notification.model';
import { listRecentAuditLogs } from '../audit-logs/audit.service';
import * as dashboardService from './dashboard.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    user: {
      count: jest.fn(),
      groupBy: jest.fn(),
      findMany: jest.fn(),
    },
    assessment: {
      groupBy: jest.fn(),
    },
    report: {
      count: jest.fn(),
    },
  },
}));

jest.mock('../notifications/notification.model', () => ({
  NotificationModel: {
    countDocuments: jest.fn(),
  },
}));

jest.mock('../audit-logs/audit.service', () => ({
  listRecentAuditLogs: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  user: {
    count: jest.Mock;
    groupBy: jest.Mock;
    findMany: jest.Mock;
  };
  assessment: {
    groupBy: jest.Mock;
  };
  report: {
    count: jest.Mock;
  };
};

const notificationModelMock = NotificationModel as unknown as {
  countDocuments: jest.Mock;
};
const listRecentAuditLogsMock = listRecentAuditLogs as jest.Mock;

describe('dashboard service', () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });

  it('returns summary counts with zero-filled distributions and open report/notification counts', async () => {
    prismaMock.user.count.mockResolvedValueOnce(10).mockResolvedValueOnce(8);
    prismaMock.user.groupBy.mockResolvedValue([
      { role: 'ADMIN', _count: { _all: 2 } },
      { role: 'PATIENT', _count: { _all: 6 } },
    ]);
    prismaMock.assessment.groupBy.mockResolvedValue([
      { status: 'NORMAL', _count: { _all: 3 } },
      { status: 'CRITICAL', _count: { _all: 1 } },
    ]);
    prismaMock.report.count.mockResolvedValue(4);
    notificationModelMock.countDocuments.mockResolvedValue(5);

    await expect(dashboardService.getSummary()).resolves.toEqual({
      users: {
        total: 10,
        active: 8,
        byRole: {
          ADMIN: 2,
          DOCTOR: 0,
          VOLUNTEER: 0,
          CALL_CENTER: 0,
          PATIENT: 6,
        },
      },
      reports: { open: 4 },
      assessments: {
        byStatus: {
          NORMAL: 3,
          MILD: 0,
          MODERATE: 0,
          SEVERE: 0,
          CRITICAL: 1,
        },
      },
      notifications: { open: 5 },
    });

    expect(prismaMock.report.count).toHaveBeenCalledWith({
      where: { status: { not: 'RESOLVED' } },
    });
    expect(notificationModelMock.countDocuments).toHaveBeenCalledWith({
      status: { $in: ['UNREAD', 'READ'] },
    });
  });

  it('returns recent activity with batched actor names and null actors for system or unknown users', async () => {
    const actorId = '11111111-1111-4111-8111-111111111111';
    listRecentAuditLogsMock.mockResolvedValue([
      {
        _id: { toString: () => 'audit-1' },
        actorId,
        action: 'REPORT_STATUS_CHANGED',
        entityType: 'REPORT',
        createdAt: new Date('2026-06-18T09:58:00.000Z'),
      },
      {
        _id: { toString: () => 'audit-2' },
        actorId: 'missing-user',
        action: 'PATIENT_UPDATED',
        entityType: 'PATIENT',
        createdAt: new Date('2026-06-18T09:30:00.000Z'),
      },
      {
        _id: { toString: () => 'audit-3' },
        actorId: null,
        action: 'HIGH_RISK_ALERT_CREATED',
        entityType: 'ASSESSMENT',
        createdAt: new Date('2026-06-18T09:00:00.000Z'),
      },
    ]);
    prismaMock.user.findMany.mockResolvedValue([
      { id: actorId, fullName: 'Admin Bahya' },
    ]);

    await expect(dashboardService.getActivity(3)).resolves.toEqual({
      data: [
        {
          id: 'audit-1',
          action: 'REPORT_STATUS_CHANGED',
          entityType: 'REPORT',
          actor: { id: actorId, fullName: 'Admin Bahya' },
          createdAt: new Date('2026-06-18T09:58:00.000Z'),
        },
        {
          id: 'audit-2',
          action: 'PATIENT_UPDATED',
          entityType: 'PATIENT',
          actor: null,
          createdAt: new Date('2026-06-18T09:30:00.000Z'),
        },
        {
          id: 'audit-3',
          action: 'HIGH_RISK_ALERT_CREATED',
          entityType: 'ASSESSMENT',
          actor: null,
          createdAt: new Date('2026-06-18T09:00:00.000Z'),
        },
      ],
    });

    expect(listRecentAuditLogsMock).toHaveBeenCalledWith(3);
    expect(prismaMock.user.findMany).toHaveBeenCalledWith({
      where: { id: { in: [actorId, 'missing-user'] } },
      select: { id: true, fullName: true },
    });
  });
});
