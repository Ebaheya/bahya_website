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
  '/options',
  authenticate,
  authorize('ADMIN', 'DOCTOR'),
  controller.listOptions
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
  // DOCTOR is permitted at the route level but restricted to clinical fields
  // inside the controller (see DOCTOR_EDITABLE_FIELDS); ADMIN/CALL_CENTER may
  // edit the full record.
  authorize('ADMIN', 'CALL_CENTER', 'DOCTOR'),
  controller.patch
);
