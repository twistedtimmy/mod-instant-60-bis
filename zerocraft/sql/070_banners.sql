-- ZeroCraft: split the Commander's Banner in two
--   23701 (red Horde standard)     = Commander's Banner: Target  (moves the targeted NPC only)
--   23700 (blue Alliance standard) = Commander's Banner: All     (moves every NPC you own)
USE acore_characters;
-- any leftover old-ID hero scrolls become the real hero item before 23700 is reused
UPDATE item_instance SET itemEntry = 951 WHERE itemEntry = 23700;

USE acore_world;
UPDATE item_template SET name = "Commander's Banner: Target",
  description = "Moves your targeted NPC to the chosen spot."
WHERE entry = 23701;

DELETE FROM item_template WHERE entry = 23700;
DROP TEMPORARY TABLE IF EXISTS zc_banner;
CREATE TEMPORARY TABLE zc_banner SELECT * FROM item_template WHERE entry = 23701;
UPDATE zc_banner SET entry = 23700, displayid = 31256, name = "Commander's Banner: All",
  description = "Moves all of your NPCs to the chosen spot.", ScriptName = 'item_zerocraft_command_all';
INSERT INTO item_template SELECT * FROM zc_banner;
DROP TEMPORARY TABLE zc_banner;

SELECT entry, name, displayid, spellid_1, ScriptName FROM item_template WHERE entry IN (23700, 23701);
