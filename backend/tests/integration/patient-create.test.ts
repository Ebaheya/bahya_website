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
  crn: 'PT-2504',
  phone: '+201234567890',
  dateOfBirth: '1995-04-12',
  gender: 'FEMALE',
  address: '123 Giza St',
  emergencyContactName: 'Mother',
  emergencyContactPhone: '+201112223334',
  medicalHistory: {
    allergies: ['penicillin'],
    conditions: ['anxiety'],
    comorbidities: ['Diabetes', 'Hypertension'],
    drugs: ['Tamoxifen 20mg daily', 'Calcium + Vitamin D'],
    familyHistory: 'Yes - breast cancer',
    notes: 'Family history of depression',
  },
  socialStatus: {
    maritalStatus: 'SINGLE',
    familySupport: 'MEDIUM',
  },
  financials: {
    incomeBracket: 'LOW',
  },
  bmi: 27.4,
  menopausalStatus: 'POST_MENOPAUSAL',
  dateOfDiagnosis: '2024-11-10',
  stageAtDiagnosis: 'STAGE_II',
  diseaseStatus: 'ACTIVE_TREATMENT',
  tumorBiology: 'LUMINAL_A',
  surgery: 'BREAST_CONSERVATIVE',
  chemotherapy: 'ADJUVANT',
  radiotherapy: true,
  hormonalTherapy: true,
  targetedTherapy: true,
  immunotherapy: true,
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
      crn: validPatientBody.crn,
      phone: validPatientBody.phone,
      gender: validPatientBody.gender,
      role: 'PATIENT',
      isActive: true,
      financials: validPatientBody.financials,
      medicalHistory: validPatientBody.medicalHistory,
      bmi: validPatientBody.bmi,
      menopausalStatus: validPatientBody.menopausalStatus,
      stageAtDiagnosis: validPatientBody.stageAtDiagnosis,
      diseaseStatus: validPatientBody.diseaseStatus,
      tumorBiology: validPatientBody.tumorBiology,
      surgery: validPatientBody.surgery,
      chemotherapy: validPatientBody.chemotherapy,
      radiotherapy: true,
      hormonalTherapy: true,
      targetedTherapy: true,
      immunotherapy: true,
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
        crn: 'PT-0001',
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

  it('rejects a duplicate CRN without creating an orphaned patient row', async () => {
    const admin = await createStaff('ADMIN', 'admin.duplicate-crn@example.com');

    const first = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({
        ...validPatientBody,
        email: 'crn.first@example.com',
      }),
    });
    expect(first.status).toBe(201);

    const duplicate = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({
        ...validPatientBody,
        email: 'crn.second@example.com',
        phone: '+201999999998',
      }),
    });

    expect(duplicate.status).toBe(409);
    await expect(duplicate.json()).resolves.toMatchObject({
      error: { code: 'CONFLICT', message: 'CRN already in use' },
    });

    await expect(prisma.patient.count()).resolves.toBe(1);
    await expect(
      prisma.user.count({ where: { email: 'crn.second@example.com' } })
    ).resolves.toBe(0);
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
        crn: 'PT-1001',
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
        crn: 'PT-1002',
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
    const volunteerBody = (await volunteerProfile.json()) as Record<string, unknown>;
    // Volunteers see basic identity/contact info only.
    expect(volunteerBody).toMatchObject({
      id: firstPatient.id,
      fullName: validPatientBody.fullName,
      crn: 'PT-1001',
      phone: validPatientBody.phone,
    });
    // ...but none of the clinical/sensitive record.
    for (const hidden of [
      'financials',
      'socialStatus',
      'medicalHistory',
      'bmi',
      'diseaseStatus',
      'tumorBiology',
      'surgery',
      'chemotherapy',
      'radiotherapy',
      'hormonalTherapy',
      'targetedTherapy',
      'immunotherapy',
      'stageAtDiagnosis',
      'menopausalStatus',
      'dateOfDiagnosis',
    ]) {
      expect(volunteerBody[hidden]).toBeUndefined();
    }

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
          crn: `PT-20${index}`,
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
      data: Array<{ financials?: unknown; diseaseStatus?: unknown; medicalHistory?: unknown }>;
    };
    expect(volunteerBody.data).toHaveLength(2);
    expect(
      volunteerBody.data.every(
        (patient) =>
          patient.financials === undefined &&
          patient.diseaseStatus === undefined &&
          patient.medicalHistory === undefined
      )
    ).toBe(true);

    // Clinical filters are ignored for volunteers: every patient here is
    // ACTIVE_TREATMENT, so a real NEWLY_DIAGNOSED filter would return 0 — but
    // the volunteer still gets the full match set (filter stripped, no leak).
    const volunteerFiltered = await request(
      '/api/v1/patients?q=sara&diseaseStatus=NEWLY_DIAGNOSED',
      { headers: { authorization: `Bearer ${volunteer.token}` } }
    );
    expect(volunteerFiltered.status).toBe(200);
    await expect(volunteerFiltered.json()).resolves.toMatchObject({ total: 2 });

    const patientToken = signAccessToken({
      sub: createdPatients[0].userId,
      role: 'PATIENT',
    });
    const patientListResponse = await request('/api/v1/patients', {
      headers: { authorization: `Bearer ${patientToken}` },
    });
    expect(patientListResponse.status).toBe(403);
  });

  it('filters the patient list by clinical fields and searches by CRN', async () => {
    const admin = await createStaff('ADMIN', 'admin.clinical-filter@example.com');

    const cases = [
      {
        email: 'clinical-a@example.com',
        crn: 'PT-3001',
        phone: '+201600000001',
        diseaseStatus: 'ACTIVE_TREATMENT',
        tumorBiology: 'LUMINAL_A',
        surgery: 'MASTECTOMY',
        radiotherapy: true,
      },
      {
        email: 'clinical-b@example.com',
        crn: 'PT-3002',
        phone: '+201600000002',
        diseaseStatus: 'FOLLOW_UP',
        tumorBiology: 'TNBC',
        surgery: 'NONE',
        radiotherapy: false,
      },
    ];

    for (const c of cases) {
      const response = await request('/api/v1/patients', {
        method: 'POST',
        headers: { authorization: `Bearer ${admin.token}` },
        body: JSON.stringify({ ...validPatientBody, ...c }),
      });
      expect(response.status).toBe(201);
    }

    const byStatus = await request('/api/v1/patients?diseaseStatus=FOLLOW_UP', {
      headers: { authorization: `Bearer ${admin.token}` },
    });
    expect(byStatus.status).toBe(200);
    await expect(byStatus.json()).resolves.toMatchObject({
      total: 1,
      data: [{ crn: 'PT-3002', tumorBiology: 'TNBC' }],
    });

    const byRadiotherapy = await request('/api/v1/patients?radiotherapy=false', {
      headers: { authorization: `Bearer ${admin.token}` },
    });
    expect(byRadiotherapy.status).toBe(200);
    await expect(byRadiotherapy.json()).resolves.toMatchObject({
      total: 1,
      data: [{ crn: 'PT-3002' }],
    });

    const byCrn = await request('/api/v1/patients?q=PT-3001', {
      headers: { authorization: `Bearer ${admin.token}` },
    });
    expect(byCrn.status).toBe(200);
    await expect(byCrn.json()).resolves.toMatchObject({
      total: 1,
      data: [{ crn: 'PT-3001', surgery: 'MASTECTOMY' }],
    });
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
        surgery: 'MASTECTOMY',
        diseaseStatus: 'FOLLOW_UP',
        medicalHistory: {
          allergies: ['ibuprofen'],
          drugs: ['Letrozole 2.5mg daily'],
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
      surgery: string;
      diseaseStatus: string;
      medicalHistory: Record<string, unknown>;
      socialStatus: Record<string, unknown>;
      financials: Record<string, unknown>;
    };
    expect(updated.address).toBe('456 Cairo Ave');
    expect(updated.surgery).toBe('MASTECTOMY');
    expect(updated.diseaseStatus).toBe('FOLLOW_UP');
    expect(updated.medicalHistory).toEqual({
      allergies: ['ibuprofen'],
      conditions: ['anxiety'],
      comorbidities: ['Diabetes', 'Hypertension'],
      drugs: ['Letrozole 2.5mg daily'],
      familyHistory: 'Yes - breast cancer',
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

  it('lets doctors edit clinical fields but blocks demographics/CRN/financials', async () => {
    const admin = await createStaff('ADMIN', 'admin.doctor-clinical@example.com');
    const doctor = await createStaff('DOCTOR', 'doctor.clinical-edit@example.com');

    const createResponse = await request('/api/v1/patients', {
      method: 'POST',
      headers: { authorization: `Bearer ${admin.token}` },
      body: JSON.stringify({
        ...validPatientBody,
        email: 'doctor-editable.patient@example.com',
      }),
    });
    expect(createResponse.status).toBe(201);
    const patient = (await createResponse.json()) as { id: string };

    // Doctor may edit clinical fields + medical history.
    const clinicalPatch = await request(`/api/v1/patients/${patient.id}`, {
      method: 'PATCH',
      headers: { authorization: `Bearer ${doctor.token}` },
      body: JSON.stringify({
        diseaseStatus: 'RECURRENCE',
        surgery: 'MASTECTOMY',
        bmi: 25.1,
        medicalHistory: { drugs: ['Letrozole 2.5mg daily'] },
      }),
    });
    expect(clinicalPatch.status).toBe(200);
    const updated = (await clinicalPatch.json()) as {
      diseaseStatus: string;
      surgery: string;
      bmi: number;
      medicalHistory: Record<string, unknown>;
    };
    expect(updated.diseaseStatus).toBe('RECURRENCE');
    expect(updated.surgery).toBe('MASTECTOMY');
    expect(updated.bmi).toBe(25.1);
    expect(updated.medicalHistory).toMatchObject({ drugs: ['Letrozole 2.5mg daily'] });

    // Doctor may NOT edit demographics, CRN, or financials.
    for (const forbiddenBody of [
      { address: '789 Alexandria Rd' },
      { crn: 'PT-9999' },
      { financials: { incomeBracket: 'HIGH' } },
    ]) {
      const blocked = await request(`/api/v1/patients/${patient.id}`, {
        method: 'PATCH',
        headers: { authorization: `Bearer ${doctor.token}` },
        body: JSON.stringify(forbiddenBody),
      });
      expect(blocked.status).toBe(403);
    }
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

    const deepTimeline = await request(
      `/api/v1/patients/${patient.id}/timeline?page=1001&pageSize=1`,
      { headers: { authorization: `Bearer ${doctor.token}` } }
    );
    expect(deepTimeline.status).toBe(400);

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
