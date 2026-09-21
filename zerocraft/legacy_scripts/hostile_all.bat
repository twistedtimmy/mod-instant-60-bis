@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > hostile_all.log
docker exec -i ac-database mysql -uroot -ppassword < hostile_all.sql >> hostile_all.log 2>&1
echo [%time%] Building... >> hostile_all.log
docker compose build ac-worldserver >> hostile_all.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> hostile_all.log & exit /b 1)
docker compose up -d ac-worldserver >> hostile_all.log 2>&1
echo [%time%] DONE >> hostile_all.log
