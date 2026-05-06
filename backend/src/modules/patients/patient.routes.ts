import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './patient.controller';

export const patientRouter = Router();

patientRouter.post(
  '/',
  authenticate,
  authorize('ADMIN', 'CALL_CENTER'),
  controller.create
);

patientRouter.get(
  '/',
  authenticate,
  authorize('ADMIN', 'DOCTOR', 'CALL_CENTER', 'VOLUNTEER'),
  controller.list
);

patientRouter.get(
  '/:id/timeline',
  authenticate,
  authorize('ADMIN', 'DOCTOR'),
  controller.timeline
);

patientRouter.get(
  '/:id',
  authenticate,
  authorize('ADMIN', 'DOCTOR', 'CALL_CENTER', 'VOLUNTEER', 'PATIENT'),
  controller.getById
);

patientRouter.patch(
  '/:id',
  authenticate,
  authorize('ADMIN', 'CALL_CENTER'),
  controller.patch
);
