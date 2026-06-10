import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './request.controller';

export const requestRouter = Router();

requestRouter.use(authenticate);

requestRouter.get('/my', authorize('PATIENT'), controller.listMy);
requestRouter.get('/summary', authorize('ADMIN', 'DOCTOR'), controller.summary);
requestRouter.get('/', authorize('ADMIN', 'DOCTOR'), controller.listQueue);
requestRouter.patch('/:id/approve', authorize('ADMIN', 'DOCTOR'), controller.approve);
requestRouter.patch('/:id/reject', authorize('ADMIN', 'DOCTOR'), controller.reject);
requestRouter.patch('/:id/cancel', authorize('PATIENT'), controller.cancel);
