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

:: Check if server is already running
echo 🔍 Checking if FarmOS server is running...
curl -s http://127.0.0.1:8001/health >nul 2>&1
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

start "FarmOS PHP Backend" php -S 127.0.0.1:8001 -t public

:: Wait for server to start
echo ⏳ Waiting for server to start...
timeout /t 5 /nobreak >nul

:: Check if server started successfully
curl -s http://127.0.0.1:8001/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Server started!
) else (
    echo ❌ Server failed to start
)

echo.
echo 🌐 Opening FarmOS in browser...
start http://localhost:8081/farmos/

echo.
echo ✅ FarmOS is running!
echo 📍 Server: http://127.0.0.1:8001
echo 🌐 Web Interface: http://localhost:8081/farmos/
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
