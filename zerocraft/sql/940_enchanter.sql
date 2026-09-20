-- ZeroCraft: the Enchanter (NPC 911172) - enchants what you're wearing, free, with any enchant up to skill 300.
-- Called with the item "NPC: Enchanter" (65002).
USE acore_world;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Enchanting Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911172;
DROP TEMPORARY TABLE IF EXISTS zc_en; CREATE TEMPORARY TABLE zc_en SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_en SET entry = 911172, name = 'Enchanter', subname = 'Enchanting (300)', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, trainer_type = 0, AIName = '', ScriptName = 'npc_zerocraft_enchanter';
INSERT INTO creature_template SELECT * FROM zc_en; DROP TEMPORARY TABLE zc_en;
DELETE FROM creature_template_model WHERE CreatureID = 911172;
DROP TEMPORARY TABLE IF EXISTS zc_enm; CREATE TEMPORARY TABLE zc_enm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_enm SET CreatureID = 911172; INSERT INTO creature_template_model SELECT * FROM zc_enm; DROP TEMPORARY TABLE zc_enm;
DELETE FROM zerocraft_npcitem WHERE item_entry = 65002 OR entry = 911172;
INSERT INTO zerocraft_npcitem (item_entry, kind, entry, name) VALUES (65002, 842, 911172, 'Enchanter');
DELETE FROM item_dbc WHERE ID = 65002;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (65002, 15, 0, -1, 1, 918, 0, 0);
DELETE FROM item_template WHERE entry = 65002;
DROP TEMPORARY TABLE IF EXISTS zc_ei; CREATE TEMPORARY TABLE zc_ei SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_ei SET entry = 65002, class = 15, subclass = 0, name = 'NPC: Enchanter', displayid = 918, Quality = 4, bonding = 0, stackable = 20, maxcount = 0,
  spellid_1 = 22275, spelltrigger_1 = 0, BuyPrice = 0, SellPrice = 0, ScriptName = 'item_zerocraft_npcitem',
  description = 'Click the ground and the Enchanter arrives: pick something you wear, pick an enchant, done - free.';
INSERT INTO item_template SELECT * FROM zc_ei; DROP TEMPORARY TABLE zc_ei;
INSERT IGNORE INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES (911090, 65002, 0, 0, 0, 1, 1, 1, 1, 'NPC: Enchanter'), (5911090, 65002, 0, 0, 0, 1, 1, 1, 1, 'NPC: Enchanter');
SELECT entry, name, subname, ScriptName FROM creature_template WHERE entry = 911172;
