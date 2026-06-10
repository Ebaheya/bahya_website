import { Prisma } from '@prisma/client';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import {
  emitServiceRequestDecided,
  emitServiceRequestSubmitted,
} from '../notifications/notification.service';
import { ServiceErrors } from './service.errors';
import * as requestService from './request.service';
import * as serviceService from './service.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    $transaction: jest.fn(),
    patient: {
      findUnique: jest.fn(),
    },
    service: {
      findMany: jest.fn(),
      count: jest.fn(),
    },
    serviceRequest: {
      findMany: jest.fn(),
      count: jest.fn(),
    },
  },
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

jest.mock('../notifications/notification.service', () => ({
  emitServiceRequestDecided: jest.fn(),
  emitServiceRequestSubmitted: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  $transaction: jest.Mock;
  patient: { findUnique: jest.Mock };
  service: {
    findMany: jest.Mock;
    count: jest.Mock;
  };
  serviceRequest: {
    findMany: jest.Mock;
    count: jest.Mock;
  };
};

const writeAuditMock = writeAudit as jest.Mock;
const emitServiceRequestDecidedMock = emitServiceRequestDecided as jest.Mock;
const emitServiceRequestSubmittedMock = emitServiceRequestSubmitted as jest.Mock;

const categoryId = '11111111-1111-4111-8111-111111111111';
const serviceId = '22222222-2222-4222-8222-222222222222';
const patientId = '33333333-3333-4333-8333-333333333333';
const actorUserId = '44444444-4444-4444-8444-444444444444';
const doctorId = '55555555-5555-4555-8555-555555555555';
const requestId = '66666666-6666-4666-8666-666666666666';

function service(overrides: Record<string, unknown> = {}) {
  return {
    id: serviceId,
    categoryId,
    name: 'Literacy Class',
    locationBranch: 'Main Branch',
    startDate: new Date('2026-07-20T00:00:00.000Z'),
    startTime: '10:00',
    endDate: null,
    departureTime: null,
    meetingPlace: null,
    capacity: 10,
    seatsTaken: 4,
    status: 'ACTIVE',
    createdById: 'doctor-1',
    createdAt: new Date('2026-06-10T00:00:00.000Z'),
    updatedAt: new Date('2026-06-10T00:00:00.000Z'),
    category: {
      id: categoryId,
      name: 'Education',
      kind: 'EDUCATIONAL',
      iconKey: 'school',
      color: '#6CCB4F',
    },
    ...overrides,
  };
}

function txWith({
  serviceRow = { id: serviceId, status: 'ACTIVE', capacity: 10, seatsTaken: 4 },
  duplicate = null,
}: {
  serviceRow?: unknown;
  duplicate?: unknown;
} = {}) {
  return {
    service: {
      findUnique: jest.fn().mockResolvedValue(serviceRow),
    },
    serviceRequest: {
      findFirst: jest.fn().mockResolvedValue(duplicate),
      create: jest.fn().mockResolvedValue({
        id: 'request-1',
        status: 'PENDING',
        serviceId,
        requestedAt: new Date('2026-06-10T00:00:00.000Z'),
      }),
    },
  };
}

function decisionRequest(overrides: Record<string, unknown> = {}) {
  return {
    id: requestId,
    serviceId,
    patientId,
    status: 'PENDING',
    decisionNote: null,
    decidedById: null,
    requestedAt: new Date('2026-06-10T00:00:00.000Z'),
    decidedAt: null,
    service: {
      id: serviceId,
      name: 'Literacy Class',
      capacity: 10,
      seatsTaken: 9,
    },
    patient: {
      id: patientId,
      userId: actorUserId,
    },
    ...overrides,
  };
}

function decisionTxWith({
  existing = decisionRequest(),
  seatCount = 1,
  requestCount = 1,
  updated = decisionRequest({ status: 'APPROVED', decidedById: doctorId, decidedAt: new Date('2026-06-10T01:00:00.000Z') }),
}: {
  existing?: unknown;
  seatCount?: number;
  requestCount?: number;
  updated?: unknown;
} = {}) {
  return {
    service: {
      updateMany: jest.fn().mockResolvedValue({ count: seatCount }),
    },
    serviceRequest: {
      findUnique: jest.fn().mockResolvedValueOnce(existing).mockResolvedValueOnce(updated),
      updateMany: jest.fn().mockResolvedValue({ count: requestCount }),
    },
  };
}

function myRequest(overrides: Record<string, unknown> = {}) {
  return {
    id: requestId,
    status: 'PENDING',
    decisionNote: null,
    requestedAt: new Date('2026-06-10T00:00:00.000Z'),
    decidedAt: null,
    service: {
      id: serviceId,
      name: 'Literacy Class',
      startDate: new Date('2026-07-20T00:00:00.000Z'),
      startTime: '10:00',
      locationBranch: 'Main Branch',
      category: { kind: 'EDUCATIONAL' },
    },
    ...overrides,
  };
}

function cancelTxWith({
  existing = { id: requestId, patientId, status: 'PENDING' },
  updateCount = 1,
  updated = {
    id: requestId,
    status: 'CANCELLED',
    serviceId,
    patientId,
  },
}: {
  existing?: unknown;
  updateCount?: number;
  updated?: unknown;
} = {}) {
  return {
    serviceRequest: {
      findUnique: jest.fn().mockResolvedValueOnce(existing).mockResolvedValueOnce(updated),
      updateMany: jest.fn().mockResolvedValue({ count: updateCount }),
    },
  };
}

describe('service browsing and request creation', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    writeAuditMock.mockResolvedValue(undefined);
    emitServiceRequestDecidedMock.mockResolvedValue(undefined);
    emitServiceRequestSubmittedMock.mockResolvedValue(undefined);
    prismaMock.patient.findUnique.mockResolvedValue({ id: patientId });
  });

  it('lists only active services for patients and includes remaining seats', async () => {
    prismaMock.service.findMany.mockResolvedValue([service()]);
    prismaMock.service.count.mockResolvedValue(1);

    await expect(
      serviceService.listServices({ page: 1, pageSize: 20 }, 'PATIENT')
    ).resolves.toMatchObject({
      total: 1,
      data: [expect.objectContaining({ status: 'ACTIVE', remainingSeats: 6 })],
    });

    expect(prismaMock.service.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ status: 'ACTIVE' }),
      })
    );
  });

  it('applies kind, category, and q filters for browsing', async () => {
    prismaMock.service.findMany.mockResolvedValue([service()]);
    prismaMock.service.count.mockResolvedValue(1);

    await serviceService.listServices(
      { kind: 'EDUCATIONAL', categoryId, q: 'literacy', page: 2, pageSize: 5 },
      'ADMIN'
    );

    expect(prismaMock.service.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          categoryId,
          category: { kind: 'EDUCATIONAL' },
          OR: expect.arrayContaining([
            { name: { contains: 'literacy', mode: 'insensitive' } },
            { locationBranch: { contains: 'literacy', mode: 'insensitive' } },
            { category: { name: { contains: 'literacy', mode: 'insensitive' } } },
          ]),
        }),
        skip: 5,
        take: 5,
      })
    );
  });

  it('lists pending request queue rows with patient and service summaries', async () => {
    prismaMock.serviceRequest.findMany.mockResolvedValue([
      {
        id: requestId,
        status: 'PENDING',
        requestedAt: new Date('2026-06-10T00:00:00.000Z'),
        decidedAt: null,
        decisionNote: null,
        patient: { id: patientId, crn: 'PT-123', user: { fullName: 'Sara Mohamed' } },
        service: {
          id: serviceId,
          name: 'Literacy Class',
          category: { kind: 'EDUCATIONAL' },
        },
      },
    ]);
    prismaMock.serviceRequest.count.mockResolvedValue(1);

    await expect(
      requestService.listQueue({ status: 'PENDING', serviceId, page: 1, pageSize: 20 })
    ).resolves.toMatchObject({
      total: 1,
      data: [
        {
          id: requestId,
          patient: { id: patientId, fullName: 'Sara Mohamed', crn: 'PT-123' },
          service: { id: serviceId, name: 'Literacy Class', kind: 'EDUCATIONAL' },
        },
      ],
    });
  });

  it('creates a pending request and emits notification plus audit', async () => {
    const tx = txWith();
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(requestService.createRequest(serviceId, actorUserId)).resolves.toMatchObject({
      id: 'request-1',
      status: 'PENDING',
      serviceId,
    });

    expect(emitServiceRequestSubmittedMock).toHaveBeenCalledWith({ patientId });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: actorUserId,
        action: 'SERVICE_REQUEST_CREATED',
        entityType: 'SERVICE_REQUEST',
        entityId: 'request-1',
      })
    );
  });

  it('rejects closed, full, and duplicate active requests', async () => {
    for (const [tx, expected] of [
      [txWith({ serviceRow: { id: serviceId, status: 'CLOSED', capacity: 10, seatsTaken: 0 } }), ServiceErrors.serviceNotAccepting()],
      [txWith({ serviceRow: { id: serviceId, status: 'ACTIVE', capacity: 10, seatsTaken: 10 } }), ServiceErrors.serviceFull()],
      [txWith({ duplicate: { id: 'existing-request' } }), ServiceErrors.duplicateServiceRequest()],
    ] as const) {
      prismaMock.$transaction.mockImplementationOnce(async (callback) => callback(tx));
      await expect(requestService.createRequest(serviceId, actorUserId)).rejects.toMatchObject({
        statusCode: expected.statusCode,
        code: expected.code,
      });
    }

    expect(emitServiceRequestSubmittedMock).not.toHaveBeenCalled();
    expect(writeAuditMock).not.toHaveBeenCalled();
  });

  it('translates a concurrent unique-violation (P2002) to DUPLICATE_SERVICE_REQUEST', async () => {
    // Two concurrent creates that both pass the in-tx duplicate read collide on
    // the partial unique index; the loser's insert raises P2002, which must
    // surface as DUPLICATE_SERVICE_REQUEST rather than a generic conflict.
    const uniqueViolation = new Prisma.PrismaClientKnownRequestError('Unique constraint failed', {
      code: 'P2002',
      clientVersion: 'test',
    });
    prismaMock.$transaction.mockRejectedValueOnce(uniqueViolation);

    await expect(requestService.createRequest(serviceId, actorUserId)).rejects.toMatchObject({
      statusCode: ServiceErrors.duplicateServiceRequest().statusCode,
      code: ServiceErrors.duplicateServiceRequest().code,
    });

    expect(emitServiceRequestSubmittedMock).not.toHaveBeenCalled();
    expect(writeAuditMock).not.toHaveBeenCalled();
  });

  it('approves a pending request, consumes one seat, and emits one decision notification and audit', async () => {
    const tx = decisionTxWith();
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(requestService.approveRequest(requestId, doctorId)).resolves.toMatchObject({
      id: requestId,
      status: 'APPROVED',
      decidedById: doctorId,
    });

    expect(tx.service.updateMany).toHaveBeenCalledWith({
      where: {
        id: serviceId,
        seatsTaken: { lt: 10 },
      },
      data: { seatsTaken: { increment: 1 } },
    });
    expect(emitServiceRequestDecidedMock).toHaveBeenCalledTimes(1);
    expect(emitServiceRequestDecidedMock).toHaveBeenCalledWith({
      patientId,
      recipientUserId: actorUserId,
      approved: true,
      serviceName: 'Literacy Class',
    });
    expect(writeAuditMock).toHaveBeenCalledTimes(1);
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: doctorId,
        action: 'SERVICE_REQUEST_APPROVED',
        entityId: requestId,
      })
    );
  });

  it('rejects approve when the service is full or the request is already decided', async () => {
    const fullTx = decisionTxWith({ seatCount: 0 });
    prismaMock.$transaction.mockImplementationOnce(async (callback) => callback(fullTx));
    await expect(requestService.approveRequest(requestId, doctorId)).rejects.toMatchObject({
      statusCode: 409,
      code: ServiceErrors.serviceFull().code,
    });

    const decidedTx = decisionTxWith({ existing: decisionRequest({ status: 'APPROVED' }) });
    prismaMock.$transaction.mockImplementationOnce(async (callback) => callback(decidedTx));
    await expect(requestService.approveRequest(requestId, doctorId)).rejects.toMatchObject({
      statusCode: 409,
      code: ServiceErrors.requestAlreadyDecided().code,
    });

    expect(emitServiceRequestDecidedMock).not.toHaveBeenCalled();
  });

  it('allows only one simultaneous approval to consume the last seat', async () => {
    const otherRequestId = '77777777-7777-4777-8777-777777777777';
    const winningTx = decisionTxWith({
      existing: decisionRequest({ id: requestId }),
      updated: decisionRequest({
        id: requestId,
        status: 'APPROVED',
        decidedById: doctorId,
        decidedAt: new Date('2026-06-10T01:00:00.000Z'),
      }),
    });
    const losingTx = decisionTxWith({
      existing: decisionRequest({ id: otherRequestId }),
      seatCount: 0,
    });
    prismaMock.$transaction
      .mockImplementationOnce(async (callback) => callback(winningTx))
      .mockImplementationOnce(async (callback) => callback(losingTx));

    const results = await Promise.allSettled([
      requestService.approveRequest(requestId, doctorId),
      requestService.approveRequest(otherRequestId, doctorId),
    ]);

    expect(results).toHaveLength(2);
    expect(results.filter((result) => result.status === 'fulfilled')).toHaveLength(1);
    const rejection = results.find((result) => result.status === 'rejected');
    expect(rejection).toMatchObject({
      reason: {
        statusCode: 409,
        code: ServiceErrors.serviceFull().code,
      },
    });
    expect(winningTx.service.updateMany).toHaveBeenCalledWith({
      where: { id: serviceId, seatsTaken: { lt: 10 } },
      data: { seatsTaken: { increment: 1 } },
    });
    expect(losingTx.service.updateMany).toHaveBeenCalledWith({
      where: { id: serviceId, seatsTaken: { lt: 10 } },
      data: { seatsTaken: { increment: 1 } },
    });
    expect(emitServiceRequestDecidedMock).toHaveBeenCalledTimes(1);
    expect(writeAuditMock).toHaveBeenCalledTimes(1);
  });

  it('rejects a pending request with a decision note and emits one patient notification and audit', async () => {
    const updated = decisionRequest({
      status: 'REJECTED',
      decisionNote: 'Capacity is reserved for a later cohort',
      decidedById: doctorId,
      decidedAt: new Date('2026-06-10T01:00:00.000Z'),
    });
    const tx = decisionTxWith({ updated });
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(
      requestService.rejectRequest(requestId, doctorId, 'Capacity is reserved for a later cohort')
    ).resolves.toMatchObject({
      id: requestId,
      status: 'REJECTED',
      decisionNote: 'Capacity is reserved for a later cohort',
    });

    expect(tx.service.updateMany).not.toHaveBeenCalled();
    expect(emitServiceRequestDecidedMock).toHaveBeenCalledTimes(1);
    expect(emitServiceRequestDecidedMock).toHaveBeenCalledWith({
      patientId,
      recipientUserId: actorUserId,
      approved: false,
      serviceName: 'Literacy Class',
    });
    expect(writeAuditMock).toHaveBeenCalledTimes(1);
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: doctorId,
        action: 'SERVICE_REQUEST_REJECTED',
        entityId: requestId,
      })
    );
  });

  it('lists only the caller patient requests with service summaries', async () => {
    prismaMock.serviceRequest.findMany.mockResolvedValue([myRequest()]);

    await expect(requestService.listMyRequests(actorUserId)).resolves.toEqual([
      {
        id: requestId,
        status: 'PENDING',
        decisionNote: null,
        requestedAt: new Date('2026-06-10T00:00:00.000Z'),
        decidedAt: null,
        service: {
          id: serviceId,
          name: 'Literacy Class',
          kind: 'EDUCATIONAL',
          startDate: new Date('2026-07-20T00:00:00.000Z'),
          startTime: '10:00',
          locationBranch: 'Main Branch',
        },
      },
    ]);

    expect(prismaMock.serviceRequest.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { patientId },
      })
    );
  });

  it('cancels the caller patient pending request and writes audit', async () => {
    const tx = cancelTxWith();
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(requestService.cancelRequest(requestId, actorUserId)).resolves.toMatchObject({
      id: requestId,
      status: 'CANCELLED',
    });

    expect(tx.serviceRequest.updateMany).toHaveBeenCalledWith({
      where: { id: requestId, patientId, status: 'PENDING' },
      data: { status: 'CANCELLED' },
    });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: actorUserId,
        action: 'SERVICE_REQUEST_CANCELLED',
        entityType: 'SERVICE_REQUEST',
        entityId: requestId,
      })
    );
  });

  it('rejects cancel for decided or another patient request', async () => {
    const decidedTx = cancelTxWith({
      existing: { id: requestId, patientId, status: 'APPROVED' },
    });
    prismaMock.$transaction.mockImplementationOnce(async (callback) => callback(decidedTx));
    await expect(requestService.cancelRequest(requestId, actorUserId)).rejects.toMatchObject({
      statusCode: 409,
      code: ServiceErrors.requestNotPending().code,
    });

    const otherPatientTx = cancelTxWith({
      existing: { id: requestId, patientId: 'other-patient', status: 'PENDING' },
    });
    prismaMock.$transaction.mockImplementationOnce(async (callback) => callback(otherPatientTx));
    await expect(requestService.cancelRequest(requestId, actorUserId)).rejects.toMatchObject({
      statusCode: 403,
      code: 'FORBIDDEN',
    });
  });

  it('returns pending, approved-today, and approved-total summary counts', async () => {
    const now = new Date('2026-06-10T15:30:00.000Z');
    const startOfToday = new Date(now);
    startOfToday.setHours(0, 0, 0, 0);
    prismaMock.serviceRequest.count
      .mockResolvedValueOnce(4)
      .mockResolvedValueOnce(2)
      .mockResolvedValueOnce(12);

    await expect(requestService.getSummary(now)).resolves.toEqual({
      pending: 4,
      approvedToday: 2,
      approvedTotal: 12,
    });

    expect(prismaMock.serviceRequest.count).toHaveBeenNthCalledWith(1, {
      where: { status: 'PENDING' },
    });
    expect(prismaMock.serviceRequest.count).toHaveBeenNthCalledWith(2, {
      where: { status: 'APPROVED', decidedAt: { gte: startOfToday } },
    });
    expect(prismaMock.serviceRequest.count).toHaveBeenNthCalledWith(3, {
      where: { status: 'APPROVED' },
    });
  });
});
