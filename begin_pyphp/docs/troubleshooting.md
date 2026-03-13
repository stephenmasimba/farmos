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
- Ensure your web server is serving the backend (`begin_pyphp/backend/`).
- If using the PHP built-in server, ensure it's running on port 8001.
- Verify `API_BASE_URL` (or `PHP_API_BASE_URL`) matches the backend URL.
- Check CORS settings in `backend/config/env.php`.

### 3. Missing Data
**Symptom**: Tables or lists are empty.
**Solution**:
- Check database connection string in `.env`.
- Inspect browser network tab for API errors (404, 500).

### 4. 401 Unauthorized / 403 Forbidden
**Symptom**: API requests fail with auth errors.
**Solution**:
- Ensure you are logged in and the token is valid.
- Check `Authorization` header format: `Bearer <token>`.
- Verify `Authorization` and `X-Tenant-ID` headers are present.
- Check user role permissions.

## Logs
- **Backend Logs**: Check standard output or configured log files.
- **Frontend Logs**: Check browser console (F12 > Console).
- **Web Server Logs**: Check `/var/log/nginx/error.log` or similar.

## Support
For further assistance, please contact the support team or open an issue on the repository.
