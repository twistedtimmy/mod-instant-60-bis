-- ZeroCraft: built things remember their guild's NAME, so a re-founded guild (or a guild whose
-- characters were all deleted and remade) keeps its furniture and Summoning Stones.
USE acore_world;
SET @has = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'acore_world' AND table_name = 'zerocraft_placed' AND column_name = 'owner_guild_name');
SET @q = IF(@has = 0, 'ALTER TABLE zerocraft_placed ADD COLUMN owner_guild_name VARCHAR(64) NOT NULL DEFAULT ''''', 'SELECT 1');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
UPDATE zerocraft_placed p JOIN acore_characters.guild g ON g.guildid = p.owner_guild SET p.owner_guild_name = g.name WHERE p.owner_guild_name = '';
-- things placed by a deleted character in a starter guild: hand them to that starter guild by name
UPDATE zerocraft_placed p
LEFT JOIN acore_characters.guild g ON g.guildid = p.owner_guild
LEFT JOIN acore_characters.characters c ON c.guid = p.owner_player
LEFT JOIN acore_characters.zerocraft_rebels rb ON rb.guid = p.owner_player
SET p.owner_guild_name = 'the Rebels'
WHERE g.guildid IS NULL AND p.owner_guild_name = '' AND rb.guid IS NOT NULL;
SELECT COUNT(*) AS placed, SUM(owner_guild_name <> '') AS with_guild_name,
       SUM(owner_guild NOT IN (SELECT guildid FROM acore_characters.guild)) AS guild_gone FROM zerocraft_placed;
