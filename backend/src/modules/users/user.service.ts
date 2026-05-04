import type { Request } from 'express';
import { Prisma, type Role, type User } from '@prisma/client';
import { prisma } from '../../config/prisma';
import { logger } from '../../config/logger';
import { writeAudit, type AuditInput } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import { sendEmail } from '../email/email.service';
import { buildPasswordResetEmail } from '../email/templates/password-reset';
import { buildResetUrl, invalidateResetToken, issueResetToken } from '../auth/reset-tokens';
import type { ListUsersQuery, PatchUserInput } from './user.schema';

export const publicUserSelect = {
  id: true,
  email: true,
  fullName: true,
  role: true,
  isActive: true,
  createdAt: true,
  updatedAt: true,
} as const;

export type PublicUser = Pick<User, keyof typeof publicUserSelect>;

export function findByEmail(email: string) {
  return prisma.user.findUnique({ where: { email: email.toLowerCase() } });
}

export function findById(id: string) {
  return prisma.user.findUnique({ where: { id } });
}

export function findPublicById(id: string) {
  return prisma.user.findUnique({ where: { id }, select: publicUserSelect });
}

export function createUser(data: {
  email: string;
  passwordHash: string;
  fullName: string;
  role: Role;
}) {
  return prisma.user.create({
    data: { ...data, email: data.email.toLowerCase() },
    select: publicUserSelect,
  });
}

export function countByRole(role: Role) {
  return prisma.user.count({ where: { role } });
}

export function revokeAllTokens(userId: string) {
  return prisma.refreshToken.updateMany({
    where: { userId, revokedAt: null },
    data: { revokedAt: new Date() },
  });
}

async function writeCommittedAdminResetAudit(input: AuditInput): Promise<void> {
  try {
    await writeAudit(input);
  } catch (err) {
    if (err instanceof AppError && err.code === 'AUDIT_UNAVAILABLE') {
      logger.error(
        {
          err,
          metric: 'audit_write_failure',
          action: input.action,
          tier: 'strict_post_commit',
          actorId: input.actorId ?? null,
          entityType: input.entityType ?? null,
          entityId: input.entityId ?? null,
        },
        'post-commit admin password-reset audit failed; preserving successful response'
      );
      return;
    }
    throw err;
  }
}

export async function listUsers(query: ListUsersQuery) {
  const where: Prisma.UserWhereInput = {};

  if (query.q) {
    where.OR = [
      { fullName: { contains: query.q, mode: 'insensitive' } },
      { email: { contains: query.q, mode: 'insensitive' } },
    ];
  }
  if (query.role) where.role = query.role;
  if (query.isActive !== undefined) where.isActive = query.isActive;

  const skip = (query.page - 1) * query.pageSize;
  const take = query.pageSize;

  const [data, total] = await prisma.$transaction([
    prisma.user.findMany({
      where,
      select: publicUserSelect,
      orderBy: { createdAt: 'desc' },
      skip,
      take,
    }),
    prisma.user.count({ where }),
  ]);

  return {
    data,
    page: query.page,
    pageSize: query.pageSize,
    total,
  };
}

export async function patchUser(
  id: string,
  data: PatchUserInput,
  actorId: string,
  req?: Request
) {
  const existing = await prisma.user.findUnique({
    where: { id },
    select: publicUserSelect,
  });
  if (!existing) throw AppError.notFound('User not found');

  if (data.fullName === undefined || data.fullName === existing.fullName) {
    return existing;
  }

  const updated = await prisma.user.update({
    where: { id },
    data: { fullName: data.fullName },
    select: publicUserSelect,
  });

  await writeAudit({
    actorId,
    action: 'USER_PROFILE_UPDATED',
    entityType: 'USER',
    entityId: id,
    oldValues: { fullName: existing.fullName },
    newValues: { fullName: updated.fullName },
    req,
  });

  return updated;
}

export async function patchUserStatus(
  id: string,
  isActive: boolean,
  actorId: string,
  req?: Request
) {
  const existing = await prisma.user.findUnique({
    where: { id },
    select: publicUserSelect,
  });
  if (!existing) throw AppError.notFound('User not found');

  if (existing.isActive === isActive) {
    return existing;
  }

  // Serialize concurrent admin-deactivations through a Postgres advisory lock so
  // two simultaneous requests cannot both observe activeAdmins > 1 and both win,
  // leaving the system with zero active admins. Same lock key as bootstrap so
  // bootstrap and deactivate cannot interleave either. The lock is released at
  // transaction end.
  const updated = await prisma.$transaction(async (tx) => {
    if (!isActive && existing.role === 'ADMIN') {
      await tx.$executeRaw`SELECT pg_advisory_xact_lock(9876543210)`;

      const activeAdmins = await tx.user.count({
        where: { role: 'ADMIN', isActive: true },
      });
      if (activeAdmins <= 1) {
        throw new AppError(
          409,
          'LAST_ACTIVE_ADMIN',
          'Cannot deactivate the last active admin'
        );
      }
    }

    return tx.user.update({
      where: { id },
      data: { isActive },
      select: publicUserSelect,
    });
  });

  if (!isActive) {
    await revokeAllTokens(id);
  }

  await writeAudit({
    actorId,
    action: isActive ? 'USER_ACTIVATED' : 'USER_DEACTIVATED',
    entityType: 'USER',
    entityId: id,
    oldValues: { isActive: existing.isActive },
    newValues: { isActive: updated.isActive },
    req,
  });

  return updated;
}

export async function triggerReset(targetId: string, actorId: string, req?: Request) {
  const target = await prisma.user.findUnique({
    where: { id: targetId },
    select: publicUserSelect,
  });
  if (!target) throw AppError.notFound('User not found');

  const issuedToken = await issueResetToken(target.id);

  const email = buildPasswordResetEmail(buildResetUrl(issuedToken.rawToken), target.fullName);
  try {
    await sendEmail(target.email, email.subject, email.html);
  } catch (err) {
    try {
      await invalidateResetToken(issuedToken.id);
    } catch (cleanupErr) {
      logger.error(
        {
          err: cleanupErr,
          metric: 'password_reset_token_cleanup_failed',
          userId: target.id,
        },
        'failed to invalidate undelivered password reset token'
      );
    }
    throw err;
  }

  await writeCommittedAdminResetAudit({
    actorId,
    action: 'PASSWORD_RESET_BY_ADMIN',
    entityType: 'USER',
    entityId: target.id,
    newValues: { email: target.email },
    req,
  });
}
