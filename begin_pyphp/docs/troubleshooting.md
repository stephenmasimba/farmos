# Begin Masimba - Troubleshooting Guide

## Common Issues

### 1. Login Failed
**Symptom**: "Invalid credentials" error on login.
**Solution**:
- Check if the database is initialized.
- Ensure the user exists in the `users` table.
- Verify the password hash matches (passwords are hashed with bcrypt).
- Check backend logs for errors.

### 2. API Connection Refused
**Symptom**: Frontend shows "Failed to fetch" or connection errors.
**Solution**:
- Ensure the backend server is running (`uvicorn` or `gunicorn`).
- Check if the backend is listening on port 8000 (default).
- Verify `API_BASE_URL` in frontend JavaScript matches the backend URL.
- Check CORS settings in `backend/app.py`.

### 3. Missing Data
**Symptom**: Tables or lists are empty.
**Solution**:
- Run the seeder to populate sample data: `python backend/common/seeder.py` (or restart backend if seeder runs on startup).
- Check database connection string in `.env`.
- Inspect browser network tab for API errors (404, 500).

### 4. 401 Unauthorized / 403 Forbidden
**Symptom**: API requests fail with auth errors.
**Solution**:
- Ensure you are logged in and the token is valid.
- Check `Authorization` header format: `Bearer <token>`.
- Verify `X-API-Key` and `X-Tenant-ID` headers are present.
- Check user role permissions.

### 5. Database Locked (SQLite)
**Symptom**: "Database is locked" error.
**Solution**:
- Ensure no other process is holding a lock on `farmos.db`.
- Restart the backend server.
- Consider migrating to PostgreSQL or MySQL for high concurrency.

## Logs
- **Backend Logs**: Check standard output or configured log files.
- **Frontend Logs**: Check browser console (F12 > Console).
- **Web Server Logs**: Check `/var/log/nginx/error.log` or similar.

## Support
For further assistance, please contact the support team or open an issue on the repository.
