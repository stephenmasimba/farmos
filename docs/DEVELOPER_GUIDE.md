# FarmOS Developer Guide

## Architecture
- **Frontend**: PHP (Server-side Rendering) + Tailwind CSS + JavaScript (Chart.js, Service Worker)
- **Backend**: Python FastAPI + SQLAlchemy + MySQL
- **Deployment**: WAMP Stack (Apache, MySQL, Python)

## Setup
1. **Prerequisites**: Python 3.10+, WAMP Server.
2. **Install Dependencies**: `pip install -r backend/requirements.txt`
3. **Database**: Create `farmos` database in MySQL.
4. **Environment**: Copy `.env.example` to `.env`.

## Contribution Workflow
1. Fork the repository.
2. Create a feature branch.
3. Commit changes.
4. Submit a Pull Request.

## Coding Standards
- **Python**: Follow PEP 8.
- **PHP**: Follow PSR-12.
- **Commits**: Use conventional commits (e.g., `feat: add new chart`).

## Testing
- Run backend tests: `pytest`
