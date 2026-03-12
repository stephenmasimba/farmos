# Begin Masimba FarmOS - Getting Started (Python + PHP)

## Pre-Flight Checklist ✈️

Use this checklist to verify everything is set up correctly before starting development.

---

## 📋 System Requirements

### Prerequisites
- [ ] **Python 3.10+** (`python --version`)
- [ ] **pip** (`pip --version`)
- [ ] **WAMP/XAMPP** running (Apache + PHP)
- [ ] **MySQL** (or SQLite for local dev)
- [ ] **Git** (`git --version`)

### Verify Installation
```bash
python --version
pip --version
php -v
mysql --version
```

---

## 🚀 Setup

Choose **ONE** of these setup methods:

### Backend (FastAPI)
1) Open terminal in `begin_pyphp/backend`
2) Install deps: `pip install -r requirements.txt`
3) Run server: `uvicorn app:app --host 127.0.0.1 --port 8000 --reload`
4) Health: `http://127.0.0.1:8000/health`

---

### Frontend (PHP)
1) Ensure WAMP/XAMPP Apache + PHP are running
2) Visit `http://localhost/farmos/begin_pyphp/frontend/public/`

**Step 4: Verify**
- [ ] Frontend loads: http://localhost:5173
- [ ] Backend responds: `curl http://localhost:3000/health`
- [ ] Database ready: `psql -d begin_masimba_farm -c "SELECT COUNT(*) FROM users;"`

---

## ✨ First Time Setup

After choosing your setup method above, complete these one-time tasks:

### Login
```bash
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "X-API-Key: local-dev-key" \
  -d '{"email": "admin@example.com", "password": "password123"}'
```

### Seed Sample Data
Seeds run automatically at backend startup. Users include admin/manager/worker.

This adds:
- Sample livestock batches
- Sample crops
- Sample inventory items
- Sample transactions

---

## 🎮 Verification Checklist

After setup, verify everything works:

### Backend Health Checks
- [ ] Health: `curl http://127.0.0.1:8000/health`
- [ ] Version: `curl http://127.0.0.1:8000/api/version`
- [ ] No error messages in terminal
- [ ] Logs show "Server started"

- [ ] Frontend loads at http://localhost/farmos/begin_pyphp/frontend/public/
- [ ] Welcome page displays
- [ ] No red errors in browser console (F12)
- [ ] Can scroll and interact with page

### Database Verification
```bash
# Check database exists
psql -l | grep begin_masimba_farm

# Check tables were created
psql -d begin_masimba_farm -c "\dt"

# Should show 9+ tables:
# users, livestock_batches, animal_events, crops, inventory_items,
# transactions, sensor_readings, sales_orders, feed_ingredients, feed_formulations
```

### Hot Reload (if developing locally)
- [ ] Modify `frontend/src/App.jsx` 
- [ ] Page automatically updates in browser
- [ ] Modify `backend/server.js`
- [ ] Server automatically reloads (watch "Restart" message)

---

## 📁 Project Structure Quick Reference

```
begin-masimba-farmos/
├── README.md                    # Start here for overview
├── QUICK_START.md              # 5-minute guide
├── PROJECT_LAUNCH.md           # Launch summary (this might be it)
├── docs/
│   ├── SETUP.md               # Detailed setup guide
│   ├── ARCHITECTURE.md        # System design
│   └── API.md                 # API documentation (coming)
├── backend/                    # Python FastAPI
│   ├── app.py                 # FastAPI app
│   ├── routers/               # API endpoints
│   └── common/                # security, db, dependencies
├── frontend/                   # PHP frontend
│   ├── public/                # web root
│   └── pages/                 # UI pages
├── database/
│   └── schema.sql             # Database schema
└── docker/
    └── docker-compose.yml     # Container setup
```

---

## 🔧 Common Development Tasks

### Start Development
```bash
npm run dev                    # Start backend + frontend
# OR
npm run dev:backend          # Just backend
npm run dev:frontend         # Just frontend
```

### Stop Development
```bash
# If using npm run dev:
Ctrl+C in each terminal

# If using Docker:
docker-compose -f docker/docker-compose.yml down
```

### Database Operations
```bash
npm run db:migrate           # Apply migrations
npm run db:seed             # Load sample data
npm run db:reset            # Clear everything (dev only!)
```

### Code Quality
```bash
npm run lint                # Check code
npm run test                # Run tests
```

---

## 🐛 Troubleshooting Guide

### "Cannot Connect to Database"

**If using Docker**:
```bash
docker-compose -f docker/docker-compose.yml logs postgres
# Look for connection errors
```

**If using Local PostgreSQL**:
```bash
# 1. Check PostgreSQL is running
psql -U postgres -c "SELECT version();"

# 2. Check database exists
createdb begin_masimba_farm

# 3. Verify .env variables match your setup
cat backend/.env
```

### "Port Already in Use"

**Port 3000 (Backend)**:
```bash
# Find process
lsof -i :3000                              # macOS/Linux
netstat -ano | findstr :3000              # Windows

# Kill process
kill -9 <PID>                              # macOS/Linux
taskkill /PID <PID> /F                    # Windows
```

**Port 5173 (Frontend)**:
```bash
# Same as above but replace 3000 with 5173
```

### "CORS Error in Browser"

1. Verify backend is running: `curl http://localhost:3000/health`
2. Check CORS_ORIGIN in backend/.env matches frontend URL
3. Clear browser cache: Ctrl+Shift+Delete
4. Hard refresh: Ctrl+Shift+R

### "Docker Containers Won't Start"

```bash
# 1. Check system resources (need 4GB+ RAM)
docker stats

# 2. Check logs
docker-compose -f docker/docker-compose.yml logs

# 3. Rebuild from scratch
docker-compose -f docker/docker-compose.yml down
docker-compose -f docker/docker-compose.yml build --no-cache
docker-compose -f docker/docker-compose.yml up -d
```

### "npm install Fails"

```bash
# Clear cache
npm cache clean --force

# Delete lock file and node_modules
rm -rf node_modules package-lock.json

# Reinstall
npm install
```

---

## 📚 Documentation Map

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **README.md** | Project overview | First - understand the big picture |
| **QUICK_START.md** | Quick setup | Second - get it running fast |
| **docs/SETUP.md** | Detailed installation | If you need detailed steps |
| **docs/ARCHITECTURE.md** | System design | To understand how it works |
| **database/schema.sql** | DB structure | To understand data model |
| **comprehensive_system_design.md** | Full specifications | To understand all features |

---

## 🎯 Next Steps After Verification

Once everything is verified working:

1. **Read [comprehensive_system_design.md](../comprehensive_system_design.md)**
   - Understand all Phase 1 requirements
   - Review database schema
   - Learn about features

2. **Review [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**
   - Understand system layers
   - Review component architecture
   - Learn data flow

3. **Start implementing Phase 1**
   - Backend: Create `/api/auth` routes
   - Frontend: Build login form
   - See [PROJECT_LAUNCH.md](PROJECT_LAUNCH.md) for detailed roadmap

4. **Use [docs/API.md](docs/API.md)** (when ready)
   - Reference for API design
   - Endpoint specifications

---

## 💡 Pro Tips

### Development Efficiency
- Use VS Code extensions: ES7, Prettier, ESLint, Thunder Client
- Keep `npm run dev` running in background
- Use browser DevTools (F12) frequently
- Check backend logs in `backend/logs/all.log`

### Database Debugging
```bash
# Connect to running database
psql -d begin_masimba_farm

# Common queries
\dt                           # List tables
SELECT COUNT(*) FROM users;   # Count users
\d users                      # Describe users table
SELECT * FROM users LIMIT 5;  # View sample data
```

### API Testing
```bash
# Use curl
curl http://localhost:3000/health

# Or use Thunder Client in VS Code
# Or use Postman
```

### Performance Monitoring
```bash
# Check database response times
# Look in backend/logs/all.log for slow queries

# Monitor Node.js memory
node --inspect server.js
# Open chrome://inspect in Chrome
```

---

## 🚨 Important Reminders

⚠️ **Before Production**:
- [ ] Change JWT_SECRET in .env
- [ ] Change database password
- [ ] Enable HTTPS/TLS
- [ ] Configure firewall
- [ ] Set up backups
- [ ] Review [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

📝 **During Development**:
- [ ] Commit code regularly to git
- [ ] Keep .env files (DON'T commit them!)
- [ ] Document any changes to schema
- [ ] Follow code style guide
- [ ] Write tests for new features

✅ **Best Practices**:
- [ ] Use meaningful commit messages
- [ ] Create branches for features
- [ ] Review code before committing
- [ ] Keep database schema in sync
- [ ] Update documentation

---

## ✨ Success Criteria

You're ready to start developing when:

- ✅ Backend responds to health check
- ✅ Frontend loads in browser
- ✅ Database has all tables
- ✅ Hot reload works (both frontend & backend)
- ✅ You can see logs in terminal
- ✅ You understand the project structure
- ✅ You've read the main documentation

---

## 🆘 Get Help

If stuck:

1. **Check the logs**
   - Backend: Terminal output
   - Frontend: Browser console (F12)
   - Docker: `docker-compose logs`

2. **Read the documentation**
   - [docs/SETUP.md](docs/SETUP.md) for detailed setup
   - [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for design

3. **Review error messages carefully**
   - Database connection errors?
   - Port already in use?
   - Missing npm packages?

4. **Try the troubleshooting section above**

---

## 📞 Support Resources

- **Project Overview**: [README.md](README.md)
- **Quick Start**: [QUICK_START.md](QUICK_START.md)
- **Detailed Setup**: [docs/SETUP.md](docs/SETUP.md)
- **Architecture**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **System Design**: [comprehensive_system_design.md](../comprehensive_system_design.md)

---

## ✅ Final Checklist

- [ ] All prerequisites installed and verified
- [ ] Setup method chosen (Docker OR Local)
- [ ] All services running successfully
- [ ] Health checks passing
- [ ] Frontend loads in browser
- [ ] Database tables confirmed
- [ ] Hot reload working
- [ ] Ready to start Phase 1 development

---

## 🎉 You're Ready!

Everything is set up. Time to start building Begin Masimba FarmOS!

**Next**: Pick a Phase 1 feature and start coding:
1. Authentication system
2. Admin dashboard
3. Inventory module
4. Financial tracking

---

**Status**: ✅ Ready to Develop  
**Date**: January 11, 2026  
**Phase**: Phase 1 - The Nervous System

Happy coding! 🚀
