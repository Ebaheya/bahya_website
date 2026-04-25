import { createApp } from './app';
import { env } from './config/env';
import { logger } from './config/logger';
import { disconnectPrisma } from './config/prisma';
import { pruneExpiredRefreshTokens } from './modules/auth/refreshToken.cleanup';

const app = createApp();

const server = app.listen(env.PORT, () => {
  logger.info({ port: env.PORT, env: env.NODE_ENV }, 'server listening');
});

// Run once at boot, then every 6 hours. .unref() so the timer does not
// prevent graceful shutdown when no other work is pending.
void pruneExpiredRefreshTokens();
setInterval(pruneExpiredRefreshTokens, 6 * 60 * 60 * 1000).unref();

async function shutdown(signal: string): Promise<void> {
  logger.info({ signal }, 'shutdown initiated');
  server.close(async (err) => {
    if (err) logger.error({ err }, 'error during server close');
    try {
      await disconnectPrisma();
    } catch (e) {
      logger.error({ err: e }, 'error disconnecting prisma');
    }
    process.exit(err ? 1 : 0);
  });

  setTimeout(() => {
    logger.warn('forcing shutdown after 10s');
    process.exit(1);
  }, 10_000).unref();
}

process.on('SIGTERM', () => void shutdown('SIGTERM'));
process.on('SIGINT', () => void shutdown('SIGINT'));

process.on('unhandledRejection', (reason) => {
  logger.error({ reason }, 'unhandled promise rejection');
});
process.on('uncaughtException', (err) => {
  logger.fatal({ err }, 'uncaught exception');
  process.exit(1);
});
