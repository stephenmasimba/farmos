# 🚀 FarmOS Auto-Start Setup Guide

## 📋 Overview

FarmOS now includes an **automatic server start system** that launches the Python backend as soon as you access the folder, ensuring your login works immediately!

---

## 🎯 **Quick Start (Recommended)**

### **Method 1: One-Click Launcher** ⭐
1. **Double-click** `LAUNCH_FARMOS.bat` in the FarmOS folder
2. **Wait** for automatic setup (installs packages if needed)
3. **FarmOS opens** automatically in your browser!
4. **Login** with: `manager@masimba.farm` / `manager123`

---

## 🔧 **Auto-Start Options**

### **Option 1: Manual Launcher**
**File**: `LAUNCH_FARMOS.bat`
- ✅ **One-click start**
- ✅ **Auto-installs packages**
- ✅ **Opens browser automatically**
- ✅ **Shows login credentials**
- ✅ **Keeps server running**

### **Option 2: Python Launcher**
**File**: `START_FARMOS.py`
- ✅ **Cross-platform compatible**
- ✅ **Package checking**
- ✅ **Background monitoring**
- ✅ **Clean interface**

### **Option 3: Background Monitor**
**File**: `monitor_server.py`
- ✅ **Runs in background**
- ✅ **Auto-restarts if server crashes**
- ✅ **Minimal resource usage**
- ✅ **Continuous monitoring**

### **Option 4: Windows Startup**
**File**: `setup_autostart.py`
- ✅ **Starts with Windows**
- ✅ **Always available**
- ✅ **Set and forget**
- ✅ **Automatic startup**

---

## 🎯 **Recommended Setup**

### **For Daily Use:**
1. **Run once**: `LAUNCH_FARMOS.bat`
2. **FarmOS starts** automatically
3. **Login** with your credentials
4. **Keep window open** to maintain server

### **For Development:**
1. **Use**: `START_FARMOS.py`
2. **Better error handling**
3. **Clean console output**
4. **Easy debugging**

### **For Production:**
1. **Setup**: `python setup_autostart.py`
2. **Auto-starts** with Windows
3. **Always available**
4. **Remove with**: `python setup_autostart.py remove`

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
| **API Server** | http://127.0.0.1:8000 |
| **API Documentation** | http://127.0.0.1:8000/docs |
| **Health Check** | http://127.0.0.1:8000/health |

---

## 🛠️ **How It Works**

### **Auto-Start Process:**
1. **Folder Access** → Launcher activates
2. **System Check** → Python & packages verified
3. **Server Start** → Python backend launches
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
# Check Python installation
python --version

# Install required packages
pip install fastapi uvicorn sqlalchemy pymysql bcrypt requests

# Start manually
cd backend
python simple_login_server.py
```

### **❌ Login Not Working:**
```bash
# Reset passwords
cd backend
python password_reset_tool.py
```

### **❌ Port Already in Use:**
```bash
# Check what's using port 8000
netstat -ano | findstr :8000

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
├── START_FARMOS.py            # Python launcher
├── AUTO_START.bat             # Background launcher
├── setup_autostart.py         # Windows startup setup
├── backend/
│   ├── monitor_server.py      # Background monitor
│   ├── simple_login_server.py # Authentication server
│   └── auto_start.py          # Auto-start system
├── frontend/
│   ├── simple_auth.php        # PHP authentication
│   └── pages/login.php        # Login page
└── FARMOS_AUTO_START_GUIDE.md # This guide
```

---

## 🎉 **Benefits**

### ✅ **What You Get:**
- **Instant access** - No manual server start
- **Auto-recovery** - Server restarts if it crashes
- **Package management** - Auto-installs dependencies
- **Browser integration** - Opens automatically
- **Background operation** - Minimal disruption
- **Cross-platform** - Works on Windows/Mac/Linux

### ✅ **When It Activates:**
- **Folder access** → Server starts
- **Server crash** → Auto-restart
- **System reboot** → Auto-start (if configured)
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
- ✅ Server starts on port 8000
- ✅ Browser opens to FarmOS
- ✅ Login works with credentials
- ✅ Dashboard loads successfully
- ✅ All features accessible

### ✅ **Auto-Start Features:**
- ✅ Server starts automatically
- ✅ No manual intervention needed
- ✅ Auto-restart on crashes
- ✅ Background monitoring
- ✅ Clean shutdown process

---

## 🎉 **Ready to Use!**

**Your FarmOS system now has complete auto-start capability!**

**🚀 Just double-click `LAUNCH_FARMOS.bat` and start using FarmOS immediately!**

---

*Last Updated: 2026-02-12*
*Version: 1.0 - Auto-Start System*
