import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './form.controller';

export const assignmentRouter = Router();

assignmentRouter.use(authenticate);

assignmentRouter.patch('/:id/cancel', authorize('DOCTOR', 'ADMIN'), controller.cancelAssignment);
