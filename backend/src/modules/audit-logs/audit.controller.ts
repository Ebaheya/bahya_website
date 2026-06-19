import type { NextFunction, Request, Response } from 'express';
import { auditIdParamSchema, listAuditLogsQuerySchema } from './audit.schema';
import * as auditService from './audit.service';

export async function list(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const query = listAuditLogsQuerySchema.parse(req.query);
    const logs = await auditService.listAuditLogs(query);
    res.status(200).json(logs);
  } catch (err) {
    next(err);
  }
}

export async function detail(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { id } = auditIdParamSchema.parse(req.params);
    const log = await auditService.getAuditLogById(id);
    res.status(200).json(log);
  } catch (err) {
    next(err);
  }
}
