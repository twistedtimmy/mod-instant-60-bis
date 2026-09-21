-- Undo ZeroCraft friendly-NPC removal
USE acore_world;
INSERT IGNORE INTO creature SELECT * FROM zerocraft_removed_creatures;
INSERT IGNORE INTO creature_addon SELECT * FROM zerocraft_removed_creature_addon;
INSERT IGNORE INTO game_event_creature SELECT * FROM zerocraft_removed_game_event_creature;
INSERT IGNORE INTO pool_creature SELECT * FROM zerocraft_removed_pool_creature;
SELECT COUNT(*) AS spawns_on_both_continents FROM creature WHERE map IN (0, 1);
