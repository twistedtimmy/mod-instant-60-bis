USE acore_characters;
SET @has = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'acore_characters' AND table_name = 'zerocraft_packed' AND column_name = 'health');
SET @q = IF(@has = 0, 'ALTER TABLE zerocraft_packed ADD COLUMN health FLOAT NOT NULL DEFAULT 1', 'SELECT 1');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
