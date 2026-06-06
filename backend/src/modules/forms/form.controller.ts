import { randomBytes } from 'node:crypto';
import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  createFormSchema,
  formIdParamSchema,
  formVersionParamSchema,
  listFormsQuerySchema,
  setFormStatusSchema,
} from './form.schema';
import * as formService from './form.service';
import {
  assignmentIdParamSchema,
  listAssignmentsQuerySchema,
  publishFormSchema,
} from './publish.schema';
import * as publishService from './publish.service';

// The authoring UI collects a title but not a stable `key`. When the client
// omits it, derive one from the name's ASCII alphanumerics plus a random
// suffix (avoids collisions and handles non-Latin titles, e.g. Arabic, which
// slugify to empty). `key` stays required on the update path — it is immutable
// once set, so it is never regenerated there.
function deriveFormKey(name: unknown): string {
  const base =
    typeof name === 'string'
      ? name
          .replace(/[^a-zA-Z0-9]+/g, '_')
          .replace(/^_+|_+$/g, '')
          .toUpperCase()
          .slice(0, 40)
      : '';
  const suffix = randomBytes(4).toString('hex').toUpperCase();
  return base.length >= 2 ? `${base}_${suffix}` : `FORM_${suffix}`;
}

export async function create(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const body = { ...(req.body as Record<string, unknown>) };
    const rawKey = body.key;
    const keyMissing =
      rawKey === undefined ||
      rawKey === null ||
      (typeof rawKey === 'string' && rawKey.trim() === '');
    if (keyMissing) body.key = deriveFormKey(body.name);

    const input = createFormSchema.parse(body);
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

export async function update(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = formIdParamSchema.parse(req.params);
    const input = createFormSchema.parse(req.body);
    const form = await formService.updateForm(id, input, req.user.id, req);
    res.status(200).json(form);
  } catch (err) {
    next(err);
  }
}

export async function setStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = formIdParamSchema.parse(req.params);
    const { isActive } = setFormStatusSchema.parse(req.body);
    const form = await formService.setStatus(id, isActive, req.user.id, req);
    res.status(200).json(form);
  } catch (err) {
    next(err);
  }
}

export async function listVersions(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { id } = formIdParamSchema.parse(req.params);
    const versions = await formService.listVersions(id);
    res.status(200).json(versions);
  } catch (err) {
    next(err);
  }
}

export async function getVersion(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { id, version } = formVersionParamSchema.parse(req.params);
    const formVersion = await formService.getVersion(id, version);
    res.status(200).json(formVersion);
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

export async function publishVersion(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = formIdParamSchema.parse(req.params);
    const form = await formService.publishVersion(id);
    res.status(200).json(form);
  } catch (err) {
    next(err);
  }
}

export async function publish(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = formIdParamSchema.parse(req.params);
    const input = publishFormSchema.parse(req.body);
    const result = await publishService.publishForm(id, input, req.user.id, req);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
}

export async function listAssignments(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = formIdParamSchema.parse(req.params);
    const query = listAssignmentsQuerySchema.parse(req.query);
    const assignments = await publishService.listAssignments(id, query);
    res.status(200).json(assignments);
  } catch (err) {
    next(err);
  }
}

export async function cancelAssignment(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = assignmentIdParamSchema.parse(req.params);
    const assignment = await publishService.cancelAssignment(id);
    res.status(200).json(assignment);
  } catch (err) {
    next(err);
  }
}
