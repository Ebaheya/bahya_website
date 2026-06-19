import { Prisma, type Role, type ServiceKind } from '@prisma/client';
import type { Request } from 'express';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import { ServiceErrors } from './service.errors';
import type { CreateServiceInput, ListServicesQuery, UpdateServiceInput } from './service.schema';

const serviceInclude = {
  category: {
    select: {
      id: true,
      name: true,
      kind: true,
      iconKey: true,
      color: true,
    },
  },
} satisfies Prisma.ServiceInclude;

type ServiceWithCategory = Prisma.ServiceGetPayload<{ include: typeof serviceInclude }>;

function hasValue(value: unknown): boolean {
  return value !== undefined && value !== null && !(typeof value === 'string' && value.trim() === '');
}

function requireTripFields(kind: ServiceKind, fields: {
  endDate?: Date | null;
  departureTime?: string | null;
  meetingPlace?: string | null;
}): void {
  if (kind !== 'TRIP') return;
  if (!hasValue(fields.endDate) || !hasValue(fields.departureTime) || !hasValue(fields.meetingPlace)) {
    throw ServiceErrors.tripFieldsRequired();
  }
}

function withRemainingSeats(service: ServiceWithCategory) {
  return {
    ...service,
    remainingSeats: service.capacity - service.seatsTaken,
  };
}

async function getCategoryOrThrow(categoryId: string) {
  const category = await prisma.serviceCategory.findUnique({
    where: { id: categoryId },
    select: { id: true, kind: true },
  });
  if (!category) throw AppError.notFound('Service category not found');
  return category;
}

export async function createService(input: CreateServiceInput, actorId: string, req?: Request) {
  if (input.capacity <= 0) throw ServiceErrors.serviceCapacityInvalid();
  const category = await getCategoryOrThrow(input.categoryId);
  requireTripFields(category.kind, input);

  const service = await prisma.service.create({
    data: {
      categoryId: input.categoryId,
      name: input.name,
      locationBranch: input.locationBranch,
      startDate: input.startDate,
      startTime: input.startTime,
      endDate: input.endDate ?? null,
      departureTime: input.departureTime ?? null,
      meetingPlace: input.meetingPlace ?? null,
      capacity: input.capacity,
      createdById: actorId,
    },
    include: serviceInclude,
  });

  await writeAudit({
    actorId,
    action: 'SERVICE_CREATED',
    entityType: 'SERVICE',
    entityId: service.id,
    newValues: {
      categoryId: service.categoryId,
      name: service.name,
      capacity: service.capacity,
      status: service.status,
    },
    req,
  });

  return withRemainingSeats(service);
}

export async function getServiceById(id: string) {
  const service = await prisma.service.findUnique({
    where: { id },
    include: serviceInclude,
  });
  if (!service) throw AppError.notFound('Service not found');
  return withRemainingSeats(service);
}

export async function listServices(query: ListServicesQuery, role: Role) {
  const where: Prisma.ServiceWhereInput = {
    ...(role === 'PATIENT' ? { status: 'ACTIVE' } : query.status ? { status: query.status } : {}),
    ...(query.categoryId ? { categoryId: query.categoryId } : {}),
    ...(query.kind ? { category: { kind: query.kind } } : {}),
    ...(query.q
      ? {
          OR: [
            { name: { contains: query.q, mode: 'insensitive' } },
            { locationBranch: { contains: query.q, mode: 'insensitive' } },
            { category: { name: { contains: query.q, mode: 'insensitive' } } },
          ],
        }
      : {}),
  };
  const skip = (query.page - 1) * query.pageSize;

  const [data, total] = await Promise.all([
    prisma.service.findMany({
      where,
      include: serviceInclude,
      orderBy: [{ startDate: 'asc' }, { startTime: 'asc' }],
      skip,
      take: query.pageSize,
    }),
    prisma.service.count({ where }),
  ]);

  return {
    data: data.map(withRemainingSeats),
    page: query.page,
    pageSize: query.pageSize,
    total,
  };
}

export async function updateService(
  id: string,
  input: UpdateServiceInput,
  actorId: string,
  req?: Request
) {
  const existing = await prisma.service.findUnique({
    where: { id },
    include: serviceInclude,
  });
  if (!existing) throw AppError.notFound('Service not found');

  const category = input.categoryId ? await getCategoryOrThrow(input.categoryId) : existing.category;
  const nextCapacity = input.capacity ?? existing.capacity;
  if (nextCapacity <= 0) throw ServiceErrors.serviceCapacityInvalid();
  if (nextCapacity < existing.seatsTaken) {
    throw ServiceErrors.serviceCapacityBelowTaken(existing.seatsTaken);
  }

  requireTripFields(category.kind, {
    endDate: input.endDate !== undefined ? input.endDate : existing.endDate,
    departureTime:
      input.departureTime !== undefined ? input.departureTime : existing.departureTime,
    meetingPlace: input.meetingPlace !== undefined ? input.meetingPlace : existing.meetingPlace,
  });

  const data: Prisma.ServiceUpdateManyMutationInput = {
    ...(input.categoryId !== undefined ? { categoryId: input.categoryId } : {}),
    ...(input.name !== undefined ? { name: input.name } : {}),
    ...(input.locationBranch !== undefined ? { locationBranch: input.locationBranch } : {}),
    ...(input.startDate !== undefined ? { startDate: input.startDate } : {}),
    ...(input.startTime !== undefined ? { startTime: input.startTime } : {}),
    ...(input.endDate !== undefined ? { endDate: input.endDate } : {}),
    ...(input.departureTime !== undefined ? { departureTime: input.departureTime } : {}),
    ...(input.meetingPlace !== undefined ? { meetingPlace: input.meetingPlace } : {}),
    ...(input.capacity !== undefined ? { capacity: input.capacity } : {}),
    ...(input.status !== undefined ? { status: input.status } : {}),
  };

  // Apply the write conditionally on the live seat count so a concurrent
  // approval that increments seatsTaken between the snapshot check above and
  // this write cannot leave capacity < seatsTaken. The guard is a no-op when
  // capacity is unchanged or raised (seatsTaken <= capacity always holds), and
  // only bites when lowering capacity into a concurrent-approval race.
  const updated = await prisma.$transaction(async (tx) => {
    const result = await tx.service.updateMany({
      where: { id, seatsTaken: { lte: nextCapacity } },
      data,
    });
    if (result.count !== 1) {
      const current = await tx.service.findUnique({
        where: { id },
        select: { seatsTaken: true },
      });
      throw ServiceErrors.serviceCapacityBelowTaken(current?.seatsTaken ?? existing.seatsTaken);
    }
    const fresh = await tx.service.findUnique({ where: { id }, include: serviceInclude });
    if (!fresh) throw AppError.notFound('Service not found');
    return fresh;
  });

  await writeAudit({
    actorId,
    action: input.status === 'CLOSED' && existing.status !== 'CLOSED' ? 'SERVICE_CLOSED' : 'SERVICE_UPDATED',
    entityType: 'SERVICE',
    entityId: updated.id,
    oldValues: {
      categoryId: existing.categoryId,
      name: existing.name,
      capacity: existing.capacity,
      status: existing.status,
    },
    newValues: {
      categoryId: updated.categoryId,
      name: updated.name,
      capacity: updated.capacity,
      status: updated.status,
    },
    req,
  });

  return withRemainingSeats(updated);
}
