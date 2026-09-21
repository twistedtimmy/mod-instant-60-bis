@echo off
cd /d C:\azerothcore
echo [%time%] Building... > hostile2.log
docker compose build ac-worldserver >> hostile2.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> hostile2.log & exit /b 1)
docker compose up -d ac-worldserver >> hostile2.log 2>&1
echo [%time%] DONE >> hostile2.log
