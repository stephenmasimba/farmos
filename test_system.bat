@echo off
echo ========================================
echo FarmOS System Test ^& Configuration
echo ========================================
echo.

REM Check if WAMP is running
echo Checking WAMP server status...
tasklist | find "wampapache.exe" >nul
if errorlevel 1 (
    echo ❌ WAMP Apache is not running
    echo Please start WAMP server first
    pause
    exit /b 1
) else (
    echo ✅ WAMP Apache is running
)

tasklist | find "wampmysqld.exe" >nul
if errorlevel 1 (
    echo ❌ WAMP MySQL is not running
    echo Please start WAMP MySQL first
    pause
    exit /b 1
) else (
    echo ✅ WAMP MySQL is running
)

echo.
echo ========================================
echo Validating FarmOS Backend...
echo ========================================

REM Backend runs under Apache/WAMP via app/backend

echo.
echo ========================================
echo Testing FarmOS System...
echo ========================================

REM Test backend health
echo Testing backend health...
curl -s http://localhost:8081/farmos/app/backend/health >nul 2>&1
if errorlevel 1 (
    echo ❌ Backend health check failed
    echo Expected URL: http://localhost:8081/farmos/app/backend/health
) else (
    echo ✅ Backend health check passed
)

REM Test frontend access
echo.
echo Testing frontend access...
curl -s -I http://localhost:8081/farmos/app/frontend/public/ >nul 2>&1
if errorlevel 1 (
    echo ❌ Frontend not accessible at port 8081
    echo Please check Apache configuration
) else (
    echo ✅ Frontend accessible at port 8081
)

echo.
echo ========================================
echo FarmOS System URLs
echo ========================================
echo.
echo 🌐 Frontend (Main Application):
echo    http://localhost:8081/farmos/app/frontend/public/
echo.
echo 🔧 Backend API:
echo    http://localhost:8081/farmos/app/backend/
echo.
echo 📊 Dashboard Direct Link:
echo    http://localhost:8081/farmos/app/frontend/public/index.php?page=dashboard
echo.
echo 🔐 Login Page:
echo    http://localhost:8081/farmos/app/frontend/public/index.php?page=login
echo.

echo ========================================
echo Opening FarmOS in browser...
echo ========================================
start http://localhost:8081/farmos/app/frontend/public/

echo.
echo ✅ FarmOS system test complete!
echo.
echo Press any key to exit...
pause >nul
