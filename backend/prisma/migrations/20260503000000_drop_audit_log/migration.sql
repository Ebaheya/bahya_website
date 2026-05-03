/*
Intentionally no-op.

The application no longer has a Prisma `AuditLog` model, but the physical
PostgreSQL table must remain available until operators run:

  npm run audit:migrate

and verify parity in MongoDB. Dropping the table as part of the normal pending
Prisma migration flow would delete the source rows before the backfill script
can copy them.

After parity is verified, operators may drop the legacy table manually:

  DROP TABLE IF EXISTS "AuditLog";

Manual rollback SQL, if the table has been dropped by mistake:

CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "actionType" TEXT NOT NULL,
    "entity" TEXT,
    "entityId" TEXT,
    "oldValues" JSONB,
    "newValues" JSONB,
    "ip" TEXT,
    "userAgent" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "AuditLog_userId_createdAt_idx" ON "AuditLog"("userId", "createdAt");
CREATE INDEX "AuditLog_actionType_createdAt_idx" ON "AuditLog"("actionType", "createdAt");

ALTER TABLE "AuditLog"
ADD CONSTRAINT "AuditLog_userId_fkey"
FOREIGN KEY ("userId") REFERENCES "User"("id")
ON DELETE SET NULL ON UPDATE CASCADE;
*/
