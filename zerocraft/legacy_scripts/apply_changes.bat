@echo off
cd /d C:\azerothcore
echo Running... > apply_changes.log
docker exec -i ac-database mysql -uroot -ppassword < remove_friendly_npcs.sql >> apply_changes.log 2>&1
docker exec -i ac-database mysql -uroot -ppassword < remove_attunements.sql >> apply_changes.log 2>&1
docker restart ac-worldserver >> apply_changes.log 2>&1
echo DONE >> apply_changes.log
