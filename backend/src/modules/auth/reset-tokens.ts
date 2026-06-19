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
  id: string;
  rawToken: string;
  tokenHash: string;
  expiresAt: Date;
}

export async function issueResetToken(userId: string): Promise<IssuedResetToken> {
  const now = new Date();
  const rawToken = crypto.randomBytes(64).toString('hex');
  const tokenHash = hashResetToken(rawToken);
  const expiresAt = new Date(now.getTime() + env.RESET_TOKEN_TTL_MINUTES * 60 * 1000);

  const token = await prisma.$transaction(async (tx) => {
    // Serialize issuance per user so concurrent reset requests cannot both
    // leave an unused token active.
    await tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtext('password_reset_token'), hashtext(${userId}))`;

    await tx.passwordResetToken.updateMany({
      where: { userId, usedAt: null },
      data: { usedAt: now },
    });

    return tx.passwordResetToken.create({
      data: { userId, tokenHash, expiresAt },
      select: { id: true },
    });
  });

  return { id: token.id, rawToken, tokenHash, expiresAt };
}

export async function invalidateResetToken(tokenId: string): Promise<void> {
  await prisma.passwordResetToken.updateMany({
    where: { id: tokenId, usedAt: null },
    data: { usedAt: new Date() },
  });
}
