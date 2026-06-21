import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  messageBodySchema,
  messagesQuerySchema,
  sessionIdParamSchema,
  sessionsListQuerySchema,
} from './chat.schema';
import * as chatService from './chat.service';
import { resolvePatientIdForUser } from './chat.profile';
import type { ChatReadActor } from './chat.service';

// `req.user.id` is a User id; chat data is keyed by Patient id. For a PATIENT we
// resolve their Patient id so storage, ownership, and escalation all use it.
// Staff (DOCTOR/ADMIN) don't own sessions — they pass an explicit `patientId`.
async function readActor(req: Request): Promise<ChatReadActor> {
  if (!req.user) throw AppError.unauthorized();
  if (req.user.role === 'PATIENT') {
    const patientId = await resolvePatientIdForUser(req.user.id);
    return { id: patientId, role: req.user.role };
  }
  return { id: req.user.id, role: req.user.role };
}

export async function sendMessage(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const input = messageBodySchema.parse(req.body);
    const patientId = await resolvePatientIdForUser(req.user.id);
    const reply = await chatService.handlePatientMessage({
      patientId,
      sessionId: input.sessionId,
      message: input.message,
    });

    res.status(200).json({
      sessionId: reply.sessionId,
      patientMessageId: reply.patientMessageId,
      botMessageId: reply.botMessageId,
      reply: reply.reply,
    });
  } catch (err) {
    next(err);
  }
}

export async function listSessions(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const query = sessionsListQuerySchema.parse(req.query);
    const actor = await readActor(req);
    const result = await chatService.listSessions(actor, query);

    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function getSessionMessages(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const params = sessionIdParamSchema.parse(req.params);
    const query = messagesQuerySchema.parse(req.query);
    const actor = await readActor(req);
    const result = await chatService.getSessionMessages(actor, params.id, query);

    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}
