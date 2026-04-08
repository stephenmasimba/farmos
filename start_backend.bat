@echo off
echo ========================================
echo Begin Masimba FarmOS Backend Startup
echo ========================================
echo.

REM FarmOS backend is Pure PHP and runs via Apache/WAMP.
REM This script validates prerequisites and checks backend health.

echo Checking WAMP Apache process...
tasklist | find "wampapache.exe" >nul
if errorlevel 1 (
    echo ERROR: WAMP Apache is not running.
    echo Start WAMP server first, then rerun this script.
    pause
    exit /b 1
)

echo Checking WAMP MySQL process...
tasklist | find "wampmysqld.exe" >nul
if errorlevel 1 (
    echo ERROR: WAMP MySQL is not running.
    echo Start WAMP server first, then rerun this script.
    pause
    exit /b 1
)

echo.
echo Testing backend health endpoint...
curl -s http://localhost:8081/farmos/app/backend/health >nul 2>&1
if errorlevel 1 (
    echo ERROR: Backend health check failed.
    echo Expected URL: http://localhost:8081/farmos/app/backend/health
    echo Verify Apache port 8081 and vhost/alias configuration.
    pause
    exit /b 1
)

echo.
echo Backend is healthy and reachable.
echo Backend API base: http://localhost:8081/farmos/app/backend
echo Frontend URL:    http://localhost:8081/farmos/app/frontend/public/

pause
