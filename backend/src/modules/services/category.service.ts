import { Prisma, type Role } from '@prisma/client';
import type { Request } from 'express';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import { ServiceErrors } from './service.errors';
import type {
  CreateCategoryInput,
  ListCategoriesQuery,
  UpdateCategoryInput,
} from './category.schema';

async function ensureNameAvailable(name: string, excludeId?: string): Promise<void> {
  const duplicate = await prisma.serviceCategory.findFirst({
    where: {
      ...(excludeId ? { id: { not: excludeId } } : {}),
      name: { equals: name, mode: 'insensitive' },
    },
    select: { id: true },
  });
  if (duplicate) throw ServiceErrors.categoryNameTaken();
}

// The findFirst pre-check above is a fast/friendly path; the authoritative guard
// is the functional unique index on LOWER(name). Two concurrent creates/renames
// that both pass the read collide on the index — the loser's P2002 is mapped to
// CATEGORY_NAME_TAKEN here so duplicates can never persist.
function rethrowNameConflict(err: unknown): never {
  if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
    throw ServiceErrors.categoryNameTaken();
  }
  throw err;
}

export async function createCategory(
  input: CreateCategoryInput,
  actorId: string,
  req?: Request
) {
  await ensureNameAvailable(input.name);

  const category = await prisma.serviceCategory
    .create({
      data: {
        name: input.name,
        kind: input.kind,
        iconKey: input.iconKey,
        color: input.color,
        isDefault: false,
        isActive: true,
        createdById: actorId,
      },
    })
    .catch(rethrowNameConflict);

  await writeAudit({
    actorId,
    action: 'SERVICE_CATEGORY_CREATED',
    entityType: 'SERVICE_CATEGORY',
    entityId: category.id,
    newValues: {
      name: category.name,
      kind: category.kind,
      iconKey: category.iconKey,
      color: category.color,
    },
    req,
  });

  return category;
}

export async function updateCategory(
  id: string,
  input: UpdateCategoryInput,
  actorId: string,
  req?: Request
) {
  const existing = await prisma.serviceCategory.findUnique({ where: { id } });
  if (!existing) throw AppError.notFound('Service category not found');
  if (input.name !== undefined) await ensureNameAvailable(input.name, id);

  const category = await prisma.serviceCategory
    .update({
      where: { id },
      data: {
        ...(input.name !== undefined ? { name: input.name } : {}),
        ...(input.kind !== undefined ? { kind: input.kind } : {}),
        ...(input.iconKey !== undefined ? { iconKey: input.iconKey } : {}),
        ...(input.color !== undefined ? { color: input.color } : {}),
      },
    })
    .catch(rethrowNameConflict);

  await writeAudit({
    actorId,
    action: 'SERVICE_CATEGORY_UPDATED',
    entityType: 'SERVICE_CATEGORY',
    entityId: category.id,
    oldValues: {
      name: existing.name,
      kind: existing.kind,
      iconKey: existing.iconKey,
      color: existing.color,
    },
    newValues: {
      name: category.name,
      kind: category.kind,
      iconKey: category.iconKey,
      color: category.color,
    },
    req,
  });

  return category;
}

export async function setCategoryStatus(
  id: string,
  isActive: boolean,
  actorId: string,
  req?: Request
) {
  const existing = await prisma.serviceCategory.findUnique({ where: { id } });
  if (!existing) throw AppError.notFound('Service category not found');
  if (existing.isActive === isActive) return existing;

  const category = await prisma.serviceCategory.update({
    where: { id },
    data: { isActive },
  });

  await writeAudit({
    actorId,
    action: isActive ? 'SERVICE_CATEGORY_UPDATED' : 'SERVICE_CATEGORY_DEACTIVATED',
    entityType: 'SERVICE_CATEGORY',
    entityId: category.id,
    oldValues: { isActive: existing.isActive },
    newValues: { isActive: category.isActive },
    req,
  });

  return category;
}

export async function listCategories(query: ListCategoriesQuery, role: Role) {
  const where: Prisma.ServiceCategoryWhereInput = {
    ...(query.kind ? { kind: query.kind } : {}),
    // Patients browse only active categories; the `isActive` query filter is a
    // staff-authoring affordance, so a patient's `isActive=false` is ignored.
    // Mirrors listServices, which scopes patients to status=ACTIVE.
    ...(role === 'PATIENT'
      ? { isActive: true }
      : query.isActive !== undefined
        ? { isActive: query.isActive }
        : {}),
  };
  const skip = (query.page - 1) * query.pageSize;

  const [data, total] = await Promise.all([
    prisma.serviceCategory.findMany({
      where,
      orderBy: [{ isDefault: 'desc' }, { name: 'asc' }],
      skip,
      take: query.pageSize,
    }),
    prisma.serviceCategory.count({ where }),
  ]);

  return { data, page: query.page, pageSize: query.pageSize, total };
}
