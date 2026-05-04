import http from 'node:http';
import type { AddressInfo } from 'node:net';
import mongoose from 'mongoose';
import type { PrismaClient, Role } from '@prisma/client';
import type { createApp as createAppFn } from '../../src/app';
import type { hashPassword as hashPasswordFn, verifyPassword as verifyPasswordFn } from '../../src/utils/passwords';
import type { signAccessToken as signAccessTokenFn } from '../../src/utils/tokens';

const oldPassword = 'OldPass123!';
const newPassword = 'NewPass123!';

let createApp: typeof createAppFn;
let prisma: PrismaClient;
let hashPassword: typeof hashPasswordFn;
let verifyPassword: typeof verifyPasswordFn;
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
      passwordHash: await hashPassword(oldPassword),
      role,
    },
  });

  return {
    user,
    token: signAccessToken({ sub: user.id, role: user.role }),
  };
}

describe('PATCH /api/v1/auth/change-password', () => {
  beforeAll(async () => {
    process.env.MONGODB_URI ??=
      'mongodb://bahya:bahya@localhost:27017/bahya_activity?authSource=admin';

    ({ createApp } = await import('../../src/app'));
    ({ prisma } = await import('../../src/config/prisma'));
    ({ hashPassword, verifyPassword } = await import('../../src/utils/passwords'));
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

  it('changes the password, revokes refresh tokens, writes audit, and supports login with the new password', async () => {
    const actor = await createUser('PATIENT', 'patient.change-password@example.com');
    await prisma.refreshToken.createMany({
      data: [
        {
          userId: actor.user.id,
          tokenHash: 'active-refresh-token',
          expiresAt: new Date(Date.now() + 60 * 60 * 1000),
        },
        {
          userId: actor.user.id,
          tokenHash: 'already-revoked-refresh-token',
          expiresAt: new Date(Date.now() + 60 * 60 * 1000),
          revokedAt: new Date(Date.now() - 1000),
        },
      ],
    });

    const response = await request('/api/v1/auth/change-password', {
      method: 'PATCH',
      headers: { authorization: `Bearer ${actor.token}` },
      body: JSON.stringify({
        currentPassword: oldPassword,
        newPassword,
      }),
    });

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({
      message: 'Password changed successfully',
    });

    const updated = await prisma.user.findUnique({ where: { id: actor.user.id } });
    expect(updated).not.toBeNull();
    await expect(verifyPassword(newPassword, updated!.passwordHash)).resolves.toBe(true);

    await expect(
      prisma.refreshToken.findUnique({ where: { tokenHash: 'active-refresh-token' } })
    ).resolves.toMatchObject({ revokedAt: expect.any(Date) });

    const audit = await mongoose.connection.collection('audit_logs').findOne({
      action: 'PASSWORD_CHANGED',
      actorId: actor.user.id,
      entityType: 'USER',
      entityId: actor.user.id,
    });
    expect(audit).toBeTruthy();
    expect(audit?.oldValues).toBeNull();
    expect(audit?.newValues).toBeNull();

    const login = await request('/api/v1/auth/login', {
      method: 'POST',
      body: JSON.stringify({
        email: actor.user.email,
        password: newPassword,
      }),
    });
    expect(login.status).toBe(200);
    await expect(login.json()).resolves.toEqual(
      expect.objectContaining({
        accessToken: expect.any(String),
        refreshToken: expect.any(String),
      })
    );
  });

  it('rejects a wrong current password', async () => {
    const actor = await createUser('DOCTOR', 'doctor.change-password@example.com');

    const response = await request('/api/v1/auth/change-password', {
      method: 'PATCH',
      headers: { authorization: `Bearer ${actor.token}` },
      body: JSON.stringify({
        currentPassword: 'WrongPass123!',
        newPassword,
      }),
    });

    expect(response.status).toBe(401);
    await expect(response.json()).resolves.toMatchObject({
      error: { code: 'INVALID_CREDENTIALS' },
    });
    await expect(prisma.user.findUnique({ where: { id: actor.user.id } })).resolves.toMatchObject({
      passwordHash: actor.user.passwordHash,
    });
  });

  it('validates the new password', async () => {
    const actor = await createUser('ADMIN', 'admin.change-password@example.com');

    const response = await request('/api/v1/auth/change-password', {
      method: 'PATCH',
      headers: { authorization: `Bearer ${actor.token}` },
      body: JSON.stringify({
        currentPassword: oldPassword,
        newPassword: 'short',
      }),
    });

    expect(response.status).toBe(400);
    await expect(response.json()).resolves.toMatchObject({
      error: { code: 'VALIDATION_ERROR' },
    });
  });
});
