import type { Request, Response, NextFunction } from 'express';
import { AppError } from '../../utils/httpError';
import { env } from '../../config/env';
import {
  loginSchema,
  logoutSchema,
  refreshSchema,
  registerPatientSchema,
  registerStaffSchema,
} from './auth.schema';
import * as authService from './auth.service';
import * as users from '../users/user.service';

export async function registerStaff(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const input = registerStaffSchema.parse(req.body);

    if (req.user?.role === 'ADMIN') {
      const user = await authService.registerStaff(input, req);
      res.status(201).json({ user });
      return;
    }

    const bootstrapHeader = req.header('x-bootstrap-secret');
    if (!bootstrapHeader) {
      throw AppError.forbidden('Only ADMIN users can register staff');
    }
    if (bootstrapHeader !== env.BOOTSTRAP_SECRET) {
      throw AppError.forbidden('Invalid bootstrap secret');
    }
    if (await authService.adminExists()) {
      throw AppError.forbidden(
        'Bootstrap path is disabled: an admin already exists. Use an ADMIN access token.'
      );
    }
    if (input.role !== 'ADMIN') {
      throw AppError.badRequest('Bootstrap registration must create an ADMIN user');
    }

    const user = await authService.registerStaff(input);
    res.status(201).json({ user, bootstrap: true });
  } catch (err) {
    next(err);
  }
}

export async function registerPatient(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const input = registerPatientSchema.parse(req.body);
    const user = await authService.registerPatient(input, req);
    res.status(201).json({ user });
  } catch (err) {
    next(err);
  }
}

export async function login(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const input = loginSchema.parse(req.body);
    const result = await authService.login(input, req);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function refresh(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { refreshToken } = refreshSchema.parse(req.body);
    const tokens = await authService.refresh(refreshToken, req);
    res.status(200).json(tokens);
  } catch (err) {
    next(err);
  }
}

export async function logout(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { refreshToken } = logoutSchema.parse(req.body);
    await authService.logout(refreshToken, req);
    res.status(204).send();
  } catch (err) {
    next(err);
  }
}

export async function me(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const user = await users.findPublicById(req.user.id);
    if (!user) throw AppError.notFound('User no longer exists');
    res.status(200).json({ user });
  } catch (err) {
    next(err);
  }
}
