-- TESTING ONLY: remove every deployed NPC and free all loyalty slots
USE acore_world;
DELETE c FROM creature c JOIN zerocraft_deployables d ON d.spawn_id = c.guid;
DELETE FROM zerocraft_deployables;
UPDATE zerocraft_faction_slots SET owner_key = NULL;
SELECT COUNT(*) AS slots_free FROM zerocraft_faction_slots WHERE owner_key IS NULL;
