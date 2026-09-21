# Database backup (2026-09-20 18:12)

Full mysqldump of the ZeroCraft server databases, gzip-compressed:

- `acore_world.sql.gz` – world DB (every ZeroCraft placement, custom items 23656/28099/23701/6777, gameobjects 911300/911301, waypoints, game_tele)
- `acore_characters.sql.gz` – characters, inventories, guilds
- `custom_tables.txt` – plain-text summary written by `backup_db.bat`

No auth dump is kept here: it holds account password hashes and this repo is public. Accounts live in the
Docker volume `azerothcore_ac-database` and can be recreated with `.account create`.

Restore into a fresh AzerothCore Docker stack (mysql root/password) with `zerocraft/restore_db.bat <folder>`
or by hand:

    gunzip -c acore_world.sql.gz | docker exec -i ac-database mysql -uroot -ppassword acore_world
