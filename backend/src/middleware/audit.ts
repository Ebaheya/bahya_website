import type { Request } from 'express';

export { writeAudit, type AuditInput } from '../modules/audit-logs/audit.service';

// Use Express's req.ip which respects the `trust proxy` setting in app.ts.
// Manual X-Forwarded-For parsing is removed: it can be spoofed by clients
// and produces a different value than what express-rate-limit uses, making
// audit logs and rate-limit identities inconsistent.
export function getClientIp(req: Request): string | null {
  return req.ip ?? null;
}
