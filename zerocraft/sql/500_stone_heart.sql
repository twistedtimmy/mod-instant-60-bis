-- ZeroCraft: Summoning Stones can be attacked by rival guilds. Each stone has an invisible "heart"
-- (creature 911130, ~200,000 HP, level 60 elite) standing in it: friendly to its guild, hostile to
-- everyone else. Break it and the stone shatters and the whole guild bank goes to the killer's mailbox.
USE acore_world;
CREATE TABLE IF NOT EXISTS zerocraft_stoneguard (stone_spawn INT UNSIGNED NOT NULL PRIMARY KEY, guard_spawn INT UNSIGNED NOT NULL, KEY guard (guard_spawn)) ENGINE=InnoDB;
DELETE FROM creature_template WHERE entry = 911130;
DROP TEMPORARY TABLE IF EXISTS zc_sg;
CREATE TEMPORARY TABLE zc_sg SELECT * FROM creature_template WHERE entry = 15384;
UPDATE zc_sg SET entry = 911130, name = 'Summoning Stone', subname = 'Guild Claim', npcflag = 1, faction = 35,
  minlevel = 60, maxlevel = 60, `rank` = 1, HealthModifier = 50, ArmorModifier = 3, DamageModifier = 0,
  unit_flags = 0x4 | 0x20000, unit_flags2 = 0, flags_extra = 0x2 | 0x40, AIName = '', ScriptName = '',
  RegenHealth = 1;
INSERT INTO creature_template SELECT * FROM zc_sg;
DROP TEMPORARY TABLE zc_sg;
DELETE FROM creature_template_model WHERE CreatureID = 911130;
INSERT INTO creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability) VALUES (911130, 0, 11686, 4, 1);
SELECT entry, name, `rank`, HealthModifier FROM creature_template WHERE entry = 911130;
