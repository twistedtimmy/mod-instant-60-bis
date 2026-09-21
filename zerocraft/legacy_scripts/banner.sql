USE acore_world;
DELETE FROM item_template WHERE entry = 911004;
DROP TEMPORARY TABLE IF EXISTS zc_tmp_item;
CREATE TEMPORARY TABLE zc_tmp_item SELECT * FROM item_template WHERE entry = 911001;
UPDATE zc_tmp_item SET entry = 911004, name = "Commander's Banner", Quality = 1, stackable = 1, maxcount = 1, bonding = 1,
  description = 'Target your NPC (or none for all nearby), then click the ground to move them there.',
  displayid = COALESCE((SELECT displayid FROM item_template WHERE name = 'Battle Standard of the Alliance' ORDER BY entry LIMIT 1),
                       (SELECT displayid FROM item_template WHERE entry = 6948)),
  ScriptName = 'item_zerocraft_command';
INSERT INTO item_template SELECT * FROM zc_tmp_item;
DROP TEMPORARY TABLE zc_tmp_item;
SELECT entry, name, spellid_1, displayid, ScriptName FROM item_template WHERE entry = 911004;
