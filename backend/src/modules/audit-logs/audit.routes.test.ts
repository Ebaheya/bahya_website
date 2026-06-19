import type { Server } from 'node:http';
import type { NextFunction, Request } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';
import { errorHandler } from '../../middleware/errorHandler';

const auditId = '64b2f0000000000000000001';
const actorId = '11111111-1111-4111-8111-111111111111';

const mockFindChain = {
  sort: jest.fn().mockReturnThis(),
  skip: jest.fn().mockReturnThis(),
  limit: jest.fn().mockReturnThis(),
  lean: jest.fn(),
};
const mockFindByIdChain = {
  lean: jest.fn(),
};
const mockAuditLogModel = {
  find: jest.fn(),
  countDocuments: jest.fn(),
  findById: jest.fn(),
  create: jest.fn(),
  updateOne: jest.fn(),
  deleteOne: jest.fn(),
  findOneAndUpdate: jest.fn(),
};

jest.mock('../../middleware/authenticate', () => ({
  authenticate: (req: Request, _res: unknown, next: NextFunction): void => {
    req.user = {
      id: 'actor-id',
      role: String(req.headers['x-test-role'] ?? 'PATIENT') as Role,
    };
    next();
  },
}));

jest.mock('./audit.model', () => ({
  AuditLogModel: mockAuditLogModel,
}));

import { auditRouter } from './audit.routes';

function auditDoc(overrides: Record<string, unknown> = {}) {
  return {
    _id: { toString: () => auditId },
    actorId,
    action: 'REPORT_STATUS_CHANGED',
    entityType: 'REPORT',
    entityId: '22222222-2222-4222-8222-222222222222',
    oldValues: { status: 'PENDING' },
    newValues: { status: 'RESOLVED' },
    ipAddress: '127.0.0.1',
    userAgent: 'jest',
    createdAt: new Date('2026-06-18T09:00:00.000Z'),
    ...overrides,
  };
}

describe('audit read routes', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use(express.json());
    app.use('/audit-logs', auditRouter);
    app.use(errorHandler);
    server = app.listen(0);
    const address = server.address();
    if (!address || typeof address === 'string') throw new Error('Failed to start test server');
    baseUrl = `http://127.0.0.1:${address.port}`;
  });

  afterAll((done) => {
    server.close(done);
  });

  beforeEach(() => {
    jest.clearAllMocks();
    mockAuditLogModel.find.mockReturnValue(mockFindChain);
    mockAuditLogModel.findById.mockReturnValue(mockFindByIdChain);
    mockAuditLogModel.countDocuments.mockResolvedValue(1);
    mockFindChain.sort.mockReturnThis();
    mockFindChain.skip.mockReturnThis();
    mockFindChain.limit.mockReturnThis();
    mockFindChain.lean.mockResolvedValue([auditDoc()]);
    mockFindByIdChain.lean.mockResolvedValue(auditDoc());
  });

  it('filters by action, actor, and date range with newest-first pagination', async () => {
    const from = '2026-06-01T00:00:00.000Z';
    const to = '2026-06-30T23:59:59.999Z';
    const response = await fetch(
      `${baseUrl}/audit-logs?action=REPORT_STATUS_CHANGED&actorId=${actorId}&from=${from}&to=${to}&page=2&pageSize=5`,
      { headers: { 'x-test-role': 'ADMIN' } }
    );

    await expect(response.json()).resolves.toMatchObject({
      data: [
        {
          id: auditId,
          actorId,
          action: 'REPORT_STATUS_CHANGED',
          entityType: 'REPORT',
          entityId: '22222222-2222-4222-8222-222222222222',
          ipAddress: '127.0.0.1',
          createdAt: '2026-06-18T09:00:00.000Z',
        },
      ],
      page: 2,
      pageSize: 5,
      total: 1,
    });
    expect(response.status).toBe(200);

    const expectedFilter = {
      action: 'REPORT_STATUS_CHANGED',
      actorId,
      createdAt: { $gte: new Date(from), $lte: new Date(to) },
    };
    expect(mockAuditLogModel.find).toHaveBeenCalledWith(expectedFilter);
    expect(mockAuditLogModel.countDocuments).toHaveBeenCalledWith(expectedFilter);
    expect(mockFindChain.sort).toHaveBeenCalledWith({ createdAt: -1 });
    expect(mockFindChain.skip).toHaveBeenCalledWith(5);
    expect(mockFindChain.limit).toHaveBeenCalledWith(5);
  });

  it('returns audit entry detail and does not write on read paths', async () => {
    const listResponse = await fetch(`${baseUrl}/audit-logs`, {
      headers: { 'x-test-role': 'ADMIN' },
    });
    const detailResponse = await fetch(`${baseUrl}/audit-logs/${auditId}`, {
      headers: { 'x-test-role': 'ADMIN' },
    });

    expect(listResponse.status).toBe(200);
    expect(detailResponse.status).toBe(200);
    await expect(detailResponse.json()).resolves.toMatchObject({
      id: auditId,
      oldValues: { status: 'PENDING' },
      newValues: { status: 'RESOLVED' },
      userAgent: 'jest',
    });

    expect(mockAuditLogModel.create).not.toHaveBeenCalled();
    expect(mockAuditLogModel.updateOne).not.toHaveBeenCalled();
    expect(mockAuditLogModel.deleteOne).not.toHaveBeenCalled();
    expect(mockAuditLogModel.findOneAndUpdate).not.toHaveBeenCalled();
  });

  it('rejects non-admins before reading audit logs', async () => {
    for (const role of ['DOCTOR', 'VOLUNTEER', 'CALL_CENTER', 'PATIENT']) {
      const listResponse = await fetch(`${baseUrl}/audit-logs`, {
        headers: { 'x-test-role': role },
      });
      const detailResponse = await fetch(`${baseUrl}/audit-logs/${auditId}`, {
        headers: { 'x-test-role': role },
      });

      expect(listResponse.status).toBe(403);
      expect(detailResponse.status).toBe(403);
    }

    expect(mockAuditLogModel.find).not.toHaveBeenCalled();
    expect(mockAuditLogModel.findById).not.toHaveBeenCalled();
  });

  it('maps missing entries to 404', async () => {
    mockFindByIdChain.lean.mockResolvedValueOnce(null);

    const response = await fetch(`${baseUrl}/audit-logs/${auditId}`, {
      headers: { 'x-test-role': 'ADMIN' },
    });

    expect(response.status).toBe(404);
  });

  it('rejects invalid filters before reading audit logs', async () => {
    const response = await fetch(`${baseUrl}/audit-logs?from=not-a-date`, {
      headers: { 'x-test-role': 'ADMIN' },
    });

    expect(response.status).toBe(400);
    expect(mockAuditLogModel.find).not.toHaveBeenCalled();
  });
});
