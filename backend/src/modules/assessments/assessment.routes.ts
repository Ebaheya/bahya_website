import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';

export const assessmentRouter = Router();

assessmentRouter.use(authenticate);
