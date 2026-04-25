import type { Role, User } from '@prisma/client';
import { prisma } from '../../config/prisma';

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
