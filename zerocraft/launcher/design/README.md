# ZeroCraft icon

`zerocraft.svg` is the master artwork (256x256): obsidian disc, beveled gold ring with rivets,
molten Z blade, ruby at the base. It is used as the app icon (`src/icon.ico`, `src/icon.png`)
and the in-app emblem (`src/emblem.svg`).

To regenerate the .ico after editing the SVG (renders with the project's own Electron):

    cd C:\azerothcore\zc_launcher
    node_modules\.bin\electron.cmd design\render_icon.js
    copy /y design\zerocraft.ico src\icon.ico
    copy /y design\icon_256.png src\icon.png
    copy /y design\zerocraft.svg src\emblem.svg
    npm run build

Windows caches taskbar icons for pinned shortcuts; after changing the icon, unpin and re-pin
the launcher (or delete %LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*.db and restart Explorer).
