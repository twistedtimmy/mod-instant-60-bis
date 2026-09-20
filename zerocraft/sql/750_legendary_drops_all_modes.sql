-- ZeroCraft: Ragnaros gets Sulfuras back, and heroic / 25-man versions of each boss drop the same legendary
USE acore_world;
UPDATE creature_template SET lootid = entry WHERE entry = 11502 AND lootid = 0;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 17182, 0, 3, 0, 1, 0, 1, 1, 'ZeroCraft legendary - Ragnaros' FROM creature_template WHERE entry = 11502 AND lootid > 0;
DROP TEMPORARY TABLE IF EXISTS zc_l2;
CREATE TEMPORARY TABLE zc_l2
SELECT DISTINCT d.lootid AS lootid, t.Item AS item, t.Chance AS chance, t.Comment AS comment
FROM creature_loot_template t
JOIN creature_template b ON b.lootid = t.Entry
JOIN creature_template d ON d.entry IN (b.difficulty_entry_1, b.difficulty_entry_2, b.difficulty_entry_3)
WHERE t.Reference = 0 AND t.Comment LIKE 'ZeroCraft legendary - %' AND d.lootid > 0;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, item, 0, chance, 0, 1, 0, 1, 1, comment FROM zc_l2;
SELECT it.name, COUNT(*) AS loot_tables FROM creature_loot_template t JOIN item_template it ON it.entry = t.Item
WHERE t.Reference = 0 AND t.Comment LIKE 'ZeroCraft legendary - %' GROUP BY it.entry ORDER BY it.name;
DROP TEMPORARY TABLE zc_l2;
