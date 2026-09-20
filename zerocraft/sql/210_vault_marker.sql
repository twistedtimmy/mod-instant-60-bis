-- ZeroCraft: invisible marker that floats a blue "!" over each Guild Vault
USE acore_world;
DELETE FROM creature_template WHERE entry = 911100;
DROP TEMPORARY TABLE IF EXISTS zc_mk;
CREATE TEMPORARY TABLE zc_mk SELECT * FROM creature_template WHERE entry = 15384;
UPDATE zc_mk SET entry = 911100, name = 'Guild Vault', subname = '', npcflag = 2, faction = 35,
  unit_flags = 0x2000000 | 0x2 | 0x100 | 0x200, flags_extra = 0,
  ScriptName = 'npc_zerocraft_vault_marker', AIName = '', minlevel = 1, maxlevel = 1;
INSERT INTO creature_template SELECT * FROM zc_mk;
DROP TEMPORARY TABLE zc_mk;
DELETE FROM creature_template_model WHERE CreatureID = 911100;
INSERT INTO creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability) VALUES (911100, 0, 11686, 1, 1);
SELECT entry, name, npcflag, unit_flags, ScriptName FROM creature_template WHERE entry = 911100;
