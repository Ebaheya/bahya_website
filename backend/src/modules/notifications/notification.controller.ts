import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  listMyNotificationsQuerySchema,
  notificationIdParamSchema,
} from './notification.schema';
import * as notificationService from './notification.service';

export async function listMy(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const query = listMyNotificationsQuerySchema.parse(req.query);
    const result = await notificationService.listMyNotifications(
      { id: req.user.id, role: req.user.role },
      query
    );
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function claim(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = notificationIdParamSchema.parse(req.params);
    const result = await notificationService.claimNotification(
      { id: req.user.id, role: req.user.role },
      id
    );
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function read(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = notificationIdParamSchema.parse(req.params);
    const result = await notificationService.markRead(
      { id: req.user.id, role: req.user.role },
      id
    );
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function done(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = notificationIdParamSchema.parse(req.params);
    const result = await notificationService.markDone(
      { id: req.user.id, role: req.user.role },
      id
    );
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}
