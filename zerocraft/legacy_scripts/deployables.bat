@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > deployables.log
docker exec -i ac-database mysql -uroot -ppassword < deployables.sql >> deployables.log 2>&1
echo [%time%] Building... >> deployables.log
docker compose build ac-worldserver >> deployables.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> deployables.log & exit /b 1)
docker compose up -d ac-worldserver >> deployables.log 2>&1
echo [%time%] DONE >> deployables.log
