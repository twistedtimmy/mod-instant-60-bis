@echo off
cd /d C:\azerothcore
echo Running remove_friendly_npcs... > remove_friendly_npcs.log
docker exec -i ac-database mysql -uroot -ppassword < remove_friendly_npcs.sql >> remove_friendly_npcs.log 2>&1
docker restart ac-worldserver >> remove_friendly_npcs.log 2>&1
echo DONE >> remove_friendly_npcs.log
