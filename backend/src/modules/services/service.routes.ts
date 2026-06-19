import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './service.controller';

export const serviceRouter = Router();

serviceRouter.use(authenticate);

serviceRouter.post('/', authorize('ADMIN', 'DOCTOR'), controller.create);
serviceRouter.get('/', controller.list);
serviceRouter.patch('/:id', authorize('ADMIN', 'DOCTOR'), controller.update);
serviceRouter.post('/:id/requests', authorize('PATIENT'), controller.createRequest);
serviceRouter.get('/:id', controller.getById);
