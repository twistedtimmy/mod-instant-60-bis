@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > poolfix.log
docker exec -i ac-database mysql -uroot -ppassword < pool_check.sql >> poolfix.log 2>&1
echo [%time%] Building... >> poolfix.log
docker compose build ac-worldserver >> poolfix.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> poolfix.log & exit /b 1)
docker compose up -d ac-worldserver >> poolfix.log 2>&1
echo [%time%] DONE >> poolfix.log
