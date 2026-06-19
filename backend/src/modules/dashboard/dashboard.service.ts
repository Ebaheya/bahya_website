import type { AssessmentStatus, Role } from '@prisma/client';
import { prisma } from '../../config/prisma';
import { listRecentAuditLogs } from '../audit-logs/audit.service';
import { NotificationModel } from '../notifications/notification.model';

const roles: Role[] = ['ADMIN', 'DOCTOR', 'VOLUNTEER', 'CALL_CENTER', 'PATIENT'];
const assessmentStatuses: AssessmentStatus[] = [
  'NORMAL',
  'MILD',
  'MODERATE',
  'SEVERE',
  'CRITICAL',
];

function zeroRoleCounts(): Record<Role, number> {
  return Object.fromEntries(roles.map((role) => [role, 0])) as Record<Role, number>;
}

function zeroAssessmentCounts(): Record<AssessmentStatus, number> {
  return Object.fromEntries(
    assessmentStatuses.map((status) => [status, 0])
  ) as Record<AssessmentStatus, number>;
}

export async function getSummary() {
  const [
    totalUsers,
    activeUsers,
    usersByRoleRows,
    assessmentsByStatusRows,
    openReports,
    openNotifications,
  ] = await Promise.all([
    prisma.user.count(),
    prisma.user.count({ where: { isActive: true } }),
    prisma.user.groupBy({
      by: ['role'],
      _count: { _all: true },
    }),
    prisma.assessment.groupBy({
      by: ['status'],
      _count: { _all: true },
    }),
    prisma.report.count({ where: { status: { not: 'RESOLVED' } } }),
    // Positive open-status predicate so MongoDB can use the status-leading
    // index (a `$ne: 'DONE'` filter is non-selective and forces a COLLSCAN).
    NotificationModel.countDocuments({ status: { $in: ['UNREAD', 'READ'] } }),
  ]);

  const byRole = zeroRoleCounts();
  for (const row of usersByRoleRows) {
    byRole[row.role] = row._count._all;
  }

  const byStatus = zeroAssessmentCounts();
  for (const row of assessmentsByStatusRows) {
    byStatus[row.status] = row._count._all;
  }

  return {
    users: {
      total: totalUsers,
      active: activeUsers,
      byRole,
    },
    reports: { open: openReports },
    assessments: { byStatus },
    notifications: { open: openNotifications },
  };
}

export async function getActivity(limit = 10) {
  const logs = await listRecentAuditLogs(limit);
  const actorIds = [...new Set(logs.map((log) => log.actorId).filter(Boolean))] as string[];

  const actors = actorIds.length
    ? await prisma.user.findMany({
        where: { id: { in: actorIds } },
        select: { id: true, fullName: true },
      })
    : [];
  const actorById = new Map(actors.map((actor) => [actor.id, actor]));

  return {
    data: logs.map((log) => ({
      id: String(log._id),
      action: log.action,
      entityType: log.entityType,
      actor: log.actorId
        ? actorById.get(log.actorId)
          ? {
              id: log.actorId,
              fullName: actorById.get(log.actorId)?.fullName,
            }
          : null
        : null,
      createdAt: log.createdAt,
    })),
  };
}
