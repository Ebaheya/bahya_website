# Mental Health Clinic — Backend (Phase 1: Auth)

Node.js + Express + TypeScript + Prisma (PostgreSQL) API for the Mental Health Clinic platform.
This phase implements the full authentication module: register, login, refresh, logout, `/me`,
role-based access control (ADMIN / DOCTOR / VOLUNTEER / CALL_CENTER / PATIENT), and audit logging.

## Prerequisites

- Node.js 20+
- PostgreSQL 15+
- npm

## Setup

```bash
cd backend
npm install
cp .env.example .env
# edit .env: set DATABASE_URL, secrets, BOOTSTRAP_SECRET
npx prisma migrate dev --name init
npm run dev
```

Server listens on `http://localhost:3000` (default).

Health check: `GET /api/v1/health`.

## Scripts

| Script | Description |
|---|---|
| `npm run dev` | Start dev server with ts-node-dev + hot reload |
| `npm run build` | Compile TypeScript to `dist/` |
| `npm start` | Run compiled server from `dist/` |
| `npm run prisma:generate` | Regenerate Prisma Client |
| `npm run prisma:migrate` | Create/apply a dev migration |
| `npm run lint` | ESLint over `src/` |
| `npm run format` | Prettier write over `src/` |

## Architecture

```
src/
  config/      # env (zod), prisma singleton, pino logger
  middleware/  # authenticate, authorize, audit, errorHandler, requestId
  modules/
    auth/      # routes, controller, service, schemas (zod)
    users/     # user.service
  routes/      # /api/v1 mount
  utils/       # passwords (bcrypt), tokens (JWT + refresh), httpError
  app.ts       # express wiring
  server.ts    # bootstrap + graceful shutdown
prisma/
  schema.prisma
```

## Authentication model

- **Access token**: JWT, 15 min, payload `{ sub, role }`, signed with `JWT_ACCESS_SECRET`.
- **Refresh token**: opaque (64 random bytes, hex). Only its SHA-256 hash is stored in the
  `RefreshToken` table. Every call to `/auth/refresh` rotates the token: the old row is marked
  `revokedAt` and linked to the new row via `replacedBy`.
- **Logout**: revokes the submitted refresh token.

## Role matrix

| Role | Capabilities |
|---|---|
| `ADMIN` | Full CRUD, registers staff and patients |
| `DOCTOR` | View/edit own patients, analytics; can register patients |
| `VOLUNTEER` | Intake only; can register patients |
| `CALL_CENTER` | Escalation view only |
| `PATIENT` | Self-service only (own profile, PHQ-9, chatbot) |

## Endpoints

Base path: `/api/v1/auth`.

### 1. `POST /auth/register-staff`

Creates an ADMIN/DOCTOR/VOLUNTEER/CALL_CENTER user. Access:

- Normal path: requires `Authorization: Bearer <ADMIN access token>`.
- One-time bootstrap: if **no** admin exists in the DB yet, a single request with
  `X-Bootstrap-Secret: <BOOTSTRAP_SECRET>` creating an `ADMIN` is allowed. Subsequent
  bootstrap calls are rejected.

```bash
# BOOTSTRAP the first admin
curl -X POST http://localhost:3000/api/v1/auth/register-staff \
  -H 'Content-Type: application/json' \
  -H "X-Bootstrap-Secret: $BOOTSTRAP_SECRET" \
  -d '{
    "email": "admin@clinic.local",
    "password": "ChangeMe!123",
    "fullName": "Clinic Admin",
    "role": "ADMIN"
  }'

# As an existing ADMIN, create a doctor
curl -X POST http://localhost:3000/api/v1/auth/register-staff \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN" \
  -d '{
    "email": "dr.ahmed@clinic.local",
    "password": "ChangeMe!123",
    "fullName": "Dr. Ahmed",
    "role": "DOCTOR"
  }'
```

### 2. `POST /auth/register-patient`

Creates a PATIENT. Requires `Authorization: Bearer <token>` for a user with role
`ADMIN`, `DOCTOR`, or `VOLUNTEER`. The `role` field, if any, is ignored; the server
always stores `PATIENT`.

```bash
curl -X POST http://localhost:3000/api/v1/auth/register-patient \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $STAFF_ACCESS_TOKEN" \
  -d '{
    "email": "patient01@example.com",
    "password": "Patient!123",
    "fullName": "Sara Patient"
  }'
```

### 3. `POST /auth/login`

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{ "email": "admin@clinic.local", "password": "ChangeMe!123" }'
```

Response:

```json
{
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "af39...",
  "user": { "id": "...", "email": "...", "role": "ADMIN", "..." }
}
```

### 4. `POST /auth/refresh`

```bash
curl -X POST http://localhost:3000/api/v1/auth/refresh \
  -H 'Content-Type: application/json' \
  -d '{ "refreshToken": "af39..." }'
```

Returns a new `{ accessToken, refreshToken }` pair. The old refresh token is revoked.

### 5. `POST /auth/logout`

```bash
curl -X POST http://localhost:3000/api/v1/auth/logout \
  -H 'Content-Type: application/json' \
  -d '{ "refreshToken": "af39..." }'
```

Returns `204 No Content`. Revokes that refresh token.

### 6. `GET /auth/me`

```bash
curl http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

## Security defaults

- `helmet` for baseline response headers.
- `cors` with allow-list from `CORS_ORIGINS`.
- `express-rate-limit`: 10/min/IP on login, 20/min/IP on other `/auth/*`.
- bcrypt cost 12.
- Pino redacts `Authorization`, `X-Bootstrap-Secret`, passwords, and tokens.
- Audit log written on LOGIN / LOGIN_FAIL / LOGOUT / REFRESH / CREATE, with IP + user-agent.
- `.env` is gitignored; copy `.env.example` and fill it in.

## Database schema (phase 1)

- `User` — `id (uuid)`, `email (unique)`, `passwordHash`, `fullName`, `role (enum)`, `isActive`, timestamps.
- `RefreshToken` — `tokenHash (sha256, unique)`, `expiresAt`, `revokedAt`, `replacedBy`, `userAgent`, `ip`.
- `AuditLog` — `userId?`, `actionType`, `entity`, `entityId`, `oldValues`, `newValues`, `ip`, `userAgent`.

See [prisma/schema.prisma](./prisma/schema.prisma).

## Out of scope for phase 1

- MFA / TOTP (scaffold to come later).
- Patient, PHQ-9, intervention, analytics modules.
- Chatbot service.
