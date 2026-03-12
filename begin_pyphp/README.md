# Begin Masimba - Python Backend & PHP Frontend

This project uses a Python (FastAPI) backend and a PHP frontend (WAMP).

## Project Structure

- **backend/**: Contains the Python FastAPI application.
  - **app.py**: The main entry point.
  - **routers/**: Contains API route handlers for each module.
  - **common/**: Shared utilities (security, database).
- **frontend/**: Contains the PHP application.
  - **public/**: The web root (index.php, css, js).
  - **pages/**: PHP templates for each page.
  - **components/**: Shared PHP components (header, etc).

## Prerequisites

- **Python 3.8+**: For the backend.
- **WAMP/XAMPP**: For the PHP frontend (Apache + PHP).
- **pip**: Python package manager.

## Setup & Running

### 1. Backend (Python)

Open a terminal in the `backend` directory and install dependencies:

```bash
pip install -r requirements.txt
```

Run the backend server:

```bash
cd backend
uvicorn app:app --host 127.0.0.1 --port 8000 --reload
```
The API runs at `http://127.0.0.1:8000`.

### 2. Frontend (PHP)

Ensure WAMP is running. Access:
`http://localhost/farmos/begin_pyphp/frontend/public/`

## Modules Implemented

- **Authentication**: Login, JWT (PyJWT), API Key.
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
