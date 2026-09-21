@echo off
cd /d C:\azerothcore
for %%f in (Talent TalentTab Spell SkillLineAbility ChrClasses) do docker cp ac-worldserver:/azerothcore/env/dist/data/dbc/%%f.dbc zc_dbc\%%f.dbc >> zc_dbc\export.log 2>&1
dir zc_dbc >> zc_dbc\export.log
docker volume ls >> zc_dbc\export.log
echo DONE >> zc_dbc\export.log
