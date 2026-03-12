# Begin Masimba - Pure PHP Backend & Frontend

This project uses a pure PHP backend and a PHP frontend (WAMP).

## Project Structure

- **backend/**: Contains the PHP backend API.
  - **public/**: The web root (index.php).
  - **src/**: Controllers, models, and core classes.
- **frontend/**: Contains the PHP application.
  - **public/**: The web root (index.php, css, js).
  - **pages/**: PHP templates for each page.
  - **components/**: Shared PHP components (header, etc).

## Prerequisites

- **PHP 8.0+**: For the backend and frontend.
- **WAMP/XAMPP**: For the PHP frontend (Apache + PHP).
- **MySQL/MariaDB**: Database.

## Setup & Running

### 1. Backend (PHP)

The backend is served by your web server at:
`http://localhost/farmos/begin_pyphp/backend/`

### 2. Frontend (PHP)

Ensure WAMP is running. Access:
`http://localhost/farmos/begin_pyphp/frontend/public/`

## Modules Implemented

- **Authentication**: Login, JWT, API Key.
- **Dashboard**: Overview of alerts, tasks, livestock.
- **Livestock**: Manage animal batches.
- **Inventory**: Track items and stock.
- **Fields**: Manage crop fields.
- **Tasks**: Task management system.
- **Financial**: Track revenue and expenses.
- **IoT**: Device management and sensor data.
- **Weather**: Weather logs and current conditions.
- **Reports**: Generate PDF/CSV reports.
- **Notifications**: System alerts and messages.
- **Marketplace**: Buy/Sell listings and orders.
- **Blockchain**: Supply chain traceability ledger.
- **System**: Export/import, health, configuration.

## Authentication Flow
- Send `X-API-Key: local-dev-key` on requests (configurable via env).
- Login: `POST /api/auth/login` returns `access_token`.
- Use `Authorization: Bearer <token>` for protected endpoints.

## Feature Discovery
Each module exposes `/features` to enumerate and fetch feature placeholders, e.g.:
- `GET /api/financial/features`
- `GET /api/financial/features?name=Multi-Enterprise Revenue Tracking`
