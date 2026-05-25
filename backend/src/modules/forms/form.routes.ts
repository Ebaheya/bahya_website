import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './form.controller';

export const formRouter = Router();

formRouter.use(authenticate);

formRouter.post('/', authorize('DOCTOR', 'ADMIN'), controller.create);
formRouter.get('/', authorize('DOCTOR', 'ADMIN'), controller.list);
formRouter.put('/:id', authorize('DOCTOR', 'ADMIN'), controller.update);
formRouter.patch('/:id/status', authorize('DOCTOR', 'ADMIN'), controller.setStatus);
formRouter.post('/:id/publish', authorize('DOCTOR', 'ADMIN'), controller.publish);
formRouter.get('/:id/assignments', authorize('DOCTOR', 'ADMIN'), controller.listAssignments);
formRouter.get('/:id/versions', authorize('DOCTOR', 'ADMIN'), controller.listVersions);
formRouter.get('/:id/versions/:version', authorize('DOCTOR', 'ADMIN'), controller.getVersion);
formRouter.get('/:id', authorize('DOCTOR', 'ADMIN'), controller.getById);
formRouter.post('/:id/publish-version', authorize('DOCTOR', 'ADMIN'), controller.publishVersion);
