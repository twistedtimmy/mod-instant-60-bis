-- ZeroCraft: training dummies are level 60, and "Training Dummy" (item 60408) is a common dungeon drop.
USE acore_world;
UPDATE creature_template SET minlevel = 60, maxlevel = 60 WHERE entry IN (31144, 31146, 32666, 32667);
DELETE FROM item_dbc WHERE ID = 60408;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60408, 15, 0, -1, 1, 7913, 0, 0);
DELETE FROM item_template WHERE entry = 60408;
DROP TEMPORARY TABLE IF EXISTS zc_d;
CREATE TEMPORARY TABLE zc_d SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_d SET entry = 60408, class = 15, subclass = 0, name = 'Training Dummy', Quality = 1, bonding = 0, stackable = 20, maxcount = 0,
  displayid = 7913, spellid_1 = 67285, description = 'Sets up a level 60 training dummy right in front of you. Guild NPCs leave it alone.',
  ScriptName = 'item_zerocraft_dummy', BuyPrice = 0, SellPrice = 0;
INSERT INTO item_template SELECT * FROM zc_d;
DROP TEMPORARY TABLE zc_d;
-- common drop: 40% from every dungeon and raid boss
DELETE FROM creature_loot_template WHERE Item = 60408 AND Reference = 0;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT Entry, 60408, 0, 40, 0, 1, 0, 1, 1, 'ZeroCraft Training Dummy' FROM creature_loot_template WHERE Reference = 911000;
SELECT COUNT(*) AS bosses_dropping_dummies FROM creature_loot_template WHERE Item = 60408;
