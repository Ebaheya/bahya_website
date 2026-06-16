import { logger } from '../../config/logger';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { NotificationModel } from './notification.model';
import { pushForNotification } from './push.service';
import {
  claimNotification,
  emitServiceRequestDecided,
  emitServiceRequestSubmitted,
  listMyNotifications,
  markDone,
  markRead,
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
    find: jest.fn(),
    countDocuments: jest.fn(),
    findOneAndUpdate: jest.fn(),
    findById: jest.fn(),
  },
}));

jest.mock('../../config/prisma', () => ({
  prisma: { patient: { findMany: jest.fn() } },
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

jest.mock('./push.service', () => ({
  pushForNotification: jest.fn(),
}));

const loggerMock = logger as unknown as { warn: jest.Mock };
const writeAuditMock = writeAudit as jest.Mock;
const pushForNotificationMock = pushForNotification as jest.Mock;
const notificationModelMock = NotificationModel as unknown as {
  create: jest.Mock;
  insertMany: jest.Mock;
  find: jest.Mock;
  countDocuments: jest.Mock;
  findOneAndUpdate: jest.Mock;
  findById: jest.Mock;
};
const prismaMock = prisma as unknown as { patient: { findMany: jest.Mock } };

// Mongoose query chain stub: find().sort().skip().limit().lean()
function findChain(result: unknown[]) {
  return {
    sort: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    lean: jest.fn().mockResolvedValue(result),
  };
}

// Mongoose query stub for a single-doc query terminated by .lean()
function leanResult(result: unknown) {
  return { lean: jest.fn().mockResolvedValue(result) };
}

describe('service notification emitters', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    pushForNotificationMock.mockResolvedValue(undefined);
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

  it('triggers best-effort push after a notification is created', async () => {
    const created = { _id: 'n1', type: 'SERVICE_REQUEST_DECIDED' };
    notificationModelMock.create.mockResolvedValue(created);

    await emitServiceRequestDecided({
      patientId: 'patient-id-1',
      recipientUserId: 'patient-user-1',
      approved: true,
      serviceName: 'Support',
    });

    expect(pushForNotificationMock).toHaveBeenCalledWith(created);
  });

  it('triggers push for every inserted broadcast notification and swallows push failures', async () => {
    const inserted = [
      { _id: 'n1', type: 'SERVICE_REQUEST_SUBMITTED', recipientRole: 'ADMIN' },
      { _id: 'n2', type: 'SERVICE_REQUEST_SUBMITTED', recipientRole: 'DOCTOR' },
    ];
    notificationModelMock.insertMany.mockResolvedValue(inserted);
    pushForNotificationMock.mockRejectedValueOnce(new Error('fcm unavailable'));

    await emitServiceRequestSubmitted({ patientId: 'patient-id-1' });

    expect(pushForNotificationMock).toHaveBeenCalledTimes(2);
    expect(pushForNotificationMock).toHaveBeenNthCalledWith(1, inserted[0]);
    expect(pushForNotificationMock).toHaveBeenNthCalledWith(2, inserted[1]);
    expect(loggerMock.warn).toHaveBeenCalledWith(
      expect.objectContaining({
        metric: 'notification_push_failure',
        type: 'SERVICE_REQUEST_SUBMITTED',
      }),
      'notification push failed'
    );
  });
});

describe('markRead / markDone', () => {
  const ID = '64b2f0000000000000000001';

  beforeEach(() => {
    jest.clearAllMocks();
    writeAuditMock.mockResolvedValue(undefined);
  });

  it('marks an owned unread notification read and audits the transition', async () => {
    const updatedDoc = {
      _id: ID,
      type: 'SERVICE_REQUEST_DECIDED',
      severity: 'LOW',
      status: 'READ',
      title: 'Service request approved',
      message: 'Your request was approved.',
      doctorNote: null,
      claimedAt: null,
      readAt: new Date('2026-06-15T03:00:00Z'),
      doneAt: null,
      createdAt: new Date('2026-06-15T00:00:00Z'),
      patientId: 'p1',
      recipientRole: 'PATIENT',
      recipientUserId: 'patient-user',
    };
    notificationModelMock.findOneAndUpdate.mockReturnValue(leanResult(updatedDoc));

    const result = await markRead({ id: 'patient-user', role: 'PATIENT' }, ID);

    expect(notificationModelMock.findOneAndUpdate).toHaveBeenCalledWith(
      { _id: ID, recipientUserId: 'patient-user', status: 'UNREAD' },
      { $set: { status: 'READ', readAt: expect.any(Date) } },
      { new: true }
    );
    expect(result).toMatchObject({ id: ID, status: 'READ', readAt: updatedDoc.readAt });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: 'patient-user',
        action: 'NOTIFICATION_READ',
        entityType: 'NOTIFICATION',
        entityId: ID,
        oldValues: { status: 'UNREAD' },
        newValues: { status: 'READ' },
      })
    );
  });

  it('marks unread directly done, keeps readAt null, and audits the transition', async () => {
    const doneAt = new Date('2026-06-15T04:00:00Z');
    const updatedDoc = {
      _id: ID,
      type: 'SERVICE_REQUEST_DECIDED',
      severity: 'LOW',
      status: 'DONE',
      title: 'Service request approved',
      message: 'Your request was approved.',
      doctorNote: null,
      claimedAt: null,
      readAt: null,
      doneAt,
      createdAt: new Date('2026-06-15T00:00:00Z'),
      patientId: 'p1',
      recipientRole: 'PATIENT',
      recipientUserId: 'patient-user',
    };
    notificationModelMock.findOneAndUpdate.mockReturnValue(leanResult(updatedDoc));

    const result = await markDone({ id: 'patient-user', role: 'PATIENT' }, ID);

    expect(notificationModelMock.findOneAndUpdate).toHaveBeenCalledWith(
      { _id: ID, recipientUserId: 'patient-user', status: { $in: ['UNREAD', 'READ'] } },
      { $set: { status: 'DONE', doneAt: expect.any(Date) } },
      { new: true }
    );
    expect(result).toMatchObject({ id: ID, status: 'DONE', readAt: null, doneAt });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: 'patient-user',
        action: 'NOTIFICATION_DONE',
        entityType: 'NOTIFICATION',
        entityId: ID,
        oldValues: { status: 'UNREAD_OR_READ' },
        newValues: { status: 'DONE' },
      })
    );
  });

  it('forbids read/done when the caller does not own the notification', async () => {
    notificationModelMock.findOneAndUpdate.mockReturnValue(leanResult(null));
    notificationModelMock.findById.mockReturnValue(
      leanResult({ _id: ID, recipientUserId: 'other-user', recipientRole: 'PATIENT', status: 'UNREAD' })
    );

    await expect(markRead({ id: 'patient-user', role: 'PATIENT' }, ID)).rejects.toMatchObject({
      statusCode: 403,
      code: 'NOT_RECIPIENT',
    });
    await expect(markDone({ id: 'patient-user', role: 'PATIENT' }, ID)).rejects.toMatchObject({
      statusCode: 403,
      code: 'NOT_RECIPIENT',
    });
    expect(writeAuditMock).not.toHaveBeenCalled();
  });

  it('rejects backward or repeated transitions with 409', async () => {
    notificationModelMock.findOneAndUpdate.mockReturnValue(leanResult(null));
    notificationModelMock.findById.mockReturnValue(
      leanResult({ _id: ID, recipientUserId: 'patient-user', recipientRole: 'PATIENT', status: 'DONE' })
    );

    await expect(markRead({ id: 'patient-user', role: 'PATIENT' }, ID)).rejects.toMatchObject({
      statusCode: 409,
      code: 'ILLEGAL_TRANSITION',
    });
    await expect(markDone({ id: 'patient-user', role: 'PATIENT' }, ID)).rejects.toMatchObject({
      statusCode: 409,
      code: 'ILLEGAL_TRANSITION',
    });
    expect(writeAuditMock).not.toHaveBeenCalled();
  });

  it('returns not found when the notification does not exist', async () => {
    notificationModelMock.findOneAndUpdate.mockReturnValue(leanResult(null));
    notificationModelMock.findById.mockReturnValue(leanResult(null));

    await expect(markRead({ id: 'patient-user', role: 'PATIENT' }, ID)).rejects.toMatchObject({
      statusCode: 404,
    });
  });
});

describe('listMyNotifications', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns personal + unclaimed-broadcast notifications with live patient contact', async () => {
    const docs = [
      {
        _id: 'n1',
        type: 'SERVICE_REQUEST_DECIDED',
        severity: 'LOW',
        status: 'UNREAD',
        title: 'Service request approved',
        message: 'Your request was approved.',
        doctorNote: null,
        claimedAt: null,
        readAt: null,
        doneAt: null,
        createdAt: new Date('2026-06-15T00:00:00Z'),
        patientId: 'p1',
        recipientRole: 'PATIENT',
        recipientUserId: 'u1',
      },
    ];
    const chain = findChain(docs);
    notificationModelMock.find.mockReturnValue(chain);
    notificationModelMock.countDocuments.mockResolvedValue(1);
    prismaMock.patient.findMany.mockResolvedValue([
      { id: 'p1', phone: '+201234567890', user: { fullName: 'Sara Ali' } },
    ]);

    const result = await listMyNotifications({ id: 'u1', role: 'PATIENT' }, { page: 1, pageSize: 20 });

    expect(notificationModelMock.find).toHaveBeenCalledWith({
      $or: [
        { recipientUserId: 'u1' },
        { recipientRole: 'PATIENT', recipientUserId: null },
      ],
    });
    expect(chain.sort).toHaveBeenCalledWith({ createdAt: -1 });
    expect(chain.skip).toHaveBeenCalledWith(0);
    expect(chain.limit).toHaveBeenCalledWith(20);
    expect(result).toEqual({
      data: [
        {
          id: 'n1',
          type: 'SERVICE_REQUEST_DECIDED',
          severity: 'LOW',
          status: 'UNREAD',
          title: 'Service request approved',
          message: 'Your request was approved.',
          doctorNote: null,
          claimedAt: null,
          readAt: null,
          doneAt: null,
          createdAt: new Date('2026-06-15T00:00:00Z'),
          patient: { id: 'p1', fullName: 'Sara Ali', phone: '+201234567890' },
        },
      ],
      page: 1,
      pageSize: 20,
      total: 1,
    });
  });

  it('applies status/severity filters and pagination offset', async () => {
    const chain = findChain([]);
    notificationModelMock.find.mockReturnValue(chain);
    notificationModelMock.countDocuments.mockResolvedValue(0);

    await listMyNotifications(
      { id: 'u9', role: 'DOCTOR' },
      { status: 'UNREAD', severity: 'HIGH', page: 3, pageSize: 10 }
    );

    expect(notificationModelMock.find).toHaveBeenCalledWith({
      $or: [
        { recipientUserId: 'u9' },
        { recipientRole: 'DOCTOR', recipientUserId: null },
      ],
      status: 'UNREAD',
      severity: 'HIGH',
    });
    expect(chain.skip).toHaveBeenCalledWith(20); // (3 - 1) * 10
    expect(chain.limit).toHaveBeenCalledWith(10);
    // No notifications → no patient lookup.
    expect(prismaMock.patient.findMany).not.toHaveBeenCalled();
  });

  it('degrades patient contact to null when the patient cannot be read', async () => {
    const docs = [
      {
        _id: 'n2',
        type: 'HIGH_RISK',
        severity: 'CRITICAL',
        status: 'UNREAD',
        title: 'High-risk',
        message: 'Needs review',
        doctorNote: null,
        claimedAt: null,
        readAt: null,
        doneAt: null,
        createdAt: new Date('2026-06-15T00:00:00Z'),
        patientId: 'gone',
        recipientRole: 'DOCTOR',
        recipientUserId: null,
      },
    ];
    notificationModelMock.find.mockReturnValue(findChain(docs));
    notificationModelMock.countDocuments.mockResolvedValue(1);
    prismaMock.patient.findMany.mockResolvedValue([]); // patient no longer exists

    const result = await listMyNotifications({ id: 'u9', role: 'DOCTOR' }, { page: 1, pageSize: 20 });

    expect(result.data[0].patient).toBeNull();
  });
});

describe('claimNotification', () => {
  const ID = '64b2f0000000000000000001';

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('atomically claims an unclaimed broadcast for the caller', async () => {
    const claimedDoc = {
      _id: 'n1',
      type: 'SERVICE_REQUEST_SUBMITTED',
      severity: 'MEDIUM',
      status: 'UNREAD',
      title: 'Service request submitted',
      message: 'A patient submitted a new service join request.',
      doctorNote: null,
      claimedAt: new Date('2026-06-15T01:00:00Z'),
      readAt: null,
      doneAt: null,
      createdAt: new Date('2026-06-15T00:00:00Z'),
      patientId: 'p1',
      recipientRole: 'DOCTOR',
      recipientUserId: 'doc1',
    };
    notificationModelMock.findOneAndUpdate.mockReturnValue(leanResult(claimedDoc));

    const result = await claimNotification({ id: 'doc1', role: 'DOCTOR' }, ID);

    expect(notificationModelMock.findOneAndUpdate).toHaveBeenCalledWith(
      { _id: ID, recipientUserId: null, recipientRole: 'DOCTOR' },
      { $set: { recipientUserId: 'doc1', claimedAt: expect.any(Date) } },
      { new: true }
    );
    expect(result).toMatchObject({ id: 'n1', status: 'UNREAD' });
    expect(notificationModelMock.findById).not.toHaveBeenCalled();
  });

  it('returns a conflict (409) when the notification is already claimed', async () => {
    notificationModelMock.findOneAndUpdate.mockReturnValue(leanResult(null));
    notificationModelMock.findById.mockReturnValue(
      leanResult({ _id: 'n1', recipientRole: 'DOCTOR', recipientUserId: 'other-doc' })
    );

    await expect(claimNotification({ id: 'doc1', role: 'DOCTOR' }, ID)).rejects.toMatchObject({
      statusCode: 409,
      code: 'CLAIM_CONFLICT',
    });
  });

  it('forbids (403) claiming a notification addressed to another role', async () => {
    notificationModelMock.findOneAndUpdate.mockReturnValue(leanResult(null));
    notificationModelMock.findById.mockReturnValue(
      leanResult({ _id: 'n1', recipientRole: 'CALL_CENTER', recipientUserId: null })
    );

    await expect(claimNotification({ id: 'doc1', role: 'DOCTOR' }, ID)).rejects.toMatchObject({
      statusCode: 403,
      code: 'NOT_RECIPIENT',
    });
  });

  it('returns not found (404) when the notification does not exist', async () => {
    notificationModelMock.findOneAndUpdate.mockReturnValue(leanResult(null));
    notificationModelMock.findById.mockReturnValue(leanResult(null));

    await expect(claimNotification({ id: 'doc1', role: 'DOCTOR' }, ID)).rejects.toMatchObject({
      statusCode: 404,
    });
  });
});
