# Bahya Backend

Node.js + Express + TypeScript API for the Bahya platform. The backend uses
Prisma with PostgreSQL for relational data, Mongoose with MongoDB for activity
data, and Mailpit-compatible SMTP settings for local password-reset email.

## Implemented Modules

- Auth: staff bootstrap, staff registration, patient registration, login,
  refresh, logout, `/me`, change password, forgot password, reset password.
- Patients: create, list/search, self/staff profile read, demographic patch,
  JSONB medical/social/financial blocks, and timeline scaffold.
- Users: admin-only list, read, full-name patch, active status changes with
  last-admin lockout protection, and admin-triggered password reset.
- Audit logging: auth, patient, user, and password-reset events with sensitive
  values kept out of logs and audit payloads.

## Prerequisites

- Node.js 20+
- npm
- Docker + Docker Compose for local PostgreSQL 16, MongoDB 7, and Mailpit

## Local Setup

```bash
cd backend
docker compose up -d
npm install
cp .env.example .env
npx prisma migrate dev
npx prisma generate
npm run dev
```

The API listens on `http://localhost:3000` by default.

Health check:

```bash
curl http://localhost:3000/api/v1/health
```

Expected healthy response:

```json
{
  "status": "ok",
  "services": {
    "postgres": "up",
    "mongo": "up"
  }
}
```

Mailpit is exposed at `http://localhost:8025` for inspecting local reset emails.

## Environment

Start from `.env.example` and override values in `.env`.

Required values:

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string used by Prisma |
| `MONGODB_URI` | MongoDB connection string used by Mongoose |
| `JWT_ACCESS_SECRET` | Access-token signing secret, at least 32 chars |
| `JWT_REFRESH_SECRET` | Refresh-token signing secret, at least 32 chars |
| `BOOTSTRAP_SECRET` | One-time first-admin bootstrap secret, at least 16 chars |
| `CORS_ORIGINS` | Comma-separated browser origin allow-list, or `*` in development |

Password reset and email values:

| Variable | Default | Purpose |
|---|---|---|
| `SMTP_HOST` | `localhost` | SMTP host, Mailpit in local development |
| `SMTP_PORT` | `1025` | SMTP port |
| `SMTP_USER` | empty | Optional SMTP username |
| `SMTP_PASS` | empty | Optional SMTP password |
| `SMTP_FROM` | `noreply@bahya.health` | Sender address |
| `RESET_TOKEN_TTL_MINUTES` | `30` | Password reset token expiry |
| `APP_URL` | `http://localhost:3000` | Base URL used in reset links |

## Scripts

| Script | Description |
|---|---|
| `npm run dev` | Start the development server with `ts-node-dev` |
| `npm run build` | Compile TypeScript to `dist/` |
| `npm start` | Run the compiled server |
| `npm run prisma:generate` | Regenerate Prisma Client |
| `npm run prisma:migrate` | Create and apply a development migration |
| `npm run audit:migrate` | Migrate audit data to MongoDB |
| `npm run lint` | Run ESLint over `src/` |
| `npm run format` | Format backend source with Prettier |
| `npm test` | Run Jest unit and integration tests |

## API Summary

Base path: `/api/v1`.

### Health

- `GET /health`

### Auth

- `POST /auth/register-staff`
- `POST /auth/register-patient`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me`
- `PATCH /auth/change-password`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`

Notes:

- First admin bootstrap uses `X-Bootstrap-Secret` and is only allowed while no
  admin exists.
- Normal staff registration requires an ADMIN access token.
- Login is rate-limited at 10 requests per minute per IP.
- Forgot password is rate-limited at 5 requests per email per 15-minute window.
- Password changes and resets revoke existing refresh tokens.

### Patients

- `POST /patients` - ADMIN and CALL_CENTER create patient accounts.
- `GET /patients` - ADMIN, DOCTOR, CALL_CENTER, and VOLUNTEER list/search.
- `GET /patients/:id` - staff read profiles; PATIENT can read only self.
- `PATCH /patients/:id` - ADMIN and CALL_CENTER update demographics/JSONB data.
- `GET /patients/:id/timeline` - ADMIN and DOCTOR read timeline data.

Patient JSONB blocks use strict schemas:

- `medicalHistory`: `allergies`, `conditions`, `notes`
- `socialStatus`: `maritalStatus`, `familySupport`, `notes`
- `financials`: `incomeBracket`, `notes`

Patch requests shallow-merge each JSONB block. Setting a sub-key to `null`
removes that sub-key. Volunteers do not receive `financials` in patient
responses.

### Users

All `/users` endpoints are ADMIN-only:

- `GET /users`
- `GET /users/:id`
- `PATCH /users/:id`
- `PATCH /users/:id/status`
- `POST /users/:id/trigger-reset`

User list supports `q`, `role`, `isActive`, `page`, and `pageSize` query
parameters.

## Architecture

```text
src/
  config/        env, email config, Prisma, Mongo, logger
  middleware/    auth, authorization, audit, errors, request IDs
  modules/
    auth/        auth routes, controller, service, schemas
    email/       password-reset email service and templates
    patients/    patient routes, controller, service, schemas, validators
    users/       admin user-management routes, controller, service, schemas
  routes/        /api/v1 router and health probe
  utils/         passwords, tokens, http errors
  app.ts         Express wiring
  server.ts      startup and graceful shutdown
prisma/
  schema.prisma
  migrations/
tests/
  integration/
  unit/
```

## Database

Relational models in Prisma:

- `User`
- `RefreshToken`
- `Patient`
- `PasswordResetToken`

MongoDB stores activity/audit data used by the timeline and audit modules.

See `prisma/schema.prisma` for the current schema.

## Security Defaults

- JWT access tokens with `{ sub, role }` payloads.
- Opaque refresh tokens stored only as SHA-256 hashes.
- bcrypt password hashing.
- Helmet response headers.
- CORS allow-list from `CORS_ORIGINS`.
- Express rate limiting for auth endpoints.
- Pino redaction for auth headers, bootstrap secret, passwords, and tokens.
- Production refuses wildcard CORS.

## Validation

Run the same checks used during implementation:

```bash
npm run build
npm run lint
npm test -- --runInBand
npx jest --testPathPatterns=validators --runInBand
```

For the full happy path, follow `../specs/003-patient-module/quickstart.md`.
