import type { Server } from 'node:http';
import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import express from 'express';
import { errorHandler } from '../../middleware/errorHandler';

const mockHandlePatientMessage = jest.fn();
const limiterHits = new Map<string, number>();

jest.mock('../../config/logger', () => ({
  logger: {
    error: jest.fn(),
  },
}));

jest.mock('../../middleware/authenticate', () => ({
  authenticate: (req: Request, _res: Response, next: NextFunction): void => {
    req.user = {
      id: String(req.headers['x-test-user-id'] ?? 'patient-user'),
      role: String(req.headers['x-test-role'] ?? 'PATIENT') as Role,
    };
    next();
  },
}));

jest.mock('../../middleware/userRateLimit', () => ({
  userRateLimiter:
    (limit: number) =>
    (req: Request, res: Response, next: NextFunction): void => {
      const key = req.user?.id ?? 'anonymous';
      const hits = (limiterHits.get(key) ?? 0) + 1;
      limiterHits.set(key, hits);
      if (hits > limit) {
        res.status(429).json({ error: { code: 'TOO_MANY_REQUESTS' } });
        return;
      }
      next();
    },
}));

jest.mock('./chat.service', () => ({
  handlePatientMessage: mockHandlePatientMessage,
}));

import { chatRouter } from './chat.routes';

describe('chat routes US1', () => {
  let server: Server;
  let baseUrl: string;

  beforeAll(() => {
    const app = express();
    app.use(express.json());
    app.use('/chatbot', chatRouter);
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
    mockHandlePatientMessage.mockResolvedValue({
      sessionId: '6650f1a2c3d4e5f6a7b8c9d0',
      patientMessageId: '6650f1a2c3d4e5f6a7b8c9d1',
      botMessageId: '6650f1a2c3d4e5f6a7b8c9d2',
      reply: 'I am here with you.',
      riskLevel: 'MEDIUM',
      emotion: 'sadness',
      intent: 'emotional_support',
      crisis: false,
    });
  });

  it('allows only patients to send chatbot messages', async () => {
    for (const role of ['DOCTOR', 'ADMIN', 'CALL_CENTER']) {
      const response = await fetch(`${baseUrl}/chatbot/message`, {
        method: 'POST',
        headers: { 'content-type': 'application/json', 'x-test-role': role },
        body: JSON.stringify({ message: 'hello' }),
      });

      expect(response.status).toBe(403);
    }

    expect(mockHandlePatientMessage).not.toHaveBeenCalled();
  });

  it('validates empty, whitespace, and over-length messages before the service call', async () => {
    for (const body of [{ message: '' }, { message: '   ' }, { message: 'a'.repeat(4001) }]) {
      const response = await fetch(`${baseUrl}/chatbot/message`, {
        method: 'POST',
        headers: { 'content-type': 'application/json', 'x-test-role': 'PATIENT' },
        body: JSON.stringify(body),
      });

      expect(response.status).toBe(400);
    }

    expect(mockHandlePatientMessage).not.toHaveBeenCalled();
  });

  it('rate-limits patients at 30 messages per minute', async () => {
    for (let i = 0; i < 31; i += 1) {
      const response = await fetch(`${baseUrl}/chatbot/message`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'x-test-role': 'PATIENT',
          'x-test-user-id': 'same-patient',
        },
        body: JSON.stringify({ message: `hello ${i}` }),
      });

      expect(response.status).toBe(i < 30 ? 200 : 429);
    }

    expect(mockHandlePatientMessage).toHaveBeenCalledTimes(30);
  });

  it('returns reply and ids only, even if the service returns internal signals', async () => {
    const response = await fetch(`${baseUrl}/chatbot/message`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-test-role': 'PATIENT' },
      body: JSON.stringify({
        sessionId: '6650f1a2c3d4e5f6a7b8c9d0',
        message: '  hello  ',
      }),
    });

    await expect(response.json()).resolves.toEqual({
      sessionId: '6650f1a2c3d4e5f6a7b8c9d0',
      patientMessageId: '6650f1a2c3d4e5f6a7b8c9d1',
      botMessageId: '6650f1a2c3d4e5f6a7b8c9d2',
      reply: 'I am here with you.',
    });
    expect(response.status).toBe(200);
    expect(mockHandlePatientMessage).toHaveBeenCalledWith({
      patientId: 'patient-user',
      sessionId: '6650f1a2c3d4e5f6a7b8c9d0',
      message: 'hello',
    });
  });
});
