import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './dashboard.controller';

export const dashboardRouter = Router();

dashboardRouter.use(authenticate);

dashboardRouter.get('/summary', authorize('ADMIN'), controller.summary);
dashboardRouter.get('/activity', authorize('ADMIN'), controller.activity);
