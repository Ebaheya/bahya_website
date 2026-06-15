import type { Server } from 'node:http';
import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';
import { errorHandler } from '../../middleware/errorHandler';

const notificationId = '64b2f0000000000000000001';

const mockListMyNotifications = jest.fn();
const mockClaimNotification = jest.fn();
const mockMarkRead = jest.fn();
const mockMarkDone = jest.fn();

jest.mock('../../middleware/authenticate', () => ({
  authenticate: (req: Request, _res: Response, next: NextFunction): void => {
    req.user = {
      id: 'actor-id',
      role: String(req.headers['x-test-role'] ?? 'PATIENT') as Role,
    };
    next();
  },
}));

jest.mock('./notification.service', () => ({
  listMyNotifications: mockListMyNotifications,
  claimNotification: mockClaimNotification,
  markRead: mockMarkRead,
  markDone: mockMarkDone,
}));

import { notificationRouter } from './notification.routes';

describe('notification lifecycle routes', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use(express.json());
    app.use('/notifications', notificationRouter);
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
    mockMarkRead.mockResolvedValue({ id: notificationId, status: 'READ' });
    mockMarkDone.mockResolvedValue({ id: notificationId, status: 'DONE' });
  });

  it('routes read and done lifecycle patches to the authenticated actor', async () => {
    const readResponse = await fetch(`${baseUrl}/notifications/${notificationId}/read`, {
      method: 'PATCH',
      headers: { 'x-test-role': 'PATIENT' },
    });
    const doneResponse = await fetch(`${baseUrl}/notifications/${notificationId}/done`, {
      method: 'PATCH',
      headers: { 'x-test-role': 'PATIENT' },
    });

    await expect(readResponse.json()).resolves.toEqual({ id: notificationId, status: 'READ' });
    await expect(doneResponse.json()).resolves.toEqual({ id: notificationId, status: 'DONE' });
    expect(readResponse.status).toBe(200);
    expect(doneResponse.status).toBe(200);
    expect(mockMarkRead).toHaveBeenCalledWith({ id: 'actor-id', role: 'PATIENT' }, notificationId);
    expect(mockMarkDone).toHaveBeenCalledWith({ id: 'actor-id', role: 'PATIENT' }, notificationId);
  });

  it('rejects malformed notification ids before calling lifecycle services', async () => {
    const response = await fetch(`${baseUrl}/notifications/not-an-object-id/read`, {
      method: 'PATCH',
      headers: { 'x-test-role': 'PATIENT' },
    });

    expect(response.status).toBe(400);
    expect(mockMarkRead).not.toHaveBeenCalled();
  });
});
