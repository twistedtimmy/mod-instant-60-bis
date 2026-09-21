@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > services.log
docker exec -i ac-database mysql -uroot -ppassword < services.sql >> services.log 2>&1
echo [%time%] Building... >> services.log
docker compose build ac-worldserver >> services.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> services.log & exit /b 1)
docker compose up -d ac-worldserver >> services.log 2>&1
echo [%time%] DONE >> services.log
