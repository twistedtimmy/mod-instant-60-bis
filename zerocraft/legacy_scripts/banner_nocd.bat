@echo off
cd /d C:\azerothcore
docker exec -i ac-database mysql -uroot -ppassword < banner_nocd.sql > banner_nocd.log 2>&1
docker restart ac-worldserver >> banner_nocd.log 2>&1
echo DONE >> banner_nocd.log
