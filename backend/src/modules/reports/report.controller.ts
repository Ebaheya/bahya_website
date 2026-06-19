import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  changeReportStatusSchema,
  createReportSchema,
  listReportsQuerySchema,
  reportIdParamSchema,
} from './report.schema';
import * as reportService from './report.service';

export async function create(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const input = createReportSchema.parse(req.body);
    const report = await reportService.createReport(input, req.user.id, req);
    res.status(201).json(report);
  } catch (err) {
    next(err);
  }
}

export async function list(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const query = listReportsQuerySchema.parse(req.query);
    const reports = await reportService.listReports(query);
    res.status(200).json(reports);
  } catch (err) {
    next(err);
  }
}

export async function summary(_req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const counts = await reportService.getSummary();
    res.status(200).json(counts);
  } catch (err) {
    next(err);
  }
}

export async function detail(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { id } = reportIdParamSchema.parse(req.params);
    const report = await reportService.getReportById(id);
    res.status(200).json(report);
  } catch (err) {
    next(err);
  }
}

export async function changeStatus(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = reportIdParamSchema.parse(req.params);
    const input = changeReportStatusSchema.parse(req.body);
    const report = await reportService.changeStatus(id, input.status, req.user.id, req);
    res.status(200).json(report);
  } catch (err) {
    next(err);
  }
}
