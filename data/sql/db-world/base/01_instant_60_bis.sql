-- Universal Proficiencies (Armor, Weapons, Riding, Mounts)
INSERT IGNORE INTO playercreateinfo_spell_custom (racemask, classmask, Spell, Note) VALUES
(0, 0, 750,   'Plate Mail'),
(0, 0, 8737,  'Mail'),
(0, 0, 9078,  'Leather'),
(0, 0, 196,   '1H Axes'),
(0, 0, 197,   '2H Axes'),
(0, 0, 198,   '1H Maces'),
(0, 0, 199,   '2H Maces'),
(0, 0, 201,   '1H Swords'),
(0, 0, 202,   '2H Swords'),
(0, 0, 200,   'Polearms'),
(0, 0, 227,   'Staves'),
(0, 0, 1180,  'Daggers'),
(0, 0, 15590, 'Fist Weapons'),
(0, 0, 264,   'Bows'),
(0, 0, 5011,  'Crossbows'),
(0, 0, 266,   'Guns'),
(0, 0, 2567,  'Thrown'),
(0, 0, 5009,  'Wands'),
(0, 0, 674,   'Dual Wield'),
(0, 0, 33388, 'Apprentice Riding'),
(0, 0, 33391, 'Journeyman Riding'),
(0, 0, 34090, 'Expert Riding'),
(0, 0, 34091, 'Artisan Riding'),
(0, 0, 54197, 'Cold Weather Flying'),
(0, 0, 23229, 'Swift Brown Steed'),
(0, 0, 23238, 'Swift Brown Ram'),
(0, 0, 23241, 'Swift Mistsaber'),
(0, 0, 23225, 'Swift Green Mechanostrider'),
(0, 0, 35710, 'Great Blue Elekk'),
(0, 0, 23250, 'Swift Brown Wolf'),
(0, 0, 23246, 'Green Skeletal Warhorse'),
(0, 0, 23249, 'Great Brown Kodo'),
(0, 0, 23257, 'Swift Blue Raptor'),
(0, 0, 35025, 'Swift Pink Hawkstrider');

-- Purge low quality starter clothing
DELETE pci FROM playercreateinfo_item pci
JOIN item_template it ON pci.itemid = it.entry
WHERE it.Quality IN (0, 1) AND pci.itemid NOT IN (21841);

-- 4x Netherweave Bags
INSERT IGNORE INTO playercreateinfo_item (race, class, itemid, amount)
SELECT DISTINCT race, class, 21841, 4 FROM playercreateinfo;

-- BiS Kit Mapping
CREATE TEMPORARY TABLE temp_bis (class_id INT, itemid INT);
INSERT INTO temp_bis (class_id, itemid) VALUES
-- Warrior (1)
(1, 22416), (1, 22417), (1, 22418), (1, 22419), (1, 22420), (1, 22421), (1, 22422), (1, 22423), (1, 23059),
(1, 23054), (1, 23053), (1, 23039), (1, 22818), (1, 23023), (1, 23045), (1, 23041), (1, 22954), (1, 23038), (1, 22812), (1, 22811),
-- Paladin (2)
(2, 22424), (2, 22425), (2, 22426), (2, 22427), (2, 22428), (2, 22429), (2, 22430), (2, 22431), (2, 23065),
(2, 22691), (2, 22988), (2, 22818), (2, 23021), (2, 23023), (2, 23071), (2, 23045), (2, 23001), (2, 23041), (2, 23031), (2, 23038),
-- Hunter (3)
(3, 22377), (3, 22378), (3, 22379), (3, 22380), (3, 22381), (3, 22382), (3, 22383), (3, 22384), (3, 23067),
(3, 22812), (3, 23037), (3, 23023), (3, 23045), (3, 23041), (3, 22954), (3, 23033),
-- Rogue (4)
(4, 22476), (4, 22477), (4, 22478), (4, 22479), (4, 22480), (4, 22481), (4, 22482), (4, 22483), (4, 23060),
(4, 23054), (4, 23014), (4, 22804), (4, 23023), (4, 23045), (4, 23041), (4, 22954), (4, 23018), (4, 22812), (4, 22811),
-- Priest (5)
(5, 22512), (5, 22513), (5, 22514), (5, 22515), (5, 22516), (5, 22517), (5, 22518), (5, 22519), (5, 23064),
(5, 22632), (5, 22807), (5, 23057), (5, 23071), (5, 23032), (5, 23001), (5, 23027), (5, 23031), (5, 23025), (5, 22820), (5, 23009),
-- Shaman (7)
(7, 22464), (7, 22465), (7, 22466), (7, 22467), (7, 22468), (7, 22469), (7, 22470), (7, 22471), (7, 23061),
(7, 22988), (7, 22818), (7, 23021), (7, 23023), (7, 23071), (7, 23045), (7, 23001), (7, 23027), (7, 23031), (7, 23038), (7, 22395),
-- Mage (8)
(8, 22496), (8, 22497), (8, 22498), (8, 22499), (8, 22500), (8, 22501), (8, 22502), (8, 22503), (8, 23062),
(8, 22589), (8, 22799), (8, 23057), (8, 23071), (8, 23050), (8, 23046), (8, 19379), (8, 23036), (8, 23031), (8, 22820), (8, 23009), (8, 14617),
-- Warlock (9)
(9, 22504), (9, 22505), (9, 22506), (9, 22507), (9, 22508), (9, 22509), (9, 22510), (9, 22511), (9, 23063),
(9, 22630), (9, 22799), (9, 23057), (9, 23071), (9, 23050), (9, 23046), (9, 19379), (9, 23036), (9, 23031), (9, 23009),
-- Druid (11)
(11, 22488), (11, 22489), (11, 22490), (11, 22491), (11, 22492), (11, 22493), (11, 22494), (11, 22495), (11, 23066),
(11, 22631), (11, 22988), (11, 23021), (11, 23023), (11, 23071), (11, 23045), (11, 23032), (11, 23001), (11, 23027), (11, 22954), (11, 23031), (11, 23038), (11, 22398);

INSERT IGNORE INTO playercreateinfo_item (race, class, itemid, amount)
SELECT p.race, p.class, t.itemid, 1
FROM playercreateinfo p
JOIN temp_bis t ON t.class_id = p.class;

-- Universal Riding & Cross-Faction Epic Mount Spells
INSERT IGNORE INTO playercreateinfo_spell_custom (racemask, classmask, Spell, Note) VALUES
(0, 0, 33388, 'Apprentice Riding'),
(0, 0, 33391, 'Journeyman Riding'),
(0, 0, 34090, 'Expert Riding'),
(0, 0, 34091, 'Artisan Riding'),
(0, 0, 54197, 'Cold Weather Flying'),
(0, 0, 23229, 'Swift Brown Steed'),
(0, 0, 23238, 'Swift Brown Ram'),
(0, 0, 23241, 'Swift Mistsaber'),
(0, 0, 23225, 'Swift Green Mechanostrider'),
(0, 0, 35710, 'Great Blue Elekk'),
(0, 0, 23250, 'Swift Brown Wolf'),
(0, 0, 23246, 'Green Skeletal Warhorse'),
(0, 0, 23249, 'Great Brown Kodo'),
(0, 0, 23257, 'Swift Blue Raptor'),
(0, 0, 35025, 'Swift Pink Hawkstrider');

-- Universal Riding & Cross-Faction Epic Mount Spells for Future Characters
INSERT IGNORE INTO playercreateinfo_spell_custom (racemask, classmask, Spell, Note) VALUES
(0, 0, 33388, 'Apprentice Riding'),
(0, 0, 33391, 'Journeyman Riding'),
(0, 0, 34090, 'Expert Riding'),
(0, 0, 34091, 'Artisan Riding'),
(0, 0, 54197, 'Cold Weather Flying'),
(0, 0, 23229, 'Swift Brown Steed'),
(0, 0, 23238, 'Swift Brown Ram'),
(0, 0, 23241, 'Swift Mistsaber'),
(0, 0, 23225, 'Swift Green Mechanostrider'),
(0, 0, 35710, 'Great Blue Elekk'),
(0, 0, 23250, 'Swift Brown Wolf'),
(0, 0, 23246, 'Green Skeletal Warhorse'),
(0, 0, 23249, 'Great Brown Kodo'),
(0, 0, 23257, 'Swift Blue Raptor'),
(0, 0, 35025, 'Swift Pink Hawkstrider');

-- Ensure all 10 epic mounts and riding skills are injected on character creation
DELETE FROM playercreateinfo_spell_custom WHERE Spell IN (33388, 33391, 34090, 34091, 54197, 23229, 23238, 23241, 23225, 35710, 23250, 23246, 23249, 23257, 35025);

INSERT IGNORE INTO playercreateinfo_spell_custom (racemask, classmask, Spell, Note)
SELECT 0, c.classmask, s.spell, 'Cross-Faction Epic Mounts & Riding'
FROM (
    SELECT 1 AS classmask UNION ALL SELECT 2 UNION ALL SELECT 4 UNION ALL 
    SELECT 8 UNION ALL SELECT 16 UNION ALL SELECT 32 UNION ALL 
    SELECT 64 UNION ALL SELECT 128 UNION ALL SELECT 256 UNION ALL SELECT 1024
) c
CROSS JOIN (
    SELECT 33388 AS spell UNION ALL -- Apprentice Riding
    SELECT 33391 UNION ALL       -- Journeyman Riding
    SELECT 34090 UNION ALL       -- Expert Riding
    SELECT 34091 UNION ALL       -- Artisan Riding
    SELECT 54197 UNION ALL       -- Cold Weather Flying
    SELECT 23229 UNION ALL       -- Swift Brown Steed
    SELECT 23238 UNION ALL       -- Swift Brown Ram
    SELECT 23241 UNION ALL       -- Swift Mistsaber
    SELECT 23225 UNION ALL       -- Swift Green Mechanostrider
    SELECT 35710 UNION ALL       -- Great Blue Elekk
    SELECT 23250 UNION ALL       -- Swift Brown Wolf
    SELECT 23246 UNION ALL       -- Green Skeletal Warhorse
    SELECT 23249 UNION ALL       -- Great Brown Kodo
    SELECT 23257 UNION ALL       -- Swift Blue Raptor
    SELECT 35025                 -- Swift Pink Hawkstrider
) s;

-- Every mount in the game, available to every class regardless of race/faction
UPDATE item_template SET AllowableRace=-1, AllowableClass=-1 WHERE class=15 AND subclass=5;

INSERT IGNORE INTO playercreateinfo_spell_custom (racemask, classmask, Spell, Note)
SELECT 0, 0, m.mount_spell, CONCAT('All Mounts: ', m.name)
FROM (
    SELECT DISTINCT
      CASE WHEN spelltrigger_1=6 THEN spellid_1
           WHEN spelltrigger_2=6 THEN spellid_2
           WHEN spelltrigger_3=6 THEN spellid_3
           WHEN spelltrigger_4=6 THEN spellid_4
           WHEN spelltrigger_5=6 THEN spellid_5
      END AS mount_spell,
      MIN(name) AS name
    FROM item_template WHERE class=15 AND subclass=5
    GROUP BY mount_spell
) m
WHERE m.mount_spell IS NOT NULL;

-- Every class learns its full max-rank trainer spell list on creation (derived
-- from the actual trainer/trainer_spell/spell_ranks tables, not a hand-picked list)
INSERT IGNORE INTO playercreateinfo_spell_custom (racemask, classmask, Spell, Note)
SELECT 0, (1 << (ct.classId - 1)), ct.SpellId, 'Max Rank Trainer Spell'
FROM (
  SELECT DISTINCT t.Requirement AS classId, ts.SpellId
  FROM trainer t
  JOIN trainer_spell ts ON ts.TrainerId = t.Id
  WHERE t.Type = 0 AND ts.ReqLevel <= 60
) ct
LEFT JOIN spell_ranks sr ON sr.spell_id = ct.SpellId
WHERE sr.first_spell_id IS NULL
   OR sr.rank = (
       SELECT MAX(sr2.rank) FROM spell_ranks sr2
       JOIN (
         SELECT DISTINCT t2.Requirement AS classId, ts2.SpellId
         FROM trainer t2
         JOIN trainer_spell ts2 ON ts2.TrainerId = t2.Id
         WHERE t2.Type = 0 AND ts2.ReqLevel <= 60
       ) ct2 ON ct2.SpellId = sr2.spell_id AND ct2.classId = ct.classId
       WHERE sr2.first_spell_id = sr.first_spell_id
   );

-- Every class gets a mount pre-slotted on the action bar (button 11 / key 12)
REPLACE INTO playercreateinfo_action (race, class, button, action, type)
SELECT race, class, 11, 23229, 0 FROM playercreateinfo;

-- Warrior rotation pre-slotted on the action bar (buttons 0-9 / keys 1-0)
DELETE FROM playercreateinfo_action WHERE class=1 AND button BETWEEN 0 AND 9;

REPLACE INTO playercreateinfo_action (race, class, button, action, type)
SELECT r.race, 1, a.button, a.action, 0
FROM (SELECT DISTINCT race FROM playercreateinfo WHERE class=1) r
CROSS JOIN (
  SELECT 0 AS button, 11605 AS action UNION ALL -- Execute
  SELECT 1, 11556 UNION ALL                     -- Heroic Strike
  SELECT 2, 11578 UNION ALL                     -- Thunder Clap
  SELECT 3, 1680  UNION ALL                     -- Whirlwind
  SELECT 4, 21553 UNION ALL                     -- Mortal Strike
  SELECT 5, 23925 UNION ALL                     -- Bloodthirst
  SELECT 6, 30016 UNION ALL                     -- Shield Slam
  SELECT 7, 11574 UNION ALL                     -- Rend
  SELECT 8, 2565  UNION ALL                     -- Shield Block
  SELECT 9, 871                                 -- Shield Wall
) a;

-- Hunter: the earlier "Cryptstalker set" IDs (22377-22380) were wrong - they're
-- actually unrelated low-level rare/epic quest-reward weapons, not the real
-- armor set, so Hunters spawned nearly naked. Replaced with the verified real
-- Cryptstalker Naxxramas set found by name in item_template.
DELETE FROM playercreateinfo_item WHERE class=3 AND itemid IN (22377, 22378, 22379, 22380);

INSERT IGNORE INTO playercreateinfo_item (race, class, itemid, amount)
SELECT p.race, 3, i.id, 1
FROM playercreateinfo p
CROSS JOIN (
    SELECT 22436 AS id UNION ALL -- Cryptstalker Tunic (Chest)
    SELECT 22437 UNION ALL       -- Cryptstalker Legguards (Legs)
    SELECT 22439 UNION ALL       -- Cryptstalker Spaulders (Shoulder)
    SELECT 22440 UNION ALL       -- Cryptstalker Boots (Feet)
    SELECT 22441 UNION ALL       -- Cryptstalker Handguards (Hands)
    SELECT 22442 UNION ALL       -- Cryptstalker Girdle (Waist)
    SELECT 22443                 -- Cryptstalker Wristguards (Wrist)
) i
WHERE p.class = 3;

-- Audit found Priest was missing a Back/Cloak item entirely (every other class
-- had one). Every other class's item list was cross-checked and verified real.
INSERT IGNORE INTO playercreateinfo_item (race, class, itemid, amount)
SELECT race, 5, 23050, 1 FROM playercreateinfo WHERE class = 5;

-- All characters spawn in Shattrath City (Outland) by default regardless of
-- race/class, instead of their normal racial starting zone. Coordinates are
-- the real, verified Shattrath entry sourced from game_tele (the same table
-- backing the .tele GM command).
UPDATE playercreateinfo
SET map = 530,
    position_x = -1838.16,
    position_y = 5301.79,
    position_z = -12.428,
    orientation = 5.9517;
