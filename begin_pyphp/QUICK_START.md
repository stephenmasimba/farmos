# Quick Start Guide - Begin Masimba FarmOS

Get the system running in 5 minutes!

## Option 1: WAMP/XAMPP (Recommended)

```bash
# Frontend
# Ensure WAMP/XAMPP is running
# Visit: http://localhost/farmos/begin_pyphp/frontend/public/

# Backend (served by WAMP/XAMPP)
# Health: http://localhost/farmos/begin_pyphp/backend/health
```

## Option 2: Windows Batch Helper

### Step 1: Start Backend

Use `begin_pyphp/LAUNCH_FARMOS.bat` to start the system.

Or run the backend with the PHP built-in server:
```bash
cd begin_pyphp/backend
composer run serve
```

### Step 2: Verify
Health: http://127.0.0.1:8001/health

### Step 3: Frontend

```bash
Visit: http://localhost/farmos/begin_pyphp/frontend/public/
```

### Step 4: Access the Application

Open your browser:
- **Frontend**: [http://localhost/farmos/begin_pyphp/frontend/public/](http://localhost/farmos/begin_pyphp/frontend/public/)
- **Backend**: [http://127.0.0.1:8001](http://127.0.0.1:8001)
- **API Health**: [http://127.0.0.1:8001/health](http://127.0.0.1:8001/health)

## Verify Everything is Working

### Backend Health Check
`curl http://127.0.0.1:8001/health`

### Auth Test
```bash
curl -X POST http://127.0.0.1:8001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password123"}'
```

### Frontend Loads

Visit [http://localhost/farmos/begin_pyphp/frontend/public/](http://localhost/farmos/begin_pyphp/frontend/public/) and you should see the login page.

## Initial Setup (First Time Only)

### Sample Data
Sample users are created on first run (admin/manager/worker).

### Seed Sample Data (Optional)

```bash
cd backend
php -r "echo 'Seed is handled by your database/schema setup.';"

# This adds sample livestock batches, crops, inventory, etc.
```

## Development Workflow

### Making Backend Changes
- Edit files in `begin_pyphp/backend`
- Restart the PHP built-in server (if using Option 2) to pick up changes

### Making Frontend Changes
- Edit PHP files in `begin_pyphp/frontend/pages`
- Refresh browser to see changes

### Database
- MySQL configured in `begin_pyphp/backend/config/env.php` and your `.env`

## Common Tasks

### View Database Schema
Use a MySQL client or phpMyAdmin via WAMP.

### Reset Database (Development Only)

```bash
cd backend
php -r "echo 'Use your MySQL tools to reset schema/data in development.';"

# This drops all tables and rebuilds schema
```

### Stop Everything
Press Ctrl+C in backend terminal; stop WAMP services for frontend.

### Logs
Backend outputs to terminal; frontend logs in browser console (F12).

## Troubleshooting

### "Cannot connect to database"
1. Check MySQL/WAMP running
2. Verify backend configuration in `begin_pyphp/backend/config/env.php` and your `.env`

### "Port 8001 already in use"
Use `netstat -ano | findstr :8001` then `taskkill /PID <PID> /F`.

### "CORS error in browser"

- Ensure backend is running
- Check CORS_ORIGIN in backend .env
- Clear browser cache (Ctrl+Shift+Delete)

## Next Steps

1. **Backend setup**: [backend/PHP_BACKEND_README.md](backend/PHP_BACKEND_README.md)
2. **Test suite**: [backend/TEST_SUITE.md](backend/TEST_SUITE.md)
3. **Developer guide**: [../docs/DEVELOPER_GUIDE.md](../docs/DEVELOPER_GUIDE.md)
4. **User manual**: [../docs/USER_MANUAL.md](../docs/USER_MANUAL.md)
5. **System design (spec)**: [../comprehensive_system_design.md](../comprehensive_system_design.md)

## Project Structure

```
begin-masimba-farmos/
├── backend/              # PHP backend
├── frontend/             # PHP frontend
├── database/             # Schema & migrations
├── docs/                 # Documentation
└── README.md             # Project overview
```

## Key Endpoints (Phase 1)

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - Create user
- `GET /api/auth/me` - Current user
- `POST /api/auth/refresh-token` - Refresh token

### Dashboard
- `GET /api/dashboard/kpis` - Key performance indicators
- `GET /api/dashboard/summary` - Daily summary

### Inventory
- `GET /api/inventory` - List items
- `POST /api/inventory` - Add item
- `GET /api/inventory/{id}` - Get item
- `PUT /api/inventory/{id}` - Update item
- `DELETE /api/inventory/{id}` - Delete item
- `POST /api/inventory/{id}/adjust` - Adjust quantity
- `GET /api/inventory/stats` - Inventory stats

### Financial
- `GET /api/financial` - List records
- `POST /api/financial` - Create record
- `GET /api/financial/{id}` - Get record
- `PUT /api/financial/{id}` - Update record
- `DELETE /api/financial/{id}` - Delete record
- `GET /api/financial/summary` - Summary

### Livestock
- `GET /api/livestock` - List livestock
- `POST /api/livestock` - Create livestock
- `GET /api/livestock/{id}` - Get livestock
- `PUT /api/livestock/{id}` - Update livestock
- `DELETE /api/livestock/{id}` - Delete livestock
- `GET /api/livestock/{id}/events` - List events
- `POST /api/livestock/{id}/events` - Add event
- `GET /api/livestock/stats` - Livestock stats

### Tasks
- `GET /api/tasks` - List tasks
- `POST /api/tasks` - Create task
- `GET /api/tasks/{id}` - Get task
- `PUT /api/tasks/{id}` - Update task
- `DELETE /api/tasks/{id}` - Delete task

### Health
- `GET /health` - Backend health check
- `GET /api/version` - API version

## IDE Setup (Recommended)

### VS Code Extensions
- Prettier - Code formatter
- ESLint
- MySQL
- Thunder Client (API testing)

## Performance Tips

### Backend
- API response target: <2 seconds
- Monitor with: `curl -w "@curl-format.txt"` 

### Frontend
- Check Network tab (F12)
- Monitor Core Web Vitals
- Use React DevTools Profiler

### Database
- Indexes already configured in schema.sql
- Monitor with: `EXPLAIN ANALYZE SELECT ...`

## Security Reminder

⚠️ **Development Only**:
- .env.example has default passwords
- JWT_SECRET shown in code
- No HTTPS in development

✅ **Before Production**:
- Change all passwords
- Generate strong JWT_SECRET
- Enable HTTPS/TLS
- Configure firewall rules
- Enable database backups
- Review security checklist in [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## Support

For issues or questions:
1. Check the full documentation in `docs/`
2. Review error logs in `backend/logs/`
3. Check browser console (F12) for frontend errors
4. Verify all services are running

---

**Ready to start?** Run one of the commands above and you'll have the system running in minutes!

Last Updated: January 11, 2026
