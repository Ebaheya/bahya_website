import { applicationDefault, cert, getApps, initializeApp } from 'firebase-admin/app';
import { getMessaging, type BatchResponse, type MulticastMessage } from 'firebase-admin/messaging';
import { env } from './env';

let initialized = false;

function credentialFromEnv() {
  if (env.FIREBASE_SERVICE_ACCOUNT) {
    const json = Buffer.from(env.FIREBASE_SERVICE_ACCOUNT, 'base64').toString('utf8');
    return cert(JSON.parse(json));
  }
  if (env.GOOGLE_APPLICATION_CREDENTIALS) return applicationDefault();
  return null;
}

function ensureFirebaseApp(): boolean {
  if (!env.FCM_ENABLED) return false;
  if (getApps().length > 0 || initialized) return true;

  const credential = credentialFromEnv();
  if (!credential) return false;

  initializeApp({ credential });
  initialized = true;
  return true;
}

export async function sendFcmMulticast(
  message: MulticastMessage
): Promise<BatchResponse | null> {
  if (message.tokens.length === 0 || !ensureFirebaseApp()) return null;
  return getMessaging().sendEachForMulticast(message);
}
