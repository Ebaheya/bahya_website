# Contributing to Bahya Website

Thanks for contributing. This guide applies to the full repository (`frontend` + `backend`).

## 1) Before You Start

- Make sure your local environment is working for the part you change.
- Keep your branch up to date with the main branch.
- Prefer small, focused pull requests.

## 2) Branch Naming

Create a new branch from `main`:

```bash
git checkout main
git pull
git checkout -b <type>/<short-description>
```

Examples:

- `feat/auth-refresh-ui`
- `fix/login-error-message`
- `chore/update-readme`

Recommended prefixes: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.

## 3) Development Setup

### Backend

```bash
cd backend
npm install
cp .env.example .env
npx prisma migrate dev --name init
npm run dev
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

## 4) Code Quality Checks

Run relevant checks before committing.

### Backend checks

```bash
cd backend
npm run lint
npm run build
```

### Frontend checks

```bash
cd frontend
flutter analyze
flutter test
```

## 5) Commit Messages

Use clear, imperative commit messages:

- `feat: add patient registration form validation`
- `fix: handle expired refresh token response`
- `docs: update monorepo setup instructions`

Tips:

- Keep subject concise.
- Explain *why* in the commit body when needed.
- Avoid mixing unrelated changes in one commit.

## 6) Pull Request Guidelines

Each PR should include:

- A clear summary of what changed and why
- Screenshots or short recordings for UI changes (frontend)
- API notes for endpoint changes (backend)
- Test notes (what you ran locally)

Checklist:

- [ ] Branch is up to date with `main`
- [ ] Lint/tests pass locally
- [ ] No secrets were committed
- [ ] Documentation updated if behavior changed

## 7) Security and Secrets

- Do not commit `.env` files or credentials.
- Rotate any key immediately if it was exposed.
- Report security concerns privately to maintainers.

## 8) Scope and Style

- Prefer minimal, targeted changes.
- Keep naming clear and consistent.
- Add comments only where logic is not obvious.
- Update docs for behavior or setup changes.
