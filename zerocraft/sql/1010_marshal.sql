-- ZeroCraft: the Master Marshal's Banner replaces Commander's Banner: Target (same item id 23701),
-- Commander's Banner: All (23700, removed from bags on login) and Recall Orders (removed on login).
USE acore_world;
UPDATE item_template SET name = 'Master Marshal''s Banner', Quality = 5, bonding = 1, stackable = 1, maxcount = 1,
  description = 'Command your NPCs like an army: click the ground to march them there. Open it to choose who and what.',
  ScriptName = 'item_zerocraft_marshal' WHERE entry = 23701;
-- the ground marker: Freya's green targeting crystal, no interaction
DELETE FROM gameobject_template WHERE entry = 911300;
DROP TEMPORARY TABLE IF EXISTS zc_mk; CREATE TEMPORARY TABLE zc_mk SELECT * FROM gameobject_template WHERE entry = 187691;
UPDATE zc_mk SET entry = 911300, name = 'Marshal''s Marker', displayId = 8649, type = 5, size = 0.6, ScriptName = '';
INSERT INTO gameobject_template SELECT * FROM zc_mk; DROP TEMPORARY TABLE zc_mk;
SELECT entry, name, ScriptName FROM item_template WHERE entry IN (23700, 23701);
SELECT entry, name, displayId, type FROM gameobject_template WHERE entry = 911300;
