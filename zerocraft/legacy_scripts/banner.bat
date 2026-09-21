@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > banner.log
docker exec -i ac-database mysql -uroot -ppassword < banner.sql >> banner.log 2>&1
echo [%time%] Building... >> banner.log
docker compose build ac-worldserver >> banner.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> banner.log & exit /b 1)
docker compose up -d ac-worldserver >> banner.log 2>&1
echo [%time%] DONE >> banner.log
