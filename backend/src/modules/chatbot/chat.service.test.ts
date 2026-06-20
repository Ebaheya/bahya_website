import { Types } from 'mongoose';
import { AppError } from '../../utils/httpError';

const mockSessionFindOne = jest.fn();
const mockSessionUpdateOne = jest.fn();
const mockSessionCreate = jest.fn();
const mockMessageFind = jest.fn();
const mockMessageCreate = jest.fn();
const mockBuildPatientProfile = jest.fn();
const mockInfer = jest.fn();
const mockEmitHighRiskAlert = jest.fn();
const mockWriteAudit = jest.fn();

jest.mock('../../config/logger', () => ({
  logger: {
    error: jest.fn(),
  },
}));

jest.mock('./chat.model', () => ({
  ChatSessionModel: {
    findOne: mockSessionFindOne,
    updateOne: mockSessionUpdateOne,
    create: mockSessionCreate,
  },
  ChatMessageModel: {
    find: mockMessageFind,
    create: mockMessageCreate,
  },
}));

jest.mock('./chat.profile', () => ({
  buildPatientProfile: mockBuildPatientProfile,
}));

jest.mock('./ai.client', () => ({
  infer: mockInfer,
}));

jest.mock('../notifications/notification.service', () => ({
  emitHighRiskAlert: mockEmitHighRiskAlert,
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: mockWriteAudit,
}));

import { getOrCreateSession, getRecentTurns, handlePatientMessage } from './chat.service';

const patientId = '8f3b7f60-997b-4e12-b45a-63f6d7dbb7ef';
const sessionId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9d0');
const patientMessageId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9d1');
const botMessageId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9d2');

function queryReturning<T>(value: T) {
  return {
    sort: jest.fn().mockReturnThis(),
    exec: jest.fn().mockResolvedValue(value),
  };
}

function findMessagesReturning<T>(value: T) {
  return {
    sort: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    exec: jest.fn().mockResolvedValue(value),
  };
}

describe('chat service US1', () => {
  beforeEach(() => {
    jest.useFakeTimers().setSystemTime(new Date('2026-06-20T12:00:00.000Z'));
    jest.clearAllMocks();
    mockEmitHighRiskAlert.mockResolvedValue(true);
    mockWriteAudit.mockResolvedValue(undefined);
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('creates a new active session when the patient has no open session', async () => {
    mockSessionFindOne.mockReturnValueOnce(queryReturning(null));
    mockSessionCreate.mockResolvedValue({
      _id: sessionId,
      patientId,
      status: 'ACTIVE',
      maxRiskLevel: null,
      lastActivityAt: new Date('2026-06-20T12:00:00.000Z'),
    });

    const session = await getOrCreateSession(patientId);

    expect(session._id.toString()).toBe(sessionId.toString());
    expect(mockSessionCreate).toHaveBeenCalledWith(
      expect.objectContaining({
        patientId,
        status: 'ACTIVE',
        maxRiskLevel: null,
        lastEmotion: null,
        summary: null,
        endedAt: null,
      })
    );
  });

  it('reuses and bumps an active session within 24 hours', async () => {
    mockSessionFindOne.mockReturnValueOnce(
      queryReturning({
        _id: sessionId,
        patientId,
        status: 'ACTIVE',
        maxRiskLevel: 'LOW',
        lastActivityAt: new Date('2026-06-20T11:00:00.000Z'),
      })
    );

    const session = await getOrCreateSession(patientId, sessionId.toString());

    expect(session._id.toString()).toBe(sessionId.toString());
    expect(mockSessionUpdateOne).toHaveBeenCalledWith(
      { _id: sessionId },
      { $set: { lastActivityAt: new Date('2026-06-20T12:00:00.000Z') } }
    );
    expect(mockSessionCreate).not.toHaveBeenCalled();
  });

  it('closes a stale active session and opens a new one after 24 hours inactivity', async () => {
    mockSessionFindOne.mockReturnValueOnce(
      queryReturning({
        _id: sessionId,
        patientId,
        status: 'ACTIVE',
        maxRiskLevel: 'MEDIUM',
        lastActivityAt: new Date('2026-06-18T11:00:00.000Z'),
      })
    );
    const newSessionId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9e0');
    mockSessionCreate.mockResolvedValue({
      _id: newSessionId,
      patientId,
      status: 'ACTIVE',
      maxRiskLevel: null,
      lastActivityAt: new Date('2026-06-20T12:00:00.000Z'),
    });

    const session = await getOrCreateSession(patientId);

    expect(session._id.toString()).toBe(newSessionId.toString());
    expect(mockSessionUpdateOne).toHaveBeenCalledWith(
      { _id: sessionId },
      {
        $set: {
          status: 'CLOSED',
          endedAt: new Date('2026-06-20T12:00:00.000Z'),
          lastActivityAt: new Date('2026-06-20T12:00:00.000Z'),
        },
      }
    );
  });

  it('throws a stable 404 for an unknown supplied session id', async () => {
    mockSessionFindOne.mockReturnValueOnce(queryReturning(null));

    await expect(getOrCreateSession(patientId, sessionId.toString())).rejects.toMatchObject<
      Partial<AppError>
    >({
      statusCode: 404,
      code: 'CHAT_SESSION_NOT_FOUND',
    });
  });

  it('rejects an explicitly supplied session that is already CLOSED instead of silently creating a new one', async () => {
    mockSessionFindOne.mockReturnValueOnce(
      queryReturning({
        _id: sessionId,
        patientId,
        status: 'CLOSED',
        lastActivityAt: new Date('2026-06-20T11:00:00.000Z'),
      })
    );

    await expect(getOrCreateSession(patientId, sessionId.toString())).rejects.toMatchObject({
      statusCode: 404,
      code: 'CHAT_SESSION_NOT_FOUND',
    });
    expect(mockSessionCreate).not.toHaveBeenCalled();
  });

  it('recovers from a concurrent-create race by returning the winning active session', async () => {
    const winnerId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9ff');
    // No open session at first read; create loses the unique-index race; re-read wins.
    mockSessionFindOne
      .mockReturnValueOnce(queryReturning(null))
      .mockReturnValueOnce(
        queryReturning({
          _id: winnerId,
          patientId,
          status: 'ACTIVE',
          maxRiskLevel: null,
          lastActivityAt: new Date('2026-06-20T12:00:00.000Z'),
        })
      );
    mockSessionCreate.mockRejectedValueOnce(Object.assign(new Error('dup'), { code: 11000 }));

    const session = await getOrCreateSession(patientId);

    expect(session._id.toString()).toBe(winnerId.toString());
  });

  it('returns the last 10 turns in ascending order for AI history', async () => {
    const turns = Array.from({ length: 12 }, (_, i) => ({
      sender: i % 2 === 0 ? 'PATIENT' : 'BOT',
      message: `turn-${i}`,
      emotion: i % 2 === 0 ? null : 'neutral',
      riskLevel: i % 2 === 0 ? null : 'LOW',
      createdAt: new Date(Date.UTC(2026, 5, 20, 10, i, 0)),
    })).slice(2).reverse();
    mockMessageFind.mockReturnValueOnce(findMessagesReturning(turns));

    const history = await getRecentTurns(sessionId, 10);

    expect(history).toHaveLength(10);
    expect(history[0]).toMatchObject({ sender: 'PATIENT', text: 'turn-2' });
    expect(history[9]).toMatchObject({ sender: 'BOT', text: 'turn-11' });
    expect(mockMessageFind).toHaveBeenCalledWith({ sessionId });
  });

  it('persists patient and bot turns, sends recent history, updates rollup, and returns no signals', async () => {
    mockSessionFindOne.mockReturnValueOnce(
      queryReturning({
        _id: sessionId,
        patientId,
        status: 'ACTIVE',
        maxRiskLevel: 'LOW',
        lastActivityAt: new Date('2026-06-20T11:00:00.000Z'),
      })
    );
    mockMessageCreate
      .mockResolvedValueOnce({ _id: patientMessageId })
      .mockResolvedValueOnce({ _id: botMessageId });
    mockMessageFind.mockReturnValueOnce(
      findMessagesReturning([
        {
          sender: 'PATIENT',
          message: 'hello',
          emotion: null,
          riskLevel: null,
          createdAt: new Date('2026-06-20T11:59:00.000Z'),
        },
      ])
    );
    mockBuildPatientProfile.mockResolvedValue({
      patientId,
      age: 36,
      languagePref: 'ar',
      cancerStage: null,
      diseaseStatus: null,
      treatments: [],
      dietNotes: null,
      riskFlagFromHistory: 'LOW',
    });
    mockInfer.mockResolvedValue({
      version: 1,
      reply: 'I am here with you.',
      lang: 'en',
      emotion: { label: 'sadness', confidence: 0.88 },
      intent: 'emotional_support',
      riskLevel: 'MEDIUM',
      crisisProbability: 0.34,
      crisis: false,
      crisisSignalType: null,
      flaggedPhrases: ['cannot sleep'],
      phq9Score: null,
    });

    const result = await handlePatientMessage({ patientId, message: 'hello' });

    expect(mockMessageCreate).toHaveBeenNthCalledWith(
      1,
      expect.objectContaining({
        sessionId,
        patientId,
        sender: 'PATIENT',
        message: 'hello',
      })
    );
    expect(mockInfer).toHaveBeenCalledWith(
      expect.objectContaining({
        version: 1,
        sessionId: sessionId.toString(),
        message: 'hello',
        history: [{ sender: 'PATIENT', text: 'hello', emotion: null, riskLevel: null, createdAt: expect.any(String) }],
      })
    );
    expect(mockMessageCreate).toHaveBeenNthCalledWith(
      2,
      expect.objectContaining({
        sessionId,
        patientId,
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
      })
    );
    expect(mockSessionUpdateOne).toHaveBeenLastCalledWith(
      { _id: sessionId },
      expect.objectContaining({
        $set: expect.objectContaining({
          maxRiskLevel: 'MEDIUM',
          lastEmotion: 'sadness',
          lastActivityAt: new Date('2026-06-20T12:00:00.000Z'),
        }),
      })
    );
    expect(result).toEqual({
      sessionId: sessionId.toString(),
      patientMessageId: patientMessageId.toString(),
      botMessageId: botMessageId.toString(),
      reply: 'I am here with you.',
    });
    expect(result).not.toHaveProperty('riskLevel');
    expect(result).not.toHaveProperty('emotion');
    expect(result).not.toHaveProperty('intent');
    expect(result).not.toHaveProperty('crisis');
  });
});
