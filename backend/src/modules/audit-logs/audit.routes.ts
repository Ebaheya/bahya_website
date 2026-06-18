import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { userRateLimiter } from '../../middleware/userRateLimit';
import * as controller from './audit.controller';

export const auditRouter = Router();

auditRouter.use(authenticate);
// Audit queries can scan the largest collection; bucket per user to bound cost.
auditRouter.use(userRateLimiter(60));

auditRouter.get('/', authorize('ADMIN'), controller.list);
auditRouter.get('/:id', authorize('ADMIN'), controller.detail);
