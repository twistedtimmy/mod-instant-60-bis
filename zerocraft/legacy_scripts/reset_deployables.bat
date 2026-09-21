@echo off
cd /d C:\azerothcore
docker exec -i ac-database mysql -uroot -ppassword < reset_deployables.sql > reset_deployables.log 2>&1
docker restart ac-worldserver >> reset_deployables.log 2>&1
echo DONE >> reset_deployables.log
