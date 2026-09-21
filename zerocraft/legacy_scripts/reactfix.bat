@echo off
cd /d C:\azerothcore
echo [%time%] Building... > reactfix.log
docker compose build ac-worldserver >> reactfix.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> reactfix.log & exit /b 1)
docker compose up -d ac-worldserver >> reactfix.log 2>&1
echo [%time%] DONE >> reactfix.log
