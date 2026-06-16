import type { Server } from 'node:http';
import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';
import { errorHandler } from '../../middleware/errorHandler';
import { AppError } from '../../utils/httpError';
import { NotificationErrors } from './notification.errors';

const notificationId = '64b2f0000000000000000001';

const mockListMyNotifications = jest.fn();
const mockClaimNotification = jest.fn();
const mockMarkRead = jest.fn();
const mockMarkDone = jest.fn();
const mockRequestBooking = jest.fn();
const mockRegisterDevice = jest.fn();
const mockUnregisterDevice = jest.fn();

jest.mock('../../middleware/authenticate', () => ({
  authenticate: (req: Request, _res: Response, next: NextFunction): void => {
    if (req.headers['x-test-unauthenticated'] === 'true') {
      const { AppError } = jest.requireActual('../../utils/httpError');
      return next(AppError.unauthorized('Missing or invalid Authorization header'));
    }
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
  requestBooking: mockRequestBooking,
}));

jest.mock('./device.service', () => ({
  registerDevice: mockRegisterDevice,
  unregisterDevice: mockUnregisterDevice,
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
    mockRequestBooking.mockResolvedValue({
      id: notificationId,
      type: 'BOOKING_REQUIRED',
      status: 'UNREAD',
      createdAt: new Date('2026-06-16T10:00:00.000Z'),
    });
    mockRegisterDevice.mockResolvedValue({ registered: true });
    mockUnregisterDevice.mockResolvedValue({ unregistered: true });
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

  it('routes device registration and unregistering to the authenticated actor', async () => {
    const registerResponse = await fetch(`${baseUrl}/notifications/devices`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-test-role': 'PATIENT' },
      body: JSON.stringify({ token: 'fcm-token-1', platform: 'ANDROID' }),
    });
    const unregisterResponse = await fetch(`${baseUrl}/notifications/devices`, {
      method: 'DELETE',
      headers: { 'content-type': 'application/json', 'x-test-role': 'PATIENT' },
      body: JSON.stringify({ token: 'fcm-token-1' }),
    });

    await expect(registerResponse.json()).resolves.toEqual({ registered: true });
    await expect(unregisterResponse.json()).resolves.toEqual({ unregistered: true });
    expect(registerResponse.status).toBe(200);
    expect(unregisterResponse.status).toBe(200);
    expect(mockRegisterDevice).toHaveBeenCalledWith('actor-id', {
      token: 'fcm-token-1',
      platform: 'ANDROID',
    });
    expect(mockUnregisterDevice).toHaveBeenCalledWith('actor-id', 'fcm-token-1');
  });

  it('rejects invalid device payloads before calling device services', async () => {
    const response = await fetch(`${baseUrl}/notifications/devices`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-test-role': 'PATIENT' },
      body: JSON.stringify({ token: '', platform: 'DESKTOP' }),
    });

    expect(response.status).toBe(400);
    expect(mockRegisterDevice).not.toHaveBeenCalled();
  });

  it('allows doctors to request a Call Center booking notification', async () => {
    const response = await fetch(`${baseUrl}/notifications/request-booking`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-test-role': 'DOCTOR' },
      body: JSON.stringify({
        patientId: '11111111-1111-4111-8111-111111111111',
        doctorNote: 'Needs urgent follow-up.',
      }),
    });

    await expect(response.json()).resolves.toMatchObject({
      id: notificationId,
      type: 'BOOKING_REQUIRED',
      status: 'UNREAD',
    });
    expect(response.status).toBe(201);
    expect(mockRequestBooking).toHaveBeenCalledWith(
      { id: 'actor-id', role: 'DOCTOR' },
      {
        patientId: '11111111-1111-4111-8111-111111111111',
        doctorNote: 'Needs urgent follow-up.',
      }
    );
  });

  it('rejects non-doctors before creating a booking notification', async () => {
    const response = await fetch(`${baseUrl}/notifications/request-booking`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-test-role': 'CALL_CENTER' },
      body: JSON.stringify({ patientId: '11111111-1111-4111-8111-111111111111' }),
    });

    expect(response.status).toBe(403);
    expect(mockRequestBooking).not.toHaveBeenCalled();
  });

  it('returns service errors such as unknown patient from request-booking', async () => {
    mockRequestBooking.mockRejectedValueOnce(AppError.notFound('Patient not found'));

    const response = await fetch(`${baseUrl}/notifications/request-booking`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-test-role': 'DOCTOR' },
      body: JSON.stringify({ patientId: '11111111-1111-4111-8111-111111111111' }),
    });

    expect(response.status).toBe(404);
    expect(mockRequestBooking).toHaveBeenCalledTimes(1);
  });

  it('returns 401 when authentication rejects a notification request', async () => {
    const response = await fetch(`${baseUrl}/notifications/my`, {
      headers: { 'x-test-unauthenticated': 'true' },
    });

    await expect(response.json()).resolves.toMatchObject({
      error: { code: 'UNAUTHORIZED' },
    });
    expect(response.status).toBe(401);
    expect(mockListMyNotifications).not.toHaveBeenCalled();
  });

  it('maps non-owner lifecycle attempts to 403', async () => {
    mockMarkRead.mockRejectedValueOnce(NotificationErrors.notRecipient());

    const response = await fetch(`${baseUrl}/notifications/${notificationId}/read`, {
      method: 'PATCH',
      headers: { 'x-test-role': 'PATIENT' },
    });

    await expect(response.json()).resolves.toMatchObject({
      error: { code: 'NOT_RECIPIENT' },
    });
    expect(response.status).toBe(403);
  });

  it('maps missing notifications to 404 on claim', async () => {
    mockClaimNotification.mockRejectedValueOnce(AppError.notFound('Notification not found'));

    const response = await fetch(`${baseUrl}/notifications/${notificationId}/claim`, {
      method: 'PATCH',
      headers: { 'x-test-role': 'DOCTOR' },
    });

    await expect(response.json()).resolves.toMatchObject({
      error: { code: 'NOT_FOUND' },
    });
    expect(response.status).toBe(404);
  });

  it('maps claim conflicts to 409', async () => {
    mockClaimNotification.mockRejectedValueOnce(NotificationErrors.claimConflict());

    const response = await fetch(`${baseUrl}/notifications/${notificationId}/claim`, {
      method: 'PATCH',
      headers: { 'x-test-role': 'DOCTOR' },
    });

    await expect(response.json()).resolves.toMatchObject({
      error: { code: 'CLAIM_CONFLICT' },
    });
    expect(response.status).toBe(409);
  });

  it('maps illegal lifecycle transitions to 409', async () => {
    mockMarkDone.mockRejectedValueOnce(NotificationErrors.illegalTransition());

    const response = await fetch(`${baseUrl}/notifications/${notificationId}/done`, {
      method: 'PATCH',
      headers: { 'x-test-role': 'PATIENT' },
    });

    await expect(response.json()).resolves.toMatchObject({
      error: { code: 'ILLEGAL_TRANSITION' },
    });
    expect(response.status).toBe(409);
  });
});
