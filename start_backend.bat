@echo off
echo ========================================
echo Begin Masimba FarmOS Backend Startup
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

REM Check if required packages are installed
echo Checking Python packages...
python -c "import fastapi, uvicorn, sqlalchemy, pydantic_settings, dotenv" 2>nul
if errorlevel 1 (
    echo Installing required packages...
    pip install fastapi uvicorn sqlalchemy pymysql pydantic-settings python-dotenv
    if errorlevel 1 (
        echo ERROR: Failed to install required packages
        pause
        exit /b 1
    )
)

REM Start the backend server
echo.
echo Starting backend server...
echo Server will be available at: http://127.0.0.1:8000
echo API docs at: http://127.0.0.1:8000/docs
echo.
echo Press Ctrl+C to stop the server
echo.

python start_backend.py

pause
