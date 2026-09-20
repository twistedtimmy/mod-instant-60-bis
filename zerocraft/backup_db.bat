@echo off
rem ZeroCraft: dump all three databases (auth, characters, world) to backups\<date_time>\
rem The world DB holds every custom item, NPC and spawn - this is the only copy outside Docker.
setlocal
cd /d C:\azerothcore
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmm"') do set TS=%%i
set OUT=backups\%TS%
mkdir "%OUT%" 2>nul
echo [%time%] ZeroCraft database backup -^> %OUT%
docker inspect -f "{{.State.Running}}" ac-database 2>nul | findstr true >nul || (echo ac-database is not running - start Docker first. & exit /b 1)
for %%D in (acore_auth acore_characters acore_world) do (
  echo   dumping %%D ...
  docker exec ac-database sh -c "mysqldump -uroot -ppassword --single-transaction --quick --routines --triggers --events %%D 2>/dev/null | gzip -c" > "%OUT%\%%D.sql.gz"
  if errorlevel 1 (echo   FAILED on %%D & exit /b 1)
)
rem the custom character tables and account list, readable without unzipping
docker exec ac-database mysql -uroot -ppassword -N -e "SELECT username FROM acore_auth.account" 2>nul > "%OUT%\accounts.txt"
docker exec ac-database mysql -uroot -ppassword -N -e "SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema='acore_characters' AND table_name LIKE 'zerocraft%%'" 2>nul > "%OUT%\custom_tables.txt"
rem keep the newest 10 backups
for /f "skip=10 delims=" %%F in ('dir /b /ad /o-n backups') do rd /s /q "backups\%%F"
echo [%time%] Done. Backups:
dir /b /ad /o-n backups
for %%F in ("%OUT%\*.gz") do echo   %%~nxF  %%~zF bytes
endlocal
