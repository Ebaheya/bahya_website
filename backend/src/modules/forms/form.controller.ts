import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import { createFormSchema, formIdParamSchema, listFormsQuerySchema } from './form.schema';
import * as formService from './form.service';

export async function create(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const input = createFormSchema.parse(req.body);
    const form = await formService.createForm(input, req.user.id, req);
    res.status(201).json(form);
  } catch (err) {
    next(err);
  }
}

export async function getById(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { id } = formIdParamSchema.parse(req.params);
    const form = await formService.getForm(id);
    res.status(200).json(form);
  } catch (err) {
    next(err);
  }
}

export async function list(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const query = listFormsQuerySchema.parse(req.query);
    const forms = await formService.listForms(query);
    res.status(200).json(forms);
  } catch (err) {
    next(err);
  }
}

export async function publishVersion(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { id } = formIdParamSchema.parse(req.params);
    const form = await formService.publishVersion(id);
    res.status(200).json(form);
  } catch (err) {
    next(err);
  }
}
