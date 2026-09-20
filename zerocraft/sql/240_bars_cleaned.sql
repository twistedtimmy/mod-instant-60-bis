-- ZeroCraft: remembers which characters already had profession buttons taken off their bars
USE acore_characters;
CREATE TABLE IF NOT EXISTS zerocraft_bars_cleaned (guid INT UNSIGNED NOT NULL PRIMARY KEY) ENGINE=InnoDB;
