@echo off
rem usage: clear_characters.bat [ACCOUNT]   (no account = delete ALL characters on the server)
cd /d C:\azerothcore
set ZCWHO=%~1
if "%ZCWHO%"=="" set ZCWHO=ALL
echo [%time%] Deleting characters for %ZCWHO%... > clear_characters.log
if /i "%ZCWHO%"=="ALL" docker exec -i ac-database mysql -uroot -ppassword < reset_deployables.sql >> clear_characters.log 2>&1
> env\dist\etc\clear_characters.flag echo %ZCWHO%
docker restart ac-worldserver >> clear_characters.log 2>&1
echo [%time%] DONE >> clear_characters.log
