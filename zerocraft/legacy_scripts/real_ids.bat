@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > real_ids.log
docker exec -i ac-database mysql -uroot -ppassword < real_ids.sql >> real_ids.log 2>&1
echo [%time%] Building... >> real_ids.log
docker compose build ac-worldserver >> real_ids.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> real_ids.log & exit /b 1)
docker compose up -d ac-worldserver >> real_ids.log 2>&1
echo [%time%] DONE >> real_ids.log
