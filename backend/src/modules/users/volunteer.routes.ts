import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './user.controller';

export const volunteerRouter = Router();

volunteerRouter.use(authenticate, authorize('DOCTOR', 'ADMIN'));

volunteerRouter.get('/', controller.listVolunteerOptions);
