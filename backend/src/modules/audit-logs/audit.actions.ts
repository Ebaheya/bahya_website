export const AUDIT_ACTIONS = [
  'LOGIN',
  'LOGIN_FAIL',
  'LOGOUT',
  'REFRESH',
  'USER_CREATED',
  'PATIENT_UPDATED',
  'ASSESSMENT_CREATED',
  'NOTIFICATION_READ',
  'NOTIFICATION_DONE',
  'HIGH_RISK_ALERT_CREATED',
  'PASSWORD_RESET_BY_ADMIN',
] as const;

export type AuditAction = (typeof AUDIT_ACTIONS)[number];

export const STRICT_AUDIT_ACTIONS: ReadonlySet<AuditAction> = new Set([
  'LOGIN',
  'LOGIN_FAIL',
  'USER_CREATED',
  'PASSWORD_RESET_BY_ADMIN',
  'HIGH_RISK_ALERT_CREATED',
]);

export function isStrictAuditAction(a: AuditAction): boolean {
  return STRICT_AUDIT_ACTIONS.has(a);
}
