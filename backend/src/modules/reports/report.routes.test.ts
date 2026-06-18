import type { Server } from 'node:http';
import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';
import { errorHandler } from '../../middleware/errorHandler';
import { AppError } from '../../utils/httpError';

const reportId = '11111111-1111-4111-8111-111111111111';
const mockCreateReport = jest.fn();
const mockListReports = jest.fn();
const mockGetReportById = jest.fn();
const mockGetSummary = jest.fn();
const mockChangeStatus = jest.fn();

const limiterHits = new Map<string, number>();

jest.mock('../../middleware/authenticate', () => ({
  authenticate: (req: Request, _res: Response, next: NextFunction): void => {
    req.user = {
      id: String(req.headers['x-test-user-id'] ?? 'actor-id'),
      role: String(req.headers['x-test-role'] ?? 'PATIENT') as Role,
    };
    next();
  },
}));

jest.mock('../../middleware/userRateLimit', () => ({
  userRateLimiter:
    (_limit: number) =>
    (req: Request, res: Response, next: NextFunction): void => {
      const key = req.user?.id ?? 'anonymous';
      const hits = (limiterHits.get(key) ?? 0) + 1;
      limiterHits.set(key, hits);
      if (hits > 1) {
        res.status(429).json({ error: { code: 'TOO_MANY_REQUESTS' } });
        return;
      }
      next();
    },
}));

jest.mock('./report.service', () => ({
  createReport: mockCreateReport,
  listReports: mockListReports,
  getReportById: mockGetReportById,
  getSummary: mockGetSummary,
  changeStatus: mockChangeStatus,
}));

import { reportRouter } from './report.routes';

describe('report routes', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use(express.json());
    app.use('/reports', reportRouter);
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
    limiterHits.clear();
    mockCreateReport.mockResolvedValue({
      id: reportId,
      title: 'Content Report',
      status: 'PENDING',
      createdAt: new Date('2026-06-18T10:00:00.000Z'),
    });
    mockListReports.mockResolvedValue({ data: [], page: 1, pageSize: 20, total: 0 });
    mockGetReportById.mockResolvedValue({ id: reportId, title: 'Content Report' });
    mockGetSummary.mockResolvedValue({ pending: 1, investigating: 0, resolved: 0 });
    mockChangeStatus.mockResolvedValue({ id: reportId, status: 'RESOLVED' });
  });

  it('allows every authenticated role to file a report', async () => {
    for (const role of ['ADMIN', 'DOCTOR', 'VOLUNTEER', 'CALL_CENTER', 'PATIENT']) {
      const response = await fetch(`${baseUrl}/reports`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'x-test-role': role,
          'x-test-user-id': `user-${role}`,
        },
        body: JSON.stringify({ title: 'Content Report', body: 'Problem details' }),
      });

      expect(response.status).toBe(201);
    }

    expect(mockCreateReport).toHaveBeenCalledTimes(5);
  });

  it('rejects empty title or body before creating a report', async () => {
    const response = await fetch(`${baseUrl}/reports`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-test-role': 'PATIENT' },
      body: JSON.stringify({ title: '', body: '' }),
    });

    expect(response.status).toBe(400);
    expect(mockCreateReport).not.toHaveBeenCalled();
  });

  it('rate-limits repeated report filing by the same user', async () => {
    for (const expectedStatus of [201, 429]) {
      const response = await fetch(`${baseUrl}/reports`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'x-test-role': 'PATIENT',
          'x-test-user-id': 'same-user',
        },
        body: JSON.stringify({ title: 'Content Report', body: 'Problem details' }),
      });

      expect(response.status).toBe(expectedStatus);
    }

    expect(mockCreateReport).toHaveBeenCalledTimes(1);
  });

  it('allows only admins to list, summarize, view, and change reports', async () => {
    const adminResponses = await Promise.all([
      fetch(`${baseUrl}/reports?status=PENDING&q=sarah`, { headers: { 'x-test-role': 'ADMIN' } }),
      fetch(`${baseUrl}/reports/summary`, { headers: { 'x-test-role': 'ADMIN' } }),
      fetch(`${baseUrl}/reports/${reportId}`, { headers: { 'x-test-role': 'ADMIN' } }),
      fetch(`${baseUrl}/reports/${reportId}/status`, {
        method: 'PATCH',
        headers: { 'content-type': 'application/json', 'x-test-role': 'ADMIN' },
        body: JSON.stringify({ status: 'RESOLVED' }),
      }),
    ]);

    for (const response of adminResponses) {
      expect(response.status).toBe(200);
    }

    for (const role of ['DOCTOR', 'VOLUNTEER', 'CALL_CENTER', 'PATIENT']) {
      const responses = await Promise.all([
        fetch(`${baseUrl}/reports`, { headers: { 'x-test-role': role } }),
        fetch(`${baseUrl}/reports/summary`, { headers: { 'x-test-role': role } }),
        fetch(`${baseUrl}/reports/${reportId}`, { headers: { 'x-test-role': role } }),
        fetch(`${baseUrl}/reports/${reportId}/status`, {
          method: 'PATCH',
          headers: { 'content-type': 'application/json', 'x-test-role': role },
          body: JSON.stringify({ status: 'RESOLVED' }),
        }),
      ]);

      for (const response of responses) {
        expect(response.status).toBe(403);
      }
    }

    expect(mockListReports).toHaveBeenCalledTimes(1);
    expect(mockGetSummary).toHaveBeenCalledTimes(1);
    expect(mockGetReportById).toHaveBeenCalledTimes(1);
    expect(mockChangeStatus).toHaveBeenCalledTimes(1);
  });

  it('maps missing reports to 404', async () => {
    mockGetReportById.mockRejectedValueOnce(AppError.notFound('Report not found'));

    const response = await fetch(`${baseUrl}/reports/${reportId}`, {
      headers: { 'x-test-role': 'ADMIN' },
    });

    expect(response.status).toBe(404);
  });
});
