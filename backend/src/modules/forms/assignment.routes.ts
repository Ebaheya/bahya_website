import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { userRateLimiter } from '../../middleware/userRateLimit';
import * as assignmentController from './assignment.controller';
import * as formController from './form.controller';

export const assignmentRouter = Router();

// Submitting writes a scored submission and may trigger a high-risk alert, so it
// gets a tighter per-user bucket than ordinary reads.
const submitLimiter = userRateLimiter(20);

assignmentRouter.use(authenticate);
assignmentRouter.use(userRateLimiter(120));

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
  submitLimiter,
  authorize('PATIENT', 'VOLUNTEER'),
  assignmentController.submit
);
