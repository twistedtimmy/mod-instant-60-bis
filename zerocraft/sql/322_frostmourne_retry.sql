-- ZeroCraft (retry): Frostmourne from the Lich King, Sulfuras from Ragnaros, companion pets from every raid boss.
USE acore_world;

-- 1) Frostmourne, Cursed Blade of the Lich King (item 36942 - the real in-game Frostmourne model, now a player weapon)
UPDATE item_template SET
  name = 'Frostmourne, Cursed Blade of the Lich King',
  description = 'There''s an inscription on the dais. It''s a warning. It says, "Whomsoever takes up this blade shall wield power eternal. Just as the blade rends flesh, so must power scar the spirit."',
  Quality = 5, bonding = 1, maxcount = 1, ItemLevel = 100, RequiredLevel = 60,
  AllowableClass = -1, AllowableRace = -1, BuyPrice = 0, SellPrice = 250000,

  stat_type1 = 4,  stat_value1 = 45,
  stat_type2 = 7,  stat_value2 = 45,
  stat_type3 = 32, stat_value3 = 28,
  stat_type4 = 31, stat_value4 = 20,
  stat_type5 = 44, stat_value5 = 30,
  stat_type6 = 0, stat_value6 = 0, stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0,
  stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0,
  dmg_min1 = 290, dmg_max1 = 480, dmg_type1 = 0, dmg_min2 = 0, dmg_max2 = 0, delay = 3600,
  frost_res = 30, shadow_res = 15, MaxDurability = 145,

  spellid_1 = 46579, spelltrigger_1 = 2, spellcharges_1 = 0, spellppmRate_1 = 3, spellcooldown_1 = -1, spellcategory_1 = 0, spellcategorycooldown_1 = -1,

  spellid_2 = 43125, spelltrigger_2 = 2, spellcharges_2 = 0, spellppmRate_2 = 2, spellcooldown_2 = -1, spellcategory_2 = 0, spellcategorycooldown_2 = -1,

  spellid_3 = 60924, spelltrigger_3 = 0, spellcharges_3 = 0, spellppmRate_3 = 0, spellcooldown_3 = 60000, spellcategory_3 = 0, spellcategorycooldown_3 = -1,
  spellid_4 = 0, spelltrigger_4 = 0, spellid_5 = 0, spelltrigger_5 = 0,
  socketColor_1 = 0, socketContent_1 = 0, socketColor_2 = 0, socketContent_2 = 0, socketColor_3 = 0, socketContent_3 = 0, socketBonus = 0
WHERE entry = 36942;
SELECT entry, name, Quality, RequiredLevel, ItemLevel, dmg_min1, dmg_max1 FROM item_template WHERE entry = 36942;

-- 1% chance from the Lich King, every difficulty
DELETE FROM creature_loot_template WHERE Item = 36942;
INSERT INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT lootid, 36942, 0, 1, 0, 1, 0, 1, 1, 'The Lich King - Frostmourne (ZeroCraft)'
FROM creature_template WHERE entry IN (36597, 39166, 39167, 39168) AND lootid > 0;

-- 2) Sulfuras, Hand of Ragnaros drops straight from Ragnaros (3%, same as the Eye of Sulfuras, which stays)
DELETE FROM creature_loot_template WHERE Entry = 11502 AND Item = 17182;
INSERT INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES (11502, 17182, 0, 3, 0, 1, 0, 1, 1, 'Ragnaros - Sulfuras, Hand of Ragnaros (ZeroCraft)');

-- 3) Companion pets: every raid boss has a 10% chance to drop one, picked by rarity
--    (white pets are the most common, then green, blue, and purple ones are rare)
DROP TEMPORARY TABLE IF EXISTS zc_pets;
CREATE TEMPORARY TABLE zc_pets
SELECT entry, name, Quality,
       CASE WHEN Quality <= 1 THEN 20 WHEN Quality = 2 THEN 10 WHEN Quality = 3 THEN 5 WHEN Quality = 4 THEN 1 ELSE 0.5 END AS w
FROM item_template
WHERE class = 15 AND subclass = 2
  AND (spellid_1 = 55884 OR spelltrigger_1 = 6 OR spelltrigger_2 = 6)
  AND name NOT LIKE '%test%' AND name NOT LIKE '%deprecated%' AND name NOT LIKE '%[PH]%' AND name NOT LIKE '%unused%' AND name NOT LIKE '%QA%';
SET @zc_total = (SELECT SUM(w) FROM zc_pets);
DELETE FROM reference_loot_template WHERE Entry = 911070;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911070, p.entry, 0, ROUND(p.w * 100 / @zc_total, 3), 0, 1, 1, 1, 1, CONCAT('ZeroCraft pet - ', p.name)
FROM zc_pets p;

DROP TEMPORARY TABLE IF EXISTS zc_raidboss;
CREATE TEMPORARY TABLE zc_raidboss (lootid INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_raidboss
SELECT ct.lootid FROM creature_template ct
WHERE ct.rank = 3 AND ct.lootid > 0
  AND ct.entry IN (SELECT id1 FROM creature WHERE map IN (249,309,409,469,509,531,533,532,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724));
INSERT IGNORE INTO zc_raidboss
SELECT d.lootid FROM creature_template ct
JOIN creature_template d ON d.entry IN (ct.difficulty_entry_1, ct.difficulty_entry_2, ct.difficulty_entry_3)
WHERE ct.rank = 3 AND d.lootid > 0
  AND ct.entry IN (SELECT id1 FROM creature WHERE map IN (249,309,409,469,509,531,533,532,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724));
DELETE FROM creature_loot_template WHERE Reference = 911070;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911070, 911070, 10, 0, 1, 0, 1, 1, 'ZeroCraft companion pet' FROM zc_raidboss;

SELECT Quality, COUNT(*) AS pets FROM zc_pets GROUP BY Quality;
SELECT COUNT(*) AS raid_bosses_dropping_pets FROM zc_raidboss;
SELECT entry, name, Quality, ItemLevel FROM item_template WHERE entry IN (36942, 17182);
DROP TEMPORARY TABLE zc_pets; DROP TEMPORARY TABLE zc_raidboss;
