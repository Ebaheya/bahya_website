# Bahya Backend

Node.js + Express + TypeScript API for the Bahya platform. The backend uses
Prisma with PostgreSQL for relational data, Mongoose with MongoDB for activity
data, and Mailpit-compatible SMTP for local password-reset email.
Firebase Cloud Messaging (FCM) is optional and used for best-effort mobile
notification wakeups when credentials are configured.

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
- [Dynamic assessment forms](#dynamic-assessment-forms)
- [Patient services & activities](#patient-services--activities)
- [Notifications](#notifications)
- [Tests](#tests)
- [Postman](#postman)
- [Authentication](#authentication)
- [API Reference](#api-reference)
  - [Conventions](#conventions)
  - [Health](#health)
  - [Auth](#auth)
  - [Patients](#patients)
  - [Users](#users)
  - [Forms](#forms)
  - [Form Assignments](#form-assignments)
  - [Assessments](#assessments)
  - [Service Categories](#service-categories)
  - [Services](#services)
  - [Service Requests](#service-requests)
  - [Notifications](#notifications-1)

## Stack

- Node.js 20+, Express 4, TypeScript 5
- Prisma 5 + PostgreSQL 16 (relational)
- Mongoose 8 + MongoDB 7 (audit log, interventions, activity)
- Zod for request validation
- JWT access tokens + opaque refresh tokens (SHA-256 hashed at rest)
- bcrypt for password hashing
- pino for structured logging, helmet, express-rate-limit, CORS allow-list
- nodemailer + Mailpit for local password-reset email
- firebase-admin for optional best-effort FCM push notifications

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
| `FCM_ENABLED` | no | `false` | Enables best-effort Firebase Cloud Messaging push delivery |
| `FIREBASE_SERVICE_ACCOUNT` | no | empty | Base64-encoded Firebase service-account JSON |
| `GOOGLE_APPLICATION_CREDENTIALS` | no | empty | Optional path to a Firebase service-account JSON file |

## Scripts

| Script | Description |
|---|---|
| `npm run dev` | Start the dev server with `ts-node-dev` |
| `npm run build` | Compile TypeScript to `dist/` |
| `npm start` | Run the compiled server |
| `npm run prisma:generate` | Regenerate Prisma Client |
| `npm run prisma:migrate` | Create and apply a development migration |
| `npm run audit:migrate` | Migrate audit data to MongoDB |
| `npm run seed:forms` | Seed the seven default dynamic assessment forms |
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
    forms/       form authoring, publishing, assignments, scoring, submissions
    assessments/ doctor review and official assessment authorship
    services/    service categories, services, and join requests (enrollment)
    notifications/ inbox, claim/read/done lifecycle, booking requests, push devices
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
- `Patient` — demographics + unique `crn` (file number) + typed clinical fields (staging, treatment, tumour biology, BMI…) + JSONB blocks (`medicalHistory`, `socialStatus`, `financials`)
- `PasswordResetToken` — single-use, time-bounded reset tokens

Additional relational models for dynamic assessments are `FormTemplate`,
`FormVersion`, `FormQuestion`, `FormChoice`, `FormScoreRange`,
`FormAssignment`, `FormSubmission`, and `Assessment`.

Relational models for patient services & activities:

- `ServiceCategory` — service classification (`name`, `kind`, `iconKey`, `color`); seeded defaults + custom (`ServiceKind` = `EDUCATIONAL` / `TRIP` / `SUPPORT` / `OTHER`)
- `Service` — a joinable activity with a seat `capacity` and `seatsTaken`; `ServiceStatus` = `ACTIVE` / `CLOSED`; trip-kind services also carry `endDate`, `departureTime`, `meetingPlace`
- `ServiceRequest` — a patient's join request; `ServiceRequestStatus` = `PENDING` / `APPROVED` / `REJECTED` / `CANCELLED` (a seat is consumed only on `APPROVED`)

Relational model for mobile push delivery:

- `DeviceToken` - a user's FCM registration token, unique by token and scoped
  to one current user; used only for best-effort notification push delivery

MongoDB stores audit log entries and timeline source data (assessments,
interventions) plus emitted notifications. The `/health` probe checks both stores.

## Dynamic assessment forms

Doctors and admins author **scored assessment forms** — questions with scored
answer choices and interpretation bands — then publish them to patients or to
a volunteer filling on a patient's behalf. The recipient fills and submits the
form; the server recomputes the score and interpretation, stores the
submission, and (for a top-band score) raises a high-risk doctor alert. The
filler sees a confirmation only — never the score. A doctor later reviews the
submission and authors an official `Assessment`.

The feature spans three routers, all mounted under `/api/v1`:

- `forms/` — authoring, versioning, publishing, lifecycle (`/forms`)
- `forms/` assignments — filling and submission (`/form-assignments`)
- `assessments/` — doctor review and official assessment authorship (`/assessments`)

### Roles and access

Every route is `authenticate` (JWT + PostgreSQL role re-validation) then
`authorize(role)`:

- **Doctor, Admin** — author, version, publish, deactivate forms; list
  active volunteers for delegated assignments; list assignments; cancel
  assignments; read the review queue and submissions.
- **Doctor only** — create an official `Assessment` (`POST /assessments`).
- **Patient** — see and submit only forms assigned to their own account.
- **Volunteer** — see and submit only forms assigned to them, on behalf of the
  linked patient. Volunteers cannot author, edit, or publish.

A deactivated (inactive) patient sees and submits nothing; prior submissions
stay readable to staff.

### Rate limits

All three routers carry a per-user (per authenticated user id) limiter on a
60-second window, with two tighter buckets for expensive actions:

| Scope | Limit |
|---|---|
| All `/forms`, `/form-assignments`, `/assessments` routes (baseline) | 120 req/min/user |
| `POST /form-assignments/:id/submit` | 20 req/min/user |
| `POST /forms/:id/publish` | 10 req/min/user |

Exceeding a bucket returns `429` with standard `RateLimit-*` headers.

### Endpoints by lifecycle

**Authoring & versioning** (`/forms`, Doctor + Admin):

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/forms` | Create a custom form (template + v1 DRAFT) |
| `GET` | `/forms` | List templates (`q`, `isActive`, `isDefault`, `category`, paginated) |
| `GET` | `/forms/:id` | Template + current version (questions, choices, scores, ranges) |
| `PUT` | `/forms/:id` | Edit structure (in-place if DRAFT; clone to version N+1 if published) |
| `GET` | `/forms/:id/versions` | List all versions (newest first) |
| `GET` | `/forms/:id/versions/:version` | Fetch a specific historical version |
| `POST` | `/forms/:id/publish-version` | Promote the current DRAFT version to PUBLISHED (assignable) |
| `PATCH` | `/forms/:id/status` | Activate / deactivate the template |

**Publishing & scheduling** (`/forms`, `/form-assignments`, Doctor + Admin):

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/forms/:id/publish` | Publish to a target (single patient / all active patients / volunteer-for-patient), optional future `publishAt` |
| `GET` | `/patients/options` | List active patients for assignment selection |
| `GET` | `/volunteers` | List active volunteers for delegated assignment selection |
| `GET` | `/forms/:id/assignments` | List assignments for a template (paginated) |
| `PATCH` | `/form-assignments/:id/cancel` | Cancel a not-yet-submitted assignment |

`publishAt` in the future creates `SCHEDULED` assignments that stay invisible
until a background due-sweep promotes them to `PUBLISHED` and notifies the
recipient; a past or null `publishAt` publishes immediately. `ALL_PATIENTS`
fans out one assignment per active patient, resolved at publish time;
`SELECTED_PATIENTS` does the same for a chosen `patientIds` list (1–200,
deduplicated, all-or-nothing — any inactive/unknown id rejects the whole publish).

Optional `dueAt` (ISO datetime, must be after the publish time) makes the form
expire: once it passes the form drops out of `/my` and submitting it → **410**
`FORM_EXPIRED`.

A patient may hold only one *outstanding* (not-yet-submitted) copy of a given
form at a time. Re-publishing the same form to a patient who still has an open
copy is a **409** `FORM_DUPLICATE_OPEN_ASSIGNMENT` for the single-patient
targets, and is silently skipped (reported as `skipped` in the response) for the
`ALL_PATIENTS`/`SELECTED_PATIENTS` fan-outs. Re-publishing is allowed once the
prior copy is submitted or cancelled. The publish response is
`{ assignmentsCreated, assignmentIds, skipped }`.

**Filling & submitting** (`/form-assignments`, Patient + Volunteer):

| Method | Path | Roles | Purpose |
|---|---|---|---|
| `GET` | `/form-assignments/my` | Patient, Volunteer | My visible assigned forms |
| `GET` | `/form-assignments/:id` | Patient (owner), Volunteer (assignee), Doctor, Admin | Assignment + form structure to render (fillers get scores stripped) |
| `POST` | `/form-assignments/:id/submit` | Patient (owner), Volunteer (assignee) | Submit answers; returns confirmation only |

**Doctor review & assessment** (`/assessments`):

| Method | Path | Roles | Purpose |
|---|---|---|---|
| `GET` | `/assessments/submissions/pending` | Doctor, Admin | Submissions awaiting review |
| `GET` | `/assessments/submissions/:id` | Doctor, Admin | Submission detail (answers + computed score/interpretation) |
| `POST` | `/assessments` | **Doctor only** | Create official assessment (from a submission or direct); flips the assignment to `REVIEWED` |
| `GET` | `/assessments/patient/:patientId` | Doctor, Admin | List a patient's official assessments |
| `GET` | `/assessments/:id` | Doctor, Admin | Official assessment detail |

### Scoring and interpretation

Scoring is server-side and ignores any client-supplied score. Question types
and their contribution to the total:

- **SINGLE_SELECT** — the score of the one selected choice.
- **MULTI_SELECT** — the **sum** of all selected choices' scores (no upper
  limit; at least one when required).
- **SCALE** — the chosen numeric value directly (author defines integer
  `scaleMin < scaleMax` and `scaleStep > 0`; values must be in range and
  step-aligned).

The form total is the sum of all question scores. Questions may be grouped
into **subscales** (e.g. HADS anxiety `A` and depression `D`); each subscale
total is computed independently. **Score ranges** map a total to an
interpretation label (e.g. Normal/Mild/Moderate/Severe/Critical). When ranges
are defined they must cover every achievable total with no gaps and no
overlaps, validated at authoring time.

When a submission lands in the **top band of a multi-band group**, the server
emits a high-risk doctor alert (`HIGH_RISK` notification +
`HIGH_RISK_ALERT_CREATED` audit) at submission time. A single-band group is a
catch-all and never escalates.

**Manual** forms (`scoringType: "MANUAL"`, `interpretationMode: "MANUAL"`)
store the answers with no automatic total, subscale totals, or interpretation;
the reviewing doctor assigns the score and severity during review.

In all cases the filler receives a confirmation (`submissionId`, `status`,
`submittedAt`) only — the computed score and interpretation are doctor-only.

### Versioning and lifecycle

Published form versions are immutable. Editing a DRAFT version updates it in
place; editing a PUBLISHED version clones the structure into version N+1 and
repoints `currentVersion`, so in-flight assignments and past submissions stay
pinned to the exact version they were answered against. The template `key` is
immutable once created. Forms and assignments use status transitions
(`isActive`, and assignment `SCHEDULED`/`PUBLISHED`/`SUBMITTED`/`REVIEWED`/
`CANCELLED`) rather than delete endpoints; deactivated forms cannot be
published or sent out, but their past submissions remain readable.

### Seeded default forms

After applying Prisma migrations, seed the default form catalog idempotently:

```bash
npm run seed:forms
```

The seed inserts seven recognized clinical instruments (idempotent
upsert-by-`key`). Five are automatically scored with interpretation ranges and
two ship as manual-review forms:

| Key | Name | Scoring | Notes |
|---|---|---|---|
| `PHQ9` | Patient Health Questionnaire-9 | Scored (RANGE) | 9 SINGLE_SELECT, bands 0–4/5–9/10–14/15–19/20–27 |
| `PHQ4` | Patient Health Questionnaire-4 | Scored (RANGE) | 4 SINGLE_SELECT, bands 0–2/3–5/6–8/9–12 |
| `DT` | Distress Thermometer | Scored (RANGE) | Single SCALE 0–10, bands 0–3/4–6/7–10 |
| `HADS` | Hospital Anxiety and Depression Scale | Scored (RANGE) | 14 SINGLE_SELECT split into subscales `A` and `D`, each 0–7/8–10/11–21 |
| `PTSD` | PTSD Checklist | Scored (RANGE) | 20 SINGLE_SELECT, bands 0–10/11–30/31–50/51–80 |
| `QOL` | Quality of Life | **Manual** | Manual interpretation; no automatic total |
| `MACS` | Mental Adjustment to Cancer Scale | **Manual** | Manual interpretation; no automatic total |

### Errors

Form-specific errors retain the standard error envelope and status contract:

| Status | Form error codes | Meaning |
|---|---|---|
| `400` | `FORM_KEY_INVALID`, `FORM_QUESTION_NO_CHOICES`, `FORM_CHOICE_MISSING_SCORE`, `FORM_SCALE_INVALID_RANGE`, `FORM_SCALE_HAS_CHOICES`, `FORM_SCALE_OUT_OF_RANGE`, `FORM_RANGES_INVALID`, `FORM_RANGES_OVERLAP`, `FORM_RANGES_GAP`, `FORM_VERSION_EMPTY`, `FORM_ANSWER_SHAPE_INVALID`, `FORM_DUPLICATE_QUESTION_ANSWER`, `FORM_DUPLICATE_CHOICE`, `FORM_INVALID_CHOICE`, `FORM_INVALID_CHOICE_COUNT`, `FORM_INVALID_QUESTION`, `FORM_INVALID_VOLUNTEER`, `FORM_MISSING_REQUIRED_ANSWER` | Request or scoring validation failed |
| `401` | `UNAUTHORIZED` | Missing or invalid access token |
| `403` | `FORBIDDEN` | Authenticated role cannot perform the operation |
| `404` | `NOT_FOUND` | Form, assignment, or accessible target is not visible/found |
| `409` | `FORM_KEY_EXISTS`, `FORM_KEY_IMMUTABLE`, `FORM_VERSION_CONFLICT`, `FORM_VERSION_NOT_DRAFT`, `FORM_NOT_PUBLISHABLE`, `FORM_ALREADY_SUBMITTED`, `FORM_ASSIGNMENT_FINALIZED` | Lifecycle or concurrent-operation conflict |

`FORM_RANGES_INVALID` is raised when a score range's `minScore` exceeds its
`maxScore`. The full as-built endpoint, request/response, and error reference
lives in
[`specs/004-dynamic-assessment-forms/contracts/forms-api.md`](../specs/004-dynamic-assessment-forms/contracts/forms-api.md).

## Patient services & activities

The clinic offers patients structured **services** — educational courses,
recreational trips, and psychological-support groups. Staff (Admin/Doctor)
author **categories** and **services** with a seat capacity; patients browse,
filter, and search the available services and **request to join** one; staff
review the incoming requests and **accept or reject** them from a dashboard. A
seat is consumed only when a request is accepted, and the seat check + increment
run in a single transaction so concurrent acceptances can never oversubscribe a
service. Accepting records enrollment only — it never schedules an appointment.

The feature spans three routers, all mounted under `/api/v1`:

- `services/` categories — `/service-categories` (Admin/Doctor author; everyone lists)
- `services/` services — `/services` (Admin/Doctor author; patients browse `ACTIVE`; patients request to join)
- `services/` requests — `/service-requests` (patient tracks own; Admin/Doctor review/decide)

### Roles and access

| Capability | Admin | Doctor | Patient | Volunteer | Call Center |
|---|:---:|:---:|:---:|:---:|:---:|
| List categories / browse services | ✅ | ✅ | ✅ (ACTIVE) | ✅ | ✅ |
| Create/update/deactivate category | ✅ | ✅ | ❌ | ❌ | ❌ |
| Create/update/close service | ✅ | ✅ | ❌ | ❌ | ❌ |
| Request to join / track own / cancel pending | ❌ | ❌ | ✅ | ❌ | ❌ |
| Review queue / summary / accept / reject | ✅ | ✅ | ❌ | ❌ | ❌ |

### Default categories

```bash
npm run seed:services
```

Seeds default categories (idempotent on case-insensitive `name`) covering the
`EDUCATIONAL`, `TRIP`, and `SUPPORT` kinds plus a starter set, so services can be
created on a fresh database.

### Errors

Service-specific errors keep the standard error envelope and status contract:

| Status | Service error codes | Meaning |
|---|---|---|
| `400` | `SERVICE_CAPACITY_INVALID`, `TRIP_FIELDS_REQUIRED`, `SERVICE_CAPACITY_BELOW_TAKEN`, `VALIDATION_ERROR` | Request validation failed (non-positive capacity, missing trip fields, capacity below accepted count) |
| `403` | `FORBIDDEN` | Authenticated role cannot perform the operation (or not the request owner) |
| `404` | `NOT_FOUND` | Service, category, or request not visible/found |
| `409` | `CATEGORY_NAME_TAKEN`, `DUPLICATE_SERVICE_REQUEST`, `SERVICE_FULL`, `SERVICE_NOT_ACCEPTING`, `REQUEST_ALREADY_DECIDED`, `REQUEST_NOT_PENDING` | Lifecycle or concurrent-operation conflict |

The full as-built endpoint, request/response, and error reference lives in
[`specs/006-patient-services-activities/contracts/services-api.md`](../specs/006-patient-services-activities/contracts/services-api.md).

## Notifications

Notifications are stored in MongoDB and exposed as a recipient-facing inbox.
Users can list notifications addressed to them, staff can atomically claim
unclaimed role-broadcast alerts, and owners can mark notifications read or done.
Doctors can raise a `BOOKING_REQUIRED` notification to the Call Center for an
existing patient without creating an internal appointment.

Every notification create also attempts a best-effort FCM push after the MongoDB
write. Push delivery never blocks the triggering request. The visible push uses
category localization keys and a data payload containing only `notificationId`
and `type`; full notification content is fetched from the API. If FCM is
disabled, credentials are missing, or a send fails, the notification remains
available through `/notifications/my`.

Device tokens are registered through authenticated endpoints and stored in
PostgreSQL as `DeviceToken` rows. Re-registering the same token rebinds it to
the latest caller and refreshes `lastSeenAt`; unregistering is scoped to the
caller.

## Tests

```bash
npm run build
npm run lint
npm test -- --runInBand
npm test -- --runInBand --runTestsByPath tests/integration/forms-workflow.test.ts
npx jest --testPathPatterns=validators --runInBand
```

Integration tests live in `tests/integration/` and exercise the API against a
real PostgreSQL + MongoDB pair. For an end-to-end happy path that mirrors
manual QA, run `tests/integration/forms-workflow.test.ts` against seeded local
stores and follow `../specs/004-dynamic-assessment-forms/quickstart.md`.

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

The full collection at
`../docs/postman/bahya-backend-api.postman_collection.json` includes a
`Notifications` folder with requests for `/notifications/my`, claim, read,
done, doctor booking requests, and device token registration/removal.

### Forms workflow variables

Testing the dynamic assessment workflow requires changing roles between
doctor, patient, and optionally volunteer requests. Add these variables to
the same Postman environment:

| Variable | Set from |
|---|---|
| `doctorToken` | Doctor `POST /auth/login` response |
| `patientToken` | Patient `POST /auth/login` response |
| `volunteerToken` | Volunteer `POST /auth/login` response, when testing delegated filling |
| `patientId` | `GET /patients/options` response (`data[].id`) |
| `volunteerId` | `GET /volunteers` response (`data[].id`) |
| `formId` | `POST /forms` or `GET /forms` response |
| `assignmentId` | `POST /forms/:id/publish` response |
| `submissionId` | `POST /form-assignments/:id/submit` response |
| `assessmentId` | `POST /assessments` response |

When logging in as each role, save its token with the following Tests script,
changing the variable name for the role:

```javascript
const body = pm.response.json();
pm.environment.set("doctorToken", body.accessToken);
```

For the forms requests below, set the Authorization header to the matching
role token, for example `Bearer {{doctorToken}}` or
`Bearer {{patientToken}}`. Response-saving snippets are included at the
endpoint where an id is first produced.

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
these fields, including the optional clinical record and the unique `crn`
(file number). See [role-based visibility](#patient-field-visibility-by-role)
for what each role receives — volunteers get basic identity/contact info only.

```json
{
  "id": "f2a8b6c4-1d3e-4a5b-9c8d-7e6f5a4b3c2d",
  "userId": "9c8d7e6f-5a4b-3c2d-1e0f-9a8b7c6d5e4f",
  "crn": "PT-2504",
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
  "medicalHistory": {
    "allergies": ["penicillin"], "conditions": [],
    "comorbidities": ["Diabetes", "Hypertension"],
    "drugs": ["Tamoxifen 20mg daily", "Calcium + Vitamin D"],
    "familyHistory": "Yes - breast cancer", "notes": null
  },
  "socialStatus":   { "maritalStatus": "single", "familySupport": "moderate", "notes": null },
  "financials":     { "incomeBracket": "low", "notes": null },
  "bmi": 27.4,
  "menopausalStatus": "POST_MENOPAUSAL",
  "dateOfDiagnosis": "2024-11-10T00:00:00.000Z",
  "stageAtDiagnosis": "STAGE_II",
  "diseaseStatus": "ACTIVE_TREATMENT",
  "tumorBiology": "LUMINAL_A",
  "surgery": "BREAST_CONSERVATIVE",
  "chemotherapy": "ADJUVANT",
  "radiotherapy": true,
  "hormonalTherapy": true,
  "targetedTherapy": true,
  "immunotherapy": true,
  "createdAt": "2026-05-06T10:00:00.000Z",
  "updatedAt": "2026-05-06T10:00:00.000Z"
}
```

JSONB blocks have strict shapes — unknown keys are rejected with
`400 VALIDATION_ERROR`:

| Block | Allowed keys |
|---|---|
| `medicalHistory` | `allergies` (string[]), `conditions` (string[]), `comorbidities` (string[]), `drugs` (string[]), `familyHistory` (string), `notes` (string) |
| `socialStatus` | `maritalStatus` (string), `familySupport` (string), `notes` (string) |
| `financials` | `incomeBracket` (string), `notes` (string) |

Each leaf inside a block can be set to `null` on PATCH to delete that key
from the stored block. PATCH shallow-merges blocks; it does not replace them
wholesale.

#### Clinical fields

These are typed columns (queryable/filterable), distinct from the free-text
JSONB blocks. All are optional.

| Field | Type | Values |
|---|---|---|
| `crn` | string (unique) | File number, e.g. `PT-2504`. Matches `^[A-Za-z0-9-]{1,32}$`. **Required on create.** |
| `bmi` | number | 5–100 |
| `menopausalStatus` | enum | `PRE_MENOPAUSAL`, `PERI_MENOPAUSAL`, `POST_MENOPAUSAL` |
| `dateOfDiagnosis` | string | ISO datetime or `YYYY-MM-DD`; not in the future |
| `stageAtDiagnosis` | enum | `STAGE_0`, `STAGE_I`, `STAGE_II`, `STAGE_III`, `STAGE_IV` |
| `diseaseStatus` | enum | `NEWLY_DIAGNOSED`, `ACTIVE_TREATMENT`, `FOLLOW_UP`, `RECURRENCE`, `METASTATIC` |
| `tumorBiology` | enum | `LUMINAL_A`, `LUMINAL_B`, `HER2_ENRICHED`, `TNBC` |
| `surgery` | enum | `NONE`, `BREAST_CONSERVATIVE`, `MASTECTOMY` |
| `chemotherapy` | enum | `NO`, `NEOADJUVANT`, `ADJUVANT`, `METASTATIC` |
| `radiotherapy` / `hormonalTherapy` / `targetedTherapy` / `immunotherapy` | boolean | — |

#### Patient field visibility by role

`projectForRole` shapes every patient response by the caller's role:

| Field group | ADMIN | DOCTOR | CALL_CENTER | VOLUNTEER | PATIENT (own) |
|---|:---:|:---:|:---:|:---:|:---:|
| Identity/contact (`crn`, `fullName`, `email`, `phone`, `gender`, `dateOfBirth`, `address`, emergency contacts) | ✅ | ✅ | ✅ | ✅ | ✅ |
| `medicalHistory`, `socialStatus`, clinical fields | ✅ | ✅ | ✅ | ❌ | ✅ |
| `financials` | ✅ | ✅ | ✅ | ❌ | ✅ |
| `latestAssessments` (list only) | ✅ | ✅ | ❌ | ❌ | ❌ |

Stripped fields are removed from the response, not nulled.

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
| `crn` | string | yes | Unique file number, e.g. `PT-2504`. Matches `^[A-Za-z0-9-]{1,32}$` |
| `phone` | string | yes | Matches `^\+?[0-9]{8,15}$` |
| `dateOfBirth` | string | no | ISO datetime with offset, or `YYYY-MM-DD`. Must be in the past, within the last 130 years. |
| `gender` | enum | no | `MALE`, `FEMALE`, `OTHER` |
| `address` | string | no | Non-empty when present |
| `emergencyContactName` | string | no | Non-empty when present |
| `emergencyContactPhone` | string | no | Same phone format as `phone` |
| `medicalHistory` | object | no | See JSONB block table above |
| `socialStatus` | object | no | See JSONB block table above |
| `financials` | object | no | See JSONB block table above |
| clinical fields | mixed | no | `bmi`, `menopausalStatus`, `dateOfDiagnosis`, `stageAtDiagnosis`, `diseaseStatus`, `tumorBiology`, `surgery`, `chemotherapy`, `radiotherapy`, `hormonalTherapy`, `targetedTherapy`, `immunotherapy` — see [Clinical fields](#clinical-fields) |

The body is `.strict()` — unknown top-level keys produce `400 VALIDATION_ERROR`.

```json
{
  "fullName": "Sara Patient",
  "email": "sara@example.com",
  "password": "Welcome123!",
  "crn": "PT-2504",
  "phone": "+201001112222",
  "dateOfBirth": "1990-05-12",
  "gender": "FEMALE",
  "address": "12 Tahrir Square, Cairo",
  "emergencyContactName": "Ahmed Patient",
  "emergencyContactPhone": "+201003334444",
  "medicalHistory": {
    "allergies": ["penicillin"],
    "comorbidities": ["Diabetes", "Hypertension"],
    "drugs": ["Tamoxifen 20mg daily"],
    "familyHistory": "Yes - breast cancer"
  },
  "bmi": 27.4,
  "menopausalStatus": "POST_MENOPAUSAL",
  "dateOfDiagnosis": "2024-11-10",
  "stageAtDiagnosis": "STAGE_II",
  "diseaseStatus": "ACTIVE_TREATMENT",
  "tumorBiology": "LUMINAL_A",
  "surgery": "BREAST_CONSERVATIVE",
  "chemotherapy": "ADJUVANT",
  "radiotherapy": true,
  "hormonalTherapy": true,
  "targetedTherapy": true,
  "immunotherapy": true
}
```

**Response 201** — the [common patient response shape](#common-patient-response-shape).

**Errors**

- `400 VALIDATION_ERROR` — invalid body
- `403 FORBIDDEN` — caller is not ADMIN or CALL_CENTER
- `409 CONFLICT` — `Email already registered` or `CRN already in use`

#### `GET /patients`

Paginated list of patients with optional search.

**Auth:** Bearer token. **Roles:** ADMIN, DOCTOR, CALL_CENTER, VOLUNTEER.

**Query parameters**

| Param | Type | Default | Notes |
|---|---|---|---|
| `q` | string | — | Case-insensitive substring match on `fullName`, `email`, or `crn` |
| `phone` | string | — | Exact match; same phone format as create |
| `surgery` | enum | — | Filter by surgery type |
| `chemotherapy` | enum | — | Filter by chemotherapy type |
| `tumorBiology` | enum | — | Filter by tumor biology |
| `diseaseStatus` | enum | — | Filter by current disease status |
| `radiotherapy` | bool | — | `true` / `false` |
| `hormonalTherapy` | bool | — | `true` / `false` |
| `targetedTherapy` | bool | — | `true` / `false` |
| `immunotherapy` | bool | — | `true` / `false` |
| `page` | int | `1` | 1-indexed |
| `pageSize` | int | `20` | Max `100` |

The query is `.strict()` — unknown query parameters produce `400 VALIDATION_ERROR`.
The clinical enum/boolean filters use the [Clinical fields](#clinical-fields) value
sets. **Volunteers cannot use the clinical filters** — they are silently ignored
for `VOLUNTEER` callers so the result set can't leak clinical data they don't see.

Example: `GET /patients?q=sara&diseaseStatus=ACTIVE_TREATMENT&tumorBiology=LUMINAL_A`

**Response 200**

```json
{
  "data": [
    {
      "id": "...",
      "fullName": "Sara Patient",
      "...": "...",
      "latestAssessments": [
        { "templateKey": "PHQ9", "score": 12, "status": "MODERATE", "createdAt": "2026-05-20T09:00:00.000Z" },
        { "templateKey": "PHQ4", "score": 3,  "status": "MILD",     "createdAt": "2026-05-18T09:00:00.000Z" }
      ]
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 1
}
```

Each item carries `latestAssessments` — the most recent official assessment
per `templateKey` for that patient (newest first within each key), computed in
one query for the whole page. Clients render per-instrument scores (e.g.
`PHQ9`, `PHQ4`) and use `status` as the diagnosis/severity label; an empty
array means the patient has no official assessments yet.

`latestAssessments` is clinical data: it is present only for `DOCTOR` and
`ADMIN` callers and is stripped for `CALL_CENTER` and `VOLUNTEER`. For
`VOLUNTEER` callers, every item in `data` is reduced to basic identity/contact
info — `financials`, `socialStatus`, `medicalHistory`, and all clinical fields
are removed (see [visibility by role](#patient-field-visibility-by-role)).

**Errors**

- `400 VALIDATION_ERROR` — bad query parameters
- `403 FORBIDDEN` — caller's role is not in the allow-list

#### `GET /patients/options`

Minimal active-patient lookup for assigning a form without loading clinical
or demographic patient data.

**Auth:** Bearer token. **Roles:** ADMIN, DOCTOR.

**Query parameters**

| Param | Type | Default | Notes |
|---|---|---|---|
| `q` | string | — | Optional case-insensitive substring match on `fullName` |
| `page` | int | `1` | 1-indexed |
| `pageSize` | int | `20` | Max `100` |

```http
GET {{baseUrl}}/patients/options?q=sara&page=1&pageSize=20
Authorization: Bearer {{doctorToken}}
```

**Response 200**

```json
{
  "data": [
    {
      "id": "patient-uuid",
      "fullName": "Sara Patient"
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 1
}
```

The response returns active patient records only.

**Errors**

- `400 VALIDATION_ERROR` — bad query parameters
- `403 FORBIDDEN` — caller is not DOCTOR or ADMIN

#### `GET /patients/:id`

Fetches a single patient by patient id.

**Auth:** Bearer token. **Roles:** ADMIN, DOCTOR, CALL_CENTER, VOLUNTEER, PATIENT.

A `PATIENT` caller may only fetch their own patient record (the one whose
`userId` matches their token's `sub`); any other id returns `403 FORBIDDEN`.

**Response 200** — the [common patient response shape](#common-patient-response-shape), shaped by [role visibility](#patient-field-visibility-by-role) (volunteers receive basic identity/contact info only).

**Errors**

- `400 VALIDATION_ERROR` — `id` is not a UUID
- `403 FORBIDDEN` — caller's role is not allowed, or `PATIENT` requested someone else's record
- `404 NOT_FOUND` — no patient with that id

#### `PATCH /patients/:id`

Updates demographic and clinical fields and shallow-merges JSONB blocks.
Fields omitted from the body are left untouched. Setting a scalar field to
`null` clears it (where the schema allows it). Setting a JSONB sub-key to
`null` removes that sub-key from the stored block.

**Auth:** Bearer token. **Roles:** ADMIN, CALL_CENTER (full record); DOCTOR
(clinical fields only).

A `DOCTOR` may edit only clinical fields and `medicalHistory` — the set
`bmi`, `menopausalStatus`, `dateOfDiagnosis`, `stageAtDiagnosis`,
`diseaseStatus`, `tumorBiology`, `surgery`, `chemotherapy`, `radiotherapy`,
`hormonalTherapy`, `targetedTherapy`, `immunotherapy`, `medicalHistory`. A
doctor PATCH containing **any** other field (e.g. `crn`, `phone`, `address`,
`socialStatus`, `financials`) is rejected wholesale with `403 FORBIDDEN` and
nothing is applied.

**Request body** — all fields are optional; the body is `.strict()`.

| Field | Type | Nullable? | Notes |
|---|---|---|---|
| `crn` | string | no | Unique file number; ADMIN/CALL_CENTER only |
| `phone` | string | no | Phone format |
| `dateOfBirth` | string | yes | ISO datetime or `YYYY-MM-DD`, past, within 130 years |
| `gender` | enum | yes | `MALE`, `FEMALE`, `OTHER` |
| `address` | string | yes | Non-empty when not null |
| `emergencyContactName` | string | yes | Non-empty when not null |
| `emergencyContactPhone` | string | yes | Phone format |
| `medicalHistory` | object | no | Shallow-merged into stored block |
| `socialStatus` | object | no | Shallow-merged into stored block |
| `financials` | object | no | Shallow-merged into stored block |
| clinical fields | mixed | yes | All [Clinical fields](#clinical-fields) except `crn`; nullable to clear |

```json
{
  "diseaseStatus": "RECURRENCE",
  "surgery": "MASTECTOMY",
  "medicalHistory": {
    "drugs": ["Letrozole 2.5mg daily"],
    "notes": null
  }
}
```

**Response 200** — the updated patient in the [common patient response shape](#common-patient-response-shape), shaped by [role visibility](#patient-field-visibility-by-role) (volunteers cannot reach this endpoint).

**Errors**

- `400 VALIDATION_ERROR` — invalid body or unknown field
- `403 FORBIDDEN` — caller is not ADMIN/CALL_CENTER/DOCTOR, or a DOCTOR included non-clinical fields
- `404 NOT_FOUND` — no patient with that id
- `409 CONFLICT` — `CRN already in use`

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

### Volunteer Options

This minimal lookup supports assigning a form to a volunteer without giving
doctors access to admin user management. All `/volunteers` endpoints require
an authenticated `DOCTOR` or `ADMIN` token and return active volunteers only.

#### `GET /volunteers`

Search active volunteers for the `VOLUNTEER_FOR_PATIENT` publishing target.

**Auth:** Bearer token. **Roles:** DOCTOR, ADMIN.

**Query parameters**

| Param | Type | Default | Notes |
|---|---|---|---|
| `q` | string | — | Optional case-insensitive substring match on `fullName` |
| `page` | int | `1` | 1-indexed |
| `pageSize` | int | `20` | Max `100` |

```http
GET {{baseUrl}}/volunteers?q=amira&page=1&pageSize=20
Authorization: Bearer {{doctorToken}}
```

**Response 200**

```json
{
  "data": [
    {
      "id": "volunteer-user-uuid",
      "fullName": "Amira Hassan"
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 1
}
```

The response intentionally excludes email, status controls, and other admin
user fields.

**Errors**

- `400 VALIDATION_ERROR` — bad query parameters
- `403 FORBIDDEN` — caller is not DOCTOR or ADMIN

---

### Forms

Forms are versioned questionnaires authored by staff and later published as
assignments. All routes in this section require a bearer token.

**Auth:** Bearer token. **Roles:** DOCTOR, ADMIN.
**Rate limit:** 120 requests/minute/user; `POST /forms/:id/publish` has a
separate 10 requests/minute/user limit.

#### `GET /forms`

Lists form templates, including seeded templates after `npm run seed:forms`.
Use this endpoint to choose a default form for publishing or populate a form
library screen.

**Query parameters**

| Param | Type | Default | Notes |
|---|---|---|---|
| `q` | string | - | Search key, name, or description |
| `isActive` | string | - | `true` or `false` |
| `isDefault` | string | - | `true` or `false` |
| `category` | string | - | Category filter |
| `page` | int | `1` | 1-indexed |
| `pageSize` | int | `20` | Max `100` |

**Example request**

```http
GET {{baseUrl}}/forms?isDefault=true&pageSize=20
Authorization: Bearer {{doctorToken}}
```

**Response 200**

```json
{
  "data": [
    {
      "id": "form-uuid",
      "key": "PHQ9",
      "name": "Patient Health Questionnaire-9",
      "isDefault": true,
      "isActive": true,
      "scoringType": "SUM",
      "interpretationMode": "RANGE",
      "currentVersion": {
        "id": "version-uuid",
        "version": 1,
        "status": "PUBLISHED"
      }
    }
  ],
  "total": 7,
  "page": 1,
  "pageSize": 20
}
```

To publish the first result while testing, add this Tests script:

```javascript
const form = pm.response.json().data[0];
pm.environment.set("formId", form.id);
```

**Errors**

- `400 VALIDATION_ERROR` - invalid or unknown query parameter.
- `403 FORBIDDEN` - patient or volunteer attempted staff form access.

#### `POST /forms`

Creates a custom template with a version 1 `DRAFT`. A draft cannot be
assigned until promoted with `POST /forms/:id/publish-version`.

`key` is optional. When omitted (or sent empty), the server derives a stable
unique key from `name` — ASCII alphanumerics uppercased plus a random suffix
(e.g. `FRONTEND_DISTRESS_CHECK_3F9A1C22`). Non-Latin names (e.g. Arabic) that
slugify to nothing fall back to `FORM_<random>`. This lets the authoring UI
submit a title without asking the author to invent a key. On `PUT /forms/:id`,
`key` is still required and immutable.

**Request body**

```json
{
  "key": "DISTRESS_CHECK_DEMO",
  "name": "Frontend Distress Check",
  "description": "Created while testing the form editor",
  "category": "Distress",
  "scoringType": "SUM",
  "interpretationMode": "RANGE",
  "questions": [
    {
      "order": 1,
      "text": "How distressed are you today?",
      "type": "SCALE",
      "required": true,
      "scaleMin": 0,
      "scaleMax": 10,
      "scaleStep": 1
    },
    {
      "order": 2,
      "text": "Which symptoms apply?",
      "type": "MULTI_SELECT",
      "required": true,
      "choices": [
        { "order": 1, "label": "Fatigue", "score": 1 },
        { "order": 2, "label": "Insomnia", "score": 2 }
      ]
    }
  ],
  "scoreRanges": [
    { "label": "Low", "minScore": 1, "maxScore": 5 },
    { "label": "High", "minScore": 6, "maxScore": 13 }
  ]
}
```

**Response 201**

```json
{
  "id": "form-uuid",
  "key": "DISTRESS_CHECK_DEMO",
  "name": "Frontend Distress Check",
  "isActive": true,
  "currentVersion": {
    "id": "version-uuid",
    "version": 1,
    "status": "DRAFT",
    "questions": [
      {
        "id": "scale-question-uuid",
        "order": 1,
        "text": "How distressed are you today?",
        "type": "SCALE",
        "required": true,
        "scaleMin": 0,
        "scaleMax": 10,
        "scaleStep": 1,
        "choices": []
      }
    ],
    "scoreRanges": [
      { "id": "range-uuid", "label": "Low", "minScore": 1, "maxScore": 5 }
    ]
  }
}
```

Save the new template id in Postman:

```javascript
pm.environment.set("formId", pm.response.json().id);
```

**Errors**

- `400 VALIDATION_ERROR` - malformed form structure; validation issue messages
  may include `FORM_KEY_INVALID`, `FORM_QUESTION_NO_CHOICES`,
  `FORM_SCALE_INVALID_RANGE`, `FORM_RANGES_OVERLAP`, or `FORM_RANGES_GAP`.
- `409 FORM_KEY_EXISTS` - a template with this key already exists.

#### `GET /forms/:id`

Returns one template with its current version, including staff-visible
question choice scores and score ranges.

```http
GET {{baseUrl}}/forms/{{formId}}
Authorization: Bearer {{doctorToken}}
```

**Response 200:** the complete template shape returned from `POST /forms`.

**Errors:** `404 NOT_FOUND` if the form id does not exist.

#### `PUT /forms/:id`

Updates a form using the full `POST /forms` body shape. The `key` cannot
change. If the current version is a draft it is updated in place; if it is
published, a new published version is created and existing assignments remain
pinned to their earlier version.

```http
PUT {{baseUrl}}/forms/{{formId}}
Authorization: Bearer {{doctorToken}}
Content-Type: application/json
```

**Response 200:** complete updated template with `currentVersion`.

**Errors**

- `400 FORM_VERSION_EMPTY` - a published replacement has no questions.
- `409 FORM_KEY_IMMUTABLE` - request attempts to change `key`.
- `409 FORM_VERSION_CONFLICT` - concurrent version creation conflict.

#### `GET /forms/:id/versions`

Lists all saved versions for a form, newest first. Use this in the staff UI
for history display.

```http
GET {{baseUrl}}/forms/{{formId}}/versions
Authorization: Bearer {{doctorToken}}
```

**Response 200**

```json
[
  { "id": "version-2-uuid", "version": 2, "status": "PUBLISHED", "questions": [] },
  { "id": "version-1-uuid", "version": 1, "status": "PUBLISHED", "questions": [] }
]
```

#### `GET /forms/:id/versions/:version`

Gets a historical version with its questions, choices, and score ranges.

```http
GET {{baseUrl}}/forms/{{formId}}/versions/1
Authorization: Bearer {{doctorToken}}
```

**Errors:** `404 NOT_FOUND` if that version does not exist.

#### `POST /forms/:id/publish-version`

Moves the current initial draft to `PUBLISHED` so it can be assigned.

```http
POST {{baseUrl}}/forms/{{formId}}/publish-version
Authorization: Bearer {{doctorToken}}
```

**Request body:** none.

**Response 200:** complete template with `currentVersion.status` set to
`PUBLISHED`.

**Errors**

- `400 FORM_VERSION_EMPTY` - draft has no questions.
- `409 FORM_VERSION_NOT_DRAFT` - current version was already published.

#### `PATCH /forms/:id/status`

Activates or deactivates a template. Inactive templates cannot be newly
published, and scheduled assignments are not promoted while inactive.

```http
PATCH {{baseUrl}}/forms/{{formId}}/status
Authorization: Bearer {{doctorToken}}
Content-Type: application/json

{ "isActive": false }
```

**Response 200:** complete template with the new `isActive` value.

#### `POST /forms/:id/publish`

Creates assignments from a published active form. Select exactly one target
body below.

**Single patient**

Set `{{patientId}}` from `GET /patients/options`.

```json
{ "target": "SINGLE_PATIENT", "patientId": "{{patientId}}", "publishAt": null }
```

**All active patients**

```json
{ "target": "ALL_PATIENTS", "publishAt": null }
```

**A chosen subset of patients**

Set `{{patientId}}` values from `GET /patients/options`. `patientIds` accepts
1–200 UUIDs and is deduplicated. The publish is all-or-nothing: if any id is not
an active patient the request returns **404** `NOT_FOUND` and nothing is created.

```json
{ "target": "SELECTED_PATIENTS", "patientIds": ["{{patientId}}"], "publishAt": null }
```

**Volunteer filling for a patient**

Set `{{patientId}}` from `GET /patients/options` and `{{volunteerId}}` from
`GET /volunteers`; doctors do not need access to the admin-only `/users` API.

```json
{
  "target": "VOLUNTEER_FOR_PATIENT",
  "patientId": "{{patientId}}",
  "volunteerId": "{{volunteerId}}",
  "publishAt": null
}
```

For scheduled visibility, set `publishAt` to an ISO timestamp in the future,
for example `"2026-06-01T08:00:00.000Z"`. Add an optional `dueAt` (ISO timestamp,
must be after the publish time) to make the form expire — after it passes the
form is hidden and submitting it returns **410** `FORM_EXPIRED`:

```json
{ "target": "ALL_PATIENTS", "publishAt": null, "dueAt": "2026-06-15T08:00:00.000Z" }
```

```http
POST {{baseUrl}}/forms/{{formId}}/publish
Authorization: Bearer {{doctorToken}}
Content-Type: application/json
```

**Response 201**

```json
{
  "assignmentsCreated": 1,
  "assignmentIds": ["assignment-uuid"],
  "skipped": 0
}
```

Save the first assignment for the patient workflow:

```javascript
const body = pm.response.json();
pm.environment.set("assignmentId", body.assignmentIds[0]);
```

**Frontend notes**

- An immediate publication appears in the recipient's `/form-assignments/my`
  result and creates a notification.
- A future publication remains hidden until the scheduled sweep publishes it.
- `ALL_PATIENTS` may return `assignmentsCreated: 0` when there are no active
  patient users. `SELECTED_PATIENTS` always creates one assignment per listed
  id on success (it rejects rather than partially fanning out).
- A selected patient or volunteer must still be active when the publish
  request is processed.
- A patient who already has an outstanding (not-yet-submitted) copy of this form
  is skipped by the fan-out targets and counted in `skipped`; the single-patient
  targets reject with **409** `FORM_DUPLICATE_OPEN_ASSIGNMENT`. Re-publish once
  the prior copy is submitted or cancelled.

**Errors**

- `400 FORM_INVALID_VOLUNTEER` - supplied user is not an active volunteer.
- `404 NOT_FOUND` - supplied patient is inactive, or the patient or template cannot be found.
- `409 FORM_NOT_PUBLISHABLE` - form is inactive, not published, or empty.

#### `GET /forms/:id/assignments`

Lists assignments created for a template for staff monitoring screens.

```http
GET {{baseUrl}}/forms/{{formId}}/assignments?page=1&pageSize=20
Authorization: Bearer {{doctorToken}}
```

**Response 200**

```json
{
  "data": [
    {
      "id": "assignment-uuid",
      "target": "SINGLE_PATIENT",
      "status": "PUBLISHED",
      "publishAt": null,
      "patient": { "id": "patient-uuid", "userId": "patient-user-uuid" },
      "formVersion": { "id": "version-uuid", "version": 1 }
    }
  ],
  "total": 1,
  "page": 1,
  "pageSize": 20
}
```

---

### Form Assignments

Assignments are the patient or volunteer copy of a published form. The filling workflow never returns scoring data to the client.

**Auth:** `Bearer {{patientToken}}` or `Bearer {{volunteerToken}}` for filling; `Bearer {{doctorToken}}` for inspection or cancellation.

**Rate limit:** `120` requests per minute per user. Submission is limited to `20` requests per minute per user.

#### `GET /form-assignments/my`

Return the published assignments currently available to the signed-in patient or volunteer.

```http
GET {{baseUrl}}/form-assignments/my
Authorization: Bearer {{patientToken}}
```

```json
[
  {
    "id": "assignment-uuid",
    "target": "SINGLE_PATIENT",
    "status": "PUBLISHED",
    "publishAt": null,
    "template": {
      "id": "form-uuid",
      "key": "DISTRESS_CHECK_DEMO",
      "name": "Frontend Distress Check"
    }
  }
]
```

Patients see their own patient-targeted assignments. Volunteers only see assignments delegated to them. Scheduled, cancelled, submitted, and unauthorized assignments do not appear in this inbox.

#### `GET /form-assignments/:id`

Retrieve the exact frozen form version to render for the recipient.

```http
GET {{baseUrl}}/form-assignments/{{assignmentId}}
Authorization: Bearer {{patientToken}}
```

```json
{
  "id": "assignment-uuid",
  "status": "PUBLISHED",
  "template": {
    "key": "DISTRESS_CHECK_DEMO",
    "name": "Frontend Distress Check"
  },
  "formVersion": {
    "version": 1,
    "questions": [
      {
        "id": "question-uuid",
        "order": 1,
        "text": "How distressed are you today?",
        "type": "SCALE",
        "required": true,
        "scaleMin": 0,
        "scaleMax": 10,
        "scaleStep": 1,
        "choices": []
      },
      {
        "id": "multi-question-uuid",
        "order": 2,
        "text": "Which symptoms apply?",
        "type": "MULTI_SELECT",
        "required": true,
        "scaleMin": null,
        "scaleMax": null,
        "scaleStep": null,
        "choices": [
          {
            "id": "choice-sleep-uuid",
            "order": 2,
            "label": "Insomnia"
          }
        ]
      }
    ],
    "scoreRanges": []
  }
}
```

The filling response omits choice scores and returns no score ranges. Frontend screens must render questions and collect answers only; score and interpretation are server-side clinical data.

**Common errors:** `404 NOT_FOUND` for unavailable or unauthorized assignments, `409 FORM_ALREADY_SUBMITTED`.

#### `POST /form-assignments/:id/submit`

Submit one answer for every required question. Use `choiceIds` for `SINGLE_SELECT` or `MULTI_SELECT` questions and `value` for `SCALE` questions.

```http
POST {{baseUrl}}/form-assignments/{{assignmentId}}/submit
Authorization: Bearer {{patientToken}}
Content-Type: application/json

{
  "answers": [
    {
      "questionId": "scale-question-uuid",
      "value": 7
    },
    {
      "questionId": "multi-question-uuid",
      "choiceIds": ["choice-sleep-uuid"]
    }
  ]
}
```

```json
{
  "submissionId": "submission-uuid",
  "status": "SUBMITTED",
  "submittedAt": "2026-05-25T10:10:00.000Z"
}
```

Save the submission ID for the doctor workflow:

```javascript
pm.environment.set("submissionId", pm.response.json().submissionId);
```

Submission confirmation intentionally does not expose a calculated score or interpretation.

**Common errors:** `400 VALIDATION_ERROR` (including `FORM_ANSWER_SHAPE_INVALID` or `FORM_DUPLICATE_QUESTION_ANSWER` details), `400 FORM_INVALID_QUESTION`, `400 FORM_INVALID_CHOICE`, `400 FORM_INVALID_CHOICE_COUNT`, `400 FORM_DUPLICATE_CHOICE`, `400 FORM_SCALE_OUT_OF_RANGE`, `400 FORM_MISSING_REQUIRED_ANSWER`, `404 NOT_FOUND`, `409 FORM_ALREADY_SUBMITTED`.

#### `PATCH /form-assignments/:id/cancel`

Cancel a scheduled or published assignment before it is completed.

**Roles:** `DOCTOR`, `ADMIN`

```http
PATCH {{baseUrl}}/form-assignments/{{assignmentId}}/cancel
Authorization: Bearer {{doctorToken}}
```

```json
{
  "id": "assignment-uuid",
  "status": "CANCELLED"
}
```

**Common error:** `409 FORM_ASSIGNMENT_FINALIZED` when a submitted or reviewed assignment can no longer be cancelled.

---

### Assessments

Assessments are the official clinical record created after a doctor reviews a submitted form, or created directly when no form submission is needed.

**Auth:** `Bearer {{doctorToken}}` for official assessment review, creation, and reads.

Official assessments are clinical staff-only records. Patients must not read
official assessment scores, interpretations, severity labels, or doctor notes.

**Rate limit:** `120` requests per minute per user.

#### `GET /assessments/submissions/pending`

List form submissions awaiting clinical review.

**Roles:** `DOCTOR`, `ADMIN`

```http
GET {{baseUrl}}/assessments/submissions/pending
Authorization: Bearer {{doctorToken}}
```

```json
[
  {
    "id": "submission-uuid",
    "totalScore": 8,
    "interpretation": { "label": "High", "subscales": [] },
    "patient": { "id": "patient-uuid", "userId": "patient-user-uuid", "user": { "fullName": "Sara Ahmed" } },
    "submittedBy": { "id": "filler-user-uuid", "role": "VOLUNTEER", "fullName": "Omar Volunteer" },
    "assignment": {
      "id": "assignment-uuid",
      "template": {
        "key": "DISTRESS_CHECK_DEMO",
        "name": "Frontend Distress Check"
      }
    }
  }
]
```

This staff-only response may expose calculated scores and interpretation for review.

`patient.user.fullName` is the subject and `submittedBy.fullName` is whoever actually filled the
form. Use `submittedBy.role` to tell a volunteer-filled form (`VOLUNTEER`) from a patient
self-report (`PATIENT`) — e.g. render _"filled by Omar Volunteer (Volunteer) for Sara Ahmed"_.

#### `GET /assessments/submissions/:id`

Retrieve one submitted form with its answers and computed result for clinical review.

**Roles:** `DOCTOR`, `ADMIN`

```http
GET {{baseUrl}}/assessments/submissions/{{submissionId}}
Authorization: Bearer {{doctorToken}}
```

The detail response includes `patient.user.fullName` (the subject) and `submittedBy`
(`{ id, role, fullName }` — the actual filler), alongside the answers, computed score, and form
version. `submittedBy.role` distinguishes a volunteer-filled form from a patient self-report.

**Common error:** `404 NOT_FOUND`.

#### `POST /assessments`

Create the official assessment record. Only doctors can create assessments.

**Roles:** `DOCTOR`

For a scored form submission:

```http
POST {{baseUrl}}/assessments
Authorization: Bearer {{doctorToken}}
Content-Type: application/json

{
  "patientId": "{{patientId}}",
  "submissionId": "{{submissionId}}",
  "templateKey": "DISTRESS_CHECK_DEMO",
  "status": "MODERATE",
  "doctorNote": "Review coping plan at the next visit."
}
```

For forms with `SUM` scoring, the server uses the stored submitted score. For forms with `MANUAL` scoring, include a doctor-confirmed `"score"` value.

To create an assessment without a form submission:

```json
{
  "patientId": "{{patientId}}",
  "submissionId": null,
  "templateKey": "CLINICAL_INTERVIEW",
  "score": 6,
  "status": "MILD",
  "doctorNote": "Direct clinical assessment."
}
```

Allowed statuses are `NORMAL`, `MILD`, `MODERATE`, `SEVERE`, and `CRITICAL`.

```json
{
  "id": "assessment-uuid",
  "patientId": "patient-uuid",
  "templateKey": "DISTRESS_CHECK_DEMO",
  "score": 8,
  "status": "MODERATE",
  "doctorNote": "Review coping plan at the next visit."
}
```

```javascript
pm.environment.set("assessmentId", pm.response.json().id);
```

Creating an assessment linked to a submission changes its assignment status to `REVIEWED`.

**Common errors:** `400 VALIDATION_ERROR`, `400 ASSESSMENT_SUBMISSION_MISMATCH`, `400 ASSESSMENT_SCORE_REQUIRED`, `403 FORBIDDEN`, `404 NOT_FOUND`, `409 ASSESSMENT_ALREADY_CREATED`.

#### `GET /assessments/patient/:patientId`

List official assessments for one patient.

**Roles:** `DOCTOR`, `ADMIN`.

```http
GET {{baseUrl}}/assessments/patient/{{patientId}}
Authorization: Bearer {{doctorToken}}
```

```json
[
  {
    "id": "assessment-uuid",
    "templateKey": "DISTRESS_CHECK_DEMO",
    "score": 8,
    "status": "MODERATE",
    "createdAt": "2026-05-25T10:20:00.000Z"
  }
]
```

#### `GET /assessments/:id`

Retrieve one official assessment.

**Roles:** `DOCTOR`, `ADMIN`.

```http
GET {{baseUrl}}/assessments/{{assessmentId}}
Authorization: Bearer {{doctorToken}}
```

**Common error:** `404 NOT_FOUND` for missing or inaccessible records.

---

### Dynamic Forms Quick Test Sequence

Use this order in Postman to test the frontend workflow:

1. Sign in as a doctor, save `doctorToken`, then call `POST /forms` and save `formId`.
2. Call `POST /forms/{{formId}}/publish-version` so an immutable version is ready to assign.
3. Call `POST /forms/{{formId}}/publish` for `{{patientId}}` and save `assignmentId`.
4. Sign in as that patient, save `patientToken`, then call `GET /form-assignments/{{assignmentId}}` to render the question IDs and choices.
5. Call `POST /form-assignments/{{assignmentId}}/submit` and save `submissionId`.
6. Switch back to `doctorToken` and call `GET /assessments/submissions/{{submissionId}}` to review server-computed results.
7. Call `POST /assessments` and save `assessmentId`.
8. Continue with `doctorToken` and call `GET /assessments/{{assessmentId}}` to inspect the official assessment record.

The filler-facing endpoints never return option scores, total score, or
computed interpretation. Official assessment records are available only to
doctors and admins, not to patients.

---

### Service Categories

Service classifications used to group and color services. Everyone authenticated
can list; only Admin and Doctor mutate. Base path `/api/v1/service-categories`.

| Method | Path | Access | Description |
|---|---|---|---|
| GET | `/service-categories` | Authenticated | List categories (filters: `kind`, `isActive`). Patients always see active categories only — `isActive` is honored for staff and ignored for the `PATIENT` role. |
| POST | `/service-categories` | Admin, Doctor | Create a category (`name`, `kind`, `iconKey`, `color`) |
| PATCH | `/service-categories/:id` | Admin, Doctor | Update name / kind / iconKey / color |
| PATCH | `/service-categories/:id/status` | Admin, Doctor | Activate / deactivate (`{ "isActive": false }`) |

A duplicate `name` (case-insensitive) returns `409 CATEGORY_NAME_TAKEN`. A
category referenced by services is deactivated, never deleted. Deactivated
categories disappear from the patient browse list (the server forces
`isActive=true` for patients); staff can still retrieve them with `isActive=false`
for authoring.

```bash
curl -X POST localhost:3000/api/v1/service-categories \
  -H "Authorization: Bearer $ADMIN" -H "Content-Type: application/json" \
  -d '{ "name": "خدمات تعليمية", "kind": "EDUCATIONAL", "iconKey": "school", "color": "#6CCB4F" }'
```

### Services

Joinable activities with a seat capacity. Admin/Doctor author; patients browse
`ACTIVE` services and request to join. Base path `/api/v1/services`.

| Method | Path | Access | Description |
|---|---|---|---|
| GET | `/services` | Authenticated | Browse. Patients see only `ACTIVE`; staff see all. Filters: `kind`, `categoryId`, `q`, `status` (staff), `page`, `pageSize` |
| GET | `/services/:id` | Authenticated | One service + `remainingSeats` (patient gets 404 for non-`ACTIVE`) |
| POST | `/services` | Admin, Doctor | Create a service |
| PATCH | `/services/:id` | Admin, Doctor | Update fields and/or close (`{ "status": "CLOSED" }`) |
| POST | `/services/:id/requests` | Patient | Request to join |

Create requires a positive `capacity`; trip-kind categories additionally require
`endDate`, `departureTime`, and `meetingPlace`. Lowering `capacity` below the
already-accepted count returns `400 SERVICE_CAPACITY_BELOW_TAKEN`. A new service
starts `ACTIVE` with `seatsTaken: 0`; each list row carries
`remainingSeats = capacity - seatsTaken`.

### Service Requests

Patient join requests (enrollment). Patients track and withdraw their own; staff
review the queue and decide. Base path `/api/v1/service-requests`.

| Method | Path | Access | Description |
|---|---|---|---|
| GET | `/service-requests/my` | Patient | The caller's own requests with status |
| GET | `/service-requests` | Admin, Doctor | Staff queue (filters: `status`, `serviceId`); includes patient name + CRN |
| GET | `/service-requests/summary` | Admin, Doctor | Counts: `{ pending, approvedToday, approvedTotal }` |
| PATCH | `/service-requests/:id/approve` | Admin, Doctor | Accept (consumes a seat, atomic) |
| PATCH | `/service-requests/:id/reject` | Admin, Doctor | Reject (optional `decisionNote`) |
| PATCH | `/service-requests/:id/cancel` | Patient (owner) | Withdraw own pending request |

Requesting a service the patient already has a `PENDING`/`APPROVED` request for
returns `409 DUPLICATE_SERVICE_REQUEST`; a full service returns `409
SERVICE_FULL`; a closed service returns `409 SERVICE_NOT_ACCEPTING`. Approving
re-checks capacity inside a transaction so concurrent acceptances never
oversubscribe, and emits a `SERVICE_REQUEST_DECIDED` notification to the patient;
a new request emits `SERVICE_REQUEST_SUBMITTED` to staff (Admin and Doctor).
Deciding an already-decided request returns `409 REQUEST_ALREADY_DECIDED`.

---

### Notifications

Recipient-facing notifications and push-device registration. Base path
`/api/v1/notifications`. Every route requires an authenticated bearer token.

| Method | Path | Access | Description |
|---|---|---|---|
| GET | `/notifications/my` | Authenticated | List personal notifications plus unclaimed role-broadcast notifications for the caller's role |
| PATCH | `/notifications/:id/claim` | Recipient role | Atomically claim an unclaimed role-broadcast notification |
| PATCH | `/notifications/:id/read` | Owning recipient | Mark an owned notification read |
| PATCH | `/notifications/:id/done` | Owning recipient | Mark an owned notification done |
| POST | `/notifications/request-booking` | Doctor | Create a `BOOKING_REQUIRED` notification for Call Center |
| POST | `/notifications/devices` | Authenticated | Register or refresh the caller's FCM device token |
| DELETE | `/notifications/devices` | Authenticated | Unregister the caller's FCM device token |

`GET /notifications/my` supports `status`, `severity`, `page`, and `pageSize`
query parameters. Results are newest-first. Patient-related notifications
include live patient contact fields when available; if the patient cannot be
read, the `patient` field is `null` instead of failing the whole list.

```http
GET /api/v1/notifications/my?status=UNREAD&page=1&pageSize=20
Authorization: Bearer {{accessToken}}
```

Claim/read/done are forward-only lifecycle actions. Claim uses a single atomic
MongoDB update, so concurrent claimers get exactly one winner; the loser gets
`409 CLAIM_CONFLICT`. Read requires `UNREAD`; done accepts `UNREAD` or `READ`.

```http
PATCH /api/v1/notifications/{{notificationId}}/claim
Authorization: Bearer {{callCenterToken}}
```

```http
PATCH /api/v1/notifications/{{notificationId}}/read
Authorization: Bearer {{callCenterToken}}
```

```http
PATCH /api/v1/notifications/{{notificationId}}/done
Authorization: Bearer {{callCenterToken}}
```

Doctors can request Call Center booking follow-up for an existing patient. This
records intent only; it does not create an appointment or schedule.

```http
POST /api/v1/notifications/request-booking
Authorization: Bearer {{doctorToken}}
Content-Type: application/json

{
  "patientId": "{{patientId}}",
  "doctorNote": "Needs urgent follow-up"
}
```

Device registration is scoped to the signed-in user. Register is an upsert by
token and supports `ANDROID`, `IOS`, or `WEB`.

```http
POST /api/v1/notifications/devices
Authorization: Bearer {{accessToken}}
Content-Type: application/json

{ "token": "{{deviceToken}}", "platform": "ANDROID" }
```

```http
DELETE /api/v1/notifications/devices
Authorization: Bearer {{accessToken}}
Content-Type: application/json

{ "token": "{{deviceToken}}" }
```

Push delivery is best-effort. Missing or invalid Firebase credentials, disabled
FCM, no registered device tokens, and FCM send failures do not change the API
response for the action that created the notification. Invalid or unregistered
tokens reported by FCM are pruned automatically.

**Common errors:** `400 VALIDATION_ERROR`, `403 FORBIDDEN` or `NOT_RECIPIENT`,
`404 NOT_FOUND`, `409 CLAIM_CONFLICT`, `409 ILLEGAL_TRANSITION`.

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
