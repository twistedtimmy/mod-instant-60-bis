@echo off
cd /d C:\azerothcore
docker exec -i ac-database mysql -uroot -ppassword < banner_mounted.sql > banner_mounted.log 2>&1
docker restart ac-worldserver >> banner_mounted.log 2>&1
echo DONE >> banner_mounted.log
