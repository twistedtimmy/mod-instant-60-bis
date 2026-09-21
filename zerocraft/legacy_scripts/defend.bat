@echo off
cd /d C:\azerothcore
echo [%time%] Building... > defend.log
docker compose build ac-worldserver >> defend.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> defend.log & exit /b 1)
docker compose up -d ac-worldserver >> defend.log 2>&1
echo [%time%] DONE >> defend.log
