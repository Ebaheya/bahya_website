import { logger } from '../../config/logger';
import {
  NotificationModel,
  type NotificationRecipientRole,
  type NotificationSeverity,
} from './notification.model';

export interface FormAssignedNotificationInput {
  patientId: string;
  recipientRole: Extract<NotificationRecipientRole, 'PATIENT' | 'VOLUNTEER'>;
  recipientUserId: string;
  assignmentId?: string;
  formName?: string;
}

export interface HighRiskAlertInput {
  patientId: string;
  submissionId?: string;
  severity: Extract<NotificationSeverity, 'HIGH' | 'CRITICAL'>;
  templateKey?: string;
}

export interface ServiceRequestSubmittedInput {
  patientId: string;
}

export interface ServiceRequestDecidedInput {
  patientId: string;
  recipientUserId: string;
  approved: boolean;
  serviceName: string;
}

function loggableError(err: unknown): { name?: string; message: string } {
  if (err instanceof Error) return { name: err.name, message: err.message };
  return { message: String(err) };
}

export async function emitFormAssigned(input: FormAssignedNotificationInput): Promise<void> {
  try {
    await NotificationModel.create({
      recipientRole: input.recipientRole,
      recipientUserId: input.recipientUserId,
      patientId: input.patientId,
      type: 'FORM_ASSIGNED',
      title: 'Assessment form assigned',
      message: input.formName ? `A new form is available: ${input.formName}` : 'A new form is available.',
      severity: 'LOW',
      reason: input.assignmentId ?? null,
      doctorNote: null,
      status: 'UNREAD',
      claimedAt: null,
      readAt: null,
      doneAt: null,
      createdAt: new Date(),
    });
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_emit_failure',
        type: 'FORM_ASSIGNED',
        patientId: input.patientId,
        recipientRole: input.recipientRole,
        recipientUserId: input.recipientUserId,
        err: loggableError(err),
      },
      'notification emit failed'
    );
  }
}

export async function emitHighRiskAlert(input: HighRiskAlertInput): Promise<void> {
  try {
    await NotificationModel.create({
      recipientRole: 'DOCTOR',
      recipientUserId: null,
      patientId: input.patientId,
      type: 'HIGH_RISK',
      title: 'High-risk assessment submitted',
      message: input.templateKey
        ? `A high-risk ${input.templateKey} submission needs review.`
        : 'A high-risk form submission needs review.',
      severity: input.severity,
      reason: input.submissionId ?? null,
      doctorNote: null,
      status: 'UNREAD',
      claimedAt: null,
      readAt: null,
      doneAt: null,
      createdAt: new Date(),
    });
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_emit_failure',
        type: 'HIGH_RISK',
        patientId: input.patientId,
        severity: input.severity,
        err: loggableError(err),
      },
      'notification emit failed'
    );
  }
}

export async function emitServiceRequestSubmitted(
  input: ServiceRequestSubmittedInput
): Promise<void> {
  try {
    const createdAt = new Date();
    await NotificationModel.insertMany(
      (['ADMIN', 'DOCTOR'] as const).map((recipientRole) => ({
        recipientRole,
        recipientUserId: null,
        patientId: input.patientId,
        type: 'SERVICE_REQUEST_SUBMITTED',
        title: 'Service request submitted',
        message: 'A patient submitted a new service join request.',
        severity: 'MEDIUM',
        reason: null,
        doctorNote: null,
        status: 'UNREAD',
        claimedAt: null,
        readAt: null,
        doneAt: null,
        createdAt,
      }))
    );
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_emit_failure',
        type: 'SERVICE_REQUEST_SUBMITTED',
        err: loggableError(err),
      },
      'notification emit failed'
    );
  }
}

export async function emitServiceRequestDecided(
  input: ServiceRequestDecidedInput
): Promise<void> {
  try {
    await NotificationModel.create({
      recipientRole: 'PATIENT',
      recipientUserId: input.recipientUserId,
      patientId: input.patientId,
      type: 'SERVICE_REQUEST_DECIDED',
      title: input.approved ? 'Service request approved' : 'Service request rejected',
      message: input.approved
        ? `Your request for ${input.serviceName} was approved.`
        : `Your request for ${input.serviceName} was rejected.`,
      severity: 'LOW',
      reason: null,
      doctorNote: null,
      status: 'UNREAD',
      claimedAt: null,
      readAt: null,
      doneAt: null,
      createdAt: new Date(),
    });
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_emit_failure',
        type: 'SERVICE_REQUEST_DECIDED',
        approved: input.approved,
        err: loggableError(err),
      },
      'notification emit failed'
    );
  }
}
