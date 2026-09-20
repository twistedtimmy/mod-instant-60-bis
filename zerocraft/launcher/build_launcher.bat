@echo off
title Building ZeroCraft Launcher
cd /d "%~dp0"
echo Installing (first time takes a few minutes)...
call npm install
if errorlevel 1 (echo. & echo npm install failed. Is Node.js installed? & pause & exit /b 1)
echo Building ZeroCraft Launcher.exe ...
call npm run build
if errorlevel 1 (echo. & echo Build failed - send Claude a screenshot. & pause & exit /b 1)
echo.
echo Done! Opening the launcher folder...
start "" "%~dp0dist\win-unpacked"
pause
