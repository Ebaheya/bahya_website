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
  severity: string;
  templateKey?: string;
}

function normalizeHighRiskSeverity(severity: string): NotificationSeverity {
  return severity === 'CRITICAL' ? 'CRITICAL' : 'HIGH';
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
        err,
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
      severity: normalizeHighRiskSeverity(input.severity),
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
        err,
      },
      'notification emit failed'
    );
  }
}
