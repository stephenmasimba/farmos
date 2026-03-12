# Begin Masimba - Developer Guide

## Contributing
We welcome contributions to Begin Masimba! Please follow these guidelines to ensure code quality and consistency.

## Project Structure
- `backend/`: FastAPI application (Python).
  - `routers/`: API route definitions.
  - `common/`: Shared utilities (database, auth, models).
  - `tests/`: Pytest test suite.
- `frontend/`: PHP frontend application.
  - `pages/`: UI pages.
  - `components/`: Reusable UI components.
  - `lib/`: Helper libraries (API client, i18n).
  - `public/`: Static assets and entry point.
- `database/`: SQL schema files.
- `docs/`: Documentation.

## Setup Development Environment

1. **Prerequisites**:
   - Python 3.8+
   - PHP 7.4+
   - MySQL/MariaDB or SQLite (default)
   - Composer (optional)

2. **Backend Setup**:
   ```bash
   cd backend
   pip install -r requirements.txt
   uvicorn app:app --reload
   ```

3. **Frontend Setup**:
   Serve the `frontend/public` directory using a web server (e.g., Apache, Nginx, or PHP built-in server).
   ```bash
   cd frontend/public
   php -S localhost:8080
   ```

## Coding Standards

### Python (Backend)
- Follow PEP 8 style guide.
- Use type hints for function arguments and return values.
- Write unit tests for new logic (`pytest`).
- Use Pydantic models for data validation.

### PHP (Frontend)
- Follow PSR-12 coding standard.
- Use the `call_api` helper for backend requests.
- Ensure HTML is semantic and accessible.
- Use Tailwind CSS for styling.

## Workflow
1. Create a new branch for your feature or bugfix.
2. Implement your changes.
3. Run tests (`pytest` for backend).
4. Submit a Pull Request (PR) with a clear description of your changes.

## Testing
- **Unit Tests**: `pytest backend/tests`
- **E2E Tests**: `pytest backend/tests/test_e2e_flow.py`

## Deployment
See `docs/deployment_guide.md` for deployment instructions.
