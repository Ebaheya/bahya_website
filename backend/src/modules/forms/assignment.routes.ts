import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as assignmentController from './assignment.controller';
import * as formController from './form.controller';

export const assignmentRouter = Router();

assignmentRouter.use(authenticate);

assignmentRouter.get('/my', authorize('PATIENT', 'VOLUNTEER'), assignmentController.my);
assignmentRouter.patch(
  '/:id/cancel',
  authorize('DOCTOR', 'ADMIN'),
  formController.cancelAssignment
);
assignmentRouter.get(
  '/:id',
  authorize('PATIENT', 'VOLUNTEER', 'DOCTOR', 'ADMIN'),
  assignmentController.getById
);
assignmentRouter.post(
  '/:id/submit',
  authorize('PATIENT', 'VOLUNTEER'),
  assignmentController.submit
);
