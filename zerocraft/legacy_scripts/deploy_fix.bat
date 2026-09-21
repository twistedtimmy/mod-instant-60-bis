@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > deploy_fix.log
docker exec -i ac-database mysql -uroot -ppassword < deploy_fix.sql >> deploy_fix.log 2>&1
echo [%time%] Building... >> deploy_fix.log
docker compose build ac-worldserver >> deploy_fix.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> deploy_fix.log & exit /b 1)
docker compose up -d ac-worldserver >> deploy_fix.log 2>&1
echo [%time%] DONE >> deploy_fix.log
