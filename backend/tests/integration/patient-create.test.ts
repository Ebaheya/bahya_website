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

const validPatientBody = {
  fullName: 'Sara Ali',
  email: 'sara.patient-create@example.com',
  password: patientPassword,
  phone: '+201234567890',
  dateOfBirth: '1995-04-12',
  gender: 'FEMALE',
  address: '123 Giza St',
  emergencyContactName: 'Mother',
  emergencyContactPhone: '+201112223334',
  medicalHistory: {
    allergies: ['penicillin'],
    conditions: ['anxiety'],
    notes: 'Family history of depression',
  },
  socialStatus: {
    maritalStatus: 'SINGLE',
    familySupport: 'MEDIUM',
  },
  financials: {
    incomeBracket: 'LOW',
  },
};

describe('POST /api/v1/patients', () => {
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

  it('creates User and Patient rows, writes audit, and allows patient login', async () => {
    const admin = await createStaff('ADMIN', 'admin.patient-create@example.com');

    const response = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify(validPatientBody),
    });

    expect(response.status).toBe(201);
    const body = (await response.json()) as { id: string; passwordHash?: string };
    expect(body).toMatchObject({
      fullName: validPatientBody.fullName,
      email: validPatientBody.email,
      phone: validPatientBody.phone,
      gender: validPatientBody.gender,
      role: 'PATIENT',
      isActive: true,
      financials: validPatientBody.financials,
    });
    expect(body.passwordHash).toBeUndefined();

    const user = await prisma.user.findUnique({
      where: { email: validPatientBody.email },
      include: { patient: true },
    });
    expect(user).toMatchObject({
      email: validPatientBody.email,
      fullName: validPatientBody.fullName,
      role: 'PATIENT',
      isActive: true,
    });
    expect(user?.patient).toMatchObject({
      id: body.id,
      phone: validPatientBody.phone,
      gender: validPatientBody.gender,
    });

    const audit = await mongoose.connection.collection('audit_logs').findOne({
      action: 'PATIENT_CREATED',
      entityType: 'PATIENT',
      entityId: body.id,
    });
    expect(audit).toMatchObject({
      actorId: admin.user.id,
      newValues: {
        email: validPatientBody.email,
        role: 'PATIENT',
        fullName: validPatientBody.fullName,
      },
    });

    const login = await request('/api/v1/auth/login', {
      method: 'POST',
      body: JSON.stringify({
        email: validPatientBody.email,
        password: patientPassword,
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

  it('rejects duplicate email without creating an orphaned patient row', async () => {
    const admin = await createStaff('ADMIN', 'admin.duplicate@example.com');

    await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify(validPatientBody),
    });

    const duplicateResponse = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({
        ...validPatientBody,
        phone: '+201999999999',
      }),
    });

    expect(duplicateResponse.status).toBe(409);
    await expect(duplicateResponse.json()).resolves.toMatchObject({
      error: { code: 'CONFLICT' },
    });

    await expect(prisma.user.count({ where: { email: validPatientBody.email } })).resolves.toBe(1);
    await expect(prisma.patient.count()).resolves.toBe(1);
    await expect(prisma.patient.findFirst({ where: { phone: '+201999999999' } })).resolves.toBeNull();
  });

  it.each([
    ['DOCTOR' as Role, 'doctor.patient-create@example.com'],
    ['VOLUNTEER' as Role, 'volunteer.patient-create@example.com'],
  ])('rejects %s role', async (role, email) => {
    const actor = await createStaff(role, email);

    const response = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${actor.token}` },
      body: JSON.stringify({
        ...validPatientBody,
        email: `${role.toLowerCase()}.blocked@example.com`,
      }),
    });

    expect(response.status).toBe(403);
    await expect(prisma.patient.count()).resolves.toBe(0);
  });

  it('returns validation errors for invalid payloads', async () => {
    const admin = await createStaff('ADMIN', 'admin.validation@example.com');

    const response = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({
        ...validPatientBody,
        email: 'not-an-email',
        phone: 'bad',
        medicalHistory: { unexpected: true },
      }),
    });

    expect(response.status).toBe(400);
    await expect(response.json()).resolves.toMatchObject({
      error: { code: 'VALIDATION_ERROR' },
    });
    await expect(prisma.patient.count()).resolves.toBe(0);
  });

  it('lets patients read only their own profile and strips financials for volunteers', async () => {
    const admin = await createStaff('ADMIN', 'admin.patient-self-read@example.com');
    const volunteer = await createStaff('VOLUNTEER', 'volunteer.patient-self-read@example.com');

    const firstResponse = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({
        ...validPatientBody,
        email: 'first.self-read@example.com',
      }),
    });
    expect(firstResponse.status).toBe(201);
    const firstPatient = (await firstResponse.json()) as {
      id: string;
      userId: string;
      financials?: unknown;
    };

    const secondResponse = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({
        ...validPatientBody,
        email: 'second.self-read@example.com',
        phone: '+201222222222',
      }),
    });
    expect(secondResponse.status).toBe(201);
    const secondPatient = (await secondResponse.json()) as { id: string };

    const patientToken = signAccessToken({
      sub: firstPatient.userId,
      role: 'PATIENT',
    });

    const ownProfile = await request(`/api/v1/patients/${firstPatient.id}`, {
      headers: { authorization: `Bearer ${patientToken}` },
    });
    expect(ownProfile.status).toBe(200);
    await expect(ownProfile.json()).resolves.toMatchObject({
      id: firstPatient.id,
      userId: firstPatient.userId,
      email: 'first.self-read@example.com',
      role: 'PATIENT',
    });

    const otherProfile = await request(`/api/v1/patients/${secondPatient.id}`, {
      headers: { authorization: `Bearer ${patientToken}` },
    });
    expect(otherProfile.status).toBe(403);

    const volunteerProfile = await request(`/api/v1/patients/${firstPatient.id}`, {
      headers: { authorization: `Bearer ${volunteer.token}` },
    });
    expect(volunteerProfile.status).toBe(200);
    const volunteerBody = (await volunteerProfile.json()) as { financials?: unknown };
    expect(volunteerBody.financials).toBeUndefined();

    await prisma.user.update({
      where: { id: firstPatient.userId },
      data: { isActive: false },
    });
    const inactiveProfile = await request(`/api/v1/patients/${firstPatient.id}`, {
      headers: { authorization: `Bearer ${patientToken}` },
    });
    expect(inactiveProfile.status).toBe(401);
  });

  it('lets staff search/list patients and hides financials from volunteers', async () => {
    const admin = await createStaff('ADMIN', 'admin.patient-list@example.com');
    const doctor = await createStaff('DOCTOR', 'doctor.patient-list@example.com');
    const volunteer = await createStaff('VOLUNTEER', 'volunteer.patient-list@example.com');

    const names = ['Sara Ali', 'Sara Hassan', 'Mona Ali', 'Nour Saleh', 'Laila Omar'];
    const createdPatients: Array<{ id: string; userId: string }> = [];

    for (const [index, fullName] of names.entries()) {
      const response = await request('/api/v1/patients', {
        method: 'POST',
        headers: { authorization: `Bearer ${admin.token}` },
        body: JSON.stringify({
          ...validPatientBody,
          fullName,
          email: `patient-list-${index}@example.com`,
          phone: `+20155555555${index}`,
        }),
      });
      expect(response.status).toBe(201);
      createdPatients.push((await response.json()) as { id: string; userId: string });
    }

    const listResponse = await request('/api/v1/patients?q=sara&page=1&pageSize=20', {
      headers: { authorization: `Bearer ${doctor.token}` },
    });

    expect(listResponse.status).toBe(200);
    const listBody = (await listResponse.json()) as {
      data: Array<{ fullName: string; financials?: unknown }>;
      page: number;
      pageSize: number;
      total: number;
    };
    expect(listBody).toMatchObject({ page: 1, pageSize: 20, total: 2 });
    expect(listBody.data.map((patient) => patient.fullName).sort()).toEqual([
      'Sara Ali',
      'Sara Hassan',
    ]);
    expect(listBody.data[0].financials).toBeDefined();

    const phoneResponse = await request('/api/v1/patients?phone=%2B201555555552', {
      headers: { authorization: `Bearer ${admin.token}` },
    });
    expect(phoneResponse.status).toBe(200);
    await expect(phoneResponse.json()).resolves.toMatchObject({
      total: 1,
      data: [{ fullName: 'Mona Ali' }],
    });

    const volunteerResponse = await request('/api/v1/patients?q=sara&page=1&pageSize=20', {
      headers: { authorization: `Bearer ${volunteer.token}` },
    });
    expect(volunteerResponse.status).toBe(200);
    const volunteerBody = (await volunteerResponse.json()) as {
      data: Array<{ financials?: unknown }>;
    };
    expect(volunteerBody.data).toHaveLength(2);
    expect(volunteerBody.data.every((patient) => patient.financials === undefined)).toBe(true);

    const patientToken = signAccessToken({
      sub: createdPatients[0].userId,
      role: 'PATIENT',
    });
    const patientListResponse = await request('/api/v1/patients', {
      headers: { authorization: `Bearer ${patientToken}` },
    });
    expect(patientListResponse.status).toBe(403);
  });

  it('lets admin/call center patch demographics and shallow-merge JSONB blocks', async () => {
    const admin = await createStaff('ADMIN', 'admin.patient-patch@example.com');
    const callCenter = await createStaff('CALL_CENTER', 'cc.patient-patch@example.com');
    const doctor = await createStaff('DOCTOR', 'doctor.patient-patch@example.com');

    const createResponse = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({
        ...validPatientBody,
        email: 'patchable.patient@example.com',
      }),
    });
    expect(createResponse.status).toBe(201);
    const patient = (await createResponse.json()) as { id: string };

    const updateResponse = await request(`/api/v1/patients/${patient.id}`, {
      method: 'PATCH',
      headers: { authorization: `Bearer ${callCenter.token}` },
      body: JSON.stringify({
        address: '456 Cairo Ave',
        medicalHistory: {
          allergies: ['ibuprofen'],
          notes: null,
        },
        socialStatus: {
          maritalStatus: 'MARRIED',
        },
      }),
    });
    expect(updateResponse.status).toBe(200);
    const updated = (await updateResponse.json()) as {
      address: string;
      medicalHistory: Record<string, unknown>;
      socialStatus: Record<string, unknown>;
      financials: Record<string, unknown>;
    };
    expect(updated.address).toBe('456 Cairo Ave');
    expect(updated.medicalHistory).toEqual({
      allergies: ['ibuprofen'],
      conditions: ['anxiety'],
    });
    expect(updated.socialStatus).toEqual({
      maritalStatus: 'MARRIED',
      familySupport: 'MEDIUM',
    });
    expect(updated.financials).toEqual({ incomeBracket: 'LOW' });

    const audit = await mongoose.connection.collection('audit_logs').findOne({
      action: 'PATIENT_UPDATED',
      entityType: 'PATIENT',
      entityId: patient.id,
    });
    expect(audit).toMatchObject({
      actorId: callCenter.user.id,
      oldValues: {
        address: '123 Giza St',
        medicalHistory: validPatientBody.medicalHistory,
        socialStatus: validPatientBody.socialStatus,
      },
      newValues: {
        address: '456 Cairo Ave',
        medicalHistory: {
          allergies: ['ibuprofen'],
          conditions: ['anxiety'],
        },
        socialStatus: {
          maritalStatus: 'MARRIED',
          familySupport: 'MEDIUM',
        },
      },
    });

    const unknownJsonKey = await request(`/api/v1/patients/${patient.id}`, {
      method: 'PATCH',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({ medicalHistory: { unexpected: true } }),
    });
    expect(unknownJsonKey.status).toBe(400);

    for (const forbiddenBody of [{ email: 'new@example.com' }, { passwordHash: 'hash' }]) {
      const forbiddenResponse = await request(`/api/v1/patients/${patient.id}`, {
        method: 'PATCH',
        headers: { authorization: `Bearer ${admin.token}` },
        body: JSON.stringify(forbiddenBody),
      });
      expect(forbiddenResponse.status).toBe(400);
    }

    const blockedDoctor = await request(`/api/v1/patients/${patient.id}`, {
      method: 'PATCH',
      headers: { authorization: `Bearer ${doctor.token}` },
      body: JSON.stringify({ address: '789 Alexandria Rd' }),
    });
    expect(blockedDoctor.status).toBe(403);

    const auditCountBeforeNoop = await mongoose.connection
      .collection('audit_logs')
      .countDocuments({ action: 'PATIENT_UPDATED', entityId: patient.id });
    expect(auditCountBeforeNoop).toBe(1);

    const noopResponse = await request(`/api/v1/patients/${patient.id}`, {
      method: 'PATCH',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({ address: '456 Cairo Ave' }),
    });
    expect(noopResponse.status).toBe(200);
    await expect(noopResponse.json()).resolves.toMatchObject({
      address: '456 Cairo Ave',
    });

    const auditCountAfterNoop = await mongoose.connection
      .collection('audit_logs')
      .countDocuments({ action: 'PATIENT_UPDATED', entityId: patient.id });
    expect(auditCountAfterNoop).toBe(1);
  });

  it('returns an empty timeline, enforces RBAC, and fails closed when Mongo is down', async () => {
    const admin = await createStaff('ADMIN', 'admin.patient-timeline@example.com');
    const doctor = await createStaff('DOCTOR', 'doctor.patient-timeline@example.com');
    const callCenter = await createStaff('CALL_CENTER', 'cc.patient-timeline@example.com');

    const createResponse = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({
        ...validPatientBody,
        email: 'timeline.patient@example.com',
      }),
    });
    expect(createResponse.status).toBe(201);
    const patient = (await createResponse.json()) as { id: string; userId: string };

    const adminTimeline = await request(
      `/api/v1/patients/${patient.id}/timeline?page=1&pageSize=5`,
      { headers: { authorization: `Bearer ${admin.token}` } }
    );
    expect(adminTimeline.status).toBe(200);
    await expect(adminTimeline.json()).resolves.toEqual({
      data: [],
      page: 1,
      pageSize: 5,
      total: 0,
    });

    const doctorTimeline = await request(`/api/v1/patients/${patient.id}/timeline`, {
      headers: { authorization: `Bearer ${doctor.token}` },
    });
    expect(doctorTimeline.status).toBe(200);
    await expect(doctorTimeline.json()).resolves.toMatchObject({
      data: [],
      page: 1,
      pageSize: 20,
      total: 0,
    });

    const blockedCallCenter = await request(`/api/v1/patients/${patient.id}/timeline`, {
      headers: { authorization: `Bearer ${callCenter.token}` },
    });
    expect(blockedCallCenter.status).toBe(403);

    const patientToken = signAccessToken({ sub: patient.userId, role: 'PATIENT' });
    const blockedPatient = await request(`/api/v1/patients/${patient.id}/timeline`, {
      headers: { authorization: `Bearer ${patientToken}` },
    });
    expect(blockedPatient.status).toBe(403);

    const missingTimeline = await request(
      '/api/v1/patients/00000000-0000-4000-8000-000000000000/timeline',
      { headers: { authorization: `Bearer ${doctor.token}` } }
    );
    expect(missingTimeline.status).toBe(404);

    await mongoose.disconnect();
    try {
      const mongoDownTimeline = await request(`/api/v1/patients/${patient.id}/timeline`, {
        headers: { authorization: `Bearer ${doctor.token}` },
      });
      expect(mongoDownTimeline.status).toBe(503);
      await expect(mongoDownTimeline.json()).resolves.toMatchObject({
        error: { code: 'DEPENDENCY_FAILURE' },
      });
    } finally {
      await mongoose.connect(process.env.MONGODB_URI as string, {
        serverSelectionTimeoutMS: 5000,
      });
    }
  });
});
