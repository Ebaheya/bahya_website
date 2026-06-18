import { AppError } from '../../utils/httpError';

export const REPORT_ERROR = {
  REPORT_NOT_FOUND: 'REPORT_NOT_FOUND',
} as const;

export const ReportErrors = {
  reportNotFound(message = 'Report not found'): AppError {
    return new AppError(404, REPORT_ERROR.REPORT_NOT_FOUND, message);
  },
};
