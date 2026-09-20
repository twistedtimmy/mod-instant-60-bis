-- ZeroCraft: Pirates (fourth side) + clear the Wetlands of friendly NPCs and Menethil Harbor of everyone
USE acore_characters;
CREATE TABLE IF NOT EXISTS zerocraft_pirates (guid INT UNSIGNED NOT NULL PRIMARY KEY) ENGINE=InnoDB;

USE acore_world;
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
