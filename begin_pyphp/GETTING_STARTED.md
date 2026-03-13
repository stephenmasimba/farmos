# Begin Masimba FarmOS - Getting Started (Pure PHP)

## Pre-Flight Checklist ✈️

Use this checklist to verify everything is set up correctly before starting development.

---

## 📋 System Requirements

### Prerequisites
- [ ] **PHP 7.4+** (`php -v`)
- [ ] **WAMP/XAMPP** running (Apache + PHP)
- [ ] **MySQL/MariaDB** running
- [ ] **Git** (`git --version`)

### Verify Installation
```bash
php -v
mysql --version
```

---

## 🚀 Setup

Choose **ONE** of these setup methods:

### Backend (PHP)
1) Ensure WAMP/XAMPP is running
2) Backend entry point: `begin_pyphp/backend/public/index.php`
3) Health: `http://localhost/farmos/begin_pyphp/backend/health`

---

### Frontend (PHP)
1) Ensure WAMP/XAMPP Apache + PHP are running
2) Visit `http://localhost/farmos/begin_pyphp/frontend/public/`

**Step 4: Verify**
- [ ] Frontend loads: http://localhost/farmos/begin_pyphp/frontend/public/
- [ ] Backend responds: `curl http://localhost/farmos/begin_pyphp/backend/health`
- [ ] Database ready (MySQL)

---

## ✨ First Time Setup

After choosing your setup method above, complete these one-time tasks:

### Login
```bash
curl -X POST http://localhost/farmos/begin_pyphp/backend/api/auth/login \
  -H "Content-Type: application/json" \
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
- [ ] Health: `curl http://localhost/farmos/begin_pyphp/backend/health`
- [ ] Version: `curl http://localhost/farmos/begin_pyphp/backend/api/version`
- [ ] No error messages in terminal
- [ ] Logs show "Server started"

- [ ] Frontend loads at http://localhost/farmos/begin_pyphp/frontend/public/
- [ ] Welcome page displays
- [ ] No red errors in browser console (F12)
- [ ] Can scroll and interact with page

### Database Verification
```bash
# Use your MySQL client/phpMyAdmin to verify the schema and tables.
```

### Local Development Notes
- Refresh the browser after editing PHP files.

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
├── backend/                    # PHP backend
│   ├── public/                # web root (index.php)
│   └── src/                   # controllers, models, core
├── frontend/                   # PHP frontend
│   ├── public/                # web root
│   └── pages/                 # UI pages
├── database/
│   └── schema.sql             # Database schema
```

---

## 🔧 Common Development Tasks

### Start Development
```bash
# Backend and frontend run under your web server (WAMP/XAMPP).
# Visit:
# http://localhost/farmos/begin_pyphp/frontend/public/
```

### Stop Development
```bash
Stop/restart WAMP/XAMPP services as needed.
```

### Database Operations
```bash
# Use MySQL/phpMyAdmin to inspect and manage the schema/data.
```

### Code Quality
```bash
cd backend
composer run lint
composer run type-check
composer run test
```

---

## 🐛 Troubleshooting Guide

### "Cannot Connect to Database"
Verify your MySQL credentials and that the MySQL service is running.

### "Port Already in Use"

If you're using the optional PHP built-in server (`composer run serve`), the default port is **8001**.

**Port 8001 (Backend)**:
```bash
# Find process
lsof -i :8001                              # macOS/Linux
netstat -ano | findstr :8001              # Windows

# Kill process
kill -9 <PID>                              # macOS/Linux
taskkill /PID <PID> /F                    # Windows
```

### "CORS Error in Browser"

1. Verify backend is reachable: `curl http://localhost/farmos/begin_pyphp/backend/health`
2. Check CORS_ORIGIN in backend config matches your frontend URL
3. Clear browser cache: Ctrl+Shift+Delete
4. Hard refresh: Ctrl+Shift+R

---

## 📚 Documentation Map

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **README.md** | Project overview | First - understand the big picture |
| **QUICK_START.md** | Quick setup | Second - get it running fast |
| **backend/PHP_BACKEND_README.md** | Backend setup & scripts | When working on the API |
| **docs/DEVELOPER_GUIDE.md** | Dev workflow & standards | When contributing |
| **docs/USER_MANUAL.md** | End-user guide | When demoing |
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

3. **Start extending the system**
   - Backend: Add/update endpoints in `backend/public/index.php` and `backend/src/Controllers/`
   - Frontend: Add new pages in `frontend/pages/`
   - See [PROJECT_LAUNCH.md](PROJECT_LAUNCH.md) for roadmap

4. **Use [docs/API.md](docs/API.md)** (when ready)
   - Reference for API design
   - Endpoint specifications

---

## 💡 Pro Tips

### Development Efficiency
- Use VS Code extensions: ES7, Prettier, ESLint, Thunder Client
- Use browser DevTools (F12) frequently
- Check backend logs in `backend/logs/all.log`

### Database Debugging
```bash
# Use your MySQL client/phpMyAdmin to inspect tables and data.
```

### API Testing
```bash
# Use curl
curl http://localhost/farmos/begin_pyphp/backend/health

# Or use Thunder Client in VS Code
# Or use Postman
```

### Performance Monitoring
```bash
# Check database response times
# Look in backend/logs/all.log for slow queries
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
- [ ] Setup method chosen (Local)
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
