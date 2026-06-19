import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import { assignmentIdParamSchema } from './publish.schema';
import { submitAssignmentSchema } from './submission.schema';
import * as submissionService from './submission.service';

export async function my(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const assignments = await submissionService.getMyAssignments(req.user.id, req.user.role);
    res.status(200).json(assignments);
  } catch (err) {
    next(err);
  }
}

export async function getById(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = assignmentIdParamSchema.parse(req.params);
    const assignment = await submissionService.getAssignmentDetail(id, req.user.id, req.user.role);
    res.status(200).json(assignment);
  } catch (err) {
    next(err);
  }
}

export async function submit(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = assignmentIdParamSchema.parse(req.params);
    const input = submitAssignmentSchema.parse(req.body);
    const submission = await submissionService.submit(id, input, req.user.id, req.user.role, req);
    res.status(201).json(submission);
  } catch (err) {
    next(err);
  }
}
