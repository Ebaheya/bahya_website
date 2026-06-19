import type { Server } from 'node:http';
import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';

const mockListByPatient = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json([]);
});
const mockGetById = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({});
});
const unusedHandler = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({});
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

jest.mock('../../middleware/userRateLimit', () => ({
  userRateLimiter: () => (_req: Request, _res: Response, next: NextFunction): void => next(),
}));

jest.mock('./assessment.controller', () => ({
  listPending: unusedHandler,
  getSubmission: unusedHandler,
  create: unusedHandler,
  listByPatient: mockListByPatient,
  getById: mockGetById,
}));

import { assessmentRouter } from './assessment.routes';

describe('official assessment read routes', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use('/assessments', assessmentRouter);
    app.use(
      (
        err: { statusCode?: number },
        _req: Request,
        res: Response,
        _next: NextFunction
      ): void => {
        res.status(err.statusCode ?? 500).json({});
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

  it('allows doctors and admins to read official assessments', async () => {
    for (const role of ['DOCTOR', 'ADMIN']) {
      expect(
        (
          await fetch(`${baseUrl}/assessments/patient/patient-id`, {
            headers: { 'x-test-role': role },
          })
        ).status
      ).toBe(200);
      expect(
        (
          await fetch(`${baseUrl}/assessments/assessment-id`, {
            headers: { 'x-test-role': role },
          })
        ).status
      ).toBe(200);
    }

    expect(mockListByPatient).toHaveBeenCalledTimes(2);
    expect(mockGetById).toHaveBeenCalledTimes(2);
  });

  it('rejects patients before official assessment data reaches a controller', async () => {
    const listResponse = await fetch(`${baseUrl}/assessments/patient/patient-id`, {
      headers: { 'x-test-role': 'PATIENT' },
    });
    const detailResponse = await fetch(`${baseUrl}/assessments/assessment-id`, {
      headers: { 'x-test-role': 'PATIENT' },
    });

    expect(listResponse.status).toBe(403);
    expect(detailResponse.status).toBe(403);
    expect(mockListByPatient).not.toHaveBeenCalled();
    expect(mockGetById).not.toHaveBeenCalled();
  });
});
