import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './user.controller';

export const userRouter = Router();

userRouter.use(authenticate, authorize('ADMIN'));

userRouter.get('/', controller.list);
userRouter.get('/:id', controller.getById);
userRouter.patch('/:id', controller.patch);
userRouter.patch('/:id/status', controller.patchStatus);
userRouter.post('/:id/trigger-reset', controller.triggerReset);
