@echo off
rem ZeroCraft: restore the databases from a backup folder made by backup_db.bat
rem Usage: restore_db.bat backups\2026-09-20_0300   (no argument = newest backup)
rem This REPLACES the live databases. Stop the worldserver first.
setlocal
cd /d C:\azerothcore
set SRC=%~1
if "%SRC%"=="" for /f "delims=" %%F in ('dir /b /ad /o-n backups') do if not defined SRC set SRC=backups\%%F
if not exist "%SRC%\acore_world.sql.gz" (echo No backup found at "%SRC%" & exit /b 1)
echo This will REPLACE acore_auth, acore_characters and acore_world with %SRC%.
set /p OK=Type YES to continue: 
if /i not "%OK%"=="YES" (echo Cancelled. & exit /b 1)
docker stop ac-worldserver ac-authserver >nul 2>&1
for %%D in (acore_auth acore_characters acore_world) do (
  echo   restoring %%D ...
  docker exec -i ac-database sh -c "gunzip -c | mysql -uroot -ppassword %%D 2>/dev/null" < "%SRC%\%%D.sql.gz"
  if errorlevel 1 (echo   FAILED on %%D & exit /b 1)
)
docker start ac-authserver ac-worldserver >nul 2>&1
echo Done. The server is coming back up.
endlocal
