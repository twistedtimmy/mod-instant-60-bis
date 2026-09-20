-- ZeroCraft: no NPCs riding the boats and zeppelins (crews/passengers on every transport).
-- Transport maps are 580-800 minus real instances/battlegrounds and the DK start zone.
USE acore_world;
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
