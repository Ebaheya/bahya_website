import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import { messageBodySchema } from './chat.schema';
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
