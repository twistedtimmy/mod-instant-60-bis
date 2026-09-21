@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > unlimited.log
docker exec -i ac-database mysql -uroot -ppassword < slots_fix.sql >> unlimited.log 2>&1
echo [%time%] Building... >> unlimited.log
docker compose build ac-worldserver >> unlimited.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> unlimited.log & exit /b 1)
docker compose up -d ac-worldserver >> unlimited.log 2>&1
echo [%time%] DONE >> unlimited.log
