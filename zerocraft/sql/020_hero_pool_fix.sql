-- ZeroCraft: fix hero pool (10182 is Rokaro, not Rexxar) + villains that are summoned by scripts rather than spawned
USE acore_world;
DELETE FROM zerocraft_hero_pool WHERE entry = 10182;
DROP TEMPORARY TABLE IF EXISTS zc_diff;
CREATE TEMPORARY TABLE zc_diff (entry INT PRIMARY KEY);
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_1 FROM creature_template WHERE difficulty_entry_1 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_2 FROM creature_template WHERE difficulty_entry_2 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_3 FROM creature_template WHERE difficulty_entry_3 > 0;
INSERT IGNORE INTO zerocraft_hero_pool (entry, villain, name)
SELECT MIN(entry), 0, name FROM creature_template WHERE name = 'Rexxar' AND entry NOT IN (SELECT entry FROM zc_diff) GROUP BY name;
INSERT IGNORE INTO zerocraft_hero_pool (entry, villain, name)
SELECT MIN(entry), 1, name FROM creature_template
WHERE name IN ('Harbinger Skyriss','Mal''Ganis','Svala Sorrowgrave','Vazruden') AND entry NOT IN (SELECT entry FROM zc_diff) GROUP BY name;
SELECT villain, COUNT(*) AS n FROM zerocraft_hero_pool GROUP BY villain;
SELECT entry, name FROM zerocraft_hero_pool WHERE name IN ('Rexxar','Harbinger Skyriss','Mal''Ganis','Svala Sorrowgrave','Vazruden');
