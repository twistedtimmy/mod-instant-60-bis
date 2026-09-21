USE acore_world;
-- ZeroCraft: deployed-NPC loyalty factions are hostile to players AND monsters
-- (everyone except their owner/guild, who get a forced friendly reaction).
DELETE FROM factiontemplate_dbc WHERE ID IN (1294,1739,1740,1742,1762,1763,1764,1765,1834,1842,1879,1889,1906,2057);
INSERT INTO factiontemplate_dbc (ID, Faction, Flags, FactionGroup, FriendGroup, EnemyGroup, Enemies_1, Enemies_2, Enemies_3, Enemies_4, Friend_1, Friend_2, Friend_3, Friend_4) VALUES
(1294,771,0,8,0,9,0,0,0,0,771,0,0,0),
(1739,982,0,8,0,9,0,0,0,0,982,0,0,0),
(1740,983,0,8,0,9,0,0,0,0,983,0,0,0),
(1742,984,0,8,0,9,0,0,0,0,984,0,0,0),
(1762,995,0,8,0,9,0,0,0,0,995,0,0,0),
(1763,996,0,8,0,9,0,0,0,0,996,0,0,0),
(1764,997,0,8,0,9,0,0,0,0,997,0,0,0),
(1765,998,0,8,0,9,0,0,0,0,998,0,0,0),
(1834,1023,0,8,0,9,0,0,0,0,1023,0,0,0),
(1842,1027,0,8,0,9,0,0,0,0,1027,0,0,0),
(1879,1042,0,8,0,9,0,0,0,0,1042,0,0,0),
(1889,1048,0,8,0,9,0,0,0,0,1048,0,0,0),
(1906,1054,0,8,0,9,0,0,0,0,1054,0,0,0),
(2057,1066,0,8,0,9,0,0,0,0,1066,0,0,0);
SELECT COUNT(*) AS loyalty_factions_updated FROM factiontemplate_dbc WHERE EnemyGroup = 9;
