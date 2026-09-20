-- ZeroCraft: guard pool = high-level city guards + dungeon elite humanoids (all deploy as level 55-60 elites)
USE acore_world;
CREATE TABLE IF NOT EXISTS zerocraft_guard_pool (entry INT UNSIGNED PRIMARY KEY, kind VARCHAR(10) NOT NULL, name VARCHAR(100));
DELETE FROM zerocraft_guard_pool;
INSERT IGNORE INTO zerocraft_guard_pool (entry, kind, name)
SELECT DISTINCT r.id, 'guard', ct.name FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.flags_extra & 0x8000) <> 0 AND ct.minlevel >= 50 AND ct.`rank` <> 3 AND ct.entry NOT IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540);

DROP TEMPORARY TABLE IF EXISTS zc_diff;
CREATE TEMPORARY TABLE zc_diff (entry INT PRIMARY KEY);
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_1 FROM creature_template WHERE difficulty_entry_1 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_2 FROM creature_template WHERE difficulty_entry_2 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_3 FROM creature_template WHERE difficulty_entry_3 > 0;

INSERT IGNORE INTO zerocraft_guard_pool (entry, kind, name)
SELECT DISTINCT ct.entry, 'dungeon', ct.name FROM creature c JOIN creature_template ct ON ct.entry = c.id
WHERE c.map IN (33,34,36,43,44,47,48,70,90,109,129,169,189,209,229,230,249,269,289,309,329,349,389,409,429,469,509,531,532,533,534,540,542,543,544,545,546,547,548,550,552,553,554,555,556,557,558,560,564,565,568,574,575,576,578,580,585,595,598,599,600,601,602,603,604,608,615,616,619,624,631,632,649,650,658,668,724)
  AND ct.`rank` = 1 AND ct.type = 7 AND ct.npcflag = 0
  AND ct.ScriptName = '' AND (ct.flags_extra & 0x80) = 0 AND (ct.unit_flags & 0x02000000) = 0
  AND ct.name NOT LIKE '%Trigger%' AND ct.name NOT LIKE '%Invisible%' AND ct.name NOT LIKE '%Bunny%' AND ct.name NOT LIKE '%[DND]%'
  AND ct.entry NOT IN (SELECT entry FROM zc_diff)
  AND ct.entry NOT IN (SELECT creditEntry FROM instance_encounters)
  AND ct.entry NOT IN (SELECT entry FROM zerocraft_hero_pool);

-- city guards whose spawns were all removed: make their template elite
UPDATE creature_template ct JOIN zerocraft_guard_pool g ON g.entry = ct.entry AND g.kind = 'guard'
SET ct.`rank` = 1 WHERE ct.`rank` = 0 AND ct.entry NOT IN (SELECT id FROM creature);

SELECT kind, COUNT(*) AS n FROM zerocraft_guard_pool GROUP BY kind;
SELECT name FROM zerocraft_guard_pool WHERE kind = 'dungeon' ORDER BY RAND() LIMIT 25;
