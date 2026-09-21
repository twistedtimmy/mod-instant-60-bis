@echo off
cd /d C:\azerothcore
echo [%time%] Building... > deathfix.log
docker compose build ac-worldserver >> deathfix.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> deathfix.log & exit /b 1)
docker compose up -d ac-worldserver >> deathfix.log 2>&1
echo [%time%] DONE >> deathfix.log
