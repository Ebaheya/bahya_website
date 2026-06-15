import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import * as controller from './notification.controller';

export const notificationRouter = Router();

// Every notification route requires an authenticated, PostgreSQL-revalidated user
// (Principle IV). Route handlers are added per user story:
//   GET    /my                        (US1 — list addressed to caller) ✓
//   PATCH  /:id/claim                 (US2 — claim role-broadcast) ✓
//   PATCH  /:id/read, /:id/done       (US3 — lifecycle)
//   POST   /request-booking           (US4 — Doctor → Call Center)
//   POST   /devices, DELETE /devices  (US5 — push device registration)
notificationRouter.use(authenticate);

notificationRouter.get('/my', controller.listMy);
notificationRouter.patch('/:id/claim', controller.claim);
