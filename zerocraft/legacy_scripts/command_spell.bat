@echo off
cd /d C:\azerothcore
echo [%time%] SQL... > command_spell.log
docker exec -i ac-database mysql -uroot -ppassword < command_spell.sql >> command_spell.log 2>&1
echo [%time%] Building... >> command_spell.log
docker compose build ac-worldserver >> command_spell.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> command_spell.log & exit /b 1)
docker compose up -d ac-worldserver >> command_spell.log 2>&1
echo [%time%] DONE >> command_spell.log
