-- ZeroCraft: every built object is clickable, and working ones keep working.
--  * objects that were built but had no clickable copy yet (grill, mailboxes, forges... from the old Builder's Kit
--    and the removed "special" scroll items) get one, plus their own furniture item
--  * working objects (chairs, mailboxes, portals, meeting stones, books...) keep their real type, so "Use it" works;
--    pure decorations (rugs, lamps...) become clickable goobers; crafting stations (anvil, forge, cooking fire)
--    get a tiny hidden twin that still counts as the anvil / forge / fire for crafting.
USE acore_world;

DROP TEMPORARY TABLE IF EXISTS zc_src;
CREATE TEMPORARY TABLE zc_src (entry INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_src SELECT src_entry FROM zerocraft_furniture;
INSERT IGNORE INTO zc_src SELECT entry FROM gameobject_template WHERE entry IN (126260,12665,13948,142075,142109,143981,143983,144112,152079,1560,1685,172911,1744,176296,176497,176498,176499,176500,176501,177044,177232,178365,178425,178666,178824,178826,178828,178831,178845,179118,1798,179895,179966,179967,179968,179969,179976,179977,180026,180030,180031,180032,180034,180039,180042,180043,180219,180324,180334,180339,180352,180434,180473,180698,180700,181075,181103,181146,181686,181883,182351,182352,182403,182948,183122,183268,185492,186143,186327,186680,186681,186682,186709,186717,186737,187316,188241,188346,188604,189993,189994,190576,190915,1915,193909,19395,19397,194097,19410,19423,19429,19430,19432,19435,19444,194490,19450,19452,19453,19454,19455,19457,19459,19460,19481,19482,19483,19485,19493,19494,19495,19506,19507,19509,19510,195141,19626,19637,20812,20818,211062,2413,24388,24538,2719,32349,3769);
INSERT IGNORE INTO zc_src SELECT IF(g.id >= 2000000, g.id - 2000000, g.id) FROM gameobject g JOIN zerocraft_placed p ON p.kind = 0 AND p.spawn_id = g.guid;
DELETE s FROM zc_src s LEFT JOIN gameobject_template t ON t.entry = s.entry WHERE t.entry IS NULL OR t.type IN (3, 6, 11, 15, 25, 29, 31, 33, 34, 35, 36) OR t.displayId = 0;

-- new furniture items for sources that don't have one yet (existing item ids never change)
SET @next = GREATEST(61020, (SELECT COALESCE(MAX(item_entry), 61019) FROM zerocraft_furniture WHERE stone = 0) + 1);
DROP TEMPORARY TABLE IF EXISTS zc_new;
CREATE TEMPORARY TABLE zc_new SELECT s.entry, t.name, ROW_NUMBER() OVER (ORDER BY t.name, s.entry) AS n
FROM zc_src s JOIN gameobject_template t ON t.entry = s.entry
LEFT JOIN zerocraft_furniture f ON f.src_entry = s.entry WHERE f.src_entry IS NULL;
INSERT INTO zerocraft_furniture (item_entry, go_entry, src_entry, name, stone)
SELECT @next + n - 1, entry + 2000000, entry, LEFT(name, 100), 0 FROM zc_new WHERE @next + n - 1 <= 63499;

-- clickable copies, rebuilt: real type for working objects, goober for decorations
DELETE FROM gameobject_template WHERE entry >= 2000000;
INSERT INTO gameobject_template (entry, type, displayId, name, IconName, castBarCaption, unk1, size, Data0, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11, Data12, Data13, Data14, Data15, Data16, Data17, Data18, Data19, Data20, Data21, Data22, Data23, AIName, ScriptName, VerifiedBuild)
SELECT t.entry + 2000000, t.type, t.displayId, t.name, t.IconName, t.castBarCaption, '', t.size, t.Data0, t.Data1, t.Data2, t.Data3, t.Data4, t.Data5, t.Data6, t.Data7, t.Data8, t.Data9, t.Data10, t.Data11, t.Data12, t.Data13, t.Data14, t.Data15, t.Data16, t.Data17, t.Data18, t.Data19, t.Data20, t.Data21, t.Data22, t.Data23, '', '', 0 FROM gameobject_template t JOIN zerocraft_furniture f ON f.src_entry = t.entry WHERE t.type IN (0,1,2,7,9,10,13,19,22,32);
INSERT INTO gameobject_template (entry, type, displayId, name, IconName, castBarCaption, unk1, size, Data0, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11, Data12, Data13, Data14, Data15, Data16, Data17, Data18, Data19, Data20, Data21, Data22, Data23, AIName, ScriptName, VerifiedBuild)
SELECT t.entry + 2000000, 10, t.displayId, t.name, 'Interact', '', '', t.size, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', 0 FROM gameobject_template t JOIN zerocraft_furniture f ON f.src_entry = t.entry WHERE t.type NOT IN (0,1,2,7,9,10,13,19,22,32);
-- every built object uses its clickable copy
UPDATE gameobject g JOIN zerocraft_placed p ON p.kind = 0 AND p.spawn_id = g.guid JOIN zerocraft_furniture f ON f.src_entry = g.id
SET g.id = f.go_entry;

-- items for the new sources (same recipe as 450)
DROP TEMPORARY TABLE IF EXISTS zc_newitems;
CREATE TEMPORARY TABLE zc_newitems SELECT f.* FROM zerocraft_furniture f LEFT JOIN item_template i ON i.entry = f.item_entry WHERE i.entry IS NULL;
DELETE d FROM item_dbc d JOIN zc_newitems n ON n.item_entry = d.ID;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType)
SELECT item_entry, 15, 0, -1, 1, 7913, 0, 0 FROM zc_newitems;
INSERT INTO item_template SELECT f.item_entry, 15, 0, t.`SoundOverrideSubclass`, LEFT(CONCAT('Furniture: ', f.name), 255), 7913, 2, t.`Flags`, t.`FlagsExtra`, t.`BuyCount`, 0, 0, t.`InventoryType`, t.`AllowableClass`, t.`AllowableRace`, 1, 0, t.`RequiredSkill`, t.`RequiredSkillRank`, t.`requiredspell`, t.`requiredhonorrank`, t.`RequiredCityRank`, t.`RequiredReputationFaction`, t.`RequiredReputationRank`, 0, 20, t.`ContainerSlots`, t.`stat_type1`, t.`stat_value1`, t.`stat_type2`, t.`stat_value2`, t.`stat_type3`, t.`stat_value3`, t.`stat_type4`, t.`stat_value4`, t.`stat_type5`, t.`stat_value5`, t.`stat_type6`, t.`stat_value6`, t.`stat_type7`, t.`stat_value7`, t.`stat_type8`, t.`stat_value8`, t.`stat_type9`, t.`stat_value9`, t.`stat_type10`, t.`stat_value10`, t.`ScalingStatDistribution`, t.`ScalingStatValue`, t.`dmg_min1`, t.`dmg_max1`, t.`dmg_type1`, t.`dmg_min2`, t.`dmg_max2`, t.`dmg_type2`, t.`armor`, t.`holy_res`, t.`fire_res`, t.`nature_res`, t.`frost_res`, t.`shadow_res`, t.`arcane_res`, t.`delay`, t.`ammo_type`, t.`RangedModRange`, 67285, 0, 0, t.`spellppmRate_1`, t.`spellcooldown_1`, t.`spellcategory_1`, t.`spellcategorycooldown_1`, t.`spellid_2`, t.`spelltrigger_2`, t.`spellcharges_2`, t.`spellppmRate_2`, t.`spellcooldown_2`, t.`spellcategory_2`, t.`spellcategorycooldown_2`, t.`spellid_3`, t.`spelltrigger_3`, t.`spellcharges_3`, t.`spellppmRate_3`, t.`spellcooldown_3`, t.`spellcategory_3`, t.`spellcategorycooldown_3`, t.`spellid_4`, t.`spelltrigger_4`, t.`spellcharges_4`, t.`spellppmRate_4`, t.`spellcooldown_4`, t.`spellcategory_4`, t.`spellcategorycooldown_4`, t.`spellid_5`, t.`spelltrigger_5`, t.`spellcharges_5`, t.`spellppmRate_5`, t.`spellcooldown_5`, t.`spellcategory_5`, t.`spellcategorycooldown_5`, 0, 'Places it right in front of you. Click it afterwards to move, turn, resize or pick it up.', t.`PageText`, t.`LanguageID`, t.`PageMaterial`, t.`startquest`, t.`lockid`, t.`Material`, t.`sheath`, t.`RandomProperty`, t.`RandomSuffix`, t.`block`, t.`itemset`, t.`MaxDurability`, t.`area`, t.`Map`, t.`BagFamily`, t.`TotemCategory`, t.`socketColor_1`, t.`socketContent_1`, t.`socketColor_2`, t.`socketContent_2`, t.`socketColor_3`, t.`socketContent_3`, t.`socketBonus`, t.`GemProperties`, t.`RequiredDisenchantSkill`, t.`ArmorDamageModifier`, t.`duration`, t.`ItemLimitCategory`, t.`HolidayId`, 'item_zerocraft_furniture', t.`DisenchantID`, t.`FoodType`, t.`minMoneyLoot`, t.`maxMoneyLoot`, t.`flagsCustom`, t.`VerifiedBuild`
FROM zc_newitems f JOIN item_template t ON t.entry = 8164;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911110, item_entry, 0, 0, 0, 1, 1, 1, 1, LEFT(name, 60) FROM zc_newitems;

SELECT COUNT(*) AS new_furniture_items FROM zc_newitems;
SELECT t.type, COUNT(*) AS clickable_copies FROM gameobject_template t WHERE t.entry >= 2000000 GROUP BY t.type;
SELECT COUNT(*) AS built_objects_not_clickable FROM gameobject g JOIN zerocraft_placed p ON p.kind = 0 AND p.spawn_id = g.guid WHERE g.id < 2000000;

-- hover cursor: speech bubble instead of the cog
UPDATE gameobject_template SET IconName = 'Speak' WHERE entry >= 2000000;

-- Builder's Rod (60407): ground-targeted like the Commander's Banner. Pick "Place" on a built object,
-- then use the rod and click the ground - the object moves there.
DELETE FROM item_dbc WHERE ID = 60407;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60407, 15, 0, -1, 1, 13435, 0, 0);
DELETE FROM item_template WHERE entry = 60407;
DROP TEMPORARY TABLE IF EXISTS zc_rod;
CREATE TEMPORARY TABLE zc_rod SELECT * FROM item_template WHERE entry = 23701;
UPDATE zc_rod SET entry = 60407, name = 'Builder''s Rod', displayid = 13435, Quality = 3, bonding = 1, maxcount = 1, stackable = 1,
  description = 'Choose "Place" on something you built, then use the rod and click the ground to set it there.',
  ScriptName = 'item_zerocraft_placerod';
INSERT INTO item_template SELECT * FROM zc_rod;
DROP TEMPORARY TABLE zc_rod;
SELECT entry, name, spellid_1, ScriptName FROM item_template WHERE entry = 60407;
