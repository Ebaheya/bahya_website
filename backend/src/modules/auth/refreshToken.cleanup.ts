import { prisma } from '../../config/prisma';
import { logger } from '../../config/logger';

// Removes rows that are either expired or have been revoked for more than 30 days.
// Called on server boot and every 6 hours. Failures are logged and do not crash the server.
export async function pruneExpiredRefreshTokens(): Promise<void> {
  try {
    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    const { count } = await prisma.refreshToken.deleteMany({
      where: {
        OR: [
          { expiresAt: { lt: now } },
          { revokedAt: { lt: thirtyDaysAgo } },
        ],
      },
    });

    if (count > 0) {
      logger.info({ count }, 'pruned expired/revoked refresh tokens');
    }
  } catch (err) {
    logger.error({ err }, 'refresh token prune job failed');
  }
}
