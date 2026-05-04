export class AppError extends Error {
  public readonly statusCode: number;
  public readonly code: string;
  public readonly details?: unknown;

  constructor(statusCode: number, code: string, message: string, details?: unknown) {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    Error.captureStackTrace?.(this, AppError);
  }

  static badRequest(message = 'Bad request', details?: unknown): AppError {
    return new AppError(400, 'BAD_REQUEST', message, details);
  }

  static unauthorized(message = 'Unauthorized'): AppError {
    return new AppError(401, 'UNAUTHORIZED', message);
  }

  static invalidCredentials(message = 'Invalid credentials'): AppError {
    return new AppError(401, 'INVALID_CREDENTIALS', message);
  }

  static forbidden(message = 'Forbidden'): AppError {
    return new AppError(403, 'FORBIDDEN', message);
  }

  static notFound(message = 'Not found'): AppError {
    return new AppError(404, 'NOT_FOUND', message);
  }

  static conflict(message = 'Conflict'): AppError {
    return new AppError(409, 'CONFLICT', message);
  }

  static invalidOrExpiredToken(message = 'Invalid or expired token'): AppError {
    return new AppError(400, 'INVALID_OR_EXPIRED_TOKEN', message);
  }

  static emailDeliveryFailed(message = 'Email delivery failed'): AppError {
    return new AppError(503, 'EMAIL_DELIVERY_FAILED', message);
  }

  static internal(message = 'Internal server error'): AppError {
    return new AppError(500, 'INTERNAL', message);
  }
}
