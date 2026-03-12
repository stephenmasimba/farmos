@echo off
echo ========================================
echo FarmOS Enhanced System Startup
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ and add it to PATH
    pause
    exit /b 1
)

REM Check if WAMP is running
echo Checking WAMP server status...
tasklist | find "wampapache.exe" >nul
if errorlevel 1 (
    echo ❌ WAMP Apache is not running
    echo Starting WAMP Apache...
    net start wampapache
    timeout /t 3 /nobreak >nul
) else (
    echo ✅ WAMP Apache is running
)

tasklist | find "wampmysqld.exe" >nul
if errorlevel 1 (
    echo ❌ WAMP MySQL is not running
    echo Starting WAMP MySQL...
    net start wampmysqld
    timeout /t 3 /nobreak >nul
) else (
    echo ✅ WAMP MySQL is running
)

echo.
echo ========================================
echo Installing Python Dependencies...
echo ========================================

REM Install required packages
echo Installing FastAPI and dependencies...
pip install fastapi uvicorn sqlalchemy pymysql pydantic-settings python-dotenv

echo Installing WebSocket dependencies...
pip install websockets

echo Installing Redis and background job dependencies...
pip install redis celery apscheduler

echo Installing additional dependencies...
pip install requests

echo.
echo ========================================
echo Starting FarmOS Enhanced System...
echo ========================================

REM Change to project directory
cd /c/wamp64/www/farmos

REM Start enhanced system
python start_enhanced_system.py

echo.
echo ========================================
echo FarmOS System Status
echo ========================================

REM Wait for servers to start
timeout /t 10 /nobreak >nul

echo.
echo Testing system components...

REM Test FastAPI server
curl -s http://127.0.0.1:8000/health >nul 2>&1
if errorlevel 1 (
    echo ❌ FastAPI server not responding
) else (
    echo ✅ FastAPI server running
)

REM Test WebSocket server
curl -s -I http://127.0.0.1:8001 >nul 2>&1
if errorlevel 1 (
    echo ❌ WebSocket server not responding
) else (
    echo ✅ WebSocket server running
)

REM Test frontend access
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
echo 🌐 Main Application:
echo    http://localhost:8081/farmos/begin_pyphp/frontend/public/
echo.
echo 🔧 Backend API:
echo    http://127.0.0.1:8000/
echo.
echo 📚 API Documentation:
echo    http://127.0.0.1:8000/docs
echo.
echo 🌐 WebSocket Endpoint:
echo    ws://127.0.0.1:8001/ws/
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
echo ✅ FarmOS Enhanced System startup complete!
echo.
echo 📝 System Features:
echo    ✅ Real-time WebSocket updates
echo    ✅ Enhanced API with rate limiting
echo    ✅ Redis caching (if available)
echo    ✅ Background job processing
echo    ✅ Improved error handling
echo    ✅ Mobile PWA support
echo.
echo Press any key to exit...
pause >nul
