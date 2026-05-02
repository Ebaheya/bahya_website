import { Router } from 'express';
import mongoose from 'mongoose';
import { prisma } from '../config/prisma';
import { authRouter } from '../modules/auth/auth.routes';

export const apiRouter = Router();

// PostgreSQL probe budget: 900 ms (under the 1 s success criterion).
// Using $transaction timeout so Prisma signals server-side cancellation when
// the budget is exceeded, preventing orphaned queries from accumulating in the
// connection pool during outages or load-balancer health storms.
const PG_PROBE_TIMEOUT_MS = 900;

apiRouter.get('/health', async (_req, res) => {
  let pgStatus: 'up' | 'down' = 'down';
  try {
    await prisma.$transaction((tx) => tx.$queryRaw`SELECT 1`, {
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
