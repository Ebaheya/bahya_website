import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './category.controller';

export const categoryRouter = Router();

categoryRouter.use(authenticate);

categoryRouter.get('/', controller.list);
categoryRouter.post('/', authorize('ADMIN', 'DOCTOR'), controller.create);
categoryRouter.patch('/:id/status', authorize('ADMIN', 'DOCTOR'), controller.setStatus);
categoryRouter.patch('/:id', authorize('ADMIN', 'DOCTOR'), controller.update);
