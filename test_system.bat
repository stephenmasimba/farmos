@echo off
echo ========================================
echo FarmOS System Test & Configuration
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
echo Starting FarmOS Backend Server...
echo ========================================

REM Start backend server
cd /c/wamp64/www/farmos
start "FarmOS Backend" cmd /k "python start_backend.py"

REM Wait for backend to start
timeout /t 5 /nobreak >nul

echo.
echo ========================================
echo Testing FarmOS System...
echo ========================================

REM Test backend health
echo Testing backend health...
curl -s http://127.0.0.1:8000/health >nul 2>&1
if errorlevel 1 (
    echo ❌ Backend health check failed
    echo Backend server may not be running properly
) else (
    echo ✅ Backend health check passed
)

REM Test frontend access
echo.
echo Testing frontend access...
curl -s -I http://localhost:8081/farmos/begin_pyphp/frontend/public/ >nul 2>&1
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
echo    http://localhost:8081/farmos/begin_pyphp/frontend/public/
echo.
echo 🔧 Backend API:
echo    http://127.0.0.1:8000/
echo.
echo 📚 API Documentation:
echo    http://127.0.0.1:8000/docs
echo.
echo 📊 Dashboard Direct Link:
echo    http://localhost:8081/farmos/begin_pyphp/frontend/public/index.php?page=dashboard
echo.
echo 🔐 Login Page:
echo    http://localhost:8081/farmos/begin_pyphp/frontend/public/index.php?page=login
echo.

echo ========================================
echo Opening FarmOS in browser...
echo ========================================
start http://localhost:8081/farmos/begin_pyphp/frontend/public/

echo.
echo ✅ FarmOS system test complete!
echo.
echo Press any key to exit...
pause >nul
