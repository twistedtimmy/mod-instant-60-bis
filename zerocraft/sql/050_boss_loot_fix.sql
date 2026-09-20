-- ZeroCraft: make sure EVERY dungeon/raid boss drops NPC scrolls (catches bosses the first pass missed)
USE acore_world;
SELECT 'BEFORE' AS t, ct.entry, ct.name, ct.lootid, ct.`rank`, ct.ScriptName,
       (SELECT GROUP_CONCAT(CONCAT(l.Item,'/',l.Reference,'/',l.Chance)) FROM creature_loot_template l WHERE l.Entry = ct.lootid) AS loot
FROM creature_template ct WHERE ct.entry IN (11380, 14507, 14517, 14509, 14510, 14515, 14834, 11382, 15114, 15082, 11982, 12098);

DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b (entry INT PRIMARY KEY, rolls INT);
-- base bosses: anything spawned inside a dungeon/raid that is boss-ranked, boss-scripted or an encounter credit
INSERT IGNORE INTO zc_b
SELECT ct.entry, IF(MAX(c.map) IN (249,309,409,469,509,531,532,533,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724), 3, 2)
FROM creature c JOIN creature_template ct ON ct.entry = c.id
WHERE c.map IN (33,34,36,43,47,48,70,90,109,129,189,209,229,230,249,269,289,309,329,349,389,409,429,469,509,531,532,533,534,540,542,543,544,545,546,547,548,550,552,553,554,555,556,557,558,560,564,565,568,574,575,576,578,580,585,595,599,600,601,602,603,604,608,615,616,619,624,631,632,649,650,658,668,724)
  AND (ct.`rank` = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0))
GROUP BY ct.entry;
-- heroic / 25-man versions of those bosses: 3 drops
INSERT IGNORE INTO zc_b SELECT ct.difficulty_entry_1, 3 FROM creature_template ct JOIN zc_b b ON b.entry = ct.entry WHERE ct.difficulty_entry_1 > 0;
INSERT IGNORE INTO zc_b SELECT ct.difficulty_entry_2, 3 FROM creature_template ct JOIN zc_b b ON b.entry = ct.entry WHERE ct.difficulty_entry_2 > 0;
INSERT IGNORE INTO zc_b SELECT ct.difficulty_entry_3, 3 FROM creature_template ct JOIN zc_b b ON b.entry = ct.entry WHERE ct.difficulty_entry_3 > 0;
DELETE FROM zc_b WHERE entry = 0;

UPDATE creature_template ct JOIN zc_b b ON b.entry = ct.entry SET ct.lootid = ct.entry WHERE ct.lootid = 0;
DELETE t FROM creature_loot_template t JOIN creature_template ct ON ct.lootid = t.Entry JOIN zc_b b ON b.entry = ct.entry;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT ct.lootid, 0, 911000, 100, 0, 1, 0, b.rolls, b.rolls, 'ZeroCraft NPC drops'
FROM creature_template ct JOIN zc_b b ON b.entry = ct.entry;

SELECT COUNT(*) AS bosses_with_npc_drops FROM zc_b;
SELECT 'AFTER' AS t, ct.entry, ct.name, ct.lootid,
       (SELECT GROUP_CONCAT(CONCAT(l.Item,'/',l.Reference,'/',l.MaxCount)) FROM creature_loot_template l WHERE l.Entry = ct.lootid) AS loot
FROM creature_template ct WHERE ct.entry IN (11380, 11382, 14507, 14517, 14834, 11982, 12098);
