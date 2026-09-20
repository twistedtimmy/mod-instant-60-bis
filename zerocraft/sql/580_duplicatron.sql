-- ZeroCraft: Tinker's Duplicatron-9000 (item 60410) - single-use gnomish copier, 50% chance to work. Dungeon drop.
USE acore_world;
DELETE FROM item_dbc WHERE ID = 60410;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60410, 15, 0, -1, 1, 7840, 0, 0);
DELETE FROM item_template WHERE entry = 60410;
DROP TEMPORARY TABLE IF EXISTS zc_dt;
CREATE TEMPORARY TABLE zc_dt SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_dt SET entry = 60410, class = 15, subclass = 0, name = 'Tinker''s Duplicatron-9000', Quality = 3, bonding = 0, stackable = 20, maxcount = 0,
  displayid = 7840, spellid_1 = 0, ScriptName = '', BuyPrice = 0, SellPrice = 0,
  description = '"Patent pending. Warranty void if used. Do not lick." Click something you built and choose Duplicate. Works 50% of the time, every time. Single use.';
INSERT INTO item_template SELECT * FROM zc_dt;
DROP TEMPORARY TABLE zc_dt;
-- dungeon drop: 15% from every dungeon and raid boss
DELETE FROM creature_loot_template WHERE Item = 60410 AND Reference = 0;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT Entry, 60410, 0, 15, 0, 1, 0, 1, 1, 'ZeroCraft Tinker''s Duplicatron-9000' FROM creature_loot_template WHERE Reference = 911000;
SELECT entry, name FROM item_template WHERE entry = 60410;
