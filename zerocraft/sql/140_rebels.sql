-- ZeroCraft: which characters are Rebels (the third side)
USE acore_characters;
CREATE TABLE IF NOT EXISTS zerocraft_rebels (guid INT UNSIGNED NOT NULL PRIMARY KEY) ENGINE=InnoDB;
SELECT COUNT(*) AS rebels FROM zerocraft_rebels;
