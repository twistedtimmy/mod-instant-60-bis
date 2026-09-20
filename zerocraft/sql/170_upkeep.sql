-- ZeroCraft: NPC upkeep bookkeeping
USE acore_world;
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
