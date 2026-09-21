@echo off
cd /d C:\azerothcore
echo [%time%] Building... > orders.log
docker compose build ac-worldserver >> orders.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> orders.log & exit /b 1)
docker compose up -d ac-worldserver >> orders.log 2>&1
echo [%time%] DONE >> orders.log
