-- ZeroCraft: remove every raid/dungeon entry requirement (attunement quests, keys, achievements, item level, level).
USE acore_world;
CREATE TABLE IF NOT EXISTS zerocraft_removed_access_requirements LIKE dungeon_access_requirements;
INSERT IGNORE INTO zerocraft_removed_access_requirements SELECT * FROM dungeon_access_requirements;
DELETE FROM dungeon_access_requirements;
UPDATE dungeon_access_template SET min_level = NULL, max_level = NULL, min_avg_item_level = NULL;
SELECT COUNT(*) AS requirements_backed_up_and_removed FROM zerocraft_removed_access_requirements;
