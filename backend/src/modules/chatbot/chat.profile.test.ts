import { prisma } from '../../config/prisma';
import { buildPatientProfile } from './chat.profile';

jest.mock('../../config/prisma', () => ({
  prisma: {
    patient: {
      findUnique: jest.fn(),
    },
  },
}));

const findUniqueMock = prisma.patient.findUnique as jest.Mock;

describe('buildPatientProfile', () => {
  beforeEach(() => {
    jest.useFakeTimers().setSystemTime(new Date('2026-06-20T00:00:00Z'));
    findUniqueMock.mockReset();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('maps the PostgreSQL patient record to the AI contract profile', async () => {
    findUniqueMock.mockResolvedValue({
      id: '8f3b7f60-997b-4e12-b45a-63f6d7dbb7ef',
      dateOfBirth: new Date('1990-06-20T00:00:00Z'),
      stageAtDiagnosis: 'STAGE_II',
      diseaseStatus: 'ACTIVE_TREATMENT',
      chemotherapy: 'ADJUVANT',
      radiotherapy: true,
      hormonalTherapy: true,
      targetedTherapy: false,
      immunotherapy: true,
      medicalHistory: { notes: 'lactose intolerant' },
    });

    await expect(
      buildPatientProfile('8f3b7f60-997b-4e12-b45a-63f6d7dbb7ef', 'MEDIUM')
    ).resolves.toEqual({
      patientId: '8f3b7f60-997b-4e12-b45a-63f6d7dbb7ef',
      age: 36,
      languagePref: 'ar',
      cancerStage: 'STAGE_II',
      diseaseStatus: 'ACTIVE_TREATMENT',
      treatments: ['ADJUVANT_CHEMO', 'RADIOTHERAPY', 'HORMONAL_THERAPY', 'IMMUNOTHERAPY'],
      dietNotes: 'lactose intolerant',
      riskFlagFromHistory: 'MEDIUM',
    });
  });

  it('throws a stable 404 when the patient record is missing', async () => {
    findUniqueMock.mockResolvedValue(null);

    await expect(
      buildPatientProfile('8f3b7f60-997b-4e12-b45a-63f6d7dbb7ef')
    ).rejects.toMatchObject({
      statusCode: 404,
      code: 'NOT_FOUND',
    });
  });
});
