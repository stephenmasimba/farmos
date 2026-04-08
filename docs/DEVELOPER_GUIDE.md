# FarmOS Developer Guide

See [INDEX.md](./INDEX.md) for the full documentation map.

## Architecture
- **Frontend**: PHP (Server-side Rendering) + Tailwind CSS + JavaScript (Chart.js, Service Worker)
- **Backend**: Pure PHP API + MySQL (see `app/backend`)
- **Deployment**: WAMP Stack (Apache, MySQL, PHP)

## Setup
1. **Prerequisites**: PHP 7.4+, Composer, WAMP Server (Apache + MySQL).
2. **Install Dependencies**: `cd app/backend && composer install`
3. **Database**: Create `begin_masimba_farm` database in MySQL (or update `app/backend/config/env.php`).
4. **Environment**: Copy `app/backend/.env.example` to `app/backend/.env` (optional; defaults exist).

## Contribution Workflow
1. Fork the repository.
2. Create a feature branch.
3. Commit changes.
4. Submit a Pull Request.

## Coding Standards
- **PHP**: Follow PSR-12.
- **Commits**: Use conventional commits (e.g., `feat: add new chart`).

## Testing
- Run backend tests: `cd app/backend && composer run test`
