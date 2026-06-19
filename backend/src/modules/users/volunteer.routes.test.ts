import type { Server } from 'node:http';
import type { Request, Response, NextFunction } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';

const mockListVolunteerOptions = jest.fn((_req: Request, res: Response): void => {
  res.status(200).json({ data: [] });
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

jest.mock('./user.controller', () => ({
  listVolunteerOptions: mockListVolunteerOptions,
}));

import { volunteerRouter } from './volunteer.routes';

describe('volunteer options routes', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use('/volunteers', volunteerRouter);
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

  it('allows doctors and admins to load assignment options', async () => {
    for (const role of ['DOCTOR', 'ADMIN']) {
      const response = await fetch(`${baseUrl}/volunteers`, {
        headers: { 'x-test-role': role },
      });
      expect(response.status).toBe(200);
    }

    expect(mockListVolunteerOptions).toHaveBeenCalledTimes(2);
  });

  it('rejects a patient before reaching the lookup controller', async () => {
    const response = await fetch(`${baseUrl}/volunteers`, {
      headers: { 'x-test-role': 'PATIENT' },
    });

    expect(response.status).toBe(403);
    expect(mockListVolunteerOptions).not.toHaveBeenCalled();
  });
});
