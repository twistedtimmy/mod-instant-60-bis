@echo off
cd /d C:\azerothcore
docker exec -i ac-database mysql -uroot -ppassword < kit10.sql > kit10.log 2>&1
docker restart ac-worldserver >> kit10.log 2>&1
echo DONE >> kit10.log
