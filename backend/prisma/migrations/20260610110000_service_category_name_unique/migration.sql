-- Enforce case-insensitive uniqueness of service category names at the database
-- level. The service layer keeps a fast findFirst pre-check, but two concurrent
-- creates/renames with the same name could both pass that read and persist
-- duplicates. A functional unique index on LOWER(name) makes the second write
-- fail atomically; the application translates the violation (P2002) to
-- CATEGORY_NAME_TAKEN.
--
-- A plain (non-functional) UNIQUE on "name" would be case-sensitive, so it is a
-- functional index. Prisma cannot express a functional unique index in
-- schema.prisma, so this lives as raw SQL and MUST be preserved across future
-- migrations.
CREATE UNIQUE INDEX "ServiceCategory_name_lower_key"
  ON "ServiceCategory" (LOWER("name"));
