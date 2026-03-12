@echo off
title FarmOS Auto-Start System
color 0A

echo.
echo  ████████╗ █████╗ ███╗   ██╗██╗  ██╗    ██████╗ ███████╗ █████╗ ████████╗
echo  ╚══██╔══╝██╔══██╗████╗  ██║██║ ██╔╝    ██╔════╝ ██╔════╝██╔══██╗╚══██╔══╝
echo     ██║   ███████║██╔██╗ ██║█████╔╝     ██║      █████╗  ███████║   ██║   
echo     ██║   ██╔══██║██║╚██╗██║██╔═██╗     ██║      ██╔══╝  ██╔══██║   ██║   
echo     ██║   ██║  ██║██║ ╚████║██║  ██╗     ╚██████╗ ███████╗██║  ██║   ██║   
echo     ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   
echo.
echo  🌟 Smart Agriculture Platform - Auto-Start System
echo  ========================================================
echo.

cd /d "%~dp0backend"

echo 🔍 Checking if FarmOS server is already running...
python -c "import requests; print('✅ Running' if requests.get('http://127.0.0.1:8000/health', timeout=2).status_code == 200 else '❌ Stopped')" 2>nul

if %errorlevel% equ 0 (
    echo.
    echo ✅ FarmOS server is already running!
    echo 🌐 Access at: http://localhost:8081/farmos/
    echo 🔧 API at: http://127.0.0.1:8000
    echo.
    echo 📋 Login Credentials:
    echo 📧 Admin: admin@masimba.farm / admin123
    echo 👨‍🌾 Manager: manager@masimba.farm / manager123
    echo 👷 Worker: worker@masimba.farm / worker123
    echo.
    pause
    exit /b
)

echo.
echo 🚀 Starting FarmOS server...
echo.

python auto_start.py

if %errorlevel% neq 0 (
    echo.
    echo ❌ Failed to start FarmOS server
    echo 💡 Please check:
    echo    1. Python is installed and in PATH
    echo    2. Required packages are installed: pip install fastapi uvicorn sqlalchemy pymysql bcrypt requests
    echo    3. Database is running: MySQL service started
    echo.
    pause
)
