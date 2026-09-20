-- ZeroCraft: deployed NPCs can be resized and sent on patrol (a route of an old townsperson, or between two points)
USE acore_world;
SET @has = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'acore_world' AND table_name = 'zerocraft_deployables' AND column_name = 'scale');
SET @q = IF(@has = 0, 'ALTER TABLE zerocraft_deployables ADD COLUMN scale FLOAT NOT NULL DEFAULT 1, ADD COLUMN patrol_path INT UNSIGNED NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
SELECT COUNT(*) AS old_townsfolk_routes FROM (SELECT DISTINCT id FROM waypoint_data WHERE id % 10 = 0) w
JOIN zerocraft_removed_creatures r ON r.guid * 10 = w.id;
