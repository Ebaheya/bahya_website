import { prisma } from '../../config/prisma';
import { registerDevice, unregisterDevice } from './device.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    deviceToken: {
      upsert: jest.fn(),
      deleteMany: jest.fn(),
    },
  },
}));

const prismaMock = prisma as unknown as {
  deviceToken: {
    upsert: jest.Mock;
    deleteMany: jest.Mock;
  };
};

describe('device token service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('upserts by token, rebinds to the caller, and refreshes lastSeenAt', async () => {
    prismaMock.deviceToken.upsert.mockResolvedValue({ id: 'device-token-1' });

    await expect(
      registerDevice('user-1', { token: 'fcm-token-1', platform: 'ANDROID' })
    ).resolves.toEqual({ registered: true });

    expect(prismaMock.deviceToken.upsert).toHaveBeenCalledWith({
      where: { token: 'fcm-token-1' },
      update: {
        userId: 'user-1',
        platform: 'ANDROID',
        lastSeenAt: expect.any(Date),
      },
      create: {
        userId: 'user-1',
        token: 'fcm-token-1',
        platform: 'ANDROID',
        lastSeenAt: expect.any(Date),
      },
    });
  });

  it('unregisters only the caller-owned token', async () => {
    prismaMock.deviceToken.deleteMany.mockResolvedValue({ count: 1 });

    await expect(unregisterDevice('user-1', 'fcm-token-1')).resolves.toEqual({
      unregistered: true,
    });

    expect(prismaMock.deviceToken.deleteMany).toHaveBeenCalledWith({
      where: { userId: 'user-1', token: 'fcm-token-1' },
    });
  });
});
