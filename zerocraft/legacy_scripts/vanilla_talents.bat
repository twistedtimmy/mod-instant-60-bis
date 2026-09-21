@echo off
cd /d C:\azerothcore
echo [%time%] Installing talent data on server... > vanilla_talents.log
docker run --rm --user root --entrypoint sh -v azerothcore_ac-client-data:/data -v C:\azerothcore\zc_dbc:/src acore/ac-wotlk-worldserver:master -c "[ -f /data/dbc/Talent.dbc.orig ] || cp /data/dbc/Talent.dbc /data/dbc/Talent.dbc.orig; cp /src/out/Talent.dbc /data/dbc/Talent.dbc; ls -la /data/dbc/Talent.dbc*" >> vanilla_talents.log 2>&1
docker exec -i ac-database mysql -uroot -ppassword < zc_dbc\reset_mage_talents.sql >> vanilla_talents.log 2>&1
docker restart ac-worldserver >> vanilla_talents.log 2>&1
echo [%time%] DONE >> vanilla_talents.log
