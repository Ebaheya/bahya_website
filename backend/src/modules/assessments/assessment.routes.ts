import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { userRateLimiter } from '../../middleware/userRateLimit';
import * as controller from './assessment.controller';

export const assessmentRouter = Router();

assessmentRouter.use(authenticate);
assessmentRouter.use(userRateLimiter(120));

assessmentRouter.get('/submissions/pending', authorize('DOCTOR', 'ADMIN'), controller.listPending);
assessmentRouter.get('/submissions/:id', authorize('DOCTOR', 'ADMIN'), controller.getSubmission);
assessmentRouter.post('/', authorize('DOCTOR'), controller.create);
assessmentRouter.get(
  '/patient/:patientId',
  authorize('DOCTOR', 'ADMIN', 'PATIENT'),
  controller.listByPatient
);
assessmentRouter.get('/:id', authorize('DOCTOR', 'ADMIN', 'PATIENT'), controller.getById);
