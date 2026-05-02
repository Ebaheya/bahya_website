import { Router } from 'express';
import mongoose from 'mongoose';
import { prisma } from '../config/prisma';
import { authRouter } from '../modules/auth/auth.routes';

export const apiRouter = Router();

// PostgreSQL probe budget: 900 ms total (under the 1 s success criterion).
// Split across Prisma's two interactive-transaction knobs so the probe can
// never exceed the budget even under pool contention:
//   - maxWait:  time allowed to acquire a connection slot from the pool.
//   - timeout:  time allowed for the query itself once a slot is held.
// Prisma defaults maxWait to 2000 ms, which would let /health block well past
// 1 s during outages and cause readiness/liveness flapping; we cap it tightly
// and reserve the remainder for the actual SELECT 1.
const PG_PROBE_MAX_WAIT_MS = 200;
const PG_PROBE_TIMEOUT_MS = 700;

apiRouter.get('/health', async (_req, res) => {
  let pgStatus: 'up' | 'down' = 'down';
  try {
    await prisma.$transaction((tx) => tx.$queryRaw`SELECT 1`, {
      maxWait: PG_PROBE_MAX_WAIT_MS,
      timeout: PG_PROBE_TIMEOUT_MS,
    });
    pgStatus = 'up';
  } catch {
    // intentionally swallowed — reported in the response body
  }

  // Check MongoDB via Mongoose connection readyState (1 = connected).
  const mongoStatus: 'up' | 'down' =
    mongoose.connection.readyState === 1 ? 'up' : 'down';

  const allUp = pgStatus === 'up' && mongoStatus === 'up';

  res.status(allUp ? 200 : 503).json({
    status: allUp ? 'ok' : 'degraded',
    timestamp: new Date().toISOString(),
    services: {
      postgres: pgStatus,
      mongo: mongoStatus,
    },
  });
});

apiRouter.use('/auth', authRouter);
