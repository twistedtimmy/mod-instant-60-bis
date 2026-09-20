-- ZeroCraft: Scrolls of Titan's Grip (swords / axes / maces) - rare dungeon boss drops that teach any class
-- to wield that kind of two-hander in each hand. New item ids 60401-60403 (also added to the client patch).
USE acore_characters;
CREATE TABLE IF NOT EXISTS zerocraft_titangrip (guid INT UNSIGNED NOT NULL PRIMARY KEY, mask INT UNSIGNED NOT NULL DEFAULT 0) ENGINE=InnoDB;
USE acore_world;
DELETE FROM item_dbc WHERE ID IN (60401, 60402, 60403, 60404, 60405, 60406);
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES
(60401, 15, 0, -1, 1, 20195, 0, 0), (60402, 15, 0, -1, 1, 19238, 0, 0), (60403, 15, 0, -1, 1, 8572, 0, 0),
(60404, 15, 0, -1, 1, 20254, 0, 0), (60405, 15, 0, -1, 1, 1644, 0, 0), (60406, 15, 0, -1, 1, 26595, 0, 0);
DELETE FROM item_template WHERE entry IN (60401, 60402, 60403, 60404, 60405, 60406);
DROP TEMPORARY TABLE IF EXISTS zc_tg;
CREATE TEMPORARY TABLE zc_tg SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_tg SET entry = 60401, name = 'Scroll of Titan''s Grip: Swords', displayid = 20195,
  description = 'Teaches you to wield a two-handed sword in each hand. Any class can learn it.';
INSERT INTO item_template SELECT * FROM zc_tg;
UPDATE zc_tg SET entry = 60402, name = 'Scroll of Titan''s Grip: Axes', displayid = 19238,
  description = 'Teaches you to wield a two-handed axe in each hand. Any class can learn it.';
INSERT INTO item_template SELECT * FROM zc_tg;
UPDATE zc_tg SET entry = 60403, name = 'Scroll of Titan''s Grip: Maces', displayid = 8572,
  description = 'Teaches you to wield a two-handed mace in each hand. Any class can learn it.';
INSERT INTO item_template SELECT * FROM zc_tg;
UPDATE zc_tg SET entry = 60404, name = 'Scroll of Titan''s Grip: Staves', displayid = 20254,
  description = 'Teaches you to wield a staff in each hand. Any class can learn it.';
INSERT INTO item_template SELECT * FROM zc_tg;
UPDATE zc_tg SET entry = 60405, name = 'Scroll of Shield Mastery', displayid = 1644,
  description = 'Teaches you to hold a shield alongside a two-handed weapon. Any class can learn it.';
INSERT INTO item_template SELECT * FROM zc_tg;
UPDATE zc_tg SET entry = 60406, name = 'Scroll of the Beastmaster', displayid = 26595,
  description = 'Hunters only. The first pet in your stable fights beside your active pet.';
INSERT INTO item_template SELECT * FROM zc_tg;
DROP TEMPORARY TABLE zc_tg;
UPDATE item_template SET class = 15, subclass = 0, Quality = 4, bonding = 1, stackable = 1, maxcount = 0,
  spellid_1 = 37435, spelltrigger_1 = 0, spellcharges_1 = -1, ScriptName = 'item_zerocraft_titangrip', BuyPrice = 0, SellPrice = 0
WHERE entry IN (60401, 60402, 60403, 60404, 60405, 60406);
UPDATE item_template SET AllowableClass = 4 WHERE entry = 60406;

-- dungeon bosses (5-player dungeons, normal and heroic): 5% chance of one of the six scrolls
DELETE FROM reference_loot_template WHERE Entry = 911100;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) VALUES
(911100, 60401, 0, 0, 0, 1, 1, 1, 1, 'Scroll of Titan''s Grip: Swords'),
(911100, 60402, 0, 0, 0, 1, 1, 1, 1, 'Scroll of Titan''s Grip: Axes'),
(911100, 60403, 0, 0, 0, 1, 1, 1, 1, 'Scroll of Titan''s Grip: Maces'),
(911100, 60404, 0, 0, 0, 1, 1, 1, 1, 'Scroll of Titan''s Grip: Staves'),
(911100, 60405, 0, 0, 0, 1, 1, 1, 1, 'Scroll of Shield Mastery'),
(911100, 60406, 0, 0, 0, 1, 1, 1, 1, 'Scroll of the Beastmaster');
SET @idcol = (SELECT IF(COUNT(*) > 0, 'id1', 'id') FROM information_schema.columns
              WHERE table_schema = 'acore_world' AND table_name = 'creature' AND column_name = 'id1');
DROP TEMPORARY TABLE IF EXISTS zc_spawned;
CREATE TEMPORARY TABLE zc_spawned (entry INT UNSIGNED PRIMARY KEY);
SET @q = CONCAT('INSERT IGNORE INTO zc_spawned SELECT DISTINCT ', @idcol, ' FROM creature WHERE map IN (33,34,36,43,47,48,70,90,109,129,189,209,229,230,289,329,349,389,429,269,540,542,543,545,546,547,552,553,554,555,556,557,558,560,585,574,575,576,578,595,599,600,601,602,604,608,619,632,650,658,668)');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
DROP TEMPORARY TABLE IF EXISTS zc_dboss;
CREATE TEMPORARY TABLE zc_dboss (lootid INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_dboss SELECT ct.lootid FROM creature_template ct JOIN zc_spawned s ON s.entry = ct.entry
WHERE ct.lootid > 0 AND (ct.`rank` = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0));
INSERT IGNORE INTO zc_dboss SELECT d.lootid FROM creature_template ct JOIN zc_spawned s ON s.entry = ct.entry
JOIN creature_template d ON d.entry IN (ct.difficulty_entry_1, ct.difficulty_entry_2, ct.difficulty_entry_3)
WHERE d.lootid > 0 AND (ct.`rank` = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0));
DELETE FROM creature_loot_template WHERE Reference = 911100;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911100, 911100, 5, 0, 1, 0, 1, 1, 'ZeroCraft Titan''s Grip scroll' FROM zc_dboss;
SELECT entry, name, Quality FROM item_template WHERE entry BETWEEN 60401 AND 60406;
SELECT COUNT(*) AS dungeon_bosses_dropping_titans_grip FROM zc_dboss;
