import crypto from 'node:crypto';
import { prisma } from '../../config/prisma';
import { env } from '../../config/env';

export function hashResetToken(rawToken: string): string {
  return crypto.createHash('sha256').update(rawToken).digest('hex');
}

export function buildResetUrl(rawToken: string): string {
  const resetUrl = new URL('/reset-password', env.APP_URL);
  resetUrl.searchParams.set('token', rawToken);
  return resetUrl.toString();
}

export interface IssuedResetToken {
  rawToken: string;
  tokenHash: string;
  expiresAt: Date;
}

export async function issueResetToken(userId: string): Promise<IssuedResetToken> {
  const now = new Date();
  const rawToken = crypto.randomBytes(64).toString('hex');
  const tokenHash = hashResetToken(rawToken);
  const expiresAt = new Date(now.getTime() + env.RESET_TOKEN_TTL_MINUTES * 60 * 1000);

  await prisma.$transaction([
    prisma.passwordResetToken.updateMany({
      where: { userId, usedAt: null },
      data: { usedAt: now },
    }),
    prisma.passwordResetToken.create({
      data: { userId, tokenHash, expiresAt },
    }),
  ]);

  return { rawToken, tokenHash, expiresAt };
}
