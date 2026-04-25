import express, { type Express } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import pinoHttp from 'pino-http';
import { corsOrigins, corsCredentials } from './config/env';
import { logger } from './config/logger';
import { apiRouter } from './routes';
import { requestId } from './middleware/requestId';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';

export function createApp(): Express {
  const app = express();

  app.disable('x-powered-by');
  app.set('trust proxy', 1);

  app.use(requestId);
  app.use(
    pinoHttp({
      logger,
      customProps: (req) => ({ reqId: (req as { id?: string }).id }),
      serializers: {
        req: (req) => ({ method: req.method, url: req.url, id: req.id }),
      },
    })
  );

  app.use(helmet());
  app.use(
    cors({
      origin: corsOrigins,
      // credentials only when a real allow-list is set; wildcard + credentials
      // is rejected by browsers and is a security posture issue.
      credentials: corsCredentials,
    })
  );
  app.use(express.json({ limit: '1mb' }));
  app.use(express.urlencoded({ extended: true }));

  app.use('/api/v1', apiRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
