-- ZeroCraft: Guild Standard-Bearer (NPC 911140, item 60409) - a mirror image of its placer in the guild tabard.
USE acore_world;
CREATE TABLE IF NOT EXISTS zerocraft_herald (spawn_id INT UNSIGNED NOT NULL PRIMARY KEY, display INT UNSIGNED NOT NULL, race TINYINT UNSIGNED NOT NULL,
  gender TINYINT UNSIGNED NOT NULL, cls TINYINT UNSIGNED NOT NULL, skin TINYINT UNSIGNED NOT NULL, face TINYINT UNSIGNED NOT NULL,
  hair TINYINT UNSIGNED NOT NULL, hair_color TINYINT UNSIGNED NOT NULL, facial TINYINT UNSIGNED NOT NULL, items VARCHAR(200) NOT NULL) ENGINE=InnoDB;
DELETE FROM creature_template WHERE entry = 911140;
DROP TEMPORARY TABLE IF EXISTS zc_h;
CREATE TEMPORARY TABLE zc_h SELECT * FROM creature_template WHERE entry = 15384;
UPDATE zc_h SET entry = 911140, name = 'Guild Standard-Bearer', subname = '', npcflag = 1, faction = 35,
  minlevel = 60, maxlevel = 60, `rank` = 1, HealthModifier = 3, DamageModifier = 1, unit_flags = 0, unit_flags2 = 0x10,
  flags_extra = 0, AIName = '', ScriptName = '';
INSERT INTO creature_template SELECT * FROM zc_h;
DROP TEMPORARY TABLE zc_h;
DELETE FROM creature_template_model WHERE CreatureID = 911140;
INSERT INTO creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability) VALUES (911140, 0, 49, 1, 1);
-- the item
DELETE FROM item_dbc WHERE ID = 60409;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60409, 15, 0, -1, 1, 20621, 0, 0);
DELETE FROM item_template WHERE entry = 60409;
DROP TEMPORARY TABLE IF EXISTS zc_hi;
CREATE TEMPORARY TABLE zc_hi SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_hi SET entry = 60409, class = 15, subclass = 0, name = 'Guild Standard-Bearer', Quality = 3, bonding = 0, stackable = 20, maxcount = 0,
  displayid = 20621, spellid_1 = 67285, description = 'Calls a standard-bearer in your guild''s tabard - your emblem and colours. Looks like you.',
  ScriptName = 'item_zerocraft_herald', BuyPrice = 0, SellPrice = 0;
INSERT INTO item_template SELECT * FROM zc_hi;
DROP TEMPORARY TABLE zc_hi;
-- also a rare dungeon boss drop (10%)
DELETE FROM creature_loot_template WHERE Item = 60409 AND Reference = 0;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT Entry, 60409, 0, 10, 0, 1, 0, 1, 1, 'ZeroCraft Guild Standard-Bearer' FROM creature_loot_template WHERE Reference = 911000;
SELECT entry, name FROM creature_template WHERE entry = 911140;
