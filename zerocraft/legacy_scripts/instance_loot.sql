-- ZeroCraft: dungeon & raid loot = deployable NPCs only
USE acore_world;
SET @ref := 911000;

-- one-time backups so this can be undone
CREATE TABLE IF NOT EXISTS zc_backup_creature_loot_template AS SELECT * FROM creature_loot_template;
CREATE TABLE IF NOT EXISTS zc_backup_gameobject_loot_template AS SELECT * FROM gameobject_loot_template;
CREATE TABLE IF NOT EXISTS zc_backup_creature_template_loot AS SELECT entry, lootid, mingold, maxgold FROM creature_template;

-- 1) NPC drop table (one pick per roll)
DELETE FROM reference_loot_template WHERE Entry = @ref;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) VALUES
(@ref, 4427, 0, 32, 0, 1, 1, 1, 1, 'Deployable Guard'),
(@ref, 5041, 0, 22, 0, 1, 1, 1, 1, 'Deployable Vendor'),
(@ref, 1267, 0, 10, 0, 1, 1, 1, 1, 'Deployable Innkeeper'),
(@ref, 6213, 0, 10, 0, 1, 1, 1, 1, 'Deployable Repair Vendor'),
(@ref, 8164, 0,  7, 0, 1, 1, 1, 1, 'Deployable Auctioneer'),
(@ref, 17163,0,  7, 0, 1, 1, 1, 1, 'Deployable Flight Master'),
(@ref, 23656,0,  7, 0, 1, 1, 1, 1, 'Deployable Banker'),
(@ref, 23700,0,  5, 0, 1, 1, 1, 1, 'Deployable Hero');

-- 2) creatures that only ever spawn inside dungeons/raids (plus their heroic/25-man versions)
DROP TEMPORARY TABLE IF EXISTS zc_base;
CREATE TEMPORARY TABLE zc_base (entry INT PRIMARY KEY, raid TINYINT);
INSERT IGNORE INTO zc_base
SELECT c.id, MAX(c.map IN (169,249,309,409,469,509,531,532,533,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724)) FROM creature c WHERE c.map IN (33,34,36,43,44,47,48,70,90,109,129,169,189,209,229,230,249,269,289,309,329,349,389,409,429,469,509,531,532,533,534,540,542,543,544,545,546,547,548,550,552,553,554,555,556,557,558,560,564,565,568,574,575,576,578,580,585,595,598,599,600,601,602,603,604,608,615,616,619,624,631,632,649,650,658,668,724)
  AND c.id NOT IN (SELECT id FROM creature WHERE map NOT IN (33,34,36,43,44,47,48,70,90,109,129,169,189,209,229,230,249,269,289,309,329,349,389,409,429,469,509,531,532,533,534,540,542,543,544,545,546,547,548,550,552,553,554,555,556,557,558,560,564,565,568,574,575,576,578,580,585,595,598,599,600,601,602,603,604,608,615,616,619,624,631,632,649,650,658,668,724)) GROUP BY c.id;

DROP TEMPORARY TABLE IF EXISTS zc_inst;
CREATE TEMPORARY TABLE zc_inst (entry INT PRIMARY KEY, raid TINYINT, heroic TINYINT, base INT);
INSERT IGNORE INTO zc_inst SELECT b.entry, b.raid, 0, b.entry FROM zc_base b;
INSERT IGNORE INTO zc_inst SELECT ct.difficulty_entry_1, b.raid, 1, b.entry FROM zc_base b JOIN creature_template ct ON ct.entry = b.entry WHERE ct.difficulty_entry_1 > 0;
INSERT IGNORE INTO zc_inst SELECT ct.difficulty_entry_2, b.raid, 1, b.entry FROM zc_base b JOIN creature_template ct ON ct.entry = b.entry WHERE ct.difficulty_entry_2 > 0;
INSERT IGNORE INTO zc_inst SELECT ct.difficulty_entry_3, b.raid, 1, b.entry FROM zc_base b JOIN creature_template ct ON ct.entry = b.entry WHERE ct.difficulty_entry_3 > 0;

-- loot ids used only by those creatures
DROP TEMPORARY TABLE IF EXISTS zc_loot;
CREATE TEMPORARY TABLE zc_loot (lootid INT PRIMARY KEY);
INSERT IGNORE INTO zc_loot SELECT ct.lootid FROM creature_template ct JOIN zc_inst i ON i.entry = ct.entry WHERE ct.lootid > 0;
DELETE l FROM zc_loot l JOIN creature_template ct ON ct.lootid = l.lootid LEFT JOIN zc_inst i ON i.entry = ct.entry WHERE i.entry IS NULL;

-- 3) wipe all their loot and money
DELETE t FROM creature_loot_template t JOIN zc_loot l ON l.lootid = t.Entry;
UPDATE creature_template ct JOIN zc_inst i ON i.entry = ct.entry SET ct.mingold = 0, ct.maxgold = 0;

-- 4) bosses: 2 NPC drops (normal dungeon) or 3 (heroic dungeon / any raid)
DROP TEMPORARY TABLE IF EXISTS zc_boss_base;
CREATE TEMPORARY TABLE zc_boss_base (entry INT PRIMARY KEY);
INSERT IGNORE INTO zc_boss_base SELECT b.entry FROM zc_base b JOIN creature_template ct ON ct.entry = b.entry
 WHERE ct.`rank` = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0);

DROP TEMPORARY TABLE IF EXISTS zc_boss;
CREATE TEMPORARY TABLE zc_boss (entry INT PRIMARY KEY, rolls INT);
INSERT IGNORE INTO zc_boss SELECT i.entry, IF(i.raid OR i.heroic, 3, 2) FROM zc_inst i JOIN zc_boss_base bb ON bb.entry = i.base;

UPDATE creature_template ct JOIN zc_boss b ON b.entry = ct.entry SET ct.lootid = ct.entry WHERE ct.lootid = 0;
DELETE t FROM creature_loot_template t JOIN creature_template ct ON ct.lootid = t.Entry JOIN zc_boss b ON b.entry = ct.entry;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT ct.lootid, 0, @ref, 100, 0, 1, 0, b.rolls, b.rolls, 'ZeroCraft NPC drops' FROM creature_template ct JOIN zc_boss b ON b.entry = ct.entry;

-- 5) chests inside dungeons/raids: emptied; boss caches drop NPCs instead
DROP TEMPORARY TABLE IF EXISTS zc_go;
CREATE TEMPORARY TABLE zc_go (lootid INT PRIMARY KEY, raid TINYINT, cache TINYINT);
INSERT IGNORE INTO zc_go
SELECT gt.Data1, MAX(g.map IN (169,249,309,409,469,509,531,532,533,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724)),
  MAX((gt.name LIKE '%Cache%' OR gt.name LIKE '%Chest%' OR gt.name LIKE '%Spoils%' OR gt.name LIKE '%Gift%' OR gt.name LIKE '%Coffer%')
      AND gt.name NOT LIKE 'Battered%' AND gt.name NOT LIKE 'Solid%' AND gt.name NOT LIKE 'Large%' AND gt.name NOT LIKE 'Tattered%' AND gt.name NOT LIKE '%Trunk%')
FROM gameobject g JOIN gameobject_template gt ON gt.entry = g.id
WHERE g.map IN (33,34,36,43,44,47,48,70,90,109,129,169,189,209,229,230,249,269,289,309,329,349,389,409,429,469,509,531,532,533,534,540,542,543,544,545,546,547,548,550,552,553,554,555,556,557,558,560,564,565,568,574,575,576,578,580,585,595,598,599,600,601,602,603,604,608,615,616,619,624,631,632,649,650,658,668,724) AND gt.type = 3 AND gt.Data1 > 0 GROUP BY gt.Data1;
DELETE z FROM zc_go z JOIN gameobject_template gt ON gt.Data1 = z.lootid AND gt.type = 3 JOIN gameobject g ON g.id = gt.entry WHERE g.map NOT IN (33,34,36,43,44,47,48,70,90,109,129,169,189,209,229,230,249,269,289,309,329,349,389,409,429,469,509,531,532,533,534,540,542,543,544,545,546,547,548,550,552,553,554,555,556,557,558,560,564,565,568,574,575,576,578,580,585,595,598,599,600,601,602,603,604,608,615,616,619,624,631,632,649,650,658,668,724);
DELETE t FROM gameobject_loot_template t JOIN zc_go z ON z.lootid = t.Entry;
INSERT IGNORE INTO gameobject_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 0, @ref, 100, 0, 1, 0, IF(raid, 3, 2), IF(raid, 3, 2), 'ZeroCraft NPC drops' FROM zc_go WHERE cache = 1;

SELECT (SELECT COUNT(*) FROM zc_inst) AS instance_creature_types, (SELECT COUNT(*) FROM zc_loot) AS loot_tables_wiped,
       (SELECT COUNT(*) FROM zc_boss) AS boss_templates_with_npc_drops, (SELECT COUNT(*) FROM zc_go WHERE cache = 1) AS boss_caches;
