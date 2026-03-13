# FarmOS Phase 4: Infrastructure Setup Guide (Shared Hosting)

**Version**: 1.0.0  
**Date**: March 13, 2026  
**Phase**: 4 (Infrastructure & DevOps)

---

## Scope

This guide covers deployment and operations without containerization, targeting standard PHP shared hosting (e.g., Afrihost) and conventional VM setups.

---

## Shared Hosting Deployment (Afrihost)

### 1. Web root and routing

- Set the document root to `begin_pyphp/backend/public/`.
- Ensure URL rewriting is enabled (Apache `mod_rewrite`). Use the project’s `.htaccess` under `public/` if present.

### 2. Environment configuration

- Create `begin_pyphp/backend/config/.env`.
- Set at minimum:
  - `APP_ENV`
  - `APP_URL`
  - `JWT_SECRET`
  - `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_NAME`, `DB_USER`, `DB_PASSWORD`, `DATABASE_URL`
  - `CORS_ORIGIN`
  - `LOG_LEVEL`, `LOG_FORMAT`, `LOG_DIR` (optional)

### 3. Database

- Create a MySQL database and user in the hosting panel.
- Import schema: `begin_pyphp/database/schema.sql`.

### 4. Dependencies

If Composer is available on the host:

```bash
cd begin_pyphp/backend
composer install --no-dev --optimize-autoloader
```

If Composer is not available on the host, install dependencies locally and upload the resulting `vendor/` directory with the backend.

---

## CI (GitHub Actions)

- Run tests, lint, and type-check on every push/PR.
- Use Composer scripts from `begin_pyphp/backend/composer.json`:
  - `composer run test`
  - `composer run lint`
  - `composer run type-check`
  - `composer run format`

---

## Monitoring & Logging

- Prefer JSON logs in production.
- Ensure a writable log directory if using file logs (configure `LOG_DIR`).
- Track request correlation via `X-Request-Id` in responses.

---

## Backups

- Schedule daily database exports via the hosting panel cron feature.
- Keep at least 14–30 days of backups.
- Periodically perform restore tests into a separate database.
