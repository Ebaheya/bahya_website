import crypto from 'node:crypto';
import http from 'node:http';
import type { AddressInfo } from 'node:net';
import mongoose from 'mongoose';
import type { PrismaClient, Role } from '@prisma/client';
import type { createApp as createAppFn } from '../../src/app';
import type { hashPassword as hashPasswordFn, verifyPassword as verifyPasswordFn } from '../../src/utils/passwords';
import type * as emailServiceModule from '../../src/modules/email/email.service';
import type * as authServiceModule from '../../src/modules/auth/auth.service';

const oldPassword = 'OldPass123!';
const newPassword = 'ResetPass123!';

let createApp: typeof createAppFn;
let prisma: PrismaClient;
let hashPassword: typeof hashPasswordFn;
let verifyPassword: typeof verifyPasswordFn;
let emailService: typeof emailServiceModule;
let forgotPasswordMessage: string;
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

async function createUser(role: Role, email: string, isActive = true) {
  return prisma.user.create({
    data: {
      email,
      fullName: `${role} User`,
      passwordHash: await hashPassword(oldPassword),
      role,
      isActive,
    },
  });
}

function hashResetToken(rawToken: string): string {
  return crypto.createHash('sha256').update(rawToken).digest('hex');
}

function tokenFromEmailHtml(): string {
  const html = (emailService.sendEmail as jest.Mock).mock.calls[0][2] as string;
  const match = html.match(/[?&]token=([a-f0-9]+)/);
  expect(match).not.toBeNull();
  return match![1];
}

describe('POST /api/v1/auth/forgot-password and /reset-password', () => {
  beforeAll(async () => {
    process.env.MONGODB_URI ??=
      'mongodb://bahya:bahya@localhost:27017/bahya_activity?authSource=admin';

    ({ createApp } = await import('../../src/app'));
    ({ prisma } = await import('../../src/config/prisma'));
    ({ hashPassword, verifyPassword } = await import('../../src/utils/passwords'));
    emailService = await import('../../src/modules/email/email.service');
    const authService: typeof authServiceModule = await import('../../src/modules/auth/auth.service');
    forgotPasswordMessage = authService.forgotPasswordMessage;

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

  it('creates a reset token and sends email for a registered active user', async () => {
    const user = await createUser('PATIENT', 'patient.forgot@example.com');
    await prisma.passwordResetToken.create({
      data: {
        userId: user.id,
        tokenHash: 'previous-reset-token',
        expiresAt: new Date(Date.now() + 60 * 60 * 1000),
      },
    });

    const response = await request('/api/v1/auth/forgot-password', {
      method: 'POST',
      body: JSON.stringify({ email: 'PATIENT.FORGOT@EXAMPLE.COM' }),
    });

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({
      message: forgotPasswordMessage,
    });

    const previous = await prisma.passwordResetToken.findUnique({
      where: { tokenHash: 'previous-reset-token' },
    });
    expect(previous?.usedAt).toBeInstanceOf(Date);

    const activeTokens = await prisma.passwordResetToken.findMany({
      where: { userId: user.id, usedAt: null },
    });
    expect(activeTokens).toHaveLength(1);
    expect(activeTokens[0].tokenHash).not.toBe('previous-reset-token');
    expect(activeTokens[0].expiresAt.getTime()).toBeGreaterThan(Date.now());

    expect(emailService.sendEmail).toHaveBeenCalledWith(
      user.email,
      expect.any(String),
      expect.stringContaining('/reset-password?token=')
    );
    expect(emailService.sendEmail).toHaveBeenCalledWith(
      user.email,
      expect.any(String),
      expect.not.stringContaining(activeTokens[0].tokenHash)
    );

    const audit = await mongoose.connection.collection('audit_logs').findOne({
      action: 'PASSWORD_RESET_REQUESTED',
      entityType: 'USER',
      entityId: user.id,
    });
    expect(audit).toMatchObject({
      actorId: null,
      newValues: { email: user.email },
    });
  });

  it('returns the same response for unregistered and inactive users without sending email', async () => {
    await createUser('DOCTOR', 'inactive.forgot@example.com', false);

    for (const email of ['missing.forgot@example.com', 'inactive.forgot@example.com']) {
      const response = await request('/api/v1/auth/forgot-password', {
        method: 'POST',
        body: JSON.stringify({ email }),
      });

      expect(response.status).toBe(200);
      await expect(response.json()).resolves.toEqual({
        message: forgotPasswordMessage,
      });
    }

    expect(emailService.sendEmail).not.toHaveBeenCalled();
    await expect(prisma.passwordResetToken.count()).resolves.toBe(0);
    await expect(
      mongoose.connection.collection('audit_logs').countDocuments({
        action: 'PASSWORD_RESET_REQUESTED',
      })
    ).resolves.toBe(0);
  });

  it('resets password with a valid token, marks token used, revokes tokens, and writes audit', async () => {
    const user = await createUser('PATIENT', 'patient.reset@example.com');
    await prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: 'active-refresh-for-reset',
        expiresAt: new Date(Date.now() + 60 * 60 * 1000),
      },
    });

    const forgot = await request('/api/v1/auth/forgot-password', {
      method: 'POST',
      body: JSON.stringify({ email: user.email }),
    });
    expect(forgot.status).toBe(200);
    const rawToken = tokenFromEmailHtml();
    const tokenHash = hashResetToken(rawToken);

    const response = await request('/api/v1/auth/reset-password', {
      method: 'POST',
      body: JSON.stringify({
        token: rawToken,
        newPassword,
      }),
    });

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({
      message: 'Password has been reset successfully',
    });

    const token = await prisma.passwordResetToken.findUnique({ where: { tokenHash } });
    expect(token?.usedAt).toBeInstanceOf(Date);

    const updatedUser = await prisma.user.findUnique({ where: { id: user.id } });
    expect(updatedUser).not.toBeNull();
    await expect(verifyPassword(newPassword, updatedUser!.passwordHash)).resolves.toBe(true);

    await expect(
      prisma.refreshToken.findUnique({ where: { tokenHash: 'active-refresh-for-reset' } })
    ).resolves.toMatchObject({ revokedAt: expect.any(Date) });

    const audit = await mongoose.connection.collection('audit_logs').findOne({
      action: 'PASSWORD_RESET_COMPLETED',
      actorId: user.id,
      entityType: 'USER',
      entityId: user.id,
    });
    expect(audit).toBeTruthy();

    const login = await request('/api/v1/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email: user.email, password: newPassword }),
    });
    expect(login.status).toBe(200);
  });

  it('rejects expired, used, invalid, and validation-failing reset requests', async () => {
    const user = await createUser('PATIENT', 'patient.bad-reset@example.com');
    const expiredRaw = 'expired-token';
    const usedRaw = 'used-token';

    await prisma.passwordResetToken.createMany({
      data: [
        {
          userId: user.id,
          tokenHash: hashResetToken(expiredRaw),
          expiresAt: new Date(Date.now() - 1000),
        },
        {
          userId: user.id,
          tokenHash: hashResetToken(usedRaw),
          expiresAt: new Date(Date.now() + 60 * 60 * 1000),
          usedAt: new Date(),
        },
      ],
    });

    for (const rawToken of [expiredRaw, usedRaw, 'unknown-token']) {
      const response = await request('/api/v1/auth/reset-password', {
        method: 'POST',
        body: JSON.stringify({ token: rawToken, newPassword }),
      });

      expect(response.status).toBe(400);
      await expect(response.json()).resolves.toMatchObject({
        error: { code: 'INVALID_OR_EXPIRED_TOKEN' },
      });
    }

    const validation = await request('/api/v1/auth/reset-password', {
      method: 'POST',
      body: JSON.stringify({ token: usedRaw, newPassword: 'short' }),
    });

    expect(validation.status).toBe(400);
    await expect(validation.json()).resolves.toMatchObject({
      error: { code: 'VALIDATION_ERROR' },
    });
  });
});
