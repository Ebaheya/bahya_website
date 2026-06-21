#!/bin/sh
set -e

# Apply any pending PostgreSQL migrations before the API starts accepting
# traffic. `migrate deploy` is the production-safe command: it only applies
# already-committed migration files and never generates or resets schema.
echo "[entrypoint] applying database migrations (prisma migrate deploy)"
npx prisma migrate deploy

echo "[entrypoint] starting: $*"
exec "$@"
