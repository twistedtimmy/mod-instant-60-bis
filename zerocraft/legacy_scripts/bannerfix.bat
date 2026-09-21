@echo off
cd /d C:\azerothcore
echo [%time%] Building... > bannerfix.log
docker compose build ac-worldserver >> bannerfix.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> bannerfix.log & exit /b 1)
docker compose up -d ac-worldserver >> bannerfix.log 2>&1
echo [%time%] DONE >> bannerfix.log
