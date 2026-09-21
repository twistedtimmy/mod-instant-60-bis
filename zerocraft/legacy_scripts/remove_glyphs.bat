@echo off
cd /d C:\azerothcore
echo Removing glyphs... > remove_glyphs.log
docker exec -i ac-database mysql -uroot -ppassword < remove_glyphs.sql >> remove_glyphs.log 2>&1
docker restart ac-worldserver >> remove_glyphs.log 2>&1
echo DONE >> remove_glyphs.log
