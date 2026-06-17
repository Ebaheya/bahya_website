import { AppError } from '../../utils/httpError';

export const NOTIFICATION_ERROR = {
  CLAIM_CONFLICT: 'CLAIM_CONFLICT',
  ILLEGAL_TRANSITION: 'ILLEGAL_TRANSITION',
  NOT_RECIPIENT: 'NOT_RECIPIENT',
} as const;

export const NotificationErrors = {
  // Losing side of a concurrent claim, or an already-claimed/non-claimable
  // notification (409). The atomic findOneAndUpdate is the authoritative guard.
  claimConflict(message = 'Notification has already been claimed'): AppError {
    return new AppError(409, NOTIFICATION_ERROR.CLAIM_CONFLICT, message);
  },
  // Forward-only lifecycle violation: e.g. read on a DONE notification, or any
  // attempt to move status backward (409).
  illegalTransition(message = 'Notification status cannot move backward'): AppError {
    return new AppError(409, NOTIFICATION_ERROR.ILLEGAL_TRANSITION, message);
  },
  // Caller does not own the notification (incl. an unclaimed role-broadcast) (403).
  notRecipient(message = 'You are not the recipient of this notification'): AppError {
    return new AppError(403, NOTIFICATION_ERROR.NOT_RECIPIENT, message);
  },
};
