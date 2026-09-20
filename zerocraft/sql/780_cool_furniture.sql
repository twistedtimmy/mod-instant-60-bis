-- ZeroCraft: builder scrolls are gone - furniture is items only. Cool furniture (thrones, banners, glowing rune
-- circles, braziers, crystals, statues, portals...) is new, epic, placed with the green ground circle, and is what
-- bosses mostly drop (1-2 each). New characters get 5 of the best.
USE acore_world;
-- 1) the cool objects
DELETE FROM gameobject_template WHERE entry BETWEEN 912000 AND 912099 OR entry BETWEEN 2912000 AND 2912099;
INSERT INTO gameobject_template (entry, type, displayId, name, IconName, castBarCaption, unk1, size, Data0, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11, Data12, Data13, Data14, Data15, Data16, Data17, Data18, Data19, Data20, Data21, Data22, Data23, AIName, ScriptName, VerifiedBuild) VALUES
(912000, 5, 343, 'Glowing Rune Circle (Blue)', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912001, 5, 465, 'Glowing Rune Circle (Purple)', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912002, 5, 674, 'Glowing Rune Circle (Green)', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912003, 5, 6679, 'Scourge Rune Circle', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912004, 5, 5812, 'Warlock Ritual Circle', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912005, 5, 1327, 'Summoning Ritual', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912006, 5, 4432, 'Pentagram of Orgrimmar', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912007, 5, 6714, 'Icy Rune of Naxxramas', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912010, 5, 7744, 'Thrall''s Throne', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912011, 5, 6690, 'Kel''Thuzad''s Throne', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912012, 5, 6713, 'Throne of Karazhan', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912013, 5, 5592, 'Throne of Blackwing Lair', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912014, 5, 2810, 'Dark Iron Throne', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912015, 5, 7594, 'Eagle Throne of Zul''Aman', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912016, 5, 8132, 'Throne of Ulduar', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912020, 5, 5773, 'Great Horde War Banner', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912021, 5, 5771, 'Great Alliance War Banner', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912022, 5, 6784, 'Dragonmaw Banner', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912023, 5, 6389, 'Crimson Banner', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912024, 5, 6388, 'Forsaken Banner', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912025, 5, 6390, 'Kaldorei Tree Banner', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912030, 5, 6660, 'Epic Brazier (Gold)', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912031, 5, 6661, 'Epic Brazier (Blue)', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912032, 5, 6754, 'Great Midsummer Bonfire', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912033, 5, 6411, 'Bonfire of Karazhan', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912034, 5, 7263, 'Satyr Brazier', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912040, 5, 4271, 'Plague Cauldron', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912041, 5, 7271, 'Blood Cauldron', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912050, 5, 6772, 'Great Silvermyst Crystal', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912051, 5, 2971, 'Un''Goro Crystal', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912052, 5, 6451, 'Great Ruby Crystal', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912053, 5, 6665, 'Illidan''s Crystal', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912054, 5, 1667, 'Floating Arcane Crystal', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912060, 5, 2932, 'Statue of Emperor Thaurissan', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912061, 5, 6815, 'Statue of Uther the Lightbringer', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912062, 5, 6925, 'Eagle Statue', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912063, 5, 139, 'Statue of Khadgar', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912064, 5, 4853, 'Naga Priestess Statue', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912070, 5, 4396, 'Mage Portal (Stormwind)', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912071, 5, 6831, 'Mage Portal (Karazhan)', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912072, 5, 6691, 'Portal of Naxxramas', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912080, 5, 5972, 'Prismatic Dragon Egg', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912081, 5, 7247, 'Chromatic Dragon Egg', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912082, 5, 7187, 'Dragon Skeleton', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0),
(912083, 5, 4718, 'Great Tauren Totem', '', '', '', 1, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0);
INSERT INTO gameobject_template (entry, type, displayId, name, IconName, castBarCaption, unk1, size, Data0, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11, Data12, Data13, Data14, Data15, Data16, Data17, Data18, Data19, Data20, Data21, Data22, Data23, AIName, ScriptName, VerifiedBuild)
SELECT entry + 2000000, 10, displayId, name, 'Speak', '', '', size, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, '', '', 0 FROM gameobject_template WHERE entry BETWEEN 912000 AND 912099;
-- furniture rows + items for the new ones
SET @next = (SELECT COALESCE(MAX(item_entry), 61019) FROM zerocraft_furniture WHERE stone = 0 AND item_entry < 63500) + 1;
DROP TEMPORARY TABLE IF EXISTS zc_new;
CREATE TEMPORARY TABLE zc_new SELECT t.entry, t.name, ROW_NUMBER() OVER (ORDER BY t.entry) AS n
FROM gameobject_template t LEFT JOIN zerocraft_furniture f ON f.src_entry = t.entry WHERE t.entry BETWEEN 912000 AND 912099 AND f.src_entry IS NULL;
INSERT INTO zerocraft_furniture (item_entry, go_entry, src_entry, name, stone)
SELECT @next + n - 1, entry + 2000000, entry, name, 0 FROM zc_new WHERE @next + n - 1 <= 63499;
DROP TEMPORARY TABLE IF EXISTS zc_newitems;
CREATE TEMPORARY TABLE zc_newitems SELECT f.* FROM zerocraft_furniture f LEFT JOIN item_template i ON i.entry = f.item_entry WHERE i.entry IS NULL;
DELETE d FROM item_dbc d JOIN zc_newitems n ON n.item_entry = d.ID;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType)
SELECT item_entry, 15, 0, -1, 1, 7913, 0, 0 FROM zc_newitems;
INSERT INTO item_template SELECT f.item_entry, 15, 0, t.`SoundOverrideSubclass`, LEFT(f.name, 255), 7913, 2, t.`Flags`, t.`FlagsExtra`, t.`BuyCount`, 0, 0, t.`InventoryType`, t.`AllowableClass`, t.`AllowableRace`, 1, 0, t.`RequiredSkill`, t.`RequiredSkillRank`, t.`requiredspell`, t.`requiredhonorrank`, t.`RequiredCityRank`, t.`RequiredReputationFaction`, t.`RequiredReputationRank`, 0, 20, t.`ContainerSlots`, t.`stat_type1`, t.`stat_value1`, t.`stat_type2`, t.`stat_value2`, t.`stat_type3`, t.`stat_value3`, t.`stat_type4`, t.`stat_value4`, t.`stat_type5`, t.`stat_value5`, t.`stat_type6`, t.`stat_value6`, t.`stat_type7`, t.`stat_value7`, t.`stat_type8`, t.`stat_value8`, t.`stat_type9`, t.`stat_value9`, t.`stat_type10`, t.`stat_value10`, t.`ScalingStatDistribution`, t.`ScalingStatValue`, t.`dmg_min1`, t.`dmg_max1`, t.`dmg_type1`, t.`dmg_min2`, t.`dmg_max2`, t.`dmg_type2`, t.`armor`, t.`holy_res`, t.`fire_res`, t.`nature_res`, t.`frost_res`, t.`shadow_res`, t.`arcane_res`, t.`delay`, t.`ammo_type`, t.`RangedModRange`, 22275, 0, 0, t.`spellppmRate_1`, t.`spellcooldown_1`, t.`spellcategory_1`, t.`spellcategorycooldown_1`, t.`spellid_2`, t.`spelltrigger_2`, t.`spellcharges_2`, t.`spellppmRate_2`, t.`spellcooldown_2`, t.`spellcategory_2`, t.`spellcategorycooldown_2`, t.`spellid_3`, t.`spelltrigger_3`, t.`spellcharges_3`, t.`spellppmRate_3`, t.`spellcooldown_3`, t.`spellcategory_3`, t.`spellcategorycooldown_3`, t.`spellid_4`, t.`spelltrigger_4`, t.`spellcharges_4`, t.`spellppmRate_4`, t.`spellcooldown_4`, t.`spellcategory_4`, t.`spellcategorycooldown_4`, t.`spellid_5`, t.`spelltrigger_5`, t.`spellcharges_5`, t.`spellppmRate_5`, t.`spellcooldown_5`, t.`spellcategory_5`, t.`spellcategorycooldown_5`, 0, 'Pick a spot on the ground and it is built there. Click it afterwards to move, turn, resize or pick it up.', t.`PageText`, t.`LanguageID`, t.`PageMaterial`, t.`startquest`, t.`lockid`, t.`Material`, t.`sheath`, t.`RandomProperty`, t.`RandomSuffix`, t.`block`, t.`itemset`, t.`MaxDurability`, t.`area`, t.`Map`, t.`BagFamily`, t.`TotemCategory`, t.`socketColor_1`, t.`socketContent_1`, t.`socketColor_2`, t.`socketContent_2`, t.`socketColor_3`, t.`socketContent_3`, t.`socketBonus`, t.`GemProperties`, t.`RequiredDisenchantSkill`, t.`ArmorDamageModifier`, t.`duration`, t.`ItemLimitCategory`, t.`HolidayId`, 'item_zerocraft_furniture', t.`DisenchantID`, t.`FoodType`, t.`minMoneyLoot`, t.`maxMoneyLoot`, t.`flagsCustom`, t.`VerifiedBuild`
FROM zc_newitems f JOIN item_template t ON t.entry = 8164;
-- 2) every furniture item is placed with the green ground circle
UPDATE item_template SET spellid_1 = 22275, description = 'Pick a spot on the ground and it is built there. Click it afterwards to move, turn, resize or pick it up.'
WHERE ScriptName = 'item_zerocraft_furniture';
-- 3) the cool ones: epic, proper names
DROP TEMPORARY TABLE IF EXISTS zc_cool;
CREATE TEMPORARY TABLE zc_cool (src INT UNSIGNED PRIMARY KEY);
INSERT INTO zc_cool VALUES (912000),(912001),(912002),(912003),(912004),(912005),(912006),(912007),(912010),(912011),(912012),(912013),(912014),(912015),(912016),(912020),(912021),(912022),(912023),(912024),(912025),(912030),(912031),(912032),(912033),(912034),(912040),(912041),(912050),(912051),(912052),(912053),(912054),(912060),(912061),(912062),(912063),(912064),(912070),(912071),(912072),(912080),(912081),(912082),(912083),(179118),(2719),(152079),(178365),(194490),(19410),(19460),(19507),(20818),(177232),(180434),(19506),(19509),(19510),(19483),(178425);
UPDATE item_template i JOIN zerocraft_furniture f ON f.item_entry = i.entry JOIN zc_cool c ON c.src = f.src_entry
SET i.Quality = 4, i.name = LEFT(REPLACE(f.name, 'Furniture: ', ''), 255);
-- 4) boss drops: one cool piece every time, a second one sometimes (mostly cool, now and then something ordinary)
DELETE FROM reference_loot_template WHERE Entry IN (911110, 911111);
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911110, f.item_entry, 0, 0, 0, 1, 1, 1, 1, LEFT(f.name, 60) FROM zerocraft_furniture f JOIN zc_cool c ON c.src = f.src_entry WHERE f.stone = 0;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911111, f.item_entry, 0, 0, 0, 1, 1, 1, 1, LEFT(f.name, 60) FROM zerocraft_furniture f LEFT JOIN zc_cool c ON c.src = f.src_entry WHERE f.stone = 0 AND c.src IS NULL;
DROP TEMPORARY TABLE IF EXISTS zc_boss;
CREATE TEMPORARY TABLE zc_boss SELECT DISTINCT Entry FROM creature_loot_template WHERE Reference = 911000;
DELETE FROM creature_loot_template WHERE Reference IN (911110, 911111);
INSERT INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT Entry, 911110, 911110, 100, 0, 1, 0, 1, 1, 'ZeroCraft cool furniture' FROM zc_boss;
INSERT INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT Entry, 911112, 911110, 35, 0, 1, 0, 1, 1, 'ZeroCraft cool furniture (second)' FROM zc_boss;
INSERT INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT Entry, 911111, 911111, 15, 0, 1, 0, 1, 1, 'ZeroCraft ordinary furniture' FROM zc_boss;
-- 5) builder scrolls, builder's kits and catalogs are gone
DROP TEMPORARY TABLE IF EXISTS zc_scr;
CREATE TEMPORARY TABLE zc_scr SELECT entry FROM item_template WHERE ScriptName IN ('item_zerocraft_bscroll', 'item_zerocraft_builder', 'item_zerocraft_catalog');
DELETE l FROM creature_loot_template l JOIN zc_scr s ON s.entry = l.Item WHERE l.Reference = 0;
DELETE l FROM reference_loot_template l JOIN zc_scr s ON s.entry = l.Item;
DELETE l FROM gameobject_loot_template l JOIN zc_scr s ON s.entry = l.Item;
DELETE ci FROM acore_characters.character_inventory ci JOIN acore_characters.item_instance ii ON ii.guid = ci.item JOIN zc_scr s ON s.entry = ii.itemEntry;
DELETE ii FROM acore_characters.item_instance ii JOIN zc_scr s ON s.entry = ii.itemEntry;
-- report
SELECT COUNT(*) AS new_cool_items FROM zerocraft_furniture WHERE src_entry BETWEEN 912000 AND 912099;
SELECT COUNT(*) AS cool_in_drop_list FROM reference_loot_template WHERE Entry = 911110;
SELECT COUNT(*) AS ordinary_in_drop_list FROM reference_loot_template WHERE Entry = 911111;
SELECT COUNT(*) AS scroll_items_removed_types FROM zc_scr;
SELECT f.item_entry, f.name FROM zerocraft_furniture f WHERE f.src_entry IN (2719, 152079, 194490, 912000, 912010);
