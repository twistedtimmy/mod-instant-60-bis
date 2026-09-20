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

-- The Hearthstone tooltip ("Returns you to X") reads the character's stored
-- home-bind AREA ID, which is separate from the actual teleport map/position -
-- it was left at each race's original zone even after the spawn point moved
-- to Shattrath, so the teleport worked but the tooltip still said the old
-- zone name. 3703 is Shattrath City's real area ID (verified via the
-- Shattrath graveyard's GhostZone entry in game_graveyard/graveyard_zone).
UPDATE playercreateinfo SET zone = 3703;

-- ZeroCraft: no glyphs. Disable the spell every glyph item casts.
INSERT IGNORE INTO disables (sourceType, entry, flags, comment)
SELECT DISTINCT 0, spellid_1, 1, 'ZeroCraft: no glyphs'
FROM item_template
WHERE class = 16 AND spellid_1 > 0;

-- ZeroCraft: remove all friendly/service NPCs from Eastern Kingdoms (map 0) and Kalimdor (map 1).
-- Keeps spirit healers / spirit guides. Every removed spawn is backed up first so it can be restored.

CREATE TABLE IF NOT EXISTS zerocraft_removed_creatures LIKE creature;

INSERT IGNORE INTO zerocraft_removed_creatures
SELECT c.* FROM creature c
JOIN creature_template ct ON ct.entry = c.id
WHERE c.map IN (0, 1)
  AND (ct.npcflag & (0x4000 | 0x8000)) = 0             -- keep spirit healers / guides
  AND (
        ct.npcflag <> 0                                 -- vendors, trainers, quest givers, innkeepers, flight masters, bankers...
     OR (ct.flags_extra & 0x8000) <> 0                  -- guards
     OR (ct.flags_extra & 0x2) <> 0                     -- civilians
     OR ct.faction = 35                                 -- generic friendly-to-all
     OR c.zoneId = 1637                                 -- Orgrimmar: remove EVERYTHING
     OR (c.map = 1 AND c.zoneId = 0 AND c.position_x BETWEEN 1300 AND 2150 AND c.position_y BETWEEN -4900 AND -4000)
  );

CREATE TABLE IF NOT EXISTS zerocraft_removed_creature_addon LIKE creature_addon;
INSERT IGNORE INTO zerocraft_removed_creature_addon SELECT ca.* FROM creature_addon ca JOIN zerocraft_removed_creatures r ON r.guid = ca.guid;
CREATE TABLE IF NOT EXISTS zerocraft_removed_game_event_creature LIKE game_event_creature;
INSERT IGNORE INTO zerocraft_removed_game_event_creature SELECT g.* FROM game_event_creature g JOIN zerocraft_removed_creatures r ON r.guid = g.guid;
CREATE TABLE IF NOT EXISTS zerocraft_removed_pool_creature LIKE pool_creature;
INSERT IGNORE INTO zerocraft_removed_pool_creature SELECT p.* FROM pool_creature p JOIN zerocraft_removed_creatures r ON r.guid = p.guid;

DELETE ca  FROM creature_addon ca        JOIN zerocraft_removed_creatures r ON r.guid = ca.guid;
DELETE gec FROM game_event_creature gec  JOIN zerocraft_removed_creatures r ON r.guid = gec.guid;
DELETE pc  FROM pool_creature pc         JOIN zerocraft_removed_creatures r ON r.guid = pc.guid;
DELETE c   FROM creature c               JOIN zerocraft_removed_creatures r ON r.guid = c.guid;

SELECT COUNT(*) AS npcs_removed_total FROM zerocraft_removed_creatures;
SELECT COUNT(*) AS spawns_left_on_both_continents FROM creature WHERE map IN (0, 1);

-- ZeroCraft: no attunements / entry requirements for any dungeon or raid
DELETE FROM dungeon_access_requirements;
UPDATE dungeon_access_template SET min_level = NULL, max_level = NULL, min_avg_item_level = NULL;

-- ZeroCraft deployable NPCs (test): tables, faction slot pool, two deploy items, starting kit.

CREATE TABLE IF NOT EXISTS zerocraft_faction_slots (
  faction_template INT UNSIGNED NOT NULL PRIMARY KEY,
  owner_key BIGINT NULL COMMENT 'guild id (>0) or -(player guid)'
);
-- client-known faction templates: hostile to all players by default, used by no creature
INSERT IGNORE INTO zerocraft_faction_slots (faction_template) VALUES
(1294),(1739),(1740),(1742),(1762),(1763),(1764),(1765),(1834),(1842),(1879),(1889),(1906),(2057);

CREATE TABLE IF NOT EXISTS zerocraft_deployables (
  spawn_id INT UNSIGNED NOT NULL PRIMARY KEY,
  entry INT UNSIGNED NOT NULL,
  owner_player INT UNSIGNED NOT NULL,
  owner_guild INT UNSIGNED NOT NULL DEFAULT 0,
  faction_template INT UNSIGNED NOT NULL,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Deploy items, cloned from the Hearthstone row so every column is valid, then reshaped.
DELETE FROM item_template WHERE entry IN (911001, 911002);
DROP TEMPORARY TABLE IF EXISTS zc_tmp_item;
CREATE TEMPORARY TABLE zc_tmp_item SELECT * FROM item_template WHERE entry = 6948;
UPDATE zc_tmp_item SET
  entry = 911001, name = 'Deployable Guard', description = 'Deploys a random guard loyal to you and your guild.',
  class = 0, subclass = 8, Quality = 3, Flags = 0, bonding = 0, stackable = 20, maxcount = 0,
  SellPrice = 0, BuyPrice = 0, ItemLevel = 1, RequiredLevel = 0,
  spellid_1 = 13567, spelltrigger_1 = 0, spellcharges_1 = 0, spellcooldown_1 = -1, spellcategory_1 = 0, spellcategorycooldown_1 = -1,
  displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 3012), displayid),
  ScriptName = 'item_zerocraft_deploy';
INSERT INTO item_template SELECT * FROM zc_tmp_item;
UPDATE zc_tmp_item SET entry = 911002, name = 'Deployable Vendor', description = 'Deploys a random vendor loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp_item;
DROP TEMPORARY TABLE zc_tmp_item;

-- Starting kit for NEW characters: 2 guards + 1 vendor
DELETE FROM playercreateinfo_item WHERE itemid IN (911001, 911002);
INSERT INTO playercreateinfo_item (race, class, itemid, amount)
SELECT DISTINCT race, class, 911001, 7 FROM playercreateinfo;
INSERT INTO playercreateinfo_item (race, class, itemid, amount)
SELECT DISTINCT race, class, 911002, 3 FROM playercreateinfo;

-- deploy items now use Flamestrike (Rank 1) purely for its ground-targeting circle
UPDATE item_template SET spellid_1 = 2120, description = 'Place it, then cast for 5 seconds to deploy a loyal NPC.' WHERE entry IN (911001, 911002);
DELETE FROM spell_script_names WHERE spell_id = 5504 AND ScriptName = 'spell_zerocraft_deploy_conjure';
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES (5504, 'spell_zerocraft_deploy_conjure');
DELETE FROM item_template WHERE entry = 911003;
DROP TEMPORARY TABLE IF EXISTS zc_tmp_item;
CREATE TEMPORARY TABLE zc_tmp_item SELECT * FROM item_template WHERE entry = 911001;
UPDATE zc_tmp_item SET entry = 911003, name = 'Deployable Hero', Quality = 4, stackable = 1,
  description = 'Deploys a random legendary hero loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp_item;
DROP TEMPORARY TABLE zc_tmp_item;
DELETE FROM playercreateinfo_item WHERE itemid = 911003;
INSERT INTO playercreateinfo_item (race, class, itemid, amount)

-- ZeroCraft: deployed-NPC loyalty factions are hostile to players AND monsters
-- (everyone except their owner/guild, who get a forced friendly reaction).
DELETE FROM factiontemplate_dbc WHERE ID IN (1294,1739,1740,1742,1762,1763,1764,1765,1834,1842,1879,1889,1906,2057);
INSERT INTO factiontemplate_dbc (ID, Faction, Flags, FactionGroup, FriendGroup, EnemyGroup, Enemies_1, Enemies_2, Enemies_3, Enemies_4, Friend_1, Friend_2, Friend_3, Friend_4) VALUES
(1294,771,0,8,0,9,0,0,0,0,771,0,0,0),
(1739,982,0,8,0,9,0,0,0,0,982,0,0,0),
(1740,983,0,8,0,9,0,0,0,0,983,0,0,0),
(1742,984,0,8,0,9,0,0,0,0,984,0,0,0),
(1762,995,0,8,0,9,0,0,0,0,995,0,0,0),
(1763,996,0,8,0,9,0,0,0,0,996,0,0,0),
(1764,997,0,8,0,9,0,0,0,0,997,0,0,0),
(1765,998,0,8,0,9,0,0,0,0,998,0,0,0),
(1834,1023,0,8,0,9,0,0,0,0,1023,0,0,0),
(1842,1027,0,8,0,9,0,0,0,0,1027,0,0,0),
(1879,1042,0,8,0,9,0,0,0,0,1042,0,0,0),
(1889,1048,0,8,0,9,0,0,0,0,1048,0,0,0),
(1906,1054,0,8,0,9,0,0,0,0,1054,0,0,0),
(2057,1066,0,8,0,9,0,0,0,0,1066,0,0,0);
DELETE FROM item_template WHERE entry = 911004;
DROP TEMPORARY TABLE IF EXISTS zc_tmp_item;
CREATE TEMPORARY TABLE zc_tmp_item SELECT * FROM item_template WHERE entry = 911001;
UPDATE zc_tmp_item SET entry = 911004, name = "Commander's Banner", Quality = 1, stackable = 1, maxcount = 1, bonding = 1,
  description = 'Target your NPC (or none for all nearby), then click the ground to move them there.',
  displayid = COALESCE((SELECT displayid FROM item_template WHERE name = 'Battle Standard of the Alliance' ORDER BY entry LIMIT 1),
                       (SELECT displayid FROM item_template WHERE entry = 6948)),
  ScriptName = 'item_zerocraft_command';
INSERT INTO item_template SELECT * FROM zc_tmp_item;
DROP TEMPORARY TABLE zc_tmp_item;
DELETE FROM spell_script_names WHERE spell_id = 24340 AND ScriptName = 'spell_zerocraft_command';
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES (24340, 'spell_zerocraft_command');
-- 15th loyalty slot
INSERT IGNORE INTO zerocraft_faction_slots (faction_template) VALUES (1234);
DELETE FROM factiontemplate_dbc WHERE ID = 1234;
INSERT INTO factiontemplate_dbc (ID, Faction, Flags, FactionGroup, FriendGroup, EnemyGroup, Enemies_1, Enemies_2, Enemies_3, Enemies_4, Friend_1, Friend_2, Friend_3, Friend_4) VALUES (1234,750,0,8,0,9,0,0,0,0,750,0,0,0);
DELETE FROM spell_script_names WHERE ScriptName = 'spell_zerocraft_command';
UPDATE item_template SET displayid = 31257, ScriptName = 'item_zerocraft_command' WHERE entry = 911004;
-- Commander's Banner: use an instant ground-target spell with no global cooldown
UPDATE item_template SET spellid_1 = 24340, spellcooldown_1 = -1, spellcategory_1 = 0, spellcategorycooldown_1 = -1 WHERE entry = 911004;
-- ZeroCraft: move custom items onto retired item IDs the client already knows,
-- so they get real icons and can be dragged onto action bars (no client patch).
DROP TEMPORARY TABLE IF EXISTS zc_map;
CREATE TEMPORARY TABLE zc_map (old_id INT, new_id INT);
INSERT INTO zc_map VALUES (911001,4427),(911002,5041),(911003,23700),(911004,23701);

DELETE it FROM item_template it JOIN zc_map m ON it.entry = m.new_id;
DROP TEMPORARY TABLE IF EXISTS zc_items;
CREATE TEMPORARY TABLE zc_items SELECT it.* FROM item_template it JOIN zc_map m ON it.entry = m.old_id;
UPDATE zc_items z JOIN zc_map m ON z.entry = m.old_id SET z.entry = m.new_id;
INSERT INTO item_template SELECT * FROM zc_items;

UPDATE playercreateinfo_item p JOIN zc_map m ON p.itemid = m.old_id SET p.itemid = m.new_id;
DELETE it FROM item_template it JOIN zc_map m ON it.entry = m.old_id;

DELETE FROM spell_script_names WHERE spell_id = 5505 AND ScriptName = 'spell_zerocraft_deploy_conjure';
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES (5505, 'spell_zerocraft_deploy_conjure');
-- Commander's Banner: ground circle from "Dropping Heavy Bomb" (instant, no cooldown, usable while mounted, 80 yd)
UPDATE item_template SET spellid_1 = 35070 WHERE entry = 23701;

DELETE FROM item_template WHERE entry = 8164;
DROP TEMPORARY TABLE IF EXISTS zc_tmp;
CREATE TEMPORARY TABLE zc_tmp SELECT * FROM item_template WHERE entry = 4427;
UPDATE zc_tmp SET entry = 8164, name = 'Deployable Auctioneer', Quality = 4, stackable = 20, description = 'Deploys a random auctioneer loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp;
DELETE FROM playercreateinfo_item WHERE itemid = 8164;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 8164, 1 FROM playercreateinfo;
DELETE FROM item_template WHERE entry = 17163;
DROP TEMPORARY TABLE IF EXISTS zc_tmp;
CREATE TEMPORARY TABLE zc_tmp SELECT * FROM item_template WHERE entry = 4427;
UPDATE zc_tmp SET entry = 17163, name = 'Deployable Flight Master', Quality = 4, stackable = 20, description = 'Deploys a random flight master loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp;
DELETE FROM playercreateinfo_item WHERE itemid = 17163;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 17163, 1 FROM playercreateinfo;
DELETE FROM item_template WHERE entry = 23656;
DROP TEMPORARY TABLE IF EXISTS zc_tmp;
CREATE TEMPORARY TABLE zc_tmp SELECT * FROM item_template WHERE entry = 4427;
UPDATE zc_tmp SET entry = 23656, name = 'Deployable Banker', Quality = 4, stackable = 20, description = 'Deploys a random banker loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp;
DELETE FROM playercreateinfo_item WHERE itemid = 23656;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 23656, 1 FROM playercreateinfo;
DELETE FROM item_template WHERE entry = 1267;
DROP TEMPORARY TABLE IF EXISTS zc_tmp;
CREATE TEMPORARY TABLE zc_tmp SELECT * FROM item_template WHERE entry = 4427;
UPDATE zc_tmp SET entry = 1267, name = 'Deployable Innkeeper', Quality = 3, stackable = 20, description = 'Deploys a random innkeeper loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp;
DELETE FROM playercreateinfo_item WHERE itemid = 1267;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 1267, 1 FROM playercreateinfo;
DELETE FROM item_template WHERE entry = 6213;
DROP TEMPORARY TABLE IF EXISTS zc_tmp;
CREATE TEMPORARY TABLE zc_tmp SELECT * FROM item_template WHERE entry = 4427;
UPDATE zc_tmp SET entry = 6213, name = 'Deployable Repair Vendor', Quality = 3, stackable = 20, description = 'Deploys a random repair vendor loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp;
DELETE FROM playercreateinfo_item WHERE itemid = 6213;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 6213, 1 FROM playercreateinfo;
UPDATE item_template SET Quality = 5 WHERE entry = 23700;  -- Deployable Hero: Legendary
-- ZeroCraft: dungeon & raid loot = deployable NPCs only
SET @ref := 911000;

-- one-time backups so this can be undone
CREATE TABLE IF NOT EXISTS zc_backup_creature_loot_template AS SELECT * FROM creature_loot_template;
CREATE TABLE IF NOT EXISTS zc_backup_gameobject_loot_template AS SELECT * FROM gameobject_loot_template;
CREATE TABLE IF NOT EXISTS zc_backup_creature_template_loot AS SELECT entry, lootid, mingold, maxgold FROM creature_template;

-- 1) NPC drop table (one pick per roll)
DELETE FROM reference_loot_template WHERE Entry = @ref;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) VALUES
(@ref, 4427, 0, 32, 0, 1, 1, 1, 1, 'Deployable Guard'),
(@ref, 5041, 0, 22, 0, 1, 1, 1, 1, 'Deployable Vendor'),
(@ref, 1267, 0, 10, 0, 1, 1, 1, 1, 'Deployable Innkeeper'),
(@ref, 6213, 0, 10, 0, 1, 1, 1, 1, 'Deployable Repair Vendor'),
(@ref, 8164, 0,  7, 0, 1, 1, 1, 1, 'Deployable Auctioneer'),
(@ref, 17163,0,  7, 0, 1, 1, 1, 1, 'Deployable Flight Master'),
(@ref, 23656,0,  7, 0, 1, 1, 1, 1, 'Deployable Banker'),
(@ref, 23700,0,  5, 0, 1, 1, 1, 1, 'Deployable Hero');

-- 2) creatures that only ever spawn inside dungeons/raids (plus their heroic/25-man versions)
DROP TEMPORARY TABLE IF EXISTS zc_base;
CREATE TEMPORARY TABLE zc_base (entry INT PRIMARY KEY, raid TINYINT);
INSERT IGNORE INTO zc_base
SELECT c.id, MAX(c.map IN (169,249,309,409,469,509,531,532,533,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724)) FROM creature c WHERE c.map IN (33,34,36,43,44,47,48,70,90,109,129,169,189,209,229,230,249,269,289,309,329,349,389,409,429,469,509,531,532,533,534,540,542,543,544,545,546,547,548,550,552,553,554,555,556,557,558,560,564,565,568,574,575,576,578,580,585,595,598,599,600,601,602,603,604,608,615,616,619,624,631,632,649,650,658,668,724)
  AND c.id NOT IN (SELECT id FROM creature WHERE map NOT IN (33,34,36,43,44,47,48,70,90,109,129,169,189,209,229,230,249,269,289,309,329,349,389,409,429,469,509,531,532,533,534,540,542,543,544,545,546,547,548,550,552,553,554,555,556,557,558,560,564,565,568,574,575,576,578,580,585,595,598,599,600,601,602,603,604,608,615,616,619,624,631,632,649,650,658,668,724)) GROUP BY c.id;

DROP TEMPORARY TABLE IF EXISTS zc_inst;
CREATE TEMPORARY TABLE zc_inst (entry INT PRIMARY KEY, raid TINYINT, heroic TINYINT, base INT);
INSERT IGNORE INTO zc_inst SELECT b.entry, b.raid, 0, b.entry FROM zc_base b;
INSERT IGNORE INTO zc_inst SELECT ct.difficulty_entry_1, b.raid, 1, b.entry FROM zc_base b JOIN creature_template ct ON ct.entry = b.entry WHERE ct.difficulty_entry_1 > 0;
INSERT IGNORE INTO zc_inst SELECT ct.difficulty_entry_2, b.raid, 1, b.entry FROM zc_base b JOIN creature_template ct ON ct.entry = b.entry WHERE ct.difficulty_entry_2 > 0;
INSERT IGNORE INTO zc_inst SELECT ct.difficulty_entry_3, b.raid, 1, b.entry FROM zc_base b JOIN creature_template ct ON ct.entry = b.entry WHERE ct.difficulty_entry_3 > 0;

-- loot ids used only by those creatures
DROP TEMPORARY TABLE IF EXISTS zc_loot;
CREATE TEMPORARY TABLE zc_loot (lootid INT PRIMARY KEY);
INSERT IGNORE INTO zc_loot SELECT ct.lootid FROM creature_template ct JOIN zc_inst i ON i.entry = ct.entry WHERE ct.lootid > 0;
DELETE l FROM zc_loot l JOIN creature_template ct ON ct.lootid = l.lootid LEFT JOIN zc_inst i ON i.entry = ct.entry WHERE i.entry IS NULL;

-- 3) wipe all their loot and money
DELETE t FROM creature_loot_template t JOIN zc_loot l ON l.lootid = t.Entry;
UPDATE creature_template ct JOIN zc_inst i ON i.entry = ct.entry SET ct.mingold = 0, ct.maxgold = 0;

-- 4) bosses: 2 NPC drops (normal dungeon) or 3 (heroic dungeon / any raid)
DROP TEMPORARY TABLE IF EXISTS zc_boss_base;
CREATE TEMPORARY TABLE zc_boss_base (entry INT PRIMARY KEY);
INSERT IGNORE INTO zc_boss_base SELECT b.entry FROM zc_base b JOIN creature_template ct ON ct.entry = b.entry
 WHERE ct.`rank` = 3 OR ct.ScriptName LIKE 'boss%' OR ct.entry IN (SELECT creditEntry FROM instance_encounters WHERE creditType = 0);

DROP TEMPORARY TABLE IF EXISTS zc_boss;
CREATE TEMPORARY TABLE zc_boss (entry INT PRIMARY KEY, rolls INT);
INSERT IGNORE INTO zc_boss SELECT i.entry, IF(i.raid OR i.heroic, 3, 2) FROM zc_inst i JOIN zc_boss_base bb ON bb.entry = i.base;

UPDATE creature_template ct JOIN zc_boss b ON b.entry = ct.entry SET ct.lootid = ct.entry WHERE ct.lootid = 0;
DELETE t FROM creature_loot_template t JOIN creature_template ct ON ct.lootid = t.Entry JOIN zc_boss b ON b.entry = ct.entry;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT ct.lootid, 0, @ref, 100, 0, 1, 0, b.rolls, b.rolls, 'ZeroCraft NPC drops' FROM creature_template ct JOIN zc_boss b ON b.entry = ct.entry;

-- 5) chests inside dungeons/raids: emptied; boss caches drop NPCs instead
DROP TEMPORARY TABLE IF EXISTS zc_go;
CREATE TEMPORARY TABLE zc_go (lootid INT PRIMARY KEY, raid TINYINT, cache TINYINT);
INSERT IGNORE INTO zc_go
SELECT gt.Data1, MAX(g.map IN (169,249,309,409,469,509,531,532,533,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724)),
  MAX((gt.name LIKE '%Cache%' OR gt.name LIKE '%Chest%' OR gt.name LIKE '%Spoils%' OR gt.name LIKE '%Gift%' OR gt.name LIKE '%Coffer%')
      AND gt.name NOT LIKE 'Battered%' AND gt.name NOT LIKE 'Solid%' AND gt.name NOT LIKE 'Large%' AND gt.name NOT LIKE 'Tattered%' AND gt.name NOT LIKE '%Trunk%')
FROM gameobject g JOIN gameobject_template gt ON gt.entry = g.id
WHERE g.map IN (33,34,36,43,44,47,48,70,90,109,129,169,189,209,229,230,249,269,289,309,329,349,389,409,429,469,509,531,532,533,534,540,542,543,544,545,546,547,548,550,552,553,554,555,556,557,558,560,564,565,568,574,575,576,578,580,585,595,598,599,600,601,602,603,604,608,615,616,619,624,631,632,649,650,658,668,724) AND gt.type = 3 AND gt.Data1 > 0 GROUP BY gt.Data1;
DELETE z FROM zc_go z JOIN gameobject_template gt ON gt.Data1 = z.lootid AND gt.type = 3 JOIN gameobject g ON g.id = gt.entry WHERE g.map NOT IN (33,34,36,43,44,47,48,70,90,109,129,169,189,209,229,230,249,269,289,309,329,349,389,409,429,469,509,531,532,533,534,540,542,543,544,545,546,547,548,550,552,553,554,555,556,557,558,560,564,565,568,574,575,576,578,580,585,595,598,599,600,601,602,603,604,608,615,616,619,624,631,632,649,650,658,668,724);
DELETE t FROM gameobject_loot_template t JOIN zc_go z ON z.lootid = t.Entry;
INSERT IGNORE INTO gameobject_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 0, @ref, 100, 0, 1, 0, IF(raid, 3, 2), IF(raid, 3, 2), 'ZeroCraft NPC drops' FROM zc_go WHERE cache = 1;


-- ZeroCraft: hero pool = friendly leaders + dungeon/raid villains (normal-sized)
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
-- ZeroCraft: fix hero pool (10182 is Rokaro, not Rexxar) + villains that are summoned by scripts rather than spawned
DELETE FROM zerocraft_hero_pool WHERE entry = 10182;
DROP TEMPORARY TABLE IF EXISTS zc_diff;
CREATE TEMPORARY TABLE zc_diff (entry INT PRIMARY KEY);
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_1 FROM creature_template WHERE difficulty_entry_1 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_2 FROM creature_template WHERE difficulty_entry_2 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_3 FROM creature_template WHERE difficulty_entry_3 > 0;
INSERT IGNORE INTO zerocraft_hero_pool (entry, villain, name)
INSERT IGNORE INTO zerocraft_hero_pool (entry, villain, name)
WHERE name IN ('Harbinger Skyriss','Mal''Ganis','Svala Sorrowgrave','Vazruden') AND entry NOT IN (SELECT entry FROM zc_diff) GROUP BY name;

-- ZeroCraft: guard pool = high-level city guards + dungeon elite humanoids (all deploy as level 55-60 elites)
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

-- ZeroCraft: move deploy items to retired IDs that have scroll icons in the client
DROP TEMPORARY TABLE IF EXISTS zc_map;
CREATE TEMPORARY TABLE zc_map (old_id INT, new_id INT, cls INT, sub INT);
INSERT INTO zc_map VALUES
 (4427, 823,   15, 0),   -- Guard:          INV_Scroll_01
 (5041, 842,   15, 0),   -- Vendor:         INV_Scroll_02
 (23700, 951,   0, 8),   -- Hero:           INV_Scroll_07
 (8164, 1078,  12, 0),   -- Auctioneer:     INV_Scroll_03
 (17163, 3504, 12, 0),   -- Flight Master:  INV_Scroll_05
 (23656, 3513, 12, 0),   -- Banker:         INV_Scroll_04
 (1267, 25747, 12, 0),   -- Innkeeper:      INV_Misc_Note_03
 (6213, 25748, 12, 0);   -- Repair Vendor:  INV_Misc_Note_04

DELETE it FROM item_template it JOIN zc_map m ON it.entry = m.new_id;
DROP TEMPORARY TABLE IF EXISTS zc_items;
CREATE TEMPORARY TABLE zc_items SELECT it.* FROM item_template it JOIN zc_map m ON it.entry = m.old_id;
UPDATE zc_items z JOIN zc_map m ON z.entry = m.old_id SET z.entry = m.new_id, z.class = m.cls, z.subclass = m.sub;
INSERT INTO item_template SELECT * FROM zc_items;

UPDATE playercreateinfo_item p JOIN zc_map m ON p.itemid = m.old_id SET p.itemid = m.new_id;
UPDATE reference_loot_template r JOIN zc_map m ON r.Item = m.old_id SET r.Item = m.new_id WHERE r.Entry = 911000;
DELETE it FROM item_template it JOIN zc_map m ON it.entry = m.old_id;

-- hunters start with The Eye of Nerub
INSERT IGNORE INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 23039, 1 FROM playercreateinfo WHERE class = 3;

-- ZeroCraft: two Commander's Banners (red = targeted NPC, blue = all NPCs)
UPDATE item_template SET name = "Commander's Banner: Target",
  description = "Moves your targeted NPC to the chosen spot."
WHERE entry = 23701;

DELETE FROM item_template WHERE entry = 23700;
DROP TEMPORARY TABLE IF EXISTS zc_banner;
CREATE TEMPORARY TABLE zc_banner SELECT * FROM item_template WHERE entry = 23701;
UPDATE zc_banner SET entry = 23700, displayid = 31256, name = "Commander's Banner: All",
  description = "Moves all of your NPCs to the chosen spot.", ScriptName = 'item_zerocraft_command_all';
INSERT INTO item_template SELECT * FROM zc_banner;
DROP TEMPORARY TABLE zc_banner;

SELECT entry, name, displayid, spellid_1, ScriptName FROM item_template WHERE entry IN (23700, 23701);

-- ZeroCraft: faction soldiers join the Guard scroll pool (kind = 'faction')
DELETE FROM zerocraft_guard_pool WHERE kind = 'faction';

DROP TEMPORARY TABLE IF EXISTS zc_diff;
CREATE TEMPORARY TABLE zc_diff (entry INT PRIMARY KEY);
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_1 FROM creature_template WHERE difficulty_entry_1 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_2 FROM creature_template WHERE difficulty_entry_2 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_3 FROM creature_template WHERE difficulty_entry_3 > 0;

DROP TEMPORARY TABLE IF EXISTS zc_spawned;
CREATE TEMPORARY TABLE zc_spawned (entry INT PRIMARY KEY);
INSERT IGNORE INTO zc_spawned SELECT id FROM creature WHERE map IN (0,1,30,530,571);
INSERT IGNORE INTO zc_spawned SELECT id FROM zerocraft_removed_creatures;

INSERT IGNORE INTO zerocraft_guard_pool (entry, kind, name)
SELECT ct.entry, 'faction', ct.name FROM creature_template ct JOIN zc_spawned s ON s.entry = ct.entry
WHERE ct.type = 7 AND (ct.npcflag & ~1) = 0 AND ct.`rank` IN (0,1) AND ct.maxlevel >= 55
  AND (ct.unit_flags & 0x02000000) = 0 AND (ct.flags_extra & 0x80) = 0
  AND (ct.name LIKE 'Argent %' OR ct.name LIKE 'Kirin Tor %' OR ct.name LIKE '%Ebon Blade%' OR ct.name LIKE 'Knight of the Ebon%'
    OR ct.name LIKE 'Scarlet %' OR ct.name LIKE 'Cenarion %' OR ct.name LIKE 'Shattered Sun %' OR ct.name LIKE 'Wyrmrest %'
    OR ct.name LIKE 'Sunreaver %' OR ct.name LIKE 'Silver Covenant %' OR ct.name LIKE 'Kor''kron %' OR ct.name LIKE 'Warsong %'
    OR ct.name LIKE 'Valiance %' OR ct.name LIKE '7th Legion %' OR ct.name LIKE 'Skybreaker %' OR ct.name LIKE 'Aldor %'
    OR ct.name LIKE 'Scryer %' OR ct.name LIKE 'Sha''tar %' OR ct.name LIKE 'Honor Hold %' OR ct.name LIKE 'Thrallmar %'
    OR ct.name LIKE 'Frostwolf %' OR ct.name LIKE 'Stormpike %' OR ct.name LIKE 'Mag''har %' OR ct.name LIKE 'Kurenai %'
    OR ct.name LIKE 'Explorers'' League %' OR ct.name LIKE 'Timbermaw %' OR ct.name LIKE 'Frenzyheart %' OR ct.name LIKE 'Crusader %'
    OR ct.name LIKE 'Brewfest %' OR ct.name LIKE 'Netherwing %' OR ct.name LIKE 'Lower City %' OR ct.name LIKE 'Keepers of Time %'
    OR ct.name LIKE 'Alliance Vanguard %' OR ct.name LIKE 'Horde %' OR ct.name LIKE 'Dalaran %' OR ct.name LIKE 'Ravenholdt %')
  AND ct.name NOT REGEXP 'Recruit|Prisoner|Captive|Wounded|Injured|Dead|Corpse|Spirit|Ghost|Trigger|Bunny|Invisible|Credit|Dummy|Target|Image|Vehicle|Mount|Cannon|Siege|Kill|Quest|Citizen|Refugee|Civilian|Peasant|Child|Orphan|DND|Brewfest'
  AND ct.entry NOT IN (SELECT entry FROM zc_diff)
  AND ct.entry NOT IN (SELECT entry FROM zerocraft_hero_pool)
  AND ct.entry NOT IN (SELECT entry FROM zerocraft_guard_pool);

-- soldiers no longer standing anywhere in the world deploy as elites
UPDATE creature_template ct JOIN zerocraft_guard_pool g ON g.entry = ct.entry AND g.kind = 'faction'
SET ct.`rank` = 1 WHERE ct.`rank` = 0 AND ct.entry NOT IN (SELECT id FROM creature);

DROP TEMPORARY TABLE zc_diff;
DROP TEMPORARY TABLE zc_spawned;
SELECT kind, COUNT(*) AS npcs FROM zerocraft_guard_pool GROUP BY kind;
SELECT name FROM zerocraft_guard_pool WHERE kind = 'faction' ORDER BY RAND() LIMIT 25;

-- ZeroCraft: Dungeon Finder rewards are NPC scrolls instead of emblems.
-- The level-60 "Satchel of Helpful Goods" becomes "Satchel of Scrolls" and holds one random NPC scroll
-- (same pool bosses drop). Random Dungeon gives 1 satchel, Random Heroic gives 2 - every run, not just daily.
SET @sat := (SELECT RewardItem1 FROM quest_template WHERE ID = 24886);

UPDATE item_template SET name = 'Satchel of Scrolls', description = 'Contains a deployable NPC scroll.' WHERE entry = @sat;
DELETE FROM item_loot_template WHERE Entry = @sat;
INSERT INTO item_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES (@sat, 0, 911000, 100, 0, 1, 0, 1, 1, 'ZeroCraft: one NPC scroll');

UPDATE quest_template SET
  RewardItem1 = @sat, RewardAmount1 = IF(ID IN (24788, 24789), 2, 1),
  RewardItem2 = 0, RewardAmount2 = 0, RewardItem3 = 0, RewardAmount3 = 0, RewardItem4 = 0, RewardAmount4 = 0,
  RewardChoiceItemID1 = 0, RewardChoiceItemQuantity1 = 0, RewardChoiceItemID2 = 0, RewardChoiceItemQuantity2 = 0,
  RewardChoiceItemID3 = 0, RewardChoiceItemQuantity3 = 0, RewardChoiceItemID4 = 0, RewardChoiceItemQuantity4 = 0,
  RewardChoiceItemID5 = 0, RewardChoiceItemQuantity5 = 0, RewardChoiceItemID6 = 0, RewardChoiceItemQuantity6 = 0
WHERE ID IN (24790, 24791, 24788, 24789);

SELECT @sat AS satchel, (SELECT name FROM item_template WHERE entry = @sat) AS name;
SELECT ID, LogTitle, RewardItem1, RewardAmount1, RewardMoney FROM quest_template WHERE ID IN (24790, 24791, 24788, 24789);

-- ZeroCraft: only Warsong Gulch and Arathi Basin are open.
-- Disable Alterac Valley (1), Eye of the Storm (7), Strand of the Ancients (9), Isle of Conquest (30).
DELETE FROM disables WHERE sourceType = 3 AND entry IN (1, 7, 9, 30);
INSERT INTO disables (sourceType, entry, flags, params_0, params_1, comment) VALUES
 (3, 1,  0, '', '', 'ZeroCraft: Alterac Valley closed'),
 (3, 7,  0, '', '', 'ZeroCraft: Eye of the Storm closed'),
 (3, 9,  0, '', '', 'ZeroCraft: Strand of the Ancients closed'),
 (3, 30, 0, '', '', 'ZeroCraft: Isle of Conquest closed');
SELECT entry, comment FROM disables WHERE sourceType = 3;

-- ZeroCraft: new characters start in their faction capital
-- Horde (orc 2, undead 5, tauren 6, troll 8, blood elf 10) -> Orgrimmar
-- Alliance (human 1, dwarf 3, night elf 4, gnome 7, draenei 11) -> Stormwind
UPDATE playercreateinfo SET map = 1, zone = 1637, position_x = 1629.36, position_y = -4373.39, position_z = 31.2564, orientation = 3.54839
WHERE race IN (2, 5, 6, 8, 10);
UPDATE playercreateinfo SET map = 0, zone = 1519, position_x = -8833.38, position_y = 628.628, position_z = 94.0066, orientation = 1.06535
WHERE race IN (1, 3, 4, 7, 11);
SELECT race, map, zone, COUNT(*) AS classes FROM playercreateinfo GROUP BY race, map, zone;

-- ZeroCraft: Founder's Charter - found your own guild. Uses a retired item ID that exists in the
-- client (so it has an icon and can sit on an action bar), preferring the guild-charter letter icon,
-- then notes, letters, scrolls and books. Cloned from the Commander's Banner (a usable bag item).
DROP TEMPORARY TABLE IF EXISTS zc_cand;
CREATE TEMPORARY TABLE zc_cand (id INT PRIMARY KEY, ord INT);
INSERT IGNORE INTO zc_cand VALUES (4992,0),(4995,1),(5174,2),(5863,3),(8463,4),(10791,5),(12563,6),(12564,7),(12780,8),(18987,9),(20803,10),(22300,11),(23560,12),(23561,13),(23562,14),(23910,15),(29588,16),(29589,17),(29590,18),(29912,19),(30689,20),(32469,21),(35277,22),(35783,23),(35941,24),(38654,25),(39355,26),(2725,27),(2728,28),(2730,29),(2732,30),(2734,31),(2735,32),(2738,33),(2740,34),(2742,35),(2744,36),(2745,37),(2748,38),(2749,39),(2750,40),(2751,41),(4432,42),(5359,43),(5390,44),(5734,45),(5799,46),(5826,47),(5839,48),(5852,49),(5949,50),(6221,51),(6222,52),(6304,53),(6305,54),(6306,55),(6342,56),(6343,57),(6344,58),(6345,59),(6346,60),(6347,61),(6348,62),(6349,63),(6375,64),(6376,65),(6377,66),(6489,67),(6490,68),(6491,69),(6492,70),(6493,71),(6494,72),(6495,73),(6496,74),(6497,75),(6620,76),(6842,77),(6929,78),(6997,79),(7231,80),(7309,81),(7675,82),(7907,83),(8383,84),(8525,85),(8594,86),(8687,87),(9153,88),(9251,89),(9252,90),(9253,91),(9299,92),(9311,93),(9544,94),(9547,95),(9552,96),(9553,97),(9558,98),(9560,99),(9565,100),(9568,101),(9573,102),(9577,103),(9579,104),(9581,105),(10022,106),(10563,107),(10564,108),(10565,109),(10566,110),(10664,111),(10792,112),(10793,113),(10794,114),(11038,115),(11039,116),(11081,117),(11098,118),(11101,119),(11148,120),(11150,121),(11151,122),(11152,123),(11163,124),(11164,125),(11165,126),(11166,127),(11167,128),(11168,129),(11202,130),(11203,131),(11204,132),(11205,133),(11206,134),(11207,135),(11208,136),(11223,137),(11224,138),(11225,139),(11226,140),(11270,141),(11282,142),(11283,143),(11312,144),(11368,145),(11446,146),(11470,147),(11616,148),(11813,149),(11843,150),(11886,151),(11941,152),(11942,153),(11943,154),(12635,155),(13448,156),(13449,157),(13450,158),(13451,159),(13471,160),(13507,161),(13852,162),(15868,163),(16214,164),(16215,165),(16216,166),(16217,167),(16218,168),(16219,169),(16220,170),(16221,171),(16222,172),(16223,173),(16224,174),(16242,175),(16243,176),(16244,177),(16245,178),(16246,179),(16247,180),(16248,181),(16249,182),(16250,183),(16251,184),(16252,185),(16253,186),(16254,187),(16255,188),(16307,189),(16645,190),(16646,191),(16647,192),(16648,193),(16649,194),(16650,195),(16651,196),(16652,197),(16653,198),(16654,199),(16655,200),(16656,201),(16657,202),(16785,203),(16790,204),(17725,205),(17781,206),(17823,207),(18226,208),(18234,209),(18259,210),(18260,211),(18642,212),(18643,213),(18779,214),(18780,215),(18781,216),(18782,217),(18783,218),(18784,219),(19338,220),(19444,221),(19445,222),(19446,223),(19447,224),(19448,225),(19449,226),(19642,227),(19978,228),(20023,229),(20404,230),(20405,231),(20541,232),(20545,233),(20552,234),(20676,235),(20677,236),(20678,237),(20679,238),(20726,239),(20727,240),(20728,241),(20729,242),(20730,243),(20731,244),(20732,245),(20733,246),(20734,247),(20735,248),(20736,249),(20751,250),(20752,251),(20753,252),(20754,253),(20755,254),(20756,255),(20757,256),(20758,257),(20810,258),(21029,259),(21142,260),(21143,261),(21807,262),(22117,263),(22119,264),(22120,265),(22121,266),(22122,267),(22123,268),(22392,269),(22530,270),(22531,271),(22532,272),(22533,273),(22534,274),(22535,275),(22536,276),(22537,277),(22538,278),(22539,279),(22540,280),(22541,281),(22542,282),(22543,283),(22544,284),(22545,285),(22546,286),(22547,287),(22548,288),(22549,289),(22551,290),(22552,291),(22553,292),(22554,293),(22555,294),(22556,295),(22557,296),(22558,297),(22559,298),(22560,299),(22561,300),(22562,301),(22563,302),(22564,303),(22565,304),(22595,305),(22600,306),(22601,307),(22602,308),(22603,309),(22604,310),(22605,311),(22606,312),(22607,313),(22608,314),(22609,315),(22610,316),(22611,317),(22612,318),(22613,319),(22614,320),(22615,321),(22616,322),(22617,323),(22618,324),(22619,325),(22620,326),(22621,327),(22622,328),(22623,329),(22624,330),(22625,331),(22626,332),(22946,333),(22948,334),(22974,335),(22975,336),(23024,337),(23695,338),(23778,339),(23858,340),(23866,341),(23867,342),(23868,343),(24000,344),(24003,345),(24005,346),(24132,347),(24223,348),(24277,349),(24367,350),(24373,351),(24471,352),(25468,353),(25747,354),(25748,355),(25749,356),(25750,357),(25751,358),(25752,359),(25753,360),(25754,361),(25755,362),(25756,363),(25757,364),(25766,365),(25848,366),(25849,367),(25866,368),(28270,369),(28271,370),(28272,371),(28273,372),(28274,373),(28276,374),(28277,375),(28279,376),(28280,377),(28281,378),(28282,379),(28359,380),(31707,381),(32454,382),(32620,383),(32888,384),(32916,385),(33050,386),(33051,387),(33148,388),(33149,389),(33150,390),(33151,391),(33152,392),(33153,393),(33165,394),(33277,395),(33307,396),(33455,397),(33564,398),(33565,399),(33856,400),(33955,401),(34110,402),(34171,403),(34801,404),(34872,405),(35297,406),(35298,407),(35299,408),(35498,409),(35500,410),(35737,411),(35756,412),(35819,413),(36837,414),(36838,415),(36839,416),(36840,417),(36848,418),(36849,419),(36850,420),(36851,421),(36877,422),(37148,423),(37267,424),(37268,425),(37269,426),(37326,427),(37327,428),(37328,429),(37329,430),(37330,431),(37331,432),(37332,433),(37333,434),(37334,435),(37335,436),(37336,437),(37337,438),(37338,439),(37341,440),(37342,441),(37343,442),(37345,443),(37346,444),(37348,445),(37571,446),(37599,447),(37736,448),(37737,449),(37910,450),(37911,451),(37912,452),(37913,453),(40947,454),(42475,455),(42476,456),(43984,457),(44459,458),(44460,459),(44461,460),(44468,461),(44858,462),(44859,463),(44860,464),(44861,465),(44862,466),(45050,467),(45924,468),(46803,469),(46804,470),(46805,471),(46806,472),(46807,473),(49192,474),(49193,475),(49923,476),(49924,477),(52562,478),(52563,479),(52706,480),(52707,481),(53048,482),(889,483),(910,484),(1293,485),(1294,486),(1327,487),(1353,488),(1381,489),(1407,490),(1408,491),(1409,492),(1410,493),(1894,494),(2187,495),(2188,496),(2619,497),(2628,498),(2874,499),(2885,500),(2891,501),(2956,502),(3238,503),(3252,504),(3468,505),(3601,506),(3701,507),(3721,508),(3921,509),(4098,510),(4100,511),(4101,512),(4102,513),(4429,514),(4433,515),(4482,516),(4486,517),(4494,518),(4514,519),(4533,520),(4620,521),(4622,522),(4834,523),(4881,524),(4883,525),(5353,526),(5354,527),(5380,528),(5381,529),(5539,530),(5594,531),(5628,532),(5717,533),(5735,534),(5737,535),(5804,536),(5807,537),(5827,538),(5846,539),(5850,540),(5882,541),(5946,542),(5947,543),(5948,544),(5960,545),(5998,546),(6065,547),(6075,548),(6276,549),(6277,550),(6279,551),(6280,552),(6846,553),(6847,554),(6926,555),(6996,556),(7628,557),(7715,558),(8070,559),(9235,560),(9236,561),(9329,562),(9436,563),(9542,564),(9548,565),(9555,566),(9570,567),(9571,568),(9576,569),(10443,570),(10643,571),(10678,572),(10679,573),(10680,574),(10681,575),(10790,576),(11103,577),(11366,578),(11367,579),(12438,580),(12652,581),(13362,582),(15998,583),(16189,584),(16209,585),(16263,586),(16310,587),(16763,588),(16764,589),(16765,590),(17126,591),(17355,592),(20460,593),(20461,594),(20484,595),(20765,596),(20805,597),(20808,598),(20809,599),(20949,600),(21032,601),(21043,602),(21131,603),(21132,604),(21133,605),(21266,606),(21314,607),(21386,608),(22284,609),(22285,610),(22286,611),(22287,612),(22289,613),(22290,614),(22293,615),(22294,616),(22297,617),(22299,618),(22648,619),(22649,620),(22650,621),(22717,622),(22723,623),(22735,624),(22930,625),(22932,626),(22944,627),(22945,628),(22970,629),(22972,630),(22973,631),(22977,632),(23500,633),(23569,634),(23662,635),(23853,636),(23902,637),(23919,638),(23929,639),(23930,640),(23937,641),(24382,642),(24415,643),(24482,644),(24573,645),(25424,646),(26048,647),(28664,648),(29545,649),(29546,650),(29797,651),(30649,652),(31662,653),(31698,654),(32726,655),(33010,656),(33037,657),(33114,658),(33115,659),(34089,660),(34132,661),(34687,662),(34695,663),(35558,664),(35855,665),(36756,666),(36780,667),(36832,668),(36833,669),(37003,670),(37741,671),(38267,672),(38319,673),(38605,674),(38608,675),(39317,676),(39647,677),(40640,678),(42953,679),(45121,680),(45122,681),(46830,682),(47048,683),(49225,684),(49372,685),(49536,686),(49676,687),(49677,688),(49872,689),(52731,690),(728,691),(745,692),(748,693),(823,694),(842,695),(875,696),(900,697),(901,698),(902,699),(903,700),(951,701),(954,702),(955,703),(1042,704),(1043,705),(1044,706),(1078,707),(1164,708),(1180,709),(1181,710),(1208,711),(1252,712),(1283,713),(1307,714),(1323,715),(1356,716),(1477,717),(1478,718),(1492,719),(1599,720),(1637,721),(1656,722),(1711,723),(1712,724),(1971,725),(1972,726),(2005,727),(2006,728),(2007,729),(2008,730),(2113,731),(2223,732),(2289,733),(2290,734),(2404,735),(2405,736),(2406,737),(2407,738),(2408,739),(2409,740),(2553,741),(2554,742),(2555,743),(2556,744),(2598,745),(2599,746),(2600,747),(2601,748),(2602,749),(2637,750),(2638,751),(2639,752),(2697,753),(2698,754),(2699,755),(2700,756),(2701,757),(2720,758),(2722,759),(2724,760),(2832,761),(2837,762),(2839,763),(2881,764),(2882,765),(2883,766),(2889,767),(3012,768),(3013,769),(3017,770),(3155,771),(3248,772),(3250,773),(3393,774),(3394,775),(3395,776),(3396,777),(3503,778),(3504,779),(3512,780),(3513,781),(3518,782),(3519,783),(3521,784),(3608,785),(3609,786),(3610,787),(3611,788),(3612,789),(3668,790),(3677,791),(3678,792),(3679,793),(3680,794),(3681,795),(3682,796),(3683,797),(3706,798),(3707,799),(3718,800),(3734,801),(3735,802),(3736,803),(3737,804),(3767,805),(3790,806),(3830,807),(3831,808),(3832,809),(3866,810),(3867,811),(3868,812),(3869,813),(3870,814),(3871,815),(3872,816),(3873,817),(3874,818),(3875,819),(3898,820),(4056,821),(4292,822),(4293,823),(4294,824),(4295,825),(4296,826),(4297,827),(4298,828),(4299,829),(4300,830),(4301,831),(4345,832),(4346,833),(4347,834),(4348,835),(4349,836),(4350,837),(4351,838),(4352,839),(4353,840),(4354,841),(4355,842),(4356,843),(4408,844),(4409,845),(4410,846),(4411,847),(4412,848),(4413,849),(4414,850),(4415,851),(4416,852),(4417,853),(4419,854),(4420,855),(4421,856),(4422,857),(4423,858),(4424,859),(4425,860),(4426,861),(4427,862),(4472,863),(4518,864),(4519,865),(4520,866),(4597,867),(4609,868),(4624,869),(4649,870),(4650,871),(4819,872),(4997,873),(5041,874),(5083,875),(5126,876),(5127,877),(5129,878),(5130,879),(5131,880),(5132,881),(5272,882),(5348,883),(5455,884),(5456,885),(5482,886),(5483,887),(5484,888),(5485,889),(5486,890),(5487,891),(5488,892),(5489,893),(5528,894),(5543,895),(5577,896),(5578,897),(5640,898),(5641,899),(5642,900),(5643,901),(5657,902),(5718,903),(5731,904),(5768,905),(5769,906),(5771,907),(5772,908),(5773,909),(5774,910),(5775,911),(5786,912),(5787,913),(5788,914),(5789,915),(5917,916),(5972,917),(5973,918),(5974,919),(6039,920),(6044,921),(6045,922),(6046,923),(6047,924),(6053,925),(6054,926),(6055,927),(6056,928),(6057,929),(6068,930),(6167,931),(6211,932),(6270,933),(6271,934),(6272,935),(6273,936),(6274,937),(6275,938),(6278,939),(6325,940),(6326,941),(6328,942),(6329,943),(6330,944),(6368,945),(6369,946),(6390,947),(6391,948),(6401,949),(6474,950),(6475,951),(6476,952),(6516,953),(6544,954),(6623,955),(6648,956),(6649,957),(6650,958),(6661,959),(6663,960),(6672,961),(6710,962),(6716,963),(6734,964),(6735,965),(6736,966),(6891,967),(6892,968),(6988,969),(7084,970),(7085,971),(7086,972),(7087,973),(7088,974),(7089,975),(7090,976),(7091,977),(7092,978),(7093,979),(7114,980),(7192,981),(7275,982),(7288,983),(7289,984),(7290,985),(7308,986),(7360,987),(7361,988),(7362,989),(7363,990),(7364,991),(7449,992),(7450,993),(7451,994),(7452,995),(7453,996),(7516,997),(7560,998),(7561,999),(7587,1000),(7613,1001),(7678,1002),(7742,1003),(7975,1004),(7976,1005),(7977,1006),(7978,1007),(7979,1008),(7980,1009),(7981,1010),(7982,1011),(7983,1012),(7984,1013),(7985,1014),(7986,1015),(7987,1016),(7988,1017),(7989,1018),(7990,1019),(7991,1020),(7992,1021),(7993,1022),(7994,1023),(7995,1024),(8028,1025),(8029,1026),(8030,1027),(8164,1028),(8384,1029),(8385,1030),(8386,1031),(8387,1032),(8388,1033),(8389,1034),(8390,1035),(8395,1036),(8397,1037),(8398,1038),(8399,1039),(8400,1040),(8401,1041),(8402,1042),(8403,1043),(8404,1044),(8405,1045),(8406,1046),(8407,1047),(8408,1048),(8409,1049),(8547,1050),(9250,1051),(9266,1052),(9293,1053),(9294,1054),(9295,1055),(9296,1056),(9297,1057),(9298,1058),(9300,1059),(9301,1060),(9302,1061),(9303,1062),(9304,1063),(9305,1064),(9323,1065),(9367,1066),(9370,1067),(9546,1068),(9559,1069),(9569,1070),(9574,1071),(9578,1072),(10300,1073),(10301,1074),(10302,1075),(10303,1076),(10304,1077),(10305,1078),(10306,1079),(10307,1080),(10308,1081),(10309,1082),(10310,1083),(10311,1084),(10312,1085),(10313,1086),(10314,1087),(10315,1088),(10316,1089),(10317,1090),(10318,1091),(10319,1092),(10320,1093),(10321,1094),(10322,1095),(10323,1096),(10324,1097),(10325,1098),(10326,1099),(10424,1100),(10463,1101),(10601,1102),(10602,1103),(10603,1104),(10604,1105),(10605,1106),(10606,1107),(10607,1108),(10608,1109),(10609,1110),(10621,1111),(10644,1112),(10713,1113),(10728,1114),(10818,1115),(10858,1116),(11108,1117),(11125,1118),(11466,1119),(11610,1120),(11611,1121),(11612,1122),(11614,1123),(11615,1124),(11827,1125),(11828,1126),(11844,1127),(12060,1128),(12162,1129),(12163,1130),(12164,1131),(12226,1132),(12227,1133),(12228,1134),(12229,1135),(12231,1136),(12232,1137),(12233,1138),(12239,1139),(12240,1140),(12261,1141),(12562,1142),(12682,1143),(12683,1144),(12684,1145),(12685,1146),(12687,1147),(12688,1148),(12689,1149),(12690,1150),(12691,1151),(12692,1152),(12693,1153),(12694,1154),(12695,1155),(12696,1156),(12697,1157),(12698,1158),(12699,1159),(12700,1160),(12701,1161),(12702,1162),(12703,1163),(12704,1164),(12705,1165),(12706,1166),(12707,1167),(12711,1168),(12713,1169),(12714,1170),(12715,1171),(12716,1172),(12717,1173),(12718,1174),(12719,1175),(12720,1176),(12725,1177),(12726,1178),(12727,1179),(12728,1180),(12730,1181),(12762,1182),(12765,1183),(12766,1184),(12768,1185),(12816,1186),(12817,1187),(12818,1188),(12819,1189),(12821,1190),(12823,1191),(12824,1192),(12825,1193),(12826,1194),(12827,1195),(12828,1196),(12830,1197),(12831,1198),(12832,1199),(12833,1200),(12834,1201),(12835,1202),(12836,1203),(12837,1204),(12838,1205),(12839,1206),(12958,1207),(13287,1208),(13288,1209),(13308,1210),(13309,1211),(13310,1212),(13311,1213),(13363,1214),(13364,1215),(13476,1216),(13477,1217),(13478,1218),(13479,1219),(13480,1220),(13481,1221),(13482,1222),(13483,1223),(13484,1224),(13485,1225),(13486,1226),(13487,1227),(13488,1228),(13489,1229),(13490,1230),(13491,1231),(13492,1232),(13493,1233),(13494,1234),(13495,1235),(13496,1236),(13497,1237),(13499,1238),(13500,1239),(13501,1240),(13517,1241),(13518,1242),(13519,1243),(13520,1244),(13521,1245),(13522,1246),(13939,1247),(13940,1248),(13941,1249),(13942,1250),(13943,1251),(13945,1252),(13946,1253),(13947,1254),(13948,1255),(13949,1256),(14466,1257),(14467,1258),(14468,1259),(14469,1260),(14470,1261),(14471,1262),(14472,1263),(14473,1264),(14474,1265),(14476,1266),(14477,1267),(14478,1268),(14479,1269),(14480,1270),(14481,1271),(14482,1272),(14483,1273),(14484,1274),(14485,1275),(14486,1276),(14488,1277),(14489,1278),(14490,1279),(14491,1280),(14492,1281),(14493,1282),(14494,1283),(14495,1284),(14496,1285),(14497,1286),(14498,1287),(14499,1288),(14500,1289),(14501,1290),(14504,1291),(14505,1292),(14506,1293),(14507,1294),(14508,1295),(14509,1296),(14510,1297),(14511,1298),(14512,1299),(14513,1300),(14514,1301),(14526,1302),(14627,1303),(14630,1304),(14634,1305),(14635,1306),(14639,1307),(14679,1308),(15724,1309),(15725,1310),(15726,1311),(15727,1312),(15728,1313),(15729,1314),(15730,1315),(15731,1316),(15732,1317),(15733,1318),(15734,1319),(15735,1320),(15737,1321),(15738,1322),(15739,1323),(15740,1324),(15741,1325),(15742,1326),(15743,1327),(15744,1328),(15745,1329),(15746,1330),(15747,1331),(15748,1332),(15749,1333),(15751,1334),(15752,1335),(15753,1336),(15754,1337),(15755,1338),(15756,1339),(15757,1340),(15758,1341),(15759,1342),(15760,1343),(15761,1344),(15762,1345),(15763,1346),(15764,1347),(15765,1348),(15768,1349),(15769,1350),(15770,1351),(15771,1352),(15772,1353),(15773,1354),(15774,1355),(15775,1356),(15776,1357),(15777,1358),(15779,1359),(15780,1360),(15781,1361),(15788,1362),(16041,1363),(16042,1364),(16043,1365),(16044,1366),(16045,1367),(16046,1368),(16047,1369),(16048,1370),(16049,1371),(16050,1372),(16051,1373),(16052,1374),(16053,1375),(16054,1376),(16055,1377),(16056,1378),(16110,1379),(16111,1380),(16746,1381),(16767,1382),(16783,1383),(17008,1384),(17017,1385),(17018,1386),(17022,1387),(17023,1388),(17025,1389),(17049,1390),(17051,1391),(17052,1392),(17053,1393),(17059,1394),(17060,1395),(17062,1396),(17200,1397),(17201,1398),(17353,1399),(17442,1400),(17706,1401),(17709,1402),(17720,1403),(17722,1404),(17724,1405),(17731,1406),(18046,1407),(18160,1408),(18235,1409),(18239,1410),(18252,1411),(18257,1412),(18264,1413),(18265,1414),(18267,1415),(18290,1416),(18291,1417),(18292,1418),(18414,1419),(18415,1420),(18416,1421),(18417,1422),(18418,1423),(18487,1424),(18514,1425),(18515,1426),(18516,1427),(18517,1428),(18518,1429),(18519,1430),(18592,1431),(18593,1432),(18628,1433),(18647,1434),(18648,1435),(18649,1436),(18650,1437),(18651,1438),(18652,1439),(18653,1440),(18654,1441),(18655,1442),(18656,1443),(18657,1444),(18658,1445),(18661,1446),(18670,1447),(18731,1448),(18922,1449),(18949,1450),(19020,1451),(19027,1452),(19202,1453),(19203,1454),(19204,1455),(19205,1456),(19206,1457),(19207,1458),(19208,1459),(19209,1460),(19210,1461),(19211,1462),(19212,1463),(19215,1464),(19216,1465),(19217,1466),(19218,1467),(19219,1468),(19220,1469),(19229,1470),(19237,1471),(19238,1472),(19239,1473),(19240,1474),(19241,1475),(19242,1476),(19243,1477),(19244,1478),(19245,1479),(19246,1480),(19247,1481),(19248,1482),(19249,1483),(19250,1484),(19251,1485),(19252,1486),(19253,1487),(19254,1488),(19255,1489),(19256,1490),(19266,1491),(19326,1492),(19327,1493),(19328,1494),(19329,1495),(19330,1496),(19331,1497),(19332,1498),(19333,1499),(19343,1500),(19423,1501),(19424,1502),(19442,1503),(19443,1504),(19451,1505),(19452,1506),(19453,1507),(19454,1508),(19764,1509),(19765,1510),(19766,1511),(19769,1512),(19770,1513),(19771,1514),(19772,1515),(19773,1516),(19776,1517),(19777,1518),(19778,1519),(19779,1520),(19780,1521),(19781,1522),(20000,1523),(20001,1524),(20011,1525),(20012,1526),(20013,1527),(20014,1528),(20040,1529),(20075,1530),(20253,1531),(20254,1532),(20382,1533),(20455,1534),(20456,1535),(20467,1536),(20506,1537),(20507,1538),(20508,1539),(20509,1540),(20510,1541),(20511,1542),(20518,1543),(20526,1544),(20527,1545),(20528,1546),(20531,1547),(20532,1548),(20533,1549),(20535,1550),(20540,1551),(20542,1552),(20543,1553),(20544,1554),(20546,1555),(20547,1556),(20548,1557),(20553,1558),(20554,1559),(20555,1560),(20576,1561),(20761,1562),(20806,1563),(20807,1564),(20854,1565),(20855,1566),(20856,1567),(20939,1568),(20940,1569),(20941,1570),(20942,1571),(20943,1572),(20944,1573),(20945,1574),(20946,1575),(20947,1576),(20948,1577),(20970,1578),(20971,1579),(20972,1580),(20973,1581),(20974,1582),(20975,1583),(20976,1584),(21099,1585),(21140,1586),(21158,1587),(21159,1588),(21160,1589),(21161,1590),(21165,1591),(21166,1592),(21167,1593),(21219,1594),(21245,1595),(21246,1596),(21247,1597),(21248,1598),(21249,1599),(21250,1600),(21251,1601),(21252,1602),(21253,1603),(21255,1604),(21256,1605),(21257,1606),(21258,1607),(21259,1608),(21260,1609),(21261,1610),(21262,1611),(21263,1612),(21264,1613),(21265,1614),(21358,1615),(21369,1616),(21371,1617),(21378,1618),(21379,1619),(21380,1620),(21381,1621),(21382,1622),(21384,1623),(21385,1624),(21514,1625),(21547,1626),(21548,1627),(21711,1628),(21722,1629),(21723,1630),(21724,1631),(21725,1632),(21726,1633),(21727,1634),(21728,1635),(21729,1636),(21730,1637),(21731,1638),(21732,1639),(21733,1640),(21734,1641),(21735,1642),(21737,1643),(21738,1644),(21739,1645),(21740,1646),(21741,1647),(21742,1648),(21743,1649),(21749,1650),(21750,1651),(21751,1652),(21776,1653),(21892,1654),(21893,1655),(21894,1656),(21895,1657),(21896,1658),(21897,1659),(21898,1660),(21899,1661),(21900,1662),(21901,1663),(21902,1664),(21903,1665),(21904,1666),(21905,1667),(21906,1668),(21907,1669),(21908,1670),(21909,1671),(21910,1672),(21911,1673),(21912,1674),(21913,1675),(21914,1676),(21915,1677),(21916,1678),(21917,1679),(21918,1680),(21919,1681),(21924,1682),(21940,1683),(21941,1684),(21942,1685),(21943,1686),(21944,1687),(21945,1688),(21947,1689),(21948,1690),(21949,1691),(21950,1692),(21951,1693),(21952,1694),(21953,1695),(21954,1696),(21955,1697),(21956,1698),(21957,1699),(21958,1700),(21959,1701),(22174,1702),(22209,1703),(22214,1704),(22219,1705),(22220,1706),(22221,1707),(22222,1708),(22307,1709),(22308,1710),(22309,1711),(22310,1712),(22312,1713),(22388,1714),(22389,1715),(22390,1716),(22568,1717),(22590,1718),(22591,1719),(22592,1720),(22593,1721),(22594,1722),(22629,1723),(22647,1724),(22683,1725),(22684,1726),(22685,1727),(22686,1728),(22687,1729),(22692,1730),(22694,1731),(22695,1732),(22696,1733),(22697,1734),(22698,1735),(22703,1736),(22704,1737),(22705,1738),(22729,1739),(22765,1740),(22766,1741),(22767,1742),(22768,1743),(22769,1744),(22770,1745),(22771,1746),(22772,1747),(22773,1748),(22774,1749),(22822,1750),(22900,1751),(22901,1752),(22902,1753),(22903,1754),(22904,1755),(22905,1756),(22906,1757),(22907,1758),(22908,1759),(22909,1760),(22910,1761),(22911,1762),(22912,1763),(22913,1764),(22914,1765),(22915,1766),(22916,1767),(22917,1768),(22918,1769),(22919,1770),(22920,1771),(22921,1772),(22922,1773),(22923,1774),(22924,1775),(22925,1776),(22926,1777),(22927,1778),(23008,1779),(23010,1780),(23011,1781),(23012,1782),(23013,1783),(23016,1784),(23055,1785),(23130,1786),(23131,1787),(23133,1788),(23134,1789),(23135,1790),(23136,1791),(23137,1792),(23138,1793),(23140,1794),(23141,1795),(23142,1796),(23143,1797),(23144,1798),(23145,1799),(23146,1800),(23147,1801),(23148,1802),(23149,1803),(23150,1804),(23151,1805),(23152,1806),(23153,1807),(23154,1808),(23155,1809),(23227,1810),(23340,1811),(23341,1812),(23342,1813),(23483,1814),(23574,1815),(23590,1816),(23591,1817),(23592,1818),(23593,1819),(23594,1820),(23595,1821),(23596,1822),(23597,1823),(23598,1824),(23599,1825),(23600,1826),(23601,1827),(23602,1828),(23603,1829),(23604,1830),(23605,1831),(23606,1832),(23607,1833),(23608,1834),(23609,1835),(23610,1836),(23611,1837),(23612,1838),(23613,1839),(23615,1840),(23617,1841),(23618,1842),(23619,1843),(23620,1844),(23621,1845),(23622,1846),(23623,1847),(23624,1848),(23625,1849),(23626,1850),(23627,1851),(23628,1852),(23629,1853),(23630,1854),(23631,1855),(23632,1856),(23633,1857),(23634,1858),(23635,1859),(23636,1860),(23637,1861),(23638,1862),(23639,1863),(23693,1864),(23740,1865),(23777,1866),(23780,1867),(23797,1868),(23798,1869),(23799,1870),(23800,1871),(23802,1872),(23803,1873),(23804,1874),(23805,1875),(23806,1876),(23807,1877),(23808,1878),(23809,1879),(23810,1880),(23811,1881),(23812,1882),(23813,1883),(23814,1884),(23815,1885),(23816,1886),(23817,1887),(23874,1888),(23882,1889),(23883,1890),(23884,1891),(23885,1892),(23887,1893),(23888,1894),(23890,1895),(23891,1896),(23892,1897),(23893,1898),(23899,1899),(23928,1900),(23990,1901),(24001,1902),(24002,1903),(24147,1904),(24148,1905),(24149,1906),(24158,1907),(24159,1908),(24160,1909),(24161,1910),(24162,1911),(24163,1912),(24164,1913),(24165,1914),(24166,1915),(24167,1916),(24168,1917),(24169,1918),(24170,1919),(24171,1920),(24172,1921),(24173,1922),(24174,1923),(24175,1924),(24176,1925),(24177,1926),(24178,1927),(24179,1928),(24180,1929),(24181,1930),(24182,1931),(24183,1932),(24192,1933),(24193,1934),(24194,1935),(24195,1936),(24196,1937),(24197,1938),(24198,1939),(24199,1940),(24200,1941),(24201,1942),(24202,1943),(24203,1944),(24204,1945),(24205,1946),(24206,1947),(24207,1948),(24208,1949),(24209,1950),(24210,1951),(24211,1952),(24212,1953),(24213,1954),(24214,1955),(24215,1956),(24216,1957),(24217,1958),(24218,1959),(24219,1960),(24220,1961),(24228,1962),(24229,1963),(24230,1964),(24292,1965),(24293,1966),(24294,1967),(24295,1968),(24296,1969),(24297,1970),(24298,1971),(24299,1972),(24300,1973),(24301,1974),(24302,1975),(24303,1976),(24304,1977),(24305,1978),(24306,1979),(24307,1980),(24308,1981),(24309,1982),(24310,1983),(24311,1984),(24312,1985),(24313,1986),(24314,1987),(24315,1988),(24316,1989),(24323,1990),(24330,1991),(24399,1992),(25526,1993),(25705,1994),(25706,1995),(25720,1996),(25721,1997),(25722,1998),(25725,1999),(25726,2000),(25728,2001),(25729,2002),(25730,2003),(25731,2004),(25732,2005),(25733,2006),(25734,2007),(25735,2008),(25736,2009),(25737,2010),(25738,2011),(25739,2012),(25740,2013),(25741,2014),(25742,2015),(25743,2016),(25765,2017),(25846,2018),(25847,2019),(25869,2020),(25870,2021),(25887,2022),(25888,2023),(25902,2024),(25903,2025),(25904,2026),(25905,2027),(25906,2028),(25907,2029),(25908,2030),(25909,2031),(25910,2032),(27419,2033),(27421,2034),(27498,2035),(27499,2036),(27500,2037),(27501,2038),(27502,2039),(27503,2040),(27504,2041),(27684,2042),(27685,2043),(27686,2044),(27687,2045),(27688,2046),(27689,2047),(27690,2048),(27691,2049),(27692,2050),(27693,2051),(27694,2052),(27695,2053),(27696,2054),(27697,2055),(27698,2056),(27699,2057),(27700,2058),(28024,2059),(28046,2060),(28099,2061),(28105,2062),(28107,2063),(28113,2064),(28114,2065),(28291,2066),(28376,2067),(28472,2068),(28473,2069),(28474,2070),(28571,2071),(28580,2072),(28596,2073),(28632,2074),(28877,2075),(28879,2076),(28880,2077),(28890,2078),(28891,2079),(28892,2080),(28893,2081),(28894,2082),(28895,2083),(28896,2084),(28897,2085),(28898,2086),(28899,2087),(28900,2088),(28901,2089),(28902,2090),(29120,2091),(29213,2092),(29214,2093),(29215,2094),(29217,2095),(29218,2096),(29219,2097),(29232,2098),(29587,2099),(29664,2100),(29669,2101),(29672,2102),(29673,2103),(29674,2104),(29675,2105),(29677,2106),(29682,2107),(29684,2108),(29689,2109),(29691,2110),(29693,2111),(29698,2112),(29700,2113),(29701,2114),(29702,2115),(29703,2116),(29704,2117),(29713,2118),(29714,2119),(29717,2120),(29718,2121),(29719,2122),(29720,2123),(29721,2124),(29722,2125),(29723,2126),(29724,2127),(29725,2128),(29726,2129),(29727,2130),(29728,2131),(29729,2132),(29730,2133),(29731,2134),(29732,2135),(29733,2136),(29734,2137),(29769,2138),(30156,2139),(30280,2140),(30281,2141),(30282,2142),(30283,2143),(30301,2144),(30302,2145),(30303,2146),(30304,2147),(30305,2148),(30306,2149),(30307,2150),(30308,2151),(30321,2152),(30322,2153),(30323,2154),(30324,2155),(30428,2156),(30443,2157),(30444,2158),(30453,2159),(30469,2160),(30470,2161),(30471,2162),(30472,2163),(30473,2164),(30474,2165),(30483,2166),(30539,2167),(30540,2168),(30617,2169),(30811,2170),(30826,2171),(30833,2172),(30842,2173),(30843,2174),(30844,2175),(31120,2176),(31260,2177),(31261,2178),(31271,2179),(31354,2180),(31355,2181),(31356,2182),(31357,2183),(31358,2184),(31359,2185),(31361,2186),(31362,2187),(31390,2188),(31391,2189),(31392,2190),(31393,2191),(31394,2192),(31395,2193),(31401,2194),(31402,2195),(31550,2196),(31674,2197),(31675,2198),(31680,2199),(31681,2200),(31682,2201),(31708,2202),(31740,2203),(31870,2204),(31871,2205),(31872,2206),(31873,2207),(31874,2208),(31875,2209),(31876,2210),(31877,2211),(31878,2212),(31879,2213),(32070,2214),(32071,2215),(32274,2216),(32277,2217),(32281,2218),(32282,2219),(32283,2220),(32284,2221),(32285,2222),(32286,2223),(32287,2224),(32288,2225),(32289,2226),(32290,2227),(32291,2228),(32292,2229),(32293,2230),(32294,2231),(32295,2232),(32296,2233),(32297,2234),(32298,2235),(32299,2236),(32300,2237),(32301,2238),(32302,2239),(32303,2240),(32304,2241),(32305,2242),(32306,2243),(32307,2244),(32308,2245),(32309,2246),(32310,2247),(32311,2248),(32312,2249),(32381,2250),(32411,2251),(32412,2252),(32429,2253),(32430,2254),(32431,2255),(32432,2256),(32433,2257),(32434,2258),(32435,2259),(32436,2260),(32437,2261),(32438,2262),(32439,2263),(32440,2264),(32441,2265),(32442,2266),(32443,2267),(32444,2268),(32447,2269),(32511,2270),(32736,2271),(32737,2272),(32738,2273),(32739,2274),(32744,2275),(32745,2276),(32746,2277),(32747,2278),(32748,2279),(32749,2280),(32750,2281),(32751,2282),(32752,2283),(32753,2284),(32754,2285),(32755,2286),(32823,2287),(32895,2288),(32896,2289),(33007,2290),(33015,2291),(33124,2292),(33145,2293),(33155,2294),(33156,2295),(33157,2296),(33158,2297),(33159,2298),(33160,2299),(33174,2300),(33186,2301),(33205,2302),(33209,2303),(33289,2304),(33305,2305),(33347,2306),(33457,2307),(33458,2308),(33459,2309),(33460,2310),(33461,2311),(33462,2312),(33581,2313),(33622,2314),(33778,2315),(33779,2316),(33780,2317),(33783,2318),(33792,2319),(33804,2320),(33869,2321),(33870,2322),(33871,2323),(33873,2324),(33875,2325),(33925,2326),(33954,2327),(34040,2328),(34041,2329),(34042,2330),(34103,2331),(34104,2332),(34114,2333),(34126,2334),(34172,2335),(34173,2336),(34174,2337),(34175,2338),(34200,2339),(34201,2340),(34218,2341),(34221,2342),(34261,2343),(34262,2344),(34319,2345),(34413,2346),(34420,2347),(34481,2348),(34491,2349),(34647,2350),(34689,2351),(34720,2352),(34834,2353),(34960,2354),(35122,2355),(35186,2356),(35187,2357),(35189,2358),(35190,2359),(35191,2360),(35192,2361),(35193,2362),(35194,2363),(35195,2364),(35196,2365),(35197,2366),(35198,2367),(35199,2368),(35200,2369),(35201,2370),(35202,2371),(35203,2372),(35204,2373),(35205,2374),(35206,2375),(35207,2376),(35208,2377),(35209,2378),(35210,2379),(35211,2380),(35212,2381),(35213,2382),(35214,2383),(35215,2384),(35216,2385),(35217,2386),(35218,2387),(35219,2388),(35230,2389),(35231,2390),(35238,2391),(35239,2392),(35240,2393),(35241,2394),(35242,2395),(35243,2396),(35244,2397),(35245,2398),(35246,2399),(35247,2400),(35248,2401),(35249,2402),(35250,2403),(35251,2404),(35252,2405),(35253,2406),(35254,2407),(35255,2408),(35256,2409),(35257,2410),(35258,2411),(35259,2412),(35260,2413),(35261,2414),(35262,2415),(35263,2416),(35264,2417),(35265,2418),(35266,2419),(35267,2420),(35268,2421),(35269,2422),(35270,2423),(35271,2424),(35294,2425),(35295,2426),(35296,2427),(35300,2428),(35301,2429),(35302,2430),(35303,2431),(35304,2432),(35305,2433),(35306,2434),(35307,2435),(35308,2436),(35309,2437),(35310,2438),(35311,2439),(35322,2440),(35323,2441),(35325,2442),(35353,2443),(35354,2444),(35355,2445),(35502,2446),(35505,2447),(35517,2448),(35518,2449),(35519,2450),(35520,2451),(35521,2452),(35522,2453),(35523,2454),(35524,2455),(35525,2456),(35526,2457),(35527,2458),(35528,2459),(35529,2460),(35530,2461),(35531,2462),(35532,2463),(35533,2464),(35534,2465),(35535,2466),(35536,2467),(35537,2468),(35538,2469),(35539,2470),(35540,2471),(35541,2472),(35542,2473),(35543,2474),(35544,2475),(35545,2476),(35546,2477),(35547,2478),(35548,2479),(35549,2480),(35550,2481),(35551,2482),(35552,2483),(35553,2484),(35554,2485),(35555,2486),(35556,2487),(35564,2488),(35566,2489),(35567,2490),(35582,2491),(35695,2492),(35696,2493),(35697,2494),(35698,2495),(35699,2496),(35708,2497),(35715,2498),(35752,2499),(35753,2500),(35754,2501),(35755,2502),(35762,2503),(35763,2504),(35764,2505),(35765,2506),(35766,2507),(35767,2508),(35768,2509),(35769,2510),(35776,2511),(35777,2512),(35778,2513),(35784,2514),(35853,2515),(36735,2516),(36841,2517),(36842,2518),(36843,2519),(36844,2520),(37091,2521),(37092,2522),(37093,2523),(37094,2524),(37097,2525),(37098,2526),(37299,2527),(37305,2528),(37504,2529),(37603,2530),(37915,2531),(38229,2532),(38327,2533),(38328,2534),(38593,2535),(38594,2536),(38595,2537),(38596,2538),(38597,2539),(38598,2540),(38599,2541),(38629,2542),(38679,2543),(38685,2544),(38724,2545),(38725,2546),(38766,2547),(38767,2548),(38768,2549),(38769,2550),(38770,2551),(38771,2552),(38772,2553),(38773,2554),(38774,2555),(38775,2556),(38776,2557),(38777,2558),(38778,2559),(38779,2560),(38780,2561),(38781,2562),(38782,2563),(38783,2564),(38784,2565),(38785,2566),(38786,2567),(38787,2568),(38788,2569),(38789,2570),(38790,2571),(38791,2572),(38792,2573),(38793,2574),(38794,2575),(38795,2576),(38796,2577),(38797,2578),(38798,2579),(38799,2580),(38800,2581),(38801,2582),(38802,2583),(38803,2584),(38804,2585),(38805,2586),(38806,2587),(38807,2588),(38808,2589),(38809,2590),(38810,2591),(38811,2592),(38812,2593),(38813,2594),(38814,2595),(38815,2596),(38816,2597),(38817,2598),(38818,2599),(38819,2600),(38820,2601),(38821,2602),(38822,2603),(38823,2604),(38824,2605),(38825,2606),(38826,2607),(38827,2608),(38828,2609),(38829,2610),(38830,2611),(38831,2612),(38832,2613),(38833,2614),(38834,2615),(38835,2616),(38836,2617),(38837,2618),(38838,2619),(38839,2620),(38840,2621),(38841,2622),(38842,2623),(38843,2624),(38844,2625),(38845,2626),(38846,2627),(38847,2628),(38848,2629),(38849,2630),(38850,2631),(38851,2632),(38852,2633),(38853,2634),(38854,2635),(38855,2636),(38856,2637),(38857,2638),(38858,2639),(38859,2640),(38860,2641),(38861,2642),(38862,2643),(38863,2644),(38864,2645),(38865,2646),(38866,2647),(38867,2648),(38868,2649),(38869,2650),(38870,2651),(38871,2652),(38872,2653),(38873,2654),(38874,2655),(38875,2656),(38876,2657),(38877,2658),(38878,2659),(38879,2660),(38880,2661),(38881,2662),(38882,2663),(38883,2664),(38884,2665),(38885,2666),(38886,2667),(38887,2668),(38888,2669),(38889,2670),(38890,2671),(38891,2672),(38892,2673),(38893,2674),(38894,2675),(38895,2676),(38896,2677),(38897,2678),(38898,2679),(38899,2680),(38900,2681),(38901,2682),(38902,2683),(38903,2684),(38904,2685),(38905,2686),(38906,2687),(38907,2688),(38908,2689),(38909,2690),(38910,2691),(38911,2692),(38912,2693),(38913,2694),(38914,2695),(38915,2696),(38916,2697),(38917,2698),(38918,2699),(38919,2700),(38920,2701),(38921,2702),(38922,2703),(38923,2704),(38924,2705),(38925,2706),(38926,2707),(38927,2708),(38928,2709),(38929,2710),(38930,2711),(38931,2712),(38932,2713),(38933,2714),(38934,2715),(38935,2716),(38936,2717),(38937,2718),(38938,2719),(38939,2720),(38940,2721),(38941,2722),(38942,2723),(38943,2724),(38944,2725),(38945,2726),(38946,2727),(38947,2728),(38948,2729),(38949,2730),(38950,2731),(38951,2732),(38952,2733),(38953,2734),(38954,2735),(38955,2736),(38956,2737),(38957,2738),(38958,2739),(38959,2740),(38960,2741),(38961,2742),(38962,2743),(38963,2744),(38964,2745),(38965,2746),(38966,2747),(38967,2748),(38968,2749),(38969,2750),(38970,2751),(38971,2752),(38972,2753),(38973,2754),(38974,2755),(38975,2756),(38976,2757),(38977,2758),(38978,2759),(38979,2760),(38980,2761),(38981,2762),(38982,2763),(38983,2764),(38984,2765),(38985,2766),(38986,2767),(38987,2768),(38988,2769),(38989,2770),(38990,2771),(38991,2772),(38992,2773),(38993,2774),(38994,2775),(38995,2776),(38996,2777),(38997,2778),(38998,2779),(38999,2780),(39000,2781),(39001,2782),(39002,2783),(39003,2784),(39004,2785),(39005,2786),(39006,2787),(39269,2788),(39302,2789),(39304,2790),(39316,2791),(39357,2792),(39358,2793),(39360,2794),(39361,2795),(39584,2796),(39585,2797),(39586,2798),(39587,2799),(39644,2800),(39692,2801),(40666,2802),(41120,2803),(41122,2804),(41123,2805),(41124,2806),(41262,2807),(41402,2808),(41403,2809),(41404,2810),(41405,2811),(41406,2812),(41407,2813),(41408,2814),(41409,2815),(41410,2816),(41411,2817),(41412,2818),(41413,2819),(41414,2820),(41415,2821),(41416,2822),(41417,2823),(41418,2824),(41419,2825),(41420,2826),(41421,2827),(41422,2828),(41423,2829),(41559,2830),(41560,2831),(41561,2832),(41562,2833),(41563,2834),(41564,2835),(41565,2836),(41566,2837),(41567,2838),(41568,2839),(41569,2840),(41570,2841),(41571,2842),(41572,2843),(41573,2844),(41574,2845),(41575,2846),(41576,2847),(41577,2848),(41578,2849),(41579,2850),(41580,2851),(41581,2852),(41582,2853),(41686,2854),(41687,2855),(41688,2856),(41689,2857),(41690,2858),(41692,2859),(41693,2860),(41694,2861),(41696,2862),(41697,2863),(41698,2864),(41699,2865),(41701,2866),(41702,2867),(41703,2868),(41704,2869),(41705,2870),(41706,2871),(41707,2872),(41708,2873),(41709,2874),(41710,2875),(41711,2876),(41718,2877),(41719,2878),(41720,2879),(41721,2880),(41722,2881),(41723,2882),(41724,2883),(41725,2884),(41726,2885),(41727,2886),(41728,2887),(41730,2888),(41732,2889),(41733,2890),(41734,2891),(41735,2892),(41736,2893),(41737,2894),(41738,2895),(41739,2896),(41740,2897),(41742,2898),(41743,2899),(41744,2900),(41747,2901),(41776,2902),(41777,2903),(41778,2904),(41779,2905),(41780,2906),(41781,2907),(41782,2908),(41783,2909),(41784,2910),(41785,2911),(41786,2912),(41787,2913),(41788,2914),(41789,2915),(41790,2916),(41791,2917),(41792,2918),(41793,2919),(41794,2920),(41795,2921),(41796,2922),(41797,2923),(41798,2924),(41799,2925),(41817,2926),(41818,2927),(41819,2928),(41820,2929),(42138,2930),(42172,2931),(42173,2932),(42174,2933),(42175,2934),(42176,2935),(42177,2936),(42178,2937),(42179,2938),(42180,2939),(42181,2940),(42182,2941),(42183,2942),(42184,2943),(42185,2944),(42186,2945),(42187,2946),(42188,2947),(42189,2948),(42190,2949),(42191,2950),(42192,2951),(42193,2952),(42194,2953),(42195,2954),(42196,2955),(42197,2956),(42198,2957),(42199,2958),(42200,2959),(42201,2960),(42202,2961),(42298,2962),(42299,2963),(42300,2964),(42301,2965),(42302,2966),(42303,2967),(42304,2968),(42305,2969),(42306,2970),(42307,2971),(42308,2972),(42309,2973),(42310,2974),(42311,2975),(42312,2976),(42313,2977),(42314,2978),(42315,2979),(42648,2980),(42649,2981),(42650,2982),(42651,2983),(42652,2984),(42653,2985),(43017,2986),(43018,2987),(43019,2988),(43020,2989),(43021,2990),(43022,2991),(43023,2992),(43024,2993),(43025,2994),(43026,2995),(43027,2996),(43028,2997),(43029,2998),(43030,2999),(43031,3000),(43032,3001),(43033,3002),(43034,3003),(43035,3004),(43036,3005),(43037,3006),(43317,3007),(43318,3008),(43319,3009),(43320,3010),(43463,3011),(43464,3012),(43465,3013),(43466,3014),(43467,3015),(43468,3016),(43485,3017),(43497,3018),(43505,3019),(43506,3020),(43507,3021),(43508,3022),(43509,3023),(43510,3024),(43597,3025),(43987,3026),(44119,3027),(44449,3028),(44453,3029),(44455,3030),(44456,3031),(44457,3032),(44458,3033),(44463,3034),(44465,3035),(44466,3036),(44467,3037),(44469,3038),(44470,3039),(44493,3040),(44497,3041),(44502,3042),(44503,3043),(44509,3044),(44510,3045),(44511,3046),(44512,3047),(44513,3048),(44514,3049),(44515,3050),(44516,3051),(44517,3052),(44518,3053),(44519,3054),(44520,3055),(44521,3056),(44522,3057),(44523,3058),(44524,3059),(44525,3060),(44526,3061),(44527,3062),(44528,3063),(44530,3064),(44531,3065),(44532,3066),(44533,3067),(44534,3068),(44535,3069),(44536,3070),(44537,3071),(44538,3072),(44539,3073),(44540,3074),(44541,3075),(44542,3076),(44543,3077),(44544,3078),(44545,3079),(44546,3080),(44547,3081),(44548,3082),(44549,3083),(44550,3084),(44551,3085),(44552,3086),(44553,3087),(44559,3088),(44560,3089),(44561,3090),(44562,3091),(44563,3092),(44564,3093),(44565,3094),(44566,3095),(44567,3096),(44568,3097),(44584,3098),(44585,3099),(44586,3100),(44587,3101),(44588,3102),(44589,3103),(44815,3104),(44916,3105),(44917,3106),(44918,3107),(44919,3108),(44932,3109),(44933,3110),(44937,3111),(44938,3112),(44946,3113),(44947,3114),(44954,3115),(44977,3116),(45056,3117),(45060,3118),(45088,3119),(45089,3120),(45090,3121),(45091,3122),(45092,3123),(45093,3124),(45094,3125),(45095,3126),(45096,3127),(45097,3128),(45098,3129),(45099,3130),(45100,3131),(45101,3132),(45102,3133),(45103,3134),(45104,3135),(45105,3136),(45628,3137),(45705,3138),(45774,3139),(46026,3140),(46098,3141),(46368,3142),(46369,3143),(46710,3144),(46875,3145),(46876,3146),(46877,3147),(46878,3148),(46879,3149),(46880,3150),(46881,3151),(46882,3152),(46883,3153),(46884,3154),(46897,3155),(46898,3156),(46899,3157),(46900,3158),(46901,3159),(46902,3160),(46903,3161),(46904,3162),(46905,3163),(46906,3164),(46907,3165),(46908,3166),(46909,3167),(46910,3168),(46911,3169),(46912,3170),(46913,3171),(46914,3172),(46915,3173),(46916,3174),(46917,3175),(46918,3176),(46919,3177),(46920,3178),(46921,3179),(46922,3180),(46923,3181),(46924,3182),(46925,3183),(46926,3184),(46927,3185),(46928,3186),(46929,3187),(46930,3188),(46931,3189),(46932,3190),(46933,3191),(46934,3192),(46935,3193),(46936,3194),(46937,3195),(46938,3196),(46939,3197),(46940,3198),(46941,3199),(46942,3200),(46943,3201),(46944,3202),(46945,3203),(46946,3204),(46947,3205),(46948,3206),(46949,3207),(46950,3208),(46951,3209),(46952,3210),(46953,3211),(46956,3212),(47007,3213),(47008,3214),(47010,3215),(47011,3216),(47012,3217),(47015,3218),(47016,3219),(47017,3220),(47018,3221),(47019,3222),(47020,3223),(47021,3224),(47022,3225),(47023,3226),(47246,3227),(47247,3228),(47507,3229),(47622,3230),(47623,3231),(47624,3232),(47625,3233),(47626,3234),(47627,3235),(47628,3236),(47629,3237),(47630,3238),(47631,3239),(47632,3240),(47633,3241),(47634,3242),(47635,3243),(47636,3244),(47637,3245),(47638,3246),(47639,3247),(47640,3248),(47641,3249),(47642,3250),(47643,3251),(47644,3252),(47645,3253),(47646,3254),(47647,3255),(47648,3256),(47649,3257),(47650,3258),(47651,3259),(47652,3260),(47653,3261),(47654,3262),(47655,3263),(47656,3264),(47657,3265),(49050,3266),(49112,3267),(49205,3268),(49953,3269),(49954,3270),(49955,3271),(49956,3272),(49957,3273),(49958,3274),(49959,3275),(49961,3276),(49962,3277),(49963,3278),(49965,3279),(49966,3280),(49969,3281),(49970,3282),(49971,3283),(49972,3284),(49973,3285),(49974,3286),(50166,3287),(50167,3288),(50168,3289),(50816,3290),(52022,3291),(52023,3292),(52565,3293),(54798,3294),(966,3295),(967,3296),(968,3297),(973,3298),(974,3299),(975,3300),(976,3301),(980,3302),(985,3303),(986,3304),(989,3305),(992,3306),(994,3307),(1002,3308),(1004,3309),(1084,3310),(1085,3311),(1086,3312),(1087,3313),(1088,3314),(1089,3315),(1090,3316),(1091,3317),(1092,3318),(1093,3319),(1095,3320),(1096,3321),(1099,3322),(1101,3323),(1102,3324),(1105,3325),(1108,3326),(1109,3327),(1111,3328),(1112,3329),(1136,3330),(1138,3331),(1139,3332),(1141,3333),(1144,3334),(1146,3335),(1149,3336),(1150,3337),(1151,3338),(1224,3339),(1228,3340),(1229,3341),(1231,3342),(1232,3343),(1238,3344),(1239,3345),(1243,3346),(1244,3347),(1245,3348),(1246,3349),(1250,3350),(1328,3351),(1332,3352),(1334,3353),(1335,3354),(1339,3355),(1341,3356),(1534,3357),(1536,3358),(1554,3359),(1559,3360),(1567,3361),(1568,3362),(1571,3363),(1574,3364),(1641,3365),(1648,3366),(1651,3367),(1655,3368),(1657,3369),(1658,3370),(1676,3371),(1681,3372),(1877,3373),(1878,3374),(1880,3375),(1882,3376),(1886,3377),(2004,3378),(2154,3379),(2161,3380),(2560,3381),(2755,3382),(2793,3383),(2794,3384),(2795,3385),(2833,3386),(3016,3387),(3088,3388),(3089,3389),(3090,3390),(3091,3391),(3092,3392),(3093,3393),(3094,3394),(3095,3395),(3096,3396),(3097,3397),(3098,3398),(3099,3399),(3100,3400),(3101,3401),(3102,3402),(3112,3403),(3113,3404),(3114,3405),(3115,3406),(3116,3407),(3117,3408),(3118,3409),(3119,3410),(3120,3411),(3121,3412),(3122,3413),(3123,3414),(3124,3415),(3134,3416),(3138,3417),(3139,3418),(3140,3419),(3141,3420),(3142,3421),(3143,3422),(3144,3423),(3146,3424),(3255,3425),(3657,3426),(3658,3427),(3659,3428),(3711,3429),(3899,3430),(4141,3431),(4142,3432),(4143,3433),(4144,3434),(4145,3435),(4146,3436),(4147,3437),(4148,3438),(4149,3439),(4150,3440),(4151,3441),(4152,3442),(4153,3443),(4154,3444),(4155,3445),(4156,3446),(4157,3447),(4158,3448),(4159,3449),(4160,3450),(4161,3451),(4162,3452),(4163,3453),(4164,3454),(4165,3455),(4166,3456),(4167,3457),(4198,3458),(4199,3459),(4200,3460),(4201,3461),(4202,3462),(4203,3463),(4204,3464),(4205,3465),(4206,3466),(4207,3467),(4208,3468),(4209,3469),(4210,3470),(4211,3471),(4212,3472),(4213,3473),(4214,3474),(4215,3475),(4216,3476),(4217,3477),(4218,3478),(4219,3479),(4220,3480),(4221,3481),(4222,3482),(4223,3483),(4224,3484),(4225,3485),(4226,3486),(4227,3487),(4228,3488),(4229,3489),(4230,3490),(4266,3491),(4267,3492),(4268,3493),(4269,3494),(4270,3495),(4271,3496),(4272,3497),(4273,3498),(4274,3499),(4275,3500),(4276,3501),(4277,3502),(4279,3503),(4280,3504),(4281,3505),(4282,3506),(4283,3507),(4284,3508),(4285,3509),(4286,3510),(4287,3511),(4288,3512),(4475,3513),(4489,3514),(4490,3515),(4647,3516),(4651,3517),(5006,3518),(5080,3519),(5088,3520),(5139,3521),(5141,3522),(5142,3523),(5144,3524),(5145,3525),(5146,3526),(5147,3527),(5148,3528),(5149,3529),(5150,3530),(5151,3531),(5152,3532),(5153,3533),(5154,3534),(5155,3535),(5156,3536),(5157,3537),(5158,3538),(5159,3539),(5160,3540),(5161,3541),(5162,3542),(5163,3543),(5352,3544),(5428,3545),(5505,3546),(5520,3547),(5533,3548),(5535,3549),(5536,3550),(5644,3551),(5647,3552),(5648,3553),(5649,3554),(5650,3555),(5658,3556),(5660,3557),(5661,3558),(5662,3559),(5666,3560),(5667,3561),(5670,3562),(5671,3563),(5672,3564),(5673,3565),(5674,3566),(5676,3567),(5677,3568),(5678,3569),(5679,3570),(5680,3571),(5682,3572),(5683,3573),(5684,3574),(5685,3575),(5719,3576),(5720,3577),(5721,3578),(5722,3579),(5723,3580),(5724,3581),(5725,3582),(5726,3583),(5727,3584),(5728,3585),(5729,3586),(5730,3587),(5790,3588),(5791,3589),(5860,3590),(5861,3591),(5897,3592),(6132,3593),(6133,3594),(6262,3595),(6283,3596),(6285,3597),(6454,3598),(6619,3599),(6621,3600),(6768,3601),(6769,3602),(6770,3603),(6771,3604),(6772,3605),(6775,3606),(6776,3607),(6777,3608),(6778,3609),(6779,3610),(6785,3611),(6897,3612),(6916,3613),(6931,3614),(6999,3615),(7006,3616),(7266,3617),(7274,3618),(7294,3619),(7295,3620),(7389,3621),(7668,3622),(7737,3623),(7886,3624),(7908,3625),(8046,3626),(8743,3627),(8744,3628),(8745,3629),(8756,3630),(8757,3631),(8758,3632),(8759,3633),(8760,3634),(8761,3635),(8762,3636),(8763,3637),(8764,3638),(8765,3639),(8767,3640),(8768,3641),(8769,3642),(8770,3643),(8771,3644),(8772,3645),(8773,3646),(8774,3647),(8775,3648),(8776,3649),(8777,3650),(8778,3651),(8779,3652),(8780,3653),(8781,3654),(8782,3655),(8783,3656),(8784,3657),(8785,3658),(8786,3659),(8787,3660),(8788,3661),(8789,3662),(8790,3663),(8791,3664),(8792,3665),(8793,3666),(8794,3667),(8795,3668),(8796,3669),(8797,3670),(8798,3671),(8799,3672),(8800,3673),(8801,3674),(8802,3675),(8803,3676),(8804,3677),(8805,3678),(8806,3679),(8807,3680),(8808,3681),(8809,3682),(8810,3683),(8811,3684),(8812,3685),(8813,3686),(8814,3687),(8815,3688),(8816,3689),(8817,3690),(8818,3691),(8819,3692),(8820,3693),(8821,3694),(8822,3695),(8823,3696),(8824,3697),(8825,3698),(8826,3699),(8828,3700),(8829,3701),(8830,3702),(8832,3703),(8833,3704),(8834,3705),(8835,3706),(8837,3707),(8840,3708),(8841,3709),(8842,3710),(8843,3711),(8844,3712),(8847,3713),(8848,3714),(8849,3715),(8850,3716),(8851,3717),(8852,3718),(8853,3719),(8854,3720),(8855,3721),(8856,3722),(8857,3723),(8858,3724),(8859,3725),(8860,3726),(8861,3727),(8862,3728),(8863,3729),(8864,3730),(8865,3731),(8866,3732),(8867,3733),(8868,3734),(8869,3735),(8870,3736),(8871,3737),(8872,3738),(8873,3739),(8874,3740),(8875,3741),(8876,3742),(8877,3743),(8878,3744),(8879,3745),(8880,3746),(8881,3747),(8882,3748),(8883,3749),(8884,3750),(8885,3751),(8886,3752),(8887,3753),(8888,3754),(8889,3755),(8890,3756),(8891,3757),(8892,3758),(8893,3759),(8894,3760),(8895,3761),(8896,3762),(8897,3763),(8898,3764),(8899,3765),(8900,3766),(8901,3767),(8902,3768),(8903,3769),(8904,3770),(8905,3771),(8906,3772),(8907,3773),(8908,3774),(8909,3775),(8910,3776),(8911,3777),(8912,3778),(8913,3779),(8914,3780),(8915,3781),(8916,3782),(8917,3783),(8918,3784),(8919,3785),(8920,3786),(8921,3787),(8922,3788),(8929,3789),(8930,3790),(8931,3791),(8933,3792),(8934,3793),(8935,3794),(8936,3795),(8937,3796),(8938,3797),(8939,3798),(8940,3799),(8941,3800),(8942,3801),(8943,3802),(8944,3803),(8945,3804),(8946,3805),(8947,3806),(8954,3807),(8955,3808),(8958,3809),(8960,3810),(8961,3811),(8962,3812),(8963,3813),(8964,3814),(8965,3815),(8966,3816),(8967,3817),(8968,3818),(8969,3819),(8970,3820),(8971,3821),(8972,3822),(8974,3823),(8975,3824),(8976,3825),(8977,3826),(8978,3827),(8979,3828),(8980,3829),(8981,3830),(8982,3831),(8983,3832),(8986,3833),(8987,3834),(8988,3835),(8989,3836),(8990,3837),(8991,3838),(8992,3839),(8993,3840),(8994,3841),(8995,3842),(8996,3843),(8997,3844),(8998,3845),(8999,3846),(9000,3847),(9001,3848),(9002,3849),(9003,3850),(9004,3851),(9005,3852),(9006,3853),(9007,3854),(9008,3855),(9009,3856),(9010,3857),(9011,3858),(9012,3859),(9013,3860),(9014,3861),(9015,3862),(9016,3863),(9017,3864),(9018,3865),(9019,3866),(9020,3867),(9021,3868),(9022,3869),(9023,3870),(9024,3871),(9025,3872),(9026,3873),(9027,3874),(9028,3875),(9029,3876),(9031,3877),(9032,3878),(9033,3879),(9034,3880),(9035,3881),(9190,3882),(9191,3883),(9192,3884),(9193,3885),(9194,3886),(9195,3887),(9196,3888),(9198,3889),(9199,3890),(9200,3891),(9201,3892),(9202,3893),(9203,3894),(9204,3895),(9205,3896),(9207,3897),(9208,3898),(9209,3899),(9211,3900),(9212,3901),(9213,3902),(9214,3903),(9215,3904),(9216,3905),(9217,3906),(9218,3907),(9219,3908),(9220,3909),(9221,3910),(9222,3911),(9223,3912),(9225,3913),(9226,3914),(9227,3915),(9228,3916),(9229,3917),(9230,3918),(9231,3919),(9331,3920),(10789,3921),(10832,3922),(11116,3923),(11147,3924),(11149,3925),(11169,3926),(11482,3927),(11613,3928),(11727,3929),(11732,3930),(11733,3931),(11734,3932),(11736,3933),(11737,3934),(12742,3935),(12743,3936),(12750,3937),(12751,3938),(12842,3939),(12860,3940),(12861,3941),(12862,3942),(12863,3943),(12864,3944),(12865,3945),(12866,3946),(12867,3947),(12868,3948),(12869,3949),(12900,3950),(12954,3951),(13149,3952),(13151,3953),(13152,3954),(13153,3955),(13154,3956),(13158,3957),(13202,3958),(13313,3959),(13315,3960),(13353,3961),(13385,3962),(13585,3963),(13624,3964),(13752,3965),(14395,3966),(14396,3967),(15696,3968),(15790,3969),(15803,3970),(15847,3971),(15884,3972),(16072,3973),(16073,3974),(16082,3975),(16083,3976),(16084,3977),(16085,3978),(16112,3979),(16113,3980),(16302,3981),(16316,3982),(16317,3983),(16318,3984),(16319,3985),(16320,3986),(16321,3987),(16322,3988),(16323,3989),(16324,3990),(16325,3991),(16326,3992),(16327,3993),(16328,3994),(16329,3995),(16330,3996),(16331,3997),(16346,3998),(16347,3999),(16348,4000),(16349,4001),(16350,4002),(16351,4003),(16352,4004),(16353,4005),(16354,4006),(16355,4007),(16356,4008),(16357,4009),(16358,4010),(16359,4011),(16360,4012),(16361,4013),(16362,4014),(16363,4015),(16364,4016),(16365,4017),(16366,4018),(16368,4019),(16371,4020),(16372,4021),(16373,4022),(16374,4023),(16375,4024),(16376,4025),(16377,4026),(16378,4027),(16379,4028),(16380,4029),(16381,4030),(16382,4031),(16383,4032),(16384,4033),(16385,4034),(16386,4035),(16387,4036),(16388,4037),(16389,4038),(16390,4039),(16665,4040),(17067,4041),(17412,4042),(17413,4043),(17414,4044),(17682,4045),(17683,4046),(17735,4047),(18229,4048),(18261,4049),(18332,4050),(18333,4051),(18334,4052),(18356,4053),(18357,4054),(18358,4055),(18359,4056),(18360,4057),(18361,4058),(18362,4059),(18363,4060),(18364,4061),(18365,4062),(18401,4063),(18474,4064),(18536,4065),(18600,4066),(18602,4067),(18664,4068),(18675,4069),(18695,4070),(18769,4071),(18770,4072),(18771,4073),(18818,4074),(19142,4075),(19308,4076),(19309,4077),(19310,4078),(19311,4079),(19337,4080),(19483,4081),(19484,4082),(19989,4083),(20009,4084),(20010,4085),(20394,4086),(20395,4087),(20396,4088),(20415,4089),(20472,4090),(20473,4091),(21025,4092),(21111,4093),(21130,4094),(21214,4095),(21279,4096),(21280,4097),(21281,4098),(21282,4099),(21283,4100),(21284,4101),(21285,4102),(21287,4103),(21288,4104),(21289,4105),(21290,4106),(21294,4107),(21295,4108),(21296,4109),(21297,4110),(21298,4111),(21299,4112),(21300,4113),(21302,4114),(21303,4115),(21304,4116),(21306,4117),(21307,4118),(21783,4119),(21992,4120),(21993,4121),(22012,4122),(22146,4123),(22153,4124),(22179,4125),(22180,4126),(22181,4127),(22182,4128),(22183,4129),(22184,4130),(22185,4131),(22186,4132),(22187,4133),(22188,4134),(22189,4135),(22190,4136),(22253,4137),(22298,4138),(22319,4139),(22344,4140),(22393,4141),(22414,4142),(22706,4143),(22719,4144),(22739,4145),(22890,4146),(22891,4147),(22897,4148),(23339,4149),(23452,4150),(23453,4151),(23462,4152),(23463,4153),(23468,4154),(23469,4155),(23689,4156),(23690,4157),(23711,4158),(23730,4159),(23731,4160),(23734,4161),(23745,4162),(23755,4163),(23818,4164),(23851,4165),(23857,4166),(23862,4167),(23864,4168),(23865,4169),(23926,4170),(23933,4171),(23934,4172),(23935,4173),(23936,4174),(24101,4175),(24102,4176),(24237,4177),(24282,4178),(24345,4179),(24369,4180),(24371,4181),(24386,4182),(24492,4183),(24499,4184),(25461,4185),(25462,4186),(25469,4187),(25900,4188),(25938,4189),(27532,4190),(27736,4191),(28068,4192),(28071,4193),(28072,4194),(28073,4195),(28213,4196),(28260,4197),(28296,4198),(28336,4199),(28346,4200),(28471,4201),(28549,4202),(28552,4203),(28598,4204),(28648,4205),(28677,4206),(28938,4207),(28941,4208),(29234,4209),(29311,4210),(29330,4211),(29331,4212),(29549,4213),(29550,4214),(29571,4215),(29739,4216),(30447,4217),(30632,4218),(30713,4219),(30808,4220),(30827,4221),(30841,4222),(30854,4223),(31033,4224),(31345,4225),(31496,4226),(31498,4227),(31500,4228),(31501,4229),(31502,4230),(31503,4231),(31505,4232),(31506,4233),(31507,4234),(31744,4235),(31823,4236),(31837,4237),(31978,4238),(32075,4239),(32191,4240),(32358,4241),(32452,4242),(32467,4243),(32523,4244),(32564,4245),(32742,4246),(32961,4247),(33077,4248),(33127,4249),(33266,4250),(33316,4251),(33681,4252),(33736,4253),(33781,4254),(33827,4255),(33842,4256),(34031,4257),(34033,4258),(34109,4259),(34496,4260),(34719,4261),(34838,4262),(35008,4263),(35016,4264),(35040,4265),(35074,4266),(35273,4267),(35312,4268),(35480,4269),(35481,4270),(35482,4271),(35598,4272),(35628,4273),(35738,4274),(35739,4275),(35858,4276),(36744,4277),(36820,4278),(36861,4279),(36940,4280),(36955,4281),(36959,4282),(36960,4283),(36963,4284),(36964,4285),(36965,4286),(36966,4287),(36967,4288),(36968,4289),(36970,4290),(36972,4291),(37033,4292),(37086,4293),(37131,4294),(37132,4295),(37133,4296),(37134,4297),(37350,4298),(37467,4299),(37540,4300),(37601,4301),(37607,4302),(37674,4303),(37830,4304),(37831,4305),(37889,4306),(37931,4307),(38217,4308),(38283,4309),(38322,4310),(38363,4311),(38520,4312),(38579,4313),(39014,4314),(39061,4315),(39152,4316),(39153,4317),(39203,4318),(39204,4319),(39362,4320),(39504,4321),(39654,4322),(39827,4323),(39832,4324),(40593,4325),(40699,4326),(42523,4327),(42524,4328),(42525,4329),(42526,4330),(42527,4331),(42528,4332),(42529,4333),(42530,4334),(42531,4335),(42532,4336),(42533,4337),(42534,4338),(42535,4339),(42536,4340),(42537,4341),(42538,4342),(42539,4343),(42540,4344),(42612,4345),(42613,4346),(42614,4347),(42615,4348),(42616,4349),(42617,4350),(42756,4351),(42772,4352),(42851,4353),(43095,4354),(43515,4355),(43654,4356),(43655,4357),(43656,4358),(43657,4359),(43660,4360),(43661,4361),(43663,4362),(43664,4363),(43666,4364),(43667,4365),(43824,4366),(43876,4367),(43886,4368),(44022,4369),(44210,4370),(44462,4371),(44600,4372),(44602,4373),(44709,4374),(44714,4375),(44793,4376),(44811,4377),(44851,4378),(44956,4379),(45010,4380),(45058,4381),(45062,4382),(45084,4383),(45849,4384),(45850,4385),(45851,4386),(45852,4387),(45853,4388),(45854,4389),(45889,4390),(45890,4391),(45891,4392),(45912,4393),(46023,4394),(46054,4395),(46055,4396),(46108,4397),(46809,4398),(46810,4399),(46870,4400),(49160,4401),(49177,4402),(49187,4403),(49308,4404),(49335,4405),(49490,4406),(49698,4407),(49915,4408),(49918,4409),(49922,4410),(49925,4411),(49926,4412),(50076,4413),(50091,4414),(50092,4415),(50093,4416),(51396,4417),(51407,4418),(51408,4419),(51409,4420),(51472,4421),(54291,4422);
SET @old := (SELECT entry FROM item_template WHERE ScriptName = 'item_zerocraft_guild_charter' LIMIT 1);
SET @id := COALESCE(@old, (SELECT id FROM zc_cand WHERE id NOT IN (SELECT entry FROM item_template) ORDER BY ord LIMIT 1));
SELECT @id AS charter_item_id;
DELETE FROM item_template WHERE entry = @id;
DROP TEMPORARY TABLE IF EXISTS zc_ch;
CREATE TEMPORARY TABLE zc_ch SELECT * FROM item_template WHERE entry = 23701;
UPDATE zc_ch SET entry = @id, name = "Founder's Charter", displayid = 16161, Quality = 3,
  description = 'Found a new guild. Guildmates are allies; everyone else is a foe.',
  spellid_1 = 18282, spelltrigger_1 = 0, spellcharges_1 = 0, spellcooldown_1 = -1, spellcategory_1 = 0, spellcategorycooldown_1 = -1,
  ScriptName = 'item_zerocraft_guild_charter';
INSERT INTO item_template SELECT * FROM zc_ch;
DROP TEMPORARY TABLE zc_ch;
DROP TEMPORARY TABLE zc_cand;
SELECT entry, name, displayid, spellid_1, ScriptName FROM item_template WHERE ScriptName = 'item_zerocraft_guild_charter';

-- ZeroCraft: take the raid bosses (huge health pools) out of the hero scroll pool
DELETE FROM zerocraft_hero_pool WHERE villain = 1 AND name IN
 ('Lady Vashj','Illidan Stormrage','Kael''thas Sunstrider','Lord Victor Nefarius','Teron Gorefiend','Moroes',
  'Shade of Aran','Terestian Illhoof','Zul''jin','Hex Lord Malacrass','Lady Deathwhisper','Prince Keleseth','Prince Valanar');
SELECT villain, name FROM zerocraft_hero_pool ORDER BY villain, name;

-- ZeroCraft: no NPCs riding the boats and zeppelins (crews/passengers on every transport).
-- Transport maps are 580-800 minus real instances/battlegrounds and the DK start zone.
CREATE TABLE IF NOT EXISTS zerocraft_removed_creatures LIKE creature;
DROP TEMPORARY TABLE IF EXISTS zc_tmaps;
CREATE TEMPORARY TABLE zc_tmaps (map INT PRIMARY KEY);
INSERT IGNORE INTO zc_tmaps SELECT DISTINCT map FROM creature
WHERE map BETWEEN 580 AND 800 AND map NOT IN (607, 609, 617, 618, 628)
  AND map NOT IN (SELECT map FROM instance_template);
SELECT GROUP_CONCAT(map) AS transport_maps FROM zc_tmaps;

INSERT IGNORE INTO zerocraft_removed_creatures SELECT c.* FROM creature c JOIN zc_tmaps t ON t.map = c.map;
DELETE ca  FROM creature_addon ca       JOIN creature c ON c.guid = ca.guid  JOIN zc_tmaps t ON t.map = c.map;
DELETE gec FROM game_event_creature gec JOIN creature c ON c.guid = gec.guid JOIN zc_tmaps t ON t.map = c.map;
DELETE c   FROM creature c              JOIN zc_tmaps t ON t.map = c.map;
SELECT ROW_COUNT() AS boat_npcs_removed;
DROP TEMPORARY TABLE zc_tmaps;

CREATE TABLE IF NOT EXISTS zerocraft_removed_creatures LIKE creature;
DROP TEMPORARY TABLE IF EXISTS zc_wet;
CREATE TEMPORARY TABLE zc_wet (guid INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_wet
SELECT c.guid FROM creature c JOIN creature_template ct ON ct.entry = c.id
WHERE c.map = 0 AND (
      -- Menethil Harbor: everything
      c.areaId = 150 OR (c.position_x BETWEEN -4050 AND -3500 AND c.position_y BETWEEN -1050 AND -450)
      -- rest of the Wetlands: anything friendly (vendors, quest givers, guards, civilians, Alliance/Ironforge/Stormwind/neutral-friendly factions)
   OR (c.zoneId = 11 AND (ct.npcflag <> 0 OR (ct.flags_extra & 0x8002) <> 0
        OR ct.faction IN (11,12,35,55,57,64,79,80,122,123,124,210,371,534,694,1054,1055,1076,1077,1078,1094,1096,1097,1216,1575,1732,1733)))
);
INSERT IGNORE INTO zerocraft_removed_creatures SELECT c.* FROM creature c JOIN zc_wet w ON w.guid = c.guid;
DELETE ca  FROM creature_addon ca       JOIN zc_wet w ON w.guid = ca.guid;
DELETE gec FROM game_event_creature gec JOIN zc_wet w ON w.guid = gec.guid;
DELETE pc  FROM pool_creature pc        JOIN zc_wet w ON w.guid = pc.guid;
DELETE c   FROM creature c              JOIN zc_wet w ON w.guid = c.guid;
SELECT COUNT(*) AS wetlands_npcs_removed FROM zc_wet;
DROP TEMPORARY TABLE zc_wet;

-- ZeroCraft: NPC upkeep bookkeeping
CREATE TABLE IF NOT EXISTS zerocraft_upkeep (
  guild_id INT UNSIGNED NOT NULL PRIMARY KEY,
  last_paid INT UNSIGNED NOT NULL DEFAULT 0,
  unpaid TINYINT UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB;
-- decay column on deployables (added only if missing)
SET @has := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'acore_world' AND TABLE_NAME = 'zerocraft_deployables' AND COLUMN_NAME = 'decay');
SET @sql := IF(@has = 0, 'ALTER TABLE zerocraft_deployables ADD COLUMN decay FLOAT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;
SHOW COLUMNS FROM zerocraft_deployables;

-- ZeroCraft: new characters start with 5 Flight Master scrolls and 3 Banker scrolls
UPDATE playercreateinfo_item SET amount = 5 WHERE itemid = 3504;
UPDATE playercreateinfo_item SET amount = 3 WHERE itemid = 3513;
SELECT i.itemid, t.name, MIN(i.amount) AS amount FROM playercreateinfo_item i JOIN item_template t ON t.entry = i.itemid WHERE i.itemid IN (3504, 3513) GROUP BY i.itemid, t.name;

-- ZeroCraft: completely empty Kalimdor (map 1) and the Eastern Kingdoms (map 0).
-- Every spawned creature goes (backed up in zerocraft_removed_creatures) except deployed NPCs.
CREATE TABLE IF NOT EXISTS zerocraft_removed_creatures LIKE creature;
DROP TEMPORARY TABLE IF EXISTS zc_all;
CREATE TEMPORARY TABLE zc_all (guid INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_all
SELECT c.guid FROM creature c
WHERE c.map IN (0, 1) AND c.guid NOT IN (SELECT spawn_id FROM zerocraft_deployables);
INSERT IGNORE INTO zerocraft_removed_creatures SELECT c.* FROM creature c JOIN zc_all a ON a.guid = c.guid;
DELETE ca  FROM creature_addon ca       JOIN zc_all a ON a.guid = ca.guid;
DELETE gec FROM game_event_creature gec JOIN zc_all a ON a.guid = gec.guid;
DELETE pc  FROM pool_creature pc        JOIN zc_all a ON a.guid = pc.guid;
DELETE lc  FROM linked_respawn lc       JOIN zc_all a ON a.guid = lc.guid;
DELETE c   FROM creature c              JOIN zc_all a ON a.guid = c.guid;
SELECT COUNT(*) AS creatures_removed FROM zc_all;
SELECT COUNT(*) AS creatures_left_on_both_continents FROM creature WHERE map IN (0, 1);
DROP TEMPORARY TABLE zc_all;

-- ZeroCraft: the Horde/Alliance faction tabards can be worn by anyone at any PvP rank, and can't be sold or lost
UPDATE item_template SET requiredhonorrank = 0, RequiredReputationFaction = 0, RequiredReputationRank = 0, AllowableRace = -1, AllowableClass = -1, bonding = 1
WHERE entry IN (15196, 15197, 5976);
SELECT entry, name, requiredhonorrank, AllowableRace, bonding FROM item_template WHERE entry IN (15196, 15197, 5976);

-- ZeroCraft: deployed NPCs remember their guild's NAME, so a re-founded guild of the same name gets them back
SET @has := (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'acore_world' AND TABLE_NAME = 'zerocraft_deployables' AND COLUMN_NAME = 'owner_guild_name');
SET @sql := IF(@has = 0, 'ALTER TABLE zerocraft_deployables ADD COLUMN owner_guild_name VARCHAR(24) NOT NULL DEFAULT ''''', 'SELECT 1');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- guilds that still exist
UPDATE zerocraft_deployables d JOIN acore_characters.guild g ON g.guildid = d.owner_guild
SET d.owner_guild_name = g.name WHERE d.owner_guild_name = '';

-- orphans whose guild is already gone: Theramore -> the Rebels, Menethil -> the Pirates
UPDATE zerocraft_deployables d JOIN creature c ON c.guid = d.spawn_id
SET d.owner_guild_name = 'the Rebels'
WHERE d.owner_guild_name = '' AND c.map = 1 AND c.position_x BETWEEN -4100 AND -3400 AND c.position_y BETWEEN -4800 AND -4100;
UPDATE zerocraft_deployables d JOIN creature c ON c.guid = d.spawn_id
SET d.owner_guild_name = 'the Pirates'
WHERE d.owner_guild_name = '' AND c.map = 0 AND c.position_x BETWEEN -4100 AND -3500 AND c.position_y BETWEEN -1100 AND -400;

SELECT owner_guild_name, owner_guild, (owner_guild IN (SELECT guildid FROM acore_characters.guild)) AS guild_exists, COUNT(*) AS npcs
FROM zerocraft_deployables GROUP BY owner_guild_name, owner_guild;

-- ZeroCraft: finish tidying NPC ownership
-- an old guild's NPCs all share one name: copy it to the ones the location guess missed
UPDATE zerocraft_deployables d
JOIN (SELECT owner_guild, MAX(owner_guild_name) AS n FROM zerocraft_deployables WHERE owner_guild > 0 AND owner_guild_name <> '' GROUP BY owner_guild) x
  ON x.owner_guild = d.owner_guild
SET d.owner_guild_name = x.n WHERE d.owner_guild_name = '';
-- NPCs deployed before guilds existed: if the character still exists, they join that character's guild
UPDATE zerocraft_deployables d
JOIN acore_characters.guild_member gm ON gm.guid = d.owner_player
JOIN acore_characters.guild g ON g.guildid = gm.guildid
SET d.owner_guild_name = g.name
WHERE d.owner_guild = 0 AND d.owner_guild_name = '';
SELECT owner_guild_name, owner_guild, COUNT(*) AS npcs FROM zerocraft_deployables GROUP BY owner_guild_name, owner_guild;

-- ZeroCraft: Recall Orders item
DROP TEMPORARY TABLE IF EXISTS zc_rc;
CREATE TEMPORARY TABLE zc_rc (id INT PRIMARY KEY, disp INT, ord INT);
INSERT IGNORE INTO zc_rc VALUES (5041,6423,0),(1267,6359,1),(6213,4717,2),(8164,1069,3),(17163,29131,4),(23656,34744,5);
SET @old := (SELECT entry FROM item_template WHERE ScriptName = 'item_zerocraft_recall' LIMIT 1);
SET @id := COALESCE(@old, (SELECT id FROM zc_rc WHERE id NOT IN (SELECT entry FROM item_template) ORDER BY ord LIMIT 1));
SET @disp := COALESCE((SELECT disp FROM zc_rc WHERE id = @id), 6338);
DELETE FROM item_template WHERE entry = @id;
DROP TEMPORARY TABLE IF EXISTS zc_r;
CREATE TEMPORARY TABLE zc_r SELECT * FROM item_template WHERE ScriptName = 'item_zerocraft_guild_charter' LIMIT 1;
UPDATE zc_r SET entry = @id, name = 'Recall Orders', displayid = @disp, Quality = 1,
  description = 'Target one of your NPCs and use to pack it back into its scroll.',
  ScriptName = 'item_zerocraft_recall';
INSERT INTO item_template SELECT * FROM zc_r;
DROP TEMPORARY TABLE zc_r;
DROP TEMPORARY TABLE zc_rc;
SELECT entry, name, displayid, spellid_1, ScriptName FROM item_template WHERE ScriptName = 'item_zerocraft_recall';

-- ZeroCraft: invisible marker that floats a blue "!" over each Guild Vault
DELETE FROM creature_template WHERE entry = 911100;
DROP TEMPORARY TABLE IF EXISTS zc_mk;
CREATE TEMPORARY TABLE zc_mk SELECT * FROM creature_template WHERE entry = 15384;
UPDATE zc_mk SET entry = 911100, name = 'Guild Vault', subname = '', npcflag = 2, faction = 35,
  unit_flags = 0x2000000 | 0x2 | 0x100 | 0x200, flags_extra = 0,
  ScriptName = 'npc_zerocraft_vault_marker', AIName = '', minlevel = 1, maxlevel = 1;
INSERT INTO creature_template SELECT * FROM zc_mk;
DROP TEMPORARY TABLE zc_mk;
DELETE FROM creature_template_model WHERE CreatureID = 911100;
INSERT INTO creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability) VALUES (911100, 0, 11686, 1, 1);
SELECT entry, name, npcflag, unit_flags, ScriptName FROM creature_template WHERE entry = 911100;

-- ZeroCraft: the guild Banker talks. No more vault chest; blue "!" floats over the Banker instead.
UPDATE creature_template SET name = 'Banker' WHERE entry = 911100;
DELETE FROM npc_text WHERE ID BETWEEN 911200 AND 911204;
INSERT INTO npc_text (ID, text0_0, text0_1, Probability0) VALUES
(911200,
 'Ah, $N. Pull up a crate and mind the ledgers.$B$BEvery blade standing out there wears our colors - and every one of them expects to be paid. Guards, smiths, that sour innkeeper, even the fellow who feeds the wyverns. Loyalty is a fine word, $C, but it does not fill a belly.$B$BThe coffers pay them every hour. Keep the gold coming, and they will hold the line for you until the end of days.',
 'Ah, $N. Pull up a crate and mind the ledgers.$B$BEvery blade standing out there wears our colors - and every one of them expects to be paid. Guards, smiths, that sour innkeeper, even the fellow who feeds the wyverns. Loyalty is a fine word, $C, but it does not fill a belly.$B$BThe coffers pay them every hour. Keep the gold coming, and they will hold the line for you until the end of days.',
 1),
(911201,
 'Here is the ledger, $N, line by line. I count it twice a day - three times when the drums start.$B$BWhen the coffers run dry, the soldiers stop eating. When they stop eating, they start dying. Slowly, a quarter of their strength each hour, until there is nothing left to bury.',
 'Here is the ledger, $N, line by line. I count it twice a day - three times when the drums start.$B$BWhen the coffers run dry, the soldiers stop eating. When they stop eating, they start dying. Slowly, a quarter of their strength each hour, until there is nothing left to bury.',
 1),
(911202,
 'Nobody here works for free, $C. Not even me.$B$BHeroes cost the most - legends have expensive tastes. The Flight Masters and I keep the whole network breathing, so we are not cheap either. Shopkeepers and smiths ask little, and a plain guard asks less.$B$BAnd mind this: if an enemy ever puts a blade through me, everything in these coffers goes with my corpse. Guard your Banker, $N.',
 'Nobody here works for free, $C. Not even me.$B$BHeroes cost the most - legends have expensive tastes. The Flight Masters and I keep the whole network breathing, so we are not cheap either. Shopkeepers and smiths ask little, and a plain guard asks less.$B$BAnd mind this: if an enemy ever puts a blade through me, everything in these coffers goes with my corpse. Guard your Banker, $N.',
 1),
(911203,
 'Counted, weighed, and locked away. The troops will drink to your name tonight, $N.',
 'Counted, weighed, and locked away. The troops will drink to your name tonight, $N.',
 1),
(911204,
 '$N! Thank the Light - or whatever you pray to. The coffers are EMPTY.$B$BThe soldiers have gone unpaid and they are wasting away out there. Every hour we wait, they lose another quarter of their strength. A few more hours and they will be corpses in our colors.$B$BGold, $C. Now. Please.',
 '$N! Thank the Light - or whatever you pray to. The coffers are EMPTY.$B$BThe soldiers have gone unpaid and they are wasting away out there. Every hour we wait, they lose another quarter of their strength. A few more hours and they will be corpses in our colors.$B$BGold, $C. Now. Please.',
 1);
SELECT ID, LEFT(text0_0, 60) FROM npc_text WHERE ID BETWEEN 911200 AND 911204;

-- ZeroCraft: the Magic Rooster is the only mount - no other mounts at character creation
DELETE s FROM playercreateinfo_spell_custom s
WHERE s.Spell IN (23229, 23238, 23241, 23225, 35710, 23250, 23246, 23249, 23257, 35025, 60025, 32242, 5784, 23161, 13819, 23214, 34769, 34767, 65917);
DELETE FROM playercreateinfo_action WHERE type = 0 AND action IN (23229, 23249, 23241, 60025, 32242);
SELECT COUNT(*) AS mount_spells_left_at_creation FROM playercreateinfo_spell_custom WHERE Spell IN (23229, 23249, 23241, 60025, 32242);

-- ZeroCraft: Builder's Kit (place useful things and decorations) + Musician, Dancer and Stable Master scrolls.
-- All four use item IDs freed when the deploy scrolls moved (they exist in the client, so they get icons).

CREATE TABLE IF NOT EXISTS zerocraft_placed (
  kind TINYINT UNSIGNED NOT NULL,           -- 0 = game object, 1 = creature
  spawn_id INT UNSIGNED NOT NULL,
  owner_guild INT UNSIGNED NOT NULL DEFAULT 0,
  owner_player INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (kind, spawn_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS zerocraft_deploy_pool (
  item_entry INT UNSIGNED NOT NULL,
  npc_entry INT UNSIGNED NOT NULL,
  emote INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (item_entry, npc_entry)
) ENGINE=InnoDB;

-- clone the Guard scroll (ground circle + deploy cast) for the three new NPC scrolls
DELETE FROM item_template WHERE entry IN (1267, 6213, 17163, 8164);
DROP TEMPORARY TABLE IF EXISTS zc_s;
CREATE TEMPORARY TABLE zc_s SELECT * FROM item_template WHERE entry = 823;
UPDATE zc_s SET entry = 1267,  name = 'Deployable Musician',      Quality = 2;
INSERT INTO item_template SELECT * FROM zc_s;
UPDATE zc_s SET entry = 6213,  name = 'Deployable Dancer',        Quality = 2;
INSERT INTO item_template SELECT * FROM zc_s;
UPDATE zc_s SET entry = 17163, name = 'Deployable Stable Master', Quality = 3;
INSERT INTO item_template SELECT * FROM zc_s;
-- Builder's Kit: same ground circle, never used up, own script, hammer icon
UPDATE zc_s SET entry = 8164, name = 'Builder''s Kit', Quality = 3, stackable = 1, maxcount = 1, bonding = 1,
  displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 5956), displayid),
  description = 'Click a spot on the ground, then choose what to build there.',
  ScriptName = 'item_zerocraft_builder';
INSERT INTO item_template SELECT * FROM zc_s;
DROP TEMPORARY TABLE zc_s;

DELETE FROM zerocraft_deploy_pool WHERE item_entry IN (1267, 6213, 17163);
-- musicians: the Tauren Chieftains and the wandering minstrel
INSERT INTO zerocraft_deploy_pool (item_entry, npc_entry, emote) VALUES
 (1267, 23619, 0), (1267, 23623, 0), (1267, 23625, 0), (1267, 23626, 0), (1267, 1451, 0);
-- dancers (always dancing: emote 10)
INSERT INTO zerocraft_deploy_pool (item_entry, npc_entry, emote) VALUES
 (6213, 25970, 10), (6213, 25974, 10), (6213, 33291, 10), (6213, 40356, 10);
-- stable masters: any removed stable master
INSERT IGNORE INTO zerocraft_deploy_pool (item_entry, npc_entry, emote)
SELECT DISTINCT 17163, r.id, 0 FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.npcflag & 0x400000) <> 0 AND ct.`rank` <> 3;

-- every new character starts with the kit and one of each new scroll
DELETE FROM playercreateinfo_item WHERE itemid IN (1267, 6213, 17163, 8164);
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 1267, 1 FROM playercreateinfo;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 6213, 1 FROM playercreateinfo;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 17163, 1 FROM playercreateinfo;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 8164, 1 FROM playercreateinfo;

SELECT entry, name, spellid_1, ScriptName FROM item_template WHERE entry IN (1267, 6213, 17163, 8164);
SELECT item_entry, COUNT(*) AS npcs FROM zerocraft_deploy_pool GROUP BY item_entry;

-- ZeroCraft: musician/dancer/stable master now come from the Builder's Kit, so new characters don't get separate scrolls
DELETE FROM playercreateinfo_item WHERE itemid IN (1267, 6213, 17163);
SELECT COUNT(*) AS separate_npc_scrolls_at_start FROM playercreateinfo_item WHERE itemid IN (1267, 6213, 17163);

-- ZeroCraft: Builder's Catalog - every placeable object found in the game files, sorted by style
CREATE TABLE IF NOT EXISTS zerocraft_catalog (id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, category VARCHAR(40) NOT NULL, name VARCHAR(64) NOT NULL, entry INT UNSIGNED NOT NULL, KEY cat (category)) ENGINE=InnoDB;
DELETE FROM zerocraft_catalog;
INSERT INTO zerocraft_catalog (category, name, entry) VALUES
('Dark Iron','Broken Keg',186808),
('Dark Iron','Broken Keg',186809),
('Dark Iron','Charred Dark Iron Remains',153157),
('Dark Iron','Charred Dark Iron Remains',153160),
('Dark Iron','Dark Iron Wood Planks 06',193483),
('Dark Iron','DARKIRONCHAIR 01',136929),
('Dark Iron','DARKIRONCHAIR 02',136931),
('Dark Iron','DARKIRONCHAIR 03',136924),
('Dark Iron','DARKIRONCHAIRBROKEN 01',136930),
('Dark Iron','darkirongrindingwheel',193149),
('Dark Iron','darkironwoodplanks 01',193482),
('Dark Iron','darkironwoodplanks 03',193484),
('Dark Iron','Imperial Throne',170592),
('Dark Iron','Mutilated Dark Iron Remains',153158),
('Dark Iron','Mutilated Dark Iron Remains',153159),
('Dark Iron','Porta-pew',190740),
('Dark Iron','Skeleton Laying 01',192974),
('Dark Iron','Skeleton Laying 02',192964),
('Dark Iron','Skeleton Laying 03',192963),
('Dark Iron','Treasure Marker',180653),
('Dwarf','Abandon hope, all ye who enter here.',177185),
('Dwarf','Apothecary Zelana Tent',184696),
('Dwarf','Barim''s Reagents',26487),
('Dwarf','Barrel of Powder',1670),
('Dwarf','Beer Wagon',186250),
('Dwarf','BerryFizz Potions and Mixed Drinks',34357),
('Dwarf','Camp Pavilion',181301),
('Dwarf','Craghelm''s Plate and Chain',26480),
('Dwarf','Dwarven High Back Chair',28611),
('Dwarf','Dwarven Table Ornate 01',180324),
('Dwarf','Dwarven Table Small',180884),
('Dwarf','DWARVENBRAZIER 02',1743),
('Dwarf','DWARVENCHAIR 04',193951),
('Dwarf','DWARVENCHAIR 05',193949),
('Dwarf','dwarventablesimple 05',195191),
('Dwarf','Excavation Banner Stand',193473),
('Dwarf','Excavation Barrier 02 Pv PCollision',190884),
('Dwarf','Excavation Stake',180007),
('Dwarf','excavationtentruined 01',193468),
('Dwarf','excavationtentruined 02',193469),
('Dwarf','Finespindle''s Leather Goods',32350),
('Dwarf','Fizzlespinner''s General Goods',26483),
('Dwarf','FORGEBONFIRE',34571),
('Dwarf','Goldfury''s Hunting Supplies',26482),
('Dwarf','Hardpacked Explosive Bundle',191841),
('Dwarf','Ironforge Visitor''s Center',26490),
('Dwarf','IRONFORGECHAIR ORNATE 01',183753),
('Dwarf','J.D.''s Work Table',174681),
('Dwarf','Jhang''s Lunchbox',185006),
('Dwarf','mallet 01',193150),
('Dwarf','NG-5 Explosives (Red)',19592),
('Dwarf','Platter Gold Ornate 02',181591),
('Dwarf','Springspindle''s Gadgets',32353),
('Dwarf','Standing Brewfest Keg',186709),
('Dwarf','Stone Chair',142947),
('Dwarf','Stone Chair',171674),
('Dwarf','Stoneblade''s',142874),
('Dwarf','Stonebranch Herbalist',26493),
('Dwarf','Stormwind Dwarf Brazier',179984),
('Dwarf','The Bronze Kettle',26498),
('Dwarf','The Stonefire Tavern',26486),
('Dwarf','Things That Go Boom!',32354),
('Dwarf','This Way',123215),
('Dwarf','Thunder Ale',369),
('Dwarf','Timberline Arms',26488),
('Dwarf','Toolbox 01',193151),
('Dwarf','Traveling Fisherman',32352),
('Dwarf','Vanguard Infirmary',192522),
('Dwarf','WotLK Light Tent',190794),
('General','Air Elemental Rift',179667),
('General','Alchemy Lab',177387),
('General','Alchemy Lab',180631),
('General','Alchemy Lab',187115),
('General','Alliance Marker',187692),
('General','Alliance Supply Crate',178646),
('General','Altar of the Tides - Focused',2563),
('General','Amadi Apples',183995),
('General','Ancient Statuette',18603),
('General','Animal Trainer Tent',180039),
('General','AQWar - Resource, Bandages, Alliance, Initial',180598),
('General','AQWar - Resource, Bandages, Alliance, Tier 1',180674),
('General','AQWar - Resource, Bandages, Alliance, Tier 2',180675),
('General','AQWar - Resource, Bandages, Alliance, Tier 3',180676),
('General','AQWar - Resource, Bandages, Alliance, Tier 4',180677),
('General','AQWar - Resource, Bandages, Alliance, Tier 5',180678),
('General','AQWar - Resource, Bandages, Horde, Initial',180826),
('General','AQWar - Resource, Bandages, Horde, Tier 1',180827),
('General','AQWar - Resource, Bandages, Horde, Tier 2',180828),
('General','AQWar - Resource, Bandages, Horde, Tier 3',180829),
('General','AQWar - Resource, Bandages, Horde, Tier 4',180830),
('General','AQWar - Resource, Bandages, Horde, Tier 5',180831),
('General','AQWar - Resource, Bars, Alliance, Initial',180680),
('General','AQWar - Resource, Bars, Alliance, Tier 1',180780),
('General','AQWar - Resource, Bars, Alliance, Tier 2',180781),
('General','AQWar - Resource, Bars, Alliance, Tier 3',180782),
('General','AQWar - Resource, Bars, Alliance, Tier 4',180783),
('General','AQWar - Resource, Bars, Alliance, Tier 5',180784),
('General','AQWar - Resource, Bars, Horde, Initial',180838),
('General','AQWar - Resource, Bars, Horde, Tier 1',180839),
('General','AQWar - Resource, Bars, Horde, Tier 2',180840),
('General','AQWar - Resource, Bars, Horde, Tier 3',180841),
('General','AQWar - Resource, Bars, Horde, Tier 4',180842),
('General','AQWar - Resource, Bars, Horde, Tier 5',180843),
('General','AQWar - Resource, Cooking, Alliance, Tier 1',180800),
('General','AQWar - Resource, Cooking, Alliance, Tier 2',180806),
('General','AQWar - Resource, Cooking, Alliance, Tier 3',180807),
('General','AQWar - Resource, Cooking, Alliance, Tier 4',180808),
('General','AQWar - Resource, Cooking, Alliance, Tier 5',180809),
('General','AQWar - Resource, Cooking, Horde, Initial',180832),
('General','AQWar - Resource, Cooking, Horde, Tier 1',180833),
('General','AQWar - Resource, Cooking, Horde, Tier 2',180834),
('General','AQWar - Resource, Cooking, Horde, Tier 3',180835),
('General','AQWar - Resource, Cooking, Horde, Tier 4',180836),
('General','AQWar - Resource, Cooking, Horde, Tier 5',180837),
('General','AQWar - Resource, Cooking/Herbs, Alliance Initial',180679),
('General','AQWar - Resource, Herbs, Alliance, Tier 1',180801),
('General','AQWar - Resource, Herbs, Alliance, Tier 2',180802),
('General','AQWar - Resource, Herbs, Alliance, Tier 3',180803),
('General','AQWar - Resource, Herbs, Alliance, Tier 4',180804),
('General','AQWar - Resource, Herbs, Alliance, Tier 5',180805),
('General','AQWar - Resource, Herbs, Horde, Initial',180818),
('General','AQWar - Resource, Herbs, Horde, Tier 1',180819),
('General','AQWar - Resource, Herbs, Horde, Tier 2',180820),
('General','AQWar - Resource, Herbs, Horde, Tier 3',180821),
('General','AQWar - Resource, Herbs, Horde, Tier 4',180822),
('General','AQWar - Resource, Herbs, Horde, Tier 5',180823),
('General','AQWar - Resource, Skins, Alliance, Initial',180681),
('General','AQWar - Resource, Skins, Alliance, Tier 1',180692),
('General','AQWar - Resource, Skins, Alliance, Tier 2',180693),
('General','AQWar - Resource, Skins, Alliance, Tier 3',180694),
('General','AQWar - Resource, Skins, Alliance, Tier 4',180695),
('General','AQWar - Resource, Skins, Alliance, Tier 5',180696),
('General','AQWar - Resource, Skins, Horde, Initial',180812),
('General','AQWar - Resource, Skins, Horde, Tier 1',180813),
('General','AQWar - Resource, Skins, Horde, Tier 2',180814),
('General','AQWar - Resource, Skins, Horde, Tier 3',180815),
('General','AQWar - Resource, Skins, Horde, Tier 4',180816),
('General','AQWar - Resource, Skins, Horde, Tier 5',180817),
('General','Arcanist Maisie the Storm-Summoner',183853),
('General','Argent Dawn Buffer Crate',181255),
('General','Argent Dawn Buffer Tent',181254),
('General','Argent Tome',191312),
('General','Ashenvale Moonwell',20806),
('General','Aura Blue Short',184831),
('General','Baby Dw',185505),
('General','Baby Gn',185506),
('General','Baby Hu',185507),
('General','Baby Ne',185508),
('General','Baby Or',185509),
('General','Baby Ta',185510),
('General','Baby Tr',185511),
('General','Bananas (Display)',190645),
('General','Barrel 02',180779),
('General','Barrow Light',185476),
('General','Basket of Corn',195192),
('General','Bat 01',180426),
('General','Bat 02',180427),
('General','Beerfest Banner 02',186229),
('General','Bellowfiz Bubbles',275),
('General','Beryl Shield',187773),
('General','Black Smoke - scale 2',965),
('General','Black Smoke Emitter',1604),
('General','Blacksmith''s Anvil',1684),
('General','BLACKSMITHFORGE',4090),
('General','Blight Fog Effect',190941),
('General','Bloodpetal Target',160465),
('General','Bly''s Escape Portal',142074),
('General','Bone 02',180222),
('General','Bones of Aggonar',181479),
('General','BOW CROSSBOW PVPALLIANCE A 01',193765),
('General','Box o'' Squirrels',178304),
('General','Brazier of Beckoning',181045),
('General','Brazier of Dancing Flames',187457),
('General','Brazier of Invocation',181051),
('General','Brewfest Banner',186717),
('General','Brewfest Beer Tent',186682),
('General','Brewfest Canopy',186680),
('General','Brewfest Food Tent',186681),
('General','Brewfest Keg Breakable',186173),
('General','Brewfest Wagon Loaded',186737),
('General','Bridge 4',19403),
('General','Broken Barrel 01',190880),
('General','Broken Barrel 02',190881),
('General','Bubbly Fissure',177524),
('General','Burning Seed Circle of Power',3218),
('General','Burning Wreckage',186278),
('General','Camp Banner',188020),
('General','Camp Pavilion',188021),
('General','Candle 01 - MFF',187572),
('General','Candle 02',180339),
('General','Candle 02 - MFF',187573),
('General','Candle 03',180340),
('General','Candle of Beckoning',1558),
('General','Candy Skulls',195069),
('General','Cannon Target',180573),
('General','Carnival Railing',180035),
('General','Cauldron Smoke',184717),
('General','CAVEMINEWHEELBARROW 01',190859),
('General','Christmas Tree',178647),
('General','Christmas Tree (Large Snowy)',178558),
('General','Christmas Tree (Large)',178425),
('General','Christmas Tree (Medium)',178557),
('General','Clefthoof Carrion Flies',184730),
('General','Cluster Launcher',180772),
('General','Coldwind Tree',188539),
('General','Comestic Chest 02 (2.00)',188225),
('General','COT Hour Glass redo',190686),
('General','Crate 01',195198),
('General','Crate 02',193637),
('General','Crate Alliance First Aid 01',180714),
('General','Crate Highlight',190117),
('General','Crate Horde First Aid 01',180599),
('General','Dark Iron Mole Machine',186763),
('General','Dark Light',181641),
('General','Dark Portal',185103),
('General','DARKMOON FAIRE',180029),
('General','Darkmoon Faire Banner',179965),
('General','Darkmoon Faire Carnie Tent Small',179966),
('General','Darkmoon Faire Wagon Loaded',180005),
('General','Darkmoon Faire Wagon Unloaded',180036),
('General','Darkstone of Terokk',185191),
('General','Demonic Circle: Summon',191083),
('General','Den of Dying Plague Cauldron',187879),
('General','Divination Scryer',179708),
('General','Drakuru''s Brazier',188287),
('General','Dust Bag',181962),
('General','Dwarf Hero',180755),
('General','Easter Egg 01',177272),
('General','Ectoplasmic Distiller',181057),
('General','Empty Arcane Prison',187772),
('General','Empty Brew Wagon',186683),
('General','Equinex Monolith Lights 1',146082),
('General','Equinex Monolith Lights 2',146083),
('General','Fancy Bed',13948),
('General','Farseer Grimwalker''s Remains',187680),
('General','Fetish of Sar''this',185856),
('General','Fire Effigy',186720),
('General','Fire Elemental Rift',179666),
('General','Firework Launcher',180771),
('General','Firework Rocket, Type 1 Blue',180854),
('General','Firework, Show, Type 3 Red',180705),
('General','Firework, Show, Type 4 Red',180706),
('General','Fishing Chair',186475),
('General','Flare of Justice',181987),
('General','Floating Sparkles',2722),
('General','Floating, Medium - MFF',181354),
('General','Floating, Medium - Val',181027),
('General','Food Tent',180031),
('General','Forsaken Hero Portrait',180760),
('General','Forsaken Stink Bomb Cloud',195122),
('General','Fortune Teller''s Tent',180030),
('General','Franclorn Light Shaft',171924),
('General','Freestanding Torch 01',180043),
('General','Fused Wiring',188091),
('General','G Brazier 01',192020),
('General','G Cage 02',181379),
('General','G Candy Bucket 01',180412),
('General','G Cannon 01',190228),
('General','G Ghost 01',180411),
('General','G Gnome Terminal',193668),
('General','G GOBLINTELEPORTER',142175),
('General','G Hanging Skeleton 01',180410),
('General','G Hologram Base Tanaris',193674),
('General','G Jewel Black',180787),
('General','G Mortar',190229),
('General','G Pumpkin 01',180405),
('General','G Pumpkin 02',180406),
('General','G Pumpkin 03',180407),
('General','G Scourge Rune Circle Crystal',181227),
('General','g shellshield',193795),
('General','G Witch Broom 01',180409),
('General','G Witch Hat 01',180408),
('General','G Xmas Wreath',178437),
('General','General Torch 01',180352),
('General','Ghostly Cooking Fire',195087),
('General','Gizmond''s Flying Machine',186558),
('General','Glowing Soulgem',19862),
('General','Gnome Hero',180756),
('General','Grimshade''s Vision',144069),
('General','Grom''s Forsaken Tribute',180208),
('General','Grown Mushroom',182073),
('General','HAMMER PVPHORDE A 01',193693),
('General','Hanging Body 2',19415),
('General','Hanging Skull Light 01',180471),
('General','Hanging Skull Light 02',180472),
('General','Hanging, Door - Val',181021),
('General','Hanging, Short/Squat, Large',181024),
('General','Hanging, Square, Large - Brewfest',195254),
('General','Hanging, Square, Large - MFF',181358),
('General','Hanging, Square, Large - Val',181014),
('General','Hanging, Square, Medium - MFF',181390),
('General','Hanging, Square, Medium - Val',181020),
('General','Hanging, Streamer - Brewfest',195266),
('General','Hanging, Streamer - MFF',181392),
('General','Hanging, Streamer - Val',181017),
('General','Hanging, Streamer x3 - Brewfest',195253),
('General','Hanging, Streamer x3 - MFF',181401),
('General','Hanging, Tall/Thin, Large - Brewfest',195255),
('General','Hanging, Tall/Thin, Large - MFF',181389),
('General','Hanging, Tall/Thin, Large - Val',181025);
INSERT INTO zerocraft_catalog (category, name, entry) VALUES
('General','Hanging, Tall/Thin, Medium - Val',181018),
('General','Hanging, Tall/Thin, Small - Brewfest',195257),
('General','Harpy Tail Feather',188494),
('General','Hay Bail 01',180037),
('General','Hay Bail 02',180038),
('General','Hive Fireflies 01',210341),
('General','Horde Bell',175885),
('General','Horde Marker',187691),
('General','Human Hero Portrait',180757),
('General','Human Tent Medium',184592),
('General','Ice Block',188067),
('General','iCoke Tent',181244),
('General','Icy Rune',186747),
('General','Imbued Drakkari Offering',188595),
('General','Imp in a Ball',185898),
('General','In Case of Emergency, Push Button',179480),
('General','Inn Barrel',179973),
('General','Inn Pillow',194865),
('General','Intact Barrel',186281),
('General','J.D.''s Manual',174683),
('General','Jaguar - Crocolisk Cage',181625),
('General','Jhang''s Sack',185007),
('General','Kodo Fossil',64855),
('General','Kraz''s Chest',186658),
('General','L70ETC Bleachers',186393),
('General','L70ETC Stage',186300),
('General','Lair Exit',211035),
('General','Large Tent',184593),
('General','Legion Ring Fog',185593),
('General','Ley Line Focus',188445),
('General','Light of Elune',177415),
('General','Light of Elune',180713),
('General','Light of Retribution',149410),
('General','light Skeleton Laying 01',176745),
('General','light Skeleton Laying 02',185454),
('General','light Skeleton Laying 03',185455),
('General','light Skeleton Sitting 01',185434),
('General','light Skeleton Sitting 02',185435),
('General','light Skeleton Sitting 03',185436),
('General','light Skeleton Sitting 04',185438),
('General','Lights x3, Broken',178745),
('General','Lights, Broken',178551),
('General','Little Flame Emitter',1603),
('General','Lucky Red Envelope',180909),
('General','Lunar New Year Banner Alliance Hanging',180773),
('General','Lunar New Year Banner Alliance Hanging 02',180774),
('General','Lunar New Year Banner Alliance Standing',180777),
('General','Lunar New Year Banner Horde Hanging',180775),
('General','Lunar New Year Banner Horde Hanging 02',180776),
('General','Lunar New Year Banner Horde Standing',180778),
('General','Lunar New Year Lantern Alliance Hanging',180765),
('General','Lunar New Year Lantern Alliance Standing',180766),
('General','Lunar New Year Lantern Horde Hanging',180767),
('General','Lunar New Year Lantern Horde Standing',180768),
('General','Lunar New Year Lights',180769),
('General','Lunar New Year Lights X 3',180770),
('General','mace 1h ulduarraidnotskinable d 01',192492),
('General','Mana Rift',103680),
('General','Mark of Detonation',177668),
('General','Meetingstone 01',190343),
('General','Merithra''s Wake',180604),
('General','Message to the Wildhammer',179911),
('General','Metal Bar Stack 01Copper',180590),
('General','Metal Bar Stack 01Iron',180591),
('General','Metal Bar Stack 01Mithril',180595),
('General','Metal Bar Stack 01Truesilver',180592),
('General','Metal Bar Stack 02Copper',180593),
('General','Metal Bar Stack 02Iron',180596),
('General','Metal Bar Stack 02Mithril',180586),
('General','Metal Bar Stack 02Truesilver',180597),
('General','Metal Bars 01Copper',180594),
('General','Metal Bars 01Iron',180587),
('General','Metal Bars 01Mithril',180588),
('General','Metal Bars 01Truesilver',180589),
('General','mistletoe',178554),
('General','mistletoe 02',180844),
('General','Molten Core Instance Portal',181623),
('General','Monestary Hall Door',19587),
('General','Muigin''s Sprout',165559),
('General','Necropolis City',181172),
('General','Night Elf Hero Portrait',180758),
('General','Northridge Lumber Mill Crate',177492),
('General','NPC Fishing Bobber',187376),
('General','Offering Bowl',195068),
('General','Oracle Glade Moonwell',19552),
('General','Orange Marigolds',195063),
('General','Orange Marigolds',195307),
('General','Orb of Translocation Target',187429),
('General','Orc Hero Portrait',180759),
('General','ORG ARENA AXE PILLAR',192657),
('General','Pentarus'' Portal to Sholazar Basin',190488),
('General','Pirate Flag',187083),
('General','Plague Cauldron Active Base',190935),
('General','Pools of Arlithrien Moonwell',19551),
('General','Portal from Shattrath City',187335),
('General','Portal to Dalaran',194481),
('General','Portal to Orgrimmar',193427),
('General','Portal to Stormwind',193956),
('General','Red Feather',182404),
('General','Rock Arch',19416),
('General','Romantic Umbrella',187265),
('General','Rope Line',178764),
('General','Rope Line Pole',178765),
('General','Rune of Return',153359),
('General','Scourge Marker',187693),
('General','Shadowglen Moonwell',19549),
('General','Shady Rest Glow',186246),
('General','Shaman Shrine',100035),
('General','Shards of Myzrael',2705),
('General','shield pvpalliance',193766),
('General','SHIELD PVPHORDE',193692),
('General','Shimmering Portal',188158),
('General','Shout Box',180044),
('General','Shout Box Generic',186714),
('General','Shrine Of Remulos',15885),
('General','Smite''s Chest',144111),
('General','Snow Ball Mound 01',192075),
('General','Souvenir Tent',180032),
('General','spring 02',193153),
('General','Standing, Exterior, Medium - Brewfest',195256),
('General','Standing, Exterior, Medium - MFF',181355),
('General','Standing, Exterior, Medium - Val',181016),
('General','Standing, Exterior, Medium - Xmas',187191),
('General','Standing, Giant - Val',181022),
('General','Standing, Interior, Medium - Brewfest',195264),
('General','Standing, Interior, Medium - MFF',181388),
('General','Standing, Interior, Medium - Val',181019),
('General','Standing, Interior, Small - Brewfest',195260),
('General','Standing, Interior, Small - MFF',181391),
('General','Standing, Interior, Small - Val',181060),
('General','Standing, Large - Brewfest',195265),
('General','Standing, Large - MFF',181300),
('General','Standing, Large - Val',181015),
('General','Starbreeze Moonwell',19550),
('General','Stormpike Supplies',178806),
('General','Summoner Shield',181142),
('General','Summoning Circle',37097),
('General','Summoning Circle',92388),
('General','Swirling Maelstrom',180669),
('General','Tainted Keg',1729),
('General','Tainted Keg Smoke',1730),
('General','Talon Den',152093),
('General','Target Practice Tent',180042),
('General','Tauren Hero Portrait',180761),
('General','Tear in the Nether',178484),
('General','Terrordale Haunting Spirit',179747),
('General','The Toxic Fogger',19586),
('General','Ticket Master Tent',180034),
('General','Tif Shl 01',181807),
('General','Tif Shl 02',181808),
('General','Tif Shl 03',181809),
('General','Tor''gash''s Cage',182163),
('General','Tradeskill Forge 01',1745),
('General','Tradeskill Forge 03',24746),
('General','Troll Hero Portrait',180762),
('General','Troll Mummy',188366),
('General','Twilight Torch',187988),
('General','Valentine Arch',181086),
('General','War Horn Shaker - Big',69420),
('General','Washing Tub',200296),
('General','Water Bucket',186614),
('General','Water Buckets',186615),
('General','Water Elemental Rift',179665),
('General','Weapon Crate Horde Axe',194874),
('General','weaponcratehordeaxeopen',194879),
('General','WotLK Light Sword Crate',191134),
('General','WotLK Light Well',190746),
('General','Writhing Mound Summoning Circle',185311),
('General','Xmas Gift 01',178428),
('General','Xmas Gift 02',178429),
('General','Xmas Gift 03',178430),
('General','Xmas Gift 04',178431),
('General','Xmas Gift 05',178432),
('General','Xmas Gift 06',178433),
('General','Xmas lights',178438),
('General','Xmas lights X 3',178624),
('General','Xmas Stocking 01',178434),
('General','Xmas Stocking 02',178435),
('General','Xmas Stocking 03',178436),
('General','Xmas Tree Large Horde 01',178426),
('General','Ysida''s Cagebase',181072),
('General','Zort''s Cauldron',188468),
('General','Zul''Farrak Cage Opener',141075),
('Gnome','Dirt Mound',19441),
('Gnome','Gnome Chair 02',191886),
('Gnome','Gnome Hazard Light Red',193631),
('Gnome','Gnome Maintenance Light 01',193586),
('Gnome','Gnome Rocket Cart',190227),
('Gnome','Gnome Street Sign 01',184149),
('Gnome','Gnome Structural Spot Light 02',193630),
('Gnome','Gnome Table',202564),
('Gnome','Gnomebucket 01',193583),
('Gnome','Gnomebucket 02',193584),
('Gnome','GNOMECHAIR 01',184733),
('Gnome','GNOMETABLE 01',193633),
('Gnome','Portable Oil Collector',187903),
('Gnome','Power Core Fragment',186441),
('Gnome','PvP Wall',19392),
('Gnome','Scourge Discombobulater',189970),
('Gnome','Subway Bench',176004),
('Gnome','Toshley''s Turbo Tesla Turret',184624),
('Gnome','Uther''s Gnome Tribute',180211),
('Goblin','Big Wagon Full of Explosives',184700),
('Goblin','Goblin Tent 01',188179),
('Goblin','Goblin Tent 02',188180),
('Goblin','Goblin Tent 03',188181),
('Goblin','Goblin Tent 04',188182),
('Goblin','Goblin Tent 05',188183),
('Goblin','Goblin Tent 06',188184),
('Goblin','Goblin Tent 07',188185),
('Goblin','Goblin Weather Vane',162024),
('Goblin','Gurda''s Shredder',178146),
('Goblin','Robotron Control Panel',181631),
('Goblin','Shredder Suit',188697),
('Human','Alchemy Gear',190445),
('Human','Aldor Target',183440),
('Human','Alliance Flagpole',186861),
('Human','Alterac Valley Supplies',178787),
('Human','Amadi Scroll',183996),
('Human','Ancient Flame',16394),
('Human','Apothecary Bench',190694),
('Human','Apothecary Table',2686),
('Human','Argent Dawn Banner',181256),
('Human','Armor Breastplate Trim',188219),
('Human','Armor Helm Trim',188220),
('Human','Armor Leather Helm Brown',188222),
('Human','Armor Leather Shirt Brown',188221),
('Human','Armor Mail Hanging Blue Long',188217),
('Human','Armor Stand',188216),
('Human','Armor Stand Mail Coif Blue',188218),
('Human','Baked Bread',2562),
('Human','ballistabow 01',193487),
('Human','ballistamissle 01',193488),
('Human','ballistawheel 01',193147),
('Human','Barbequed Buzzard Wings',2332),
('Human','Beer Keg 01',179976),
('Human','Beer Keg 02',180575),
('Human','Blue Ragdoll',186725),
('Human','Bone Fire',43116),
('Human','Book Medium Open 02',193825),
('Human','Boss Fight Altar',180875),
('Human','Bottle Smoke',2692),
('Human','Bowl of Fruit',181144),
('Human','Bread French 01',180051),
('Human','Bread French Half',180050),
('Human','Bridenbrad''s Sword',192650),
('Human','Bubbling Cauldron',2719),
('Human','bucket',2696),
('Human','Bundle of Bloodthistle',184798),
('Human','Bunkbed 01',193167),
('Human','Camp Mug',181307),
('Human','catapultwheel 01',193148),
('Human','Cathedral Square',25338),
('Human','Cathedral Square',25355),
('Human','City Hall',2159),
('Human','Covered Bridge',19421),
('Human','Crimson Wall Shield 01',190860),
('Human','Cut Woodpile',103573),
('Human','Danger! Crystalvein Mine closed!',179144),
('Human','Darkmoon Faire Signpost',180026),
('Human','Darkshire Entrance',19422),
('Human','Dead Mine Powder Keg',193640),
('Human','Dog House',180033),
('Human','Dredan''s Table',177724),
('Human','Drugan''s Keg',202218),
('Human','Duke''s Box',180853),
('Human','Duncan''s Textiles',2161),
('Human','Duskwood Bench',42080),
('Human','Duskwood Bookshelf 01',190446),
('Human','Duskwood Bookshelf 02',183268),
('Human','Duskwood Foot Locker 01',183266),
('Human','Duskwood Shop Counter',188189),
('Human','Duskwood Wardrobe 02',183267),
('Human','Dwarven District',28044),
('Human','Essential Components',2163),
('Human','Everyday Merchandise',2146),
('Human','Fiery Brazier',37089),
('Human','Fire Plume Ridge Lava Lake',4004),
('Human','Firewood Pile 01',1829),
('Human','Fish of the Day',181143),
('Human','Flowers for Tony',181063),
('Human','Flowers for Tony',181064),
('Human','Flowers for Tony',181065),
('Human','Flowers for Tony',181066),
('Human','Flowers Wreath 02',186315),
('Human','Fragrant Flowers',2109),
('Human','Fresh Lion Carcass',19875),
('Human','Front Door',19866),
('Human','Gallina Winery',111094),
('Human','General Book Stack Short 01',2695),
('Human','General Candelabra 01',2697),
('Human','General Lantern 01',179977),
('Human','GENERALCHURCHPEW 01',160846),
('Human','Globe of Scrying',178439),
('Human','Golden Goblet (Cosmetic)',192946),
('Human','Good Food',56903),
('Human','Green Bottle 01',2693),
('Human','Green Bottle 02',2694),
('Human','Green Ragdoll',186723),
('Human','Gryphon Roost',182254);
INSERT INTO zerocraft_catalog (category, name, entry) VALUES
('Human','Gun Shop Ammo Box Blue',180880),
('Human','Gun Shop Ammo Box Blue Block',180881),
('Human','Gun Shop Ammo Box Red',180882),
('Human','Gun Shop Bomb',193634),
('Human','Gun Shop Dynamite',193719),
('Human','Gun Shop Fireworks Barrel',180878),
('Human','Gun Shop Powder Keg Open',193700),
('Human','GUNSHOPMORTARSHELL',193667),
('Human','Gypsy Wagon',178666),
('Human','Hanging Cloak Red',188223),
('Human','High Back Chair',2489),
('Human','Human Brazier Corrupt',190215),
('Human','Human Brazier Magic',175075),
('Human','Human Sign Post Pointer 01',176967),
('Human','Human Sign Post Pointer 03',1771),
('Human','Human Sign Post Pointer 05',2023),
('Human','Human Sword 01',193490),
('Human','Human Sword 02',193699),
('Human','Industrial District',25334),
('Human','Inn Table Tiny',180885),
('Human','Kerri''s Weights',180054),
('Human','Lab Table',190665),
('Human','Lava Altar',19405),
('Human','Lexicon of Power',187330),
('Human','Locked ball and chain',1764),
('Human','Log Pile',194393),
('Human','Mage Quarter',25348),
('Human','Magus Rimtori''s Journal',152098),
('Human','Map of the Eastern Plaguelands',181081),
('Human','Metal Cup 03',2698),
('Human','Metal Mace',386),
('Human','Miblon''s Bait',164758),
('Human','Mug 01',180049),
('Human','Mug Foam 01',180048),
('Human','Northshire Abbey',89),
('Human','Ogremound 9',19420),
('Human','oildrum 01',193747),
('Human','Party Table',180698),
('Human','Peasent Woodpile',105568),
('Human','Pig and Whistle Tavern',2152),
('Human','Poster Knife',190353),
('Human','Potbelly Stove',3769),
('Human','POTBELLYSTOVEWALL',38019),
('Human','PVP HOLIDAY ALLIANCE AV',180399),
('Human','PVP HOLIDAY GENERIC SIGNPOST',180397),
('Human','ragdoll 01',186621),
('Human','Red Ragdoll',186724),
('Human','Replace Crate 01',179969),
('Human','Replace Crate 02',179970),
('Human','Rituals of Power',104592),
('Human','Roast Boar Platter',181145),
('Human','Rolled Scroll',187254),
('Human','Scourge Campfire',20969),
('Human','Scroll A 03',193133),
('Human','Seal Destroyed Flame',16395),
('Human','Sentinel Hill',81),
('Human','Sparkling Wine',180697),
('Human','Stairway to Mercy',187117),
('Human','Starsong Scroll',180910),
('Human','Stone Sign Pointer 01',101),
('Human','Stormpike Supplies',178807),
('Human','Stormpike Supplies',178808),
('Human','Stormwind Counting House',2145),
('Human','Stormwind Crate 01',179972),
('Human','Stormwind Rug 01',181077),
('Human','Stormwind Rug 02',180334),
('Human','Stormwind Scaffolding',190571),
('Human','Stranglevine Wine',2333),
('Human','Thane''s Boots and Shoulderpads',2151),
('Human','The Ancient Armor of the Kvaldir',187384),
('Human','The Chair',178934),
('Human','The Cheese Cutters',2148),
('Human','The Empty Quiver',2138),
('Human','The Park',25341),
('Human','The Park',25342),
('Human','The Sepulcher',1675),
('Human','The Seven Deadly Venoms',2149),
('Human','The Silver Shield',2150),
('Human','The Wine Cask',2130),
('Human','Trias'' Cheese',105188),
('Human','Troll Book 1',202889),
('Human','Turkey Leg',1587),
('Human','Unfinished Mace',35758),
('Human','Unyielding Banner',184005),
('Human','Uther''s Human Tribute',180210),
('Human','WARRIORBANNER 01',189544),
('Human','Watch Tower',19450),
('Human','Weapon Rack',183269),
('Human','Weller''s Arsenal',2139),
('Human','West Fall Grain Silo Destroyed 01',190802),
('Human','Wooden Bench',24538),
('Human','Wooden Chair',2413),
('Human','Wooden Chair',61919),
('Human','Wooden Chair',112068),
('Human','WotLK Light Altar',190741),
('Human','WotLK Light Banner, Stormwind',190748),
('Human','WotLK Light Book Open',191140),
('Human','WotLK Light Book Stack',191128),
('Human','Yellow Ragdoll',186722),
('Human','Zul''Aman Exterior Crate B',186307),
('Large buildings','Giant Sea Turtle',20820),
('Large buildings','Giant Turtle',20821),
('Large buildings','Guard Tower',20816),
('Large buildings','Holding Pen',20817),
('Large buildings','Landing Pad',20822),
('Large buildings','MD Goldmine 1Room',20811),
('Large buildings','Moon Well 2',20819),
('Large buildings','Night Elf Moon Well',20818),
('Large buildings','Orc Barracks',184363),
('Large buildings','Orc Tower',20812),
('Large buildings','Player Housing',20823),
('Large buildings','Ship, Icebreaker (Stormbreaker)',186239),
('Large buildings','Stormwind City',20827),
('Large buildings','Theramore Transport',48797),
('Large buildings','Transport Vrykul Large',187263),
('Large buildings','Zeppelin (The Wild Wench)',188513),
('Night Elf','Barrow Chest',185503),
('Night Elf','Charging Stone',2711),
('Night Elf','Confession Screen',194820),
('Night Elf','Dire Pool',178224),
('Night Elf','Dor''Danil Pillar',20724),
('Night Elf','Elf Crate 01',179971),
('Night Elf','elfwallhanging 09',185459),
('Night Elf','Elven Wooden Table 01',180879),
('Night Elf','First Aid',92537),
('Night Elf','General Goods',92528),
('Night Elf','Grove of the Ancients',12893),
('Night Elf','Mail Armor',92545),
('Night Elf','Moon Well',186218),
('Night Elf','Night Elf Sign Post Pointer 01',12351),
('Night Elf','Night Elf Stool',182077),
('Night Elf','Night Elf Tent 02 x.8',201388),
('Night Elf','Nightelf Glowing Bowl',182078),
('Night Elf','Nightelf Stone Rune',182079),
('Night Elf','Nightelf Stone Rune',182080),
('Night Elf','NIGHTELFSIGN ALCHEMIST',92526),
('Night Elf','NIGHTELFSIGN BAGS',92527),
('Night Elf','NIGHTELFSIGN CLOTHARMOR',92531),
('Night Elf','NIGHTELFSIGN COOKING',92538),
('Night Elf','NIGHTELFSIGN ENCHANTING',92529),
('Night Elf','NIGHTELFSIGN FLETCHER',92544),
('Night Elf','NIGHTELFSIGN NOBLEHOUSE',92524),
('Night Elf','NIGHTELFSIGN SHIELDS',92546),
('Night Elf','NIGHTELFSIGN STAVES',92532),
('Night Elf','NIGHTELFSIGN TAILOR',92533),
('Night Elf','NIGHTELFSIGN TAVERN',148423),
('Night Elf','NIGHTELFSIGN WEAPONSMITH',92539),
('Night Elf','PVP HOLIDAY ALLIANCE CTF',180400),
('Night Elf','Stone of Shy-Rotam',103819),
('Night Elf','Uther''s Night Elf Tribute',180213),
('Northrend','Ahn''kahet Brazier',193057),
('Northrend','Alchemy Lab',191540),
('Northrend','All That Glitters Prospecting Co.',192848),
('Northrend','Alliance Banner',201869),
('Northrend','Apothecary Banner',190670),
('Northrend','Apothecary Tent',190666),
('Northrend','Argent Crusade Banner',190523),
('Northrend','Argent Crusader''s Banner',195302),
('Northrend','argentcrusade banner 02',192930),
('Northrend','Arranged Crystal Formation',190503),
('Northrend','azjol web rope angled 01',192166),
('Northrend','azjol web rope straight 01',192815),
('Northrend','azjol web rope straight 03',192807),
('Northrend','BARBERSHOP POLEWALL',191741),
('Northrend','Barrier (Large)',189997),
('Northrend','BD LAVAFALL 01',191854),
('Northrend','BD LAVAFALL 03',191860),
('Northrend','Bethod''s Sword',192558),
('Northrend','Black Knight Burial',195460),
('Northrend','Blue Moon Sigil',192689),
('Northrend','Bomb Stack Inactive',193401),
('Northrend','Bonfire Northrend 01',188242),
('Northrend','Bonfire Northrend 01Blue',191407),
('Northrend','Bor''s Anvil',188654),
('Northrend','Bor''s Hammer',188653),
('Northrend','Borean Geyser 01',186941),
('Northrend','borean shrub 03',193230),
('Northrend','Broken Plague Sprayer',190539),
('Northrend','Broodmother Slivina''s Skull',190601),
('Northrend','Burning Tree Large, Chapter III',191160),
('Northrend','Burning Wreckage',190400),
('Northrend','Burnt Giant Wheel',19404),
('Northrend','Burnt Stone Tree Fire Flies VFX',190785),
('Northrend','Cartier & Co. Fine Jewelry',192846),
('Northrend','Celebration Torch',202924),
('Northrend','Chemical Wagon',201716),
('Northrend','Chunk of Saronite',190551),
('Northrend','Crucible Brazier',201600),
('Northrend','Crusader Dargath''s Light',191547),
('Northrend','Crystal Offering',195116),
('Northrend','Cultist''s Cauldron',193788),
('Northrend','DALARAN BENCH 01',191476),
('Northrend','DALARAN BENCH 02',192199),
('Northrend','DALARAN CHAIR 01',191475),
('Northrend','DALARAN CHAIR 01',193909),
('Northrend','DALARAN CHAIR 02',191887),
('Northrend','Dalaran Fountain',191446),
('Northrend','DALARAN HELM DEEPDIVEHELM SPACE',193708),
('Northrend','Dalaran Merchants'' Bank',191734),
('Northrend','dalaran rug 01',193138),
('Northrend','Dalaran Visitor Center',191678),
('Northrend','Darnassus Banner',194282),
('Northrend','Dead Orca',189315),
('Northrend','Death''s Gaze Orb',192917),
('Northrend','dragonblight fires lower 01',193386),
('Northrend','dragonblight fires lower east 02',193381),
('Northrend','dragonblight fires lower west 03',193382),
('Northrend','dragonblight fires upper east 01',193383),
('Northrend','dragonblight fires upper north 03',193384),
('Northrend','dragonblight fires upper west 02',193385),
('Northrend','dragonblight iceshard 01',192723),
('Northrend','dragonblight iceshard 02',192722),
('Northrend','dragonblight iceshard 03',192728),
('Northrend','dragonblight iceshard 04',192724),
('Northrend','dragonblight iceshard 05',192725),
('Northrend','dragonblight iceshard 06',192726),
('Northrend','Drak''Mar Brazier',194237),
('Northrend','Drakuru''s Message Stand',191765),
('Northrend','Drakuru''s Platform',190816),
('Northrend','Drakuru''s Stairs',190897),
('Northrend','Dun Argol',188330),
('Northrend','Ebon Blade Banner',192180),
('Northrend','Elder Kesuk',191088),
('Northrend','Emerald Dream Catcher 3',19490),
('Northrend','Emerald Dream Catcher 4',19491),
('Northrend','Enchanted Anvil',192697),
('Northrend','Exodar Banner',194280),
('Northrend','Eye of the Prophets',190597),
('Northrend','First to Your Aid',192843),
('Northrend','Fjorn''s Anvil',192525),
('Northrend','FK Chemistry Set 05',193407),
('Northrend','fk chemistryset 02',200333),
('Northrend','fk chemistryset 03',200334),
('Northrend','fk chemistryset 04',200335),
('Northrend','FK Tent 01',190213),
('Northrend','FK Tent 04',190217),
('Northrend','Floor Glyph',191762),
('Northrend','Forsaken Plague Barrel',200337),
('Northrend','Forsaken Plague Barrel Empty',200338),
('Northrend','Forsaken Wagon',200336),
('Northrend','FROSTGIANTICESHARD 04',192186),
('Northrend','Frostgut''s Altar',191842),
('Northrend','Frozen Bones',193961),
('Northrend','Frozen Lavaman',202436),
('Northrend','Frozen Waterfall',186666),
('Northrend','Glorious Goods',191676),
('Northrend','Gnomeregan Banner',194279),
('Northrend','Green Moon Sigil',192687),
('Northrend','Grizzly Hills Blurpleflower 01',193222),
('Northrend','Grizzly Hills Shrubs 01',193227),
('Northrend','Grizzly Hills Yellowflower 01',193224),
('Northrend','grizzlyhills shrubs 03',193221),
('Northrend','Grom''gol Zeppelin',195457),
('Northrend','hatchwindow',192718),
('Northrend','he tent 01',193130),
('Northrend','hu crane dock',193029),
('Northrend','hu fencepost northrend',194844),
('Northrend','hu scaffolding',192822),
('Northrend','hu scaffolding 02',192821),
('Northrend','HU Signpost Sign Northrend',187312),
('Northrend','hu tarp boxes',192920),
('Northrend','hu tent 01',194839),
('Northrend','hu tent 02',192925),
('Northrend','Ice Giant Piece',188229),
('Northrend','Ice Giant Piece',188230),
('Northrend','ICECROWN RAILING 01',193652),
('Northrend','icecrown rock 03',194838),
('Northrend','icecrown rock 04',194832),
('Northrend','icecrown rock 05',194833),
('Northrend','icecrown tree 01',192953),
('Northrend','icecrown tree 02',192954),
('Northrend','icecrown tree 03',192955),
('Northrend','icecrown tree 04',192956),
('Northrend','Icemist Village',188371),
('Northrend','id anvil',192582),
('Northrend','id forge',192583),
('Northrend','ID Pillar Base',190023),
('Northrend','Incense Burner',186559),
('Northrend','inscription scroll boxside',194890),
('Northrend','inscription scroll boxup',194891),
('Northrend','inscription scroll rolledblue',194893),
('Northrend','Inscription Scroll Sealed 01',194894),
('Northrend','Inscription Scroll Sealed 02',194895),
('Northrend','Ironforge Banner',194277),
('Northrend','Isle of Conquest Portal Niche Alliance',195427),
('Northrend','Isle of Conquest Portal Niche Horde',195428),
('Northrend','IT BRAZIER 02',191853),
('Northrend','Karazahn Pedestal',19467),
('Northrend','Karazahn Pedestal 2',19468),
('Northrend','Kutube''sa''s Totem',193770),
('Northrend','Kvaldir Banner',195319),
('Northrend','Langrom''s Leather & Links',191675),
('Northrend','Lavaman Pillars (Chained)',202437),
('Northrend','Lavaman Pillars (Unchained)',202438),
('Northrend','Lebronski''s Rug',186933),
('Northrend','Legendary Leathers',192847),
('Northrend','Like Clockwork',192856),
('Northrend','Lion Statue',19460),
('Northrend','Magical Menagerie',191680),
('Northrend','Magnataur Worship Candle',188438);
INSERT INTO zerocraft_catalog (category, name, entry) VALUES
('Northrend','Magnataur Worship Candle',188439),
('Northrend','Magnataur Worship Candles',188436),
('Northrend','Magnataur Worship Candles',188437),
('Northrend','Mimir''s Anvil',192125),
('Northrend','Mist of the Ancient Mariner',187707),
('Northrend','Monument to the Fallen',187116),
('Northrend','ND Human Barrier End',189996),
('Northrend','Necromantic Runestone',189314),
('Northrend','NEW IN STOCK! Enchanted Ammunition from Azeroth & Beyond!',191941),
('Northrend','Nexus Dragon Egg',188457),
('Northrend','Nexus Dragon Egg 01',193562),
('Northrend','Nexus Magic Orb Blue 01',190019),
('Northrend','Nexus Sigil Blue 01',188448),
('Northrend','Nexus Sigil Blue 02',188447),
('Northrend','Norgannon''s Binding',192134),
('Northrend','Norgannon''s Binding',192149),
('Northrend','Northrend Elwynn Campfire',191184),
('Northrend','Northrend Elwynn Campfire blue',189294),
('Northrend','northrendtorch 01',192921),
('Northrend','Oluf''s Cage',186601),
('Northrend','One More Glass',191682),
('Northrend','Orgrimmar Banner',194278),
('Northrend','Orik''s Crystalline Orb',189305),
('Northrend','Pile of Crusader Skulls',193003),
('Northrend','Plague Wagon Empty',202105),
('Northrend','Plagued Grain',188084),
('Northrend','Plagued Grain Crate',190095),
('Northrend','Poison Vial',194357),
('Northrend','potion red 04',193107),
('Northrend','Projection of the Arcanomicon',188446),
('Northrend','Purple Moon Sigil',192691),
('Northrend','PVP HOLIDAY ALLIANCE ISLE OF CONQUEST',195532),
('Northrend','PVP HOLIDAY HORDE ISLE OF CONQUEST',195533),
('Northrend','Red Moon Sigil',192690),
('Northrend','RX-214 Repair-o-matic Station',194261),
('Northrend','Sapphire Hive Honeycomb',190497),
('Northrend','Saronite Bar',201777),
('Northrend','Saronite Bars',201776),
('Northrend','sc blighter 2 green',192578),
('Northrend','SC Body Cart 01',190812),
('Northrend','SC Body Cart 02',190813),
('Northrend','SC Body Hook Arm 02',191266),
('Northrend','SC Body Hook Torso',191267),
('Northrend','SC Bodyjar',191261),
('Northrend','sc bonearm 01',192959),
('Northrend','SC Cages 01',191262),
('Northrend','SC Casting Circle 01',190615),
('Northrend','SC Fleshgiant Boot',191268),
('Northrend','SC Floor Decoration 01',191205),
('Northrend','SC Frost Glow',192077),
('Northrend','SC Meat Wagon 01',190804),
('Northrend','sc meatwagon 01 broken',193191),
('Northrend','SC Pit Cylinder',202391),
('Northrend','SC Platform 2',190919),
('Northrend','SC RUNEFORGE 01',191746),
('Northrend','SC RUNEFORGE 02',191757),
('Northrend','sc skullpikes 01',192576),
('Northrend','sc skullpikes 02',192577),
('Northrend','SC Spirit Effect 01',190921),
('Northrend','SC Spirits 01',192982),
('Northrend','SC Stairs 2',190920),
('Northrend','SC Surgical Table 01',191264),
('Northrend','SC Surgical Table 02',191265),
('Northrend','Sc Trench C Long',193612),
('Northrend','Sc Trench C Medium',193613),
('Northrend','Sc Trench C Tall',193614),
('Northrend','SC Wagon',190913),
('Northrend','sc wagon 02 broken',193193),
('Northrend','SC Wall 01 Cap',191203),
('Northrend','SC Wall 01 Ramp',191204),
('Northrend','SC Wall 06 Piece',191269),
('Northrend','Scarlet O Brazier Fire',191332),
('Northrend','Scarlet O Brazier Lit',190130),
('Northrend','Scarlet O Brazier Smoker',190150),
('Northrend','Scourge Body Wagon',190575),
('Northrend','Scourge Weapon Rack',190576),
('Northrend','Scourge Weapon Rack',190577),
('Northrend','Scrote''s Clock',188594),
('Northrend','Sen''jin Banner',194281),
('Northrend','Sen''jin Pennant',202893),
('Northrend','Shandy''s Clothesline',200297),
('Northrend','Shattered Sun Banner',187123),
('Northrend','Shattered Sun Banner (Blood Elf - Pole)',187357),
('Northrend','Shattered Sun Banner (Hanging scale x3.00)',187363),
('Northrend','Shop Counter',19624),
('Northrend','Silver Covenant Banner',196871),
('Northrend','Silvermoon City Banner',194275),
('Northrend','Simply Enchanting',192844),
('Northrend','Sisters Sorcerous',191732),
('Northrend','Sky Vortex',191767),
('Northrend','Small Boat',19484),
('Northrend','Small Coliseum Cage',195213),
('Northrend','Smoldering Leaves',191071),
('Northrend','Smoldering Leaves',191073),
('Northrend','Smoldering Leaves',191080),
('Northrend','Snake Statue',19485),
('Northrend','Soul Font',190707),
('Northrend','Spiritsbreath Incense',188443),
('Northrend','Stone Block',194461),
('Northrend','Stormwind Banner',194274),
('Northrend','Suspicious Grain Crate',190094),
('Northrend','Talismanic Textiles',192849),
('Northrend','Telestra Energy Well',188475),
('Northrend','Temple of Invention Orb',193589),
('Northrend','The Agronomical Apothecary',191731),
('Northrend','The Arsenal Absolute',191677),
('Northrend','The Filthy Animal',191681),
('Northrend','The Hunter''s Reach',191679),
('Northrend','The Militant Mystic',191674),
('Northrend','The Scribes'' Sacellum',192845),
('Northrend','The Shadow Vault Banner',192123),
('Northrend','The Shadow Vault Banner (Baron Sliver''s)',192178),
('Northrend','The Shield of the Aesirites',187386),
('Northrend','The Wonderworks',191733),
('Northrend','Thel''zan Summoning Obelisk',190156),
('Northrend','Thorim''s Throne',191647),
('Northrend','Thunder Bluff Banner',194283),
('Northrend','ti resurrection on 01',192256),
('Northrend','tradeskill firstaid 02',193105),
('Northrend','TRAPPER POTBELLYSTOVE 01',194659),
('Northrend','Troll Watch Tower',19482),
('Northrend','TS Anvil 01',187387),
('Northrend','TS Forge 01',187388),
('Northrend','Tua''kea''s Fishing Hook',188370),
('Northrend','UL THRONE 02',192654),
('Northrend','Ulduar Protective Bubble',194484),
('Northrend','Under Construction Magnataur Altar',188440),
('Northrend','Undercity Banner',194276),
('Northrend','Valduran''s Shield',191510),
('Northrend','Vehicle Teleporter',192951),
('Northrend','Venture Bay',188265),
('Northrend','Voldrune Banner',194008),
('Northrend','VR BM WOOD 01',193678),
('Northrend','VR Brazier 01',187105),
('Northrend','vr brazier 01 blue',192591),
('Northrend','VR CHAIR 01',186695),
('Northrend','VR Cookpot 01',187081),
('Northrend','VR COOKPOT 02',194679),
('Northrend','vr haybail 01',194863),
('Northrend','VR Sign Post Sign 01',186479),
('Northrend','VR Standing Light Snow Blue 01',193566),
('Northrend','vr straw large 01',19419),
('Northrend','vr straw small 01',194861),
('Northrend','vr trough',194864),
('Northrend','Vrykul Cage Base',186602),
('Northrend','Vrykul Hawk Roost',190222),
('Northrend','War Horn Base',190659),
('Northrend','Water Basin',19462),
('Northrend','Wolvar Anvil',190766),
('Northrend','Wolvar Cook Pot',190021),
('Northrend','wolvar forge',192831),
('Northrend','worc barricade',193440),
('Northrend','Wreckage A',188087),
('Northrend','Wreckage B',188088),
('Northrend','WT Brazier Lit',187317),
('Northrend','Yellow Moon Sigil',192685),
('Northrend','Zul Drak Burning Log 01',191313),
('Northrend','Zul Drak Skull Pile 02',190594),
('Northrend','Zul Drak Stone Face 01',190574),
('Northrend','Zul''Drak Spike Line',191615),
('Northrend','ZULDRAK BRAZIER 01',191834),
('Northrend','ZULDRAK TORCH 03',191836),
('Orc','Arms of Legend',173078),
('Orc','Bank of Orgrimmar',173216),
('Orc','Banner of the Bleeding Hollow Clan',181504),
('Orc','Banner of the Twilight''s Hammer Clan',181503),
('Orc','BLACKROCKORCCAMPFIRE',126312),
('Orc','Bladespire Clan Banner',184713),
('Orc','Blazing Fire',3866),
('Orc','Borstan''s Firepit',173016),
('Orc','Bowels and Brains',190656),
('Orc','Bowl Wood 02',181592),
('Orc','bowlwood 01',192589),
('Orc','Box C',184856),
('Orc','BUBBLINGBOWL 01',176157),
('Orc','Burning Embers',3825),
('Orc','Burning Embers',3832),
('Orc','Burning Embers',3865),
('Orc','Burnt Outpost 05',190863),
('Orc','Burnt Outpost 06',190864),
('Orc','Cooking Table',12665),
('Orc','Cooking Table',176463),
('Orc','Darkfire Enclave',173005),
('Orc','Death Post',179694),
('Orc','Eagle Nest',186813),
('Orc','Frostwolf Supplies',178909),
('Orc','Frostwolf Supplies',178910),
('Orc','Gotri''s Travelling Gear',173017),
('Orc','Grom''gol',3202),
('Orc','Guard Tower',19423),
('Orc','Healed Celebrian Vine',178904),
('Orc','Heated Forge',50983),
('Orc','High Quality Fur',187983),
('Orc','Horde Banner',152079),
('Orc','Horde Pavilion',191784),
('Orc','Horde Supply Crate',178442),
('Orc','Jandi''s Arboretum',173020),
('Orc','Jar Orc 01',180341),
('Orc','Jar Orc 02',180342),
('Orc','Jar Orc 03',180345),
('Orc','Jar Orc 04',180347),
('Orc','Jar Orc 05',180348),
('Orc','Jar Orc 06',180349),
('Orc','Large Fire Pit 01',3084),
('Orc','Magar''s Cloth Goods',173018),
('Orc','Meat Rack',176461),
('Orc','MEDIUMBRAZIERNOOMNI 01',18047),
('Orc','Mighty Blaze',3893),
('Orc','Mighty Blaze',172950),
('Orc','Mighty Blaze',172998),
('Orc','Mighty Blaze',173000),
('Orc','Morag''s Brew',33360),
('Orc','Orc Barrel 03',179974),
('Orc','Orc Bench 01',180326),
('Orc','Orc Brazier Lightpost Barrens',57748),
('Orc','Orc Jug 01',180350),
('Orc','Orc Jug 02',180351),
('Orc','Orc Mug 01',193146),
('Orc','Orc PVPBonfire Large',183909),
('Orc','Orc Table 01',180888),
('Orc','Orc Tent',193217),
('Orc','Orc Tent',193218),
('Orc','Orc Wagon 02',184865),
('Orc','Orc Wagon 03',184864),
('Orc','ORCAXE 02',193695),
('Orc','ORCSHIELD 02',193679),
('Orc','ORCSPEAR 03',193683),
('Orc','orctent 02',193127),
('Orc','Orgrimmar Bowyer',173080),
('Orc','PVP HOLIDAY HORDE AV',180395),
('Orc','PVP HOLIDAY HORDE CTF',180394),
('Orc','Recovered Horde Armaments',188252),
('Orc','Red Canyon Mining',173081),
('Orc','Sen''jin Bat Roost Fence Post',202839),
('Orc','Skull Candle 01',180425),
('Orc','Small Brazier 01',1967),
('Orc','Small Ritual Drum',202882),
('Orc','Small Ritual Drum 2',202883),
('Orc','SMALLBRAZIERNOOMNI 01',74138),
('Orc','Smoking Rack',18077),
('Orc','Smoldering Blaze',6289),
('Orc','Soran''s Leather and Steel Armory',173202),
('Orc','Spiritfury Reagents',173006),
('Orc','Tall Brazier',31575),
('Orc','Torp''s Farm',191698),
('Orc','Warmaul Ogre Banner',182353),
('Orc','Warsong Banner',187771),
('Orc','Warsong Granary',191697),
('Orc','Wyvern Roost',182255),
('Other peoples','Ancient Drakkari Tablets',190595),
('Other peoples','Beacon Torch',176093),
('Other peoples','Ogre Poo 2',175490),
('Other peoples','Razor Fen Leanto 03',3265),
('Other peoples','Seaworn Altar',2871),
('Other peoples','Sethekk Halls Moonstone',185590),
('Other peoples','Urok''s Tribute Pile',175621),
('Other peoples','Walk of Elders',182318),
('Outland','AK Alchemy Bottle 01',193135),
('Outland','AK Alchemy Bottle 03',193134),
('Outland','Alchemy & Herbalism',183890),
('Outland','Alchemy Lab',183848),
('Outland','Alchemy Table',187114),
('Outland','Ammen Vale Torch',184284),
('Outland','Ancient Brazier',185108),
('Outland','ANCIENT D BRAIZER BLUE LOWBATCH',186019),
('Outland','ANCIENT D BRAIZER BLUE SHORTSMOKE',185979),
('Outland','ANCIENT D STANDING LIGHT',185967),
('Outland','Ancient Dirt Mound',190550),
('Outland','AO Signpostpointer 01',183199),
('Outland','Apothecary Orb',190675),
('Outland','Arakkoa Summoning Dome',185171),
('Outland','Arcane Brazier',183098),
('Outland','Ashli''s Vase',186671),
('Outland','Auchindoun Bridge FX',183969),
('Outland','Auchindoun Bridge Spirits Flying',183968),
('Outland','Auction House',183855),
('Outland','Axxarien Crystal',185056),
('Outland','Battle Standard of the Mag''har',182259),
('Outland','BE Banner 01',181585),
('Outland','BE Banner 03',181587),
('Outland','BE BENCH 01',182608),
('Outland','BE Campfire 01',181319),
('Outland','BE CHAIR 01',184671),
('Outland','BE CHAIR 02',182598),
('Outland','BE CHAIR 03',182654),
('Outland','BE CHAIR 04',182762),
('Outland','BE cook Pot 01',181933),
('Outland','BE FORGE',183757),
('Outland','Beryl Shield Detonator',187850),
('Outland','Bladed Weapons',183869),
('Outland','Blades by Rahein',182751),
('Outland','Blood Elf Banner (Hanging scale x3.00)',187360),
('Outland','Blood Elf Table - Small',182093),
('Outland','Bloodmyst Crystal Aparatus 01',187371),
('Outland','Blunt Weapons',182750),
('Outland','Brightwing Bows',181900),
('Outland','Chulo the Mad''s Totem',193768),
('Outland','COLLECTORTUBES STRAIGHT STATES',188062),
('Outland','Consortium Transporter',183850),
('Outland','Crystal Ward',187078);
INSERT INTO zerocraft_catalog (category, name, entry) VALUES
('Outland','Crystallized Blight',190716),
('Outland','Crystallized Blight',190939),
('Outland','Crystallized Blight',190940),
('Outland','Danwe''s Devices',182744),
('Outland','Destroyed Doom Walker',183328),
('Outland','Diagnostic Frame',184590),
('Outland','Doomclaw''s Brazier',184613),
('Outland','DR Anvil 01',182055),
('Outland','DR BENCH 01',184038),
('Outland','DR Brazier 02',185543),
('Outland','DR Cookpot 01',181790),
('Outland','DR FORGE 01',184922),
('Outland','DR Signpost Sign ancient',182100),
('Outland','DR SIGNS BOOK',183875),
('Outland','DR SIGNS COOKING',183859),
('Outland','DR SIGNS ENGINEERING',183863),
('Outland','DR SIGNS HERBALISM',183873),
('Outland','DR SIGNS TAILOR',183864),
('Outland','DR SIGNS TAVERN',183861),
('Outland','Draenei Banner',181917),
('Outland','Draenei Banner',185107),
('Outland','Draenei HoloRunes',183318),
('Outland','Draenei HoloRunes',183319),
('Outland','Draenei HoloRunes',183320),
('Outland','Draenei Machine',183771),
('Outland','Draenei Spirit',183448),
('Outland','Draenei Wreckage Frame',184808),
('Outland','Drakkari Pedestal',190522),
('Outland','Duskwither Spire Power Source Satellite',182092),
('Outland','Elemental Rift',182120),
('Outland','Enchants Enhanced',182739),
('Outland','Ethereal Coffin Effect',184806),
('Outland','Ethereal Particles',184807),
('Outland','Ethereal Technology',183820),
('Outland','Ethereum Prison Base (Global)',184998),
('Outland','Fel Cannon Base',183158),
('Outland','Feledis'' Axes',182754),
('Outland','Gateway Murketh',183350),
('Outland','Grom''s Blood Elf Tribute',180212),
('Outland','Ground Rune',183036),
('Outland','Guild Master & Tabards',183865),
('Outland','Hall of the Mystics',183893),
('Outland','Heart of the Ancients',190596),
('Outland','HELLFIRE DW FLOORBRAIZER',184496),
('Outland','Hellfire fireparticle',183503),
('Outland','HELLFIRE FLOORBRAIZER',183831),
('Outland','hellfiresupplies 02',193160),
('Outland','hellfiresupplies 03',193161),
('Outland','hellfiresupplies 04',193162),
('Outland','hellfiresupplies 05',193163),
('Outland','hellfiresupplies 06',192929),
('Outland','Hippogryph Nest',186805),
('Outland','Hologram Floorpiece',184828),
('Outland','Holographic Emitter',182057),
('Outland','Hunters'' Sanctum',183866),
('Outland','Imprisoned Voidwalker',184452),
('Outland','Jade Statue (Cosmetic)',192948),
('Outland','Jewelcraft Grinder',188190),
('Outland','Keelen''s Trustworthy Tailoring',182752),
('Outland','Kil''sorrow Banner',182354),
('Outland','Kirin''Var Ward',183955),
('Outland','Legion Communicator',184072),
('Outland','Legion Ring Obelisk',185588),
('Outland','Light Crystal',184307),
('Outland','Magister Duskwither''s Journal',181012),
('Outland','Mana Cell',187058),
('Outland','Mana Cell 3x3',187057),
('Outland','Mana Loom',184803),
('Outland','Mining & Smithing',183862),
('Outland','Naaru Room Crystal',182036),
('Outland','Nerubian Crater',190555),
('Outland','Nexus-Prince Haramad''s Teleporter',184070),
('Outland','Night Elf Moon Crystal',181361),
('Outland','Offering Bowl',190507),
('Outland','Ogre Firepit',182573),
('Outland','Ogri''la Crystal Smoke Image',185901),
('Outland','Ogrila Crystal 01',185933),
('Outland','Ogrila Crystal 02',185934),
('Outland','OM Chair 01',183409),
('Outland','OM Forge 01',183408),
('Outland','outlanddeadcampfire',193559),
('Outland','Plate and Mail Protection',182746),
('Outland','Plate Armor & Shields',183868),
('Outland','Protectorate Tracer',184447),
('Outland','Ring of Arms',183867),
('Outland','Royal Exchange Bank',181909),
('Outland','Salaadin''s Cover',184464),
('Outland','School of Red Snapper',181616),
('Outland','Shadow Council Banner 01',185021),
('Outland','Shadow Council Magic Device 01',185016),
('Outland','Shadow Council Magic Device 02',185017),
('Outland','Shadow Council Tent 01',185001),
('Outland','Shadow Council Tent 02',185002),
('Outland','Shadow Council Torch',185003),
('Outland','Shadowmoon Rune 1',191707),
('Outland','Shattrath Battlemaster Pedestal',187702),
('Outland','Shattrath Soup Tent',183355),
('Outland','Shields of Silver',182749),
('Outland','Shrine of the Eagle',185552),
('Outland','Silvermoon Alchemy',182737),
('Outland','Silvermoon City Inn',182753),
('Outland','Silvermoon Flower 04',193220),
('Outland','silvermoonflower 01',193397),
('Outland','silvermoonflower 02',193399),
('Outland','Skar''this''s Prison',185292),
('Outland','Smoldering Scrap',192124),
('Outland','Steam Main',190367),
('Outland','Students of Shadow',182748),
('Outland','Sun Gate',182186),
('Outland','Suncrown Village',181934),
('Outland','Sunwell Plateau',187345),
('Outland','Surveying Marker',184378),
('Outland','terokkarweb 02',192162),
('Outland','terokkarweb 03',192161),
('Outland','The Ark of Ssslith',182082),
('Outland','The Book of the Raven',185581),
('Outland','The Exodar',181691),
('Outland','The Frozen Heart of Isuldof',187383),
('Outland','The Mark of Kael''Thas',185170),
('Outland','The Sunspire',181967),
('Outland','Torgos''s Bane',184842),
('Outland','Tu''u''gwar''s Bait',188386),
('Outland','Vindicators'' Sanctum',183891),
('Outland','Vision of the Future',181755),
('Outland','Ward Effect',183948),
('Outland','Warmaul Banner of Conquering',182366),
('Outland','Warmaul Skull',182183),
('Outland','Wayfarer''s Rest',182740),
('Outland','Wreckage C',188089),
('Outland','Zangar Signpostpointer 01',182283),
('Outland','Zort''s Volatile Concoction',188467),
('Outland','Zul''Aman - Eagle Throne',187118),
('PvP','Alliance Banner',192292),
('PvP','Alliance Flag',186862),
('PvP','Battlefield Banner Alliance Status Bar 2Min',193675),
('PvP','Battlefield Banner Neutral Post',191311),
('PvP','Buff 2 Billboard',179869),
('PvP','Challenge From the Horde',185222),
('PvP','Consuming Flames',178672),
('PvP','Dreadsteed Portal',179681),
('PvP','Flag of Ownership',190589),
('PvP','Ghost Gate',180322),
('PvP','Horde Banner',192336),
('PvP','Mana Loom Glow',185019),
('PvP','Netherstorm Flag',184493),
('PvP','PVP HOLIDAY ALLIANCE ARATHI',180398),
('PvP','Speed Buff Billboard',179868),
('PvP','Teleporter Pad',202733),
('PvP','Visual Banner2 (Horde)',184413),
('Tauren','Archery Target Dwarf 01',193157),
('Tauren','Archery Target Human 01',13952),
('Tauren','Bena''s Alchemy',50486),
('Tauren','Bloodhoof Village',2968),
('Tauren','Bridge to Elder Rise',177266),
('Tauren','Bridge to Hunter Rise',177268),
('Tauren','Bridge to Spirit Rise',177265),
('Tauren','Clay Oven',186143),
('Tauren','Cloudweaver''s Baskets',50484),
('Tauren','Dawnstrider Enchanters',50485),
('Tauren','Fruits and Vegetables',50490),
('Tauren','Gawanil''s Totem',193769),
('Tauren','Grom''s Tauren Tribute',180209),
('Tauren','Holistic Herbalism',50487),
('Tauren','Hospital Bed',178226),
('Tauren','Karn''s Smithy',50493),
('Tauren','Kibler''s Cage',175246),
('Tauren','Kibler''s Cage',175247),
('Tauren','Kibler''s Cage',175248),
('Tauren','Kibler''s Cage',175249),
('Tauren','largebasket 03',195196),
('Tauren','Mag''har Rug',182257),
('Tauren','Ogre Drum',185591),
('Tauren','Relic Bundle',177526),
('Tauren','Small Basket 01',195194),
('Tauren','Tauren Lamp Post',57708),
('Tauren','Tauren Rug',188346),
('Tauren','Tauren Rug',188347),
('Tauren','TAURENDRUMMED 01',152583),
('Tauren','TAURENLOGCHAIR 02',126050),
('Tauren','Thunder Bluff Armorers',50488),
('Tauren','Thunder Bluff Bank',50492),
('Tauren','Thunder Bluff Weapons',50503),
('Tauren','Thunderhorn''s Archery',50489),
('Tauren','Water Trough Small',179975),
('Undead','Bag Vendor',58624),
('Undead','Bat Handler',58597),
('Undead','Bow Merchant',58618),
('Undead','General Goods',58598),
('Undead','Krastinov''s Work Bench',176561),
('Undead','Light Armor',58600),
('Undead','lordaeron citybanner 01',193429),
('Undead','Meat Wagon',190731),
('Undead','Meat Wagon Body',193620),
('Undead','Meat Wagon Claw',193619),
('Undead','Meat Wagon Grill',193617),
('Undead','Meat Wagon Hauler',183163),
('Undead','Meat Wagon Roller',193618),
('Undead','Meat Wagon Wheel',193616),
('Undead','Meat Wagon Wrecked 01',183164),
('Undead','Staff Merchant',58629),
('Undead','UNDEADSIGN ALCHEMIST',58610),
('Undead','UNDEADSIGN BANK',58601),
('Undead','UNDEADSIGN BLACKSMITH',58617),
('Undead','UNDEADSIGN COOK',58606),
('Undead','UNDEADSIGN HERBALIST',58615),
('Undead','UNDEADSIGN MINER',58620),
('Undead','UNDEADSIGN POISON',58625),
('Undead','UNDEADSIGN TAILOR',58607),
('Undead','UNDEADSIGN WEAPONS',58596),
('Undead','UNDERCITYSIGNPOSTPOINTER',33998),
('Zones of Azeroth','Agmar''s Throne',188227),
('Zones of Azeroth','Ahn''Qiraj Gong',177223),
('Zones of Azeroth','Ahn''Qiraj Ossirian Crystal',210312),
('Zones of Azeroth','All Things Flora',59517),
('Zones of Azeroth','Altar of Aggonar',181449),
('Zones of Azeroth','Altar of Hyjal',211019),
('Zones of Azeroth','Alterac Shrub 03',184353),
('Zones of Azeroth','Amani Drum',186865),
('Zones of Azeroth','Amberseed (generic)',188668),
('Zones of Azeroth','Ancient Casket',184799),
('Zones of Azeroth','Angelista''s Boutique',175470),
('Zones of Azeroth','Anvil',1744),
('Zones of Azeroth','Apothecary  Bookcase',190693),
('Zones of Azeroth','Apothecary Blood Machine',190672),
('Zones of Azeroth','Apothecary Blood Vial',190673),
('Zones of Azeroth','Apothecary Bowl',190679),
('Zones of Azeroth','Apothecary Cage',190674),
('Zones of Azeroth','Apothecary Cage (Bottom)',188363),
('Zones of Azeroth','Apple Barrel',190559),
('Zones of Azeroth','Arakkoa Shrine',185863),
('Zones of Azeroth','Arathi Basin Pumpkin',180218),
('Zones of Azeroth','Arathi Basin Pumpkin Patch',180219),
('Zones of Azeroth','Archive Fire',176295),
('Zones of Azeroth','Archmage Vargoth''s Orb',183507),
('Zones of Azeroth','Ash Tree Smoke 01',164870),
('Zones of Azeroth','Azshara Debris Wall',190891),
('Zones of Azeroth','Ballista',190799),
('Zones of Azeroth','Ballista Ruined',190801),
('Zones of Azeroth','Banner of Provocation',181058),
('Zones of Azeroth','Banner of the Blackrock Clan',181505),
('Zones of Azeroth','Banner of the Dragonmaw Clan',181507),
('Zones of Azeroth','Barrens Lamp Post 01',6286),
('Zones of Azeroth','Battle Glade Sword Skull',192973),
('Zones of Azeroth','Battleground Shield',372),
('Zones of Azeroth','Big Barracks Flame',176746),
('Zones of Azeroth','Binder''s Brazier',186678),
('Zones of Azeroth','Black Knight''s Grave',195186),
('Zones of Azeroth','BLACKWINGLAIR THRONE',179118),
('Zones of Azeroth','Blasted Lands Bone Pile 02',180224),
('Zones of Azeroth','Blasted Lands Bone Pile 03',180225),
('Zones of Azeroth','Blasted Lands Skull 01',180223),
('Zones of Azeroth','Blasted Lands Spine 01',181193),
('Zones of Azeroth','Blood Device',190609),
('Zones of Azeroth','Blood Vat',190604),
('Zones of Azeroth','Body Shrouded',190647),
('Zones of Azeroth','Bogbean Plant',20939),
('Zones of Azeroth','Bone Spike 02',192993),
('Zones of Azeroth','bonespike 01',192997),
('Zones of Azeroth','Books On Fire',184510),
('Zones of Azeroth','Booty Bay Blacksmith',169967),
('Zones of Azeroth','Broken Cart',182403),
('Zones of Azeroth','Broken Cart',186807),
('Zones of Azeroth','Broken Raptor Egg',194129),
('Zones of Azeroth','Broken Tablet',186718),
('Zones of Azeroth','Casket Lid',184800),
('Zones of Azeroth','Catapult',180744),
('Zones of Azeroth','Charred Remains',184445),
('Zones of Azeroth','Concealing Bush',181824),
('Zones of Azeroth','Cranberry Masher',195195),
('Zones of Azeroth','Dark Brazier',185036),
('Zones of Azeroth','Dark Brazier',185047),
('Zones of Azeroth','Darkshore Anchor 01',177791),
('Zones of Azeroth','DNRDream Drooping Flower 02',185494),
('Zones of Azeroth','DNRDream Orange Flower 02',193392),
('Zones of Azeroth','DNRDream Purple Flower 01',193394),
('Zones of Azeroth','DNRDream Purple Flower 02',185492),
('Zones of Azeroth','DNRDream Spinning Flower 01',185495),
('Zones of Azeroth','dnrdreamdroopingflower 01',193389),
('Zones of Azeroth','dnrdreamorangeflower 01',193391),
('Zones of Azeroth','Doomweed 01',180226),
('Zones of Azeroth','Dragon Kin Nest 01',185929),
('Zones of Azeroth','Dragon Kin Nest 02',185930),
('Zones of Azeroth','Dragon Kin Nest 03',185931),
('Zones of Azeroth','Dragon Skeleton',184108),
('Zones of Azeroth','Drak''Mar Lily Pad',194239),
('Zones of Azeroth','Dream Catcher Glow',185518),
('Zones of Azeroth','Dry Haystack',192045),
('Zones of Azeroth','Dusk Wood Fallen Tree',190872),
('Zones of Azeroth','Duskwood Barn Closed',191176),
('Zones of Azeroth','Duskwood Hay Wagon',190893),
('Zones of Azeroth','Duskwood human farm closed',191165),
('Zones of Azeroth','Duskwood lumbermill',191190),
('Zones of Azeroth','Duskwood Stable',191177),
('Zones of Azeroth','Elwynn Campfire',1766),
('Zones of Azeroth','Elwynn Campfire blue',179147),
('Zones of Azeroth','Elwynn Fence',211062),
('Zones of Azeroth','Elwynn Fence',211063),
('Zones of Azeroth','Elwynn Flower 01',181103),
('Zones of Azeroth','Emerald Dream Fountain Tree 01',185491),
('Zones of Azeroth','Emerald Dream Fountain Tree 05',185496);
INSERT INTO zerocraft_catalog (category, name, entry) VALUES
('Zones of Azeroth','Enchanted Sea Kelp',2872),
('Zones of Azeroth','Ethereal Teleport Visual',183851),
('Zones of Azeroth','Eye of Asheron',211021),
('Zones of Azeroth','Farshire Grain',188112),
('Zones of Azeroth','Fel Stratholme Fire Smoke Embers',184294),
('Zones of Azeroth','Fire Plume Ridge Hot Spot',148503),
('Zones of Azeroth','Fishing Box',180403),
('Zones of Azeroth','Floating Purple Crystal 01',210348),
('Zones of Azeroth','FORGELAVAA',171717),
('Zones of Azeroth','FORGELAVAB',171716),
('Zones of Azeroth','Frost Rock, Large',188068),
('Zones of Azeroth','Generic Hoofprint',187272),
('Zones of Azeroth','Gloomweed 01',180227),
('Zones of Azeroth','Glyphed Crystal',210337),
('Zones of Azeroth','Goblin Smelting Pot',123207),
('Zones of Azeroth','Golem Arm',188186),
('Zones of Azeroth','Goodman''s General Store',175467),
('Zones of Azeroth','Gor''tesh''s Lopped Off Head',160839),
('Zones of Azeroth','Gorishi Silithid Crystal',174792),
('Zones of Azeroth','Grasp of C''Thun',180745),
('Zones of Azeroth','Grimbooze''s Still',190634),
('Zones of Azeroth','haystack 01',179968),
('Zones of Azeroth','Headhunter Skull',2371),
('Zones of Azeroth','Headless Horseman Pumpkin Table',186327),
('Zones of Azeroth','Heart of Fury',185125),
('Zones of Azeroth','Heart of Fury Pedestal',185146),
('Zones of Azeroth','Heart of Hakkar Object',180402),
('Zones of Azeroth','Holy Spring Well',19483),
('Zones of Azeroth','Horn of Margol the Rager',147136),
('Zones of Azeroth','Hot Coals',171552),
('Zones of Azeroth','Hyal Family Monument',186322),
('Zones of Azeroth','Icebellow Anvil',181234),
('Zones of Azeroth','Impact Site Crystal',181779),
('Zones of Azeroth','impalingstone corpse 01',192992),
('Zones of Azeroth','impalingstone corpse 02',192996),
('Zones of Azeroth','Iron Forge Steam Tank',180605),
('Zones of Azeroth','Ironforge Main Gate',32355),
('Zones of Azeroth','Ironridge Table',184657),
('Zones of Azeroth','Jar 01',180329),
('Zones of Azeroth','Jar 02',180330),
('Zones of Azeroth','Jar 03',180331),
('Zones of Azeroth','JD Red Crystal 1',164838),
('Zones of Azeroth','JD Yellow Crystal 1',164927),
('Zones of Azeroth','jug 01',180332),
('Zones of Azeroth','jug 02',180333),
('Zones of Azeroth','Karazahn Bon Fire 01',180434),
('Zones of Azeroth','Karazahn Table Small',189289),
('Zones of Azeroth','KARAZAHNBONFIRE 02',183128),
('Zones of Azeroth','KELTHUZAD THRONE',181640),
('Zones of Azeroth','Kirtonos Bros. Funeral Home',175466),
('Zones of Azeroth','Large Wisp',19540),
('Zones of Azeroth','Lighthouse Beam',180124),
('Zones of Azeroth','Magna Totem',187890),
('Zones of Azeroth','Makeshift Helipad',150086),
('Zones of Azeroth','Master Control Program',48516),
('Zones of Azeroth','Medium Wisp',19539),
('Zones of Azeroth','Metal Post',193007),
('Zones of Azeroth','Metzen''s Fencing',180742),
('Zones of Azeroth','Metzen''s Stable',180719),
('Zones of Azeroth','Miblon''s Door',164729),
('Zones of Azeroth','Moonglade Dream Catcher',185504),
('Zones of Azeroth','Naga Flag',181694),
('Zones of Azeroth','Nautical Needs',59518),
('Zones of Azeroth','Nazzivus Monument',182212),
('Zones of Azeroth','Northern Salmon',188504),
('Zones of Azeroth','Nox Portal Plaguewood',181476),
('Zones of Azeroth','Ogre Campfire 01',181311),
('Zones of Azeroth','Onslaught Table',190190),
('Zones of Azeroth','Onyxia''s Flame Breath',179561),
('Zones of Azeroth','Orc Bon Fire',1831),
('Zones of Azeroth','Orc Bon Fire Off',3308),
('Zones of Azeroth','Orc Small Foundry Pit',1685),
('Zones of Azeroth','Orc Spy Report',21128),
('Zones of Azeroth','Orc Tent',193219),
('Zones of Azeroth','ORCBONFIRE BLUE',40198),
('Zones of Azeroth','ORCSLEEPMAT 03',193684),
('Zones of Azeroth','ORGRIMMARBONFIRE 01',177002),
('Zones of Azeroth','Out House',180006),
('Zones of Azeroth','Outland Map',181310),
('Zones of Azeroth','Pamela''s Doll',176247),
('Zones of Azeroth','Plaguewood Smoke',177671),
('Zones of Azeroth','Plaugelands Cage 01',188678),
('Zones of Azeroth','PVP HOLIDAY HORDE ARATHI',180396),
('Zones of Azeroth','Quenching Barrel',201774),
('Zones of Azeroth','Razorthorn Dirt Mound',187073),
('Zones of Azeroth','Red Ridge Barn Closed',191172),
('Zones of Azeroth','Red Ridge Fallen Tree 01',190890),
('Zones of Azeroth','Red Ridge human farm closed',191166),
('Zones of Azeroth','Red Ridge lumbermill',191191),
('Zones of Azeroth','Red Ridge Stable',191178),
('Zones of Azeroth','Red Riding Hood Backdrop',183491),
('Zones of Azeroth','Red Riding Hood House',183493),
('Zones of Azeroth','Red Riding Hood Tree',183492),
('Zones of Azeroth','Rejek''s Sword',191125),
('Zones of Azeroth','Rock Rubble',190386),
('Zones of Azeroth','Rocket Delivery System',201906),
('Zones of Azeroth','Rockwall Fence',211064),
('Zones of Azeroth','Romeo and Juliet Backdrop',183443),
('Zones of Azeroth','Romeo and Juliet Balcony',183495),
('Zones of Azeroth','Romeo and Juliet Moon',183494),
('Zones of Azeroth','Row Boat 01',190226),
('Zones of Azeroth','Sack of Gold',180660),
('Zones of Azeroth','Sand Worm Rock Base',210343),
('Zones of Azeroth','Scholomance Brazier 01Green',185245),
('Zones of Azeroth','Scholomance Brazier 01Orange',185250),
('Zones of Azeroth','Scholomance Brazier 01Purple',185235),
('Zones of Azeroth','Scourge Banner',176087),
('Zones of Azeroth','Scourge Body Hanging 01',190923),
('Zones of Azeroth','Scourge Body Hanging 02',190924),
('Zones of Azeroth','Scourge Body Hanging 03',190925),
('Zones of Azeroth','Scourge Bonfire',188542),
('Zones of Azeroth','Serpent Offering',202931),
('Zones of Azeroth','Shark (Hanging)',195429),
('Zones of Azeroth','Short Wooden Seat',48403),
('Zones of Azeroth','Shovel',180651),
('Zones of Azeroth','Shrine of the Naga Priestess',187342),
('Zones of Azeroth','Signaling Gem',181447),
('Zones of Azeroth','silithus crystal formation 03',210344),
('Zones of Azeroth','Skull Key',105168),
('Zones of Azeroth','Slain Peasant',179695),
('Zones of Azeroth','Slain Peasant',179696),
('Zones of Azeroth','Slain Peasant',179698),
('Zones of Azeroth','Slain Peasant',179699),
('Zones of Azeroth','Small Dirt Mound',181104),
('Zones of Azeroth','Small Proto-Drake Egg',192538),
('Zones of Azeroth','Small Wisp',19538),
('Zones of Azeroth','SMALLPORTCULLIS',187718),
('Zones of Azeroth','Smelting Weapons',23304),
('Zones of Azeroth','Smokywood Pastures',178746),
('Zones of Azeroth','Soaked Fertile Dirt',191136),
('Zones of Azeroth','Statue Eye',187678),
('Zones of Azeroth','Stone Anvil',50830),
('Zones of Azeroth','Stranglethorn Trust Bank',56911),
('Zones of Azeroth','STRATHOLMEFLOATINGEMBERS',191862),
('Zones of Azeroth','Styleen''s Cart',176348),
('Zones of Azeroth','Sunken Boat',186770),
('Zones of Azeroth','Sweet Potato',195215),
('Zones of Azeroth','T''chali''s Grave',184742),
('Zones of Azeroth','T''chali''s Skull',184745),
('Zones of Azeroth','Talonshrike''s Egg',190284),
('Zones of Azeroth','Tan-Your-Hide Leatherworks',56901),
('Zones of Azeroth','Terokkar Forest',185062),
('Zones of Azeroth','The Black Anvil',172911),
('Zones of Azeroth','The Black Forge',174045),
('Zones of Azeroth','The Great Anvil',171715),
('Zones of Azeroth','The Happy Bobber',59852),
('Zones of Azeroth','The Salty Sailor Tavern',56910),
('Zones of Azeroth','The Sleeper''s Bed',185475),
('Zones of Azeroth','Tirion Fordring''s Grave',177239),
('Zones of Azeroth','Troll Bat Totem',190591),
('Zones of Azeroth','TROLLRUINSGONG 03',180386),
('Zones of Azeroth','Twilight Crystal Base',188048),
('Zones of Azeroth','Twilight Crystal Base',188050),
('Zones of Azeroth','Twilight Crystal Base',188156),
('Zones of Azeroth','Twilight Crystal Base',188157),
('Zones of Azeroth','Twilight Summoning Circle',187976),
('Zones of Azeroth','Twilight Summoning Circle',187977),
('Zones of Azeroth','Twilight Tablet',210336),
('Zones of Azeroth','Underworld Power Fragment',190736),
('Zones of Azeroth','Underworld Power Fragment',190737),
('Zones of Azeroth','Underworld Power Fragment',190738),
('Zones of Azeroth','Unforged Seal of Ascension',175321),
('Zones of Azeroth','Vylestem Vine',178908),
('Zones of Azeroth','Wall Light',190664),
('Zones of Azeroth','War Map',180852),
('Zones of Azeroth','Warlock Mount Ritual Circle',179668),
('Zones of Azeroth','Water Hut 01',186742),
('Zones of Azeroth','Water Hut 02',186743),
('Zones of Azeroth','Water Manifestation Effect',106528),
('Zones of Azeroth','West Fall Barrel 01',190878),
('Zones of Azeroth','West Fall Crate',190879),
('Zones of Azeroth','West Fall Grain Silo 01',190800),
('Zones of Azeroth','West Fall Scarecrow',190932),
('Zones of Azeroth','Westfall Fencepost',190871),
('Zones of Azeroth','Witherbark Totem Bundle',174764),
('Zones of Azeroth','Wizard of Oz Backdrop',183442),
('Zones of Azeroth','Wizard of Oz Hay',183496),
('Zones of Azeroth','WotLK Light Rock',191132),
('Zones of Azeroth','Zul''Aman - Dwarf Hammer',186623);
-- Builder's Catalog item (reuses a freed item ID that exists in the client), a book icon
DELETE FROM item_template WHERE entry = 23656;
DROP TEMPORARY TABLE IF EXISTS zc_c;
CREATE TEMPORARY TABLE zc_c SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_c SET entry = 23656, name = 'Builder''s Catalog', Quality = 4,
  displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 18401), displayid),
  description = 'Every object in the world, sorted by style. Click a spot, then browse.',
  ScriptName = 'item_zerocraft_catalog';
INSERT INTO item_template SELECT * FROM zc_c;
DROP TEMPORARY TABLE zc_c;
SELECT category, COUNT(*) AS objects FROM zerocraft_catalog GROUP BY category ORDER BY objects DESC;

-- ZeroCraft: the Builder's Kit and Catalog are split into themed Builder's Scrolls, one useful thing + ~24 decorations each.
-- Tiers: green (crafting station), rare (mailbox / musician / dancer), epic (summoning stone, spirit healer, stable master), legendary (portal).
CREATE TABLE IF NOT EXISTS zerocraft_bscroll (item_entry INT UNSIGNED NOT NULL PRIMARY KEY, quality TINYINT UNSIGNED NOT NULL, name VARCHAR(80) NOT NULL, description VARCHAR(255) NOT NULL) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS zerocraft_bscroll_items (item_entry INT UNSIGNED NOT NULL, idx INT UNSIGNED NOT NULL, kind TINYINT UNSIGNED NOT NULL, entry INT UNSIGNED NOT NULL, name VARCHAR(64) NOT NULL, useful TINYINT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (item_entry, idx)) ENGINE=InnoDB;
DELETE FROM zerocraft_bscroll; DELETE FROM zerocraft_bscroll_items;
INSERT INTO zerocraft_bscroll (item_entry, quality, name, description) VALUES
(4431,2,'Builder''s Scroll: Odds and Ends I','Builds Bubbling Cauldron and 26 decorations. Click a spot on the ground.'),
(4451,3,'Builder''s Scroll: Odds and Ends II','Builds Dancer and 26 decorations. Click a spot on the ground.'),
(4452,2,'Builder''s Scroll: Odds and Ends III','Builds The Black Anvil and 26 decorations. Click a spot on the ground.'),
(4523,2,'Builder''s Scroll: Odds and Ends IV','Builds Cooking Fire and 26 decorations. Click a spot on the ground.'),
(4573,3,'Builder''s Scroll: Odds and Ends V','Builds Mailbox: Goblin (Gadgetzan) and 26 decorations. Click a spot on the ground.'),
(4578,2,'Builder''s Scroll: Odds and Ends VI','Builds Grill and 26 decorations. Click a spot on the ground.'),
(4579,2,'Builder''s Scroll: Odds and Ends VII','Builds Anvil and 26 decorations. Click a spot on the ground.'),
(4754,3,'Builder''s Scroll: Odds and Ends VIII','Builds Mailbox: Wildhammer (Aerie Peak) and 19 decorations. Click a spot on the ground.'),
(4839,2,'Builder''s Scroll: Walls and War I','Builds Forge and 25 decorations. Click a spot on the ground.'),
(4842,2,'Builder''s Scroll: Walls and War II','Builds Cooking Table and 25 decorations. Click a spot on the ground.'),
(4868,2,'Builder''s Scroll: Walls and War III','Builds Cooking Fire and 25 decorations. Click a spot on the ground.'),
(4884,2,'Builder''s Scroll: Walls and War IV','Builds Clay Oven and 25 decorations. Click a spot on the ground.'),
(4885,4,'Builder''s Scroll: Walls and War V','Builds Meeting Stone (Ashenvale) and 25 decorations. Click a spot on the ground.'),
(4889,4,'Builder''s Scroll: Walls and War VI','Builds Meeting Stone (Barrens) and 25 decorations. Click a spot on the ground.'),
(4927,3,'Builder''s Scroll: Walls and War VII','Builds Musician and 25 decorations. Click a spot on the ground.'),
(5171,2,'Builder''s Scroll: Walls and War VIII','Builds Anvil and 18 decorations. Click a spot on the ground.'),
(5228,4,'Builder''s Scroll: Fire and Light I','Builds Stable Master and 24 decorations. Click a spot on the ground.'),
(5331,3,'Builder''s Scroll: Fire and Light II','Builds Mailbox: Northrend (Grizzly Hills) and 24 decorations. Click a spot on the ground.'),
(5365,3,'Builder''s Scroll: Fire and Light III','Builds Mailbox: Ebon Hold (Death Knight) and 24 decorations. Click a spot on the ground.'),
(5372,2,'Builder''s Scroll: Fire and Light IV','Builds The Black Anvil and 24 decorations. Click a spot on the ground.'),
(5384,3,'Builder''s Scroll: Fire and Light V','Builds Mailbox: Dwarf (Ironforge) and 24 decorations. Click a spot on the ground.'),
(5407,5,'Builder''s Scroll: Fire and Light VI','Builds Portal to Theramore and 21 decorations. Click a spot on the ground.'),
(5434,3,'Builder''s Scroll: Arcane and Magic I','Builds Mailbox: Blood Elf (Silvermoon) and 26 decorations. Click a spot on the ground.'),
(5436,2,'Builder''s Scroll: Arcane and Magic II','Builds Potbelly Stove and 26 decorations. Click a spot on the ground.'),
(5438,2,'Builder''s Scroll: Arcane and Magic III','Builds Forge and 26 decorations. Click a spot on the ground.'),
(5449,3,'Builder''s Scroll: Arcane and Magic IV','Builds Mailbox: Draenei (Exodar) and 26 decorations. Click a spot on the ground.'),
(5450,2,'Builder''s Scroll: Arcane and Magic V','Builds Grill and 22 decorations. Click a spot on the ground.'),
(5453,5,'Builder''s Scroll: Crates and Cargo I','Builds Portal to Karazhan and 24 decorations. Click a spot on the ground.'),
(5454,5,'Builder''s Scroll: Crates and Cargo II','Builds Portal to Darnassus and 24 decorations. Click a spot on the ground.'),
(5515,2,'Builder''s Scroll: Crates and Cargo III','Builds Moonwell and 24 decorations. Click a spot on the ground.'),
(5531,5,'Builder''s Scroll: Crates and Cargo IV','Builds Portal to Exodar and 24 decorations. Click a spot on the ground.'),
(5651,5,'Builder''s Scroll: Crates and Cargo V','Builds Portal to Thunder Bluff and 23 decorations. Click a spot on the ground.'),
(5652,2,'Builder''s Scroll: Graveyard and Crypt I','Builds Bubbling Cauldron and 27 decorations. Click a spot on the ground.'),
(5653,2,'Builder''s Scroll: Graveyard and Crypt II','Builds Anvil and 27 decorations. Click a spot on the ground.'),
(6090,5,'Builder''s Scroll: Graveyard and Crypt III','Builds Portal to Blasted Lands and 27 decorations. Click a spot on the ground.'),
(6297,2,'Builder''s Scroll: Graveyard and Crypt IV','Builds Clay Oven and 27 decorations. Click a spot on the ground.'),
(6301,2,'Builder''s Scroll: Furniture I','Builds Forge and 25 decorations. Click a spot on the ground.'),
(6455,2,'Builder''s Scroll: Furniture II','Builds Potbelly Stove and 25 decorations. Click a spot on the ground.'),
(6639,2,'Builder''s Scroll: Furniture III','Builds Grill and 25 decorations. Click a spot on the ground.'),
(8589,2,'Builder''s Scroll: Furniture IV','Builds Cooking Fire and 24 decorations. Click a spot on the ground.'),
(8590,2,'Builder''s Scroll: Nature and Farm I','Builds Moonwell and 23 decorations. Click a spot on the ground.'),
(9464,3,'Builder''s Scroll: Nature and Farm II','Builds Mailbox: Human (Stormwind) and 23 decorations. Click a spot on the ground.'),
(10594,2,'Builder''s Scroll: Nature and Farm III','Builds Bubbling Cauldron and 23 decorations. Click a spot on the ground.'),
(11132,2,'Builder''s Scroll: Nature and Farm IV','Builds Training Dummy and 20 decorations. Click a spot on the ground.'),
(11443,2,'Builder''s Scroll: Northrend Frontier I','Builds Forge and 22 decorations. Click a spot on the ground.'),
(11663,4,'Builder''s Scroll: Northrend Frontier II','Builds Meeting Stone (Silverpine) and 22 decorations. Click a spot on the ground.'),
(11664,2,'Builder''s Scroll: Northrend Frontier III','Builds Potbelly Stove and 22 decorations. Click a spot on the ground.'),
(11666,4,'Builder''s Scroll: Northrend Frontier IV','Builds Meeting Stone (Feralas) and 22 decorations. Click a spot on the ground.'),
(11667,3,'Builder''s Scroll: Workshop and Mine I','Builds Mailbox: Tauren (Thunder Bluff) and 22 decorations. Click a spot on the ground.'),
(11670,5,'Builder''s Scroll: Workshop and Mine II','Builds Portal to Silvermoon and 22 decorations. Click a spot on the ground.'),
(11671,2,'Builder''s Scroll: Workshop and Mine III','Builds Training Dummy and 22 decorations. Click a spot on the ground.'),
(11672,3,'Builder''s Scroll: Workshop and Mine IV','Builds Mailbox: Forsaken (Undercity) and 19 decorations. Click a spot on the ground.'),
(11673,4,'Builder''s Scroll: Kitchen and Tavern I','Builds Summoning Portal (Northrend) and 27 decorations. Click a spot on the ground.'),
(11676,2,'Builder''s Scroll: Kitchen and Tavern II','Builds Training Dummy and 27 decorations. Click a spot on the ground.'),
(11683,2,'Builder''s Scroll: Kitchen and Tavern III','Builds Moonwell and 26 decorations. Click a spot on the ground.'),
(12385,4,'Builder''s Scroll: Holiday Festival I','Builds Spirit Healer and 21 decorations. Click a spot on the ground.'),
(12526,5,'Builder''s Scroll: Holiday Festival II','Builds Portal to Stonard and 21 decorations. Click a spot on the ground.'),
(16068,2,'Builder''s Scroll: Holiday Festival III','Builds Cooking Table and 19 decorations. Click a spot on the ground.'),
(16069,2,'Builder''s Scroll: Outland Frontier I','Builds Clay Oven and 26 decorations. Click a spot on the ground.'),
(16070,2,'Builder''s Scroll: Outland Frontier II','Builds Cooking Table and 26 decorations. Click a spot on the ground.'),
(16071,3,'Builder''s Scroll: Human Township I','Builds Mailbox: Northrend (Dragonblight) and 25 decorations. Click a spot on the ground.'),
(16074,2,'Builder''s Scroll: Human Township II','Builds Training Dummy and 24 decorations. Click a spot on the ground.'),
(16075,5,'Builder''s Scroll: Camp and Tents I','Builds Portal to Stormwind and 24 decorations. Click a spot on the ground.'),
(16076,2,'Builder''s Scroll: Camp and Tents II','Builds The Black Anvil and 23 decorations. Click a spot on the ground.'),
(16077,3,'Builder''s Scroll: Books and Signs I','Builds Mailbox: Orc (Orgrimmar) and 20 decorations. Click a spot on the ground.'),
(16078,4,'Builder''s Scroll: Books and Signs II','Builds Meeting Stone (Plaguelands) and 19 decorations. Click a spot on the ground.'),
(16079,5,'Builder''s Scroll: Statues and Ruins I','Builds Portal to Ironforge and 17 decorations. Click a spot on the ground.'),
(16080,5,'Builder''s Scroll: Docks and Water','Builds Portal to Undercity and 22 decorations. Click a spot on the ground.'),
(16081,2,'Builder''s Scroll: Orcish Warcamp','Builds Moonwell and 20 decorations. Click a spot on the ground.'),
(16086,3,'Builder''s Scroll: Animals','Builds Mailbox: Northrend (Borean Tundra) and 15 decorations. Click a spot on the ground.'),
(16102,5,'Builder''s Scroll: Grand Structures','Builds Portal to Orgrimmar and 14 decorations. Click a spot on the ground.'),
(16103,3,'Builder''s Scroll: Dwarven Hold','Builds Mailbox: Night Elf (Darnassus) and 14 decorations. Click a spot on the ground.'),
(16105,2,'Builder''s Scroll: Tauren Village','Builds Cooking Fire and 11 decorations. Click a spot on the ground.'),
(16106,2,'Builder''s Scroll: Racial Relics','Builds The Black Anvil and 23 decorations. Click a spot on the ground.'),
(16107,2,'Builder''s Scroll: Statues and Ruins II','Builds Anvil and 16 decorations. Click a spot on the ground.');
INSERT INTO zerocraft_bscroll_items (item_entry, idx, kind, entry, name, useful) VALUES
(4431,0,0,2719,'Bubbling Cauldron',1),
(4431,1,0,177223,'Ahn''Qiraj Gong',0),
(4431,2,0,179667,'Air Elemental Rift',0),
(4431,3,0,177387,'Alchemy Lab',0),
(4431,4,0,180631,'Alchemy Lab',0),
(4431,5,0,187115,'Alchemy Lab',0),
(4431,6,0,59517,'All Things Flora',0),
(4431,7,0,187692,'Alliance Marker',0),
(4431,8,0,186865,'Amani Drum',0),
(4431,9,0,175470,'Angelista''s Boutique',0),
(4431,10,0,184831,'Aura Blue Short',0),
(4431,11,0,185505,'Baby Dw',0),
(4431,12,0,185506,'Baby Gn',0),
(4431,13,0,185507,'Baby Hu',0),
(4431,14,0,185508,'Baby Ne',0),
(4431,15,0,185509,'Baby Or',0),
(4431,16,0,185510,'Baby Ta',0),
(4431,17,0,185511,'Baby Tr',0),
(4431,18,0,190645,'Bananas (Display)',0),
(4431,19,0,180426,'Bat 01',0),
(4431,20,0,180427,'Bat 02',0),
(4431,21,0,275,'Bellowfiz Bubbles',0),
(4431,22,0,1604,'Black Smoke Emitter',0),
(4431,23,0,181193,'Blasted Lands Spine 01',0),
(4431,24,0,190647,'Body Shrouded',0),
(4431,25,0,169967,'Booty Bay Blacksmith',0),
(4431,26,0,19403,'Bridge 4',0),
(4451,0,2,6213,'Dancer',1),
(4451,1,0,194129,'Broken Raptor Egg',0),
(4451,2,0,177524,'Bubbly Fissure',0),
(4451,3,0,180035,'Carnival Railing',0),
(4451,4,0,184445,'Charred Remains',0),
(4451,5,0,184730,'Clefthoof Carrion Flies',0),
(4451,6,0,180772,'Cluster Launcher',0),
(4451,7,0,190686,'COT Hour Glass redo',0),
(4451,8,0,195195,'Cranberry Masher',0),
(4451,9,0,179708,'Divination Scryer',0),
(4451,10,0,180226,'Doomweed 01',0),
(4451,11,0,185929,'Dragon Kin Nest 01',0),
(4451,12,0,185930,'Dragon Kin Nest 02',0),
(4451,13,0,185931,'Dragon Kin Nest 03',0),
(4451,14,0,194239,'Drak''Mar Lily Pad',0),
(4451,15,0,185518,'Dream Catcher Glow',0),
(4451,16,0,191176,'Duskwood Barn Closed',0),
(4451,17,0,177272,'Easter Egg 01',0),
(4451,18,0,181057,'Ectoplasmic Distiller',0),
(4451,19,0,2872,'Enchanted Sea Kelp',0),
(4451,20,0,183851,'Ethereal Teleport Visual',0),
(4451,21,0,211021,'Eye of Asheron',0),
(4451,22,0,187680,'Farseer Grimwalker''s Remains',0),
(4451,23,0,188112,'Farshire Grain',0),
(4451,24,0,185856,'Fetish of Sar''this',0),
(4451,25,0,2722,'Floating Sparkles',0),
(4451,26,0,181354,'Floating, Medium - MFF',0),
(4452,0,0,172911,'The Black Anvil',1),
(4452,1,0,181027,'Floating, Medium - Val',0),
(4452,2,0,180760,'Forsaken Hero Portrait',0),
(4452,3,0,188091,'Fused Wiring',0),
(4452,4,0,180411,'G Ghost 01',0),
(4452,5,0,180787,'G Jewel Black',0),
(4452,6,0,190229,'G Mortar',0),
(4452,7,0,180409,'G Witch Broom 01',0),
(4452,8,0,180408,'G Witch Hat 01',0),
(4452,9,0,187272,'Generic Hoofprint',0),
(4452,10,0,180227,'Gloomweed 01',0),
(4452,11,0,19862,'Glowing Soulgem',0),
(4452,12,0,188186,'Golem Arm',0),
(4452,13,0,180745,'Grasp of C''Thun',0),
(4452,14,0,190634,'Grimbooze''s Still',0),
(4452,15,0,144069,'Grimshade''s Vision',0),
(4452,16,0,180208,'Grom''s Forsaken Tribute',0),
(4452,17,0,19415,'Hanging Body 2',0),
(4452,18,0,181021,'Hanging, Door - Val',0),
(4452,19,0,181024,'Hanging, Short/Squat, Large',0),
(4452,20,0,181358,'Hanging, Square, Large - MFF',0),
(4452,21,0,181014,'Hanging, Square, Large - Val',0),
(4452,22,0,181390,'Hanging, Square, Medium - MFF',0),
(4452,23,0,181020,'Hanging, Square, Medium - Val',0),
(4452,24,0,181392,'Hanging, Streamer - MFF',0),
(4452,25,0,181017,'Hanging, Streamer - Val',0),
(4452,26,0,181401,'Hanging, Streamer x3 - MFF',0),
(4523,0,0,1915,'Cooking Fire',1),
(4523,1,0,181389,'Hanging, Tall/Thin, Large - MFF',0),
(4523,2,0,181025,'Hanging, Tall/Thin, Large - Val',0),
(4523,3,0,181018,'Hanging, Tall/Thin, Medium - Val',0),
(4523,4,0,188494,'Harpy Tail Feather',0),
(4523,5,0,185125,'Heart of Fury',0),
(4523,6,0,180402,'Heart of Hakkar Object',0),
(4523,7,0,175885,'Horde Bell',0),
(4523,8,0,187691,'Horde Marker',0),
(4523,9,0,147136,'Horn of Margol the Rager',0),
(4523,10,0,171552,'Hot Coals',0),
(4523,11,0,180757,'Human Hero Portrait',0),
(4523,12,0,188595,'Imbued Drakkari Offering',0),
(4523,13,0,185898,'Imp in a Ball',0),
(4523,14,0,179480,'In Case of Emergency, Push Button',0),
(4523,15,0,174683,'J.D.''s Manual',0),
(4523,16,0,175466,'Kirtonos Bros. Funeral Home',0),
(4523,17,0,64855,'Kodo Fossil',0),
(4523,18,0,186393,'L70ETC Bleachers',0),
(4523,19,0,186300,'L70ETC Stage',0),
(4523,20,0,211035,'Lair Exit',0),
(4523,21,0,19540,'Large Wisp',0),
(4523,22,0,185593,'Legion Ring Fog',0),
(4523,23,0,1603,'Little Flame Emitter',0),
(4523,24,0,180909,'Lucky Red Envelope',0),
(4523,25,0,192492,'mace 1h ulduarraidnotskinable d 01',0),
(4523,26,0,150086,'Makeshift Helipad',0),
(4573,0,0,144112,'Mailbox: Goblin (Gadgetzan)',1),
(4573,1,0,177668,'Mark of Detonation',0),
(4573,2,0,48516,'Master Control Program',0),
(4573,3,0,19539,'Medium Wisp',0),
(4573,4,0,180604,'Merithra''s Wake',0),
(4573,5,0,179911,'Message to the Wildhammer',0),
(4573,6,0,180590,'Metal Bar Stack 01Copper',0),
(4573,7,0,180591,'Metal Bar Stack 01Iron',0),
(4573,8,0,180595,'Metal Bar Stack 01Mithril',0),
(4573,9,0,180592,'Metal Bar Stack 01Truesilver',0),
(4573,10,0,180593,'Metal Bar Stack 02Copper',0),
(4573,11,0,180596,'Metal Bar Stack 02Iron',0),
(4573,12,0,180586,'Metal Bar Stack 02Mithril',0),
(4573,13,0,180597,'Metal Bar Stack 02Truesilver',0),
(4573,14,0,180594,'Metal Bars 01Copper',0),
(4573,15,0,180587,'Metal Bars 01Iron',0),
(4573,16,0,180588,'Metal Bars 01Mithril',0),
(4573,17,0,180589,'Metal Bars 01Truesilver',0),
(4573,18,0,193007,'Metal Post',0),
(4573,19,0,180742,'Metzen''s Fencing',0),
(4573,20,0,164729,'Miblon''s Door',0),
(4573,21,0,178554,'mistletoe',0),
(4573,22,0,180844,'mistletoe 02',0),
(4573,23,0,19587,'Monestary Hall Door',0),
(4573,24,0,185504,'Moonglade Dream Catcher',0),
(4573,25,0,165559,'Muigin''s Sprout',0),
(4573,26,0,59518,'Nautical Needs',0),
(4578,0,0,194490,'Grill',1),
(4578,1,0,180758,'Night Elf Hero Portrait',0),
(4578,2,0,188504,'Northern Salmon',0),
(4578,3,0,175490,'Ogre Poo 2',0),
(4578,4,0,179561,'Onyxia''s Flame Breath',0),
(4578,5,0,195063,'Orange Marigolds',0),
(4578,6,0,195307,'Orange Marigolds',0),
(4578,7,0,180759,'Orc Hero Portrait',0),
(4578,8,0,1685,'Orc Small Foundry Pit',0),
(4578,9,0,21128,'Orc Spy Report',0),
(4578,10,0,193684,'ORCSLEEPMAT 03',0),
(4578,11,0,180006,'Out House',0),
(4578,12,0,176247,'Pamela''s Doll',0),
(4578,13,0,3265,'Razor Fen Leanto 03',0),
(4578,14,0,187073,'Razorthorn Dirt Mound',0),
(4578,15,0,182404,'Red Feather',0),
(4578,16,0,191172,'Red Ridge Barn Closed',0),
(4578,17,0,183491,'Red Riding Hood Backdrop',0),
(4578,18,0,183493,'Red Riding Hood House',0),
(4578,19,0,187265,'Romantic Umbrella',0),
(4578,20,0,183443,'Romeo and Juliet Backdrop',0),
(4578,21,0,183495,'Romeo and Juliet Balcony',0),
(4578,22,0,183494,'Romeo and Juliet Moon',0),
(4578,23,0,202931,'Serpent Offering',0),
(4578,24,0,186246,'Shady Rest Glow',0),
(4578,25,0,2705,'Shards of Myzrael',0),
(4578,26,0,195429,'Shark (Hanging)',0),
(4579,0,0,1744,'Anvil',1),
(4579,1,0,48403,'Short Wooden Seat',0),
(4579,2,0,179695,'Slain Peasant',0),
(4579,3,0,179696,'Slain Peasant',0),
(4579,4,0,179698,'Slain Peasant',0),
(4579,5,0,179699,'Slain Peasant',0),
(4579,6,0,181104,'Small Dirt Mound',0),
(4579,7,0,192538,'Small Proto-Drake Egg',0),
(4579,8,0,19538,'Small Wisp',0),
(4579,9,0,187718,'SMALLPORTCULLIS',0),
(4579,10,0,178746,'Smokywood Pastures',0),
(4579,11,0,191136,'Soaked Fertile Dirt',0),
(4579,12,0,193153,'spring 02',0),
(4579,13,0,181355,'Standing, Exterior, Medium - MFF',0),
(4579,14,0,181016,'Standing, Exterior, Medium - Val',0),
(4579,15,0,181022,'Standing, Giant - Val',0),
(4579,16,0,181388,'Standing, Interior, Medium - MFF',0),
(4579,17,0,181019,'Standing, Interior, Medium - Val',0),
(4579,18,0,181391,'Standing, Interior, Small - MFF',0),
(4579,19,0,181060,'Standing, Interior, Small - Val',0),
(4579,20,0,181300,'Standing, Large - MFF',0),
(4579,21,0,181015,'Standing, Large - Val',0),
(4579,22,0,56911,'Stranglethorn Trust Bank',0),
(4579,23,0,191862,'STRATHOLMEFLOATINGEMBERS',0),
(4579,24,0,195215,'Sweet Potato',0),
(4579,25,0,180669,'Swirling Maelstrom',0),
(4579,26,0,152093,'Talon Den',0),
(4754,0,0,179895,'Mailbox: Wildhammer (Aerie Peak)',1),
(4754,1,0,190284,'Talonshrike''s Egg',0),
(4754,2,0,56901,'Tan-Your-Hide Leatherworks',0),
(4754,3,0,180761,'Tauren Hero Portrait',0),
(4754,4,0,185062,'Terokkar Forest',0),
(4754,5,0,59852,'The Happy Bobber',0),
(4754,6,0,56910,'The Salty Sailor Tavern',0),
(4754,7,0,19586,'The Toxic Fogger',0),
(4754,8,0,181807,'Tif Shl 01',0),
(4754,9,0,181808,'Tif Shl 02',0),
(4754,10,0,181809,'Tif Shl 03',0),
(4754,11,0,180762,'Troll Hero Portrait',0),
(4754,12,0,188366,'Troll Mummy',0),
(4754,13,0,190736,'Underworld Power Fragment',0),
(4754,14,0,190737,'Underworld Power Fragment',0),
(4754,15,0,190738,'Underworld Power Fragment',0),
(4754,16,0,182318,'Walk of Elders',0),
(4754,17,0,200296,'Washing Tub',0),
(4754,18,0,190800,'West Fall Grain Silo 01',0),
(4754,19,0,183442,'Wizard of Oz Backdrop',0),
(4839,0,0,1685,'Forge',1),
(4839,1,0,183440,'Aldor Target',0),
(4839,2,0,178365,'Alliance Banner',0),
(4839,3,0,192292,'Alliance Banner',0),
(4839,4,0,201869,'Alliance Banner',0),
(4839,5,0,183122,'Alliance Cannon',0),
(4839,6,0,186862,'Alliance Flag',0),
(4839,7,0,186861,'Alliance Flagpole',0),
(4839,8,0,190670,'Apothecary Banner',0),
(4839,9,0,180598,'AQWar - Resource, Bandages, Alliance, Initial',0),
(4839,10,0,180674,'AQWar - Resource, Bandages, Alliance, Tier 1',0),
(4839,11,0,180675,'AQWar - Resource, Bandages, Alliance, Tier 2',0),
(4839,12,0,180676,'AQWar - Resource, Bandages, Alliance, Tier 3',0),
(4839,13,0,180677,'AQWar - Resource, Bandages, Alliance, Tier 4',0),
(4839,14,0,180678,'AQWar - Resource, Bandages, Alliance, Tier 5',0),
(4839,15,0,180826,'AQWar - Resource, Bandages, Horde, Initial',0),
(4839,16,0,180827,'AQWar - Resource, Bandages, Horde, Tier 1',0),
(4839,17,0,180828,'AQWar - Resource, Bandages, Horde, Tier 2',0),
(4839,18,0,180829,'AQWar - Resource, Bandages, Horde, Tier 3',0),
(4839,19,0,180830,'AQWar - Resource, Bandages, Horde, Tier 4',0),
(4839,20,0,180831,'AQWar - Resource, Bandages, Horde, Tier 5',0),
(4839,21,0,180680,'AQWar - Resource, Bars, Alliance, Initial',0),
(4839,22,0,180780,'AQWar - Resource, Bars, Alliance, Tier 1',0),
(4839,23,0,180781,'AQWar - Resource, Bars, Alliance, Tier 2',0),
(4839,24,0,180782,'AQWar - Resource, Bars, Alliance, Tier 3',0),
(4839,25,0,180783,'AQWar - Resource, Bars, Alliance, Tier 4',0),
(4842,0,0,12665,'Cooking Table',1),
(4842,1,0,180784,'AQWar - Resource, Bars, Alliance, Tier 5',0),
(4842,2,0,180838,'AQWar - Resource, Bars, Horde, Initial',0),
(4842,3,0,180839,'AQWar - Resource, Bars, Horde, Tier 1',0),
(4842,4,0,180840,'AQWar - Resource, Bars, Horde, Tier 2',0),
(4842,5,0,180841,'AQWar - Resource, Bars, Horde, Tier 3',0),
(4842,6,0,180842,'AQWar - Resource, Bars, Horde, Tier 4',0),
(4842,7,0,180843,'AQWar - Resource, Bars, Horde, Tier 5',0),
(4842,8,0,180801,'AQWar - Resource, Herbs, Alliance, Tier 1',0),
(4842,9,0,180802,'AQWar - Resource, Herbs, Alliance, Tier 2',0),
(4842,10,0,180803,'AQWar - Resource, Herbs, Alliance, Tier 3',0),
(4842,11,0,180804,'AQWar - Resource, Herbs, Alliance, Tier 4',0),
(4842,12,0,180805,'AQWar - Resource, Herbs, Alliance, Tier 5',0),
(4842,13,0,180818,'AQWar - Resource, Herbs, Horde, Initial',0),
(4842,14,0,180819,'AQWar - Resource, Herbs, Horde, Tier 1',0),
(4842,15,0,180820,'AQWar - Resource, Herbs, Horde, Tier 2',0),
(4842,16,0,180821,'AQWar - Resource, Herbs, Horde, Tier 3',0),
(4842,17,0,180822,'AQWar - Resource, Herbs, Horde, Tier 4',0),
(4842,18,0,180823,'AQWar - Resource, Herbs, Horde, Tier 5',0),
(4842,19,0,180681,'AQWar - Resource, Skins, Alliance, Initial',0),
(4842,20,0,180692,'AQWar - Resource, Skins, Alliance, Tier 1',0),
(4842,21,0,180693,'AQWar - Resource, Skins, Alliance, Tier 2',0),
(4842,22,0,180694,'AQWar - Resource, Skins, Alliance, Tier 3',0),
(4842,23,0,180695,'AQWar - Resource, Skins, Alliance, Tier 4',0),
(4842,24,0,180696,'AQWar - Resource, Skins, Alliance, Tier 5',0),
(4842,25,0,180812,'AQWar - Resource, Skins, Horde, Initial',0),
(4868,0,0,1915,'Cooking Fire',1),
(4868,1,0,180813,'AQWar - Resource, Skins, Horde, Tier 1',0),
(4868,2,0,180814,'AQWar - Resource, Skins, Horde, Tier 2',0),
(4868,3,0,180815,'AQWar - Resource, Skins, Horde, Tier 3',0),
(4868,4,0,180816,'AQWar - Resource, Skins, Horde, Tier 4',0),
(4868,5,0,180817,'AQWar - Resource, Skins, Horde, Tier 5',0),
(4868,6,0,193157,'Archery Target Dwarf 01',0),
(4868,7,0,13952,'Archery Target Human 01',0),
(4868,8,0,190523,'Argent Crusade Banner',0),
(4868,9,0,195302,'Argent Crusader''s Banner',0),
(4868,10,0,181256,'Argent Dawn Banner',0),
(4868,11,0,192930,'argentcrusade banner 02',0),
(4868,12,0,188220,'Armor Helm Trim',0),
(4868,13,0,188222,'Armor Leather Helm Brown',0),
(4868,14,0,188221,'Armor Leather Shirt Brown',0),
(4868,15,0,188217,'Armor Mail Hanging Blue Long',0),
(4868,16,0,188216,'Armor Stand',0),
(4868,17,0,188218,'Armor Stand Mail Coif Blue',0),
(4868,18,0,190891,'Azshara Debris Wall',0),
(4868,19,0,190799,'Ballista',0),
(4868,20,0,190801,'Ballista Ruined',0),
(4868,21,0,193487,'ballistabow 01',0),
(4868,22,0,193488,'ballistamissle 01',0),
(4868,23,0,181058,'Banner of Provocation',0),
(4868,24,0,181505,'Banner of the Blackrock Clan',0),
(4868,25,0,181504,'Banner of the Bleeding Hollow Clan',0),
(4884,0,0,186143,'Clay Oven',1),
(4884,1,0,181507,'Banner of the Dragonmaw Clan',0),
(4884,2,0,191741,'BARBERSHOP POLEWALL',0),
(4884,3,0,182259,'Battle Standard of the Mag''har',0),
(4884,4,0,193675,'Battlefield Banner Alliance Status Bar 2Min',0),
(4884,5,0,191311,'Battlefield Banner Neutral Post',0),
(4884,6,0,372,'Battleground Shield',0),
(4884,7,0,181585,'BE Banner 01',0),
(4884,8,0,181587,'BE Banner 03',0),
(4884,9,0,187773,'Beryl Shield',0),
(4884,10,0,187850,'Beryl Shield Detonator',0),
(4884,11,0,192558,'Bethod''s Sword',0),
(4884,12,0,176746,'Big Barracks Flame',0),
(4884,13,0,183869,'Bladed Weapons',0),
(4884,14,0,184713,'Bladespire Clan Banner',0),
(4884,15,0,182750,'Blunt Weapons',0),
(4884,16,0,193765,'BOW CROSSBOW PVPALLIANCE A 01',0),
(4884,17,0,192650,'Bridenbrad''s Sword',0),
(4884,18,0,180573,'Cannon Target',0),
(4884,19,0,180744,'Catapult',0),
(4884,20,0,190860,'Crimson Wall Shield 01',0),
(4884,21,0,194282,'Darnassus Banner',0),
(4884,22,0,180755,'Dwarf Hero',0),
(4884,23,0,28044,'Dwarven District',0),
(4884,24,0,192180,'Ebon Blade Banner',0),
(4884,25,0,185459,'elfwallhanging 09',0),
(4885,0,0,178828,'Meeting Stone (Ashenvale)',1),
(4885,1,0,211062,'Elwynn Fence',0),
(4885,2,0,211063,'Elwynn Fence',0),
(4885,3,0,193473,'Excavation Banner Stand',0),
(4885,4,0,194280,'Exodar Banner',0),
(4885,5,0,19454,'Fence',0),
(4885,6,0,190589,'Flag of Ownership',0),
(4885,7,0,190228,'G Cannon 01',0),
(4885,8,0,193795,'g shellshield',0),
(4885,9,0,19435,'Gate',0),
(4885,10,0,183350,'Gateway Murketh',0),
(4885,11,0,180322,'Ghost Gate',0),
(4885,12,0,19423,'Guard Tower',0),
(4885,13,0,193693,'HAMMER PVPHORDE A 01',0),
(4885,14,0,152079,'Horde Banner',0),
(4885,15,0,192336,'Horde Banner',0),
(4885,16,0,194844,'hu fencepost northrend',0),
(4885,17,0,19452,'Human Ballista',0),
(4885,18,0,193490,'Human Sword 01',0),
(4885,19,0,193699,'Human Sword 02',0),
(4885,20,0,182354,'Kil''sorrow Banner',0),
(4885,21,0,183955,'Kirin''Var Ward',0),
(4885,22,0,195319,'Kvaldir Banner',0),
(4885,23,0,193429,'lordaeron citybanner 01',0),
(4885,24,0,92545,'Mail Armor',0),
(4885,25,0,181694,'Naga Flag',0),
(4889,0,0,178824,'Meeting Stone (Barrens)',1),
(4889,1,0,92531,'NIGHTELFSIGN CLOTHARMOR',0),
(4889,2,0,92546,'NIGHTELFSIGN SHIELDS',0),
(4889,3,0,92539,'NIGHTELFSIGN WEAPONSMITH',0),
(4889,4,0,19453,'Orc Catapult',0),
(4889,5,0,20812,'Orc Tower',0),
(4889,6,0,193679,'ORCSHIELD 02',0),
(4889,7,0,193683,'ORCSPEAR 03',0),
(4889,8,0,194278,'Orgrimmar Banner',0),
(4889,9,0,187083,'Pirate Flag',0),
(4889,10,0,180398,'PVP HOLIDAY ALLIANCE ARATHI',0),
(4889,11,0,180399,'PVP HOLIDAY ALLIANCE AV',0),
(4889,12,0,180400,'PVP HOLIDAY ALLIANCE CTF',0),
(4889,13,0,195532,'PVP HOLIDAY ALLIANCE ISLE OF CONQUEST',0),
(4889,14,0,180397,'PVP HOLIDAY GENERIC SIGNPOST',0),
(4889,15,0,180396,'PVP HOLIDAY HORDE ARATHI',0),
(4889,16,0,180395,'PVP HOLIDAY HORDE AV',0),
(4889,17,0,180394,'PVP HOLIDAY HORDE CTF',0),
(4889,18,0,195533,'PVP HOLIDAY HORDE ISLE OF CONQUEST',0),
(4889,19,0,19392,'PvP Wall',0),
(4889,20,0,191125,'Rejek''s Sword',0),
(4889,21,0,19444,'Rock Wall',0),
(4889,22,0,211064,'Rockwall Fence',0),
(4889,23,0,191203,'SC Wall 01 Cap',0),
(4889,24,0,191204,'SC Wall 01 Ramp',0),
(4889,25,0,191269,'SC Wall 06 Piece',0),
(4927,0,2,1267,'Musician',1),
(4927,1,0,194281,'Sen''jin Banner',0),
(4927,2,0,202839,'Sen''jin Bat Roost Fence Post',0),
(4927,3,0,185021,'Shadow Council Banner 01',0),
(4927,4,0,187123,'Shattered Sun Banner',0),
(4927,5,0,193766,'shield pvpalliance',0),
(4927,6,0,193692,'SHIELD PVPHORDE',0),
(4927,7,0,182749,'Shields of Silver',0),
(4927,8,0,194275,'Silvermoon City Banner',0),
(4927,9,0,18077,'Smoking Rack',0),
(4927,10,0,173202,'Soran''s Leather and Steel Armory',0),
(4927,11,0,19395,'Spike Wall',0),
(4927,12,0,19455,'Stone Fence',0),
(4927,13,0,194274,'Stormwind Banner',0),
(4927,14,0,182186,'Sun Gate',0),
(4927,15,0,187384,'The Ancient Armor of the Kvaldir',0),
(4927,16,0,192123,'The Shadow Vault Banner',0),
(4927,17,0,192178,'The Shadow Vault Banner (Baron Sliver''s)',0),
(4927,18,0,187386,'The Shield of the Aesirites',0),
(4927,19,0,2150,'The Silver Shield',0),
(4927,20,0,50488,'Thunder Bluff Armorers',0),
(4927,21,0,194283,'Thunder Bluff Banner',0),
(4927,22,0,50503,'Thunder Bluff Weapons',0),
(4927,23,0,19482,'Troll Watch Tower',0),
(4927,24,0,188386,'Tu''u''gwar''s Bait',0),
(4927,25,0,194276,'Undercity Banner',0),
(5171,0,0,1744,'Anvil',1),
(5171,1,0,184005,'Unyielding Banner',0),
(5171,2,0,191510,'Valduran''s Shield',0),
(5171,3,0,184413,'Visual Banner2 (Horde)',0),
(5171,4,0,190659,'War Horn Base',0),
(5171,5,0,69420,'War Horn Shaker - Big',0),
(5171,6,0,180852,'War Map',0),
(5171,7,0,183948,'Ward Effect',0),
(5171,8,0,182366,'Warmaul Banner of Conquering',0);
INSERT INTO zerocraft_bscroll_items (item_entry, idx, kind, entry, name, useful) VALUES
(5171,9,0,182353,'Warmaul Ogre Banner',0),
(5171,10,0,187771,'Warsong Banner',0),
(5171,11,0,191697,'Warsong Granary',0),
(5171,12,0,19450,'Watch Tower',0),
(5171,13,0,190576,'Weapon Rack',0),
(5171,14,0,183269,'Weapon Rack',0),
(5171,15,0,190871,'Westfall Fencepost',0),
(5171,16,0,193440,'worc barricade',0),
(5171,17,0,186623,'Zul''Aman - Dwarf Hammer',0),
(5171,18,0,191615,'Zul''Drak Spike Line',0),
(5228,0,2,17163,'Stable Master',1),
(5228,1,0,193057,'Ahn''kahet Brazier',0),
(5228,2,0,184284,'Ammen Vale Torch',0),
(5228,3,0,185108,'Ancient Brazier',0),
(5228,4,0,185967,'ANCIENT D STANDING LIGHT',0),
(5228,5,0,176295,'Archive Fire',0),
(5228,6,0,181503,'Banner of the Twilight''s Hammer Clan',0),
(5228,7,0,6286,'Barrens Lamp Post 01',0),
(5228,8,0,185476,'Barrow Light',0),
(5228,9,0,181319,'BE Campfire 01',0),
(5228,10,0,176093,'Beacon Torch',0),
(5228,11,0,186678,'Binder''s Brazier',0),
(5228,12,0,126312,'BLACKROCKORCCAMPFIRE',0),
(5228,13,0,3866,'Blazing Fire',0),
(5228,14,0,190941,'Blight Fog Effect',0),
(5228,15,0,180434,'Bonfire',0),
(5228,16,0,188242,'Bonfire Northrend 01',0),
(5228,17,0,191407,'Bonfire Northrend 01Blue',0),
(5228,18,0,184510,'Books On Fire',0),
(5228,19,0,173016,'Borstan''s Firepit',0),
(5228,20,0,180473,'Brazier',0),
(5228,21,0,181045,'Brazier of Beckoning',0),
(5228,22,0,187457,'Brazier of Dancing Flames',0),
(5228,23,0,181051,'Brazier of Invocation',0),
(5228,24,0,190785,'Burnt Stone Tree Fire Flies VFX',0),
(5331,0,0,188241,'Mailbox: Northrend (Grizzly Hills)',1),
(5331,1,0,1798,'Campfire',0),
(5331,2,0,187572,'Candle 01 - MFF',0),
(5331,3,0,187573,'Candle 02 - MFF',0),
(5331,4,0,180340,'Candle 03',0),
(5331,5,0,1558,'Candle of Beckoning',0),
(5331,6,0,180339,'Candles',0),
(5331,7,0,202924,'Celebration Torch',0),
(5331,8,0,190117,'Crate Highlight',0),
(5331,9,0,201600,'Crucible Brazier',0),
(5331,10,0,191547,'Crusader Dargath''s Light',0),
(5331,11,0,185036,'Dark Brazier',0),
(5331,12,0,185047,'Dark Brazier',0),
(5331,13,0,181641,'Dark Light',0),
(5331,14,0,173005,'Darkfire Enclave',0),
(5331,15,0,184613,'Doomclaw''s Brazier',0),
(5331,16,0,185543,'DR Brazier 02',0),
(5331,17,0,193386,'dragonblight fires lower 01',0),
(5331,18,0,193381,'dragonblight fires lower east 02',0),
(5331,19,0,193382,'dragonblight fires lower west 03',0),
(5331,20,0,193383,'dragonblight fires upper east 01',0),
(5331,21,0,193384,'dragonblight fires upper north 03',0),
(5331,22,0,193385,'dragonblight fires upper west 02',0),
(5331,23,0,192723,'dragonblight iceshard 01',0),
(5331,24,0,192722,'dragonblight iceshard 02',0),
(5365,0,0,190915,'Mailbox: Ebon Hold (Death Knight)',1),
(5365,1,0,192728,'dragonblight iceshard 03',0),
(5365,2,0,192724,'dragonblight iceshard 04',0),
(5365,3,0,192725,'dragonblight iceshard 05',0),
(5365,4,0,192726,'dragonblight iceshard 06',0),
(5365,5,0,194237,'Drak''Mar Brazier',0),
(5365,6,0,188287,'Drakuru''s Brazier',0),
(5365,7,0,1743,'DWARVENBRAZIER 02',0),
(5365,8,0,1766,'Elwynn Campfire',0),
(5365,9,0,179147,'Elwynn Campfire blue',0),
(5365,10,0,146082,'Equinex Monolith Lights 1',0),
(5365,11,0,146083,'Equinex Monolith Lights 2',0),
(5365,12,0,37089,'Fiery Brazier',0),
(5365,13,0,186720,'Fire Effigy',0),
(5365,14,0,179666,'Fire Elemental Rift',0),
(5365,15,0,148503,'Fire Plume Ridge Hot Spot',0),
(5365,16,0,4004,'Fire Plume Ridge Lava Lake',0),
(5365,17,0,1829,'Firewood Pile 01',0),
(5365,18,0,34571,'FORGEBONFIRE',0),
(5365,19,0,171924,'Franclorn Light Shaft',0),
(5365,20,0,192020,'G Brazier 01',0),
(5365,21,0,195087,'Ghostly Cooking Fire',0),
(5365,22,0,193631,'Gnome Hazard Light Red',0),
(5365,23,0,193586,'Gnome Maintenance Light 01',0),
(5365,24,0,193630,'Gnome Structural Spot Light 02',0),
(5372,0,0,172911,'The Black Anvil',1),
(5372,1,0,183503,'Hellfire fireparticle',0),
(5372,2,0,193160,'hellfiresupplies 02',0),
(5372,3,0,193161,'hellfiresupplies 03',0),
(5372,4,0,193162,'hellfiresupplies 04',0),
(5372,5,0,193163,'hellfiresupplies 05',0),
(5372,6,0,192929,'hellfiresupplies 06',0),
(5372,7,0,210341,'Hive Fireflies 01',0),
(5372,8,0,190215,'Human Brazier Corrupt',0),
(5372,9,0,191853,'IT BRAZIER 02',0),
(5372,10,0,183128,'KARAZAHNBONFIRE 02',0),
(5372,11,0,19457,'Lamp Post',0),
(5372,12,0,179977,'Lantern',0),
(5372,13,0,3084,'Large Fire Pit 01',0),
(5372,14,0,58600,'Light Armor',0),
(5372,15,0,177415,'Light of Elune',0),
(5372,16,0,180713,'Light of Elune',0),
(5372,17,0,149410,'Light of Retribution',0),
(5372,18,0,180124,'Lighthouse Beam',0),
(5372,19,0,178745,'Lights x3, Broken',0),
(5372,20,0,178551,'Lights, Broken',0),
(5372,21,0,188438,'Magnataur Worship Candle',0),
(5372,22,0,188439,'Magnataur Worship Candle',0),
(5372,23,0,188436,'Magnataur Worship Candles',0),
(5372,24,0,188437,'Magnataur Worship Candles',0),
(5384,0,0,32349,'Mailbox: Dwarf (Ironforge)',1),
(5384,1,0,18047,'MEDIUMBRAZIERNOOMNI 01',0),
(5384,2,0,191184,'Northrend Elwynn Campfire',0),
(5384,3,0,189294,'Northrend Elwynn Campfire blue',0),
(5384,4,0,192921,'northrendtorch 01',0),
(5384,5,0,181311,'Ogre Campfire 01',0),
(5384,6,0,182573,'Ogre Firepit',0),
(5384,7,0,1831,'Orc Bon Fire',0),
(5384,8,0,3308,'Orc Bon Fire Off',0),
(5384,9,0,57748,'Orc Brazier Lightpost Barrens',0),
(5384,10,0,183909,'Orc PVPBonfire Large',0),
(5384,11,0,40198,'ORCBONFIRE BLUE',0),
(5384,12,0,177002,'ORGRIMMARBONFIRE 01',0),
(5384,13,0,193559,'outlanddeadcampfire',0),
(5384,14,0,192578,'sc blighter 2 green',0),
(5384,15,0,191332,'Scarlet O Brazier Fire',0),
(5384,16,0,190130,'Scarlet O Brazier Lit',0),
(5384,17,0,190150,'Scarlet O Brazier Smoker',0),
(5384,18,0,185245,'Scholomance Brazier 01Green',0),
(5384,19,0,185250,'Scholomance Brazier 01Orange',0),
(5384,20,0,185235,'Scholomance Brazier 01Purple',0),
(5384,21,0,185003,'Shadow Council Torch',0),
(5384,22,0,1967,'Small Brazier 01',0),
(5384,23,0,74138,'SMALLBRAZIERNOOMNI 01',0),
(5384,24,0,180043,'Standing Torch',0),
(5407,0,0,189993,'Portal to Theramore',1),
(5407,1,0,179984,'Stormwind Dwarf Brazier',0),
(5407,2,0,31575,'Tall Brazier',0),
(5407,3,0,57708,'Tauren Lamp Post',0),
(5407,4,0,26486,'The Stonefire Tavern',0),
(5407,5,0,210336,'Twilight Tablet',0),
(5407,6,0,187988,'Twilight Torch',0),
(5407,7,0,187105,'VR Brazier 01',0),
(5407,8,0,192591,'vr brazier 01 blue',0),
(5407,9,0,193566,'VR Standing Light Snow Blue 01',0),
(5407,10,0,190664,'Wall Light',0),
(5407,11,0,180352,'Wall Torch',0),
(5407,12,0,190748,'WotLK Light Banner, Stormwind',0),
(5407,13,0,191140,'WotLK Light Book Open',0),
(5407,14,0,191128,'WotLK Light Book Stack',0),
(5407,15,0,191132,'WotLK Light Rock',0),
(5407,16,0,191134,'WotLK Light Sword Crate',0),
(5407,17,0,190794,'WotLK Light Tent',0),
(5407,18,0,190746,'WotLK Light Well',0),
(5407,19,0,187317,'WT Brazier Lit',0),
(5407,20,0,191834,'ZULDRAK BRAZIER 01',0),
(5407,21,0,191836,'ZULDRAK TORCH 03',0),
(5434,0,0,181883,'Mailbox: Blood Elf (Silvermoon)',1),
(5434,1,0,210312,'Ahn''Qiraj Ossirian Crystal',0),
(5434,2,0,181449,'Altar of Aggonar',0),
(5434,3,0,211019,'Altar of Hyjal',0),
(5434,4,0,2563,'Altar of the Tides - Focused',0),
(5434,5,0,178787,'Alterac Valley Supplies',0),
(5434,6,0,190675,'Apothecary Orb',0),
(5434,7,0,185863,'Arakkoa Shrine',0),
(5434,8,0,185171,'Arakkoa Summoning Dome',0),
(5434,9,0,183098,'Arcane Brazier',0),
(5434,10,0,183853,'Arcanist Maisie the Storm-Summoner',0),
(5434,11,0,183507,'Archmage Vargoth''s Orb',0),
(5434,12,0,190503,'Arranged Crystal Formation',0),
(5434,13,0,185056,'Axxarien Crystal',0),
(5434,14,0,192689,'Blue Moon Sigil',0),
(5434,15,0,142074,'Bly''s Escape Portal',0),
(5434,16,0,180875,'Boss Fight Altar',0),
(5434,17,0,193768,'Chulo the Mad''s Totem',0),
(5434,18,0,195116,'Crystal Offering',0),
(5434,19,0,187078,'Crystal Ward',0),
(5434,20,0,190716,'Crystallized Blight',0),
(5434,21,0,190939,'Crystallized Blight',0),
(5434,22,0,190940,'Crystallized Blight',0),
(5434,23,0,179144,'Danger! Crystalvein Mine closed!',0),
(5434,24,0,185103,'Dark Portal',0),
(5434,25,0,192917,'Death''s Gaze Orb',0),
(5434,26,0,191083,'Demonic Circle: Summon',0),
(5436,0,0,3769,'Potbelly Stove',1),
(5436,1,0,181917,'Draenei Banner',0),
(5436,2,0,185107,'Draenei Banner',0),
(5436,3,0,183318,'Draenei HoloRunes',0),
(5436,4,0,183319,'Draenei HoloRunes',0),
(5436,5,0,183320,'Draenei HoloRunes',0),
(5436,6,0,183771,'Draenei Machine',0),
(5436,7,0,183448,'Draenei Spirit',0),
(5436,8,0,184808,'Draenei Wreckage Frame',0),
(5436,9,0,179681,'Dreadsteed Portal',0),
(5436,10,0,187772,'Empty Arcane Prison',0),
(5436,11,0,183158,'Fel Cannon Base',0),
(5436,12,0,184294,'Fel Stratholme Fire Smoke Embers',0),
(5436,13,0,210348,'Floating Purple Crystal 01',0),
(5436,14,0,191842,'Frostgut''s Altar',0),
(5436,15,0,193769,'Gawanil''s Totem',0),
(5436,16,0,210337,'Glyphed Crystal',0),
(5436,17,0,174792,'Gorishi Silithid Crystal',0),
(5436,18,0,192687,'Green Moon Sigil',0),
(5436,19,0,183036,'Ground Rune',0),
(5436,20,0,184496,'HELLFIRE DW FLOORBRAIZER',0),
(5436,21,0,183831,'HELLFIRE FLOORBRAIZER',0),
(5436,22,0,175075,'Human Brazier Magic',0),
(5436,23,0,186747,'Icy Rune',0),
(5436,24,0,181779,'Impact Site Crystal',0),
(5436,25,0,195427,'Isle of Conquest Portal Niche Alliance',0),
(5436,26,0,195428,'Isle of Conquest Portal Niche Horde',0),
(5438,0,0,1685,'Forge',1),
(5438,1,0,164838,'JD Red Crystal 1',0),
(5438,2,0,164927,'JD Yellow Crystal 1',0),
(5438,3,0,193770,'Kutube''sa''s Totem',0),
(5438,4,0,19405,'Lava Altar',0),
(5438,5,0,185588,'Legion Ring Obelisk',0),
(5438,6,0,188445,'Ley Line Focus',0),
(5438,7,0,184307,'Light Crystal',0),
(5438,8,0,191680,'Magical Menagerie',0),
(5438,9,0,187890,'Magna Totem',0),
(5438,10,0,187058,'Mana Cell',0),
(5438,11,0,187057,'Mana Cell 3x3',0),
(5438,12,0,184803,'Mana Loom',0),
(5438,13,0,185019,'Mana Loom Glow',0),
(5438,14,0,103680,'Mana Rift',0),
(5438,15,0,181623,'Molten Core Instance Portal',0),
(5438,16,0,182036,'Naaru Room Crystal',0),
(5438,17,0,184493,'Netherstorm Flag',0),
(5438,18,0,190019,'Nexus Magic Orb Blue 01',0),
(5438,19,0,188448,'Nexus Sigil Blue 01',0),
(5438,20,0,188447,'Nexus Sigil Blue 02',0),
(5438,21,0,181361,'Night Elf Moon Crystal',0),
(5438,22,0,182079,'Nightelf Stone Rune',0),
(5438,23,0,182080,'Nightelf Stone Rune',0),
(5438,24,0,185901,'Ogri''la Crystal Smoke Image',0),
(5438,25,0,185933,'Ogrila Crystal 01',0),
(5438,26,0,185934,'Ogrila Crystal 02',0),
(5449,0,0,182948,'Mailbox: Draenei (Exodar)',1),
(5449,1,0,187429,'Orb of Translocation Target',0),
(5449,2,0,189305,'Orik''s Crystalline Orb',0),
(5449,3,0,190488,'Pentarus'' Portal to Sholazar Basin',0),
(5449,4,0,187335,'Portal from Shattrath City',0),
(5449,5,0,194481,'Portal to Dalaran',0),
(5449,6,0,193427,'Portal to Orgrimmar',0),
(5449,7,0,193956,'Portal to Stormwind',0),
(5449,8,0,192691,'Purple Moon Sigil',0),
(5449,9,0,192690,'Red Moon Sigil',0),
(5449,10,0,177526,'Relic Bundle',0),
(5449,11,0,104592,'Rituals of Power',0),
(5449,12,0,153359,'Rune of Return',0),
(5449,13,0,191746,'SC RUNEFORGE 01',0),
(5449,14,0,191757,'SC RUNEFORGE 02',0),
(5449,15,0,2871,'Seaworn Altar',0),
(5449,16,0,185016,'Shadow Council Magic Device 01',0),
(5449,17,0,185017,'Shadow Council Magic Device 02',0),
(5449,18,0,191707,'Shadowmoon Rune 1',0),
(5449,19,0,100035,'Shaman Shrine',0),
(5449,20,0,188158,'Shimmering Portal',0),
(5449,21,0,15885,'Shrine Of Remulos',0),
(5449,22,0,185552,'Shrine of the Eagle',0),
(5449,23,0,187342,'Shrine of the Naga Priestess',0),
(5449,24,0,210344,'silithus crystal formation 03',0),
(5449,25,0,202882,'Small Ritual Drum',0),
(5449,26,0,202883,'Small Ritual Drum 2',0),
(5450,0,0,194490,'Grill',1),
(5450,1,0,181142,'Summoner Shield',0),
(5450,2,0,37097,'Summoning Circle',0),
(5450,3,0,92388,'Summoning Circle',0),
(5450,4,0,178484,'Tear in the Nether',0),
(5450,5,0,193589,'Temple of Invention Orb',0),
(5450,6,0,190156,'Thel''zan Summoning Obelisk',0),
(5450,7,0,184624,'Toshley''s Turbo Tesla Turret',0),
(5450,8,0,190591,'Troll Bat Totem',0),
(5450,9,0,188048,'Twilight Crystal Base',0),
(5450,10,0,188050,'Twilight Crystal Base',0),
(5450,11,0,188156,'Twilight Crystal Base',0),
(5450,12,0,188157,'Twilight Crystal Base',0),
(5450,13,0,187976,'Twilight Summoning Circle',0),
(5450,14,0,187977,'Twilight Summoning Circle',0),
(5450,15,0,188440,'Under Construction Magnataur Altar',0),
(5450,16,0,194008,'Voldrune Banner',0),
(5450,17,0,179668,'Warlock Mount Ritual Circle',0),
(5450,18,0,189544,'WARRIORBANNER 01',0),
(5450,19,0,174764,'Witherbark Totem Bundle',0),
(5450,20,0,190741,'WotLK Light Altar',0),
(5450,21,0,185311,'Writhing Mound Summoning Circle',0),
(5450,22,0,192685,'Yellow Moon Sigil',0),
(5453,0,0,181146,'Portal to Karazhan',1),
(5453,1,0,178646,'Alliance Supply Crate',0),
(5453,2,0,184799,'Ancient Casket',0),
(5453,3,0,126260,'Ancient Chest',0),
(5453,4,0,190559,'Apple Barrel',0),
(5453,5,0,181255,'Argent Dawn Buffer Crate',0),
(5453,6,0,186671,'Ashli''s Vase',0),
(5453,7,0,58624,'Bag Vendor',0),
(5453,8,0,179967,'Barrel',0),
(5453,9,0,180779,'Barrel 02',0),
(5453,10,0,1670,'Barrel of Powder',0),
(5453,11,0,185503,'Barrow Chest',0),
(5453,12,0,195192,'Basket of Corn',0),
(5453,13,0,181933,'BE cook Pot 01',0),
(5453,14,0,179976,'Beer Keg',0),
(5453,15,0,180575,'Beer Keg 02',0),
(5453,16,0,184856,'Box C',0),
(5453,17,0,178304,'Box o'' Squirrels',0),
(5453,18,0,190880,'Broken Barrel 01',0),
(5453,19,0,190881,'Broken Barrel 02',0),
(5453,20,0,182403,'Broken Cart',0),
(5453,21,0,186808,'Broken Keg',0),
(5453,22,0,186809,'Broken Keg',0),
(5453,23,0,2696,'bucket',0),
(5453,24,0,3825,'Burning Embers',0),
(5454,0,0,176498,'Portal to Darnassus',1),
(5454,1,0,3832,'Burning Embers',0),
(5454,2,0,3865,'Burning Embers',0),
(5454,3,0,3218,'Burning Seed Circle of Power',0),
(5454,4,0,191160,'Burning Tree Large, Chapter III',0),
(5454,5,0,186278,'Burning Wreckage',0),
(5454,6,0,190400,'Burning Wreckage',0),
(5454,7,0,19404,'Burnt Giant Wheel',0),
(5454,8,0,190863,'Burnt Outpost 05',0),
(5454,9,0,190864,'Burnt Outpost 06',0),
(5454,10,0,184800,'Casket Lid',0),
(5454,11,0,50484,'Cloudweaver''s Baskets',0),
(5454,12,0,188225,'Comestic Chest 02 (2.00)',0),
(5454,13,0,195198,'Crate 01',0),
(5454,14,0,193637,'Crate 02',0),
(5454,15,0,180714,'Crate Alliance First Aid 01',0),
(5454,16,0,180599,'Crate Horde First Aid 01',0),
(5454,17,0,103573,'Cut Woodpile',0),
(5454,18,0,193640,'Dead Mine Powder Keg',0),
(5454,19,0,181790,'DR Cookpot 01',0),
(5454,20,0,180853,'Duke''s Box',0),
(5454,21,0,181962,'Dust Bag',0),
(5454,22,0,179971,'Elf Crate 01',0),
(5454,23,0,180403,'Fishing Box',0),
(5454,24,0,178909,'Frostwolf Supplies',0),
(5515,0,0,177232,'Moonwell',1),
(5515,1,0,178910,'Frostwolf Supplies',0),
(5515,2,0,193583,'Gnomebucket 01',0),
(5515,3,0,193584,'Gnomebucket 02',0),
(5515,4,0,123207,'Goblin Smelting Pot',0),
(5515,5,0,26482,'Goldfury''s Hunting Supplies',0),
(5515,6,0,180880,'Gun Shop Ammo Box Blue',0),
(5515,7,0,180881,'Gun Shop Ammo Box Blue Block',0),
(5515,8,0,180882,'Gun Shop Ammo Box Red',0),
(5515,9,0,193700,'Gun Shop Powder Keg Open',0),
(5515,10,0,178666,'Gypsy Wagon',0),
(5515,11,0,191841,'Hardpacked Explosive Bundle',0),
(5515,12,0,19430,'Hay Wagon',0),
(5515,13,0,178442,'Horde Supply Crate',0),
(5515,14,0,186559,'Incense Burner',0),
(5515,15,0,179973,'Inn Barrel',0),
(5515,16,0,194890,'inscription scroll boxside',0),
(5515,17,0,194891,'inscription scroll boxup',0),
(5515,18,0,186281,'Intact Barrel',0),
(5515,19,0,180329,'Jar 01',0),
(5515,20,0,180330,'Jar 02',0),
(5515,21,0,180331,'Jar 03',0),
(5515,22,0,180341,'Jar Orc 01',0),
(5515,23,0,180342,'Jar Orc 02',0),
(5515,24,0,180345,'Jar Orc 03',0),
(5531,0,0,182351,'Portal to Exodar',1),
(5531,1,0,180347,'Jar Orc 04',0),
(5531,2,0,180348,'Jar Orc 05',0),
(5531,3,0,180349,'Jar Orc 06',0),
(5531,4,0,185006,'Jhang''s Lunchbox',0),
(5531,5,0,185007,'Jhang''s Sack',0),
(5531,6,0,186658,'Kraz''s Chest',0),
(5531,7,0,195196,'largebasket 03',0),
(5531,8,0,194393,'Log Pile',0),
(5531,9,0,181012,'Magister Duskwither''s Journal',0),
(5531,10,0,152098,'Magus Rimtori''s Journal',0),
(5531,11,0,190555,'Nerubian Crater',0),
(5531,12,0,92527,'NIGHTELFSIGN BAGS',0),
(5531,13,0,177492,'Northridge Lumber Mill Crate',0),
(5531,14,0,179974,'Orc Barrel 03',0),
(5531,15,0,105568,'Peasent Woodpile',0),
(5531,16,0,201774,'Quenching Barrel',0),
(5531,17,0,179970,'Replace Crate 02',0),
(5531,18,0,180660,'Sack of Gold',0),
(5531,19,0,191261,'SC Bodyjar',0),
(5531,20,0,180044,'Shout Box',0),
(5531,21,0,186714,'Shout Box Generic',0),
(5531,22,0,195194,'Small Basket 01',0),
(5531,23,0,19481,'Small Boat',0),
(5531,24,0,144111,'Smite''s Chest',0),
(5651,0,0,176500,'Portal to Thunder Bluff',1),
(5651,1,0,1560,'Storage Chest',0),
(5651,2,0,178806,'Stormpike Supplies',0),
(5651,3,0,178807,'Stormpike Supplies',0),
(5651,4,0,178808,'Stormpike Supplies',0),
(5651,5,0,179972,'Stormwind Crate 01',0),
(5651,6,0,179969,'Supply Crate',0),
(5651,7,0,190094,'Suspicious Grain Crate',0),
(5651,8,0,1729,'Tainted Keg',0),
(5651,9,0,1730,'Tainted Keg Smoke',0),
(5651,10,0,2130,'The Wine Cask',0),
(5651,11,0,193151,'Toolbox 01',0);
INSERT INTO zerocraft_bscroll_items (item_entry, idx, kind, entry, name, useful) VALUES
(5651,12,0,175621,'Urok''s Tribute Pile',0),
(5651,13,0,187081,'VR Cookpot 01',0),
(5651,14,0,194679,'VR COOKPOT 02',0),
(5651,15,0,186614,'Water Bucket',0),
(5651,16,0,186615,'Water Buckets',0),
(5651,17,0,194874,'Weapon Crate Horde Axe',0),
(5651,18,0,194879,'weaponcratehordeaxeopen',0),
(5651,19,0,190878,'West Fall Barrel 01',0),
(5651,20,0,190879,'West Fall Crate',0),
(5651,21,0,190021,'Wolvar Cook Pot',0),
(5651,22,0,191313,'Zul Drak Burning Log 01',0),
(5651,23,0,186307,'Zul''Aman Exterior Crate B',0),
(5652,0,0,2719,'Bubbling Cauldron',1),
(5652,1,0,190672,'Apothecary Blood Machine',0),
(5652,2,0,190673,'Apothecary Blood Vial',0),
(5652,3,0,190674,'Apothecary Cage',0),
(5652,4,0,188363,'Apothecary Cage (Bottom)',0),
(5652,5,0,192166,'azjol web rope angled 01',0),
(5652,6,0,192815,'azjol web rope straight 01',0),
(5652,7,0,192807,'azjol web rope straight 03',0),
(5652,8,0,192973,'Battle Glade Sword Skull',0),
(5652,9,0,195186,'Black Knight''s Grave',0),
(5652,10,0,180224,'Blasted Lands Bone Pile 02',0),
(5652,11,0,180225,'Blasted Lands Bone Pile 03',0),
(5652,12,0,180223,'Blasted Lands Skull 01',0),
(5652,13,0,190609,'Blood Device',0),
(5652,14,0,187360,'Blood Elf Banner (Hanging scale x3.00)',0),
(5652,15,0,182093,'Blood Elf Table - Small',0),
(5652,16,0,190604,'Blood Vat',0),
(5652,17,0,2968,'Bloodhoof Village',0),
(5652,18,0,187371,'Bloodmyst Crystal Aparatus 01',0),
(5652,19,0,160465,'Bloodpetal Target',0),
(5652,20,0,180222,'Bone 02',0),
(5652,21,0,43116,'Bone Fire',0),
(5652,22,0,192993,'Bone Spike 02',0),
(5652,23,0,181479,'Bones of Aggonar',0),
(5652,24,0,192997,'bonespike 01',0),
(5652,25,0,190539,'Broken Plague Sprayer',0),
(5652,26,0,190601,'Broodmother Slivina''s Skull',0),
(5652,27,0,184798,'Bundle of Bloodthistle',0),
(5653,0,0,1744,'Anvil',1),
(5653,1,0,187879,'Den of Dying Plague Cauldron',0),
(5653,2,0,184108,'Dragon Skeleton',0),
(5653,3,0,184806,'Ethereal Coffin Effect',0),
(5653,4,0,200337,'Forsaken Plague Barrel',0),
(5653,5,0,200338,'Forsaken Plague Barrel Empty',0),
(5653,6,0,193961,'Frozen Bones',0),
(5653,7,0,181379,'G Cage 02',0),
(5653,8,0,180410,'G Hanging Skeleton 01',0),
(5653,9,0,181227,'G Scourge Rune Circle Crystal',0),
(5653,10,0,180212,'Grom''s Blood Elf Tribute',0),
(5653,11,0,180471,'Hanging Skull Light 01',0),
(5653,12,0,180472,'Hanging Skull Light 02',0),
(5653,13,0,2371,'Headhunter Skull',0),
(5653,14,0,192992,'impalingstone corpse 01',0),
(5653,15,0,192996,'impalingstone corpse 02',0),
(5653,16,0,181625,'Jaguar - Crocolisk Cage',0),
(5653,17,0,175246,'Kibler''s Cage',0),
(5653,18,0,175247,'Kibler''s Cage',0),
(5653,19,0,175248,'Kibler''s Cage',0),
(5653,20,0,175249,'Kibler''s Cage',0),
(5653,21,0,176745,'light Skeleton Laying 01',0),
(5653,22,0,185454,'light Skeleton Laying 02',0),
(5653,23,0,185455,'light Skeleton Laying 03',0),
(5653,24,0,185434,'light Skeleton Sitting 01',0),
(5653,25,0,185435,'light Skeleton Sitting 02',0),
(5653,26,0,185436,'light Skeleton Sitting 03',0),
(5653,27,0,185438,'light Skeleton Sitting 04',0),
(6090,0,0,195141,'Portal to Blasted Lands',1),
(6090,1,0,181081,'Map of the Eastern Plaguelands',0),
(6090,2,0,189314,'Necromantic Runestone',0),
(6090,3,0,181172,'Necropolis City',0),
(6090,4,0,181476,'Nox Portal Plaguewood',0),
(6090,5,0,186601,'Oluf''s Cage',0),
(6090,6,0,193003,'Pile of Crusader Skulls',0),
(6090,7,0,190935,'Plague Cauldron Active Base',0),
(6090,8,0,202105,'Plague Wagon Empty',0),
(6090,9,0,188084,'Plagued Grain',0),
(6090,10,0,190095,'Plagued Grain Crate',0),
(6090,11,0,177671,'Plaguewood Smoke',0),
(6090,12,0,188678,'Plaugelands Cage 01',0),
(6090,13,0,192959,'sc bonearm 01',0),
(6090,14,0,191262,'SC Cages 01',0),
(6090,15,0,192576,'sc skullpikes 01',0),
(6090,16,0,192577,'sc skullpikes 02',0),
(6090,17,0,176087,'Scourge Banner',0),
(6090,18,0,190923,'Scourge Body Hanging 01',0),
(6090,19,0,190924,'Scourge Body Hanging 02',0),
(6090,20,0,190925,'Scourge Body Hanging 03',0),
(6090,21,0,190575,'Scourge Body Wagon',0),
(6090,22,0,188542,'Scourge Bonfire',0),
(6090,23,0,20969,'Scourge Campfire',0),
(6090,24,0,189970,'Scourge Discombobulater',0),
(6090,25,0,187693,'Scourge Marker',0),
(6090,26,0,190577,'Scourge Weapon Rack',0),
(6090,27,0,187357,'Shattered Sun Banner (Blood Elf - Pole)',0),
(6297,0,0,186143,'Clay Oven',1),
(6297,1,0,192974,'Skeleton Laying 01',0),
(6297,2,0,192964,'Skeleton Laying 02',0),
(6297,3,0,192963,'Skeleton Laying 03',0),
(6297,4,0,180425,'Skull Candle 01',0),
(6297,5,0,105168,'Skull Key',0),
(6297,6,0,195213,'Small Coliseum Cage',0),
(6297,7,0,184742,'T''chali''s Grave',0),
(6297,8,0,184745,'T''chali''s Skull',0),
(6297,9,0,192162,'terokkarweb 02',0),
(6297,10,0,192161,'terokkarweb 03',0),
(6297,11,0,179747,'Terrordale Haunting Spirit',0),
(6297,12,0,177239,'Tirion Fordring''s Grave',0),
(6297,13,0,182163,'Tor''gash''s Cage',0),
(6297,14,0,58610,'UNDEADSIGN ALCHEMIST',0),
(6297,15,0,58601,'UNDEADSIGN BANK',0),
(6297,16,0,58617,'UNDEADSIGN BLACKSMITH',0),
(6297,17,0,58606,'UNDEADSIGN COOK',0),
(6297,18,0,58615,'UNDEADSIGN HERBALIST',0),
(6297,19,0,58620,'UNDEADSIGN MINER',0),
(6297,20,0,58625,'UNDEADSIGN POISON',0),
(6297,21,0,58607,'UNDEADSIGN TAILOR',0),
(6297,22,0,58596,'UNDEADSIGN WEAPONS',0),
(6297,23,0,186602,'Vrykul Cage Base',0),
(6297,24,0,182183,'Warmaul Skull',0),
(6297,25,0,181072,'Ysida''s Cagebase',0),
(6297,26,0,190594,'Zul Drak Skull Pile 02',0),
(6297,27,0,141075,'Zul''Farrak Cage Opener',0),
(6301,0,0,1685,'Forge',1),
(6301,1,0,188227,'Agmar''s Throne',0),
(6301,2,0,187114,'Alchemy Table',0),
(6301,3,0,190595,'Ancient Drakkari Tablets',0),
(6301,4,0,190693,'Apothecary  Bookcase',0),
(6301,5,0,190694,'Apothecary Bench',0),
(6301,6,0,2686,'Apothecary Table',0),
(6301,7,0,182608,'BE BENCH 01',0),
(6301,8,0,184671,'BE CHAIR 01',0),
(6301,9,0,182598,'BE CHAIR 02',0),
(6301,10,0,182654,'BE CHAIR 03',0),
(6301,11,0,182762,'BE CHAIR 04',0),
(6301,12,0,183268,'Bookshelf',0),
(6301,13,0,186718,'Broken Tablet',0),
(6301,14,0,193167,'Bunkbed 01',0),
(6301,15,0,12665,'Cooking Table',0),
(6301,16,0,176463,'Cooking Table',0),
(6301,17,0,191476,'DALARAN BENCH 01',0),
(6301,18,0,192199,'DALARAN BENCH 02',0),
(6301,19,0,191475,'DALARAN CHAIR 01',0),
(6301,20,0,191887,'DALARAN CHAIR 02',0),
(6301,21,0,193138,'dalaran rug 01',0),
(6301,22,0,136929,'DARKIRONCHAIR 01',0),
(6301,23,0,136931,'DARKIRONCHAIR 02',0),
(6301,24,0,136924,'DARKIRONCHAIR 03',0),
(6301,25,0,136930,'DARKIRONCHAIRBROKEN 01',0),
(6455,0,0,3769,'Potbelly Stove',1),
(6455,1,0,184038,'DR BENCH 01',0),
(6455,2,0,177724,'Dredan''s Table',0),
(6455,3,0,202218,'Drugan''s Keg',0),
(6455,4,0,42080,'Duskwood Bench',0),
(6455,5,0,190446,'Duskwood Bookshelf 01',0),
(6455,6,0,188189,'Duskwood Shop Counter',0),
(6455,7,0,191177,'Duskwood Stable',0),
(6455,8,0,183267,'Duskwood Wardrobe 02',0),
(6455,9,0,28611,'Dwarven High Back Chair',0),
(6455,10,0,180324,'Dwarven Table',0),
(6455,11,0,180884,'Dwarven Table Small',0),
(6455,12,0,193951,'DWARVENCHAIR 04',0),
(6455,13,0,193949,'DWARVENCHAIR 05',0),
(6455,14,0,195191,'dwarventablesimple 05',0),
(6455,15,0,180879,'Elven Wooden Table 01',0),
(6455,16,0,13948,'Fancy Bed',0),
(6455,17,0,186475,'Fishing Chair',0),
(6455,18,0,50490,'Fruits and Vegetables',0),
(6455,19,0,191886,'Gnome Chair 02',0),
(6455,20,0,202564,'Gnome Table',0),
(6455,21,0,184733,'GNOMECHAIR 01',0),
(6455,22,0,193633,'GNOMETABLE 01',0),
(6455,23,0,2489,'High Back Chair',0),
(6455,24,0,178226,'Hospital Bed',0),
(6455,25,0,170592,'Imperial Throne',0),
(6639,0,0,194490,'Grill',1),
(6639,1,0,194865,'Inn Pillow',0),
(6639,2,0,180885,'Inn Table Tiny',0),
(6639,3,0,183753,'IRONFORGECHAIR ORNATE 01',0),
(6639,4,0,184657,'Ironridge Table',0),
(6639,5,0,174681,'J.D.''s Work Table',0),
(6639,6,0,189289,'Karazahn Table Small',0),
(6639,7,0,181640,'KELTHUZAD THRONE',0),
(6639,8,0,176561,'Krastinov''s Work Bench',0),
(6639,9,0,190665,'Lab Table',0),
(6639,10,0,186933,'Lebronski''s Rug',0),
(6639,11,0,182257,'Mag''har Rug',0),
(6639,12,0,180719,'Metzen''s Stable',0),
(6639,13,0,182077,'Night Elf Stool',0),
(6639,14,0,183409,'OM Chair 01',0),
(6639,15,0,190190,'Onslaught Table',0),
(6639,16,0,180326,'Orc Bench 01',0),
(6639,17,0,180888,'Orc Table 01',0),
(6639,18,0,180698,'Party Table',0),
(6639,19,0,187903,'Portable Oil Collector',0),
(6639,20,0,191178,'Red Ridge Stable',0),
(6639,21,0,191264,'SC Surgical Table 01',0),
(6639,22,0,191265,'SC Surgical Table 02',0),
(6639,23,0,19624,'Shop Counter',0),
(6639,24,0,19626,'Sign Post',0),
(6639,25,0,24388,'Stone Bench',0),
(8589,0,0,1915,'Cooking Fire',1),
(8589,1,0,142947,'Stone Chair',0),
(8589,2,0,171674,'Stone Chair',0),
(8589,3,0,193909,'Stool',0),
(8589,4,0,180334,'Stormwind Rug',0),
(8589,5,0,181077,'Stormwind Rug 01',0),
(8589,6,0,176004,'Subway Bench',0),
(8589,7,0,181075,'Table',0),
(8589,8,0,188346,'Tauren Rug',0),
(8589,9,0,188347,'Tauren Rug',0),
(8589,10,0,126050,'TAURENLOGCHAIR 02',0),
(8589,11,0,178934,'The Chair',0),
(8589,12,0,185475,'The Sleeper''s Bed',0),
(8589,13,0,191647,'Thorim''s Throne',0),
(8589,14,0,179118,'Throne',0),
(8589,15,0,193105,'tradeskill firstaid 02',0),
(8589,16,0,1745,'Tradeskill Forge 01',0),
(8589,17,0,24746,'Tradeskill Forge 03',0),
(8589,18,0,192654,'UL THRONE 02',0),
(8589,19,0,186695,'VR CHAIR 01',0),
(8589,20,0,24538,'Wooden Bench',0),
(8589,21,0,2413,'Wooden Chair',0),
(8589,22,0,61919,'Wooden Chair',0),
(8589,23,0,112068,'Wooden Chair',0),
(8589,24,0,187118,'Zul''Aman - Eagle Throne',0),
(8590,0,0,177232,'Moonwell',1),
(8590,1,0,184353,'Alterac Shrub 03',0),
(8590,2,0,188668,'Amberseed (generic)',0),
(8590,3,0,164870,'Ash Tree Smoke 01',0),
(8590,4,0,20939,'Bogbean Plant',0),
(8590,5,0,193230,'borean shrub 03',0),
(8590,6,0,2711,'Charging Stone',0),
(8590,7,0,188539,'Coldwind Tree',0),
(8590,8,0,181824,'Concealing Bush',0),
(8590,9,0,182744,'Danwe''s Devices',0),
(8590,10,0,185191,'Darkstone of Terokk',0),
(8590,11,0,185494,'DNRDream Drooping Flower 02',0),
(8590,12,0,193392,'DNRDream Orange Flower 02',0),
(8590,13,0,193394,'DNRDream Purple Flower 01',0),
(8590,14,0,185495,'DNRDream Spinning Flower 01',0),
(8590,15,0,193389,'dnrdreamdroopingflower 01',0),
(8590,16,0,193391,'dnrdreamorangeflower 01',0),
(8590,17,0,185492,'Dream Flower',0),
(8590,18,0,192045,'Dry Haystack',0),
(8590,19,0,190872,'Dusk Wood Fallen Tree',0),
(8590,20,0,191165,'Duskwood human farm closed',0),
(8590,21,0,19494,'Emerald Dream Tree',0),
(8590,22,0,19495,'Emerald Dream Tree 2',0),
(8590,23,0,183820,'Ethereal Technology',0),
(9464,0,0,142075,'Mailbox: Human (Stormwind)',1),
(9464,1,0,181987,'Flare of Justice',0),
(9464,2,0,181103,'Flower',0),
(9464,3,0,181063,'Flowers for Tony',0),
(9464,4,0,181064,'Flowers for Tony',0),
(9464,5,0,181065,'Flowers for Tony',0),
(9464,6,0,181066,'Flowers for Tony',0),
(9464,7,0,186315,'Flowers Wreath 02',0),
(9464,8,0,2109,'Fragrant Flowers',0),
(9464,9,0,188068,'Frost Rock, Large',0),
(9464,10,0,192186,'FROSTGIANTICESHARD 04',0),
(9464,11,0,193674,'G Hologram Base Tanaris',0),
(9464,12,0,193222,'Grizzly Hills Blurpleflower 01',0),
(9464,13,0,193227,'Grizzly Hills Shrubs 01',0),
(9464,14,0,193224,'Grizzly Hills Yellowflower 01',0),
(9464,15,0,193221,'grizzlyhills shrubs 03',0),
(9464,16,0,182073,'Grown Mushroom',0),
(9464,17,0,193667,'GUNSHOPMORTARSHELL',0),
(9464,18,0,180037,'Hay Bail 01',0),
(9464,19,0,180038,'Hay Bail 02',0),
(9464,20,0,180700,'Hay Bale',0),
(9464,21,0,19429,'Hay Stack',0),
(9464,22,0,179968,'Haystack',0),
(9464,23,0,178904,'Healed Celebrian Vine',0),
(10594,0,0,2719,'Bubbling Cauldron',1),
(10594,1,0,184828,'Hologram Floorpiece',0),
(10594,2,0,182057,'Holographic Emitter',0),
(10594,3,0,188067,'Ice Block',0),
(10594,4,0,188229,'Ice Giant Piece',0),
(10594,5,0,188230,'Ice Giant Piece',0),
(10594,6,0,193652,'ICECROWN RAILING 01',0),
(10594,7,0,194838,'icecrown rock 03',0),
(10594,8,0,194832,'icecrown rock 04',0),
(10594,9,0,194833,'icecrown rock 05',0),
(10594,10,0,192953,'icecrown tree 01',0),
(10594,11,0,192954,'icecrown tree 02',0),
(10594,12,0,192955,'icecrown tree 03',0),
(10594,13,0,192956,'icecrown tree 04',0),
(10594,14,0,188371,'Icemist Village',0),
(10594,15,0,181686,'Lumber Pile',0),
(10594,16,0,190343,'Meetingstone 01',0),
(10594,17,0,180219,'Pumpkin Patch',0),
(10594,18,0,190890,'Red Ridge Fallen Tree 01',0),
(10594,19,0,191166,'Red Ridge human farm closed',0),
(10594,20,0,183492,'Red Riding Hood Tree',0),
(10594,21,0,190386,'Rock Rubble',0),
(10594,22,0,210343,'Sand Worm Rock Base',0),
(10594,23,0,19432,'Scarecrow',0),
(11132,0,1,31144,'Training Dummy',1),
(11132,1,0,185590,'Sethekk Halls Moonstone',0),
(11132,2,0,193220,'Silvermoon Flower 04',0),
(11132,3,0,193397,'silvermoonflower 01',0),
(11132,4,0,193399,'silvermoonflower 02',0),
(11132,5,0,191071,'Smoldering Leaves',0),
(11132,6,0,191073,'Smoldering Leaves',0),
(11132,7,0,191080,'Smoldering Leaves',0),
(11132,8,0,192075,'Snow Ball Mound 01',0),
(11132,9,0,19493,'Spinning Flower',0),
(11132,10,0,194461,'Stone Block',0),
(11132,11,0,103819,'Stone of Shy-Rotam',0),
(11132,12,0,101,'Stone Sign Pointer 01',0),
(11132,13,0,142874,'Stoneblade''s',0),
(11132,14,0,26493,'Stonebranch Herbalist',0),
(11132,15,0,191698,'Torp''s Farm',0),
(11132,16,0,194863,'vr haybail 01',0),
(11132,17,0,178908,'Vylestem Vine',0),
(11132,18,0,190932,'West Fall Scarecrow',0),
(11132,19,0,183496,'Wizard of Oz Hay',0),
(11132,20,0,190574,'Zul Drak Stone Face 01',0),
(11443,0,0,1685,'Forge',1),
(11443,1,0,191540,'Alchemy Lab',0),
(11443,2,0,192848,'All That Glitters Prospecting Co.',0),
(11443,3,0,189997,'Barrier (Large)',0),
(11443,4,0,191854,'BD LAVAFALL 01',0),
(11443,5,0,191860,'BD LAVAFALL 03',0),
(11443,6,0,195460,'Black Knight Burial',0),
(11443,7,0,188653,'Bor''s Hammer',0),
(11443,8,0,186941,'Borean Geyser 01',0),
(11443,9,0,190551,'Chunk of Saronite',0),
(11443,10,0,193708,'DALARAN HELM DEEPDIVEHELM SPACE',0),
(11443,11,0,191734,'Dalaran Merchants'' Bank',0),
(11443,12,0,191678,'Dalaran Visitor Center',0),
(11443,13,0,189315,'Dead Orca',0),
(11443,14,0,191765,'Drakuru''s Message Stand',0),
(11443,15,0,190816,'Drakuru''s Platform',0),
(11443,16,0,190897,'Drakuru''s Stairs',0),
(11443,17,0,188330,'Dun Argol',0),
(11443,18,0,191088,'Elder Kesuk',0),
(11443,19,0,19490,'Emerald Dream Catcher 3',0),
(11443,20,0,19491,'Emerald Dream Catcher 4',0),
(11443,21,0,190597,'Eye of the Prophets',0),
(11443,22,0,192843,'First to Your Aid',0),
(11663,0,0,178845,'Meeting Stone (Silverpine)',1),
(11663,1,0,193407,'FK Chemistry Set 05',0),
(11663,2,0,200333,'fk chemistryset 02',0),
(11663,3,0,200334,'fk chemistryset 03',0),
(11663,4,0,200335,'fk chemistryset 04',0),
(11663,5,0,191762,'Floor Glyph',0),
(11663,6,0,202436,'Frozen Lavaman',0),
(11663,7,0,191676,'Glorious Goods',0),
(11663,8,0,195457,'Grom''gol Zeppelin',0),
(11663,9,0,192718,'hatchwindow',0),
(11663,10,0,192847,'Legendary Leathers',0),
(11663,11,0,192856,'Like Clockwork',0),
(11663,12,0,187707,'Mist of the Ancient Mariner',0),
(11663,13,0,189996,'ND Human Barrier End',0),
(11663,14,0,191941,'NEW IN STOCK! Enchanted Ammunition from Azeroth & Beyond!',0),
(11663,15,0,188457,'Nexus Dragon Egg',0),
(11663,16,0,193562,'Nexus Dragon Egg 01',0),
(11663,17,0,192134,'Norgannon''s Binding',0),
(11663,18,0,192149,'Norgannon''s Binding',0),
(11663,19,0,194357,'Poison Vial',0),
(11663,20,0,193107,'potion red 04',0),
(11663,21,0,188446,'Projection of the Arcanomicon',0),
(11663,22,0,194261,'RX-214 Repair-o-matic Station',0),
(11664,0,0,3769,'Potbelly Stove',1),
(11664,1,0,190497,'Sapphire Hive Honeycomb',0),
(11664,2,0,201777,'Saronite Bar',0),
(11664,3,0,201776,'Saronite Bars',0),
(11664,4,0,191266,'SC Body Hook Arm 02',0),
(11664,5,0,191267,'SC Body Hook Torso',0),
(11664,6,0,190615,'SC Casting Circle 01',0),
(11664,7,0,191268,'SC Fleshgiant Boot',0),
(11664,8,0,191205,'SC Floor Decoration 01',0),
(11664,9,0,192077,'SC Frost Glow',0),
(11664,10,0,202391,'SC Pit Cylinder',0),
(11664,11,0,190919,'SC Platform 2',0),
(11664,12,0,190921,'SC Spirit Effect 01',0),
(11664,13,0,192982,'SC Spirits 01',0),
(11664,14,0,190920,'SC Stairs 2',0),
(11664,15,0,193612,'Sc Trench C Long',0),
(11664,16,0,193613,'Sc Trench C Medium',0),
(11664,17,0,193614,'Sc Trench C Tall',0),
(11664,18,0,188594,'Scrote''s Clock',0),
(11664,19,0,202893,'Sen''jin Pennant',0),
(11664,20,0,200297,'Shandy''s Clothesline',0),
(11664,21,0,192844,'Simply Enchanting',0),
(11664,22,0,191732,'Sisters Sorcerous',0),
(11666,0,0,178826,'Meeting Stone (Feralas)',1),
(11666,1,0,191767,'Sky Vortex',0),
(11666,2,0,190707,'Soul Font',0),
(11666,3,0,188443,'Spiritsbreath Incense',0),
(11666,4,0,192849,'Talismanic Textiles',0),
(11666,5,0,191731,'The Agronomical Apothecary',0),
(11666,6,0,191677,'The Arsenal Absolute',0),
(11666,7,0,191681,'The Filthy Animal',0),
(11666,8,0,191679,'The Hunter''s Reach',0),
(11666,9,0,191674,'The Militant Mystic',0),
(11666,10,0,192845,'The Scribes'' Sacellum',0);
INSERT INTO zerocraft_bscroll_items (item_entry, idx, kind, entry, name, useful) VALUES
(11666,11,0,191733,'The Wonderworks',0),
(11666,12,0,192256,'ti resurrection on 01',0),
(11666,13,0,194484,'Ulduar Protective Bubble',0),
(11666,14,0,192951,'Vehicle Teleporter',0),
(11666,15,0,188265,'Venture Bay',0),
(11666,16,0,193678,'VR BM WOOD 01',0),
(11666,17,0,19419,'vr straw large 01',0),
(11666,18,0,194861,'vr straw small 01',0),
(11666,19,0,194864,'vr trough',0),
(11666,20,0,190222,'Vrykul Hawk Roost',0),
(11666,21,0,188087,'Wreckage A',0),
(11666,22,0,188088,'Wreckage B',0),
(11667,0,0,143983,'Mailbox: Tauren (Thunder Bluff)',1),
(11667,1,0,190445,'Alchemy Gear',0),
(11667,2,0,1744,'Anvil',0),
(11667,3,0,193147,'ballistawheel 01',0),
(11667,4,0,183757,'BE FORGE',0),
(11667,5,0,184700,'Big Wagon Full of Explosives',0),
(11667,6,0,1684,'Blacksmith''s Anvil',0),
(11667,7,0,4090,'BLACKSMITHFORGE',0),
(11667,8,0,193401,'Bomb Stack Inactive',0),
(11667,9,0,188654,'Bor''s Anvil',0),
(11667,10,0,186807,'Broken Cart',0),
(11667,11,0,192846,'Cartier & Co. Fine Jewelry',0),
(11667,12,0,193148,'catapultwheel 01',0),
(11667,13,0,190859,'CAVEMINEWHEELBARROW 01',0),
(11667,14,0,201716,'Chemical Wagon',0),
(11667,15,0,186763,'Dark Iron Mole Machine',0),
(11667,16,0,193483,'Dark Iron Wood Planks 06',0),
(11667,17,0,193149,'darkirongrindingwheel',0),
(11667,18,0,193482,'darkironwoodplanks 01',0),
(11667,19,0,193484,'darkironwoodplanks 03',0),
(11667,20,0,177791,'Darkshore Anchor 01',0),
(11667,21,0,182055,'DR Anvil 01',0),
(11667,22,0,184922,'DR FORGE 01',0),
(11670,0,0,182352,'Portal to Silvermoon',1),
(11670,1,0,183863,'DR SIGNS ENGINEERING',0),
(11670,2,0,190893,'Duskwood Hay Wagon',0),
(11670,3,0,191190,'Duskwood lumbermill',0),
(11670,4,0,186683,'Empty Brew Wagon',0),
(11670,5,0,192697,'Enchanted Anvil',0),
(11670,6,0,182754,'Feledis'' Axes',0),
(11670,7,0,192525,'Fjorn''s Anvil',0),
(11670,8,0,171717,'FORGELAVAA',0),
(11670,9,0,171716,'FORGELAVAB',0),
(11670,10,0,195122,'Forsaken Stink Bomb Cloud',0),
(11670,11,0,200336,'Forsaken Wagon',0),
(11670,12,0,193668,'G Gnome Terminal',0),
(11670,13,0,142175,'G GOBLINTELEPORTER',0),
(11670,14,0,186558,'Gizmond''s Flying Machine',0),
(11670,15,0,180756,'Gnome Hero',0),
(11670,16,0,190227,'Gnome Rocket Cart',0),
(11670,17,0,184149,'Gnome Street Sign 01',0),
(11670,18,0,194279,'Gnomeregan Banner',0),
(11670,19,0,162024,'Goblin Weather Vane',0),
(11670,20,0,175467,'Goodman''s General Store',0),
(11670,21,0,173017,'Gotri''s Travelling Gear',0),
(11670,22,0,193634,'Gun Shop Bomb',0),
(11671,0,1,31144,'Training Dummy',1),
(11671,1,0,193719,'Gun Shop Dynamite',0),
(11671,2,0,50983,'Heated Forge',0),
(11671,3,0,192822,'hu scaffolding',0),
(11671,4,0,192821,'hu scaffolding 02',0),
(11671,5,0,181234,'Icebellow Anvil',0),
(11671,6,0,192582,'id anvil',0),
(11671,7,0,192583,'id forge',0),
(11671,8,0,180605,'Iron Forge Steam Tank',0),
(11671,9,0,194277,'Ironforge Banner',0),
(11671,10,0,32355,'Ironforge Main Gate',0),
(11671,11,0,26490,'Ironforge Visitor''s Center',0),
(11671,12,0,192125,'Mimir''s Anvil',0),
(11671,13,0,19592,'NG-5 Explosives (Red)',0),
(11671,14,0,183408,'OM Forge 01',0),
(11671,15,0,191682,'One More Glass',0),
(11671,16,0,184865,'Orc Wagon 02',0),
(11671,17,0,184864,'Orc Wagon 03',0),
(11671,18,0,193695,'ORCAXE 02',0),
(11671,19,0,192657,'ORG ARENA AXE PILLAR',0),
(11671,20,0,186441,'Power Core Fragment',0),
(11671,21,0,191191,'Red Ridge lumbermill',0),
(11671,22,0,201906,'Rocket Delivery System',0),
(11672,0,0,177044,'Mailbox: Forsaken (Undercity)',1),
(11672,1,0,190812,'SC Body Cart 01',0),
(11672,2,0,190813,'SC Body Cart 02',0),
(11672,3,0,190913,'SC Wagon',0),
(11672,4,0,193193,'sc wagon 02 broken',0),
(11672,5,0,180651,'Shovel',0),
(11672,6,0,23304,'Smelting Weapons',0),
(11672,7,0,190367,'Steam Main',0),
(11672,8,0,50830,'Stone Anvil',0),
(11672,9,0,190571,'Stormwind Scaffolding',0),
(11672,10,0,176348,'Styleen''s Cart',0),
(11672,11,0,172911,'The Black Anvil',0),
(11672,12,0,174045,'The Black Forge',0),
(11672,13,0,171715,'The Great Anvil',0),
(11672,14,0,187387,'TS Anvil 01',0),
(11672,15,0,187388,'TS Forge 01',0),
(11672,16,0,175321,'Unforged Seal of Ascension',0),
(11672,17,0,180211,'Uther''s Gnome Tribute',0),
(11672,18,0,190766,'Wolvar Anvil',0),
(11672,19,0,192831,'wolvar forge',0),
(11673,0,0,194097,'Summoning Portal (Northrend)',1),
(11673,1,0,193135,'AK Alchemy Bottle 01',0),
(11673,2,0,193134,'AK Alchemy Bottle 03',0),
(11673,3,0,183995,'Amadi Apples',0),
(11673,4,0,190679,'Apothecary Bowl',0),
(11673,5,0,180800,'AQWar - Resource, Cooking, Alliance, Tier 1',0),
(11673,6,0,180806,'AQWar - Resource, Cooking, Alliance, Tier 2',0),
(11673,7,0,180807,'AQWar - Resource, Cooking, Alliance, Tier 3',0),
(11673,8,0,180808,'AQWar - Resource, Cooking, Alliance, Tier 4',0),
(11673,9,0,180809,'AQWar - Resource, Cooking, Alliance, Tier 5',0),
(11673,10,0,180832,'AQWar - Resource, Cooking, Horde, Initial',0),
(11673,11,0,180833,'AQWar - Resource, Cooking, Horde, Tier 1',0),
(11673,12,0,180834,'AQWar - Resource, Cooking, Horde, Tier 2',0),
(11673,13,0,180835,'AQWar - Resource, Cooking, Horde, Tier 3',0),
(11673,14,0,180836,'AQWar - Resource, Cooking, Horde, Tier 4',0),
(11673,15,0,180837,'AQWar - Resource, Cooking, Horde, Tier 5',0),
(11673,16,0,180679,'AQWar - Resource, Cooking/Herbs, Alliance Initial',0),
(11673,17,0,188219,'Armor Breastplate Trim',0),
(11673,18,0,20806,'Ashenvale Moonwell',0),
(11673,19,0,2562,'Baked Bread',0),
(11673,20,0,186250,'Beer Wagon',0),
(11673,21,0,186229,'Beerfest Banner 02',0),
(11673,22,0,965,'Black Smoke - scale 2',0),
(11673,23,0,2692,'Bottle Smoke',0),
(11673,24,0,181144,'Bowl of Fruit',0),
(11673,25,0,181592,'Bowl Wood 02',0),
(11673,26,0,192589,'bowlwood 01',0),
(11673,27,0,180051,'Bread French 01',0),
(11676,0,1,31144,'Training Dummy',1),
(11676,1,0,180050,'Bread French Half',0),
(11676,2,0,2719,'Bubbling Cauldron',0),
(11676,3,0,176157,'BUBBLINGBOWL 01',0),
(11676,4,0,184717,'Cauldron Smoke',0),
(11676,5,0,186143,'Clay Oven',0),
(11676,6,0,26480,'Craghelm''s Plate and Chain',0),
(11676,7,0,193788,'Cultist''s Cauldron',0),
(11676,8,0,183859,'DR SIGNS COOKING',0),
(11676,9,0,181143,'Fish of the Day',0),
(11676,10,0,111094,'Gallina Winery',0),
(11676,11,0,56903,'Good Food',0),
(11676,12,0,2693,'Green Bottle 01',0),
(11676,13,0,2694,'Green Bottle 02',0),
(11676,14,0,180332,'jug 01',0),
(11676,15,0,180333,'jug 02',0),
(11676,16,0,176461,'Meat Rack',0),
(11676,17,0,190731,'Meat Wagon',0),
(11676,18,0,193620,'Meat Wagon Body',0),
(11676,19,0,193619,'Meat Wagon Claw',0),
(11676,20,0,193617,'Meat Wagon Grill',0),
(11676,21,0,183163,'Meat Wagon Hauler',0),
(11676,22,0,193618,'Meat Wagon Roller',0),
(11676,23,0,193616,'Meat Wagon Wheel',0),
(11676,24,0,183164,'Meat Wagon Wrecked 01',0),
(11676,25,0,2698,'Metal Cup 03',0),
(11676,26,0,180049,'Mug 01',0),
(11676,27,0,180048,'Mug Foam 01',0),
(11683,0,0,177232,'Moonwell',1),
(11683,1,0,182078,'Nightelf Glowing Bowl',0),
(11683,2,0,92538,'NIGHTELFSIGN COOKING',0),
(11683,3,0,187376,'NPC Fishing Bobber',0),
(11683,4,0,190507,'Offering Bowl',0),
(11683,5,0,195068,'Offering Bowl',0),
(11683,6,0,180350,'Orc Jug 01',0),
(11683,7,0,180351,'Orc Jug 02',0),
(11683,8,0,193146,'Orc Mug 01',0),
(11683,9,0,182746,'Plate and Mail Protection',0),
(11683,10,0,183868,'Plate Armor & Shields',0),
(11683,11,0,3769,'Potbelly Stove',0),
(11683,12,0,38019,'POTBELLYSTOVEWALL',0),
(11683,13,0,190804,'SC Meat Wagon 01',0),
(11683,14,0,193191,'sc meatwagon 01 broken',0),
(11683,15,0,187363,'Shattered Sun Banner (Hanging scale x3.00)',0),
(11683,16,0,196871,'Silver Covenant Banner',0),
(11683,17,0,180697,'Sparkling Wine',0),
(11683,18,0,2333,'Stranglevine Wine',0),
(11683,19,0,187345,'Sunwell Plateau',0),
(11683,20,0,2148,'The Cheese Cutters',0),
(11683,21,0,369,'Thunder Ale',0),
(11683,22,0,194659,'TRAPPER POTBELLYSTOVE 01',0),
(11683,23,0,32352,'Traveling Fisherman',0),
(11683,24,0,105188,'Trias'' Cheese',0),
(11683,25,0,188370,'Tua''kea''s Fishing Hook',0),
(11683,26,0,188468,'Zort''s Cauldron',0),
(12385,0,1,6491,'Spirit Healer',1),
(12385,1,0,180218,'Arathi Basin Pumpkin',0),
(12385,2,0,186717,'Brewfest Banner',0),
(12385,3,0,186709,'Brewfest Keg',0),
(12385,4,0,186173,'Brewfest Keg Breakable',0),
(12385,5,0,186737,'Brewfest Wagon',0),
(12385,6,0,195069,'Candy Skulls',0),
(12385,7,0,178425,'Christmas Tree',0),
(12385,8,0,178647,'Christmas Tree',0),
(12385,9,0,178558,'Christmas Tree (Large Snowy)',0),
(12385,10,0,178557,'Christmas Tree (Medium)',0),
(12385,11,0,180029,'DARKMOON FAIRE',0),
(12385,12,0,179965,'Darkmoon Faire Banner',0),
(12385,13,0,180005,'Darkmoon Faire Wagon Loaded',0),
(12385,14,0,180036,'Darkmoon Faire Wagon Unloaded',0),
(12385,15,0,180026,'Darkmoon Signpost',0),
(12385,16,0,180771,'Firework Launcher',0),
(12385,17,0,180854,'Firework Rocket, Type 1 Blue',0),
(12385,18,0,180705,'Firework, Show, Type 3 Red',0),
(12385,19,0,180706,'Firework, Show, Type 4 Red',0),
(12385,20,0,180412,'G Candy Bucket 01',0),
(12385,21,0,180405,'G Pumpkin 01',0),
(12526,0,0,189994,'Portal to Stonard',1),
(12526,1,0,180406,'G Pumpkin 02',0),
(12526,2,0,180407,'G Pumpkin 03',0),
(12526,3,0,178437,'G Xmas Wreath',0),
(12526,4,0,180878,'Gun Shop Fireworks Barrel',0),
(12526,5,0,195254,'Hanging, Square, Large - Brewfest',0),
(12526,6,0,195266,'Hanging, Streamer - Brewfest',0),
(12526,7,0,195253,'Hanging, Streamer x3 - Brewfest',0),
(12526,8,0,195255,'Hanging, Tall/Thin, Large - Brewfest',0),
(12526,9,0,195257,'Hanging, Tall/Thin, Small - Brewfest',0),
(12526,10,0,180773,'Lunar New Year Banner Alliance Hanging',0),
(12526,11,0,180774,'Lunar New Year Banner Alliance Hanging 02',0),
(12526,12,0,180777,'Lunar New Year Banner Alliance Standing',0),
(12526,13,0,180775,'Lunar New Year Banner Horde Hanging',0),
(12526,14,0,180776,'Lunar New Year Banner Horde Hanging 02',0),
(12526,15,0,180778,'Lunar New Year Banner Horde Standing',0),
(12526,16,0,180765,'Lunar New Year Lantern Alliance Hanging',0),
(12526,17,0,180766,'Lunar New Year Lantern Alliance Standing',0),
(12526,18,0,180767,'Lunar New Year Lantern Horde Hanging',0),
(12526,19,0,180768,'Lunar New Year Lantern Horde Standing',0),
(12526,20,0,180769,'Lunar New Year Lights',0),
(12526,21,0,180770,'Lunar New Year Lights X 3',0),
(16068,0,0,12665,'Cooking Table',1),
(16068,1,0,186327,'Pumpkin Table',0),
(16068,2,0,195256,'Standing, Exterior, Medium - Brewfest',0),
(16068,3,0,187191,'Standing, Exterior, Medium - Xmas',0),
(16068,4,0,195264,'Standing, Interior, Medium - Brewfest',0),
(16068,5,0,195260,'Standing, Interior, Small - Brewfest',0),
(16068,6,0,195265,'Standing, Large - Brewfest',0),
(16068,7,0,181086,'Valentine Arch',0),
(16068,8,0,178428,'Xmas Gift 01',0),
(16068,9,0,178429,'Xmas Gift 02',0),
(16068,10,0,178430,'Xmas Gift 03',0),
(16068,11,0,178431,'Xmas Gift 04',0),
(16068,12,0,178432,'Xmas Gift 05',0),
(16068,13,0,178433,'Xmas Gift 06',0),
(16068,14,0,178438,'Xmas lights',0),
(16068,15,0,178624,'Xmas lights X 3',0),
(16068,16,0,178434,'Xmas Stocking 01',0),
(16068,17,0,178435,'Xmas Stocking 02',0),
(16068,18,0,178436,'Xmas Stocking 03',0),
(16068,19,0,178426,'Xmas Tree Large Horde 01',0),
(16069,0,0,186143,'Clay Oven',1),
(16069,1,0,183890,'Alchemy & Herbalism',0),
(16069,2,0,183848,'Alchemy Lab',0),
(16069,3,0,186019,'ANCIENT D BRAIZER BLUE LOWBATCH',0),
(16069,4,0,185979,'ANCIENT D BRAIZER BLUE SHORTSMOKE',0),
(16069,5,0,190550,'Ancient Dirt Mound',0),
(16069,6,0,183969,'Auchindoun Bridge FX',0),
(16069,7,0,183968,'Auchindoun Bridge Spirits Flying',0),
(16069,8,0,183855,'Auction House',0),
(16069,9,0,182751,'Blades by Rahein',0),
(16069,10,0,181900,'Brightwing Bows',0),
(16069,11,0,188062,'COLLECTORTUBES STRAIGHT STATES',0),
(16069,12,0,183850,'Consortium Transporter',0),
(16069,13,0,183328,'Destroyed Doom Walker',0),
(16069,14,0,184590,'Diagnostic Frame',0),
(16069,15,0,182092,'Duskwither Spire Power Source Satellite',0),
(16069,16,0,182120,'Elemental Rift',0),
(16069,17,0,182739,'Enchants Enhanced',0),
(16069,18,0,184807,'Ethereal Particles',0),
(16069,19,0,184998,'Ethereum Prison Base (Global)',0),
(16069,20,0,183865,'Guild Master & Tabards',0),
(16069,21,0,183893,'Hall of the Mystics',0),
(16069,22,0,190596,'Heart of the Ancients',0),
(16069,23,0,186805,'Hippogryph Nest',0),
(16069,24,0,183866,'Hunters'' Sanctum',0),
(16069,25,0,184452,'Imprisoned Voidwalker',0),
(16069,26,0,182752,'Keelen''s Trustworthy Tailoring',0),
(16070,0,0,12665,'Cooking Table',1),
(16070,1,0,184072,'Legion Communicator',0),
(16070,2,0,183862,'Mining & Smithing',0),
(16070,3,0,184070,'Nexus-Prince Haramad''s Teleporter',0),
(16070,4,0,184447,'Protectorate Tracer',0),
(16070,5,0,183867,'Ring of Arms',0),
(16070,6,0,181909,'Royal Exchange Bank',0),
(16070,7,0,184464,'Salaadin''s Cover',0),
(16070,8,0,181616,'School of Red Snapper',0),
(16070,9,0,182737,'Silvermoon Alchemy',0),
(16070,10,0,182753,'Silvermoon City Inn',0),
(16070,11,0,185292,'Skar''this''s Prison',0),
(16070,12,0,192124,'Smoldering Scrap',0),
(16070,13,0,182748,'Students of Shadow',0),
(16070,14,0,181934,'Suncrown Village',0),
(16070,15,0,184378,'Surveying Marker',0),
(16070,16,0,182082,'The Ark of Ssslith',0),
(16070,17,0,181691,'The Exodar',0),
(16070,18,0,187383,'The Frozen Heart of Isuldof',0),
(16070,19,0,185170,'The Mark of Kael''Thas',0),
(16070,20,0,181967,'The Sunspire',0),
(16070,21,0,184842,'Torgos''s Bane',0),
(16070,22,0,183891,'Vindicators'' Sanctum',0),
(16070,23,0,181755,'Vision of the Future',0),
(16070,24,0,182740,'Wayfarer''s Rest',0),
(16070,25,0,188089,'Wreckage C',0),
(16070,26,0,188467,'Zort''s Volatile Concoction',0),
(16071,0,0,188604,'Mailbox: Northrend (Dragonblight)',1),
(16071,1,0,16394,'Ancient Flame',0),
(16071,2,0,2332,'Barbequed Buzzard Wings',0),
(16071,3,0,186725,'Blue Ragdoll',0),
(16071,4,0,25338,'Cathedral Square',0),
(16071,5,0,25355,'Cathedral Square',0),
(16071,6,0,2159,'City Hall',0),
(16071,7,0,19421,'Covered Bridge',0),
(16071,8,0,19422,'Darkshire Entrance',0),
(16071,9,0,180033,'Dog House',0),
(16071,10,0,2161,'Duncan''s Textiles',0),
(16071,11,0,183266,'Duskwood Foot Locker 01',0),
(16071,12,0,2163,'Essential Components',0),
(16071,13,0,2146,'Everyday Merchandise',0),
(16071,14,0,19875,'Fresh Lion Carcass',0),
(16071,15,0,19866,'Front Door',0),
(16071,16,0,2697,'General Candelabra 01',0),
(16071,17,0,160846,'GENERALCHURCHPEW 01',0),
(16071,18,0,192946,'Golden Goblet (Cosmetic)',0),
(16071,19,0,186723,'Green Ragdoll',0),
(16071,20,0,182254,'Gryphon Roost',0),
(16071,21,0,188223,'Hanging Cloak Red',0),
(16071,22,0,25334,'Industrial District',0),
(16071,23,0,180054,'Kerri''s Weights',0),
(16071,24,0,187330,'Lexicon of Power',0),
(16071,25,0,1764,'Locked ball and chain',0),
(16074,0,1,31144,'Training Dummy',1),
(16074,1,0,25348,'Mage Quarter',0),
(16074,2,0,386,'Metal Mace',0),
(16074,3,0,164758,'Miblon''s Bait',0),
(16074,4,0,89,'Northshire Abbey',0),
(16074,5,0,19420,'Ogremound 9',0),
(16074,6,0,193747,'oildrum 01',0),
(16074,7,0,2152,'Pig and Whistle Tavern',0),
(16074,8,0,186621,'ragdoll 01',0),
(16074,9,0,186724,'Red Ragdoll',0),
(16074,10,0,16395,'Seal Destroyed Flame',0),
(16074,11,0,81,'Sentinel Hill',0),
(16074,12,0,187117,'Stairway to Mercy',0),
(16074,13,0,2145,'Stormwind Counting House',0),
(16074,14,0,2151,'Thane''s Boots and Shoulderpads',0),
(16074,15,0,2138,'The Empty Quiver',0),
(16074,16,0,25341,'The Park',0),
(16074,17,0,25342,'The Park',0),
(16074,18,0,1675,'The Sepulcher',0),
(16074,19,0,2149,'The Seven Deadly Venoms',0),
(16074,20,0,1587,'Turkey Leg',0),
(16074,21,0,35758,'Unfinished Mace',0),
(16074,22,0,180210,'Uther''s Human Tribute',0),
(16074,23,0,190802,'West Fall Grain Silo Destroyed 01',0),
(16074,24,0,186722,'Yellow Ragdoll',0),
(16075,0,0,176296,'Portal to Stormwind',1),
(16075,1,0,180039,'Animal Trainer Tent',0),
(16075,2,0,190666,'Apothecary Tent',0),
(16075,3,0,184696,'Apothecary Zelana Tent',0),
(16075,4,0,181254,'Argent Dawn Buffer Tent',0),
(16075,5,0,186682,'Brewfest Beer Tent',0),
(16075,6,0,186680,'Brewfest Canopy',0),
(16075,7,0,186681,'Brewfest Food Tent',0),
(16075,8,0,188020,'Camp Banner',0),
(16075,9,0,181307,'Camp Mug',0),
(16075,10,0,181301,'Camp Pavilion',0),
(16075,11,0,188021,'Camp Pavilion',0),
(16075,12,0,179966,'Carnival Tent',0),
(16075,13,0,193468,'excavationtentruined 01',0),
(16075,14,0,193469,'excavationtentruined 02',0),
(16075,15,0,190213,'FK Tent 01',0),
(16075,16,0,190217,'FK Tent 04',0),
(16075,17,0,180031,'Food Tent',0),
(16075,18,0,180030,'Fortune Teller''s Tent',0),
(16075,19,0,188179,'Goblin Tent 01',0),
(16075,20,0,188180,'Goblin Tent 02',0),
(16075,21,0,188181,'Goblin Tent 03',0),
(16075,22,0,188182,'Goblin Tent 04',0),
(16075,23,0,188183,'Goblin Tent 05',0),
(16075,24,0,188184,'Goblin Tent 06',0),
(16076,0,0,172911,'The Black Anvil',1),
(16076,1,0,188185,'Goblin Tent 07',0),
(16076,2,0,193130,'he tent 01',0),
(16076,3,0,191784,'Horde Pavilion',0),
(16076,4,0,192920,'hu tarp boxes',0),
(16076,5,0,194839,'hu tent 01',0),
(16076,6,0,192925,'hu tent 02',0),
(16076,7,0,184592,'Human Tent Medium',0),
(16076,8,0,19637,'Human Vendor Tent',0),
(16076,9,0,181244,'iCoke Tent',0),
(16076,10,0,184593,'Large Tent',0),
(16076,11,0,201388,'Night Elf Tent 02 x.8',0),
(16076,12,0,193217,'Orc Tent',0),
(16076,13,0,193218,'Orc Tent',0),
(16076,14,0,193219,'Orc Tent',0),
(16076,15,0,193127,'orctent 02',0),
(16076,16,0,185001,'Shadow Council Tent 01',0),
(16076,17,0,185002,'Shadow Council Tent 02',0),
(16076,18,0,183355,'Shattrath Soup Tent',0),
(16076,19,0,180032,'Souvenir Tent',0),
(16076,20,0,180042,'Target Practice Tent',0),
(16076,21,0,180034,'Ticket Master Tent',0);
INSERT INTO zerocraft_bscroll_items (item_entry, idx, kind, entry, name, useful) VALUES
(16076,22,0,186742,'Water Hut 01',0),
(16076,23,0,186743,'Water Hut 02',0),
(16077,0,0,143981,'Mailbox: Orc (Orgrimmar)',1),
(16077,1,0,183996,'Amadi Scroll',0),
(16077,2,0,183199,'AO Signpostpointer 01',0),
(16077,3,0,191312,'Argent Tome',0),
(16077,4,0,34357,'BerryFizz Potions and Mixed Drinks',0),
(16077,5,0,193825,'Book Medium Open 02',0),
(16077,6,0,182100,'DR Signpost Sign ancient',0),
(16077,7,0,183875,'DR SIGNS BOOK',0),
(16077,8,0,183873,'DR SIGNS HERBALISM',0),
(16077,9,0,183864,'DR SIGNS TAILOR',0),
(16077,10,0,183861,'DR SIGNS TAVERN',0),
(16077,11,0,2695,'General Book Stack Short 01',0),
(16077,12,0,178439,'Globe of Scrying',0),
(16077,13,0,187312,'HU Signpost Sign Northrend',0),
(16077,14,0,176967,'Human Sign Post Pointer 01',0),
(16077,15,0,1771,'Human Sign Post Pointer 03',0),
(16077,16,0,2023,'Human Sign Post Pointer 05',0),
(16077,17,0,194893,'inscription scroll rolledblue',0),
(16077,18,0,194894,'Inscription Scroll Sealed 01',0),
(16077,19,0,194895,'Inscription Scroll Sealed 02',0),
(16077,20,0,191675,'Langrom''s Leather & Links',0),
(16078,0,0,178831,'Meeting Stone (Plaguelands)',1),
(16078,1,0,12351,'Night Elf Sign Post Pointer 01',0),
(16078,2,0,92526,'NIGHTELFSIGN ALCHEMIST',0),
(16078,3,0,92529,'NIGHTELFSIGN ENCHANTING',0),
(16078,4,0,92544,'NIGHTELFSIGN FLETCHER',0),
(16078,5,0,92524,'NIGHTELFSIGN NOBLEHOUSE',0),
(16078,6,0,92532,'NIGHTELFSIGN STAVES',0),
(16078,7,0,92533,'NIGHTELFSIGN TAILOR',0),
(16078,8,0,148423,'NIGHTELFSIGN TAVERN',0),
(16078,9,0,181310,'Outland Map',0),
(16078,10,0,190353,'Poster Knife',0),
(16078,11,0,187254,'Rolled Scroll',0),
(16078,12,0,193133,'Scroll A 03',0),
(16078,13,0,181447,'Signaling Gem',0),
(16078,14,0,180910,'Starsong Scroll',0),
(16078,15,0,185581,'The Book of the Raven',0),
(16078,16,0,202889,'Troll Book 1',0),
(16078,17,0,33998,'UNDERCITYSIGNPOSTPOINTER',0),
(16078,18,0,186479,'VR Sign Post Sign 01',0),
(16078,19,0,182283,'Zangar Signpostpointer 01',0),
(16079,0,0,176497,'Portal to Ironforge',1),
(16079,1,0,18603,'Ancient Statuette',0),
(16079,2,0,191446,'Dalaran Fountain',0),
(16079,3,0,20724,'Dor''Danil Pillar',0),
(16079,4,0,190522,'Drakkari Pedestal',0),
(16079,5,0,185491,'Emerald Dream Fountain Tree 01',0),
(16079,6,0,185496,'Emerald Dream Fountain Tree 05',0),
(16079,7,0,19507,'Fountain',0),
(16079,8,0,19397,'Goblin Statue',0),
(16079,9,0,160839,'Gor''tesh''s Lopped Off Head',0),
(16079,10,0,185146,'Heart of Fury Pedestal',0),
(16079,11,0,19483,'Holy Spring Well',0),
(16079,12,0,186322,'Hyal Family Monument',0),
(16079,13,0,190023,'ID Pillar Base',0),
(16079,14,0,192948,'Jade Statue (Cosmetic)',0),
(16079,15,0,19467,'Karazahn Pedestal',0),
(16079,16,0,19468,'Karazahn Pedestal 2',0),
(16079,17,0,202437,'Lavaman Pillars (Chained)',0),
(16080,0,0,176501,'Portal to Undercity',1),
(16080,1,0,179869,'Buff 2 Billboard',0),
(16080,2,0,186666,'Frozen Waterfall',0),
(16080,3,0,193029,'hu crane dock',0),
(16080,4,0,188190,'Jewelcraft Grinder',0),
(16080,5,0,186218,'Moon Well',0),
(16080,6,0,19552,'Oracle Glade Moonwell',0),
(16080,7,0,19551,'Pools of Arlithrien Moonwell',0),
(16080,8,0,181145,'Roast Boar Platter',0),
(16080,9,0,178764,'Rope Line',0),
(16080,10,0,178765,'Rope Line Pole',0),
(16080,11,0,190226,'Row Boat 01',0),
(16080,12,0,19549,'Shadowglen Moonwell',0),
(16080,13,0,19484,'Small Boat',0),
(16080,14,0,179868,'Speed Buff Billboard',0),
(16080,15,0,19550,'Starbreeze Moonwell',0),
(16080,16,0,186770,'Sunken Boat',0),
(16080,17,0,188475,'Telestra Energy Well',0),
(16080,18,0,19462,'Water Basin',0),
(16080,19,0,179665,'Water Elemental Rift',0),
(16080,20,0,106528,'Water Manifestation Effect',0),
(16080,21,0,179975,'Water Trough Small',0),
(16080,22,0,2139,'Weller''s Arsenal',0),
(16081,0,0,177232,'Moonwell',1),
(16081,1,0,173078,'Arms of Legend',0),
(16081,2,0,173216,'Bank of Orgrimmar',0),
(16081,3,0,190656,'Bowels and Brains',0),
(16081,4,0,179694,'Death Post',0),
(16081,5,0,186813,'Eagle Nest',0),
(16081,6,0,3202,'Grom''gol',0),
(16081,7,0,187983,'High Quality Fur',0),
(16081,8,0,173020,'Jandi''s Arboretum',0),
(16081,9,0,173018,'Magar''s Cloth Goods',0),
(16081,10,0,3893,'Mighty Blaze',0),
(16081,11,0,172950,'Mighty Blaze',0),
(16081,12,0,172998,'Mighty Blaze',0),
(16081,13,0,173000,'Mighty Blaze',0),
(16081,14,0,33360,'Morag''s Brew',0),
(16081,15,0,173080,'Orgrimmar Bowyer',0),
(16081,16,0,188252,'Recovered Horde Armaments',0),
(16081,17,0,173081,'Red Canyon Mining',0),
(16081,18,0,6289,'Smoldering Blaze',0),
(16081,19,0,173006,'Spiritfury Reagents',0),
(16081,20,0,182255,'Wyvern Roost',0),
(16086,0,0,187316,'Mailbox: Northrend (Borean Tundra)',1),
(16086,1,1,15475,'Beetle',0),
(16086,2,1,7385,'Bombay Cat',0),
(16086,3,1,620,'Chicken',0),
(16086,4,1,2442,'Cow',0),
(16086,5,1,883,'Deer',0),
(16086,6,1,4166,'Gazelle',0),
(16086,7,1,5951,'Hare',0),
(16086,8,1,2620,'Prairie Dog',0),
(16086,9,1,721,'Rabbit',0),
(16086,10,1,1933,'Sheep',0),
(16086,11,1,2914,'Snake',0),
(16086,12,1,1412,'Squirrel',0),
(16086,13,1,10685,'Swine',0),
(16086,14,1,1420,'Toad',0),
(16086,15,1,7386,'White Kitten',0),
(16102,0,0,176499,'Portal to Orgrimmar',1),
(16102,1,0,20820,'Giant Sea Turtle',0),
(16102,2,0,20821,'Giant Turtle',0),
(16102,3,0,20816,'Guard Tower',0),
(16102,4,0,20817,'Holding Pen',0),
(16102,5,0,20822,'Landing Pad',0),
(16102,6,0,20811,'MD Goldmine 1Room',0),
(16102,7,0,20819,'Moon Well 2',0),
(16102,8,0,184363,'Orc Barracks',0),
(16102,9,0,20823,'Player Housing',0),
(16102,10,0,186239,'Ship, Icebreaker (Stormbreaker)',0),
(16102,11,0,20827,'Stormwind City',0),
(16102,12,0,48797,'Theramore Transport',0),
(16102,13,0,187263,'Transport Vrykul Large',0),
(16102,14,0,188513,'Zeppelin (The Wild Wench)',0),
(16103,0,0,142109,'Mailbox: Night Elf (Darnassus)',1),
(16103,1,0,177185,'Abandon hope, all ye who enter here.',0),
(16103,2,0,26487,'Barim''s Reagents',0),
(16103,3,0,190884,'Excavation Barrier 02 Pv PCollision',0),
(16103,4,0,180007,'Excavation Stake',0),
(16103,5,0,32350,'Finespindle''s Leather Goods',0),
(16103,6,0,26483,'Fizzlespinner''s General Goods',0),
(16103,7,0,193150,'mallet 01',0),
(16103,8,0,181591,'Platter Gold Ornate 02',0),
(16103,9,0,32353,'Springspindle''s Gadgets',0),
(16103,10,0,26498,'The Bronze Kettle',0),
(16103,11,0,32354,'Things That Go Boom!',0),
(16103,12,0,123215,'This Way',0),
(16103,13,0,26488,'Timberline Arms',0),
(16103,14,0,192522,'Vanguard Infirmary',0),
(16105,0,0,1915,'Cooking Fire',1),
(16105,1,0,50486,'Bena''s Alchemy',0),
(16105,2,0,177266,'Bridge to Elder Rise',0),
(16105,3,0,177268,'Bridge to Hunter Rise',0),
(16105,4,0,177265,'Bridge to Spirit Rise',0),
(16105,5,0,50485,'Dawnstrider Enchanters',0),
(16105,6,0,180209,'Grom''s Tauren Tribute',0),
(16105,7,0,50487,'Holistic Herbalism',0),
(16105,8,0,50493,'Karn''s Smithy',0),
(16105,9,0,185591,'Ogre Drum',0),
(16105,10,0,152583,'TAURENDRUMMED 01',0),
(16105,11,0,50492,'Thunder Bluff Bank',0),
(16106,0,0,172911,'The Black Anvil',1),
(16106,1,0,194820,'Confession Screen',0),
(16106,2,0,178224,'Dire Pool',0),
(16106,3,0,92537,'First Aid',0),
(16106,4,0,92528,'General Goods',0),
(16106,5,0,12893,'Grove of the Ancients',0),
(16106,6,0,180213,'Uther''s Night Elf Tribute',0),
(16106,7,0,153157,'Charred Dark Iron Remains',0),
(16106,8,0,153160,'Charred Dark Iron Remains',0),
(16106,9,0,153158,'Mutilated Dark Iron Remains',0),
(16106,10,0,153159,'Mutilated Dark Iron Remains',0),
(16106,11,0,190740,'Porta-pew',0),
(16106,12,0,180653,'Treasure Marker',0),
(16106,13,0,58597,'Bat Handler',0),
(16106,14,0,58618,'Bow Merchant',0),
(16106,15,0,58598,'General Goods',0),
(16106,16,0,58629,'Staff Merchant',0),
(16106,17,0,178146,'Gurda''s Shredder',0),
(16106,18,0,181631,'Robotron Control Panel',0),
(16106,19,0,188697,'Shredder Suit',0),
(16106,20,0,185222,'Challenge From the Horde',0),
(16106,21,0,178672,'Consuming Flames',0),
(16106,22,0,202733,'Teleporter Pad',0),
(16106,23,0,19441,'Dirt Mound',0),
(16107,0,0,1744,'Anvil',1),
(16107,1,0,202438,'Lavaman Pillars (Unchained)',0),
(16107,2,0,19460,'Lion Statue',0),
(16107,3,0,19410,'Lothar Statue',0),
(16107,4,0,19509,'Mage Statue',0),
(16107,5,0,187116,'Monument to the Fallen',0),
(16107,6,0,19506,'Mountain King Statue',0),
(16107,7,0,182212,'Nazzivus Monument',0),
(16107,8,0,20818,'Night Elf Moon Well',0),
(16107,9,0,19416,'Rock Arch',0),
(16107,10,0,19459,'Ruined Fountain',0),
(16107,11,0,187702,'Shattrath Battlemaster Pedestal',0),
(16107,12,0,19485,'Snake Statue',0),
(16107,13,0,19510,'Spearman Statue',0),
(16107,14,0,187678,'Statue Eye',0),
(16107,15,0,50489,'Thunderhorn''s Archery',0),
(16107,16,0,180386,'TROLLRUINSGONG 03',0);
DELETE FROM item_template WHERE entry = 4431;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4431 SET z.entry = 4431, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4451;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4451 SET z.entry = 4451, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4452;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4452 SET z.entry = 4452, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4523;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4523 SET z.entry = 4523, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4573;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4573 SET z.entry = 4573, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4578;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4578 SET z.entry = 4578, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4579;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4579 SET z.entry = 4579, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4754;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4754 SET z.entry = 4754, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4839;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4839 SET z.entry = 4839, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4842;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4842 SET z.entry = 4842, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4868;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4868 SET z.entry = 4868, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4884;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4884 SET z.entry = 4884, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4885;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4885 SET z.entry = 4885, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4889;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4889 SET z.entry = 4889, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 4927;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 4927 SET z.entry = 4927, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5171;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5171 SET z.entry = 5171, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5228;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5228 SET z.entry = 5228, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5331;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5331 SET z.entry = 5331, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5365;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5365 SET z.entry = 5365, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5372;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5372 SET z.entry = 5372, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5384;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5384 SET z.entry = 5384, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5407;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5407 SET z.entry = 5407, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5434;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5434 SET z.entry = 5434, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5436;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5436 SET z.entry = 5436, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5438;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5438 SET z.entry = 5438, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5449;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5449 SET z.entry = 5449, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5450;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5450 SET z.entry = 5450, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5453;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5453 SET z.entry = 5453, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5454;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5454 SET z.entry = 5454, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5515;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5515 SET z.entry = 5515, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5531;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5531 SET z.entry = 5531, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5651;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5651 SET z.entry = 5651, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5652;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5652 SET z.entry = 5652, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 5653;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 5653 SET z.entry = 5653, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 6090;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 6090 SET z.entry = 6090, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 6297;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 6297 SET z.entry = 6297, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 6301;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 6301 SET z.entry = 6301, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 6455;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 6455 SET z.entry = 6455, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 6639;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 6639 SET z.entry = 6639, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 8589;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 8589 SET z.entry = 8589, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 8590;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 8590 SET z.entry = 8590, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 9464;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 9464 SET z.entry = 9464, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 10594;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 10594 SET z.entry = 10594, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11132;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11132 SET z.entry = 11132, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11443;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11443 SET z.entry = 11443, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11663;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11663 SET z.entry = 11663, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11664;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11664 SET z.entry = 11664, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11666;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11666 SET z.entry = 11666, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11667;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11667 SET z.entry = 11667, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11670;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11670 SET z.entry = 11670, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11671;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11671 SET z.entry = 11671, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11672;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11672 SET z.entry = 11672, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11673;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11673 SET z.entry = 11673, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11676;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11676 SET z.entry = 11676, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 11683;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 11683 SET z.entry = 11683, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 12385;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 12385 SET z.entry = 12385, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 12526;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 12526 SET z.entry = 12526, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16068;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16068 SET z.entry = 16068, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16069;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16069 SET z.entry = 16069, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16070;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16070 SET z.entry = 16070, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16071;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16071 SET z.entry = 16071, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16074;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16074 SET z.entry = 16074, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16075;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16075 SET z.entry = 16075, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16076;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16076 SET z.entry = 16076, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16077;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16077 SET z.entry = 16077, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16078;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16078 SET z.entry = 16078, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16079;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16079 SET z.entry = 16079, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16080;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16080 SET z.entry = 16080, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16081;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16081 SET z.entry = 16081, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16086;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16086 SET z.entry = 16086, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16102;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16102 SET z.entry = 16102, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16103;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16103 SET z.entry = 16103, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16105;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16105 SET z.entry = 16105, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16106;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16106 SET z.entry = 16106, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16107;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16107 SET z.entry = 16107, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DROP TEMPORARY TABLE IF EXISTS zc_b;
-- boss loot: every boss that drops NPC scrolls also has a 60% chance of one Builder's Scroll
-- (inside the scroll roll: green 50%, rare 30%, epic 15%, legendary 5%)
DELETE FROM reference_loot_template WHERE Entry = 911050;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) VALUES
(911050,4431,0,1.282,0,1,1,1,1,'Builder''s Scroll: Odds and Ends I'),
(911050,4451,0,1.875,0,1,1,1,1,'Builder''s Scroll: Odds and Ends II'),
(911050,4452,0,1.282,0,1,1,1,1,'Builder''s Scroll: Odds and Ends III'),
(911050,4523,0,1.282,0,1,1,1,1,'Builder''s Scroll: Odds and Ends IV'),
(911050,4573,0,1.875,0,1,1,1,1,'Builder''s Scroll: Odds and Ends V'),
(911050,4578,0,1.282,0,1,1,1,1,'Builder''s Scroll: Odds and Ends VI'),
(911050,4579,0,1.282,0,1,1,1,1,'Builder''s Scroll: Odds and Ends VII'),
(911050,4754,0,1.875,0,1,1,1,1,'Builder''s Scroll: Odds and Ends VIII'),
(911050,4839,0,1.282,0,1,1,1,1,'Builder''s Scroll: Walls and War I'),
(911050,4842,0,1.282,0,1,1,1,1,'Builder''s Scroll: Walls and War II'),
(911050,4868,0,1.282,0,1,1,1,1,'Builder''s Scroll: Walls and War III'),
(911050,4884,0,1.282,0,1,1,1,1,'Builder''s Scroll: Walls and War IV'),
(911050,4885,0,1.875,0,1,1,1,1,'Builder''s Scroll: Walls and War V'),
(911050,4889,0,1.875,0,1,1,1,1,'Builder''s Scroll: Walls and War VI'),
(911050,4927,0,1.875,0,1,1,1,1,'Builder''s Scroll: Walls and War VII'),
(911050,5171,0,1.282,0,1,1,1,1,'Builder''s Scroll: Walls and War VIII'),
(911050,5228,0,1.875,0,1,1,1,1,'Builder''s Scroll: Fire and Light I'),
(911050,5331,0,1.875,0,1,1,1,1,'Builder''s Scroll: Fire and Light II'),
(911050,5365,0,1.875,0,1,1,1,1,'Builder''s Scroll: Fire and Light III'),
(911050,5372,0,1.282,0,1,1,1,1,'Builder''s Scroll: Fire and Light IV'),
(911050,5384,0,1.875,0,1,1,1,1,'Builder''s Scroll: Fire and Light V'),
(911050,5407,0,0.417,0,1,1,1,1,'Builder''s Scroll: Fire and Light VI'),
(911050,5434,0,1.875,0,1,1,1,1,'Builder''s Scroll: Arcane and Magic I'),
(911050,5436,0,1.282,0,1,1,1,1,'Builder''s Scroll: Arcane and Magic II'),
(911050,5438,0,1.282,0,1,1,1,1,'Builder''s Scroll: Arcane and Magic III'),
(911050,5449,0,1.875,0,1,1,1,1,'Builder''s Scroll: Arcane and Magic IV'),
(911050,5450,0,1.282,0,1,1,1,1,'Builder''s Scroll: Arcane and Magic V'),
(911050,5453,0,0.417,0,1,1,1,1,'Builder''s Scroll: Crates and Cargo I'),
(911050,5454,0,0.417,0,1,1,1,1,'Builder''s Scroll: Crates and Cargo II'),
(911050,5515,0,1.282,0,1,1,1,1,'Builder''s Scroll: Crates and Cargo III'),
(911050,5531,0,0.417,0,1,1,1,1,'Builder''s Scroll: Crates and Cargo IV'),
(911050,5651,0,0.417,0,1,1,1,1,'Builder''s Scroll: Crates and Cargo V'),
(911050,5652,0,1.282,0,1,1,1,1,'Builder''s Scroll: Graveyard and Crypt I'),
(911050,5653,0,1.282,0,1,1,1,1,'Builder''s Scroll: Graveyard and Crypt II'),
(911050,6090,0,0.417,0,1,1,1,1,'Builder''s Scroll: Graveyard and Crypt III'),
(911050,6297,0,1.282,0,1,1,1,1,'Builder''s Scroll: Graveyard and Crypt IV'),
(911050,6301,0,1.282,0,1,1,1,1,'Builder''s Scroll: Furniture I'),
(911050,6455,0,1.282,0,1,1,1,1,'Builder''s Scroll: Furniture II'),
(911050,6639,0,1.282,0,1,1,1,1,'Builder''s Scroll: Furniture III'),
(911050,8589,0,1.282,0,1,1,1,1,'Builder''s Scroll: Furniture IV'),
(911050,8590,0,1.282,0,1,1,1,1,'Builder''s Scroll: Nature and Farm I'),
(911050,9464,0,1.875,0,1,1,1,1,'Builder''s Scroll: Nature and Farm II'),
(911050,10594,0,1.282,0,1,1,1,1,'Builder''s Scroll: Nature and Farm III'),
(911050,11132,0,1.282,0,1,1,1,1,'Builder''s Scroll: Nature and Farm IV'),
(911050,11443,0,1.282,0,1,1,1,1,'Builder''s Scroll: Northrend Frontier I'),
(911050,11663,0,1.875,0,1,1,1,1,'Builder''s Scroll: Northrend Frontier II'),
(911050,11664,0,1.282,0,1,1,1,1,'Builder''s Scroll: Northrend Frontier III'),
(911050,11666,0,1.875,0,1,1,1,1,'Builder''s Scroll: Northrend Frontier IV'),
(911050,11667,0,1.875,0,1,1,1,1,'Builder''s Scroll: Workshop and Mine I'),
(911050,11670,0,0.417,0,1,1,1,1,'Builder''s Scroll: Workshop and Mine II'),
(911050,11671,0,1.282,0,1,1,1,1,'Builder''s Scroll: Workshop and Mine III'),
(911050,11672,0,1.875,0,1,1,1,1,'Builder''s Scroll: Workshop and Mine IV'),
(911050,11673,0,1.875,0,1,1,1,1,'Builder''s Scroll: Kitchen and Tavern I'),
(911050,11676,0,1.282,0,1,1,1,1,'Builder''s Scroll: Kitchen and Tavern II'),
(911050,11683,0,1.282,0,1,1,1,1,'Builder''s Scroll: Kitchen and Tavern III'),
(911050,12385,0,1.875,0,1,1,1,1,'Builder''s Scroll: Holiday Festival I'),
(911050,12526,0,0.417,0,1,1,1,1,'Builder''s Scroll: Holiday Festival II'),
(911050,16068,0,1.282,0,1,1,1,1,'Builder''s Scroll: Holiday Festival III'),
(911050,16069,0,1.282,0,1,1,1,1,'Builder''s Scroll: Outland Frontier I'),
(911050,16070,0,1.282,0,1,1,1,1,'Builder''s Scroll: Outland Frontier II'),
(911050,16071,0,1.875,0,1,1,1,1,'Builder''s Scroll: Human Township I'),
(911050,16074,0,1.282,0,1,1,1,1,'Builder''s Scroll: Human Township II'),
(911050,16075,0,0.417,0,1,1,1,1,'Builder''s Scroll: Camp and Tents I'),
(911050,16076,0,1.282,0,1,1,1,1,'Builder''s Scroll: Camp and Tents II'),
(911050,16077,0,1.875,0,1,1,1,1,'Builder''s Scroll: Books and Signs I'),
(911050,16078,0,1.875,0,1,1,1,1,'Builder''s Scroll: Books and Signs II'),
(911050,16079,0,0.417,0,1,1,1,1,'Builder''s Scroll: Statues and Ruins I'),
(911050,16080,0,0.417,0,1,1,1,1,'Builder''s Scroll: Docks and Water'),
(911050,16081,0,1.282,0,1,1,1,1,'Builder''s Scroll: Orcish Warcamp'),
(911050,16086,0,1.875,0,1,1,1,1,'Builder''s Scroll: Animals'),
(911050,16102,0,0.417,0,1,1,1,1,'Builder''s Scroll: Grand Structures'),
(911050,16103,0,1.875,0,1,1,1,1,'Builder''s Scroll: Dwarven Hold'),
(911050,16105,0,1.282,0,1,1,1,1,'Builder''s Scroll: Tauren Village'),
(911050,16106,0,1.282,0,1,1,1,1,'Builder''s Scroll: Racial Relics'),
(911050,16107,0,1.282,0,1,1,1,1,'Builder''s Scroll: Statues and Ruins II');
DELETE FROM creature_loot_template WHERE Reference = 911050;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT Entry, 911050, 911050, 60, 0, 1, 0, 1, 1, 'ZeroCraft Builder scroll' FROM creature_loot_template WHERE Reference = 911000;
SELECT quality, COUNT(*) AS scrolls FROM zerocraft_bscroll GROUP BY quality;
SELECT COUNT(DISTINCT Entry) AS bosses_with_builder_scrolls FROM creature_loot_template WHERE Reference = 911050;

-- ZeroCraft: extra Builder's Scrolls made from the one-of-a-kind objects that were standing around the old world
-- (books, plaques, graves, wanted posters, ribbon pole, wind stones...). Same rules: one useful thing + decorations.
USE acore_world;
DELETE FROM zerocraft_bscroll WHERE item_entry IN (16108,16109,16173,16174,16175);
DELETE FROM zerocraft_bscroll_items WHERE item_entry IN (16108,16109,16173,16174,16175);
INSERT INTO zerocraft_bscroll (item_entry, quality, name, description) VALUES
(16108,3,'Builder''s Scroll: Notices and Wanted Posters','Builds Mailbox: Human (Stormwind) and 24 decorations. Click a spot on the ground.'),
(16109,4,'Builder''s Scroll: Graves and Remembrance','Builds Spirit Healer and 19 decorations. Click a spot on the ground.'),
(16173,3,'Builder''s Scroll: Festival and Fire','Builds Dancer and 20 decorations. Click a spot on the ground.'),
(16174,5,'Builder''s Scroll: Crystals and Wind Stones','Builds Portal to Theramore and 27 decorations. Click a spot on the ground.'),
(16175,2,'Builder''s Scroll: Wilds and Oddities','Builds Moonwell and 34 decorations. Click a spot on the ground.');
INSERT INTO zerocraft_bscroll_items (item_entry, idx, kind, entry, name, useful) VALUES
(16108,0,0,142075,'Mailbox: Human (Stormwind)',1),
(16108,1,0,179707,'Military Ranks of the Horde & Alliance',0),
(16108,2,0,21042,'Theramore Guard Badge',0),
(16108,3,0,179827,'Wanted/Missing/Lost & Found',0),
(16108,4,0,2083,'Bloodsail Correspondence',0),
(16108,5,0,186426,'Wanted Poster',0),
(16108,6,0,164868,'KILL ON SIGHT',0),
(16108,7,0,256,'WANTED',0),
(16108,8,0,3972,'WANTED',0),
(16108,9,0,2713,'Wanted Board',0),
(16108,10,0,176115,'Wanted Poster - Arnak Grimtotem',0),
(16108,11,0,177226,'Book "Soothsaying for Dummies"',0),
(16108,12,0,179735,'Alliance Military Ranks',0),
(16108,13,0,1726,'Missing: Corporal Keeshan',0),
(16108,14,0,60,'Wanted: Gath''Ilzogg',0),
(16108,15,0,175926,'Mrs. Dalson''s Diary',0),
(16108,16,0,175894,'Janice''s Parcel',0),
(16108,17,0,175924,'Locked Cabinet',0),
(16108,18,0,177667,'Torn Scroll',0),
(16108,19,0,181649,'Featherbeard''s Journal',0),
(16108,20,0,179551,'Hydraxis'' Coffer',0),
(16108,21,0,12666,'Twilight Tome',0),
(16108,22,0,175587,'Damaged Crate',0),
(16108,23,0,180503,'Sandy Cookbook',0),
(16108,24,0,164953,'Large Leather Backpacks',0),
(16109,0,1,6491,'Spirit Healer',1),
(16109,1,0,139852,'Memorial to Sully Balloo',0),
(16109,2,0,160445,'Sha''ni Proudtusk''s Remains',0),
(16109,3,0,2875,'Battered Dwarven Skeleton',0),
(16109,4,0,186332,'Ogre Remains',0),
(16109,5,0,37,'Eliza''s Tombstone',0),
(16109,6,0,61,'A Weathered Grave',0),
(16109,7,0,2703,'Trollbane''s Tomb',0),
(16109,8,0,175933,'Decorated Headstone',0),
(16109,9,0,148504,'A Conspicuous Gravestone',0),
(16109,10,0,177204,'Sorrow of the Earthmother',0),
(16109,11,0,51708,'Eliza''s Grave Dirt',0),
(16109,12,0,181062,'In Loving Memory',0),
(16109,13,0,124374,'Horatio Montgomery, M.D.',0),
(16109,14,0,20923,'Stone of Remembrance',0),
(16109,15,0,31,'Old Lion Statue',0),
(16109,16,0,2082,'Uther the Lightbringer',0),
(16109,17,0,181653,'Uther''s Statue',0),
(16109,18,0,21004,'Monument to Grom Hellscream',0),
(16109,19,0,103813,'Mausoleum Seal',0),
(16173,0,2,6213,'Dancer',1),
(16173,1,0,180437,'Wickerman Ember',0),
(16173,2,0,26449,'Recombobulator',0),
(16173,3,0,149030,'Sentry Brazier',0),
(16173,4,0,22234,'Signal Torch',0),
(16173,5,0,180764,'Firecrackers',0),
(16173,6,0,180870,'Firecrackers',0),
(16173,7,0,175948,'Booty Bay Alarm Bell',0),
(16173,8,0,175788,'Unadorned Stake',0),
(16173,9,0,181605,'Ribbon Pole',0),
(16173,10,0,180515,'Blastenheimer 5000 Ultra Cannon',0),
(16173,11,0,180524,'Tonk Control Console',0),
(16173,12,0,180728,'Firework, Show, Type 1 White',0),
(16173,13,0,186185,'Gordok Festive Keg',0),
(16173,14,0,1557,'Lillith''s Dinner Table',0),
(16173,15,0,176767,'Torch',0),
(16173,16,0,178247,'Naga Brazier',0),
(16173,17,0,142179,'Solarsal Gazebo',0),
(16173,18,0,187951,'Horde Bonfire',0),
(16173,19,0,202880,'Ritual Gong',0),
(16173,20,0,181332,'Flame of Stormwind',0),
(16174,0,0,189993,'Portal to Theramore',1),
(16174,1,0,148498,'Altar of Suntara',0),
(16174,2,0,2933,'Seal of the Earth',0),
(16174,3,0,178444,'Shrine of Sha''gri',0),
(16174,4,0,106529,'Cleansing Water Aura',0),
(16174,5,0,177644,'Moonkin Stone Aura',0),
(16174,6,0,2688,'Keystone',0),
(16174,7,0,2701,'Iridescent Shards',0),
(16174,8,0,153205,'Altar of the Defiler',0),
(16174,9,0,142343,'Uldum Pedestal',0),
(16174,10,0,169217,'Un''Goro Flat Rock',0),
(16174,11,0,164955,'Northern Crystal Pylon',0),
(16174,12,0,176581,'Hand of Iruxos Crystal',0),
(16174,13,0,178386,'Doodad_CentaurTeleporter01',0),
(16174,14,0,184503,'Orb of Translocation',0),
(16174,15,0,19025,'Ancient Inscription',0),
(16174,16,0,150140,'Arcane Focusing Crystal',0),
(16174,17,0,175524,'Mysterious Red Crystal',0),
(16174,18,0,180518,'Lesser Wind Stone',0),
(16174,19,0,180534,'Wind Stone',0),
(16174,20,0,180539,'Greater Wind Stone',0),
(16174,21,0,181598,'Silithyst Geyser',0),
(16174,22,0,180453,'Hive''Regal Glyphed Crystal',0),
(16174,23,0,180454,'Hive''Ashi Glyphed Crystal',0),
(16174,24,0,180455,'Hive''Zora Glyphed Crystal',0),
(16174,25,0,188148,'Ice Stone',0),
(16174,26,0,144063,'Equinex Monolith',0),
(16174,27,0,191364,'Doodad_Nox_portal_orange_bossroom01',0),
(16175,0,0,177232,'Moonwell',1),
(16175,1,0,21583,'The Kaldorei and the Well of Eternity',0),
(16175,2,0,178125,'Lotharian Lotus',0),
(16175,3,0,175761,'Civil War in the Plaguelands',0),
(16175,4,0,20985,'Loose Dirt',0),
(16175,5,0,17157,'Door Lever',0),
(16175,6,0,149502,'Hoard of the Black Dragonflight',0),
(16175,7,0,175856,'Wrath of Soulflayer',0),
(16175,8,0,175756,'The Scourge of Lordaeron',0),
(16175,9,0,2657,'Legends of the Earth',0),
(16175,10,0,123462,'The Jewel of the Southsea',0),
(16175,11,0,20359,'Egg of Onyxia',0),
(16175,12,0,4072,'Main Control Valve',0),
(16175,13,0,61935,'Regulator Valve',0),
(16175,14,0,6906,'Red Raptor Nest',0),
(16175,15,0,2704,'Cache of Explosives',0),
(16175,16,0,177207,'Mists of Dawn',0),
(16175,17,0,180056,'Mysterious Tree Stump',0),
(16175,18,0,177929,'Gaea Dirt Mound',0),
(16175,19,0,180025,'Mysterious Eastvale Haystack',0),
(16175,20,0,176393,'Scourge Cauldron',0),
(16175,21,0,182106,'Tower Banner',0),
(16175,22,0,149420,'Ani',0),
(16175,23,0,175227,'Beached Sea Creature',0),
(16175,24,0,176191,'Beached Sea Turtle',0),
(16175,25,0,176198,'Beached Sea Turtle',0),
(16175,26,0,175230,'Beached Sea Creature',0),
(16175,27,0,175226,'Beached Sea Creature',0),
(16175,28,0,174686,'Corrupted Whipper Root',0),
(16175,29,0,174608,'Corrupted Night Dragon',0),
(16175,30,0,174596,'Corrupted Songflower',0),
(16175,31,0,174708,'Corrupted Windblossom',0),
(16175,32,0,6752,'Strange Fronded Plant',0),
(16175,33,0,7923,'Denalan''s Planter',0),
(16175,34,0,164954,'Zukk''ash Pod',0);
DELETE FROM item_template WHERE entry = 16108;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16108 SET z.entry = 16108, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16109;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16109 SET z.entry = 16109, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16173;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16173 SET z.entry = 16173, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16174;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16174 SET z.entry = 16174, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16175;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16175 SET z.entry = 16175, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DROP TEMPORARY TABLE IF EXISTS zc_b;
-- add them to the boss Builder's Scroll drop, then re-balance so each tier still adds up to green 50 / rare 30 / epic 15 / legendary 5
DELETE FROM reference_loot_template WHERE Entry = 911050 AND Item IN (16108,16109,16173,16174,16175);
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) VALUES
(911050,16108,0,1,0,1,1,1,1,'Builder''s Scroll: Notices and Wanted Posters'),
(911050,16109,0,1,0,1,1,1,1,'Builder''s Scroll: Graves and Remembrance'),
(911050,16173,0,1,0,1,1,1,1,'Builder''s Scroll: Festival and Fire'),
(911050,16174,0,1,0,1,1,1,1,'Builder''s Scroll: Crystals and Wind Stones'),
(911050,16175,0,1,0,1,1,1,1,'Builder''s Scroll: Wilds and Oddities');
UPDATE reference_loot_template r JOIN zerocraft_bscroll b ON b.item_entry = r.Item
JOIN (SELECT quality, COUNT(*) AS n FROM zerocraft_bscroll GROUP BY quality) t ON t.quality = b.quality
SET r.Chance = ROUND(CASE b.quality WHEN 2 THEN 50 WHEN 3 THEN 30 WHEN 4 THEN 15 ELSE 5 END / t.n, 3)
WHERE r.Entry = 911050;
SELECT quality, COUNT(*) AS scrolls FROM zerocraft_bscroll GROUP BY quality;

-- Builder's Scrolls: diamond icon + builder "Use:" line
UPDATE item_template SET displayid = 4775, spellid_1 = 21342 WHERE entry IN (SELECT item_entry FROM zerocraft_bscroll);

-- ZeroCraft: Illidan's Warglaives of Azzinoth squished for level 60 (were item level 156, level 70).
-- Rogues start wielding both; warriors get the pair in their bags. The twin-blade set bonus and +44 attack power stay.
UPDATE item_template SET ItemLevel = 100, RequiredLevel = 60,
  stat_type1 = 3, stat_value1 = 14, stat_type2 = 7, stat_value2 = 18, stat_type3 = 31, stat_value3 = 13,
  dmg_min1 = 150, dmg_max1 = 280, delay = 2800
WHERE entry = 32837;   -- main hand: Agility, Stamina, Hit
UPDATE item_template SET ItemLevel = 100, RequiredLevel = 60,
  stat_type1 = 3, stat_value1 = 13, stat_type2 = 7, stat_value2 = 17, stat_type3 = 32, stat_value3 = 14,
  dmg_min1 = 75, dmg_max1 = 140, delay = 1400
WHERE entry = 32838;   -- off hand: Agility, Stamina, Crit
DELETE FROM zerocraft_bscroll_items WHERE useful = 1;

-- ZeroCraft: no epic mounts at character creation (only the Magic Rooster and a race mount, given in code)
DELETE FROM playercreateinfo_spell_custom WHERE Spell IN (23229, 23238, 23241, 23225, 35710, 23250, 23246, 23249, 23257, 35025, 60025, 32242, 5784, 23161, 13819, 23214, 34769, 34767, 65917);
