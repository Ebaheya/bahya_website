import type { DevicePlatform } from '@prisma/client';
import { prisma } from '../../config/prisma';

export interface RegisterDeviceInput {
  token: string;
  platform: DevicePlatform;
}

export async function registerDevice(userId: string, input: RegisterDeviceInput) {
  const now = new Date();
  await prisma.deviceToken.upsert({
    where: { token: input.token },
    update: {
      userId,
      platform: input.platform,
      lastSeenAt: now,
    },
    create: {
      userId,
      token: input.token,
      platform: input.platform,
      lastSeenAt: now,
    },
  });

  return { registered: true };
}

export async function unregisterDevice(userId: string, token: string) {
  await prisma.deviceToken.deleteMany({
    where: { userId, token },
  });

  return { unregistered: true };
}
