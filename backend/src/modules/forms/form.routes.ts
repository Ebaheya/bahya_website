import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './form.controller';

export const formRouter = Router();

formRouter.use(authenticate);

formRouter.post('/', authorize('DOCTOR', 'ADMIN'), controller.create);
formRouter.get('/', authorize('DOCTOR', 'ADMIN'), controller.list);
formRouter.post('/:id/publish', authorize('DOCTOR', 'ADMIN'), controller.publish);
formRouter.get('/:id/assignments', authorize('DOCTOR', 'ADMIN'), controller.listAssignments);
formRouter.get('/:id', authorize('DOCTOR', 'ADMIN'), controller.getById);
formRouter.post('/:id/publish-version', authorize('DOCTOR', 'ADMIN'), controller.publishVersion);
