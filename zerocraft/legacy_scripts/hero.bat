@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > hero.log
docker exec -i ac-database mysql -uroot -ppassword < hero.sql >> hero.log 2>&1
echo [%time%] Building... >> hero.log
docker compose build ac-worldserver >> hero.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> hero.log & exit /b 1)
docker compose up -d ac-worldserver >> hero.log 2>&1
echo [%time%] DONE >> hero.log
