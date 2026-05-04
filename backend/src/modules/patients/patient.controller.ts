import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  createPatientSchema,
  patientIdParamSchema,
  patientTimelineQuerySchema,
  patchPatientSchema,
  queryPatientsSchema,
} from './patient.schema';
import * as patientService from './patient.service';

function omitFinancials<T extends { financials?: unknown }>(patient: T): Omit<T, 'financials'> {
  const response = { ...patient };
  delete response.financials;
  return response;
}

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

    const response =
      req.user.role === 'VOLUNTEER' ? omitFinancials(patient) : patient;

    res.status(200).json(response);
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
    const result = await patientService.listPatients(query);
    const data =
      req.user.role === 'VOLUNTEER'
        ? result.data.map((patient) => omitFinancials(patient))
        : result.data;

    res.status(200).json({ ...result, data });
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
    const patient = await patientService.patchPatient(id, input, req.user.id, req);

    const response =
      req.user.role === 'VOLUNTEER' ? omitFinancials(patient) : patient;

    res.status(200).json(response);
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
