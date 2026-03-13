# FarmOS - Docker Guide (Not Used)

This repository does not use Docker. The deployment target is a standard shared hosting environment (e.g., Afrihost) with PHP and MySQL.

## What to use instead

- Use [DEPLOYMENT_GUIDE.md](file:///c:/wamp64/www/farmos/DEPLOYMENT_GUIDE.md) for server/shared-hosting deployment steps.
- For local development on Windows, run the backend from WAMP (or PHP built-in server via `composer run serve`) and point the frontend at the backend URL.

## Shared hosting notes (Afrihost)

- Backend entrypoint: `begin_pyphp/backend/public/index.php` (set as the web root / document root).
- Environment configuration: `begin_pyphp/backend/config/.env` (do not commit this file).
- Database: provision a MySQL database in the hosting control panel, then import `begin_pyphp/database/schema.sql`.

