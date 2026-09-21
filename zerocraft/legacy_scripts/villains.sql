-- ZeroCraft: hero pool = friendly leaders + dungeon/raid villains (normal-sized)
USE acore_world;
CREATE TABLE IF NOT EXISTS zerocraft_hero_pool (entry INT UNSIGNED PRIMARY KEY, villain TINYINT NOT NULL DEFAULT 0, name VARCHAR(100));
DELETE FROM zerocraft_hero_pool;
INSERT INTO zerocraft_hero_pool (entry, villain, name) SELECT entry, 0, name FROM creature_template WHERE entry IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540);
DROP TEMPORARY TABLE IF EXISTS zc_diff;
CREATE TEMPORARY TABLE zc_diff (entry INT PRIMARY KEY);
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_1 FROM creature_template WHERE difficulty_entry_1 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_2 FROM creature_template WHERE difficulty_entry_2 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_3 FROM creature_template WHERE difficulty_entry_3 > 0;
INSERT IGNORE INTO zerocraft_hero_pool (entry, villain, name)
SELECT MIN(ct.entry), 1, ct.name FROM creature_template ct
WHERE ct.name IN ('Edwin VanCleef','Archmage Arugal','Herod','High Inquisitor Whitemane','Scarlet Commander Mograine','Baron Rivendare','Darkmaster Gandling','Emperor Dagran Thaurissan','Jin''do the Hexxer','Lord Victor Nefarius','Kael''thas Sunstrider','Lady Vashj','Illidan Stormrage','Teron Gorefiend','Moroes','Shade of Aran','Terestian Illhoof','Zul''jin','Hex Lord Malacrass','Warchief Kargath Bladefist','Blackheart the Inciter','Harbinger Skyriss','Nexus-Prince Shaffar','Mal''Ganis','Ingvar the Plunderer','King Ymiron','Lady Deathwhisper','Prince Keleseth','Prince Valanar','Prince Taldaram','Grand Warlock Nethekurse','Ras Frostwhisper','Vazruden','Omor the Unscarred','Talon King Ikiss','Exarch Maladaar','Prince Tenris Mirkblood','Svala Sorrowgrave','Mograine') AND ct.entry NOT IN (SELECT entry FROM zc_diff)
  AND ct.entry IN (SELECT id FROM creature)
GROUP BY ct.name;
SELECT villain, COUNT(*) AS n, GROUP_CONCAT(name ORDER BY name SEPARATOR ', ') AS names FROM zerocraft_hero_pool GROUP BY villain;
