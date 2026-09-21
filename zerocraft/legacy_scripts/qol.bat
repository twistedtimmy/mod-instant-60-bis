@echo off
cd /d C:\azerothcore
echo [%time%] Building... > qol.log
docker compose build ac-worldserver >> qol.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> qol.log & exit /b 1)
docker compose up -d ac-worldserver >> qol.log 2>&1
echo [%time%] DONE >> qol.log
