-- ZeroCraft: NPC Books are gone. Bosses drop single NPCs instead: "NPC: <name>" (blue, heroes epic),
-- from the cool pool (the NPCs of the blue and epic books, plus the heroes). Use it, click the ground, they arrive.
USE acore_world;
CREATE TABLE IF NOT EXISTS zerocraft_npcitem (item_entry INT UNSIGNED NOT NULL PRIMARY KEY, kind INT UNSIGNED NOT NULL,
  entry INT UNSIGNED NOT NULL, name VARCHAR(100) NOT NULL, UNIQUE KEY e (entry)) ENGINE=InnoDB;
DROP TEMPORARY TABLE IF EXISTS zc_np;
CREATE TEMPORARY TABLE zc_np (entry INT UNSIGNED PRIMARY KEY, kind INT UNSIGNED, name VARCHAR(100), q TINYINT);
INSERT IGNORE INTO zc_np SELECT h.entry, 951, ct.name, 4 FROM zerocraft_hero_pool h JOIN creature_template ct ON ct.entry = h.entry;
INSERT IGNORE INTO zc_np SELECT n.entry, n.kind, n.name, 3 FROM zerocraft_nbook_npcs n JOIN zerocraft_nbook b ON b.item_entry = n.item_entry
  JOIN creature_template ct ON ct.entry = n.entry WHERE b.quality >= 3 AND n.entry > 0;
SET @next = (SELECT COALESCE(MAX(item_entry), 63999) FROM zerocraft_npcitem) + 1;
DROP TEMPORARY TABLE IF EXISTS zc_np2;
CREATE TEMPORARY TABLE zc_np2 SELECT p.*, ROW_NUMBER() OVER (ORDER BY p.q DESC, p.name) AS n FROM zc_np p LEFT JOIN zerocraft_npcitem i ON i.entry = p.entry WHERE i.entry IS NULL;
INSERT INTO zerocraft_npcitem (item_entry, kind, entry, name) SELECT @next + n - 1, kind, entry, LEFT(name, 100) FROM zc_np2 WHERE @next + n - 1 <= 65999;
-- the items
DELETE d FROM item_dbc d JOIN zerocraft_npcitem n ON n.item_entry = d.ID;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType)
SELECT item_entry, 15, 0, -1, 1, 918, 0, 0 FROM zerocraft_npcitem;
DELETE t FROM item_template t JOIN zerocraft_npcitem n ON n.item_entry = t.entry;
DROP TEMPORARY TABLE IF EXISTS zc_nit;
CREATE TEMPORARY TABLE zc_nit SELECT * FROM item_template WHERE entry = 8164;
DROP TEMPORARY TABLE IF EXISTS zc_nit2;
CREATE TEMPORARY TABLE zc_nit2 SELECT t.*, n.item_entry AS ne, n.name AS nn, n.entry AS nent FROM zc_nit t JOIN zerocraft_npcitem n;
UPDATE zc_nit2 z JOIN zc_np p ON p.entry = z.nent
SET z.entry = z.ne, z.class = 15, z.subclass = 0, z.name = LEFT(CONCAT('NPC: ', z.nn), 255), z.displayid = 918, z.Quality = p.q,
  z.bonding = 0, z.stackable = 20, z.maxcount = 0, z.spellid_1 = 22275, z.spelltrigger_1 = 0, z.BuyPrice = 0, z.SellPrice = 0,
  z.description = LEFT(CONCAT('Click the ground and ', z.nn, ' arrives there, loyal to you.'), 255), z.ScriptName = 'item_zerocraft_npcitem';
ALTER TABLE zc_nit2 DROP COLUMN ne, DROP COLUMN nn, DROP COLUMN nent;
INSERT IGNORE INTO item_template SELECT * FROM zc_nit2;
-- boss drop list 911090 (and the raid copy 5911090): NPCs instead of books
DELETE FROM reference_loot_template WHERE Entry IN (911090, 5911090);
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911090, item_entry, 0, 0, 0, 1, 1, 1, 1, LEFT(CONCAT('NPC: ', name), 60) FROM zerocraft_npcitem;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 5911090, item_entry, 0, 0, 0, 1, 1, 1, 1, LEFT(CONCAT('NPC: ', name), 60) FROM zerocraft_npcitem;
-- NPC Books: out of every drop list and every bag
DELETE l FROM creature_loot_template l JOIN zerocraft_nbook b ON b.item_entry = l.Item WHERE l.Reference = 0;
DELETE l FROM reference_loot_template l JOIN zerocraft_nbook b ON b.item_entry = l.Item;
DELETE ci FROM acore_characters.character_inventory ci JOIN acore_characters.item_instance ii ON ii.guid = ci.item JOIN zerocraft_nbook b ON b.item_entry = ii.itemEntry;
DELETE ii FROM acore_characters.item_instance ii JOIN zerocraft_nbook b ON b.item_entry = ii.itemEntry;
SELECT COUNT(*) AS npc_items, SUM(entry IN (SELECT entry FROM zerocraft_hero_pool)) AS heroes, MIN(item_entry) AS first_id, MAX(item_entry) AS last_id FROM zerocraft_npcitem;
