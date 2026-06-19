import { AppError } from '../../utils/httpError';

export const REPORT_ERROR = {
  REPORT_NOT_FOUND: 'REPORT_NOT_FOUND',
  REPORT_INVALID_STATUS_TRANSITION: 'REPORT_INVALID_STATUS_TRANSITION',
  REPORT_STATUS_CONFLICT: 'REPORT_STATUS_CONFLICT',
} as const;

export const ReportErrors = {
  reportNotFound(message = 'Report not found'): AppError {
    return new AppError(404, REPORT_ERROR.REPORT_NOT_FOUND, message);
  },
  invalidStatusTransition(from: string, to: string): AppError {
    return new AppError(
      409,
      REPORT_ERROR.REPORT_INVALID_STATUS_TRANSITION,
      `Cannot change report status from ${from} to ${to}`
    );
  },
  statusConflict(
    message = 'Report status changed concurrently; reload and retry'
  ): AppError {
    return new AppError(409, REPORT_ERROR.REPORT_STATUS_CONFLICT, message);
  },
};
