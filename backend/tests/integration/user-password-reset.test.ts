import http from 'node:http';
import type { AddressInfo } from 'node:net';
import mongoose from 'mongoose';
import type { PrismaClient, Role } from '@prisma/client';
import type { createApp as createAppFn } from '../../src/app';
import type { hashPassword as hashPasswordFn } from '../../src/utils/passwords';
import type { signAccessToken as signAccessTokenFn } from '../../src/utils/tokens';
import type * as emailServiceModule from '../../src/modules/email/email.service';

const password = 'StaffPass123!';

let createApp: typeof createAppFn;
let prisma: PrismaClient;
let hashPassword: typeof hashPasswordFn;
let signAccessToken: typeof signAccessTokenFn;
let emailService: typeof emailServiceModule;
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

async function createUser(role: Role, email: string, fullName = `${role} User`) {
  const user = await prisma.user.create({
    data: {
      email,
      fullName,
      passwordHash: await hashPassword(password),
      role,
    },
  });

  return {
    user,
    token: signAccessToken({ sub: user.id, role: user.role }),
  };
}

describe('POST /api/v1/users/:id/trigger-reset', () => {
  beforeAll(async () => {
    process.env.MONGODB_URI ??=
      'mongodb://bahya:bahya@localhost:27017/bahya_activity?authSource=admin';

    ({ createApp } = await import('../../src/app'));
    ({ prisma } = await import('../../src/config/prisma'));
    ({ hashPassword } = await import('../../src/utils/passwords'));
    ({ signAccessToken } = await import('../../src/utils/tokens'));
    emailService = await import('../../src/modules/email/email.service');

    if (mongoose.connection.readyState !== 1) {
      await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 5000 });
    }

    server = createApp().listen(0);
    await new Promise<void>((resolve) => server.once('listening', resolve));
    const address = server.address() as AddressInfo;
    baseUrl = `http://127.0.0.1:${address.port}`;
  });

  beforeEach(async () => {
    jest.spyOn(emailService, 'sendEmail').mockResolvedValue(undefined);
    await prisma.refreshToken.deleteMany();
    await prisma.passwordResetToken.deleteMany();
    await prisma.patient.deleteMany();
    await prisma.user.deleteMany();
    await mongoose.connection.collection('audit_logs').deleteMany({});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  afterAll(async () => {
    await new Promise<void>((resolve, reject) => {
      server.close((err) => (err ? reject(err) : resolve()));
    });
    await prisma.$disconnect();
    await mongoose.disconnect();
  });

  it('lets an admin create a reset token, send email, and write audit', async () => {
    const admin = await createUser('ADMIN', 'admin.reset@example.com', 'Admin User');
    const target = await createUser('DOCTOR', 'doctor.reset@example.com', 'Dr. Reset');

    const response = await request(`/api/v1/users/${target.user.id}/trigger-reset`, {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
    });

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({
      message: "Password reset link sent to user's email",
    });

    const tokens = await prisma.passwordResetToken.findMany({
      where: { userId: target.user.id },
    });
    expect(tokens).toHaveLength(1);
    expect(tokens[0]).toMatchObject({
      usedAt: null,
      tokenHash: expect.any(String),
    });
    expect(tokens[0].expiresAt.getTime()).toBeGreaterThan(Date.now());

    expect(emailService.sendEmail).toHaveBeenCalledWith(
      target.user.email,
      expect.any(String),
      expect.stringContaining('/reset-password?token=')
    );
    expect(emailService.sendEmail).toHaveBeenCalledWith(
      target.user.email,
      expect.any(String),
      expect.not.stringContaining(tokens[0].tokenHash)
    );

    const audit = await mongoose.connection.collection('audit_logs').findOne({
      action: 'PASSWORD_RESET_BY_ADMIN',
      actorId: admin.user.id,
      entityType: 'USER',
      entityId: target.user.id,
    });
    expect(audit).toMatchObject({
      newValues: { email: target.user.email },
    });
  });

  it('lets an admin list, view, and patch users without exposing password hashes', async () => {
    const admin = await createUser('ADMIN', 'admin.manage@example.com', 'Admin User');
    const target = await createUser('DOCTOR', 'doctor.manage@example.com', 'Dr. Manage');

    const listResponse = await request('/api/v1/users?q=manage&role=DOCTOR&page=1&pageSize=10', {
      headers: { authorization: `Bearer ${admin.token}` },
    });

    expect(listResponse.status).toBe(200);
    const listBody = (await listResponse.json()) as {
      data: Array<{ id: string; passwordHash?: string }>;
      total: number;
    };
    expect(listBody.total).toBe(1);
    expect(listBody.data[0]).toMatchObject({
      id: target.user.id,
      email: target.user.email,
      fullName: 'Dr. Manage',
      role: 'DOCTOR',
      isActive: true,
    });
    expect(listBody.data[0].passwordHash).toBeUndefined();

    const getResponse = await request(`/api/v1/users/${target.user.id}`, {
      headers: { authorization: `Bearer ${admin.token}` },
    });
    expect(getResponse.status).toBe(200);
    await expect(getResponse.json()).resolves.toMatchObject({
      id: target.user.id,
      email: target.user.email,
      fullName: 'Dr. Manage',
    });

    const patchResponse = await request(`/api/v1/users/${target.user.id}`, {
      method: 'PATCH',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({ fullName: 'Dr. Managed' }),
    });
    expect(patchResponse.status).toBe(200);
    await expect(patchResponse.json()).resolves.toMatchObject({
      id: target.user.id,
      fullName: 'Dr. Managed',
    });

    const audit = await mongoose.connection.collection('audit_logs').findOne({
      action: 'USER_PROFILE_UPDATED',
      actorId: admin.user.id,
      entityId: target.user.id,
    });
    expect(audit).toMatchObject({
      oldValues: { fullName: 'Dr. Manage' },
      newValues: { fullName: 'Dr. Managed' },
    });

    const rejectedPatch = await request(`/api/v1/users/${target.user.id}`, {
      method: 'PATCH',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({ email: 'changed@example.com' }),
    });
    expect(rejectedPatch.status).toBe(400);
  });

  it('invalidates previous reset tokens for the target user', async () => {
    const admin = await createUser('ADMIN', 'admin.reset-previous@example.com');
    const target = await createUser('PATIENT', 'patient.reset-previous@example.com');

    await prisma.passwordResetToken.create({
      data: {
        userId: target.user.id,
        tokenHash: 'previous-token-hash',
        expiresAt: new Date(Date.now() + 60 * 60 * 1000),
      },
    });

    const response = await request(`/api/v1/users/${target.user.id}/trigger-reset`, {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
    });

    expect(response.status).toBe(200);

    const previous = await prisma.passwordResetToken.findUnique({
      where: { tokenHash: 'previous-token-hash' },
    });
    expect(previous?.usedAt).toBeInstanceOf(Date);
    await expect(
      prisma.passwordResetToken.count({
        where: { userId: target.user.id, usedAt: null },
      })
    ).resolves.toBe(1);
  });

  it('rejects non-admin users', async () => {
    const actor = await createUser('DOCTOR', 'doctor.reset-forbidden@example.com');
    const target = await createUser('PATIENT', 'patient.reset-forbidden@example.com');

    const response = await request(`/api/v1/users/${target.user.id}/trigger-reset`, {
      method: 'POST',
      headers: { authorization: `Bearer ${actor.token}` },
    });

    expect(response.status).toBe(403);
    await expect(prisma.passwordResetToken.count()).resolves.toBe(0);
    expect(emailService.sendEmail).not.toHaveBeenCalled();
  });
});
