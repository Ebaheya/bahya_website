import { prisma } from '../../config/prisma';
import { AppError } from '../../utils/httpError';
import type { ChatRiskLevel } from './chat.model';
import type { AiPatientProfile } from './ai.client';

interface PatientTreatmentFields {
  chemotherapy: string | null;
  radiotherapy: boolean | null;
  hormonalTherapy: boolean | null;
  targetedTherapy: boolean | null;
  immunotherapy: boolean | null;
}

function calculateAge(dateOfBirth: Date | null): number | null {
  if (!dateOfBirth) return null;

  const today = new Date();
  let age = today.getUTCFullYear() - dateOfBirth.getUTCFullYear();
  const monthDiff = today.getUTCMonth() - dateOfBirth.getUTCMonth();
  const beforeBirthday =
    monthDiff < 0 || (monthDiff === 0 && today.getUTCDate() < dateOfBirth.getUTCDate());

  if (beforeBirthday) age -= 1;
  return age;
}

function treatmentTags(patient: PatientTreatmentFields): string[] {
  const treatments: string[] = [];

  if (patient.chemotherapy && patient.chemotherapy !== 'NO') {
    treatments.push(`${patient.chemotherapy}_CHEMO`);
  }
  if (patient.radiotherapy) treatments.push('RADIOTHERAPY');
  if (patient.hormonalTherapy) treatments.push('HORMONAL_THERAPY');
  if (patient.targetedTherapy) treatments.push('TARGETED_THERAPY');
  if (patient.immunotherapy) treatments.push('IMMUNOTHERAPY');

  return treatments;
}

function dietNotes(medicalHistory: unknown): string | null {
  if (
    medicalHistory &&
    typeof medicalHistory === 'object' &&
    'notes' in medicalHistory &&
    typeof medicalHistory.notes === 'string'
  ) {
    return medicalHistory.notes;
  }

  return null;
}

export async function buildPatientProfile(
  patientId: string,
  riskFlagFromHistory: ChatRiskLevel | null = null
): Promise<AiPatientProfile> {
  const patient = await prisma.patient.findUnique({
    where: { id: patientId },
    select: {
      id: true,
      dateOfBirth: true,
      stageAtDiagnosis: true,
      diseaseStatus: true,
      chemotherapy: true,
      radiotherapy: true,
      hormonalTherapy: true,
      targetedTherapy: true,
      immunotherapy: true,
      medicalHistory: true,
    },
  });

  if (!patient) throw AppError.notFound('Patient not found');

  return {
    patientId: patient.id,
    age: calculateAge(patient.dateOfBirth),
    languagePref: 'ar',
    cancerStage: patient.stageAtDiagnosis,
    diseaseStatus: patient.diseaseStatus,
    treatments: treatmentTags(patient),
    dietNotes: dietNotes(patient.medicalHistory),
    riskFlagFromHistory,
  };
}
