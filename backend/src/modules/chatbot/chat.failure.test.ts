import { Types } from 'mongoose';
import { chatErrors } from './chat.errors';

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

import { handlePatientMessage } from './chat.service';

const patientId = '8f3b7f60-997b-4e12-b45a-63f6d7dbb7ef';
const sessionId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9d0');
const patientMessageId = new Types.ObjectId('6650f1a2c3d4e5f6a7b8c9d1');

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

describe('chat failure path US5', () => {
  beforeEach(() => {
    jest.useFakeTimers().setSystemTime(new Date('2026-06-20T12:00:00.000Z'));
    jest.clearAllMocks();
    mockEmitHighRiskAlert.mockResolvedValue(undefined);
    mockWriteAudit.mockResolvedValue(undefined);
    mockSessionFindOne.mockReturnValue(
      queryReturning({
        _id: sessionId,
        patientId,
        status: 'ACTIVE',
        maxRiskLevel: 'LOW',
        lastEmotion: 'calm',
        lastActivityAt: new Date('2026-06-20T11:00:00.000Z'),
      })
    );
    mockMessageCreate.mockResolvedValue({ _id: patientMessageId });
    mockMessageFind.mockReturnValue(findMessagesReturning([]));
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
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it.each([
    ['AI throw', chatErrors.aiInferenceFailed()],
    ['timeout', chatErrors.aiInferenceFailed()],
    ['malformed response', chatErrors.aiInferenceFailed()],
  ])(
    'preserves the patient turn and writes no bot turn or rollup on %s',
    async (_label, err) => {
      mockInfer.mockRejectedValueOnce(err);

      await expect(handlePatientMessage({ patientId, message: 'Are you there?' })).rejects.toMatchObject({
        statusCode: 502,
        code: 'AI_INFERENCE_FAILED',
      });

      expect(mockMessageCreate).toHaveBeenCalledTimes(1);
      expect(mockMessageCreate).toHaveBeenCalledWith(
        expect.objectContaining({
          sessionId,
          patientId,
          sender: 'PATIENT',
          message: 'Are you there?',
        })
      );
      expect(mockInfer).toHaveBeenCalledTimes(1);
      expect(mockSessionUpdateOne).toHaveBeenCalledTimes(1);
      expect(mockSessionUpdateOne).toHaveBeenCalledWith(
        { _id: sessionId },
        { $set: { lastActivityAt: new Date('2026-06-20T12:00:00.000Z') } }
      );
      expect(mockEmitHighRiskAlert).not.toHaveBeenCalled();
      expect(mockWriteAudit).not.toHaveBeenCalled();
    }
  );
});
