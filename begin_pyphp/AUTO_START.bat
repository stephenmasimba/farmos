@echo off
title FarmOS Auto-Start
color 0A

:: Hide the command window
if "%1"=="hidden" (
    goto start_hidden
)

:: Check if already running
tasklist /FI "WINDOWTITLE eq FarmOS Auto-Start*" 2>NUL | find /I "php.exe" >NUL
if %errorlevel% equ 0 (
    exit /b
)

:: Start hidden instance
start /MIN "" cmd /C "%~f0" hidden
exit /b

:start_hidden
cd /d "%~dp0"

cd backend
start "FarmOS PHP Backend" php -S 127.0.0.1:8001 -t public

exit
