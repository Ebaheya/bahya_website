import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';

export const assignmentRouter = Router();

assignmentRouter.use(authenticate);
