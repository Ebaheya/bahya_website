import type { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/httpError';
import { verifyAccessToken } from '../utils/tokens';

export function authenticate(req: Request, _res: Response, next: NextFunction): void {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      throw AppError.unauthorized('Missing or invalid Authorization header');
    }
    const token = header.slice('Bearer '.length).trim();
    if (!token) throw AppError.unauthorized('Missing bearer token');

    const payload = verifyAccessToken(token);
    req.user = { id: payload.sub, role: payload.role };
    next();
  } catch (err) {
    if (err instanceof AppError) return next(err);
    return next(AppError.unauthorized('Invalid or expired access token'));
  }
}
