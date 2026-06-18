import type { NextFunction, Request, Response } from 'express';
import { activityQuerySchema } from './dashboard.schema';
import * as dashboardService from './dashboard.service';

export async function summary(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const result = await dashboardService.getSummary();
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function activity(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const query = activityQuerySchema.parse(req.query);
    const result = await dashboardService.getActivity(query.limit);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}
