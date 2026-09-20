@echo off
cd /d C:\azerothcore
echo [%time%] ZeroCraft update > update.log
if exist "C:\Games\WoW335\ChromieCraft_3.3.5a\Data\patch-Y.new" move /y "C:\Games\WoW335\ChromieCraft_3.3.5a\Data\patch-Y.new" "C:\Games\WoW335\ChromieCraft_3.3.5a\Data\patch-Y.MPQ" >> update.log 2>&1
docker logs --tail 3000 ac-worldserver > last_server_log.txt 2>&1
for %%f in (zc_pending\*.sql) do (
  echo --- applying %%~nxf >> update.log
  docker exec -i ac-database mysql -uroot -ppassword < "%%f" >> update.log 2>&1
  move /y "%%f" zc_applied\ >nul
)
echo [%time%] Building... >> update.log
docker compose build ac-worldserver >> update.log 2>&1
if errorlevel 1 (echo BUILD FAILED >> update.log & type update.log >> update_history.log & exit /b 1)
docker compose up -d ac-worldserver >> update.log 2>&1
docker restart ac-worldserver >> update.log 2>&1
if exist zc_pending\build_launcher.flag (
  echo [%time%] Building ZeroCraft Launcher... >> update.log
  taskkill /f /im "ZeroCraft Launcher.exe" >nul 2>&1
  timeout /t 2 /nobreak >nul
  pushd zc_launcher
  call npm install >> ..\update.log 2>&1
  call npm run build >> ..\update.log 2>&1
  if errorlevel 1 (echo LAUNCHER BUILD FAILED >> ..\update.log) else (echo Launcher built: zc_launcher\dist\win-unpacked\ZeroCraft Launcher.exe >> ..\update.log & del ..\zc_pending\build_launcher.flag)
  popd
)
echo [%time%] DONE >> update.log
type update.log >> update_history.log
