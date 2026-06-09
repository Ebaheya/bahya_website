import { AppError } from '../../utils/httpError';

export const SERVICE_ERROR = {
  CATEGORY_NAME_TAKEN: 'CATEGORY_NAME_TAKEN',
  SERVICE_CAPACITY_INVALID: 'SERVICE_CAPACITY_INVALID',
  TRIP_FIELDS_REQUIRED: 'TRIP_FIELDS_REQUIRED',
  SERVICE_CAPACITY_BELOW_TAKEN: 'SERVICE_CAPACITY_BELOW_TAKEN',
  DUPLICATE_SERVICE_REQUEST: 'DUPLICATE_SERVICE_REQUEST',
  SERVICE_FULL: 'SERVICE_FULL',
  SERVICE_NOT_ACCEPTING: 'SERVICE_NOT_ACCEPTING',
  REQUEST_ALREADY_DECIDED: 'REQUEST_ALREADY_DECIDED',
  REQUEST_NOT_PENDING: 'REQUEST_NOT_PENDING',
} as const;

export const ServiceErrors = {
  categoryNameTaken(message = 'Category name is already taken'): AppError {
    return new AppError(409, SERVICE_ERROR.CATEGORY_NAME_TAKEN, message);
  },
  serviceCapacityInvalid(message = 'Service capacity must be greater than zero'): AppError {
    return new AppError(400, SERVICE_ERROR.SERVICE_CAPACITY_INVALID, message);
  },
  tripFieldsRequired(
    message = 'Trip services require end date, departure time, and meeting place'
  ): AppError {
    return new AppError(400, SERVICE_ERROR.TRIP_FIELDS_REQUIRED, message);
  },
  serviceCapacityBelowTaken(minimum: number): AppError {
    return new AppError(
      400,
      SERVICE_ERROR.SERVICE_CAPACITY_BELOW_TAKEN,
      `Service capacity cannot be lower than seats already taken (${minimum})`,
      { minimum }
    );
  },
  duplicateServiceRequest(
    message = 'Patient already has an active request for this service'
  ): AppError {
    return new AppError(409, SERVICE_ERROR.DUPLICATE_SERVICE_REQUEST, message);
  },
  serviceFull(message = 'Service is full'): AppError {
    return new AppError(409, SERVICE_ERROR.SERVICE_FULL, message);
  },
  serviceNotAccepting(message = 'Service is not accepting requests'): AppError {
    return new AppError(409, SERVICE_ERROR.SERVICE_NOT_ACCEPTING, message);
  },
  requestAlreadyDecided(message = 'Request has already been decided'): AppError {
    return new AppError(409, SERVICE_ERROR.REQUEST_ALREADY_DECIDED, message);
  },
  requestNotPending(message = 'Request is not pending'): AppError {
    return new AppError(409, SERVICE_ERROR.REQUEST_NOT_PENDING, message);
  },
};
