import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './audit.controller';

export const auditRouter = Router();

auditRouter.use(authenticate);

auditRouter.get('/', authorize('ADMIN'), controller.list);
auditRouter.get('/:id', authorize('ADMIN'), controller.detail);
