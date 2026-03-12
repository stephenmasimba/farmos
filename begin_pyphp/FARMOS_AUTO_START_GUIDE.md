# 🚀 FarmOS Auto-Start Setup Guide

## 📋 Overview

FarmOS includes an **automatic start system** that can launch the PHP backend and open the web UI.

---

## 🎯 **Quick Start (Recommended)**

### **Method 1: One-Click Launcher** ⭐
1. **Double-click** `LAUNCH_FARMOS.bat` in the FarmOS folder
2. **FarmOS opens** automatically in your browser!
4. **Login** with: `manager@masimba.farm` / `manager123`

---

## 🔧 **Auto-Start Options**

### **Option 1: Manual Launcher**
**File**: `LAUNCH_FARMOS.bat`
- ✅ **One-click start**
- ✅ **Opens browser automatically**
- ✅ **Shows login credentials**
- ✅ **Keeps server running**

---

## 🎯 **Recommended Setup**

### **For Daily Use:**
1. **Run once**: `LAUNCH_FARMOS.bat`
2. **FarmOS starts** automatically
3. **Login** with your credentials
4. **Keep window open** to maintain server

### **For Development:**
1. Run the backend: `start_backend.bat`
2. Use the API health check to confirm it's running

### **For Production:**
Use Apache/Nginx to serve the frontend at `begin_pyphp/frontend/public/` and the backend at `begin_pyphp/backend/` (or set backend doc root to `begin_pyphp/backend/public/`).

---

## 🔑 **Login Credentials**

| Role | Email | Password |
|------|-------|----------|
| **Admin** | admin@masimba.farm | admin123 |
| **Manager** | manager@masimba.farm | manager123 |
| **Worker** | worker@masimba.farm | worker123 |

---

## 🌐 **Access URLs**

| Service | URL |
|---------|-----|
| **Web Interface** | http://localhost:8081/farmos/ |
| **API Server** | http://127.0.0.1:8001 |
| **Health Check** | http://127.0.0.1:8001/health |

---

## 🛠️ **How It Works**

### **Auto-Start Process:**
1. **Folder Access** → Launcher activates
2. **Server Start** → PHP backend launches
4. **Health Check** → Server responsiveness verified
5. **Browser Open** → FarmOS loads automatically
6. **Login Ready** → Authentication system active

### **Monitoring System:**
- **Continuous monitoring** every 5 seconds
- **Auto-restart** if server crashes
- **Background operation** (minimal resources)
- **Clean shutdown** on exit

---

## 🔧 **Troubleshooting**

### **❌ Server Won't Start:**
```bash
# Check PHP installation
php -v

# Start backend
cd backend
php -S 127.0.0.1:8001 -t public/
```

### **❌ Login Not Working:**
Verify MySQL is running and the `users` table has your login user.

### **❌ Port Already in Use:**
```bash
# Check what's using port 8001
netstat -ano | findstr :8001

# Kill the process
taskkill /PID [PID_NUMBER] /F
```

### **❌ Database Connection:**
```bash
# Check MySQL service
# Windows: Services → MySQL → Start
# Or restart MySQL service
```

---

## 📁 **File Structure**

```
begin_pyphp/
├── LAUNCH_FARMOS.bat          # ⭐ Main launcher
├── start_backend.bat          # Start backend (PHP built-in server)
├── AUTO_START.bat             # Background launcher
├── AutoStart.vbs              # Optional launcher helper
├── backend/
│   └── public/                # Backend web root
├── frontend/
│   ├── simple_auth.php        # PHP authentication
│   └── pages/login.php        # Login page
└── FARMOS_AUTO_START_GUIDE.md # This guide
```

---

## 🎉 **Benefits**

### ✅ **What You Get:**
- **Instant access** - No manual server start
- **Browser integration** - Opens automatically
- **Background operation** - Minimal disruption

### ✅ **When It Activates:**
- **Folder access** → Server starts
- **Manual launch** → Instant start

---

## 🚀 **Getting Started**

### **First Time Setup:**
1. **Double-click** `LAUNCH_FARMOS.bat`
2. **Wait** for automatic setup
3. **Login** with provided credentials
4. **Enjoy** FarmOS!

### **Daily Use:**
1. **Open** the FarmOS folder
2. **Double-click** `LAUNCH_FARMOS.bat`
3. **FarmOS loads** automatically
4. **Start working!**

---

## 🎯 **Success Indicators**

### ✅ **Working Correctly When:**
- ✅ Launcher runs without errors
- ✅ Server starts on port 8001
- ✅ Browser opens to FarmOS
- ✅ Login works with credentials
- ✅ Dashboard loads successfully
- ✅ All features accessible

### ✅ **Auto-Start Features:**
- ✅ Server starts automatically
- ✅ No manual intervention needed
- ✅ Background monitoring
- ✅ Clean shutdown process

---

## 🎉 **Ready to Use!**

**Your FarmOS system now has complete auto-start capability!**

**🚀 Just double-click `LAUNCH_FARMOS.bat` and start using FarmOS immediately!**

---

*Last Updated: 2026-02-12*
*Version: 1.0 - Auto-Start System*
