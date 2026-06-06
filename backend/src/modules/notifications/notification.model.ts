import { Schema, model, models } from 'mongoose';

export type NotificationRecipientRole = 'DOCTOR' | 'CALL_CENTER' | 'VOLUNTEER' | 'PATIENT';
export type NotificationType =
  | 'FORM_ASSIGNED'
  | 'HIGH_RISK'
  | 'BOOKING_REQUIRED'
  | 'DOCTOR_REVIEW'
  | 'FOLLOW_UP_REQUIRED';
export type NotificationSeverity = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
export type NotificationStatus = 'UNREAD' | 'READ' | 'DONE';

export interface NotificationDoc {
  recipientRole: NotificationRecipientRole;
  recipientUserId: string | null;
  patientId: string;
  type: NotificationType;
  title: string;
  message: string;
  severity: NotificationSeverity;
  reason: string | null;
  doctorNote: string | null;
  status: NotificationStatus;
  claimedAt: Date | null;
  readAt: Date | null;
  doneAt: Date | null;
  createdAt: Date;
}

const NotificationSchema = new Schema<NotificationDoc>(
  {
    recipientRole: {
      type: String,
      enum: ['DOCTOR', 'CALL_CENTER', 'VOLUNTEER', 'PATIENT'],
      required: true,
    },
    recipientUserId: { type: String, default: null },
    patientId: { type: String, required: true },
    type: {
      type: String,
      enum: ['FORM_ASSIGNED', 'HIGH_RISK', 'BOOKING_REQUIRED', 'DOCTOR_REVIEW', 'FOLLOW_UP_REQUIRED'],
      required: true,
    },
    title: { type: String, required: true },
    message: { type: String, required: true },
    severity: { type: String, enum: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'], required: true },
    reason: { type: String, default: null },
    doctorNote: { type: String, default: null },
    status: { type: String, enum: ['UNREAD', 'READ', 'DONE'], default: 'UNREAD', required: true },
    claimedAt: { type: Date, default: null },
    readAt: { type: Date, default: null },
    doneAt: { type: Date, default: null },
    createdAt: { type: Date, required: true },
  },
  { collection: 'notifications', versionKey: false, strict: 'throw' }
);

NotificationSchema.index({ recipientRole: 1, status: 1, createdAt: -1 });
NotificationSchema.index({ recipientUserId: 1, status: 1, createdAt: -1 });
NotificationSchema.index({ patientId: 1, createdAt: -1 });

export const NotificationModel =
  models.Notification ?? model<NotificationDoc>('Notification', NotificationSchema);
