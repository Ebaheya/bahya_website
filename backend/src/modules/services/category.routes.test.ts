import type { Server } from 'node:http';
import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';

const categoryId = '11111111-1111-4111-8111-111111111111';

const mockList = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ data: [{ id: categoryId, isDefault: true }], page: 1, pageSize: 20, total: 1 });
});
const mockCreate = jest.fn((_req: Request, res: Response): void => {
  res.status(201).json({ id: categoryId, name: 'Education' });
});
const mockUpdate = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ id: categoryId, name: 'Education Plus' });
});
const mockSetStatus = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ id: categoryId, isActive: false });
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

jest.mock('./category.controller', () => ({
  list: mockList,
  create: mockCreate,
  update: mockUpdate,
  setStatus: mockSetStatus,
}));

import { categoryRouter } from './category.routes';

describe('service category routes', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use(express.json());
    app.use('/service-categories', categoryRouter);
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

  it('lets any authenticated role list categories', async () => {
    for (const role of ['ADMIN', 'DOCTOR', 'PATIENT', 'VOLUNTEER', 'CALL_CENTER']) {
      const response = await fetch(`${baseUrl}/service-categories`, {
        headers: { 'x-test-role': role },
      });
      const body = (await response.json()) as { data: Array<{ isDefault: boolean }> };

      expect(response.status).toBe(200);
      expect(body.data[0]).toMatchObject({ isDefault: true });
    }

    expect(mockList).toHaveBeenCalledTimes(5);
  });

  it('allows admins and doctors to create, update, and deactivate categories', async () => {
    for (const role of ['ADMIN', 'DOCTOR']) {
      const createResponse = await fetch(`${baseUrl}/service-categories`, {
        method: 'POST',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({}),
      });
      const patchResponse = await fetch(`${baseUrl}/service-categories/${categoryId}`, {
        method: 'PATCH',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({ name: 'Education Plus' }),
      });
      const statusResponse = await fetch(`${baseUrl}/service-categories/${categoryId}/status`, {
        method: 'PATCH',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({ isActive: false }),
      });

      expect(createResponse.status).toBe(201);
      expect(patchResponse.status).toBe(200);
      expect(statusResponse.status).toBe(200);
    }

    expect(mockCreate).toHaveBeenCalledTimes(2);
    expect(mockUpdate).toHaveBeenCalledTimes(2);
    expect(mockSetStatus).toHaveBeenCalledTimes(2);
  });

  it('rejects non-staff category mutations before reaching controllers', async () => {
    for (const role of ['PATIENT', 'VOLUNTEER', 'CALL_CENTER']) {
      const createResponse = await fetch(`${baseUrl}/service-categories`, {
        method: 'POST',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({}),
      });
      const patchResponse = await fetch(`${baseUrl}/service-categories/${categoryId}`, {
        method: 'PATCH',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({ name: 'Education Plus' }),
      });
      const statusResponse = await fetch(`${baseUrl}/service-categories/${categoryId}/status`, {
        method: 'PATCH',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({ isActive: false }),
      });

      expect(createResponse.status).toBe(403);
      expect(patchResponse.status).toBe(403);
      expect(statusResponse.status).toBe(403);
    }

    expect(mockCreate).not.toHaveBeenCalled();
    expect(mockUpdate).not.toHaveBeenCalled();
    expect(mockSetStatus).not.toHaveBeenCalled();
  });
});
