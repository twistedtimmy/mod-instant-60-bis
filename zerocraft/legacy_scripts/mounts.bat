@echo off
cd /d C:\azerothcore
echo [%time%] Building... > mounts.log
docker compose build ac-worldserver >> mounts.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> mounts.log & exit /b 1)
docker compose up -d ac-worldserver >> mounts.log 2>&1
echo [%time%] DONE >> mounts.log
