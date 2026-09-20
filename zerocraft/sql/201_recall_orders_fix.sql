-- ZeroCraft: Recall Orders - pack a deployed NPC back into its scroll
USE acore_characters;
CREATE TABLE IF NOT EXISTS zerocraft_packed (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  player_guid INT UNSIGNED NOT NULL,
  scroll_entry INT UNSIGNED NOT NULL,
  entry INT UNSIGNED NOT NULL,
  KEY player_scroll (player_guid, scroll_entry)
) ENGINE=InnoDB;

USE acore_world;
DROP TEMPORARY TABLE IF EXISTS zc_rc;
CREATE TEMPORARY TABLE zc_rc (id INT PRIMARY KEY, disp INT, ord INT);
INSERT IGNORE INTO zc_rc VALUES (5041,6423,0),(1267,6359,1),(6213,4717,2),(8164,1069,3),(17163,29131,4),(23656,34744,5);
SET @old := (SELECT entry FROM item_template WHERE ScriptName = 'item_zerocraft_recall' LIMIT 1);
SET @id := COALESCE(@old, (SELECT id FROM zc_rc WHERE id NOT IN (SELECT entry FROM item_template) ORDER BY ord LIMIT 1));
SET @disp := COALESCE((SELECT disp FROM zc_rc WHERE id = @id), 6338);
DELETE FROM item_template WHERE entry = @id;
DROP TEMPORARY TABLE IF EXISTS zc_r;
CREATE TEMPORARY TABLE zc_r SELECT * FROM item_template WHERE ScriptName = 'item_zerocraft_guild_charter' LIMIT 1;
UPDATE zc_r SET entry = @id, name = 'Recall Orders', displayid = @disp, Quality = 1,
  description = 'Target one of your NPCs and use to pack it back into its scroll.',
  ScriptName = 'item_zerocraft_recall';
INSERT INTO item_template SELECT * FROM zc_r;
DROP TEMPORARY TABLE zc_r;
DROP TEMPORARY TABLE zc_rc;
SELECT entry, name, displayid, spellid_1, ScriptName FROM item_template WHERE ScriptName = 'item_zerocraft_recall';
