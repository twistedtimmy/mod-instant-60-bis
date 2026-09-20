-- ZeroCraft: the Potion Master (NPC 911170) - a fully trained alchemist who hands out, free, every potion, elixir, flask and
-- transmute an alchemist can make up to skill 300. Called with the item "NPC: Potion Master" (65000).
USE acore_world;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Alchemy Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911170;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_pm SET entry = 911170, name = 'Potion Master', subname = 'Alchemy (300)', npcflag = 129, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, trainer_type = 0, AIName = '', ScriptName = '';
INSERT INTO creature_template SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
DELETE FROM creature_template_model WHERE CreatureID = 911170;
DROP TEMPORARY TABLE IF EXISTS zc_pmm; CREATE TEMPORARY TABLE zc_pmm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pmm SET CreatureID = 911170; INSERT INTO creature_template_model SELECT * FROM zc_pmm; DROP TEMPORARY TABLE zc_pmm;
DELETE FROM npc_vendor WHERE entry = 911170;
INSERT IGNORE INTO npc_vendor (entry, item, maxcount, incrtime, ExtendedCost) VALUES (911170, 118, 0, 0, 0),(911170, 858, 0, 0, 0),(911170, 929, 0, 0, 0),(911170, 1710, 0, 0, 0),(911170, 2454, 0, 0, 0),(911170, 2455, 0, 0, 0),(911170, 2456, 0, 0, 0),(911170, 2457, 0, 0, 0),(911170, 2458, 0, 0, 0),(911170, 2459, 0, 0, 0),(911170, 2460, 0, 0, 0),(911170, 3382, 0, 0, 0),(911170, 3383, 0, 0, 0),(911170, 3384, 0, 0, 0),(911170, 3385, 0, 0, 0),(911170, 3386, 0, 0, 0),(911170, 3387, 0, 0, 0),(911170, 3388, 0, 0, 0),(911170, 3389, 0, 0, 0),(911170, 3390, 0, 0, 0),(911170, 3391, 0, 0, 0),(911170, 3577, 0, 0, 0),(911170, 3823, 0, 0, 0),(911170, 3824, 0, 0, 0),(911170, 3825, 0, 0, 0),(911170, 3826, 0, 0, 0),(911170, 3827, 0, 0, 0),(911170, 3828, 0, 0, 0),(911170, 3829, 0, 0, 0),(911170, 3928, 0, 0, 0),(911170, 4596, 0, 0, 0),(911170, 4623, 0, 0, 0),(911170, 5631, 0, 0, 0),(911170, 5633, 0, 0, 0),(911170, 5634, 0, 0, 0),(911170, 5996, 0, 0, 0),(911170, 5997, 0, 0, 0),(911170, 6037, 0, 0, 0),(911170, 6048, 0, 0, 0),(911170, 6049, 0, 0, 0),(911170, 6050, 0, 0, 0),(911170, 6051, 0, 0, 0),(911170, 6052, 0, 0, 0),(911170, 6149, 0, 0, 0),(911170, 6370, 0, 0, 0),(911170, 6371, 0, 0, 0),(911170, 6372, 0, 0, 0),(911170, 6373, 0, 0, 0),(911170, 6662, 0, 0, 0),(911170, 7068, 0, 0, 0),(911170, 7076, 0, 0, 0),(911170, 7078, 0, 0, 0),(911170, 7080, 0, 0, 0),(911170, 7082, 0, 0, 0),(911170, 8949, 0, 0, 0),(911170, 8951, 0, 0, 0),(911170, 8956, 0, 0, 0),(911170, 9030, 0, 0, 0),(911170, 9036, 0, 0, 0),(911170, 9061, 0, 0, 0),(911170, 9088, 0, 0, 0),(911170, 9144, 0, 0, 0),(911170, 9149, 0, 0, 0),(911170, 9154, 0, 0, 0),(911170, 9155, 0, 0, 0),(911170, 9172, 0, 0, 0),(911170, 9179, 0, 0, 0),(911170, 9187, 0, 0, 0),(911170, 9197, 0, 0, 0),(911170, 9206, 0, 0, 0),(911170, 9210, 0, 0, 0),(911170, 9224, 0, 0, 0),(911170, 9233, 0, 0, 0),(911170, 9264, 0, 0, 0),(911170, 10592, 0, 0, 0),(911170, 12190, 0, 0, 0),(911170, 12360, 0, 0, 0),(911170, 12803, 0, 0, 0),(911170, 12808, 0, 0, 0),(911170, 13423, 0, 0, 0),(911170, 13442, 0, 0, 0),(911170, 13443, 0, 0, 0),(911170, 13444, 0, 0, 0),(911170, 13445, 0, 0, 0),(911170, 13446, 0, 0, 0),(911170, 13447, 0, 0, 0),(911170, 13452, 0, 0, 0),(911170, 13453, 0, 0, 0),(911170, 13454, 0, 0, 0),(911170, 13455, 0, 0, 0),(911170, 13456, 0, 0, 0),(911170, 13457, 0, 0, 0),(911170, 13458, 0, 0, 0),(911170, 13459, 0, 0, 0),(911170, 13460, 0, 0, 0),(911170, 13461, 0, 0, 0),(911170, 13462, 0, 0, 0),(911170, 13506, 0, 0, 0),(911170, 13510, 0, 0, 0),(911170, 13511, 0, 0, 0),(911170, 13512, 0, 0, 0),(911170, 13513, 0, 0, 0),(911170, 17708, 0, 0, 0),(911170, 18253, 0, 0, 0),(911170, 18294, 0, 0, 0),(911170, 19931, 0, 0, 0),(911170, 20002, 0, 0, 0),(911170, 20004, 0, 0, 0),(911170, 20007, 0, 0, 0),(911170, 20008, 0, 0, 0),(911170, 21546, 0, 0, 0),(911170, 22823, 0, 0, 0),(911170, 22824, 0, 0, 0),(911170, 28100, 0, 0, 0),(911170, 28102, 0, 0, 0),(911170, 28103, 0, 0, 0),(911170, 45621, 0, 0, 0);
DELETE nv FROM npc_vendor nv LEFT JOIN item_template it ON it.entry = nv.item WHERE nv.entry = 911170 AND it.entry IS NULL;
-- the item that calls him
DELETE FROM zerocraft_npcitem WHERE item_entry = 65000 OR entry = 911170;
INSERT INTO zerocraft_npcitem (item_entry, kind, entry, name) VALUES (65000, 842, 911170, 'Potion Master');
DELETE FROM item_dbc WHERE ID = 65000;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (65000, 15, 0, -1, 1, 918, 0, 0);
DELETE FROM item_template WHERE entry = 65000;
DROP TEMPORARY TABLE IF EXISTS zc_pi; CREATE TEMPORARY TABLE zc_pi SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_pi SET entry = 65000, class = 15, subclass = 0, name = 'NPC: Potion Master', displayid = 918, Quality = 4, bonding = 0, stackable = 20, maxcount = 0,
  spellid_1 = 22275, spelltrigger_1 = 0, BuyPrice = 0, SellPrice = 0, ScriptName = 'item_zerocraft_npcitem',
  description = 'Click the ground and the Potion Master arrives: a fully trained alchemist with every potion up to skill 300.';
INSERT INTO item_template SELECT * FROM zc_pi; DROP TEMPORARY TABLE zc_pi;
INSERT IGNORE INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES (911090, 65000, 0, 0, 0, 1, 1, 1, 1, 'NPC: Potion Master'), (5911090, 65000, 0, 0, 0, 1, 1, 1, 1, 'NPC: Potion Master');
SELECT COUNT(*) AS potions_for_sale FROM npc_vendor WHERE entry = 911170;
SELECT entry, name, subname, npcflag FROM creature_template WHERE entry = 911170;
