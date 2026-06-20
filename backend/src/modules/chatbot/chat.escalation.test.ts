import { Types } from 'mongoose';

const mockSessionFindOne = jest.fn();
const mockSessionUpdateOne = jest.fn();
const mockSessionCreate = jest.fn();
const mockMessageFind = jest.fn();
const mockMessageCreate = jest.fn();
const mockBuildPatientProfile = jest.fn();
const mockInfer = jest.fn();
const mockEmitHighRiskAlert = jest.fn();
const mockWriteAudit = jest.fn();
const mockLoggerError = jest.fn();

jest.mock('../../config/logger', () => ({
  logger: {
    error: mockLoggerError,
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

import { escalateIfNeeded, handlePatientMessage } from './chat.service';

const patientId = '8f3b7f60-997b-4e12-b45a-63f6d7dbb7ef';
const sessionId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9d0');
const patientMessageId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9d1');
const botMessageId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9d2');

const mediumInference = {
  version: 1 as const,
  reply: 'I am here with you.',
  lang: 'en' as const,
  emotion: { label: 'sadness', confidence: 0.88 },
  intent: 'emotional_support' as const,
  riskLevel: 'MEDIUM' as const,
  crisisProbability: 0.34,
  crisis: false,
  crisisSignalType: null,
  flaggedPhrases: ['cannot sleep'],
  phq9Score: null,
};

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

async function flushMicrotasks() {
  await Promise.resolve();
  await Promise.resolve();
}

describe('chat escalation US2', () => {
  beforeEach(() => {
    jest.useFakeTimers().setSystemTime(new Date('2026-06-20T12:00:00.000Z'));
    jest.clearAllMocks();
    mockEmitHighRiskAlert.mockResolvedValue(undefined);
    mockWriteAudit.mockResolvedValue(undefined);
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('skips LOW risk without notification or audit', async () => {
    await escalateIfNeeded({
      patientId,
      sessionId: sessionId.toString(),
      inf: { ...mediumInference, riskLevel: 'LOW', flaggedPhrases: [] },
    });

    expect(mockEmitHighRiskAlert).not.toHaveBeenCalled();
    expect(mockWriteAudit).not.toHaveBeenCalled();
  });

  it('raises a doctor alert and strict audit for MEDIUM risk with flagged phrases', async () => {
    await escalateIfNeeded({
      patientId,
      sessionId: sessionId.toString(),
      inf: mediumInference,
    });

    expect(mockEmitHighRiskAlert).toHaveBeenCalledWith({
      patientId,
      severity: 'MEDIUM',
      reason: 'AI risk level MEDIUM',
      flaggedPhrases: ['cannot sleep'],
    });
    expect(mockWriteAudit).toHaveBeenCalledWith({
      actorId: null,
      action: 'HIGH_RISK_ALERT_CREATED',
      entityType: 'CHAT_SESSION',
      entityId: sessionId.toString(),
      newValues: {
        riskLevel: 'MEDIUM',
        crisisProbability: 0.34,
        crisis: false,
        flaggedPhrases: ['cannot sleep'],
      },
    });
  });

  it('swallows alert failures so handlePatientMessage still returns the patient reply', async () => {
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
    mockMessageFind.mockReturnValueOnce(findMessagesReturning([]));
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
    mockInfer.mockResolvedValue(mediumInference);
    mockEmitHighRiskAlert.mockRejectedValueOnce(new Error('notification store down'));

    await expect(handlePatientMessage({ patientId, message: 'hello' })).resolves.toEqual({
      sessionId: sessionId.toString(),
      patientMessageId: patientMessageId.toString(),
      botMessageId: botMessageId.toString(),
      reply: 'I am here with you.',
    });
    await flushMicrotasks();

    expect(mockLoggerError).toHaveBeenCalledWith(
      expect.objectContaining({
        metric: 'chat_escalation_failure',
        patientId,
        sessionId: sessionId.toString(),
        riskLevel: 'MEDIUM',
      }),
      'chat escalation failed'
    );
  });
});
