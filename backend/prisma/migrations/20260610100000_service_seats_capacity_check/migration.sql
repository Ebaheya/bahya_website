-- Backstop the core seat invariant (INV-1) at the database level: a service can
-- never have more accepted enrollments than its capacity, and seatsTaken can
-- never go negative. The application already guards both mutation paths with
-- live-value checks (approval increments WHERE seatsTaken < capacity; capacity
-- edits apply WHERE seatsTaken <= newCapacity), so this CHECK never trips in
-- correct flow — it exists so no future code path can silently oversubscribe a
-- service. Prisma cannot express a CHECK constraint in schema.prisma, so this
-- lives as raw SQL and MUST be preserved across future migrations.
ALTER TABLE "Service"
  ADD CONSTRAINT "Service_seats_within_capacity_check"
  CHECK ("seatsTaken" >= 0 AND "seatsTaken" <= "capacity");
