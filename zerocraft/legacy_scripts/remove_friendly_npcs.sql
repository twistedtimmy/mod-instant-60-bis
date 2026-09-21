-- ZeroCraft: remove all friendly/service NPCs from Eastern Kingdoms (map 0) and Kalimdor (map 1).
-- Keeps spirit healers / spirit guides. Every removed spawn is backed up first so it can be restored.
USE acore_world;

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
SELECT COUNT(*) AS left_in_orgrimmar FROM creature WHERE zoneId = 1637;
