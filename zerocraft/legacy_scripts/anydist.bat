@echo off
cd /d C:\azerothcore
echo [%time%] Building... > anydist.log
docker compose build ac-worldserver >> anydist.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> anydist.log & exit /b 1)
docker compose up -d ac-worldserver >> anydist.log 2>&1
echo [%time%] DONE >> anydist.log
