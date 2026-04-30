import { Router } from 'express';
import mongoose from 'mongoose';
import { prisma } from '../config/prisma';
import { authRouter } from '../modules/auth/auth.routes';

export const apiRouter = Router();

/** Resolve to `true` after the given ms — used to cap health probe duration. */
function timeout(ms: number): Promise<false> {
  return new Promise((resolve) => setTimeout(() => resolve(false), ms).unref());
}

// PostgreSQL probe budget: 900 ms (under the 1 s success criterion).
// If Prisma's driver timeout or an unreachable host would take longer,
// this cap ensures the health endpoint returns postgres: "down" within
// the required window so load balancers get a timely response.
const PG_PROBE_TIMEOUT_MS = 900;

apiRouter.get('/health', async (_req, res) => {
  // Check PostgreSQL by running a trivial query, bounded by PG_PROBE_TIMEOUT_MS.
  let pgStatus: 'up' | 'down' = 'down';
  try {
    const pgOk = await Promise.race([
      prisma.$queryRaw`SELECT 1`.then(() => true as const),
      timeout(PG_PROBE_TIMEOUT_MS),
    ]);
    if (pgOk) pgStatus = 'up';
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
