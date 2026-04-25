import type { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/httpError';
import { verifyAccessToken } from '../utils/tokens';
import * as users from '../modules/users/user.service';

// Loads the user from the DB on every request so that demoted, disabled,
// or deleted users are rejected immediately without waiting for JWT expiry.
export async function authenticate(req: Request, _res: Response, next: NextFunction): Promise<void> {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      throw AppError.unauthorized('Missing or invalid Authorization header');
    }
    const token = header.slice('Bearer '.length).trim();
    if (!token) throw AppError.unauthorized('Missing bearer token');

    const payload = verifyAccessToken(token);

    const user = await users.findById(payload.sub);
    if (!user || !user.isActive) {
      throw AppError.unauthorized('User is inactive or no longer exists');
    }

    // Role comes from DB, not from the JWT claim, so demotions take effect immediately.
    req.user = { id: user.id, role: user.role };
    next();
  } catch (err) {
    if (err instanceof AppError) return next(err);
    return next(AppError.unauthorized('Invalid or expired access token'));
  }
}
