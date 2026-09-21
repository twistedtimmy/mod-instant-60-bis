@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > deploy_cast.log
docker exec -i ac-database mysql -uroot -ppassword < deploy_cast.sql >> deploy_cast.log 2>&1
echo [%time%] Building... >> deploy_cast.log
docker compose build ac-worldserver >> deploy_cast.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> deploy_cast.log & exit /b 1)
docker compose up -d ac-worldserver >> deploy_cast.log 2>&1
echo [%time%] DONE >> deploy_cast.log
