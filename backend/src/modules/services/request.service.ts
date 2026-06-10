import { Prisma } from '@prisma/client';
import type { Request } from 'express';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import {
  emitServiceRequestDecided,
  emitServiceRequestSubmitted,
} from '../notifications/notification.service';
import { ServiceErrors } from './service.errors';
import type { ListServiceRequestsQuery } from './request.schema';

const queueInclude = {
  patient: {
    select: {
      id: true,
      crn: true,
      user: { select: { fullName: true } },
    },
  },
  service: {
    select: {
      id: true,
      name: true,
      category: { select: { kind: true } },
    },
  },
} satisfies Prisma.ServiceRequestInclude;

type QueueRequest = Prisma.ServiceRequestGetPayload<{ include: typeof queueInclude }>;

const decisionSelect = {
  id: true,
  serviceId: true,
  patientId: true,
  status: true,
  decisionNote: true,
  decidedById: true,
  requestedAt: true,
  decidedAt: true,
  service: {
    select: {
      id: true,
      name: true,
      capacity: true,
      seatsTaken: true,
    },
  },
  patient: {
    select: {
      id: true,
      userId: true,
    },
  },
} satisfies Prisma.ServiceRequestSelect;

type DecisionRequest = Prisma.ServiceRequestGetPayload<{ select: typeof decisionSelect }>;

const myRequestInclude = {
  service: {
    select: {
      id: true,
      name: true,
      startDate: true,
      startTime: true,
      locationBranch: true,
      category: { select: { kind: true } },
    },
  },
} satisfies Prisma.ServiceRequestInclude;

type MyRequest = Prisma.ServiceRequestGetPayload<{ include: typeof myRequestInclude }>;

const cancelSelect = {
  id: true,
  serviceId: true,
  patientId: true,
  status: true,
} satisfies Prisma.ServiceRequestSelect;

function toQueueItem(request: QueueRequest) {
  return {
    id: request.id,
    status: request.status,
    requestedAt: request.requestedAt,
    decidedAt: request.decidedAt,
    decisionNote: request.decisionNote,
    patient: {
      id: request.patient.id,
      fullName: request.patient.user.fullName,
      crn: request.patient.crn,
    },
    service: {
      id: request.service.id,
      name: request.service.name,
      kind: request.service.category.kind,
    },
  };
}

function toMyRequestItem(request: MyRequest) {
  return {
    id: request.id,
    status: request.status,
    decisionNote: request.decisionNote,
    requestedAt: request.requestedAt,
    decidedAt: request.decidedAt,
    service: {
      id: request.service.id,
      name: request.service.name,
      kind: request.service.category.kind,
      startDate: request.service.startDate,
      startTime: request.service.startTime,
      locationBranch: request.service.locationBranch,
    },
  };
}

async function getPatientForUser(actorUserId: string) {
  const patient = await prisma.patient.findUnique({
    where: { userId: actorUserId },
    select: { id: true },
  });
  if (!patient) throw AppError.notFound('Patient profile not found');
  return patient;
}

async function emitDecisionSideEffects(
  request: DecisionRequest,
  actorId: string,
  approved: boolean,
  req?: Request
): Promise<void> {
  await emitServiceRequestDecided({
    patientId: request.patientId,
    recipientUserId: request.patient.userId,
    approved,
    serviceName: request.service.name,
  });
  await writeAudit({
    actorId,
    action: approved ? 'SERVICE_REQUEST_APPROVED' : 'SERVICE_REQUEST_REJECTED',
    entityType: 'SERVICE_REQUEST',
    entityId: request.id,
    newValues: {
      serviceId: request.serviceId,
      patientId: request.patientId,
      status: request.status,
      decisionNote: request.decisionNote,
    },
    req,
  });
}

export async function createRequest(serviceId: string, actorUserId: string, req?: Request) {
  const patient = await getPatientForUser(actorUserId);

  const request = await prisma.$transaction(async (tx) => {
    const service = await tx.service.findUnique({
      where: { id: serviceId },
      select: { id: true, status: true, capacity: true, seatsTaken: true },
    });
    if (!service) throw AppError.notFound('Service not found');
    if (service.status !== 'ACTIVE') throw ServiceErrors.serviceNotAccepting();
    if (service.seatsTaken >= service.capacity) throw ServiceErrors.serviceFull();

    const duplicate = await tx.serviceRequest.findFirst({
      where: {
        serviceId,
        patientId: patient.id,
        status: { in: ['PENDING', 'APPROVED'] },
      },
      select: { id: true },
    });
    if (duplicate) throw ServiceErrors.duplicateServiceRequest();

    return tx.serviceRequest.create({
      data: {
        serviceId,
        patientId: patient.id,
      },
      select: {
        id: true,
        status: true,
        serviceId: true,
        requestedAt: true,
      },
    });
  });

  await emitServiceRequestSubmitted({ patientId: patient.id });
  await writeAudit({
    actorId: actorUserId,
    action: 'SERVICE_REQUEST_CREATED',
    entityType: 'SERVICE_REQUEST',
    entityId: request.id,
    newValues: {
      serviceId: request.serviceId,
      patientId: patient.id,
      status: request.status,
    },
    req,
  });

  return request;
}

export async function listMyRequests(actorUserId: string) {
  const patient = await getPatientForUser(actorUserId);
  const requests = await prisma.serviceRequest.findMany({
    where: { patientId: patient.id },
    include: myRequestInclude,
    orderBy: { requestedAt: 'desc' },
  });

  return requests.map(toMyRequestItem);
}

export async function cancelRequest(requestId: string, actorUserId: string, req?: Request) {
  const patient = await getPatientForUser(actorUserId);
  const request = await prisma.$transaction(async (tx) => {
    const existing = await tx.serviceRequest.findUnique({
      where: { id: requestId },
      select: cancelSelect,
    });
    if (!existing) throw AppError.notFound('Service request not found');
    if (existing.patientId !== patient.id) throw AppError.forbidden('Request does not belong to caller');
    if (existing.status !== 'PENDING') throw ServiceErrors.requestNotPending();

    const update = await tx.serviceRequest.updateMany({
      where: { id: requestId, patientId: patient.id, status: 'PENDING' },
      data: { status: 'CANCELLED' },
    });
    if (update.count !== 1) throw ServiceErrors.requestNotPending();

    const updated = await tx.serviceRequest.findUnique({
      where: { id: requestId },
      select: cancelSelect,
    });
    if (!updated) throw AppError.notFound('Service request not found');
    return updated;
  });

  await writeAudit({
    actorId: actorUserId,
    action: 'SERVICE_REQUEST_CANCELLED',
    entityType: 'SERVICE_REQUEST',
    entityId: request.id,
    oldValues: { status: 'PENDING' },
    newValues: {
      serviceId: request.serviceId,
      patientId: request.patientId,
      status: request.status,
    },
    req,
  });

  return request;
}

export async function listQueue(query: ListServiceRequestsQuery) {
  const where: Prisma.ServiceRequestWhereInput = {
    ...(query.status ? { status: query.status } : {}),
    ...(query.serviceId ? { serviceId: query.serviceId } : {}),
  };
  const skip = (query.page - 1) * query.pageSize;

  const [data, total] = await Promise.all([
    prisma.serviceRequest.findMany({
      where,
      include: queueInclude,
      orderBy: { requestedAt: 'desc' },
      skip,
      take: query.pageSize,
    }),
    prisma.serviceRequest.count({ where }),
  ]);

  return {
    data: data.map(toQueueItem),
    page: query.page,
    pageSize: query.pageSize,
    total,
  };
}

export async function getSummary(now = new Date()) {
  const startOfToday = new Date(now);
  startOfToday.setHours(0, 0, 0, 0);

  const [pending, approvedToday, approvedTotal] = await Promise.all([
    prisma.serviceRequest.count({ where: { status: 'PENDING' } }),
    prisma.serviceRequest.count({
      where: { status: 'APPROVED', decidedAt: { gte: startOfToday } },
    }),
    prisma.serviceRequest.count({ where: { status: 'APPROVED' } }),
  ]);

  return { pending, approvedToday, approvedTotal };
}

export async function approveRequest(requestId: string, actorId: string, req?: Request) {
  const request = await prisma.$transaction(async (tx) => {
    const existing = await tx.serviceRequest.findUnique({
      where: { id: requestId },
      select: decisionSelect,
    });
    if (!existing) throw AppError.notFound('Service request not found');
    if (existing.status !== 'PENDING') throw ServiceErrors.requestAlreadyDecided();

    const seatUpdate = await tx.service.updateMany({
      where: {
        id: existing.serviceId,
        seatsTaken: { lt: existing.service.capacity },
      },
      data: { seatsTaken: { increment: 1 } },
    });
    if (seatUpdate.count !== 1) throw ServiceErrors.serviceFull();

    const decidedAt = new Date();
    const requestUpdate = await tx.serviceRequest.updateMany({
      where: { id: requestId, status: 'PENDING' },
      data: {
        status: 'APPROVED',
        decidedById: actorId,
        decidedAt,
      },
    });
    if (requestUpdate.count !== 1) throw ServiceErrors.requestAlreadyDecided();

    const updated = await tx.serviceRequest.findUnique({
      where: { id: requestId },
      select: decisionSelect,
    });
    if (!updated) throw AppError.notFound('Service request not found');
    return updated;
  });

  await emitDecisionSideEffects(request, actorId, true, req);
  return request;
}

export async function rejectRequest(
  requestId: string,
  actorId: string,
  decisionNote?: string,
  req?: Request
) {
  const request = await prisma.$transaction(async (tx) => {
    const existing = await tx.serviceRequest.findUnique({
      where: { id: requestId },
      select: decisionSelect,
    });
    if (!existing) throw AppError.notFound('Service request not found');
    if (existing.status !== 'PENDING') throw ServiceErrors.requestAlreadyDecided();

    const decidedAt = new Date();
    const requestUpdate = await tx.serviceRequest.updateMany({
      where: { id: requestId, status: 'PENDING' },
      data: {
        status: 'REJECTED',
        decisionNote: decisionNote ?? null,
        decidedById: actorId,
        decidedAt,
      },
    });
    if (requestUpdate.count !== 1) throw ServiceErrors.requestAlreadyDecided();

    const updated = await tx.serviceRequest.findUnique({
      where: { id: requestId },
      select: decisionSelect,
    });
    if (!updated) throw AppError.notFound('Service request not found');
    return updated;
  });

  await emitDecisionSideEffects(request, actorId, false, req);
  return request;
}
