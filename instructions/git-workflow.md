# Git Workflow & Branching

This project follows a simple, safe workflow that protects `dev` and `main` and keeps changes reviewable.

## Branching Rules
- Do NOT push directly to `dev` or `main`.
- Always create a branch from `dev` for any change.
- Allowed naming patterns:
  - `feature/<short-title-description>` for new functionality
  - `bugfix/<short-title-description>` for fixes
  - Optional (when useful): `docs/<short-title>`, `chore/<short-title>`, `hotfix/<short-title>`
- Use kebab-case for `<short-title-description>` (e.g., `feature/db-auth-jwt`).

## Standard Flow
1. Sync with remote `dev`:
   ```bash
   git checkout dev
   git pull origin dev
   ```
2. Create a branch:
   ```bash
   git checkout -b feature/db-auth-jwt
   ```
3. Commit work with a clear message (Conventional style recommended):
   ```bash
   git add -A
   git commit -m "feat(auth): add database-backed auth with JWT"
   ```
4. Push branch and create PR → `dev`:
   ```bash
   git push -u origin feature/db-auth-jwt
   # Open PR: base = dev, compare = feature/db-auth-jwt
   ```
5. After merge to `dev`, create a release PR from `dev` → `main`.
   - Compare link: `https://github.com/<owner>/<repo>/compare/main...dev?expand=1`

## Pull Request Requirements
- Title: concise and descriptive (e.g., `feat: database-backed auth`)
- Description must include:
  - Problem / context
  - What changed (bullet points)
  - How to test (commands/URLs)
  - Risk/impact assessment and migration notes
- Link related issues or tickets when available.

## Example PR Description
```
Summary
- Implement DB-backed authentication (Postgres + bcrypt + JWT)
- Improve login UX (404 for unregistered email, 401 for wrong password)
- Per-user avatar upload folders; serve via Nginx → Express
- Add structured logging to /home/logs/ndlelaSearchEngineLogs

Testing
- Register → 201; Login → 200 returns JWT; /api/auth/me returns user
- Avatar upload succeeds and persists across restarts

Risks
- Requires DB connectivity; ensure .env and Compose env variables are set
```

## Protection
- `main`: production only; merged from `dev` via PR
- `dev`: integration branch; merged via PRs from feature/bugfix branches

## Notes
- Keep changes small and focused; prefer multiple small PRs over one large PR.
- Always describe changes clearly so reviewers understand the scope quickly.
