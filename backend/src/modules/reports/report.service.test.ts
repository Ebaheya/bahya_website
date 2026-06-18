import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { ReportErrors } from './report.errors';
import * as reportService from './report.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    $transaction: jest.fn(),
    report: {
      create: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      groupBy: jest.fn(),
    },
  },
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  $transaction: jest.Mock;
  report: {
    create: jest.Mock;
    findMany: jest.Mock;
    count: jest.Mock;
    findUnique: jest.Mock;
    update: jest.Mock;
    groupBy: jest.Mock;
  };
};

const writeAuditMock = writeAudit as jest.Mock;

const reportId = '11111111-1111-4111-8111-111111111111';
const reporterId = '22222222-2222-4222-8222-222222222222';
const adminId = '33333333-3333-4333-8333-333333333333';

function reportRow(overrides: Record<string, unknown> = {}) {
  return {
    id: reportId,
    reporterId,
    title: 'Content Report',
    body: 'Some content contains inappropriate language.',
    status: 'PENDING',
    handledById: null,
    handledAt: null,
    createdAt: new Date('2026-06-18T10:00:00.000Z'),
    updatedAt: new Date('2026-06-18T10:00:00.000Z'),
    reporter: {
      id: reporterId,
      fullName: 'Sarah Johnson',
      email: 'sarah.johnson@email.com',
      role: 'DOCTOR',
    },
    handledBy: null,
    ...overrides,
  };
}

describe('report service', () => {
  beforeEach(() => {
    jest.resetAllMocks();
    writeAuditMock.mockResolvedValue(undefined);
  });

  it('creates reports as pending for the authenticated reporter and audits creation', async () => {
    prismaMock.report.create.mockResolvedValue({
      id: reportId,
      title: 'Content Report',
      status: 'PENDING',
      createdAt: new Date('2026-06-18T10:00:00.000Z'),
    });

    await expect(
      reportService.createReport(
        { title: 'Content Report', body: 'Some content contains inappropriate language.' },
        reporterId
      )
    ).resolves.toMatchObject({
      id: reportId,
      title: 'Content Report',
      status: 'PENDING',
    });

    expect(prismaMock.report.create).toHaveBeenCalledWith({
      data: {
        title: 'Content Report',
        body: 'Some content contains inappropriate language.',
        reporterId,
        status: 'PENDING',
      },
      select: expect.any(Object),
    });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: reporterId,
        action: 'REPORT_CREATED',
        entityType: 'REPORT',
        entityId: reportId,
        newValues: {
          title: 'Content Report',
          status: 'PENDING',
          reporterId,
        },
      })
    );
  });

  it('lists reports with status filter, q search over title and reporter identity, and deactivated reporter enrichment', async () => {
    const row = reportRow();
    prismaMock.report.findMany.mockResolvedValue([row]);
    prismaMock.report.count.mockResolvedValue(1);
    prismaMock.$transaction.mockImplementation(async (queries) => Promise.all(queries));

    await expect(
      reportService.listReports({
        status: 'PENDING',
        q: 'sarah',
        page: 2,
        pageSize: 5,
      })
    ).resolves.toEqual({
      data: [
        {
          id: reportId,
          title: 'Content Report',
          status: 'PENDING',
          createdAt: row.createdAt,
          reporter: row.reporter,
        },
      ],
      page: 2,
      pageSize: 5,
      total: 1,
    });

    expect(prismaMock.report.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          status: 'PENDING',
          OR: [
            { title: { contains: 'sarah', mode: 'insensitive' } },
            { reporter: { fullName: { contains: 'sarah', mode: 'insensitive' } } },
            { reporter: { email: { contains: 'sarah', mode: 'insensitive' } } },
          ],
        },
        orderBy: { createdAt: 'desc' },
        skip: 5,
        take: 5,
      })
    );
    expect(prismaMock.report.findMany.mock.calls[0][0].select.reporter.select).toEqual({
      id: true,
      fullName: true,
      email: true,
      role: true,
    });
  });

  it('returns zero-filled report summary counts', async () => {
    prismaMock.report.groupBy.mockResolvedValue([
      { status: 'PENDING', _count: { _all: 2 } },
      { status: 'RESOLVED', _count: { _all: 4 } },
    ]);

    await expect(reportService.getSummary()).resolves.toEqual({
      pending: 2,
      investigating: 0,
      resolved: 4,
    });
  });

  it('returns report detail with reporter and handler enrichment', async () => {
    const handledAt = new Date('2026-06-18T11:00:00.000Z');
    prismaMock.report.findUnique.mockResolvedValue(
      reportRow({
        status: 'RESOLVED',
        handledById: adminId,
        handledAt,
        handledBy: {
          id: adminId,
          fullName: 'Admin Bahya',
          email: 'admin@bahya.org',
          role: 'ADMIN',
        },
      })
    );

    await expect(reportService.getReportById(reportId)).resolves.toMatchObject({
      id: reportId,
      body: 'Some content contains inappropriate language.',
      status: 'RESOLVED',
      reporter: { id: reporterId, fullName: 'Sarah Johnson' },
      handledBy: { id: adminId, fullName: 'Admin Bahya' },
      handledAt,
    });
  });

  it('throws not found when a report is missing', async () => {
    prismaMock.report.findUnique.mockResolvedValue(null);

    await expect(reportService.getReportById(reportId)).rejects.toMatchObject({
      statusCode: ReportErrors.reportNotFound().statusCode,
      code: ReportErrors.reportNotFound().code,
    });
  });

  it('changes status, records handler fields, and audits status changes', async () => {
    const existing = reportRow({ status: 'PENDING' });
    const updated = reportRow({
      status: 'RESOLVED',
      handledById: adminId,
      handledAt: new Date('2026-06-18T11:00:00.000Z'),
    });
    prismaMock.report.findUnique.mockResolvedValueOnce(existing).mockResolvedValueOnce(updated);
    prismaMock.report.update.mockResolvedValue(updated);

    await expect(reportService.changeStatus(reportId, 'RESOLVED', adminId)).resolves.toMatchObject({
      id: reportId,
      status: 'RESOLVED',
      handledById: adminId,
    });

    expect(prismaMock.report.update).toHaveBeenCalledWith({
      where: { id: reportId },
      data: {
        status: 'RESOLVED',
        handledById: adminId,
        handledAt: expect.any(Date),
      },
      select: expect.any(Object),
    });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: adminId,
        action: 'REPORT_STATUS_CHANGED',
        entityType: 'REPORT',
        entityId: reportId,
        oldValues: { status: 'PENDING' },
        newValues: { status: 'RESOLVED' },
      })
    );
  });

  it('does not update or audit when status is unchanged', async () => {
    const existing = reportRow({ status: 'PENDING' });
    prismaMock.report.findUnique.mockResolvedValue(existing);

    await expect(reportService.changeStatus(reportId, 'PENDING', adminId)).resolves.toMatchObject({
      id: reportId,
      status: 'PENDING',
    });

    expect(prismaMock.report.update).not.toHaveBeenCalled();
    expect(writeAuditMock).not.toHaveBeenCalled();
  });
});
