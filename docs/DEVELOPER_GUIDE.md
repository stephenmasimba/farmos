# FarmOS Developer Guide

## Architecture
- **Frontend**: PHP (Server-side Rendering) + Tailwind CSS + JavaScript (Chart.js, Service Worker)
- **Backend**: Pure PHP API + MySQL (see `begin_pyphp/backend`)
- **Deployment**: WAMP Stack (Apache, MySQL, PHP)

## Setup
1. **Prerequisites**: PHP 7.4+, Composer, WAMP Server (Apache + MySQL).
2. **Install Dependencies**: `cd begin_pyphp/backend && composer install`
3. **Database**: Create `begin_masimba_farm` database in MySQL (or update `begin_pyphp/backend/config/env.php`).
4. **Environment**: Copy `begin_pyphp/backend/.env.example` to `begin_pyphp/backend/.env` (optional; defaults exist).

## Contribution Workflow
1. Fork the repository.
2. Create a feature branch.
3. Commit changes.
4. Submit a Pull Request.

## Coding Standards
- **PHP**: Follow PSR-12.
- **Commits**: Use conventional commits (e.g., `feat: add new chart`).

## Testing
- Run backend tests: `cd begin_pyphp/backend && composer run test`
