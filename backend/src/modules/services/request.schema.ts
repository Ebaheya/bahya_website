import { z } from 'zod';

const serviceRequestStatus = z.enum(['PENDING', 'APPROVED', 'REJECTED', 'CANCELLED']);

export const serviceRequestServiceParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export const serviceRequestIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export const listServiceRequestsQuerySchema = z
  .object({
    status: serviceRequestStatus.optional(),
    serviceId: z.string().uuid().optional(),
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export const rejectServiceRequestSchema = z
  .object({
    decisionNote: z.string().trim().min(1).max(500).optional(),
  })
  .strict();

export type ServiceRequestServiceParam = z.infer<typeof serviceRequestServiceParamSchema>;
export type ServiceRequestIdParam = z.infer<typeof serviceRequestIdParamSchema>;
export type ListServiceRequestsQuery = z.infer<typeof listServiceRequestsQuerySchema>;
export type RejectServiceRequestInput = z.infer<typeof rejectServiceRequestSchema>;
