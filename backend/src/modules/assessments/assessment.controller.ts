import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  assessmentIdParamSchema,
  assessmentPatientIdParamSchema,
  createAssessmentSchema,
  submissionIdParamSchema,
} from './assessment.schema';
import * as assessmentService from './assessment.service';

export async function listPending(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const submissions = await assessmentService.listPendingSubmissions(req.user.role);
    res.status(200).json(submissions);
  } catch (err) {
    next(err);
  }
}

export async function getSubmission(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = submissionIdParamSchema.parse(req.params);
    const submission = await assessmentService.getSubmission(id, req.user.role);
    res.status(200).json(submission);
  } catch (err) {
    next(err);
  }
}

export async function create(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const input = createAssessmentSchema.parse(req.body);
    const assessment = await assessmentService.createAssessment(
      input,
      req.user.id,
      req.user.role,
      req
    );
    res.status(201).json(assessment);
  } catch (err) {
    next(err);
  }
}

export async function listByPatient(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { patientId } = assessmentPatientIdParamSchema.parse(req.params);
    const assessments = await assessmentService.listByPatient(
      patientId,
      req.user.id,
      req.user.role
    );
    res.status(200).json(assessments);
  } catch (err) {
    next(err);
  }
}

export async function getById(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = assessmentIdParamSchema.parse(req.params);
    const assessment = await assessmentService.getById(id, req.user.id, req.user.role);
    res.status(200).json(assessment);
  } catch (err) {
    next(err);
  }
}
