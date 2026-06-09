import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  createServiceSchema,
  listServicesQuerySchema,
  serviceIdParamSchema,
  updateServiceSchema,
} from './service.schema';
import * as serviceService from './service.service';
import { serviceRequestServiceParamSchema } from './request.schema';
import * as requestService from './request.service';

export async function create(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const input = createServiceSchema.parse(req.body);
    const service = await serviceService.createService(input, req.user.id, req);
    res.status(201).json(service);
  } catch (err) {
    next(err);
  }
}

export async function update(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = serviceIdParamSchema.parse(req.params);
    const input = updateServiceSchema.parse(req.body);
    const service = await serviceService.updateService(id, input, req.user.id, req);
    res.status(200).json(service);
  } catch (err) {
    next(err);
  }
}

export async function getById(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = serviceIdParamSchema.parse(req.params);
    const service = await serviceService.getServiceById(id);
    if (req.user.role === 'PATIENT' && service.status !== 'ACTIVE') {
      throw AppError.notFound('Service not found');
    }
    res.status(200).json(service);
  } catch (err) {
    next(err);
  }
}

export async function list(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const query = listServicesQuerySchema.parse(req.query);
    const services = await serviceService.listServices(query, req.user.role);
    res.status(200).json(services);
  } catch (err) {
    next(err);
  }
}

export async function createRequest(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = serviceRequestServiceParamSchema.parse(req.params);
    const request = await requestService.createRequest(id, req.user.id, req);
    res.status(201).json(request);
  } catch (err) {
    next(err);
  }
}
