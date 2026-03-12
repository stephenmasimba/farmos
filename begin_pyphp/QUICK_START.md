# Quick Start Guide - Begin Masimba FarmOS

Get the system running in 5 minutes!

## Option 1: FastAPI + WAMP (Recommended)

```bash
# Backend
cd begin_pyphp/backend
pip install -r requirements.txt
uvicorn app:app --host 127.0.0.1 --port 8000 --reload

# Frontend
# Ensure WAMP/XAMPP is running
# Visit: http://localhost/farmos/begin_pyphp/frontend/public/
```

## Option 2: Windows Batch Helper

### Step 1: Start Backend

Use `begin_pyphp/start_backend.bat` to install deps and run uvicorn.

### Step 2: Verify
Health: http://127.0.0.1:8000/health

### Step 3: Frontend

```bash
Visit: http://localhost/farmos/begin_pyphp/frontend/public/
```

### Step 4: Access the Application

Open your browser:
- **Frontend**: [http://localhost:5173](http://localhost:5173)
- **Backend**: [http://127.0.0.1:8000](http://127.0.0.1:8000)
- **API Health**: [http://127.0.0.1:8000/health](http://127.0.0.1:8000/health)

## Verify Everything is Working

### Backend Health Check
`curl http://127.0.0.1:8000/health`

### Auth Test
```bash
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "X-API-Key: local-dev-key" \
  -d '{"email":"admin@example.com","password":"password123"}'
```

### Frontend Loads

Visit [http://localhost:5173](http://localhost:5173) and you should see a welcome page.

## Initial Setup (First Time Only)

### Sample Data
Seeder creates admin, manager, worker accounts on startup.

### Seed Sample Data (Optional)

```bash
cd backend
npm run db:seed

# This adds sample livestock batches, crops, inventory, etc.
```

## Development Workflow

### Making Backend Changes
- Edit files in `begin_pyphp/backend`
- uvicorn reload flag auto-restarts server

### Making Frontend Changes
- Edit PHP files in `begin_pyphp/frontend/pages`
- Refresh browser to see changes

### Database
- MySQL configured via SQLAlchemy in backend/common/database.py

## Common Tasks

### View Database Schema
Use a MySQL client or phpMyAdmin via WAMP.

### Reset Database (Development Only)

```bash
cd backend
npm run db:reset

# This drops all tables and rebuilds schema
```

### Stop Everything
Press Ctrl+C in backend terminal; stop WAMP services for frontend.

### Logs
Backend outputs to terminal; frontend logs in browser console (F12).

## Troubleshooting

### "Cannot connect to database"
1. Check MySQL/WAMP running
2. Verify backend/common/database.py connection string

### "Port 8000 already in use"
Use `netstat -ano | findstr :8000` then `taskkill /PID <PID> /F`.

### "CORS error in browser"

- Ensure backend is running
- Check CORS_ORIGIN in backend .env
- Clear browser cache (Ctrl+Shift+Delete)

## Next Steps

1. **Read Full Setup Guide**: [docs/SETUP.md](docs/SETUP.md)
2. **Learn Architecture**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
3. **API Reference**: [docs/API.md](docs/API.md)
4. **Deployment Guide**: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)
5. **System Design**: [../comprehensive_system_design.md](../comprehensive_system_design.md)

## Project Structure

```
begin-masimba-farmos/
├── backend/              # Python FastAPI
├── frontend/             # PHP frontend
├── database/             # Schema & migrations
├── docs/                 # Documentation
└── README.md             # Project overview
```

## Key Endpoints (Phase 1)

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - Create user

### Dashboard
- `GET /api/dashboard/kpis` - Key performance indicators
- `GET /api/dashboard/summary` - Daily summary

### Inventory
- `GET /api/inventory` - List items
- `POST /api/inventory/items` - Add item
- `POST /api/inventory/transactions` - Record usage

### Financial
- `POST /api/financial/transactions` - Log expense/income
- `GET /api/financial/daily-summary` - Daily P&L

### Livestock
- `GET /api/livestock/batches` - Active batches
- `POST /api/livestock/:id/events` - Record event (feeding, mortality, etc.)

### Health
- `GET /health` - Backend health check
- `GET /api/version` - API version

## IDE Setup (Recommended)

### VS Code Extensions
- ES7+ React/Redux/React-Native snippets
- Prettier - Code formatter
- ESLint
- MySQL
- Thunder Client (API testing)

## Performance Tips

### Backend
- API response target: <2 seconds
- Monitor with: `curl -w "@curl-format.txt"` 
- Database queries logged in `backend/logs/`

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
