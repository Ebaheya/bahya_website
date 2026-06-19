import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  createPatientSchema,
  listPatientOptionsQuerySchema,
  patientIdParamSchema,
  patientTimelineQuerySchema,
  patchPatientSchema,
  queryPatientsSchema,
} from './patient.schema';
import * as patientService from './patient.service';

// Fields a DOCTOR may edit. Clinical data (staging, treatment, tumour biology,
// BMI) plus the medical-history blob are the doctor's domain; CRN, demographics,
// contacts, social status, and financials stay with ADMIN/CALL_CENTER.
const DOCTOR_EDITABLE_FIELDS = new Set([
  'bmi',
  'menopausalStatus',
  'dateOfDiagnosis',
  'stageAtDiagnosis',
  'diseaseStatus',
  'tumorBiology',
  'surgery',
  'chemotherapy',
  'radiotherapy',
  'hormonalTherapy',
  'targetedTherapy',
  'immunotherapy',
  'medicalHistory',
]);

// Clinical list filters a VOLUNTEER is not allowed to use (would leak clinical
// data they can't otherwise see).
const VOLUNTEER_CLINICAL_FILTERS = [
  'surgery',
  'chemotherapy',
  'tumorBiology',
  'diseaseStatus',
  'radiotherapy',
  'hormonalTherapy',
  'targetedTherapy',
  'immunotherapy',
] as const;

export async function create(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();

    const input = createPatientSchema.parse(req.body);
    const patient = await patientService.createPatient(input, req.user.id, req);

    res.status(201).json(patient);
  } catch (err) {
    next(err);
  }
}

export async function getById(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();

    const { id } = patientIdParamSchema.parse(req.params);
    const patient = await patientService.getPatientById(id);
    if (!patient) throw AppError.notFound('Patient not found');

    if (req.user.role === 'PATIENT' && patient.userId !== req.user.id) {
      throw AppError.forbidden('Patients can only access their own profile');
    }

    res.status(200).json(patientService.projectForRole(patient, req.user.role));
  } catch (err) {
    next(err);
  }
}

export async function list(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();

    const query = queryPatientsSchema.parse(req.query);
    const role = req.user.role;

    // Volunteers can't see clinical data, so they can't filter by it either —
    // otherwise the result set would leak the value they filtered on.
    if (role === 'VOLUNTEER') {
      for (const field of VOLUNTEER_CLINICAL_FILTERS) {
        delete query[field];
      }
    }

    const result = await patientService.listPatients(query);
    const data = result.data.map((patient) => patientService.projectForRole(patient, role));

    res.status(200).json({ ...result, data });
  } catch (err) {
    next(err);
  }
}

export async function listOptions(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const query = listPatientOptionsQuerySchema.parse(req.query);
    const result = await patientService.listPatientOptions(query);

    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function patch(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();

    const { id } = patientIdParamSchema.parse(req.params);
    const input = patchPatientSchema.parse(req.body);

    if (req.user.role === 'DOCTOR') {
      const forbidden = Object.keys(input).filter(
        (field) => !DOCTOR_EDITABLE_FIELDS.has(field)
      );
      if (forbidden.length > 0) {
        throw AppError.forbidden(
          `Doctors can only edit clinical fields; not allowed: ${forbidden.join(', ')}`
        );
      }
    }

    const patient = await patientService.patchPatient(id, input, req.user.id, req);

    res.status(200).json(patientService.projectForRole(patient, req.user.role));
  } catch (err) {
    next(err);
  }
}

export async function timeline(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();

    const { id } = patientIdParamSchema.parse(req.params);
    const query = patientTimelineQuerySchema.parse(req.query);
    const patient = await patientService.getPatientById(id);
    if (!patient) throw AppError.notFound('Patient not found');

    const result = await patientService.getPatientTimeline(
      id,
      query.page,
      query.pageSize
    );

    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}
