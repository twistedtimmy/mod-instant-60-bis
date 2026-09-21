@echo off
cd /d C:\azerothcore
echo [%time%] Building... > drake.log
docker compose build ac-worldserver >> drake.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> drake.log & exit /b 1)
docker compose up -d ac-worldserver >> drake.log 2>&1
echo [%time%] DONE >> drake.log
