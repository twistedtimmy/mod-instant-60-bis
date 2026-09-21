@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > banner2.log
docker exec -i ac-database mysql -uroot -ppassword < banner2.sql >> banner2.log 2>&1
echo [%time%] Building... >> banner2.log
docker compose build ac-worldserver >> banner2.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> banner2.log & exit /b 1)
docker compose up -d ac-worldserver >> banner2.log 2>&1
echo [%time%] DONE >> banner2.log
