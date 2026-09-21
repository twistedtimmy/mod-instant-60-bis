@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > instances.log
docker exec -i ac-database mysql -uroot -ppassword < services.sql >> instances.log 2>&1
docker exec -i ac-database mysql -uroot -ppassword < instance_loot.sql >> instances.log 2>&1
echo [%time%] Building... >> instances.log
docker compose build ac-worldserver >> instances.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> instances.log & exit /b 1)
docker compose up -d ac-worldserver >> instances.log 2>&1
echo [%time%] DONE >> instances.log
