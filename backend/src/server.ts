import { createApp } from './app';
import { env } from './config/env';
import { logger } from './config/logger';
import { prisma, disconnectPrisma } from './config/prisma';
import { connectMongo, disconnectMongo } from './config/mongo';
import { pruneExpiredRefreshTokens } from './modules/auth/refreshToken.cleanup';
import { runDueAssignmentsSweep } from './modules/forms/publish.service';

const app = createApp();

// server is assigned inside start() and used by shutdown().
// The variable is declared in the outer scope so the signal handlers
// can reference it before start() resolves.
let server: ReturnType<typeof app.listen> | undefined;
const DUE_ASSIGNMENTS_SWEEP_INTERVAL_MS = 60 * 1000;

async function sweepDueFormAssignments(): Promise<void> {
  try {
    const promoted = await runDueAssignmentsSweep();
    if (promoted > 0) {
      logger.info({ promoted }, 'scheduled form assignments published');
    }
  } catch (err) {
    logger.warn({ err }, 'scheduled form assignment sweep failed');
  }
}

async function start(): Promise<void> {
  // Both datastores must be reachable before the backend accepts traffic.
  // Prisma lazy-connects on first query, so an explicit $connect() is needed
  // to surface unreachable PostgreSQL at startup instead of after app.listen().
  await Promise.all([connectMongo(), prisma.$connect()]);

  server = app.listen(env.PORT, () => {
    logger.info({ port: env.PORT, env: env.NODE_ENV }, 'server listening');
  });

  // Run once at boot, then every 6 hours. .unref() so the timer does not
  // prevent graceful shutdown when no other work is pending.
  void pruneExpiredRefreshTokens();
  setInterval(pruneExpiredRefreshTokens, 6 * 60 * 60 * 1000).unref();

  void sweepDueFormAssignments();
  setInterval(() => void sweepDueFormAssignments(), DUE_ASSIGNMENTS_SWEEP_INTERVAL_MS).unref();
}

async function shutdown(signal: string): Promise<void> {
  logger.info({ signal }, 'shutdown initiated');

  const cleanup = async (err?: Error): Promise<void> => {
    if (err) logger.error({ err }, 'error during server close');
    try {
      await disconnectPrisma();
    } catch (e) {
      logger.error({ err: e }, 'error disconnecting prisma');
    }
    try {
      await disconnectMongo();
    } catch (e) {
      logger.error({ err: e }, 'error disconnecting mongodb');
    }
    process.exit(err ? 1 : 0);
  };

  // If SIGTERM/SIGINT arrives before app.listen() has run (e.g. during the
  // datastore connect phase), server is still undefined — skip .close() and
  // go straight to resource cleanup.
  if (server) {
    server.close((err) => void cleanup(err ?? undefined));
  } else {
    void cleanup();
  }

  setTimeout(() => {
    logger.warn('forcing shutdown after 10s');
    process.exit(1);
  }, 10_000).unref();
}

process.on('SIGTERM', () => void shutdown('SIGTERM'));
process.on('SIGINT', () => void shutdown('SIGINT'));

process.on('unhandledRejection', (reason) => {
  logger.fatal({ reason }, 'unhandled promise rejection — exiting');
  process.exit(1);
});
process.on('uncaughtException', (err) => {
  logger.fatal({ err }, 'uncaught exception');
  process.exit(1);
});

// Explicit catch ensures that a connectMongo() failure (or any other startup
// rejection) terminates the process with a non-zero code instead of hanging
// on open driver handles or silently exiting with code 0.
start().catch((err: unknown) => {
  logger.fatal({ err }, 'fatal: server failed to start');
  process.exit(1);
});
