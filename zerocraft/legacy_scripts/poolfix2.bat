@echo off
cd /d C:\azerothcore
echo [%time%] Building... > poolfix2.log
docker compose build ac-worldserver >> poolfix2.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> poolfix2.log & exit /b 1)
docker compose up -d ac-worldserver >> poolfix2.log 2>&1
echo [%time%] DONE >> poolfix2.log
