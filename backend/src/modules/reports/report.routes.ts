import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { userRateLimiter } from '../../middleware/userRateLimit';
import * as controller from './report.controller';

export const reportRouter = Router();

const fileReportLimiter = userRateLimiter(10);

reportRouter.use(authenticate);

reportRouter.post('/', fileReportLimiter, controller.create);
reportRouter.get('/summary', authorize('ADMIN'), controller.summary);
reportRouter.get('/', authorize('ADMIN'), controller.list);
reportRouter.get('/:id', authorize('ADMIN'), controller.detail);
reportRouter.patch('/:id/status', authorize('ADMIN'), controller.changeStatus);
