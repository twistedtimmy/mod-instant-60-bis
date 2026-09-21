@echo off
cd /d C:\azerothcore
echo [%time%] Building... > squad.log
docker compose build ac-worldserver >> squad.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> squad.log & exit /b 1)
docker compose up -d ac-worldserver >> squad.log 2>&1
echo [%time%] DONE >> squad.log
