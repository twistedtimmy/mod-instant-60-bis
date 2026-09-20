-- ZeroCraft fix 2: dungeon bosses are mostly 'elite' rank, not 'boss' rank - use the same boss test as the NPC-scroll drops
-- (boss rank, a boss_ script, or an encounter credit).
USE acore_world;
SET @idcol = (SELECT IF(COUNT(*) > 0, 'id1', 'id') FROM information_schema.columns
              WHERE table_schema = 'acore_world' AND table_name = 'creature' AND column_name = 'id1');
-- companion pets from raid bosses
DROP TEMPORARY TABLE IF EXISTS zc_raidboss;
CREATE TEMPORARY TABLE zc_raidboss (lootid INT UNSIGNED PRIMARY KEY);
DROP TEMPORARY TABLE IF EXISTS zc_spawned;
CREATE TEMPORARY TABLE zc_spawned (entry INT UNSIGNED PRIMARY KEY);
SET @q = CONCAT('INSERT IGNORE INTO zc_spawned SELECT DISTINCT ', @idcol, ' FROM creature WHERE map IN (249,309,409,469,509,531,533,532,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724)');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
INSERT IGNORE INTO zc_raidboss
SELECT ct.lootid FROM creature_template ct JOIN zc_spawned s ON s.entry = ct.entry WHERE ct.lootid > 0 AND (ct.rank = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0));
INSERT IGNORE INTO zc_raidboss
SELECT d.lootid FROM creature_template ct JOIN zc_spawned s ON s.entry = ct.entry
JOIN creature_template d ON d.entry IN (ct.difficulty_entry_1, ct.difficulty_entry_2, ct.difficulty_entry_3)
WHERE d.lootid > 0 AND (ct.rank = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0));
DELETE FROM creature_loot_template WHERE Reference = 911070;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911070, 911070, 10, 0, 1, 0, 1, 1, 'ZeroCraft companion pet' FROM zc_raidboss;
-- ground mounts from dungeon bosses
DROP TEMPORARY TABLE IF EXISTS zc_dboss;
CREATE TEMPORARY TABLE zc_dboss (lootid INT UNSIGNED PRIMARY KEY);
DROP TEMPORARY TABLE IF EXISTS zc_spawned;
CREATE TEMPORARY TABLE zc_spawned (entry INT UNSIGNED PRIMARY KEY);
SET @q = CONCAT('INSERT IGNORE INTO zc_spawned SELECT DISTINCT ', @idcol, ' FROM creature WHERE map IN (33,34,36,43,47,48,70,90,109,129,189,209,229,230,289,329,349,389,429,269,540,542,543,545,546,547,552,553,554,555,556,557,558,560,585,574,575,576,578,595,599,600,601,602,604,608,619,632,650,658,668)');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
INSERT IGNORE INTO zc_dboss
SELECT ct.lootid FROM creature_template ct JOIN zc_spawned s ON s.entry = ct.entry WHERE ct.lootid > 0 AND (ct.rank = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0));
INSERT IGNORE INTO zc_dboss
SELECT d.lootid FROM creature_template ct JOIN zc_spawned s ON s.entry = ct.entry
JOIN creature_template d ON d.entry IN (ct.difficulty_entry_1, ct.difficulty_entry_2, ct.difficulty_entry_3)
WHERE d.lootid > 0 AND (ct.rank = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0));
DELETE FROM creature_loot_template WHERE Reference = 911080;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911080, 911080, 5, 0, 1, 0, 1, 1, 'ZeroCraft ground mount' FROM zc_dboss;
SELECT COUNT(*) AS pets_in_pool FROM reference_loot_template WHERE Entry = 911070;
SELECT COUNT(*) AS mounts_in_pool FROM reference_loot_template WHERE Entry = 911080;
SELECT COUNT(*) AS raid_bosses_dropping_pets FROM zc_raidboss;
SELECT COUNT(*) AS dungeon_bosses_dropping_mounts FROM zc_dboss;
SELECT COUNT(*) AS ragnaros_sulfuras FROM creature_loot_template WHERE Entry = 11502 AND Item = 17182;
SELECT COUNT(*) AS lich_king_frostmourne FROM creature_loot_template WHERE Item = 36942;

