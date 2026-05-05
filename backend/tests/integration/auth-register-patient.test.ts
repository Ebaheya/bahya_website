import http from 'node:http';
import type { AddressInfo } from 'node:net';
import mongoose from 'mongoose';
import type { PrismaClient, Role } from '@prisma/client';
import type { createApp as createAppFn } from '../../src/app';
import type { hashPassword as hashPasswordFn } from '../../src/utils/passwords';
import type { signAccessToken as signAccessTokenFn } from '../../src/utils/tokens';

const staffPassword = 'StaffPass123!';
const patientPassword = 'PatientPass123!';

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

async function createStaff(role: Role, email: string) {
  const user = await prisma.user.create({
    data: {
      email,
      fullName: `${role} User`,
      passwordHash: await hashPassword(staffPassword),
      role,
    },
  });

  return {
    user,
    token: signAccessToken({ sub: user.id, role: user.role }),
  };
}

const validBody = {
  fullName: 'Layla Hassan',
  email: 'layla.register-patient@example.com',
  password: patientPassword,
  phone: '+201234567899',
  dateOfBirth: '1992-08-21',
  gender: 'FEMALE',
};

describe('POST /api/v1/auth/register-patient', () => {
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

  it('creates linked User + Patient atomically and logs PATIENT_CREATED', async () => {
    const admin = await createStaff('ADMIN', 'admin.register-patient@example.com');

    const response = await request('/api/v1/auth/register-patient', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify(validBody),
    });

    expect(response.status).toBe(201);
    const body = (await response.json()) as { id: string; userId: string; passwordHash?: string };
    expect(body).toMatchObject({
      fullName: validBody.fullName,
      email: validBody.email,
      phone: validBody.phone,
      gender: validBody.gender,
      role: 'PATIENT',
      isActive: true,
    });
    expect(body.passwordHash).toBeUndefined();

    const user = await prisma.user.findUnique({
      where: { email: validBody.email },
      include: { patient: true },
    });
    expect(user?.role).toBe('PATIENT');
    expect(user?.patient).toMatchObject({
      id: body.id,
      phone: validBody.phone,
    });

    const audit = await mongoose.connection.collection('audit_logs').findOne({
      action: 'PATIENT_CREATED',
      entityType: 'PATIENT',
      entityId: body.id,
    });
    expect(audit).toMatchObject({
      actorId: admin.user.id,
      newValues: { email: validBody.email, role: 'PATIENT' },
    });

    const login = await request('/api/v1/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email: validBody.email, password: patientPassword }),
    });
    expect(login.status).toBe(200);
  });

  // Regression guard for the original PR #15 bug: a User with role=PATIENT must
  // never exist without a linked Patient row. If the second create fails on
  // unique-email, the transaction must roll back the User insert too.
  it('rejects duplicate email and leaves zero orphaned User rows', async () => {
    const admin = await createStaff('ADMIN', 'admin.dup-register-patient@example.com');

    const first = await request('/api/v1/auth/register-patient', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify(validBody),
    });
    expect(first.status).toBe(201);

    const dup = await request('/api/v1/auth/register-patient', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({ ...validBody, phone: '+201888888888' }),
    });
    expect(dup.status).toBe(409);
    await expect(dup.json()).resolves.toMatchObject({ error: { code: 'CONFLICT' } });

    await expect(prisma.user.count({ where: { email: validBody.email } })).resolves.toBe(1);
    await expect(prisma.patient.count()).resolves.toBe(1);
    const orphans = await prisma.user.findMany({
      where: { role: 'PATIENT', patient: null },
    });
    expect(orphans).toEqual([]);
  });

  it('rejects payloads missing the required Patient phone field', async () => {
    const admin = await createStaff('ADMIN', 'admin.missing-phone@example.com');

    const { phone: _phone, ...bodyWithoutPhone } = validBody;
    const response = await request('/api/v1/auth/register-patient', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify(bodyWithoutPhone),
    });

    expect(response.status).toBe(400);
    await expect(response.json()).resolves.toMatchObject({
      error: { code: 'VALIDATION_ERROR' },
    });
    await expect(prisma.user.count()).resolves.toBe(1); // only the admin
    await expect(prisma.patient.count()).resolves.toBe(0);
  });

  it.each([
    ['DOCTOR' as Role, 'doctor.register-patient@example.com'],
    ['VOLUNTEER' as Role, 'volunteer.register-patient@example.com'],
  ])('rejects %s role with 403 and creates no records', async (role, email) => {
    const actor = await createStaff(role, email);

    const response = await request('/api/v1/auth/register-patient', {
      method: 'POST',
      headers: { authorization: `Bearer ${actor.token}` },
      body: JSON.stringify({ ...validBody, email: `${role.toLowerCase()}.blocked@example.com` }),
    });

    expect(response.status).toBe(403);
    await expect(prisma.patient.count()).resolves.toBe(0);
  });

  it('rejects unauthenticated requests with 401', async () => {
    const response = await request('/api/v1/auth/register-patient', {
      method: 'POST',
      body: JSON.stringify(validBody),
    });

    expect(response.status).toBe(401);
    await expect(prisma.patient.count()).resolves.toBe(0);
  });
});
