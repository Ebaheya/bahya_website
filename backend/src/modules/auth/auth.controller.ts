import type { Request, Response, NextFunction } from 'express';
import { AppError } from '../../utils/httpError';
import { env } from '../../config/env';
import {
  changePasswordSchema,
  forgotPasswordSchema,
  loginSchema,
  logoutSchema,
  refreshSchema,
  registerPatientSchema,
  registerStaffSchema,
  resetPasswordSchema,
} from './auth.schema';
import * as authService from './auth.service';
import * as patientService from '../patients/patient.service';
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
    if (input.role !== 'ADMIN') {
      throw AppError.badRequest('Bootstrap registration must create an ADMIN user');
    }

    // bootstrapFirstAdmin acquires a pg advisory lock before checking admin existence,
    // preventing two simultaneous requests from both creating an admin.
    const user = await authService.bootstrapFirstAdmin(input, req);
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
    if (!req.user) throw AppError.unauthorized();
    const input = registerPatientSchema.parse(req.body);
    const patient = await patientService.createPatient(input, req.user.id, req);
    res.status(201).json(patient);
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

export async function changePassword(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const input = changePasswordSchema.parse(req.body);
    await authService.changePassword(
      req.user.id,
      input.currentPassword,
      input.newPassword,
      req
    );
    res.status(200).json({ message: 'Password changed successfully' });
  } catch (err) {
    next(err);
  }
}

export async function forgotPassword(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const input = forgotPasswordSchema.parse(req.body);
    const result = await authService.forgotPassword(input.email, req);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function resetPassword(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const input = resetPasswordSchema.parse(req.body);
    await authService.resetPassword(input.token, input.newPassword, req);
    res.status(200).json({ message: 'Password has been reset successfully' });
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
