import type { Role } from '@prisma/client';
import type { BatchResponse, MulticastMessage } from 'firebase-admin/messaging';
import { logger } from '../../config/logger';
import { sendFcmMulticast } from '../../config/fcm';
import { prisma } from '../../config/prisma';
import {
  NotificationModel,
  type NotificationDoc,
  type NotificationRecipientRole,
  type NotificationType,
} from './notification.model';

type PushableNotification = NotificationDoc & { _id: unknown };

const STALE_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-argument',
]);

function notificationId(doc: PushableNotification): string {
  return String(doc._id);
}

function locKeys(type: NotificationType) {
  return {
    titleLocKey: `NOTIFICATION_${type}_TITLE`,
    bodyLocKey: `NOTIFICATION_${type}_BODY`,
  };
}

async function resolveTokens(doc: PushableNotification): Promise<string[]> {
  const where = doc.recipientUserId
    ? { userId: doc.recipientUserId }
    : {
        user: {
          is: {
            role: doc.recipientRole as Role,
            isActive: true,
          },
        },
      };

  const rows = await prisma.deviceToken.findMany({
    where,
    select: { token: true },
  });

  return rows.map((row) => row.token);
}

function buildMessage(doc: PushableNotification, tokens: string[]): MulticastMessage {
  const keys = locKeys(doc.type);
  return {
    tokens,
    data: {
      notificationId: notificationId(doc),
      type: doc.type,
    },
    android: {
      notification: {
        titleLocKey: keys.titleLocKey,
        bodyLocKey: keys.bodyLocKey,
      },
    },
    apns: {
      payload: {
        aps: {
          alert: {
            titleLocKey: keys.titleLocKey,
            locKey: keys.bodyLocKey,
          },
        },
      },
    },
  };
}

async function pruneStaleTokens(tokens: string[], response: BatchResponse): Promise<void> {
  const staleTokens = response.responses
    .map((r, index) => (!r.success && r.error && STALE_TOKEN_CODES.has(r.error.code) ? tokens[index] : null))
    .filter((token): token is string => Boolean(token));

  if (staleTokens.length > 0) {
    await prisma.deviceToken.deleteMany({
      where: { token: { in: staleTokens } },
    });
  }
}

export async function pushForNotification(doc: PushableNotification): Promise<void> {
  try {
    const tokens = await resolveTokens(doc);
    if (tokens.length === 0) return;

    const response = await sendFcmMulticast(buildMessage(doc, tokens));
    if (!response) return;

    await pruneStaleTokens(tokens, response);

    if (response.successCount > 0) {
      await NotificationModel.updateOne(
        { _id: doc._id },
        { $set: { pushedAt: new Date() } }
      );
    }
  } catch (err) {
    logger.warn(
      {
        metric: 'notification_push_failure',
        notificationId: notificationId(doc),
        type: doc.type,
        recipientRole: doc.recipientRole as NotificationRecipientRole,
        err: err instanceof Error ? { name: err.name, message: err.message } : { message: String(err) },
      },
      'notification push failed'
    );
  }
}
