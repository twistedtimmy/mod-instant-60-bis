@echo off
cd /d C:\azerothcore
echo [%time%] Building... > crashfix.log
docker compose build ac-worldserver >> crashfix.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> crashfix.log & exit /b 1)
docker compose up -d ac-worldserver >> crashfix.log 2>&1
echo [%time%] DONE >> crashfix.log
