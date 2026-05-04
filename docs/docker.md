# Database Docker Runbook

This phase runs the databases only. The backend process still runs on the host with
`npm run dev` from `backend/`.

## Prerequisites

- Docker Desktop, or Docker Engine with Compose v2.
- Node.js 20+ and npm for running Prisma migrations and the backend.
- A backend `.env` copied from `backend/.env.example`.

## Start And Inspect

```powershell
cd backend
docker compose up -d
docker compose ps
```

Expected services:

- `bahya-postgres` on `127.0.0.1:5433`, image `postgres:16`
- `bahya-mongo` on `127.0.0.1:27017`, image `mongo:7`

Both services should report `healthy` within about 60 seconds. If they stay in
`starting`, inspect logs:

```powershell
docker compose logs postgres
docker compose logs mongo
```

## Volumes

The stack uses named volumes:

- `postgres_data` mounted at `/var/lib/postgresql/data`
- `mongo_data` mounted at `/data/db`

`docker compose down` stops and removes containers, but keeps these volumes and
their data. Starting the stack again with `docker compose up -d` reuses the same
data.

`docker compose down -v` is destructive. It deletes `postgres_data` and
`mongo_data`, wiping local database state.

## Application Lifecycle

After the database tier is healthy:

```powershell
cd backend
npm run prisma:migrate
npm run dev
```

The backend should log successful PostgreSQL and MongoDB startup. MongoDB uses
the credentials from `MONGO_INITDB_ROOT_USERNAME` and
`MONGO_INITDB_ROOT_PASSWORD`, and the app connects through `MONGODB_URI` with
`authSource=admin`.

## Audit Failure Operations

Strict audit actions reject the originating request if MongoDB is unavailable
before the primary database write commits. For operator triage, a 503 with
`AUDIT_UNAVAILABLE` during `PASSWORD_RESET_BY_ADMIN` or
`HIGH_RISK_ALERT_CREATED` means MongoDB health should be checked first.
`USER_CREATED` audit failures after a user row has committed, `LOGIN` audit
failures after refresh-token persistence, and `LOGIN_FAIL` audit failures that
must preserve the standard 401 response, are logged as `audit_write_failure`
errors while the client response is preserved:

```powershell
docker compose ps
docker compose logs mongo
```

Best-effort audit actions log a structured `audit_write_failure` warning and let
the request continue.
