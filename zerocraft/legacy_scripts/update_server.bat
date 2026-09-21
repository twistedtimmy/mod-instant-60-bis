@echo off
cd /d C:\azerothcore
echo [%time%] Removing friendly NPCs... > update_server.log
docker exec -i ac-database mysql -uroot -ppassword < remove_friendly_npcs.sql >> update_server.log 2>&1
echo [%time%] Building worldserver (this can take a while)... >> update_server.log
docker compose build ac-worldserver >> update_server.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> update_server.log & exit /b 1)
echo [%time%] Starting new worldserver... >> update_server.log
docker compose up -d ac-worldserver >> update_server.log 2>&1
echo [%time%] DONE >> update_server.log
