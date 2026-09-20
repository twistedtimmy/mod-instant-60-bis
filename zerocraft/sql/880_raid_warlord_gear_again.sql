-- ZeroCraft: High Warlord / Grand Marshal gear drops much more from raid bosses:
-- every kill: one helm/shoulders/chest AND one gloves/legs/boots, plus a 50% chance at a PvP weapon.
USE acore_world;
DROP TEMPORARY TABLE IF EXISTS zc_raid3;
CREATE TEMPORARY TABLE zc_raid3 (lootid INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_raid3 SELECT DISTINCT ct.lootid FROM creature c JOIN creature_template ct ON ct.entry = c.id
  WHERE ct.lootid > 0 AND c.map IN (249,309,409,469,509,531,532,533,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724)
  AND ct.lootid IN (SELECT Entry FROM creature_loot_template WHERE Reference IN (911000, 5911000));
DROP TEMPORARY TABLE IF EXISTS zc_raid3_copy;
CREATE TEMPORARY TABLE zc_raid3_copy SELECT lootid FROM zc_raid3;
INSERT IGNORE INTO zc_raid3 SELECT d.lootid FROM creature_template b JOIN zc_raid3_copy r ON r.lootid = b.lootid
  JOIN creature_template d ON d.entry IN (b.difficulty_entry_1, b.difficulty_entry_2, b.difficulty_entry_3) WHERE d.lootid > 0;
DELETE t FROM creature_loot_template t JOIN zc_raid3 r ON r.lootid = t.Entry WHERE t.Reference IN (911120, 911121, 911122, 5911120, 5911121, 5911122);
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911121, 911121, 100, 0, 1, 0, 1, 1, 'ZeroCraft PvP helm/shoulders/chest (raid)' FROM zc_raid3;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911120, 911120, 100, 0, 1, 0, 1, 1, 'ZeroCraft PvP gloves/legs/boots (raid)' FROM zc_raid3;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911122, 911122, 50, 0, 1, 0, 1, 1, 'ZeroCraft PvP weapon (raid)' FROM zc_raid3;
SELECT COUNT(*) AS raid_bosses_with_warlord_gear FROM zc_raid3;
SELECT MIN(i.Quality) AS lowest_quality_in_pvp_lists FROM reference_loot_template l JOIN item_template i ON i.entry = l.Item WHERE l.Entry IN (911120, 911121, 911122);
