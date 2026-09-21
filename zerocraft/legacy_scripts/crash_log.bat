@echo off
cd /d C:\azerothcore
docker ps -a > crash.log 2>&1
docker logs --tail 60 ac-worldserver >> crash.log 2>&1
echo DONE >> crash.log
