import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';

export const formRouter = Router();

formRouter.use(authenticate);
