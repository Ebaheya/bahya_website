-- Optional expiry/due date for a published assignment: once dueAt has passed the
-- form can no longer be filled.
ALTER TABLE "FormAssignment" ADD COLUMN "dueAt" TIMESTAMP(3);

-- One-outstanding-copy-per-form guard. A patient (or a volunteer acting for them)
-- must not hold two not-yet-submitted copies of the same form template at once.
-- Re-publishing is allowed once the prior copy leaves the active set (SUBMITTED,
-- REVIEWED or CANCELLED). This filtered UNIQUE index backs the application guard
-- against the double-click / concurrent-publish race; Prisma cannot express a
-- partial index, so it is defined here rather than in schema.prisma.
CREATE UNIQUE INDEX "FormAssignment_template_patient_active_unique"
  ON "FormAssignment" ("templateId", "patientId")
  WHERE "status" IN ('SCHEDULED', 'PUBLISHED');
