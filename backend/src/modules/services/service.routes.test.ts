import type { Server } from 'node:http';
import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';

const serviceId = '22222222-2222-4222-8222-222222222222';

const mockCreate = jest.fn((_req: Request, res: Response): void => {
  res.status(201).json({ id: serviceId, status: 'ACTIVE', seatsTaken: 0, remainingSeats: 20 });
});
const mockUpdate = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ id: serviceId, status: 'CLOSED', seatsTaken: 2, remainingSeats: 18 });
});
const mockGetById = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ id: serviceId, status: 'ACTIVE', seatsTaken: 7, remainingSeats: 13 });
});
const mockList = jest.fn((req: Request, res: Response): void => {
  const status = req.headers['x-test-role'] === 'PATIENT' ? 'ACTIVE' : 'CLOSED';
  res.status(200).json({
    data: [{ id: serviceId, status, remainingSeats: 13 }],
    page: 1,
    pageSize: 20,
    total: 1,
  });
});
const mockCreateRequest = jest.fn((_req: Request, res: Response): void => {
  res.status(201).json({ id: 'request-1', status: 'PENDING', serviceId });
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

jest.mock('./service.controller', () => ({
  create: mockCreate,
  update: mockUpdate,
  getById: mockGetById,
  list: mockList,
  createRequest: mockCreateRequest,
}));

import { serviceRouter } from './service.routes';

describe('service routes', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use(express.json());
    app.use('/services', serviceRouter);
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

  it('allows admins and doctors to create and update services', async () => {
    for (const role of ['ADMIN', 'DOCTOR']) {
      const createResponse = await fetch(`${baseUrl}/services`, {
        method: 'POST',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({}),
      });
      const createBody = await createResponse.json();
      expect(createResponse.status).toBe(201);
      expect(createBody).toMatchObject({ status: 'ACTIVE', seatsTaken: 0 });

      const patchResponse = await fetch(`${baseUrl}/services/${serviceId}`, {
        method: 'PATCH',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({ status: 'CLOSED' }),
      });
      expect(patchResponse.status).toBe(200);
    }

    expect(mockCreate).toHaveBeenCalledTimes(2);
    expect(mockUpdate).toHaveBeenCalledTimes(2);
  });

  it('rejects non-staff create and update before reaching the controller', async () => {
    for (const role of ['PATIENT', 'VOLUNTEER', 'CALL_CENTER']) {
      const createResponse = await fetch(`${baseUrl}/services`, {
        method: 'POST',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({}),
      });
      const patchResponse = await fetch(`${baseUrl}/services/${serviceId}`, {
        method: 'PATCH',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({ status: 'CLOSED' }),
      });

      expect(createResponse.status).toBe(403);
      expect(patchResponse.status).toBe(403);
    }

    expect(mockCreate).not.toHaveBeenCalled();
    expect(mockUpdate).not.toHaveBeenCalled();
  });

  it('lets any authenticated role fetch a service with remaining seats', async () => {
    for (const role of ['ADMIN', 'DOCTOR', 'PATIENT', 'VOLUNTEER', 'CALL_CENTER']) {
      const response = await fetch(`${baseUrl}/services/${serviceId}`, {
        headers: { 'x-test-role': role },
      });
      const body = (await response.json()) as { data: Array<{ status: string; remainingSeats: number }> };

      expect(response.status).toBe(200);
      expect(body).toMatchObject({ id: serviceId, remainingSeats: 13 });
    }

    expect(mockGetById).toHaveBeenCalledTimes(5);
  });

  it('lets all authenticated roles browse services', async () => {
    for (const role of ['ADMIN', 'DOCTOR', 'PATIENT', 'VOLUNTEER', 'CALL_CENTER']) {
      const response = await fetch(`${baseUrl}/services?kind=EDUCATIONAL&q=literacy`, {
        headers: { 'x-test-role': role },
      });
      const body = (await response.json()) as {
        data: Array<{ status: string; remainingSeats: number }>;
      };

      expect(response.status).toBe(200);
      expect(body).toMatchObject({
        data: [expect.objectContaining({ remainingSeats: 13 })],
      });
      if (role === 'PATIENT') {
        expect(body.data[0]).toMatchObject({ status: 'ACTIVE' });
      }
    }

    expect(mockList).toHaveBeenCalledTimes(5);
  });

  it('allows only patients to request joining a service', async () => {
    const patientResponse = await fetch(`${baseUrl}/services/${serviceId}/requests`, {
      method: 'POST',
      headers: { 'x-test-role': 'PATIENT' },
    });
    const patientBody = await patientResponse.json();

    expect(patientResponse.status).toBe(201);
    expect(patientBody).toMatchObject({ status: 'PENDING', serviceId });

    for (const role of ['ADMIN', 'DOCTOR', 'VOLUNTEER', 'CALL_CENTER']) {
      const response = await fetch(`${baseUrl}/services/${serviceId}/requests`, {
        method: 'POST',
        headers: { 'x-test-role': role },
      });
      expect(response.status).toBe(403);
    }

    expect(mockCreateRequest).toHaveBeenCalledTimes(1);
  });
});
