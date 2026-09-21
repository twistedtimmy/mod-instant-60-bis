USE acore_world;
-- 15th loyalty slot
INSERT IGNORE INTO zerocraft_faction_slots (faction_template) VALUES (1234);
DELETE FROM factiontemplate_dbc WHERE ID = 1234;
INSERT INTO factiontemplate_dbc (ID, Faction, Flags, FactionGroup, FriendGroup, EnemyGroup, Enemies_1, Enemies_2, Enemies_3, Enemies_4, Friend_1, Friend_2, Friend_3, Friend_4) VALUES (1234,750,0,8,0,9,0,0,0,0,750,0,0,0);
-- free slots held by owners with no deployed NPCs left
UPDATE zerocraft_faction_slots s
LEFT JOIN (SELECT DISTINCT faction_template FROM zerocraft_deployables) d ON d.faction_template = s.faction_template
SET s.owner_key = NULL WHERE d.faction_template IS NULL;
SELECT s.faction_template, s.owner_key, COUNT(d.spawn_id) AS npcs FROM zerocraft_faction_slots s LEFT JOIN zerocraft_deployables d ON d.faction_template = s.faction_template GROUP BY s.faction_template, s.owner_key;
