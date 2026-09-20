-- ZeroCraft: raid bosses never drop white or green items - only blue and epic (and legendary).
-- Raid bosses get their own copies of the shared drop lists with everything below blue taken out.
USE acore_world;
DROP TEMPORARY TABLE IF EXISTS zc_raid2;
CREATE TEMPORARY TABLE zc_raid2 (lootid INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_raid2 SELECT DISTINCT ct.lootid FROM creature c JOIN creature_template ct ON ct.entry = c.id
  WHERE ct.lootid > 0 AND c.map IN (249,309,409,469,509,531,532,533,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724)
  AND ct.lootid IN (SELECT Entry FROM creature_loot_template WHERE Reference = 911000);
INSERT IGNORE INTO zc_raid2 SELECT d.lootid FROM creature_template b JOIN zc_raid2 r ON r.lootid = b.lootid
  JOIN creature_template d ON d.entry IN (b.difficulty_entry_1, b.difficulty_entry_2, b.difficulty_entry_3) WHERE d.lootid > 0;
-- 1) direct white/green items on raid bosses go
DELETE t FROM creature_loot_template t JOIN zc_raid2 r ON r.lootid = t.Entry JOIN item_template i ON i.entry = t.Item
WHERE t.Reference = 0 AND i.Quality < 3;
-- 2) raid copies (id + 5000000) of every drop list raid bosses use, two levels deep, blue and up only
DROP TEMPORARY TABLE IF EXISTS zc_refs;
CREATE TEMPORARY TABLE zc_refs (ref INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_refs SELECT DISTINCT t.Reference FROM creature_loot_template t JOIN zc_raid2 r ON r.lootid = t.Entry WHERE t.Reference > 0 AND t.Reference < 5000000;
DROP TEMPORARY TABLE IF EXISTS zc_refs2;
CREATE TEMPORARY TABLE zc_refs2 SELECT DISTINCT l.Reference AS ref FROM reference_loot_template l JOIN zc_refs z ON z.ref = l.Entry WHERE l.Reference > 0 AND l.Reference < 5000000;
INSERT IGNORE INTO zc_refs SELECT ref FROM zc_refs2;
DELETE l FROM reference_loot_template l JOIN zc_refs z ON l.Entry = z.ref + 5000000;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT l.Entry + 5000000, l.Item, IF(l.Reference > 0, l.Reference + 5000000, 0), l.Chance, l.QuestRequired, l.LootMode, l.GroupId, l.MinCount, l.MaxCount, l.Comment
FROM reference_loot_template l JOIN zc_refs z ON z.ref = l.Entry
LEFT JOIN item_template i ON i.entry = l.Item AND l.Reference = 0
WHERE l.Reference > 0 OR i.Quality >= 3;
-- (a nested list that ended up empty is simply skipped by the game)
UPDATE creature_loot_template t JOIN zc_raid2 r ON r.lootid = t.Entry
SET t.Reference = t.Reference + 5000000 WHERE t.Reference > 0 AND t.Reference < 5000000;
-- 3) report
SELECT COUNT(*) AS raid_loot_tables FROM zc_raid2;
SELECT COUNT(*) AS below_blue_left_on_raid_bosses FROM creature_loot_template t JOIN zc_raid2 r ON r.lootid = t.Entry
  JOIN item_template i ON i.entry = t.Item WHERE t.Reference = 0 AND i.Quality < 3;
SELECT l.Entry - 5000000 AS list, COUNT(*) AS items_kept FROM reference_loot_template l WHERE l.Entry > 5000000 GROUP BY l.Entry ORDER BY list;
