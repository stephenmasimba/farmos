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
curl -s http://127.0.0.1:8001/health >nul 2>&1

if %errorlevel% equ 0 (
    echo.
    echo ✅ FarmOS server is already running!
    echo 🌐 Access at: http://localhost:8081/farmos/
    echo 🔧 API at: http://127.0.0.1:8001
    echo.
    echo 🔐 No default credentials are shipped.
    echo 💡 Create an admin user via your setup/seed process or use the registration endpoint.
    echo.
    pause
    exit /b
)

echo.
echo 🚀 Starting FarmOS server...
echo.

start "FarmOS PHP Backend" php -S 127.0.0.1:8001 -t public

if %errorlevel% neq 0 (
    echo.
    echo ❌ Failed to start FarmOS server
    echo 💡 Please check:
    echo    1. PHP is installed and in PATH
    echo    2. Database is running: MySQL service started
    echo.
    pause
)
