import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import * as controller from './auth.controller';

const authLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 20,
  standardHeaders: true,
  legacyHeaders: false,
});

const loginLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 10,
  standardHeaders: true,
  legacyHeaders: false,
});

export const authRouter = Router();

authRouter.post(
  '/register-staff',
  authLimiter,
  (req, res, next) => {
    if (req.header('x-bootstrap-secret')) return next();
    return authenticate(req, res, (err) => {
      if (err) return next(err);
      return authorize('ADMIN')(req, res, next);
    });
  },
  controller.registerStaff
);

authRouter.post(
  '/register-patient',
  authLimiter,
  authenticate,
  authorize('ADMIN', 'CALL_CENTER'),
  controller.registerPatient
);

authRouter.post('/login', loginLimiter, controller.login);
authRouter.post('/refresh', authLimiter, controller.refresh);
authRouter.post('/logout', authLimiter, controller.logout);
authRouter.get('/me', authenticate, controller.me);
