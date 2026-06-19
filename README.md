# Bahya Website 

![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?logo=nodedotjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/Language-TypeScript-3178C6?logo=typescript&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![Prisma](https://img.shields.io/badge/ORM-Prisma-2D3748?logo=prisma&logoColor=white)

This repository contains the full Bahya platform:

- `frontend/`: Flutter application (mobile, web, desktop targets)
- `backend/`: Node.js + Express + TypeScript + Prisma API (PostgreSQL)

## Table of Contents

- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Backend Notes](#backend-notes)
- [Frontend Notes](#frontend-notes)
- [Common Development Commands](#common-development-commands)
- [Environment and Secrets](#environment-and-secrets)
- [Contributing](#contributing)

## Project Structure

```text
bahya_website/
  frontend/   # Flutter app
  backend/    # API server and database layer
```

## Prerequisites

Install the following tools before running the project:

- Flutter SDK (with Dart)
- Node.js 20+
- npm
- PostgreSQL 15+

## Quick Start

> Run backend and frontend in separate terminals.

### 1) Clone and enter the repository

```bash
git clone <your-repo-url>
cd bahya_website
```

### 2) Run the backend

```bash
cd backend
npm install
cp .env.example .env
```

Update values in `.env` (especially database URL and secrets), then run:

```bash
npx prisma migrate dev --name init
npm run dev
```

By default, backend runs on:

- API: `http://localhost:3000`
- Health check: `GET /api/v1/health`

### 3) Run the frontend

Open a new terminal:

```bash
cd frontend
flutter pub get
flutter run
```

For web:

```bash
flutter run -d chrome
```

## Backend Notes

- Backend supports authentication, RBAC, patient records, dynamic assessment
  forms, services/activities, and recipient-facing notifications.
- Main auth endpoints are under `/api/v1/auth`; notification inbox, lifecycle,
  booking request, and device-token endpoints are under `/api/v1/notifications`.
- Mobile push through Firebase Cloud Messaging is optional and best-effort; the
  notification document in MongoDB remains the source of truth.
- Database schema is defined in `backend/prisma/schema.prisma`.

For backend-only details, see `backend/README.md`.

## Frontend Notes

- Flutter app with assets and custom Arabic font configuration.
- Targets Android, iOS, Web, Windows, macOS, and Linux.

For frontend-specific details, see `frontend/README.md`.

## Common Development Commands

### Backend (`backend/`)

- `npm run dev`: start development server
- `npm run build`: compile TypeScript
- `npm start`: run compiled server
- `npm run lint`: lint TypeScript files
- `npm run format`: format backend source

### Frontend (`frontend/`)

- `flutter pub get`: install Dart/Flutter dependencies
- `flutter run`: run app on connected device/emulator
- `flutter test`: run Flutter tests
- `flutter analyze`: run static analysis

## Environment and Secrets

- Never commit real secrets.
- Use `backend/.env.example` as the template for local setup.
- Keep local credentials only in `backend/.env` (already gitignored).

> [!IMPORTANT]
> If any secret is accidentally committed, rotate it immediately.

## Contributing

Please read `CONTRIBUTING.md` before opening a pull request.
