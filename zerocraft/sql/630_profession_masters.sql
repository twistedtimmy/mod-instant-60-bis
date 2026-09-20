-- ZeroCraft: Profession Masters (911150-911160). Click one to open that profession's crafting window.
USE acore_world;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Alchemy Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911150;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911150, name = 'Master Alchemist', subname = 'Alchemy', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911150;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911150; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Blacksmithing Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911151;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911151, name = 'Master Blacksmith', subname = 'Blacksmithing', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911151;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911151; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Enchanting Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911152;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911152, name = 'Master Enchanter', subname = 'Enchanting', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911152;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911152; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Engineering Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911153;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911153, name = 'Master Engineer', subname = 'Engineering', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911153;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911153; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Inscription Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911154;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911154, name = 'Master Scribe', subname = 'Inscription', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911154;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911154; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Jewelcrafting Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911155;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911155, name = 'Master Jewelcrafter', subname = 'Jewelcrafting', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911155;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911155; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Leatherworking Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911156;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911156, name = 'Master Leatherworker', subname = 'Leatherworking', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911156;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911156; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Tailoring Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911157;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911157, name = 'Master Tailor', subname = 'Tailoring', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911157;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911157; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Cooking Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911158;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911158, name = 'Master Chef', subname = 'Cooking', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911158;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911158; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'First Aid Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911159;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911159, name = 'Master Healer', subname = 'First Aid', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911159;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911159; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SET @src = (SELECT entry FROM creature_template WHERE subname = 'Mining Trainer' AND entry < 100000 ORDER BY entry LIMIT 1);
DELETE FROM creature_template WHERE entry = 911160;
DROP TEMPORARY TABLE IF EXISTS zc_p; CREATE TEMPORARY TABLE zc_p SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_p SET entry = 911160, name = 'Master Miner', subname = 'Smelting', npcflag = 1, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = 'npc_zerocraft_profession';
INSERT INTO creature_template SELECT * FROM zc_p; DROP TEMPORARY TABLE zc_p;
DELETE FROM creature_template_model WHERE CreatureID = 911160;
DROP TEMPORARY TABLE IF EXISTS zc_pm; CREATE TEMPORARY TABLE zc_pm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_pm SET CreatureID = 911160; INSERT INTO creature_template_model SELECT * FROM zc_pm; DROP TEMPORARY TABLE zc_pm;
SELECT t.entry, t.name, t.subname, COUNT(m.CreatureID) AS models FROM creature_template t LEFT JOIN creature_template_model m ON m.CreatureID = t.entry WHERE t.entry BETWEEN 911150 AND 911160 GROUP BY t.entry;
