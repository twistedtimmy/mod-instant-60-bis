-- ZeroCraft: built things that never got a clickable copy (the Lumber Pile is really a quest chest the game
-- won't let you click) get one now, plus a furniture item, so they can be clicked, moved and picked up.
USE acore_world;
DROP TEMPORARY TABLE IF EXISTS zc_orph;
CREATE TEMPORARY TABLE zc_orph SELECT DISTINCT g.id AS entry FROM gameobject g JOIN zerocraft_placed p ON p.kind = 0 AND p.spawn_id = g.guid WHERE g.id < 2000000;
DELETE FROM gameobject_template WHERE entry IN (SELECT entry + 2000000 FROM zc_orph);
INSERT INTO gameobject_template (entry, type, displayId, name, IconName, castBarCaption, unk1, size, Data0, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11, Data12, Data13, Data14, Data15, Data16, Data17, Data18, Data19, Data20, Data21, Data22, Data23, AIName, ScriptName, VerifiedBuild)
SELECT t.entry + 2000000, 10, t.displayId, t.name, 'Speak', '', '', t.size, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0
FROM gameobject_template t JOIN zc_orph o ON o.entry = t.entry;
SET @next = (SELECT COALESCE(MAX(item_entry), 61019) FROM zerocraft_furniture WHERE stone = 0 AND item_entry < 63500) + 1;
DROP TEMPORARY TABLE IF EXISTS zc_new;
CREATE TEMPORARY TABLE zc_new SELECT t.entry, t.name, ROW_NUMBER() OVER (ORDER BY t.entry) AS n
FROM gameobject_template t JOIN zc_orph o ON o.entry = t.entry LEFT JOIN zerocraft_furniture f ON f.src_entry = t.entry WHERE f.src_entry IS NULL;
INSERT INTO zerocraft_furniture (item_entry, go_entry, src_entry, name, stone)
SELECT @next + n - 1, entry + 2000000, entry, LEFT(name, 100), 0 FROM zc_new WHERE @next + n - 1 <= 63499;
DROP TEMPORARY TABLE IF EXISTS zc_newitems;
CREATE TEMPORARY TABLE zc_newitems SELECT f.* FROM zerocraft_furniture f LEFT JOIN item_template i ON i.entry = f.item_entry WHERE i.entry IS NULL;
DELETE d FROM item_dbc d JOIN zc_newitems n ON n.item_entry = d.ID;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType)
SELECT item_entry, 15, 0, -1, 1, 7913, 0, 0 FROM zc_newitems;
INSERT INTO item_template SELECT f.item_entry, 15, 0, t.`SoundOverrideSubclass`, LEFT(f.name, 255), 7913, 2, t.`Flags`, t.`FlagsExtra`, t.`BuyCount`, 0, 0, t.`InventoryType`, t.`AllowableClass`, t.`AllowableRace`, 1, 0, t.`RequiredSkill`, t.`RequiredSkillRank`, t.`requiredspell`, t.`requiredhonorrank`, t.`RequiredCityRank`, t.`RequiredReputationFaction`, t.`RequiredReputationRank`, 0, 20, t.`ContainerSlots`, t.`stat_type1`, t.`stat_value1`, t.`stat_type2`, t.`stat_value2`, t.`stat_type3`, t.`stat_value3`, t.`stat_type4`, t.`stat_value4`, t.`stat_type5`, t.`stat_value5`, t.`stat_type6`, t.`stat_value6`, t.`stat_type7`, t.`stat_value7`, t.`stat_type8`, t.`stat_value8`, t.`stat_type9`, t.`stat_value9`, t.`stat_type10`, t.`stat_value10`, t.`ScalingStatDistribution`, t.`ScalingStatValue`, t.`dmg_min1`, t.`dmg_max1`, t.`dmg_type1`, t.`dmg_min2`, t.`dmg_max2`, t.`dmg_type2`, t.`armor`, t.`holy_res`, t.`fire_res`, t.`nature_res`, t.`frost_res`, t.`shadow_res`, t.`arcane_res`, t.`delay`, t.`ammo_type`, t.`RangedModRange`, 22275, 0, 0, t.`spellppmRate_1`, t.`spellcooldown_1`, t.`spellcategory_1`, t.`spellcategorycooldown_1`, t.`spellid_2`, t.`spelltrigger_2`, t.`spellcharges_2`, t.`spellppmRate_2`, t.`spellcooldown_2`, t.`spellcategory_2`, t.`spellcategorycooldown_2`, t.`spellid_3`, t.`spelltrigger_3`, t.`spellcharges_3`, t.`spellppmRate_3`, t.`spellcooldown_3`, t.`spellcategory_3`, t.`spellcategorycooldown_3`, t.`spellid_4`, t.`spelltrigger_4`, t.`spellcharges_4`, t.`spellppmRate_4`, t.`spellcooldown_4`, t.`spellcategory_4`, t.`spellcategorycooldown_4`, t.`spellid_5`, t.`spelltrigger_5`, t.`spellcharges_5`, t.`spellppmRate_5`, t.`spellcooldown_5`, t.`spellcategory_5`, t.`spellcategorycooldown_5`, 0, 'Pick a spot on the ground and it is built there. Click it afterwards to move, turn, resize or pick it up.', t.`PageText`, t.`LanguageID`, t.`PageMaterial`, t.`startquest`, t.`lockid`, t.`Material`, t.`sheath`, t.`RandomProperty`, t.`RandomSuffix`, t.`block`, t.`itemset`, t.`MaxDurability`, t.`area`, t.`Map`, t.`BagFamily`, t.`TotemCategory`, t.`socketColor_1`, t.`socketContent_1`, t.`socketColor_2`, t.`socketContent_2`, t.`socketColor_3`, t.`socketContent_3`, t.`socketBonus`, t.`GemProperties`, t.`RequiredDisenchantSkill`, t.`ArmorDamageModifier`, t.`duration`, t.`ItemLimitCategory`, t.`HolidayId`, 'item_zerocraft_furniture', t.`DisenchantID`, t.`FoodType`, t.`minMoneyLoot`, t.`maxMoneyLoot`, t.`flagsCustom`, t.`VerifiedBuild`
FROM zc_newitems f JOIN item_template t ON t.entry = 8164;
UPDATE gameobject g JOIN zerocraft_placed p ON p.kind = 0 AND p.spawn_id = g.guid JOIN zerocraft_furniture f ON f.src_entry = g.id
SET g.id = f.go_entry WHERE g.id < 2000000;
SELECT COUNT(*) AS objects_made_clickable FROM zc_orph;
SELECT COUNT(*) AS built_objects_still_not_clickable FROM gameobject g JOIN zerocraft_placed p ON p.kind = 0 AND p.spawn_id = g.guid WHERE g.id < 2000000;
