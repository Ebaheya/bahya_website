import { logger } from '../../config/logger';
import { NotificationModel } from './notification.model';
import {
  emitServiceRequestDecided,
  emitServiceRequestSubmitted,
} from './notification.service';

jest.mock('../../config/logger', () => ({
  logger: {
    warn: jest.fn(),
  },
}));

jest.mock('./notification.model', () => ({
  NotificationModel: {
    create: jest.fn(),
    insertMany: jest.fn(),
  },
}));

const loggerMock = logger as unknown as { warn: jest.Mock };
const notificationModelMock = NotificationModel as unknown as {
  create: jest.Mock;
  insertMany: jest.Mock;
};

describe('service notification emitters', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('omits patient identifiers from submitted-request failure logs', async () => {
    notificationModelMock.insertMany.mockRejectedValue(new Error('mongo unavailable'));

    await emitServiceRequestSubmitted({ patientId: 'patient-id-1' });

    const logPayload = loggerMock.warn.mock.calls[0][0];
    expect(JSON.stringify(logPayload)).not.toContain('patient-id-1');
    expect(logPayload).toMatchObject({
      metric: 'notification_emit_failure',
      type: 'SERVICE_REQUEST_SUBMITTED',
    });
  });

  it('omits patient and recipient identifiers from decision failure logs', async () => {
    notificationModelMock.create.mockRejectedValue(new Error('mongo unavailable'));

    await emitServiceRequestDecided({
      patientId: 'patient-id-1',
      recipientUserId: 'user-id-1',
      approved: true,
      serviceName: 'Sensitive Support Group',
    });

    const logPayload = loggerMock.warn.mock.calls[0][0];
    expect(JSON.stringify(logPayload)).not.toContain('patient-id-1');
    expect(JSON.stringify(logPayload)).not.toContain('user-id-1');
    expect(JSON.stringify(logPayload)).not.toContain('Sensitive Support Group');
    expect(logPayload).toMatchObject({
      metric: 'notification_emit_failure',
      type: 'SERVICE_REQUEST_DECIDED',
      approved: true,
    });
  });
});
