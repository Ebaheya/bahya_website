import http from 'node:http';
import type { AddressInfo } from 'node:net';
import mongoose from 'mongoose';
import type { PrismaClient, Role } from '@prisma/client';
import type { createApp as createAppFn } from '../../src/app';
import type { hashPassword as hashPasswordFn } from '../../src/utils/passwords';
import type { signAccessToken as signAccessTokenFn } from '../../src/utils/tokens';

const password = 'StaffPass123!';

let createApp: typeof createAppFn;
let prisma: PrismaClient;
let hashPassword: typeof hashPasswordFn;
let signAccessToken: typeof signAccessTokenFn;
let server: http.Server;
let baseUrl: string;

async function request(path: string, init: RequestInit = {}) {
  return fetch(`${baseUrl}${path}`, {
    ...init,
    headers: {
      'content-type': 'application/json',
      ...(init.headers ?? {}),
    },
  });
}

async function createUser(role: Role, email: string) {
  const user = await prisma.user.create({
    data: {
      email,
      fullName: `${role} User`,
      passwordHash: await hashPassword(password),
      role,
    },
  });

  return {
    user,
    token: signAccessToken({ sub: user.id, role: user.role }),
  };
}

describe('PATCH /api/v1/users/:id/status last-admin lockout', () => {
  beforeAll(async () => {
    process.env.MONGODB_URI ??=
      'mongodb://bahya:bahya@localhost:27017/bahya_activity?authSource=admin';

    ({ createApp } = await import('../../src/app'));
    ({ prisma } = await import('../../src/config/prisma'));
    ({ hashPassword } = await import('../../src/utils/passwords'));
    ({ signAccessToken } = await import('../../src/utils/tokens'));

    if (mongoose.connection.readyState !== 1) {
      await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 5000 });
    }

    server = createApp().listen(0);
    await new Promise<void>((resolve) => server.once('listening', resolve));
    const address = server.address() as AddressInfo;
    baseUrl = `http://127.0.0.1:${address.port}`;
  });

  beforeEach(async () => {
    await prisma.refreshToken.deleteMany();
    await prisma.passwordResetToken.deleteMany();
    await prisma.patient.deleteMany();
    await prisma.user.deleteMany();
    await mongoose.connection.collection('audit_logs').deleteMany({});
  });

  afterAll(async () => {
    await new Promise<void>((resolve, reject) => {
      server.close((err) => (err ? reject(err) : resolve()));
    });
    await prisma.$disconnect();
    await mongoose.disconnect();
  });

  it('rejects deactivating the only active admin', async () => {
    const admin = await createUser('ADMIN', 'admin.only@example.com');

    const response = await request(`/api/v1/users/${admin.user.id}/status`, {
      method: 'PATCH',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({ isActive: false }),
    });

    expect(response.status).toBe(409);
    await expect(response.json()).resolves.toMatchObject({
      error: { code: 'LAST_ACTIVE_ADMIN' },
    });
    await expect(
      prisma.user.findUnique({ where: { id: admin.user.id } })
    ).resolves.toMatchObject({ isActive: true });
  });

  it('lets one admin deactivate another admin when at least two are active', async () => {
    const actor = await createUser('ADMIN', 'admin.actor@example.com');
    const target = await createUser('ADMIN', 'admin.target@example.com');
    await prisma.refreshToken.create({
      data: {
        userId: target.user.id,
        tokenHash: 'target-refresh-token',
        expiresAt: new Date(Date.now() + 60 * 60 * 1000),
      },
    });

    const response = await request(`/api/v1/users/${target.user.id}/status`, {
      method: 'PATCH',
      headers: { authorization: `Bearer ${actor.token}` },
      body: JSON.stringify({ isActive: false }),
    });

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toMatchObject({
      id: target.user.id,
      isActive: false,
    });

    await expect(
      prisma.refreshToken.findUnique({ where: { tokenHash: 'target-refresh-token' } })
    ).resolves.toMatchObject({ revokedAt: expect.any(Date) });

    const audit = await mongoose.connection.collection('audit_logs').findOne({
      action: 'USER_DEACTIVATED',
      actorId: actor.user.id,
      entityType: 'USER',
      entityId: target.user.id,
    });
    expect(audit).toMatchObject({
      oldValues: { isActive: true },
      newValues: { isActive: false },
    });
  });
});
