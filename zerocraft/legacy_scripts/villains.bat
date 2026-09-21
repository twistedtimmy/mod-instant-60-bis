@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > villains.log
docker exec -i ac-database mysql -uroot -ppassword < villains.sql >> villains.log 2>&1
echo [%time%] Building... >> villains.log
docker compose build ac-worldserver >> villains.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> villains.log & exit /b 1)
docker compose up -d ac-worldserver >> villains.log 2>&1
echo [%time%] DONE >> villains.log
