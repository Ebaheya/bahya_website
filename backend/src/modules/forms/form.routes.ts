import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { userRateLimiter } from '../../middleware/userRateLimit';
import * as controller from './form.controller';

export const formRouter = Router();

// Publishing fans out one assignment + notification per active patient
// (ALL_PATIENTS), so it gets a tighter per-user bucket than ordinary actions.
const publishLimiter = userRateLimiter(10);

formRouter.use(authenticate);
formRouter.use(userRateLimiter(120));

formRouter.post('/', authorize('DOCTOR', 'ADMIN'), controller.create);
formRouter.get('/', authorize('DOCTOR', 'ADMIN'), controller.list);
formRouter.put('/:id', authorize('DOCTOR', 'ADMIN'), controller.update);
formRouter.patch('/:id/status', authorize('DOCTOR', 'ADMIN'), controller.setStatus);
formRouter.post('/:id/publish', publishLimiter, authorize('DOCTOR', 'ADMIN'), controller.publish);
formRouter.get('/:id/assignments', authorize('DOCTOR', 'ADMIN'), controller.listAssignments);
formRouter.get('/:id/versions', authorize('DOCTOR', 'ADMIN'), controller.listVersions);
formRouter.get('/:id/versions/:version', authorize('DOCTOR', 'ADMIN'), controller.getVersion);
formRouter.get('/:id', authorize('DOCTOR', 'ADMIN'), controller.getById);
formRouter.post('/:id/publish-version', authorize('DOCTOR', 'ADMIN'), controller.publishVersion);
