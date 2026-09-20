-- ZeroCraft: completely empty Kalimdor (map 1) and the Eastern Kingdoms (map 0).
-- Every spawned creature goes (backed up in zerocraft_removed_creatures) except deployed NPCs.
USE acore_world;
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
