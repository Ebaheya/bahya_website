import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { userRateLimiter } from '../../middleware/userRateLimit';
import * as controller from './chat.controller';

export const chatRouter = Router();

const messageLimiter = userRateLimiter(30);

chatRouter.use(authenticate);

chatRouter.post('/message', authorize('PATIENT'), messageLimiter, controller.sendMessage);
