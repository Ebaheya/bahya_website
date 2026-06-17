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

// Firebase rejects a multicast carrying more than 500 tokens, so a single
// role broadcast that resolves more devices than this must be split — otherwise
// the whole send throws and (being best-effort) is swallowed, silently dropping
// the push for every recipient.
const FCM_MULTICAST_LIMIT = 500;

function chunk<T>(items: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    chunks.push(items.slice(i, i + size));
  }
  return chunks;
}

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

    let anySuccess = false;
    for (const batch of chunk(tokens, FCM_MULTICAST_LIMIT)) {
      const response = await sendFcmMulticast(buildMessage(doc, batch));
      // null means FCM is disabled/unconfigured — no point trying further batches.
      if (!response) return;

      // Prune per batch so the index alignment with the batch's tokens holds.
      await pruneStaleTokens(batch, response);
      if (response.successCount > 0) anySuccess = true;
    }

    if (anySuccess) {
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
