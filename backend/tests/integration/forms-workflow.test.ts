import http from 'node:http';
import type { AddressInfo } from 'node:net';
import mongoose from 'mongoose';
import type { Patient, PrismaClient, User } from '@prisma/client';
import { seedDefaultForms } from '../../prisma/seed/forms';
import type { createApp as createAppFn } from '../../src/app';
import type { signAccessToken as signAccessTokenFn } from '../../src/utils/tokens';

const emailSuffix = '@forms-acceptance.test';
const customKey = 'ACCEPTANCE_MIXED_FORM';

let createApp: typeof createAppFn;
let prisma: PrismaClient;
let signAccessToken: typeof signAccessTokenFn;
let server: http.Server;
let baseUrl: string;
let doctor: User;
let patientUser: User;
let otherPatientUser: User;
let volunteer: User;
let patient: Patient;
let otherPatient: Patient;

function token(user: User): string {
  return signAccessToken({ sub: user.id, role: user.role });
}

async function request(path: string, accessToken: string, init: RequestInit = {}) {
  return fetch(`${baseUrl}${path}`, {
    ...init,
    headers: {
      authorization: `Bearer ${accessToken}`,
      'content-type': 'application/json',
      ...(init.headers ?? {}),
    },
  });
}

async function cleanupAcceptanceData(): Promise<void> {
  const users = await prisma.user.findMany({
    where: { email: { endsWith: emailSuffix } },
    select: { id: true },
  });
  const userIds = users.map((user) => user.id);
  const patients = await prisma.patient.findMany({
    where: { userId: { in: userIds } },
    select: { id: true },
  });
  const patientIds = patients.map((item) => item.id);

  await prisma.assessment.deleteMany({
    where: { OR: [{ patientId: { in: patientIds } }, { doctorId: { in: userIds } }] },
  });
  await prisma.formSubmission.deleteMany({
    where: { OR: [{ patientId: { in: patientIds } }, { submittedByUserId: { in: userIds } }] },
  });
  await prisma.formAssignment.deleteMany({
    where: {
      OR: [
        { patientId: { in: patientIds } },
        { assignedToUserId: { in: userIds } },
        { assignedById: { in: userIds } },
      ],
    },
  });
  await prisma.formTemplate.deleteMany({ where: { key: customKey } });
  await prisma.patient.deleteMany({ where: { id: { in: patientIds } } });
  await prisma.user.deleteMany({ where: { id: { in: userIds } } });

  await mongoose.connection.collection('notifications').deleteMany({
    patientId: { $in: patientIds },
  });
  await mongoose.connection.collection('audit_logs').deleteMany({
    actorId: { $in: userIds },
  });
}

const customForm = {
  key: customKey,
  name: 'Acceptance mixed form',
  category: 'Acceptance',
  scoringType: 'SUM',
  interpretationMode: 'RANGE',
  questions: [
    {
      order: 1,
      text: 'Single answer',
      type: 'SINGLE_SELECT',
      required: true,
      choices: [
        { order: 1, label: 'No', score: 0 },
        { order: 2, label: 'Yes', score: 1 },
      ],
    },
    {
      order: 2,
      text: 'Multiple answers',
      type: 'MULTI_SELECT',
      required: true,
      choices: [
        { order: 1, label: 'A', score: 0 },
        { order: 2, label: 'B', score: 2 },
      ],
    },
    {
      order: 3,
      text: 'Scale answer',
      type: 'SCALE',
      required: true,
      scaleMin: 0,
      scaleMax: 2,
      scaleStep: 1,
    },
  ],
  scoreRanges: [
    { label: 'Normal', minScore: 0, maxScore: 2 },
    { label: 'Raised', minScore: 3, maxScore: 5 },
  ],
};

describe('dynamic assessment forms acceptance workflow', () => {
  beforeAll(async () => {
    process.env.MONGODB_URI ??=
      'mongodb://bahya:bahya@localhost:27017/bahya_activity?authSource=admin';

    ({ createApp } = await import('../../src/app'));
    ({ prisma } = await import('../../src/config/prisma'));
    ({ signAccessToken } = await import('../../src/utils/tokens'));

    if (mongoose.connection.readyState !== 1) {
      await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 5000 });
    }

    server = createApp().listen(0);
    await new Promise<void>((resolve) => server.once('listening', resolve));
    baseUrl = `http://127.0.0.1:${(server.address() as AddressInfo).port}`;
  });

  beforeEach(async () => {
    await cleanupAcceptanceData();
    await seedDefaultForms(prisma);

    [doctor, patientUser, otherPatientUser, volunteer] = await Promise.all([
      prisma.user.create({
        data: {
          email: `doctor${emailSuffix}`,
          passwordHash: 'not-used',
          fullName: 'Acceptance Doctor',
          role: 'DOCTOR',
        },
      }),
      prisma.user.create({
        data: {
          email: `patient${emailSuffix}`,
          passwordHash: 'not-used',
          fullName: 'Acceptance Patient',
          role: 'PATIENT',
        },
      }),
      prisma.user.create({
        data: {
          email: `other-patient${emailSuffix}`,
          passwordHash: 'not-used',
          fullName: 'Other Acceptance Patient',
          role: 'PATIENT',
        },
      }),
      prisma.user.create({
        data: {
          email: `volunteer${emailSuffix}`,
          passwordHash: 'not-used',
          fullName: 'Acceptance Volunteer',
          role: 'VOLUNTEER',
        },
      }),
    ]);

    [patient, otherPatient] = await Promise.all([
      prisma.patient.create({ data: { userId: patientUser.id, phone: '+201000000001' } }),
      prisma.patient.create({ data: { userId: otherPatientUser.id, phone: '+201000000002' } }),
    ]);
  });

  afterAll(async () => {
    await cleanupAcceptanceData();
    await new Promise<void>((resolve, reject) => {
      server.close((err) => (err ? reject(err) : resolve()));
    });
    await prisma.$disconnect();
    await mongoose.disconnect();
  });

  it('completes seeded authoring, assignment, submission, alert, and doctor review flows', async () => {
    const doctorToken = token(doctor);
    const patientToken = token(patientUser);
    const otherPatientToken = token(otherPatientUser);
    const volunteerToken = token(volunteer);

    const formListResponse = await request('/api/v1/forms?pageSize=100', doctorToken);
    expect(formListResponse.status).toBe(200);
    const formList = (await formListResponse.json()) as {
      data: Array<{ id: string; key: string; scoringType: string }>;
    };
    expect(formList.data.map((form) => form.key)).toEqual(
      expect.arrayContaining(['PHQ9', 'PHQ4', 'DT', 'HADS', 'PTSD', 'QOL', 'MACS'])
    );
    expect(formList.data.filter((form) => ['QOL', 'MACS'].includes(form.key))).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ key: 'QOL', scoringType: 'MANUAL' }),
        expect.objectContaining({ key: 'MACS', scoringType: 'MANUAL' }),
      ])
    );

    const forbiddenCreate = await request('/api/v1/forms', patientToken, {
      method: 'POST',
      body: JSON.stringify(customForm),
    });
    expect(forbiddenCreate.status).toBe(403);

    const invalidForm = await request('/api/v1/forms', doctorToken, {
      method: 'POST',
      body: JSON.stringify({
        ...customForm,
        key: 'ACCEPTANCE_INVALID_FORM',
        scoreRanges: [
          { label: 'Normal', minScore: 0, maxScore: 1 },
          { label: 'Raised', minScore: 3, maxScore: 5 },
        ],
      }),
    });
    expect(invalidForm.status).toBe(400);

    const createResponse = await request('/api/v1/forms', doctorToken, {
      method: 'POST',
      body: JSON.stringify(customForm),
    });
    expect(createResponse.status).toBe(201);
    const custom = (await createResponse.json()) as { id: string };

    const publishVersionResponse = await request(
      `/api/v1/forms/${custom.id}/publish-version`,
      doctorToken,
      { method: 'POST', body: '{}' }
    );
    expect(publishVersionResponse.status).toBe(200);

    const pinnedPublish = await request(`/api/v1/forms/${custom.id}/publish`, doctorToken, {
      method: 'POST',
      body: JSON.stringify({ target: 'SINGLE_PATIENT', patientId: patient.id, publishAt: null }),
    });
    const pinnedAssignmentId = ((await pinnedPublish.json()) as { assignmentIds: string[] })
      .assignmentIds[0];
    const pinnedDetail = (await (
      await request(`/api/v1/form-assignments/${pinnedAssignmentId}`, patientToken)
    ).json()) as {
      formVersion: {
        questions: Array<{
          id: string;
          type: string;
          scaleMin: number | null;
          choices: Array<{ id: string }>;
        }>;
      };
    };
    const pinnedAnswers = pinnedDetail.formVersion.questions.map((question) =>
      question.type === 'SCALE'
        ? { questionId: question.id, value: question.scaleMin }
        : { questionId: question.id, choiceIds: [question.choices[0].id] }
    );
    const pinnedSubmission = (await (
      await request(`/api/v1/form-assignments/${pinnedAssignmentId}/submit`, patientToken, {
        method: 'POST',
        body: JSON.stringify({ answers: pinnedAnswers }),
      })
    ).json()) as { submissionId: string };

    const updateResponse = await request(`/api/v1/forms/${custom.id}`, doctorToken, {
      method: 'PUT',
      body: JSON.stringify({ ...customForm, name: 'Acceptance mixed form v2' }),
    });
    expect(updateResponse.status).toBe(200);
    await expect(updateResponse.json()).resolves.toEqual(
      expect.objectContaining({ currentVersion: expect.objectContaining({ version: 2 }) })
    );

    const versionsResponse = await request(`/api/v1/forms/${custom.id}/versions`, doctorToken);
    expect(versionsResponse.status).toBe(200);
    const versions = (await versionsResponse.json()) as Array<{ version: number }>;
    expect(versions.map((version) => version.version)).toEqual(expect.arrayContaining([1, 2]));

    const pinnedSubmissionResponse = await request(
      `/api/v1/assessments/submissions/${pinnedSubmission.submissionId}`,
      doctorToken
    );
    await expect(pinnedSubmissionResponse.json()).resolves.toEqual(
      expect.objectContaining({ formVersion: expect.objectContaining({ version: 1 }) })
    );

    const phq9 = formList.data.find((form) => form.key === 'PHQ9')!;
    const singlePublish = await request(`/api/v1/forms/${phq9.id}/publish`, doctorToken, {
      method: 'POST',
      body: JSON.stringify({ target: 'SINGLE_PATIENT', patientId: patient.id, publishAt: null }),
    });
    expect(singlePublish.status).toBe(201);
    const singleAssignmentId = ((await singlePublish.json()) as { assignmentIds: string[] })
      .assignmentIds[0];

    const patientAssignments = await request('/api/v1/form-assignments/my', patientToken);
    const visibleToPatient = (await patientAssignments.json()) as Array<{ id: string }>;
    expect(visibleToPatient).toEqual(
      expect.arrayContaining([expect.objectContaining({ id: singleAssignmentId })])
    );
    const notPatientAssignments = await request('/api/v1/form-assignments/my', otherPatientToken);
    await expect(notPatientAssignments.json()).resolves.not.toEqual(
      expect.arrayContaining([expect.objectContaining({ id: singleAssignmentId })])
    );

    const scheduled = await request(`/api/v1/forms/${phq9.id}/publish`, doctorToken, {
      method: 'POST',
      body: JSON.stringify({
        target: 'SINGLE_PATIENT',
        patientId: otherPatient.id,
        publishAt: new Date(Date.now() + 60_000).toISOString(),
      }),
    });
    const scheduledId = ((await scheduled.json()) as { assignmentIds: string[] }).assignmentIds[0];
    const scheduledHidden = await request('/api/v1/form-assignments/my', otherPatientToken);
    await expect(scheduledHidden.json()).resolves.not.toEqual(
      expect.arrayContaining([expect.objectContaining({ id: scheduledId })])
    );

    const volunteerPublish = await request(`/api/v1/forms/${phq9.id}/publish`, doctorToken, {
      method: 'POST',
      body: JSON.stringify({
        target: 'VOLUNTEER_FOR_PATIENT',
        patientId: otherPatient.id,
        volunteerId: volunteer.id,
        publishAt: null,
      }),
    });
    expect(volunteerPublish.status).toBe(201);
    const volunteerAssignmentId = ((await volunteerPublish.json()) as { assignmentIds: string[] })
      .assignmentIds[0];
    const volunteerAssignments = await request('/api/v1/form-assignments/my', volunteerToken);
    await expect(volunteerAssignments.json()).resolves.toEqual(
      expect.arrayContaining([expect.objectContaining({ id: volunteerAssignmentId })])
    );

    const allPatients = await request(`/api/v1/forms/${phq9.id}/publish`, doctorToken, {
      method: 'POST',
      body: JSON.stringify({ target: 'ALL_PATIENTS', publishAt: null }),
    });
    expect(allPatients.status).toBe(201);
    const allPatientsBody = (await allPatients.json()) as { assignmentsCreated: number };
    expect(allPatientsBody.assignmentsCreated).toBeGreaterThanOrEqual(2);

    const detailResponse = await request(
      `/api/v1/form-assignments/${singleAssignmentId}`,
      patientToken
    );
    const detail = (await detailResponse.json()) as {
      formVersion: {
        questions: Array<{
          id: string;
          type: string;
          scaleMax: number | null;
          choices: Array<{ id: string; score?: number }>;
        }>;
      };
    };
    expect(detail.formVersion.questions.flatMap((question) => question.choices)).not.toEqual(
      expect.arrayContaining([expect.objectContaining({ score: expect.any(Number) })])
    );
    const answers = detail.formVersion.questions.map((question) =>
      question.type === 'SCALE'
        ? { questionId: question.id, value: question.scaleMax }
        : { questionId: question.id, choiceIds: [question.choices.at(-1)!.id] }
    );

    const submitResponse = await request(
      `/api/v1/form-assignments/${singleAssignmentId}/submit`,
      patientToken,
      { method: 'POST', body: JSON.stringify({ answers }) }
    );
    expect(submitResponse.status).toBe(201);
    const submission = (await submitResponse.json()) as {
      submissionId: string;
      status: string;
      totalScore?: number;
      interpretation?: unknown;
    };
    expect(submission).toMatchObject({ status: 'SUBMITTED' });
    expect(submission.totalScore).toBeUndefined();
    expect(submission.interpretation).toBeUndefined();

    expect(
      await mongoose.connection.collection('notifications').findOne({
        patientId: patient.id,
        type: 'HIGH_RISK',
        reason: submission.submissionId,
      })
    ).not.toBeNull();

    const pendingResponse = await request('/api/v1/assessments/submissions/pending', doctorToken);
    await expect(pendingResponse.json()).resolves.toEqual(
      expect.arrayContaining([expect.objectContaining({ id: submission.submissionId })])
    );

    const assessmentBody = {
      patientId: patient.id,
      submissionId: submission.submissionId,
      templateKey: 'PHQ9',
      score: 0,
      status: 'SEVERE',
      doctorNote: 'Acceptance follow-up',
    };
    const patientAssessment = await request('/api/v1/assessments', patientToken, {
      method: 'POST',
      body: JSON.stringify(assessmentBody),
    });
    expect(patientAssessment.status).toBe(403);

    const assessmentResponse = await request('/api/v1/assessments', doctorToken, {
      method: 'POST',
      body: JSON.stringify(assessmentBody),
    });
    expect(assessmentResponse.status).toBe(201);

    expect(
      await mongoose.connection.collection('audit_logs').countDocuments({
        actorId: doctor.id,
        action: { $in: ['FORM_PUBLISHED', 'ASSESSMENT_CREATED'] },
      })
    ).toBeGreaterThanOrEqual(2);
    expect(
      await mongoose.connection.collection('audit_logs').countDocuments({
        actorId: patientUser.id,
        action: 'FORM_SUBMITTED',
      })
    ).toBe(2);
    expect(
      await mongoose.connection.collection('audit_logs').countDocuments({
        actorId: patientUser.id,
        action: 'HIGH_RISK_ALERT_CREATED',
      })
    ).toBe(1);
  });
});
