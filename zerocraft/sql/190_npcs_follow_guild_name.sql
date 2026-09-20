-- ZeroCraft: deployed NPCs remember their guild's NAME, so a re-founded guild of the same name gets them back
USE acore_world;
SET @has := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'acore_world' AND TABLE_NAME = 'zerocraft_deployables' AND COLUMN_NAME = 'owner_guild_name');
SET @sql := IF(@has = 0, 'ALTER TABLE zerocraft_deployables ADD COLUMN owner_guild_name VARCHAR(24) NOT NULL DEFAULT ''''', 'SELECT 1');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- guilds that still exist
UPDATE zerocraft_deployables d JOIN acore_characters.guild g ON g.guildid = d.owner_guild
SET d.owner_guild_name = g.name WHERE d.owner_guild_name = '';

-- orphans whose guild is already gone: Theramore -> the Rebels, Menethil -> the Pirates
UPDATE zerocraft_deployables d JOIN creature c ON c.guid = d.spawn_id
SET d.owner_guild_name = 'the Rebels'
WHERE d.owner_guild_name = '' AND c.map = 1 AND c.position_x BETWEEN -4100 AND -3400 AND c.position_y BETWEEN -4800 AND -4100;
UPDATE zerocraft_deployables d JOIN creature c ON c.guid = d.spawn_id
SET d.owner_guild_name = 'the Pirates'
WHERE d.owner_guild_name = '' AND c.map = 0 AND c.position_x BETWEEN -4100 AND -3500 AND c.position_y BETWEEN -1100 AND -400;

SELECT owner_guild_name, owner_guild, (owner_guild IN (SELECT guildid FROM acore_characters.guild)) AS guild_exists, COUNT(*) AS npcs
FROM zerocraft_deployables GROUP BY owner_guild_name, owner_guild;
