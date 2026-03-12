@echo off
title FarmOS Launcher
color 0A

:: FarmOS ASCII Art
echo.
echo  ████████╗ █████╗ ███╗   ██╗██╗  ██╗    ██████╗ ███████╗ █████╗ ████████╗
echo  ╚══██╔══╝██╔══██╗████╗  ██║██║ ██╔╝    ██╔════╝ ██╔════╝██╔══██╗╚══██╔══╝
echo     ██║   ███████║██╔██╗ ██║█████╔╝     ██║      █████╗  ███████║   ██║   
echo     ██║   ██╔══██║██║╚██╗██║██╔═██╗     ██║      ██╔══╝  ██╔══██║   ██║   
echo     ██║   ██║  ██║██║ ╚████║██║  ██╗     ╚██████╗ ███████╗██║  ██║   ██║   
echo     ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   
echo.
echo  🌟 Smart Agriculture Platform
echo  ================================
echo.

cd /d "%~dp0backend"

echo 🔍 Checking system requirements...

:: Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not found! Please install Python first.
    echo 📥 Download from: https://python.org
    pause
    exit /b 1
)

:: Check required packages
echo 📦 Checking required packages...
python -c "import fastapi, uvicorn, sqlalchemy, pymysql, bcrypt, requests" 2>nul
if %errorlevel% neq 0 (
    echo 📦 Installing required packages...
    pip install fastapi uvicorn sqlalchemy pymysql bcrypt requests
    if %errorlevel% neq 0 (
        echo ❌ Failed to install packages!
        pause
        exit /b 1
    )
)

:: Check if server is already running
echo 🔍 Checking if FarmOS server is running...
python -c "import requests; requests.get('http://127.0.0.1:8000/health', timeout=2)" 2>nul
if %errorlevel% equ 0 (
    echo ✅ FarmOS server is already running!
    echo 🌐 Opening FarmOS...
    start http://localhost:8081/farmos/
    echo.
    echo 📋 Login Credentials:
    echo 📧 Admin: admin@masimba.farm / admin123
    echo 👨‍🌾 Manager: manager@masimba.farm / manager123
    echo 👷 Worker: worker@masimba.farm / worker123
    echo.
    echo 💡 FarmOS is ready! Close this window to keep server running.
    pause
    exit /b 0
)

echo.
echo 🚀 Starting FarmOS server...
echo.

:: Start the server monitor
start /B python monitor_server.py

:: Wait for server to start
echo ⏳ Waiting for server to start...
timeout /t 5 /nobreak >nul

:: Check if server started successfully
python -c "import requests; print('✅ Server started!' if requests.get('http://127.0.0.1:8000/health', timeout=2).status_code == 200 else '❌ Server failed to start')" 2>nul

echo.
echo 🌐 Opening FarmOS in browser...
start http://localhost:8081/farmos/

echo.
echo ✅ FarmOS is running!
echo 📍 Server: http://127.0.0.1:8000
echo 🌐 Web Interface: http://localhost:8081/farmos/
echo 📚 API Docs: http://127.0.0.1:8000/docs
echo.
echo 📋 Login Credentials:
echo 📧 Admin: admin@masimba.farm / admin123
echo 👨‍🌾 Manager: manager@masimba.farm / manager123
echo 👷 Worker: worker@masimba.farm / worker123
echo.
echo 💡 Keep this window open to keep FarmOS running
echo 🔄 Server will auto-restart if it stops
echo ⏹️  Close this window to stop FarmOS server
echo.

:: Keep the window open
:loop
timeout /t 60 /nobreak >nul
goto loop
