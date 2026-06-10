import type { Server } from 'node:http';
import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';

const requestId = '66666666-6666-4666-8666-666666666666';

const mockListQueue = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ data: [], page: 1, pageSize: 20, total: 0 });
});
const mockApprove = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ id: requestId, status: 'APPROVED' });
});
const mockReject = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ id: requestId, status: 'REJECTED', decisionNote: 'No seats' });
});
const mockListMy = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json([{ id: requestId, status: 'PENDING' }]);
});
const mockCancel = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ id: requestId, status: 'CANCELLED' });
});
const mockSummary = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ pending: 4, approvedToday: 2, approvedTotal: 12 });
});

jest.mock('../../middleware/authenticate', () => ({
  authenticate: (req: Request, _res: Response, next: NextFunction): void => {
    req.user = {
      id: 'actor-id',
      role: String(req.headers['x-test-role']) as Role,
    };
    next();
  },
}));

jest.mock('./request.controller', () => ({
  listQueue: mockListQueue,
  listMy: mockListMy,
  approve: mockApprove,
  cancel: mockCancel,
  reject: mockReject,
  summary: mockSummary,
}));

import { requestRouter } from './request.routes';

describe('service request decision routes', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use(express.json());
    app.use('/service-requests', requestRouter);
    app.use(
      (
        err: { statusCode?: number; code?: string },
        _req: Request,
        res: Response,
        _next: NextFunction
      ): void => {
        res.status(err.statusCode ?? 500).json({ error: { code: err.code ?? 'INTERNAL' } });
      }
    );
    server = app.listen(0);
    const address = server.address();
    if (!address || typeof address === 'string') throw new Error('Failed to start test server');
    baseUrl = `http://127.0.0.1:${address.port}`;
  });

  afterAll((done) => {
    server.close(done);
  });

  beforeEach(() => jest.clearAllMocks());

  it('allows admins and doctors to list, approve, and reject service requests', async () => {
    for (const role of ['ADMIN', 'DOCTOR']) {
      const queueResponse = await fetch(`${baseUrl}/service-requests?status=PENDING`, {
        headers: { 'x-test-role': role },
      });
      const approveResponse = await fetch(`${baseUrl}/service-requests/${requestId}/approve`, {
        method: 'PATCH',
        headers: { 'x-test-role': role },
      });
      const rejectResponse = await fetch(`${baseUrl}/service-requests/${requestId}/reject`, {
        method: 'PATCH',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({ decisionNote: 'No seats' }),
      });

      expect(queueResponse.status).toBe(200);
      expect(approveResponse.status).toBe(200);
      expect(rejectResponse.status).toBe(200);
    }

    expect(mockListQueue).toHaveBeenCalledTimes(2);
    expect(mockApprove).toHaveBeenCalledTimes(2);
    expect(mockReject).toHaveBeenCalledTimes(2);
  });

  it('rejects non-staff roles before reaching request decision controllers', async () => {
    for (const role of ['PATIENT', 'VOLUNTEER', 'CALL_CENTER']) {
      const queueResponse = await fetch(`${baseUrl}/service-requests`, {
        headers: { 'x-test-role': role },
      });
      const approveResponse = await fetch(`${baseUrl}/service-requests/${requestId}/approve`, {
        method: 'PATCH',
        headers: { 'x-test-role': role },
      });
      const rejectResponse = await fetch(`${baseUrl}/service-requests/${requestId}/reject`, {
        method: 'PATCH',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({ decisionNote: 'No seats' }),
      });

      expect(queueResponse.status).toBe(403);
      expect(approveResponse.status).toBe(403);
      expect(rejectResponse.status).toBe(403);
    }

    expect(mockListQueue).not.toHaveBeenCalled();
    expect(mockApprove).not.toHaveBeenCalled();
    expect(mockReject).not.toHaveBeenCalled();
  });

  it('allows only patients to list and cancel their own requests', async () => {
    const listResponse = await fetch(`${baseUrl}/service-requests/my`, {
      headers: { 'x-test-role': 'PATIENT' },
    });
    const cancelResponse = await fetch(`${baseUrl}/service-requests/${requestId}/cancel`, {
      method: 'PATCH',
      headers: { 'x-test-role': 'PATIENT' },
    });

    expect(listResponse.status).toBe(200);
    expect(cancelResponse.status).toBe(200);

    for (const role of ['ADMIN', 'DOCTOR', 'VOLUNTEER', 'CALL_CENTER']) {
      const nonPatientList = await fetch(`${baseUrl}/service-requests/my`, {
        headers: { 'x-test-role': role },
      });
      const nonPatientCancel = await fetch(`${baseUrl}/service-requests/${requestId}/cancel`, {
        method: 'PATCH',
        headers: { 'x-test-role': role },
      });

      expect(nonPatientList.status).toBe(403);
      expect(nonPatientCancel.status).toBe(403);
    }

    expect(mockListMy).toHaveBeenCalledTimes(1);
    expect(mockCancel).toHaveBeenCalledTimes(1);
  });

  it('allows only admins and doctors to fetch service request summary counts', async () => {
    for (const role of ['ADMIN', 'DOCTOR']) {
      const response = await fetch(`${baseUrl}/service-requests/summary`, {
        headers: { 'x-test-role': role },
      });

      expect(response.status).toBe(200);
      await expect(response.json()).resolves.toEqual({
        pending: 4,
        approvedToday: 2,
        approvedTotal: 12,
      });
    }

    for (const role of ['PATIENT', 'VOLUNTEER', 'CALL_CENTER']) {
      const response = await fetch(`${baseUrl}/service-requests/summary`, {
        headers: { 'x-test-role': role },
      });

      expect(response.status).toBe(403);
    }

    expect(mockSummary).toHaveBeenCalledTimes(2);
  });
});
