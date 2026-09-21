@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > slots_fix.log
docker exec -i ac-database mysql -uroot -ppassword < slots_fix.sql >> slots_fix.log 2>&1
echo [%time%] Building... >> slots_fix.log
docker compose build ac-worldserver >> slots_fix.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> slots_fix.log & exit /b 1)
docker compose up -d ac-worldserver >> slots_fix.log 2>&1
echo [%time%] DONE >> slots_fix.log
