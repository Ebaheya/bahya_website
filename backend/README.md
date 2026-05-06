# Bahya Backend

Node.js + Express + TypeScript API for the Bahya platform. The backend uses
Prisma with PostgreSQL for relational data, Mongoose with MongoDB for activity
data, and Mailpit-compatible SMTP for local password-reset email.

This README is split in two: the first half covers running the service locally
(stack, setup, environment, scripts, architecture). The second half is a
reference for every endpoint exposed under `/api/v1`, intended for frontend
developers and engineers exercising the API in Postman.

- [Stack](#stack)
- [Quick start](#quick-start)
- [Environment](#environment)
- [Scripts](#scripts)
- [Architecture](#architecture)
- [Database](#database)
- [Tests](#tests)
- [Postman](#postman)
- [Authentication](#authentication)
- [API Reference](#api-reference)
  - [Conventions](#conventions)
  - [Health](#health)
  - [Auth](#auth)
  - [Patients](#patients)
  - [Users](#users)

## Stack

- Node.js 20+, Express 4, TypeScript 5
- Prisma 5 + PostgreSQL 16 (relational)
- Mongoose 8 + MongoDB 7 (audit log, interventions, activity)
- Zod for request validation
- JWT access tokens + opaque refresh tokens (SHA-256 hashed at rest)
- bcrypt for password hashing
- pino for structured logging, helmet, express-rate-limit, CORS allow-list
- nodemailer + Mailpit for local password-reset email

## Quick start

```bash
cd backend
docker compose up -d            # PostgreSQL on 5433, MongoDB on 27017, Mailpit on 1025/8025
npm install
cp .env.example .env
npx prisma migrate dev
npx prisma generate
npm run dev
```

The API listens on `http://localhost:3000`. Confirm it is up:

```bash
curl http://localhost:3000/api/v1/health
```

```json
{
  "status": "ok",
  "timestamp": "2026-05-06T10:15:00.000Z",
  "services": { "postgres": "up", "mongo": "up" }
}
```

Mailpit's web UI is at `http://localhost:8025` for inspecting password-reset
emails captured in development.

## Environment

Copy `.env.example` to `.env` and override values as needed. The server
refuses to start if required values are missing.

| Variable | Required | Default | Purpose |
|---|---|---|---|
| `NODE_ENV` | no | `development` | `development`, `test`, or `production` |
| `PORT` | no | `3000` | HTTP port |
| `LOG_LEVEL` | no | `info` | pino log level |
| `DATABASE_URL` | yes | — | PostgreSQL connection string used by Prisma |
| `MONGODB_URI` | yes | — | MongoDB connection string used by Mongoose |
| `JWT_ACCESS_SECRET` | yes | — | Access-token signing secret, at least 32 chars |
| `JWT_REFRESH_SECRET` | yes | — | Refresh-token signing secret, at least 32 chars |
| `ACCESS_TOKEN_TTL` | no | `15m` | Access-token lifetime (e.g. `15m`, `1h`) |
| `REFRESH_TOKEN_TTL_DAYS` | no | `7` | Refresh-token lifetime in days |
| `BOOTSTRAP_SECRET` | yes | — | One-time first-admin bootstrap secret, at least 16 chars |
| `CORS_ORIGINS` | yes | — | Comma-separated browser origin allow-list, or `*` in development. Production refuses `*`. |
| `TRUST_PROXY` | no | `false` | Set to `true` only when deployed behind a trusted reverse proxy (Nginx, ALB). When `false`, `X-Forwarded-For` is ignored — protects per-IP rate limits and audit IPs from spoofing. |
| `SMTP_HOST` | no | `localhost` | SMTP host (Mailpit in local dev) |
| `SMTP_PORT` | no | `1025` | SMTP port |
| `SMTP_USER` | no | empty | Optional SMTP username |
| `SMTP_PASS` | no | empty | Optional SMTP password |
| `SMTP_FROM` | no | `noreply@bahya.health` | Sender address for password-reset email |
| `RESET_TOKEN_TTL_MINUTES` | no | `30` | Password-reset token lifetime |
| `APP_URL` | no | `http://localhost:3000` | Base URL embedded in reset links |

## Scripts

| Script | Description |
|---|---|
| `npm run dev` | Start the dev server with `ts-node-dev` |
| `npm run build` | Compile TypeScript to `dist/` |
| `npm start` | Run the compiled server |
| `npm run prisma:generate` | Regenerate Prisma Client |
| `npm run prisma:migrate` | Create and apply a development migration |
| `npm run audit:migrate` | Migrate audit data to MongoDB |
| `npm run lint` | Run ESLint over `src/` |
| `npm run format` | Format backend source with Prettier |
| `npm test` | Run Jest unit and integration tests |

## Architecture

```text
src/
  config/        env, email config, Prisma, Mongo, logger
  middleware/    authenticate, authorize, audit, errors, request IDs
  modules/
    auth/        routes, controller, service, schemas, reset tokens
    email/       password-reset email service and templates
    patients/    routes, controller, service, schemas, JSONB validators
    users/       admin user management
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

Relational models in Prisma (`prisma/schema.prisma`):

- `User` — staff and patient accounts; role determines access
- `RefreshToken` — opaque refresh tokens, hashed at rest, with `replacedBy` chain
- `Patient` — demographics + JSONB blocks (`medicalHistory`, `socialStatus`, `financials`)
- `PasswordResetToken` — single-use, time-bounded reset tokens

MongoDB stores audit log entries and timeline source data (assessments,
interventions). The `/health` probe checks both stores.

## Tests

```bash
npm run build
npm run lint
npm test -- --runInBand
npx jest --testPathPatterns=validators --runInBand
```

Integration tests live in `tests/integration/` and exercise the API against a
real PostgreSQL + MongoDB pair. For an end-to-end happy path that mirrors
manual QA, follow `../specs/003-patient-module/quickstart.md`.

---

## Postman

The API base URL in local development is:

```
http://localhost:3000/api/v1
```

Recommended Postman setup:

1. Create a Postman environment (e.g. "Bahya Local") with variables
   `baseUrl`, `accessToken`, and `refreshToken`.
2. Set `baseUrl` to `http://localhost:3000/api/v1`.
3. Send the [`POST /auth/login`](#post-authlogin) request first. In its
   **Tests** tab, save the tokens to the environment so subsequent requests
   pick them up automatically:

   ```javascript
   const body = pm.response.json();
   pm.environment.set("accessToken", body.accessToken);
   pm.environment.set("refreshToken", body.refreshToken);
   ```

4. On every authenticated request, set the **Authorization** header to
   `Bearer {{accessToken}}`. When the access token expires (default 15
   minutes), call [`POST /auth/refresh`](#post-authrefresh) and reuse the same
   "save tokens" snippet — `/auth/refresh` rotates the refresh token, so the
   old one becomes invalid as soon as the new pair is issued.

Every example body in the API reference below is copy-paste-ready for
Postman's **Body → raw → JSON** tab.

## Authentication

Most endpoints require a JWT access token in the `Authorization` header:

```
Authorization: Bearer <accessToken>
```

Tokens are issued by `POST /auth/login`. The response gives you both an
access token (short-lived, signed JWT carrying `{ sub, role }`) and a refresh
token (opaque random string, hashed at rest in the database).

The role on `req.user` is always re-read from PostgreSQL on every request, so
deactivating a user or changing their role takes effect immediately — even
before their access token would expire.

End-to-end flow:

```http
# 1) Log in to get tokens
POST /api/v1/auth/login
Content-Type: application/json

{ "email": "admin@example.com", "password": "correct horse battery staple" }
```

```json
{
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "9b3a...e7"
}
```

```http
# 2) Call any protected endpoint with the access token
GET /api/v1/auth/me
Authorization: Bearer eyJhbGciOi...
```

```http
# 3) When the access token expires, exchange the refresh token for a new pair
POST /api/v1/auth/refresh
Content-Type: application/json

{ "refreshToken": "9b3a...e7" }
```

```json
{ "accessToken": "eyJhbGciOi...new", "refreshToken": "f4c1...9a" }
```

The previous refresh token is revoked the moment a new pair is issued.
Re-using a refresh token returns `401 UNAUTHORIZED`.

To sign out, call [`POST /auth/logout`](#post-authlogout) with the current
refresh token. The access token has no server-side revocation; it expires on
its own (default 15 minutes).

---

## API Reference

### Conventions

- **Base path:** `/api/v1`. All paths in this section are relative to that
  prefix.
- **Content type:** all request bodies are `application/json`. All responses
  are JSON unless explicitly noted.
- **Auth header:** protected endpoints require `Authorization: Bearer
  <accessToken>`. Endpoints labeled **Auth: none** are public.
- **Roles:** the API uses five roles — `ADMIN`, `DOCTOR`, `CALL_CENTER`,
  `VOLUNTEER`, `PATIENT`. Each endpoint lists which roles may call it.
- **Date and ID formats:** `id` fields are UUID v4. Timestamps are ISO 8601
  strings. `dateOfBirth` accepts either an ISO datetime with offset or a
  plain `YYYY-MM-DD` string and is stored as a `Date`.

#### Standard error envelope

Every error response from the API uses the same shape:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "requestId": "abc123",
    "details": { "fieldErrors": { "email": ["Invalid email"] } }
  }
}
```

- `code` — stable machine-readable identifier (do not parse `message`).
- `message` — human-readable summary; safe to surface to a developer audience.
- `requestId` — correlates with server logs; include it when filing bugs.
- `details` — present for `VALIDATION_ERROR` (Zod's `flatten()` output) and
  for some conflicts; absent otherwise.

Common `(status, code)` pairs you will see across the API:

| Status | Code | When |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Body, params, or query failed Zod validation |
| `400` | `BAD_REQUEST` | Other client-side request error |
| `400` | `INVALID_OR_EXPIRED_TOKEN` | Reset token consumed, expired, or unknown |
| `401` | `UNAUTHORIZED` | Missing/invalid bearer token, refresh-token reuse, deactivated user |
| `401` | `INVALID_CREDENTIALS` | Email/password mismatch on login or change-password |
| `403` | `FORBIDDEN` | Authenticated but role not allowed; or invalid bootstrap secret |
| `404` | `NOT_FOUND` | Route or resource does not exist |
| `409` | `CONFLICT` | Email already registered or other unique-constraint conflict |
| `409` | `LAST_ACTIVE_ADMIN` | Attempt to deactivate the only remaining active admin |
| `429` | (rate-limit body) | Express rate-limit triggered (see endpoint notes) |
| `503` | `AUDIT_UNAVAILABLE` | Mongo audit write failed for a strict-tier action that has not yet committed (e.g. login fail) |
| `503` | `DEPENDENCY_FAILURE` | A backing service required for the request is down (e.g. Mongo for the timeline) |
| `503` | `EMAIL_DELIVERY_FAILED` | SMTP rejected an outgoing email |
| `500` | `INTERNAL` | Unhandled server error |

Each endpoint section below lists only the codes it can produce in addition
to the universal ones (`401 UNAUTHORIZED` if a bearer token is required and
missing, `403 FORBIDDEN` if the role is wrong, `429` for rate-limited routes,
`500 INTERNAL` for unexpected failures).

---

### Health

#### `GET /health`

Liveness/readiness probe. Returns `200` when both PostgreSQL and MongoDB are
reachable, `503` otherwise. The probe is bounded under one second even when
the database is degraded.

**Auth:** none.

**Response 200**

```json
{
  "status": "ok",
  "timestamp": "2026-05-06T10:15:00.000Z",
  "services": { "postgres": "up", "mongo": "up" }
}
```

**Response 503** (one or both backends down)

```json
{
  "status": "degraded",
  "timestamp": "2026-05-06T10:15:00.000Z",
  "services": { "postgres": "up", "mongo": "down" }
}
```

---

### Auth

All `/auth` routes share a 20-requests-per-minute baseline IP limiter, with
stricter per-route limits called out below.

#### `POST /auth/register-staff`

Creates a staff user (ADMIN, DOCTOR, VOLUNTEER, or CALL_CENTER). Two
authentication modes are supported:

- **Bootstrap (one-time):** if no admin exists yet, send the
  `X-Bootstrap-Secret` header. The request must create an `ADMIN`. Once the
  first admin exists, this header path is rejected with `403 FORBIDDEN`.
- **Standard:** otherwise, an authenticated `ADMIN` access token is required.

**Auth:** Bearer token (ADMIN) **or** `X-Bootstrap-Secret` header.
**Roles:** ADMIN. Bootstrap path: only when no admin exists, and `role`
must be `ADMIN`.

**Rate limit:** 20/min/IP.

**Request body**

| Field | Type | Required | Notes |
|---|---|---|---|
| `email` | string | yes | Valid email, max 254 chars, lowercased server-side |
| `password` | string | yes | 8–128 chars |
| `fullName` | string | yes | 2–120 chars, trimmed |
| `role` | enum | yes | `ADMIN`, `DOCTOR`, `VOLUNTEER`, `CALL_CENTER` |

```json
{
  "email": "doctor@example.com",
  "password": "ChangeMe123!",
  "fullName": "Dr. Jane Roe",
  "role": "DOCTOR"
}
```

**Response 201** (standard, ADMIN-authenticated)

```json
{
  "user": {
    "id": "8d4b2a3e-8f0c-4d6c-9c8b-2a5b6c7d8e9f",
    "email": "doctor@example.com",
    "fullName": "Dr. Jane Roe",
    "role": "DOCTOR",
    "isActive": true,
    "createdAt": "2026-05-06T10:00:00.000Z",
    "updatedAt": "2026-05-06T10:00:00.000Z"
  }
}
```

**Response 201** (bootstrap path)

```json
{
  "user": { "id": "...", "email": "...", "role": "ADMIN", "...": "..." },
  "bootstrap": true
}
```

**Errors**

- `400 VALIDATION_ERROR` — body did not validate, or bootstrap path used with `role !== "ADMIN"` (returns `400 BAD_REQUEST`)
- `403 FORBIDDEN` — neither an ADMIN token nor a valid bootstrap secret was provided; or the bootstrap path was used after an admin already exists
- `409 CONFLICT` — `Email already registered`

#### `POST /auth/login`

Exchanges email and password for an access token + refresh token pair.

**Auth:** none.
**Rate limit:** 10/min/IP.

**Request body**

```json
{ "email": "admin@example.com", "password": "ChangeMe123!" }
```

**Response 200**

```json
{
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "9b3a...e7"
}
```

**Errors**

- `400 VALIDATION_ERROR` — missing or malformed `email`/`password`
- `401 UNAUTHORIZED` — `Invalid email or password` (covers unknown email, deactivated user, and bad password)

#### `POST /auth/refresh`

Rotates the refresh token. The submitted refresh token is revoked atomically
and a new access + refresh token pair is returned. Re-using the same refresh
token a second time fails with `401`.

**Auth:** none (the refresh token in the body is the credential).
**Rate limit:** 20/min/IP.

**Request body**

```json
{ "refreshToken": "9b3a...e7" }
```

**Response 200**

```json
{ "accessToken": "eyJhbGciOi...new", "refreshToken": "f4c1...9a" }
```

**Errors**

- `400 VALIDATION_ERROR` — `refreshToken` missing or empty
- `401 UNAUTHORIZED` — token unknown, expired, already used/revoked, or owner is inactive

#### `POST /auth/logout`

Revokes the supplied refresh token. Idempotent: revoking an already-revoked
or unknown token returns `204` with no body.

**Auth:** none (refresh token is the credential).
**Rate limit:** 20/min/IP.

**Request body**

```json
{ "refreshToken": "9b3a...e7" }
```

**Response 204** — empty body.

**Errors**

- `400 VALIDATION_ERROR` — `refreshToken` missing or empty

#### `GET /auth/me`

Returns the current authenticated user.

**Auth:** Bearer token. **Roles:** any.

**Response 200**

```json
{
  "user": {
    "id": "8d4b2a3e-8f0c-4d6c-9c8b-2a5b6c7d8e9f",
    "email": "admin@example.com",
    "fullName": "Site Admin",
    "role": "ADMIN",
    "isActive": true,
    "createdAt": "2026-05-01T08:00:00.000Z",
    "updatedAt": "2026-05-01T08:00:00.000Z"
  }
}
```

**Errors**

- `401 UNAUTHORIZED` — missing/invalid bearer token
- `404 NOT_FOUND` — user record was deleted between token issuance and now

#### `PATCH /auth/change-password`

Changes the authenticated user's password. On success, all of that user's
active refresh tokens and outstanding password-reset tokens are revoked.

**Auth:** Bearer token. **Roles:** any.
**Rate limit:** 20/min/IP.

**Request body**

| Field | Type | Required | Notes |
|---|---|---|---|
| `currentPassword` | string | yes | Must match the stored hash |
| `newPassword` | string | yes | 8–128 chars |

```json
{
  "currentPassword": "ChangeMe123!",
  "newPassword": "Even-Better-Pass!2026"
}
```

**Response 200**

```json
{ "message": "Password changed successfully" }
```

**Errors**

- `400 VALIDATION_ERROR` — body failed validation
- `401 UNAUTHORIZED` — caller is not authenticated, or user has been deactivated
- `401 INVALID_CREDENTIALS` — `currentPassword` does not match

#### `POST /auth/forgot-password`

Starts a password reset. Always returns `200` with a generic message,
regardless of whether the email exists, so callers cannot enumerate accounts.
If the email matches an active user, a reset link is sent via SMTP (Mailpit
in local dev).

**Auth:** none.
**Rate limit:** 5 requests per `(email, IP)` pair per 15-minute window.

**Request body**

```json
{ "email": "admin@example.com" }
```

**Response 200**

```json
{ "message": "If an account with that email exists, a password reset link has been sent" }
```

**Errors**

- `400 VALIDATION_ERROR` — `email` missing or malformed

#### `POST /auth/reset-password`

Consumes a reset token (from the email link) and sets a new password. The
token is single-use and time-bounded (`RESET_TOKEN_TTL_MINUTES`, default 30).
On success, all of the user's active refresh tokens are revoked.

**Auth:** none (the reset token is the credential).
**Rate limit:** 20/min/IP.

**Request body**

| Field | Type | Required | Notes |
|---|---|---|---|
| `token` | string | yes | The raw reset token from the email URL |
| `newPassword` | string | yes | 8–128 chars |

```json
{
  "token": "a4c93f1b...e0",
  "newPassword": "Even-Better-Pass!2026"
}
```

**Response 200**

```json
{ "message": "Password has been reset successfully" }
```

**Errors**

- `400 VALIDATION_ERROR` — body failed validation
- `400 INVALID_OR_EXPIRED_TOKEN` — token unknown, already used, expired, or owner is deactivated

---

### Patients

Patient resources combine a `User` (with role `PATIENT`) and a `Patient`
demographic record. The `POST /patients` endpoint creates both atomically;
there is no separate "register patient" endpoint.

#### Common patient response shape

After flattening by `sanitizePatientResponse`, every patient response has
these fields. Volunteers do not receive `financials` (the field is removed
from the response, not nulled).

```json
{
  "id": "f2a8b6c4-1d3e-4a5b-9c8d-7e6f5a4b3c2d",
  "userId": "9c8d7e6f-5a4b-3c2d-1e0f-9a8b7c6d5e4f",
  "fullName": "Sara Patient",
  "email": "sara@example.com",
  "role": "PATIENT",
  "isActive": true,
  "phone": "+201001112222",
  "dateOfBirth": "1990-05-12T00:00:00.000Z",
  "gender": "FEMALE",
  "address": "12 Tahrir Square, Cairo",
  "emergencyContactName": "Ahmed Patient",
  "emergencyContactPhone": "+201003334444",
  "medicalHistory": { "allergies": ["penicillin"], "conditions": [], "notes": null },
  "socialStatus":   { "maritalStatus": "single", "familySupport": "moderate", "notes": null },
  "financials":     { "incomeBracket": "low", "notes": null },
  "createdAt": "2026-05-06T10:00:00.000Z",
  "updatedAt": "2026-05-06T10:00:00.000Z"
}
```

JSONB blocks have strict shapes — unknown keys are rejected with
`400 VALIDATION_ERROR`:

| Block | Allowed keys |
|---|---|
| `medicalHistory` | `allergies` (string[]), `conditions` (string[]), `notes` (string) |
| `socialStatus` | `maritalStatus` (string), `familySupport` (string), `notes` (string) |
| `financials` | `incomeBracket` (string), `notes` (string) |

Each leaf inside a block can be set to `null` on PATCH to delete that key
from the stored block. PATCH shallow-merges blocks; it does not replace them
wholesale.

#### `POST /patients`

Creates a new `User` (with `role = PATIENT`) and a linked `Patient` row in a
single transaction. Emits both `USER_CREATED` and `PATIENT_CREATED` audit
records.

**Auth:** Bearer token. **Roles:** ADMIN, CALL_CENTER.

**Request body**

| Field | Type | Required | Notes |
|---|---|---|---|
| `fullName` | string | yes | 2–120 chars, trimmed |
| `email` | string | yes | Valid email, max 254 chars, lowercased server-side |
| `password` | string | yes | 8–128 chars; the patient signs in with this |
| `phone` | string | yes | Matches `^\+?[0-9]{8,15}$` |
| `dateOfBirth` | string | no | ISO datetime with offset, or `YYYY-MM-DD`. Must be in the past, within the last 130 years. |
| `gender` | enum | no | `MALE`, `FEMALE`, `OTHER` |
| `address` | string | no | Non-empty when present |
| `emergencyContactName` | string | no | Non-empty when present |
| `emergencyContactPhone` | string | no | Same phone format as `phone` |
| `medicalHistory` | object | no | See JSONB block table above |
| `socialStatus` | object | no | See JSONB block table above |
| `financials` | object | no | See JSONB block table above |

The body is `.strict()` — unknown top-level keys produce `400 VALIDATION_ERROR`.

```json
{
  "fullName": "Sara Patient",
  "email": "sara@example.com",
  "password": "Welcome123!",
  "phone": "+201001112222",
  "dateOfBirth": "1990-05-12",
  "gender": "FEMALE",
  "address": "12 Tahrir Square, Cairo",
  "emergencyContactName": "Ahmed Patient",
  "emergencyContactPhone": "+201003334444",
  "medicalHistory": { "allergies": ["penicillin"] }
}
```

**Response 201** — the [common patient response shape](#common-patient-response-shape).

**Errors**

- `400 VALIDATION_ERROR` — invalid body
- `403 FORBIDDEN` — caller is not ADMIN or CALL_CENTER
- `409 CONFLICT` — `Email already registered`

#### `GET /patients`

Paginated list of patients with optional search.

**Auth:** Bearer token. **Roles:** ADMIN, DOCTOR, CALL_CENTER, VOLUNTEER.

**Query parameters**

| Param | Type | Default | Notes |
|---|---|---|---|
| `q` | string | — | Case-insensitive substring match on `fullName` or `email` |
| `phone` | string | — | Exact match; same phone format as create |
| `page` | int | `1` | 1-indexed |
| `pageSize` | int | `20` | Max `100` |

The query is `.strict()` — unknown query parameters produce `400 VALIDATION_ERROR`.

Example: `GET /patients?q=sara&page=1&pageSize=20`

**Response 200**

```json
{
  "data": [ { "id": "...", "fullName": "Sara Patient", "...": "..." } ],
  "page": 1,
  "pageSize": 20,
  "total": 1
}
```

For `VOLUNTEER` callers, every item in `data` has its `financials` field
removed.

**Errors**

- `400 VALIDATION_ERROR` — bad query parameters
- `403 FORBIDDEN` — caller's role is not in the allow-list

#### `GET /patients/:id`

Fetches a single patient by patient id.

**Auth:** Bearer token. **Roles:** ADMIN, DOCTOR, CALL_CENTER, VOLUNTEER, PATIENT.

A `PATIENT` caller may only fetch their own patient record (the one whose
`userId` matches their token's `sub`); any other id returns `403 FORBIDDEN`.

**Response 200** — the [common patient response shape](#common-patient-response-shape) (volunteers receive it without `financials`).

**Errors**

- `400 VALIDATION_ERROR` — `id` is not a UUID
- `403 FORBIDDEN` — caller's role is not allowed, or `PATIENT` requested someone else's record
- `404 NOT_FOUND` — no patient with that id

#### `PATCH /patients/:id`

Updates demographic fields and shallow-merges JSONB blocks. Fields omitted
from the body are left untouched. Setting a scalar field to `null` clears
it (where the schema allows it). Setting a JSONB sub-key to `null` removes
that sub-key from the stored block.

**Auth:** Bearer token. **Roles:** ADMIN, CALL_CENTER.

**Request body** — all fields are optional; the body is `.strict()`.

| Field | Type | Nullable? | Notes |
|---|---|---|---|
| `phone` | string | no | Phone format |
| `dateOfBirth` | string | yes | ISO datetime or `YYYY-MM-DD`, past, within 130 years |
| `gender` | enum | yes | `MALE`, `FEMALE`, `OTHER` |
| `address` | string | yes | Non-empty when not null |
| `emergencyContactName` | string | yes | Non-empty when not null |
| `emergencyContactPhone` | string | yes | Phone format |
| `medicalHistory` | object | no | Shallow-merged into stored block |
| `socialStatus` | object | no | Shallow-merged into stored block |
| `financials` | object | no | Shallow-merged into stored block |

```json
{
  "address": "New Cairo, 5th Settlement",
  "medicalHistory": {
    "conditions": ["asthma"],
    "notes": null
  }
}
```

**Response 200** — the updated patient in the [common patient response shape](#common-patient-response-shape) (volunteers cannot reach this endpoint).

**Errors**

- `400 VALIDATION_ERROR` — invalid body or unknown field
- `403 FORBIDDEN` — caller is not ADMIN or CALL_CENTER
- `404 NOT_FOUND` — no patient with that id

#### `GET /patients/:id/timeline`

Returns a chronological timeline merged from PostgreSQL assessments and
MongoDB interventions, newest first.

**Auth:** Bearer token. **Roles:** ADMIN, DOCTOR.

**Query parameters**

| Param | Type | Default | Notes |
|---|---|---|---|
| `page` | int | `1` | 1-indexed |
| `pageSize` | int | `20` | Max `100`. The product `page * pageSize` may not exceed `1000`. |

**Response 200**

```json
{
  "data": [
    {
      "kind": "INTERVENTION",
      "id": "651f0b1f8c9e2a0012a4c8e1",
      "timestamp": "2026-05-04T13:22:00.000Z",
      "summary": "Phone check-in"
    },
    {
      "kind": "ASSESSMENT",
      "id": "5b1c3d2e-...",
      "timestamp": "2026-05-01T09:10:00.000Z",
      "summary": "Initial assessment"
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 2
}
```

**Errors**

- `400 VALIDATION_ERROR` — bad query parameters
- `400 BAD_REQUEST` — pagination window exceeds 1000 items
- `403 FORBIDDEN` — caller is not ADMIN or DOCTOR
- `404 NOT_FOUND` — no patient with that id
- `503 DEPENDENCY_FAILURE` — MongoDB is not reachable

---

### Users

All `/users` endpoints require an authenticated `ADMIN` access token.

**Auth:** Bearer token. **Roles:** ADMIN.

#### `GET /users`

Paginated list of users with optional filters.

**Query parameters**

| Param | Type | Default | Notes |
|---|---|---|---|
| `q` | string | — | Case-insensitive substring match on `fullName` or `email` |
| `role` | enum | — | One of `ADMIN`, `DOCTOR`, `VOLUNTEER`, `CALL_CENTER`, `PATIENT` |
| `isActive` | string | — | `true` or `false`; coerced to boolean |
| `page` | int | `1` | 1-indexed |
| `pageSize` | int | `20` | Max `100` |

The query is `.strict()` — unknown query parameters produce `400 VALIDATION_ERROR`.

**Response 200**

```json
{
  "data": [
    {
      "id": "...",
      "email": "doctor@example.com",
      "fullName": "Dr. Jane Roe",
      "role": "DOCTOR",
      "isActive": true,
      "createdAt": "2026-05-01T08:00:00.000Z",
      "updatedAt": "2026-05-01T08:00:00.000Z"
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 1
}
```

**Errors**

- `400 VALIDATION_ERROR` — bad query parameters
- `403 FORBIDDEN` — caller is not ADMIN

#### `GET /users/:id`

Fetches a single user (any role) by id.

**Response 200**

```json
{
  "id": "...",
  "email": "doctor@example.com",
  "fullName": "Dr. Jane Roe",
  "role": "DOCTOR",
  "isActive": true,
  "createdAt": "2026-05-01T08:00:00.000Z",
  "updatedAt": "2026-05-01T08:00:00.000Z"
}
```

**Errors**

- `400 VALIDATION_ERROR` — `id` is not a UUID
- `403 FORBIDDEN` — caller is not ADMIN
- `404 NOT_FOUND` — no user with that id

#### `PATCH /users/:id`

Updates a user's profile. Currently only `fullName` is supported; the body
is `.strict()`, so any other field returns `400 VALIDATION_ERROR`.

**Request body**

| Field | Type | Required | Notes |
|---|---|---|---|
| `fullName` | string | no | 2–120 chars, trimmed |

```json
{ "fullName": "Dr. Jane Roe, MD" }
```

**Response 200** — the updated user, same shape as `GET /users/:id`.

**Errors**

- `400 VALIDATION_ERROR` — invalid body
- `403 FORBIDDEN` — caller is not ADMIN
- `404 NOT_FOUND` — no user with that id

#### `PATCH /users/:id/status`

Activates or deactivates a user. Deactivating a user also revokes all of
their active refresh tokens. The system refuses to deactivate the last
remaining active admin.

**Request body**

| Field | Type | Required | Notes |
|---|---|---|---|
| `isActive` | boolean | yes | `true` to activate, `false` to deactivate |

```json
{ "isActive": false }
```

**Response 200** — the updated user, same shape as `GET /users/:id`.

**Errors**

- `400 VALIDATION_ERROR` — `isActive` missing or not a boolean
- `403 FORBIDDEN` — caller is not ADMIN
- `404 NOT_FOUND` — no user with that id
- `409 LAST_ACTIVE_ADMIN` — `Cannot deactivate the last active admin`

#### `POST /users/:id/trigger-reset`

Issues a password-reset token for the target user and emails them a reset
link. Use this when a user reports a forgotten password and the admin wants
to send them a fresh link without going through `/auth/forgot-password`.

**Request body:** none.

**Response 200**

```json
{ "message": "Password reset link sent to user's email" }
```

**Errors**

- `400 VALIDATION_ERROR` — `id` is not a UUID
- `403 FORBIDDEN` — caller is not ADMIN
- `404 NOT_FOUND` — no user with that id
- `503 EMAIL_DELIVERY_FAILED` — SMTP rejected the outgoing reset email

---

## Security defaults

- JWT access tokens carry only `{ sub, role }`; the role is re-read from
  PostgreSQL on every request, so demotions and deactivations take effect
  immediately.
- Refresh tokens are random 64-byte values, stored only as SHA-256 hashes,
  and rotated on every use with a `replacedBy` chain for audit.
- bcrypt password hashing.
- Helmet response headers and a CORS allow-list from `CORS_ORIGINS`
  (production refuses `*`).
- Express rate limiting on auth endpoints (see per-endpoint notes).
- pino redaction for `Authorization` headers, the bootstrap secret,
  passwords, and tokens.
- `TRUST_PROXY` defaults to `false` so a misconfigured deployment cannot let
  attackers spoof `X-Forwarded-For` to bypass per-IP rate limits or forge
  audit IPs.
