@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > fastdeploy.log
docker exec -i ac-database mysql -uroot -ppassword < fastdeploy.sql >> fastdeploy.log 2>&1
echo [%time%] Building... >> fastdeploy.log
docker compose build ac-worldserver >> fastdeploy.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> fastdeploy.log & exit /b 1)
docker compose up -d ac-worldserver >> fastdeploy.log 2>&1
echo [%time%] DONE >> fastdeploy.log
