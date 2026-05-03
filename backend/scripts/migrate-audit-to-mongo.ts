import { Prisma } from '@prisma/client';
import { connectMongo, disconnectMongo } from '../src/config/mongo';
import { disconnectPrisma, prisma } from '../src/config/prisma';
import { logger } from '../src/config/logger';
import { AUDIT_ACTIONS } from '../src/modules/audit-logs/audit.actions';
import {
  __migrationFindByLegacyPgId,
  __migrationInsertLegacyAudit,
  __migrationSyncAuditIndexes,
} from '../src/modules/audit-logs/audit.service';

interface LegacyAuditRow {
  id: string;
  userId: string | null;
  actionType: string;
  entity: string | null;
  entityId: string | null;
  oldValues: Prisma.JsonValue | null;
  newValues: Prisma.JsonValue | null;
  ip: string | null;
  userAgent: string | null;
  createdAt: Date;
}

interface Summary {
  read: number;
  inserted: number;
  skipped: number;
  failed: number;
  non_vocab_actions: number;
}

const BATCH_SIZE = 1000;

function mapAction(row: LegacyAuditRow): string {
  if (row.actionType === 'CREATE' && row.entity === 'User') return 'USER_CREATED';
  return row.actionType;
}

function mapEntityType(entity: string | null): string | null {
  if (!entity) return null;

  const knownEntities: Record<string, string> = {
    User: 'USER',
    USER: 'USER',
    RefreshToken: 'REFRESH_TOKEN',
    REFRESH_TOKEN: 'REFRESH_TOKEN',
    Patient: 'PATIENT',
    PATIENT: 'PATIENT',
    Assessment: 'ASSESSMENT',
    ASSESSMENT: 'ASSESSMENT',
    Notification: 'NOTIFICATION',
    NOTIFICATION: 'NOTIFICATION',
  };

  return knownEntities[entity] ?? entity;
}

async function readBatch(
  lastCreatedAt: Date | null,
  lastId: string | null
): Promise<LegacyAuditRow[]> {
  if (lastCreatedAt && lastId) {
    return prisma.$queryRaw<LegacyAuditRow[]>`
      SELECT id, "userId", "actionType", entity, "entityId", "oldValues", "newValues", ip, "userAgent", "createdAt"
      FROM "AuditLog"
      WHERE "createdAt" > ${lastCreatedAt}
         OR ("createdAt" = ${lastCreatedAt} AND id > ${lastId})
      ORDER BY "createdAt" ASC, id ASC
      LIMIT ${BATCH_SIZE}
    `;
  }

  return prisma.$queryRaw<LegacyAuditRow[]>`
    SELECT id, "userId", "actionType", entity, "entityId", "oldValues", "newValues", ip, "userAgent", "createdAt"
    FROM "AuditLog"
    ORDER BY "createdAt" ASC, id ASC
    LIMIT ${BATCH_SIZE}
  `;
}

async function migrate(): Promise<Summary> {
  const summary: Summary = {
    read: 0,
    inserted: 0,
    skipped: 0,
    failed: 0,
    non_vocab_actions: 0,
  };

  await prisma.$connect();
  await connectMongo();
  await __migrationSyncAuditIndexes();

  let lastCreatedAt: Date | null = null;
  let lastId: string | null = null;

  for (;;) {
    const rows = await readBatch(lastCreatedAt, lastId);
    if (rows.length === 0) break;

    for (const row of rows) {
      summary.read += 1;

      const action = mapAction(row);
      if (!AUDIT_ACTIONS.includes(action as never)) {
        summary.non_vocab_actions += 1;
      }

      try {
        const alreadyMigrated = await __migrationFindByLegacyPgId(row.id);
        if (alreadyMigrated) {
          summary.skipped += 1;
          continue;
        }

        const status = await __migrationInsertLegacyAudit({
          legacyPgId: row.id,
          actorId: row.userId,
          action,
          entityType: mapEntityType(row.entity),
          entityId: row.entityId,
          oldValues: row.oldValues,
          newValues: row.newValues,
          ipAddress: row.ip,
          userAgent: row.userAgent,
          createdAt: row.createdAt,
        });

        if (status === 'inserted') summary.inserted += 1;
        else summary.skipped += 1;
      } catch (err) {
        summary.failed += 1;
        logger.error({ err, legacyPgId: row.id }, 'legacy audit migration row failed');
      }
    }

    const last = rows[rows.length - 1];
    lastCreatedAt = last.createdAt;
    lastId = last.id;
  }

  return summary;
}

migrate()
  .then((summary) => {
    console.log(
      `audit-migration: read=${summary.read} inserted=${summary.inserted} skipped=${summary.skipped} failed=${summary.failed} non_vocab_actions=${summary.non_vocab_actions}`
    );
    process.exitCode = summary.failed === 0 ? 0 : 1;
  })
  .catch((err: unknown) => {
    logger.error({ err }, 'legacy audit migration failed');
    process.exitCode = 1;
  })
  .finally(async () => {
    await Promise.allSettled([disconnectPrisma(), disconnectMongo()]);
  });
