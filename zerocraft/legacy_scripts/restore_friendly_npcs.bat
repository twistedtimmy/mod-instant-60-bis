@echo off
cd /d C:\azerothcore
echo Running restore_friendly_npcs... > restore_friendly_npcs.log
docker exec -i ac-database mysql -uroot -ppassword < restore_friendly_npcs.sql >> restore_friendly_npcs.log 2>&1
docker restart ac-worldserver >> restore_friendly_npcs.log 2>&1
echo DONE >> restore_friendly_npcs.log
