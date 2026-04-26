import type { Request } from 'express';
import type { Role } from '@prisma/client';
import { prisma } from '../../config/prisma';
import { AppError } from '../../utils/httpError';
import { hashPassword, verifyPassword } from '../../utils/passwords';
import {
  generateRefreshToken,
  hashRefreshToken,
  signAccessToken,
} from '../../utils/tokens';
import { writeAudit, getClientIp } from '../../middleware/audit';
import * as users from '../users/user.service';
import type {
  LoginInput,
  RegisterPatientInput,
  RegisterStaffInput,
} from './auth.schema';

interface TokenBundle {
  accessToken: string;
  refreshToken: string;
}

async function issueTokens(
  userId: string,
  role: Role,
  req?: Request
): Promise<TokenBundle> {
  const accessToken = signAccessToken({ sub: userId, role });
  const { raw, hash, expiresAt } = generateRefreshToken();

  await prisma.refreshToken.create({
    data: {
      userId,
      tokenHash: hash,
      expiresAt,
      userAgent: req?.get('user-agent') ?? null,
      ip: req ? getClientIp(req) : null,
    },
  });

  return { accessToken, refreshToken: raw };
}

export async function registerStaff(input: RegisterStaffInput, req?: Request) {
  const existing = await users.findByEmail(input.email);
  if (existing) throw AppError.conflict('Email already registered');

  const passwordHash = await hashPassword(input.password);
  const user = await users.createUser({
    email: input.email,
    fullName: input.fullName,
    passwordHash,
    role: input.role as Role,
  });

  await writeAudit({
    userId: req?.user?.id ?? null,
    actionType: 'CREATE',
    entity: 'User',
    entityId: user.id,
    newValues: { email: user.email, role: user.role, fullName: user.fullName },
    req,
  });

  return user;
}

export async function registerPatient(input: RegisterPatientInput, req?: Request) {
  const existing = await users.findByEmail(input.email);
  if (existing) throw AppError.conflict('Email already registered');

  const passwordHash = await hashPassword(input.password);
  const user = await users.createUser({
    email: input.email,
    fullName: input.fullName,
    passwordHash,
    role: 'PATIENT',
  });

  await writeAudit({
    userId: req?.user?.id ?? null,
    actionType: 'CREATE',
    entity: 'User',
    entityId: user.id,
    newValues: { email: user.email, role: user.role, fullName: user.fullName },
    req,
  });

  return user;
}

export async function login(input: LoginInput, req?: Request) {
  const user = await users.findByEmail(input.email);
  if (!user || !user.isActive) {
    await writeAudit({
      actionType: 'LOGIN_FAIL',
      entity: 'User',
      newValues: { email: input.email, reason: 'not_found_or_inactive' },
      req,
    });
    throw AppError.unauthorized('Invalid email or password');
  }

  const ok = await verifyPassword(input.password, user.passwordHash);
  if (!ok) {
    await writeAudit({
      userId: user.id,
      actionType: 'LOGIN_FAIL',
      entity: 'User',
      entityId: user.id,
      newValues: { reason: 'bad_password' },
      req,
    });
    throw AppError.unauthorized('Invalid email or password');
  }

  const tokens = await issueTokens(user.id, user.role, req);

  await writeAudit({
    userId: user.id,
    actionType: 'LOGIN',
    entity: 'User',
    entityId: user.id,
    req,
  });

  return tokens;
}

export async function refresh(rawRefreshToken: string, req?: Request) {
  const tokenHash = hashRefreshToken(rawRefreshToken);

  // Load the existing token first (outside the tx) for validation.
  const existing = await prisma.refreshToken.findUnique({
    where: { tokenHash },
    include: { user: true },
  });

  if (!existing) throw AppError.unauthorized('Invalid refresh token');
  if (existing.expiresAt.getTime() < Date.now()) {
    throw AppError.unauthorized('Refresh token expired');
  }
  if (!existing.user.isActive) {
    throw AppError.unauthorized('User is inactive');
  }

  // Atomically revoke the old token and create the replacement in one transaction.
  // updateMany with revokedAt: null as a guard ensures only the first concurrent
  // caller wins; a duplicate request gets count=0 and is rejected as token reuse.
  const newTokens = await prisma.$transaction(async (tx) => {
    const revoked = await tx.refreshToken.updateMany({
      where: { id: existing.id, revokedAt: null },
      data: { revokedAt: new Date() },
    });

    if (revoked.count !== 1) {
      throw AppError.unauthorized('Refresh token has already been used or revoked');
    }

    const accessToken = signAccessToken({ sub: existing.user.id, role: existing.user.role });
    const { raw, hash, expiresAt } = generateRefreshToken();

    const newRow = await tx.refreshToken.create({
      data: {
        userId: existing.user.id,
        tokenHash: hash,
        expiresAt,
        userAgent: req?.get('user-agent') ?? null,
        ip: req ? getClientIp(req) : null,
      },
    });

    // Link old token to its replacement for audit trail.
    await tx.refreshToken.update({
      where: { id: existing.id },
      data: { replacedBy: newRow.id },
    });

    return { accessToken, refreshToken: raw };
  });

  await writeAudit({
    userId: existing.user.id,
    actionType: 'REFRESH',
    entity: 'RefreshToken',
    entityId: existing.id,
    req,
  });

  return newTokens;
}

export async function logout(rawRefreshToken: string, req?: Request) {
  const tokenHash = hashRefreshToken(rawRefreshToken);
  const existing = await prisma.refreshToken.findUnique({ where: { tokenHash } });
  if (!existing || existing.revokedAt) return;

  await prisma.refreshToken.update({
    where: { id: existing.id },
    data: { revokedAt: new Date() },
  });

  await writeAudit({
    userId: existing.userId,
    actionType: 'LOGOUT',
    entity: 'RefreshToken',
    entityId: existing.id,
    req,
  });
}

export async function adminExists(): Promise<boolean> {
  const count = await users.countByRole('ADMIN');
  return count > 0;
}

// Creates the very first ADMIN under a Postgres advisory lock so that two
// simultaneous bootstrap requests cannot both observe "no admin" and both succeed.
// pg_advisory_xact_lock is released automatically at transaction end.
// writeAudit is intentionally called after the transaction so that an audit
// write failure does not roll back the user creation.
export async function bootstrapFirstAdmin(input: RegisterStaffInput, req?: Request) {
  const user = await prisma.$transaction(async (tx) => {
    // Lock key: arbitrary stable bigint scoped to this operation.
    await tx.$executeRaw`SELECT pg_advisory_xact_lock(9876543210)`;

    const existingCount = await tx.user.count({ where: { role: 'ADMIN' } });
    if (existingCount > 0) {
      throw AppError.forbidden(
        'Bootstrap path is disabled: an admin already exists. Use an ADMIN access token.'
      );
    }

    // Guard against an existing patient/staff row that already owns this email.
    // Without this check, tx.user.create would throw a Prisma unique-constraint
    // error (P2002) that the error middleware cannot map, producing a 500.
    const emailTaken = await tx.user.findUnique({
      where: { email: input.email.toLowerCase() },
      select: { id: true },
    });
    if (emailTaken) throw AppError.conflict('Email already registered');

    const passwordHash = await hashPassword(input.password);
    return tx.user.create({
      data: {
        email: input.email.toLowerCase(),
        fullName: input.fullName,
        passwordHash,
        role: 'ADMIN',
      },
      select: users.publicUserSelect,
    });
  });

  await writeAudit({
    userId: null,
    actionType: 'CREATE',
    entity: 'User',
    entityId: user.id,
    newValues: { email: user.email, role: user.role, fullName: user.fullName, bootstrap: true },
    req,
  });

  return user;
}
