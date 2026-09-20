-- ZeroCraft: finish tidying NPC ownership
USE acore_world;
-- an old guild's NPCs all share one name: copy it to the ones the location guess missed
UPDATE zerocraft_deployables d
JOIN (SELECT owner_guild, MAX(owner_guild_name) AS n FROM zerocraft_deployables WHERE owner_guild > 0 AND owner_guild_name <> '' GROUP BY owner_guild) x
  ON x.owner_guild = d.owner_guild
SET d.owner_guild_name = x.n WHERE d.owner_guild_name = '';
-- NPCs deployed before guilds existed: if the character still exists, they join that character's guild
UPDATE zerocraft_deployables d
JOIN acore_characters.guild_member gm ON gm.guid = d.owner_player
JOIN acore_characters.guild g ON g.guildid = gm.guildid
SET d.owner_guild_name = g.name
WHERE d.owner_guild = 0 AND d.owner_guild_name = '';
SELECT owner_guild_name, owner_guild, COUNT(*) AS npcs FROM zerocraft_deployables GROUP BY owner_guild_name, owner_guild;
