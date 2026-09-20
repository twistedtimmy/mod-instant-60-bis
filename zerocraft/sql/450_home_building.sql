-- ZeroCraft: HOME BUILDING, ComfyCraft style.
--  * Every decoration is now its own item ("Furniture: Wooden Chair"), 1 random one drops from every boss.
--  * Placed objects are clickable (cog cursor): move, turn, resize, pick up.
--  * Summoning Stones claim a spot: building privilege within 60 yards (a la Rust), one stone per area,
--    and talking to one summons guildmates, opens the guild bank or stores gold.
--  * High Warlord / Field Marshal gear drops: gloves, legs, boots from elite trash; helm, shoulders, chest
--    from dungeon bosses; High Warlord / Grand Marshal weapons from raid bosses.
USE acore_world;

CREATE TABLE IF NOT EXISTS zerocraft_furniture (item_entry INT UNSIGNED NOT NULL PRIMARY KEY, go_entry INT UNSIGNED NOT NULL, src_entry INT UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL, stone TINYINT UNSIGNED NOT NULL DEFAULT 0, KEY go (go_entry)) ENGINE=InnoDB;
DELETE FROM zerocraft_furniture;

-- scale for placed things
SET @has = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'acore_world' AND table_name = 'zerocraft_placed' AND column_name = 'scale');
SET @q = IF(@has = 0, 'ALTER TABLE zerocraft_placed ADD COLUMN scale FLOAT NOT NULL DEFAULT 1', 'SELECT 1');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;

-- everything that can be built: the catalog, the Builder's Scrolls, and every summoning/meeting stone
DROP TEMPORARY TABLE IF EXISTS zc_src;
CREATE TEMPORARY TABLE zc_src (entry INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_src SELECT entry FROM zerocraft_catalog;
INSERT IGNORE INTO zc_src SELECT entry FROM zerocraft_bscroll_items WHERE kind = 0;
INSERT IGNORE INTO zc_src SELECT entry FROM gameobject_template WHERE type = 23;
DELETE s FROM zc_src s JOIN gameobject_template t ON t.entry = s.entry WHERE t.type IN (3, 6, 11, 15, 25, 29, 31, 32, 34, 35, 36) OR t.displayId = 0;
DELETE s FROM zc_src s LEFT JOIN gameobject_template t ON t.entry = s.entry WHERE t.entry IS NULL;

DROP TEMPORARY TABLE IF EXISTS zc_f;
CREATE TEMPORARY TABLE zc_f SELECT s.entry, t.name, IF(t.type = 23 OR t.name LIKE '%Summoning Stone%' OR t.name LIKE 'Meeting Stone%', 1, 0) AS stone,
  ROW_NUMBER() OVER (ORDER BY IF(t.type = 23 OR t.name LIKE '%Summoning Stone%' OR t.name LIKE 'Meeting Stone%', 0, 1), t.name, s.entry) AS n
FROM zc_src s JOIN gameobject_template t ON t.entry = s.entry;
-- item ids: stones 61000-61019, furniture 61020-63499
SET @stones = (SELECT COUNT(*) FROM zc_f WHERE stone = 1);
INSERT INTO zerocraft_furniture (item_entry, go_entry, src_entry, name, stone)
SELECT IF(stone, 60999 + n, 61019 + n - @stones), entry + 2000000, entry, LEFT(name, 100), stone FROM zc_f
WHERE (stone = 1 AND n <= 20) OR (stone = 0 AND 61019 + n - @stones <= 63499);

-- clickable copies of every buildable object (a "goober" with the cog cursor), entry + 2,000,000
DELETE FROM gameobject_template WHERE entry >= 2000000;
INSERT INTO gameobject_template (entry, type, displayId, name, IconName, castBarCaption, unk1, size, Data0, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11, Data12, Data13, Data14, Data15, Data16, Data17, Data18, Data19, Data20, Data21, Data22, Data23, AIName, ScriptName, VerifiedBuild)
SELECT t.entry + 2000000, 10, t.displayId, t.name, 'Interact', '', '', t.size, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', 0 FROM gameobject_template t JOIN zerocraft_furniture f ON f.src_entry = t.entry;
-- things already built become clickable too
UPDATE gameobject g JOIN zerocraft_placed p ON p.kind = 0 AND p.spawn_id = g.guid JOIN zerocraft_furniture f ON f.src_entry = g.id
SET g.id = f.go_entry;

-- the furniture items (client knows ids 61000-63499 through the patch)
DELETE FROM item_dbc WHERE ID BETWEEN 61000 AND 63499;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType)
SELECT item_entry, 15, 0, -1, 1, IF(stone, 20219, 7913), 0, 0 FROM zerocraft_furniture;
DELETE FROM item_template WHERE entry BETWEEN 61000 AND 63499;
INSERT INTO item_template SELECT f.item_entry, 15, 0, t.`SoundOverrideSubclass`, LEFT(CONCAT(IF(f.stone,'Summoning Stone: ','Furniture: '), f.name), 255), IF(f.stone, 20219, 7913), IF(f.stone, 4, 2), t.`Flags`, t.`FlagsExtra`, t.`BuyCount`, 0, 0, t.`InventoryType`, t.`AllowableClass`, t.`AllowableRace`, 1, 0, t.`RequiredSkill`, t.`RequiredSkillRank`, t.`requiredspell`, t.`requiredhonorrank`, t.`RequiredCityRank`, t.`RequiredReputationFaction`, t.`RequiredReputationRank`, 0, 20, t.`ContainerSlots`, t.`stat_type1`, t.`stat_value1`, t.`stat_type2`, t.`stat_value2`, t.`stat_type3`, t.`stat_value3`, t.`stat_type4`, t.`stat_value4`, t.`stat_type5`, t.`stat_value5`, t.`stat_type6`, t.`stat_value6`, t.`stat_type7`, t.`stat_value7`, t.`stat_type8`, t.`stat_value8`, t.`stat_type9`, t.`stat_value9`, t.`stat_type10`, t.`stat_value10`, t.`ScalingStatDistribution`, t.`ScalingStatValue`, t.`dmg_min1`, t.`dmg_max1`, t.`dmg_type1`, t.`dmg_min2`, t.`dmg_max2`, t.`dmg_type2`, t.`armor`, t.`holy_res`, t.`fire_res`, t.`nature_res`, t.`frost_res`, t.`shadow_res`, t.`arcane_res`, t.`delay`, t.`ammo_type`, t.`RangedModRange`, 67285, 0, 0, t.`spellppmRate_1`, t.`spellcooldown_1`, t.`spellcategory_1`, t.`spellcategorycooldown_1`, t.`spellid_2`, t.`spelltrigger_2`, t.`spellcharges_2`, t.`spellppmRate_2`, t.`spellcooldown_2`, t.`spellcategory_2`, t.`spellcategorycooldown_2`, t.`spellid_3`, t.`spelltrigger_3`, t.`spellcharges_3`, t.`spellppmRate_3`, t.`spellcooldown_3`, t.`spellcategory_3`, t.`spellcategorycooldown_3`, t.`spellid_4`, t.`spelltrigger_4`, t.`spellcharges_4`, t.`spellppmRate_4`, t.`spellcooldown_4`, t.`spellcategory_4`, t.`spellcategorycooldown_4`, t.`spellid_5`, t.`spelltrigger_5`, t.`spellcharges_5`, t.`spellppmRate_5`, t.`spellcooldown_5`, t.`spellcategory_5`, t.`spellcategorycooldown_5`, 0, IF(f.stone, 'Place it to claim this spot for your guild: nobody else can build within 60 yards. Talk to it to summon guildmates or open the guild bank.', 'Places it right in front of you. Click it afterwards to move, turn, resize or pick it up.'), t.`PageText`, t.`LanguageID`, t.`PageMaterial`, t.`startquest`, t.`lockid`, t.`Material`, t.`sheath`, t.`RandomProperty`, t.`RandomSuffix`, t.`block`, t.`itemset`, t.`MaxDurability`, t.`area`, t.`Map`, t.`BagFamily`, t.`TotemCategory`, t.`socketColor_1`, t.`socketContent_1`, t.`socketColor_2`, t.`socketContent_2`, t.`socketColor_3`, t.`socketContent_3`, t.`socketBonus`, t.`GemProperties`, t.`RequiredDisenchantSkill`, t.`ArmorDamageModifier`, t.`duration`, t.`ItemLimitCategory`, t.`HolidayId`, 'item_zerocraft_furniture', t.`DisenchantID`, t.`FoodType`, t.`minMoneyLoot`, t.`maxMoneyLoot`, t.`flagsCustom`, t.`VerifiedBuild`
FROM zerocraft_furniture f JOIN item_template t ON t.entry = 8164;

-- boss loot: the Builder's Scroll drop is replaced by 1 random piece of furniture from EVERY boss,
-- plus a 10% chance of a Summoning Stone
DELETE FROM creature_loot_template WHERE Reference = 911050;
DELETE FROM reference_loot_template WHERE Entry IN (911110, 911111);
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911110, item_entry, 0, 0, 0, 1, 1, 1, 1, LEFT(name, 60) FROM zerocraft_furniture WHERE stone = 0;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911111, item_entry, 0, 0, 0, 1, 1, 1, 1, LEFT(name, 60) FROM zerocraft_furniture WHERE stone = 1;
DELETE FROM creature_loot_template WHERE Reference IN (911110, 911111);
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT Entry, 911110, 911110, 100, 0, 1, 0, 1, 1, 'ZeroCraft furniture' FROM creature_loot_template WHERE Reference = 911000;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT Entry, 911111, 911111, 10, 0, 1, 0, 1, 1, 'ZeroCraft summoning stone' FROM creature_loot_template WHERE Reference = 911000;

-- ---------------------------------------------------------------- High Warlord gear
DROP TEMPORARY TABLE IF EXISTS zc_pvp;
CREATE TEMPORARY TABLE zc_pvp SELECT entry, InventoryType, class FROM item_template
WHERE Quality = 4 AND ItemLevel BETWEEN 65 AND 80 AND RequiredLevel <= 60
  AND (name LIKE 'Warlord''s %' OR name LIKE 'General''s %' OR name LIKE 'High Warlord''s %'
    OR name LIKE 'Field Marshal''s %' OR name LIKE 'Marshal''s %' OR name LIKE 'Grand Marshal''s %');
UPDATE item_template i JOIN zc_pvp p ON p.entry = i.entry SET i.AllowableRace = -1, i.requiredhonorrank = 0, i.RequiredReputationFaction = 0, i.RequiredReputationRank = 0;
DELETE FROM reference_loot_template WHERE Entry IN (911120, 911121, 911122);
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911120, entry, 0, 0, 0, 1, 1, 1, 1, 'ZeroCraft PvP: gloves/legs/boots' FROM zc_pvp WHERE InventoryType IN (7, 8, 10);
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911121, entry, 0, 0, 0, 1, 1, 1, 1, 'ZeroCraft PvP: helm/shoulders/chest' FROM zc_pvp WHERE InventoryType IN (1, 3, 5, 20);
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911122, entry, 0, 0, 0, 1, 1, 1, 1, 'ZeroCraft PvP: weapons' FROM zc_pvp WHERE class = 2 OR InventoryType IN (14, 23);

SET @idcol = (SELECT IF(COUNT(*) > 0, 'id1', 'id') FROM information_schema.columns
              WHERE table_schema = 'acore_world' AND table_name = 'creature' AND column_name = 'id1');
DROP TEMPORARY TABLE IF EXISTS zc_inst;
CREATE TEMPORARY TABLE zc_inst (entry INT UNSIGNED PRIMARY KEY, raid TINYINT);
SET @q = CONCAT('INSERT IGNORE INTO zc_inst SELECT DISTINCT ', @idcol, ', map IN (249,309,409,469,509,531,533,532,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724) FROM creature WHERE map IN (33,34,36,43,47,48,70,90,109,129,189,209,229,230,289,329,349,389,429,269,540,542,543,545,546,547,552,553,554,555,556,557,558,560,585,574,575,576,578,595,599,600,601,602,604,608,619,632,650,658,668,249,309,409,469,509,531,533,532,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724)');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
DROP TEMPORARY TABLE IF EXISTS zc_lt;
CREATE TEMPORARY TABLE zc_lt (lootid INT UNSIGNED PRIMARY KEY, boss TINYINT, raid TINYINT);
INSERT IGNORE INTO zc_lt SELECT ct.lootid, (ct.`rank` = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0)), i.raid FROM creature_template ct JOIN zc_inst i ON i.entry = ct.entry WHERE ct.lootid > 0 AND ct.`rank` >= 1;
INSERT IGNORE INTO zc_lt SELECT d.lootid, (ct.`rank` = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0)), i.raid FROM creature_template ct JOIN zc_inst i ON i.entry = ct.entry
  JOIN creature_template d ON d.entry IN (ct.difficulty_entry_1, ct.difficulty_entry_2, ct.difficulty_entry_3) WHERE d.lootid > 0 AND ct.`rank` >= 1;
DELETE FROM creature_loot_template WHERE Reference IN (911120, 911121, 911122);
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911120, 911120, 0.5, 0, 1, 0, 1, 1, 'ZeroCraft PvP gloves/legs/boots' FROM zc_lt WHERE boss = 0;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911121, 911121, 5, 0, 1, 0, 1, 1, 'ZeroCraft PvP helm/shoulders/chest' FROM zc_lt WHERE boss = 1 AND raid = 0;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911121, 911121, 10, 0, 1, 0, 1, 1, 'ZeroCraft PvP helm/shoulders/chest' FROM zc_lt WHERE boss = 1 AND raid = 1;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911122, 911122, 8, 0, 1, 0, 1, 1, 'ZeroCraft PvP weapons' FROM zc_lt WHERE boss = 1 AND raid = 1;

SELECT SUM(stone = 0) AS furniture_items, SUM(stone = 1) AS summoning_stones FROM zerocraft_furniture;
SELECT COUNT(*) AS clickable_templates FROM gameobject_template WHERE entry >= 2000000;
SELECT InventoryType, COUNT(*) AS pvp_items FROM zc_pvp GROUP BY InventoryType;
SELECT SUM(boss = 0) AS trash_lootids, SUM(boss = 1 AND raid = 0) AS dungeon_bosses, SUM(boss = 1 AND raid = 1) AS raid_bosses FROM zc_lt;
