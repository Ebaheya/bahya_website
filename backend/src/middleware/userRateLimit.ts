import rateLimit, { type Options } from 'express-rate-limit';
import type { Request } from 'express';
import { rateLimitIpKey } from '../modules/auth/rate-limit-keys';

/**
 * Rate-limit key for authenticated routes. Buckets per authenticated user so a
 * single account cannot drive abuse regardless of source IP; falls back to the
 * (subnet-normalized) client IP for the rare pre-authentication case.
 */
function userRateLimitKey(req: Request): string {
  const userId = req.user?.id;
  return userId ? `user:${userId}` : `ip:${rateLimitIpKey(req.ip)}`;
}

/**
 * Build a per-user rate limiter. Use a generous bucket for general reads/writes
 * and a tighter one for expensive or sensitive actions (submit, publish).
 */
export function userRateLimiter(limit: number, windowMs = 60 * 1000): ReturnType<typeof rateLimit> {
  const options: Partial<Options> = {
    windowMs,
    limit,
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: userRateLimitKey,
  };
  return rateLimit(options);
}
