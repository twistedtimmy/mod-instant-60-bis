@echo off
cd /d C:\azerothcore
echo [%time%] Restoring original talents... > revert_talents.log
docker run --rm --user root --entrypoint sh -v azerothcore_ac-client-data:/data acore/ac-wotlk-worldserver:master -c "cp /data/dbc/Talent.dbc.orig /data/dbc/Talent.dbc && ls -la /data/dbc/Talent.dbc*" >> revert_talents.log 2>&1
docker exec -i ac-database mysql -uroot -ppassword -e "UPDATE acore_characters.characters SET at_login = at_login | 4 WHERE class = 8;" >> revert_talents.log 2>&1
docker restart ac-worldserver >> revert_talents.log 2>&1
echo [%time%] DONE >> revert_talents.log
