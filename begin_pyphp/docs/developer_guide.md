# Begin Masimba - Developer Guide

## Contributing
We welcome contributions to Begin Masimba! Please follow these guidelines to ensure code quality and consistency.

## Project Structure
- `backend/`: PHP backend API.
  - `public/`: Web root (index.php).
  - `src/`: Controllers, models, and core classes.
  - `tests/`: PHPUnit test suite.
- `frontend/`: PHP frontend application.
  - `pages/`: UI pages.
  - `components/`: Reusable UI components.
  - `lib/`: Helper libraries (API client, i18n).
  - `public/`: Static assets and entry point.
- `database/`: SQL schema files.
- `docs/`: Documentation.

## Setup Development Environment

1. **Prerequisites**:
   - PHP 8.0+
   - MySQL/MariaDB
   - Composer

2. **Backend Setup**:
   ```bash
   cd backend
   composer install
   composer run serve
   ```

3. **Frontend Setup**:
   Serve the `frontend/public` directory using a web server (e.g., Apache, Nginx, or PHP built-in server).
   ```bash
   cd frontend/public
   php -S localhost:8080
   ```

## Coding Standards

### PHP (Frontend)
- Follow PSR-12 coding standard.
- Use the `call_api` helper for backend requests.
- Ensure HTML is semantic and accessible.
- Use Tailwind CSS for styling.

## Workflow
1. Create a new branch for your feature or bugfix.
2. Implement your changes.
3. Run tests (`composer run test` for backend).
4. Submit a Pull Request (PR) with a clear description of your changes.

## Testing
- **Backend Tests**: `cd backend && composer run test`

## Deployment
See `docs/deployment_guide.md` for deployment instructions.
