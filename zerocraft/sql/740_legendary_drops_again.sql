-- ZeroCraft: every legendary weapon now drops from the dungeon/raid boss it belongs to (no quests).
-- Only real bosses count (their loot tables carry the ZeroCraft NPC drops, reference 911000); every
-- difficulty of the boss drops it.
USE acore_world;
DROP TEMPORARY TABLE IF EXISTS zc_leg;
CREATE TEMPORARY TABLE zc_leg (boss VARCHAR(100), item INT, chance FLOAT);
INSERT INTO zc_leg VALUES
 ('The Lich King',            36942, 1),    -- Frostmourne, Cursed Blade of the Lich King (Icecrown Citadel)
 ('Ragnaros',                 17182, 3),    -- Sulfuras, Hand of Ragnaros (Molten Core)
 ('Illidan Stormrage',        32837, 4),    -- Warglaive of Azzinoth, main hand (Black Temple)
 ('Illidan Stormrage',        32838, 4),    -- Warglaive of Azzinoth, off hand
 ('Kel''Thuzad',              22589, 1),    -- Atiesh, Greatstaff of the Guardian (mage)
 ('Kel''Thuzad',              22630, 1),    -- Atiesh (warlock)
 ('Kel''Thuzad',              22631, 1),    -- Atiesh (priest)
 ('Kel''Thuzad',              22632, 1),    -- Atiesh (druid)
 ('Warchief Rend Blackhand',  60411, 2),    -- Doomhammer, Mace of the Warchief (Upper Blackrock Spire)
 ('Kael''thas Sunstrider',    60412, 2),    -- Spellbreaker, Glaive of Silvermoon (Magisters' Terrace + Tempest Keep)
 ('Priestess Delrissa',       60413, 2),    -- Crest of Silvermoon, Shield of the Guardians (Magisters' Terrace)
 ('Princess Theradras',       60414, 2),    -- Earthmother's Fury, War Totem of the Chieftains (Maraudon)
 ('Zul''jin',                 60415, 3),    -- Warbringer, Cleaver of the Amani (Zul'Aman)
 ('King Ymiron',              60417, 2),    -- Stormharpoon, Spear of the Ymirjar (Utgarde Pinnacle)
 ('Archimonde',               60418, 3);    -- Moonglaive of Elune, Blade of the Sentinels (Mount Hyjal)
-- the Atiesh staves need to be usable at level 60 without the old quest chain
UPDATE item_template SET RequiredLevel = 60, Quality = 5 WHERE entry IN (22589, 22630, 22631, 22632);
-- clear any older drop rows for these items, then add the new ones
DELETE FROM creature_loot_template WHERE Item IN (36942, 17182, 32837, 32838, 22589, 22630, 22631, 22632, 60411, 60412, 60413, 60414, 60415, 60416, 60417, 60418) AND Reference = 0;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT ct.lootid, l.item, 0, l.chance, 0, 1, 0, 1, 1, CONCAT('ZeroCraft legendary - ', l.boss)
FROM zc_leg l JOIN creature_template ct ON BINARY ct.name = BINARY l.boss
WHERE ct.lootid > 0 AND ct.lootid IN (SELECT Entry FROM creature_loot_template WHERE Reference = 911000);
-- report: which boss drops what, and anything that found no boss
SELECT l.boss, it.name AS item, l.chance, COUNT(DISTINCT t.Entry) AS loot_tables
FROM zc_leg l JOIN item_template it ON it.entry = l.item
LEFT JOIN creature_loot_template t ON t.Item = l.item AND t.Reference = 0 AND BINARY t.Comment = BINARY CONCAT('ZeroCraft legendary - ', l.boss)
GROUP BY l.boss, l.item, l.chance ORDER BY loot_tables, l.boss;
DROP TEMPORARY TABLE zc_leg;
