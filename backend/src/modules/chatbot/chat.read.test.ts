import type { Server } from 'node:http';
import type { NextFunction, Request, Response } from 'express';
import type { Role } from '@prisma/client';
import { Types } from 'mongoose';
import express from 'express';
import { errorHandler } from '../../middleware/errorHandler';

const mockSessionFind = jest.fn();
const mockSessionFindOne = jest.fn();
const mockSessionCountDocuments = jest.fn();
const mockSessionUpdateOne = jest.fn();
const mockSessionCreate = jest.fn();
const mockMessageFind = jest.fn();
const mockMessageCountDocuments = jest.fn();
const mockMessageCreate = jest.fn();
const mockResolvePatientIdForUser = jest.fn();

jest.mock('../../config/logger', () => ({
  logger: {
    error: jest.fn(),
  },
}));

jest.mock('./chat.model', () => ({
  ChatSessionModel: {
    find: mockSessionFind,
    findOne: mockSessionFindOne,
    countDocuments: mockSessionCountDocuments,
    updateOne: mockSessionUpdateOne,
    create: mockSessionCreate,
  },
  ChatMessageModel: {
    find: mockMessageFind,
    countDocuments: mockMessageCountDocuments,
    create: mockMessageCreate,
  },
}));

jest.mock('./chat.profile', () => ({
  buildPatientProfile: jest.fn(),
  resolvePatientIdForUser: mockResolvePatientIdForUser,
}));

jest.mock('./ai.client', () => ({
  infer: jest.fn(),
}));

jest.mock('../notifications/notification.service', () => ({
  emitHighRiskAlert: jest.fn(),
  emitCallCenterAlert: jest.fn(),
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

import {
  getSessionMessages,
  listSessions,
  projectTurnForRole,
} from './chat.service';

const ownerPatientId = '11111111-1111-4111-8111-111111111111';
const otherPatientId = '22222222-2222-4222-8222-222222222222';
const sessionId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9d0');
const messageId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9d1');

function queryChain<T>(result: T) {
  return {
    sort: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    lean: jest.fn().mockResolvedValue(result),
    exec: jest.fn().mockResolvedValue(result),
  };
}

describe('chat read service US4', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('lists own sessions for patients and ignores no staff-only patientId requirement', async () => {
    const startedAt = new Date('2026-06-20T01:00:00.000Z');
    const docs = [
      {
        _id: sessionId,
        patientId: ownerPatientId,
        status: 'ACTIVE',
        maxRiskLevel: 'MEDIUM',
        lastEmotion: 'sadness',
        startedAt,
        endedAt: null,
      },
    ];
    const chain = queryChain(docs);
    mockSessionFind.mockReturnValue(chain);
    mockSessionCountDocuments.mockResolvedValue(1);

    await expect(
      listSessions({ id: ownerPatientId, role: 'PATIENT' }, { page: 2, pageSize: 10 })
    ).resolves.toEqual({
      data: [
        {
          id: sessionId.toString(),
          status: 'ACTIVE',
          maxRiskLevel: 'MEDIUM',
          lastEmotion: 'sadness',
          startedAt,
          endedAt: null,
        },
      ],
      page: 2,
      pageSize: 10,
      total: 1,
    });
    expect(mockSessionFind).toHaveBeenCalledWith({ patientId: ownerPatientId });
    expect(chain.sort).toHaveBeenCalledWith({ startedAt: -1 });
    expect(chain.skip).toHaveBeenCalledWith(10);
    expect(chain.limit).toHaveBeenCalledWith(10);
  });

  it('requires patientId for Doctor/Admin session lists', async () => {
    await expect(
      listSessions({ id: 'doctor-1', role: 'DOCTOR' }, { page: 1, pageSize: 20 })
    ).rejects.toMatchObject({ statusCode: 400, code: 'BAD_REQUEST' });

    expect(mockSessionFind).not.toHaveBeenCalled();
  });

  it('lists requested patient sessions for clinicians', async () => {
    mockSessionFind.mockReturnValue(queryChain([]));
    mockSessionCountDocuments.mockResolvedValue(0);

    await listSessions(
      { id: 'doctor-1', role: 'DOCTOR' },
      { patientId: ownerPatientId, page: 1, pageSize: 20 }
    );

    expect(mockSessionFind).toHaveBeenCalledWith({ patientId: ownerPatientId });
  });

  it('projects signal fields only for Doctor/Admin message reads', async () => {
    const turn = {
      _id: messageId,
      sender: 'BOT',
      message: 'I am here with you.',
      lang: 'en',
      emotion: 'sadness',
      emotionConfidence: 0.88,
      intent: 'emotional_support',
      riskLevel: 'MEDIUM',
      crisisProbability: 0.34,
      crisis: false,
      crisisSignalType: null,
      flaggedPhrases: ['cannot sleep'],
      phq9Score: null,
      createdAt: new Date('2026-06-20T01:00:03.000Z'),
    };

    expect(projectTurnForRole(turn, 'PATIENT')).toEqual({
      id: messageId.toString(),
      sender: 'BOT',
      message: 'I am here with you.',
      createdAt: turn.createdAt,
    });
    expect(projectTurnForRole(turn, 'DOCTOR')).toEqual({
      id: messageId.toString(),
      sender: 'BOT',
      message: 'I am here with you.',
      lang: 'en',
      emotion: 'sadness',
      emotionConfidence: 0.88,
      intent: 'emotional_support',
      riskLevel: 'MEDIUM',
      crisisProbability: 0.34,
      crisis: false,
      crisisSignalType: null,
      flaggedPhrases: ['cannot sleep'],
      phq9Score: null,
      createdAt: turn.createdAt,
    });
  });

  it('returns ordered paginated messages for owner patients without signals', async () => {
    mockSessionFindOne.mockReturnValue(
      queryChain({ _id: sessionId, patientId: ownerPatientId, maxRiskLevel: 'MEDIUM' })
    );
    mockMessageFind.mockReturnValue(
      queryChain([
        {
          _id: messageId,
          sender: 'BOT',
          message: 'I am here with you.',
          emotion: 'sadness',
          riskLevel: 'MEDIUM',
          createdAt: new Date('2026-06-20T01:00:03.000Z'),
        },
      ])
    );
    mockMessageCountDocuments.mockResolvedValue(1);

    const result = await getSessionMessages(
      { id: ownerPatientId, role: 'PATIENT' },
      sessionId.toString(),
      { page: 1, pageSize: 20 }
    );

    expect(mockMessageFind).toHaveBeenCalledWith({ sessionId });
    expect(result.data[0]).toEqual({
      id: messageId.toString(),
      sender: 'BOT',
      message: 'I am here with you.',
      createdAt: new Date('2026-06-20T01:00:03.000Z'),
    });
    expect(result.data[0]).not.toHaveProperty('riskLevel');
  });

  it('forbids patient access to another patient session and returns 404 for missing session', async () => {
    mockSessionFindOne.mockReturnValueOnce(
      queryChain({ _id: sessionId, patientId: otherPatientId })
    );

    await expect(
      getSessionMessages(
        { id: ownerPatientId, role: 'PATIENT' },
        sessionId.toString(),
        { page: 1, pageSize: 20 }
      )
    ).rejects.toMatchObject({ statusCode: 403, code: 'FORBIDDEN' });

    mockSessionFindOne.mockReturnValueOnce(queryChain(null));

    await expect(
      getSessionMessages(
        { id: 'doctor-1', role: 'DOCTOR' },
        sessionId.toString(),
        { page: 1, pageSize: 20 }
      )
    ).rejects.toMatchObject({ statusCode: 404, code: 'CHAT_SESSION_NOT_FOUND' });
  });
});

jest.mock('../../middleware/authenticate', () => ({
  authenticate: (req: Request, _res: Response, next: NextFunction): void => {
    req.user = {
      id: String(req.headers['x-test-user-id'] ?? ownerPatientId),
      role: String(req.headers['x-test-role'] ?? 'PATIENT') as Role,
    };
    next();
  },
}));

import { chatRouter } from './chat.routes';

describe('chat read routes US4', () => {
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
    // Controller resolves the patient User id to their Patient id for reads.
    mockResolvePatientIdForUser.mockResolvedValue(ownerPatientId);
  });

  it('routes patient session list to their own actor context', async () => {
    mockSessionFind.mockReturnValue(queryChain([]));
    mockSessionCountDocuments.mockResolvedValue(0);

    const response = await fetch(`${baseUrl}/chatbot/sessions?page=2&pageSize=10`, {
      headers: { 'x-test-role': 'PATIENT', 'x-test-user-id': ownerPatientId },
    });

    await expect(response.json()).resolves.toEqual({ data: [], page: 2, pageSize: 10, total: 0 });
    expect(response.status).toBe(200);
    expect(mockSessionFind).toHaveBeenCalledWith({ patientId: ownerPatientId });
  });

  it('rejects staff session list requests missing patientId before service call', async () => {
    const response = await fetch(`${baseUrl}/chatbot/sessions`, {
      headers: { 'x-test-role': 'DOCTOR', 'x-test-user-id': 'doctor-1' },
    });

    expect(response.status).toBe(400);
    expect(mockSessionFind).not.toHaveBeenCalled();
  });

  it('routes staff session lists with patientId and preserves maxRiskLevel response data', async () => {
    mockSessionFind.mockReturnValue(
      queryChain([
        {
          _id: sessionId,
          status: 'ACTIVE',
          maxRiskLevel: 'MEDIUM',
          lastEmotion: null,
          startedAt: new Date('2026-06-20T01:00:00.000Z'),
          endedAt: null,
        },
      ])
    );
    mockSessionCountDocuments.mockResolvedValue(1);

    const response = await fetch(`${baseUrl}/chatbot/sessions?patientId=${ownerPatientId}`, {
      headers: { 'x-test-role': 'DOCTOR', 'x-test-user-id': 'doctor-1' },
    });

    await expect(response.json()).resolves.toMatchObject({
      data: [{ id: sessionId.toString(), maxRiskLevel: 'MEDIUM' }],
    });
    expect(response.status).toBe(200);
    expect(mockSessionFind).toHaveBeenCalledWith({ patientId: ownerPatientId });
  });

  it('routes message reads and relies on service projection/ownership checks', async () => {
    mockSessionFindOne.mockReturnValue(queryChain({ _id: sessionId, patientId: ownerPatientId }));
    mockMessageFind.mockReturnValue(queryChain([]));
    mockMessageCountDocuments.mockResolvedValue(0);

    const response = await fetch(`${baseUrl}/chatbot/sessions/${sessionId.toString()}/messages`, {
      headers: { 'x-test-role': 'PATIENT', 'x-test-user-id': ownerPatientId },
    });

    await expect(response.json()).resolves.toEqual({
      sessionId: sessionId.toString(),
      data: [],
      page: 1,
      pageSize: 20,
      total: 0,
    });
    expect(response.status).toBe(200);
    expect(mockSessionFindOne).toHaveBeenCalledWith({ _id: sessionId });
  });

  it('rejects malformed session ids on message reads', async () => {
    const response = await fetch(`${baseUrl}/chatbot/sessions/not-an-id/messages`, {
      headers: { 'x-test-role': 'DOCTOR' },
    });

    expect(response.status).toBe(400);
    expect(mockSessionFindOne).not.toHaveBeenCalled();
  });

  it('rejects Call Center read access', async () => {
    const response = await fetch(`${baseUrl}/chatbot/sessions`, {
      headers: { 'x-test-role': 'CALL_CENTER' },
    });

    expect(response.status).toBe(403);
    expect(mockSessionFind).not.toHaveBeenCalled();
  });
});
