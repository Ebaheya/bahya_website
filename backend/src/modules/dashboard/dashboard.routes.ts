import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { userRateLimiter } from '../../middleware/userRateLimit';
import * as controller from './dashboard.controller';

export const dashboardRouter = Router();

dashboardRouter.use(authenticate);
// Each summary/activity call fans out to several aggregations; bucket per user
// so a single (admin) token cannot drive resource exhaustion.
dashboardRouter.use(userRateLimiter(60));

dashboardRouter.get('/summary', authorize('ADMIN'), controller.summary);
dashboardRouter.get('/activity', authorize('ADMIN'), controller.activity);
