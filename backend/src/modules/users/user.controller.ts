import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  listVolunteerOptionsQuerySchema,
  listUsersQuerySchema,
  patchUserSchema,
  patchUserStatusSchema,
  userIdParamSchema,
} from './user.schema';
import * as userService from './user.service';

export async function list(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const query = listUsersQuerySchema.parse(req.query);
    const result = await userService.listUsers(query);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function listVolunteerOptions(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const query = listVolunteerOptionsQuerySchema.parse(req.query);
    const result = await userService.listVolunteerOptions(query);
    res.status(200).json(result);
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
    const { id } = userIdParamSchema.parse(req.params);
    const user = await userService.findPublicById(id);
    if (!user) throw AppError.notFound('User not found');
    res.status(200).json(user);
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

    const { id } = userIdParamSchema.parse(req.params);
    const input = patchUserSchema.parse(req.body);
    const user = await userService.patchUser(id, input, req.user.id, req);

    res.status(200).json(user);
  } catch (err) {
    next(err);
  }
}

export async function patchStatus(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();

    const { id } = userIdParamSchema.parse(req.params);
    const input = patchUserStatusSchema.parse(req.body);
    const user = await userService.patchUserStatus(id, input.isActive, req.user.id, req);

    res.status(200).json(user);
  } catch (err) {
    next(err);
  }
}

export async function triggerReset(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();

    const { id } = userIdParamSchema.parse(req.params);
    await userService.triggerReset(id, req.user.id, req);

    res.status(200).json({ message: "Password reset link sent to user's email" });
  } catch (err) {
    next(err);
  }
}
