USE acore_world;
DELETE FROM item_template WHERE entry = 911003;
DROP TEMPORARY TABLE IF EXISTS zc_tmp_item;
CREATE TEMPORARY TABLE zc_tmp_item SELECT * FROM item_template WHERE entry = 911001;
UPDATE zc_tmp_item SET entry = 911003, name = 'Deployable Hero', Quality = 4, stackable = 1,
  description = 'Deploys a random legendary hero loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp_item;
DROP TEMPORARY TABLE zc_tmp_item;
DELETE FROM playercreateinfo_item WHERE itemid = 911003;
INSERT INTO playercreateinfo_item (race, class, itemid, amount)
SELECT DISTINCT race, class, 911003, 1 FROM playercreateinfo;
SELECT entry, name, Quality, spellid_1, ScriptName FROM item_template WHERE entry = 911003;
