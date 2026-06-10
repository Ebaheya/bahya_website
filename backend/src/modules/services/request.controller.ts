import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  listServiceRequestsQuerySchema,
  rejectServiceRequestSchema,
  serviceRequestIdParamSchema,
} from './request.schema';
import * as requestService from './request.service';

export async function listQueue(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const query = listServiceRequestsQuerySchema.parse(req.query);
    const requests = await requestService.listQueue(query);
    res.status(200).json(requests);
  } catch (err) {
    next(err);
  }
}

export async function listMy(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const requests = await requestService.listMyRequests(req.user.id);
    res.status(200).json(requests);
  } catch (err) {
    next(err);
  }
}

export async function summary(_req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const counts = await requestService.getSummary();
    res.status(200).json(counts);
  } catch (err) {
    next(err);
  }
}

export async function approve(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = serviceRequestIdParamSchema.parse(req.params);
    const request = await requestService.approveRequest(id, req.user.id, req);
    res.status(200).json(request);
  } catch (err) {
    next(err);
  }
}

export async function cancel(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = serviceRequestIdParamSchema.parse(req.params);
    const request = await requestService.cancelRequest(id, req.user.id, req);
    res.status(200).json(request);
  } catch (err) {
    next(err);
  }
}

export async function reject(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = serviceRequestIdParamSchema.parse(req.params);
    const input = rejectServiceRequestSchema.parse(req.body);
    const request = await requestService.rejectRequest(id, req.user.id, input.decisionNote, req);
    res.status(200).json(request);
  } catch (err) {
    next(err);
  }
}
