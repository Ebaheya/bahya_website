import type { Server } from 'node:http';
import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';

const mockListOptions = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ data: [] });
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

jest.mock('./patient.controller', () => ({
  create: unusedHandler,
  list: unusedHandler,
  listOptions: mockListOptions,
  timeline: unusedHandler,
  getById: unusedHandler,
  patch: unusedHandler,
}));

import { patientRouter } from './patient.routes';

describe('patient options routes', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use('/patients', patientRouter);
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

  it('allows doctors and admins to load patient assignment options', async () => {
    for (const role of ['DOCTOR', 'ADMIN']) {
      const response = await fetch(`${baseUrl}/patients/options`, {
        headers: { 'x-test-role': role },
      });
      expect(response.status).toBe(200);
    }

    expect(mockListOptions).toHaveBeenCalledTimes(2);
  });

  it('rejects a volunteer before reaching the options controller', async () => {
    const response = await fetch(`${baseUrl}/patients/options`, {
      headers: { 'x-test-role': 'VOLUNTEER' },
    });

    expect(response.status).toBe(403);
    expect(mockListOptions).not.toHaveBeenCalled();
  });
});
