-- ZeroCraft: legendary drop rates up - each legendary drops 15% from its own boss.
-- Frostmourne only comes from Naxxramas now: Kel'Thuzad, 10%. Bosses' NPC books are all blue (rare) books.
USE acore_world;
UPDATE creature_loot_template SET Chance = 15 WHERE Reference = 0 AND Comment LIKE 'ZeroCraft legendary - %' AND Item <> 36942;
-- Atiesh: the four versions share one 15% roll (group 5)
UPDATE creature_loot_template SET Chance = 3.75, GroupId = 5 WHERE Reference = 0 AND Comment LIKE 'ZeroCraft legendary - %' AND Item IN (22589, 22630, 22631, 22632);
-- Frostmourne: off the Lich King, onto Kel'Thuzad (every version) at 10%
DELETE FROM creature_loot_template WHERE Item = 36942 AND Reference = 0;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT ct.lootid, 36942, 0, 10, 0, 1, 0, 1, 1, 'ZeroCraft legendary - Kel''Thuzad (Frostmourne)'
FROM creature_template ct WHERE BINARY ct.name = BINARY 'Kel''Thuzad' AND ct.lootid > 0 AND ct.lootid IN (SELECT Entry FROM creature_loot_template WHERE Reference = 911000);
-- NPC books from bosses: blue books only
DELETE r FROM reference_loot_template r JOIN zerocraft_nbook b ON b.item_entry = r.Item WHERE r.Entry = 911090 AND b.quality <> 3;
UPDATE reference_loot_template SET Chance = 0 WHERE Entry = 911090;
SELECT b.quality, COUNT(*) AS books_in_boss_pool FROM reference_loot_template r JOIN zerocraft_nbook b ON b.item_entry = r.Item WHERE r.Entry = 911090 GROUP BY b.quality;
SELECT it.name, t.Chance, COUNT(*) AS loot_tables FROM creature_loot_template t JOIN item_template it ON it.entry = t.Item
WHERE t.Reference = 0 AND t.Comment LIKE 'ZeroCraft legendary - %' GROUP BY it.entry, t.Chance ORDER BY it.name;
