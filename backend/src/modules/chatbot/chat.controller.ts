import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  messageBodySchema,
  messagesQuerySchema,
  sessionIdParamSchema,
  sessionsListQuerySchema,
} from './chat.schema';
import * as chatService from './chat.service';

export async function sendMessage(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const input = messageBodySchema.parse(req.body);
    const reply = await chatService.handlePatientMessage({
      patientId: req.user.id,
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
    if (!req.user) throw AppError.unauthorized();
    const query = sessionsListQuerySchema.parse(req.query);
    const result = await chatService.listSessions(
      { id: req.user.id, role: req.user.role },
      query
    );

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
    if (!req.user) throw AppError.unauthorized();
    const params = sessionIdParamSchema.parse(req.params);
    const query = messagesQuerySchema.parse(req.query);
    const result = await chatService.getSessionMessages(
      { id: req.user.id, role: req.user.role },
      params.id,
      query
    );

    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}
