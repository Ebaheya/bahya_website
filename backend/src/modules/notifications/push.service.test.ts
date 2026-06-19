import { logger } from '../../config/logger';
import { prisma } from '../../config/prisma';
import { sendFcmMulticast } from '../../config/fcm';
import { NotificationModel } from './notification.model';
import type { NotificationDoc } from './notification.model';
import { pushForNotification } from './push.service';

jest.mock('../../config/logger', () => ({
  logger: {
    warn: jest.fn(),
  },
}));

jest.mock('../../config/prisma', () => ({
  prisma: {
    deviceToken: {
      findMany: jest.fn(),
      deleteMany: jest.fn(),
    },
  },
}));

jest.mock('../../config/fcm', () => ({
  sendFcmMulticast: jest.fn(),
}));

jest.mock('./notification.model', () => ({
  NotificationModel: {
    updateOne: jest.fn(),
  },
}));

const loggerMock = logger as unknown as { warn: jest.Mock };
const sendFcmMulticastMock = sendFcmMulticast as jest.Mock;
const notificationModelMock = NotificationModel as unknown as { updateOne: jest.Mock };
const prismaMock = prisma as unknown as {
  deviceToken: {
    findMany: jest.Mock;
    deleteMany: jest.Mock;
  };
};

function notificationDoc(overrides: Partial<NotificationDoc & { _id: string }> = {}): NotificationDoc & { _id: string } {
  return {
    _id: '64b2f0000000000000000001',
    recipientRole: 'PATIENT',
    recipientUserId: 'patient-user-1',
    patientId: 'patient-1',
    type: 'SERVICE_REQUEST_DECIDED',
    title: 'Do not send this title',
    message: 'Do not send this message',
    severity: 'LOW',
    reason: null,
    doctorNote: null,
    status: 'UNREAD',
    claimedAt: null,
    readAt: null,
    doneAt: null,
    pushedAt: null,
    createdAt: new Date('2026-06-15T00:00:00Z'),
    ...overrides,
  };
}

describe('pushForNotification', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('sends category localization keys to personal recipient tokens and sets pushedAt', async () => {
    prismaMock.deviceToken.findMany.mockResolvedValue([{ token: 'token-a' }, { token: 'token-b' }]);
    sendFcmMulticastMock.mockResolvedValue({
      successCount: 2,
      failureCount: 0,
      responses: [{ success: true }, { success: true }],
    });
    notificationModelMock.updateOne.mockResolvedValue({ modifiedCount: 1 });

    await pushForNotification(notificationDoc());

    expect(prismaMock.deviceToken.findMany).toHaveBeenCalledWith({
      where: { userId: 'patient-user-1' },
      select: { token: true },
    });
    expect(sendFcmMulticastMock).toHaveBeenCalledWith(
      expect.objectContaining({
        tokens: ['token-a', 'token-b'],
        data: {
          notificationId: '64b2f0000000000000000001',
          type: 'SERVICE_REQUEST_DECIDED',
        },
        android: {
          priority: 'high',
          notification: {
            titleLocKey: 'NOTIFICATION_SERVICE_REQUEST_DECIDED_TITLE',
            bodyLocKey: 'NOTIFICATION_SERVICE_REQUEST_DECIDED_BODY',
            channelId: 'default_channel',
            defaultSound: true,
          },
        },
      })
    );
    expect(JSON.stringify(sendFcmMulticastMock.mock.calls[0][0])).not.toContain('Do not send');
    expect(notificationModelMock.updateOne).toHaveBeenCalledWith(
      { _id: '64b2f0000000000000000001' },
      { $set: { pushedAt: expect.any(Date) } }
    );
  });

  it('resolves broadcast tokens from active users with the recipient role', async () => {
    prismaMock.deviceToken.findMany.mockResolvedValue([{ token: 'doctor-token' }]);
    sendFcmMulticastMock.mockResolvedValue({
      successCount: 1,
      failureCount: 0,
      responses: [{ success: true }],
    });

    await pushForNotification(
      notificationDoc({ recipientRole: 'DOCTOR', recipientUserId: null, type: 'HIGH_RISK' })
    );

    expect(prismaMock.deviceToken.findMany).toHaveBeenCalledWith({
      where: { user: { is: { role: 'DOCTOR', isActive: true } } },
      select: { token: true },
    });
  });

  it('prunes tokens that FCM reports as unregistered or invalid', async () => {
    prismaMock.deviceToken.findMany.mockResolvedValue([{ token: 'gone' }, { token: 'bad' }]);
    sendFcmMulticastMock.mockResolvedValue({
      successCount: 0,
      failureCount: 2,
      responses: [
        { success: false, error: { code: 'messaging/registration-token-not-registered' } },
        { success: false, error: { code: 'messaging/invalid-argument' } },
      ],
    });

    await pushForNotification(notificationDoc());

    expect(prismaMock.deviceToken.deleteMany).toHaveBeenCalledWith({
      where: { token: { in: ['gone', 'bad'] } },
    });
  });

  it('swallows FCM failures and leaves pushedAt unset', async () => {
    prismaMock.deviceToken.findMany.mockResolvedValue([{ token: 'token-a' }]);
    sendFcmMulticastMock.mockRejectedValue(new Error('fcm down'));

    await expect(pushForNotification(notificationDoc())).resolves.toBeUndefined();

    expect(notificationModelMock.updateOne).not.toHaveBeenCalled();
    expect(loggerMock.warn).toHaveBeenCalledWith(
      expect.objectContaining({
        metric: 'notification_push_failure',
        notificationId: '64b2f0000000000000000001',
      }),
      'notification push failed'
    );
  });

  it('splits broadcasts over the 500-token FCM limit into batches and prunes per batch', async () => {
    // 650 tokens => two multicasts (500 + 150). Firebase rejects a single
    // multicast above 500, so without chunking none of these would be delivered.
    const tokens = Array.from({ length: 650 }, (_, i) => ({ token: `token-${i}` }));
    prismaMock.deviceToken.findMany.mockResolvedValue(tokens);
    sendFcmMulticastMock
      .mockResolvedValueOnce({
        successCount: 499,
        failureCount: 1,
        responses: [
          ...Array.from({ length: 499 }, () => ({ success: true })),
          { success: false, error: { code: 'messaging/registration-token-not-registered' } },
        ],
      })
      .mockResolvedValueOnce({
        successCount: 150,
        failureCount: 0,
        responses: Array.from({ length: 150 }, () => ({ success: true })),
      });
    notificationModelMock.updateOne.mockResolvedValue({ modifiedCount: 1 });

    await pushForNotification(
      notificationDoc({ recipientRole: 'DOCTOR', recipientUserId: null, type: 'HIGH_RISK' })
    );

    expect(sendFcmMulticastMock).toHaveBeenCalledTimes(2);
    expect(sendFcmMulticastMock.mock.calls[0][0].tokens).toHaveLength(500);
    expect(sendFcmMulticastMock.mock.calls[1][0].tokens).toHaveLength(150);
    // The stale token in batch one (index 499 => 'token-499') is pruned.
    expect(prismaMock.deviceToken.deleteMany).toHaveBeenCalledWith({
      where: { token: { in: ['token-499'] } },
    });
    // pushedAt set once after at least one batch succeeded.
    expect(notificationModelMock.updateOne).toHaveBeenCalledTimes(1);
  });

  it('no-ops without device tokens or when the FCM sender is disabled', async () => {
    prismaMock.deviceToken.findMany.mockResolvedValueOnce([]);
    await pushForNotification(notificationDoc());

    prismaMock.deviceToken.findMany.mockResolvedValueOnce([{ token: 'token-a' }]);
    sendFcmMulticastMock.mockResolvedValueOnce(null);
    await pushForNotification(notificationDoc());

    expect(notificationModelMock.updateOne).not.toHaveBeenCalled();
  });
});
