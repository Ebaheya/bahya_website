import type { Server } from 'node:http';
import type { NextFunction, Request } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';
import { errorHandler } from '../../middleware/errorHandler';

const mockGetSummary = jest.fn();
const mockGetActivity = jest.fn();

jest.mock('../../middleware/authenticate', () => ({
  authenticate: (req: Request, _res: unknown, next: NextFunction): void => {
    req.user = {
      id: 'actor-id',
      role: String(req.headers['x-test-role'] ?? 'PATIENT') as Role,
    };
    next();
  },
}));

jest.mock('./dashboard.service', () => ({
  getSummary: mockGetSummary,
  getActivity: mockGetActivity,
}));

import { dashboardRouter } from './dashboard.routes';

describe('dashboard routes', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use(express.json());
    app.use('/dashboard', dashboardRouter);
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
    mockGetSummary.mockResolvedValue({
      users: { total: 0, active: 0, byRole: {} },
      reports: { open: 0 },
      assessments: { byStatus: {} },
      notifications: { open: 0 },
    });
    mockGetActivity.mockResolvedValue({ data: [] });
  });

  it('allows only admins to access dashboard summary and activity', async () => {
    const adminSummary = await fetch(`${baseUrl}/dashboard/summary`, {
      headers: { 'x-test-role': 'ADMIN' },
    });
    const adminActivity = await fetch(`${baseUrl}/dashboard/activity?limit=7`, {
      headers: { 'x-test-role': 'ADMIN' },
    });

    expect(adminSummary.status).toBe(200);
    expect(adminActivity.status).toBe(200);
    expect(mockGetSummary).toHaveBeenCalledTimes(1);
    expect(mockGetActivity).toHaveBeenCalledWith(7);

    for (const role of ['DOCTOR', 'VOLUNTEER', 'CALL_CENTER', 'PATIENT']) {
      const summary = await fetch(`${baseUrl}/dashboard/summary`, {
        headers: { 'x-test-role': role },
      });
      const activity = await fetch(`${baseUrl}/dashboard/activity`, {
        headers: { 'x-test-role': role },
      });

      expect(summary.status).toBe(403);
      expect(activity.status).toBe(403);
    }

    expect(mockGetSummary).toHaveBeenCalledTimes(1);
    expect(mockGetActivity).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid activity limits before calling the service', async () => {
    const response = await fetch(`${baseUrl}/dashboard/activity?limit=500`, {
      headers: { 'x-test-role': 'ADMIN' },
    });

    expect(response.status).toBe(400);
    expect(mockGetActivity).not.toHaveBeenCalled();
  });
});
