-- ZeroCraft: move custom items onto retired item IDs the client already knows,
-- so they get real icons and can be dragged onto action bars (no client patch).
USE acore_world;
DROP TEMPORARY TABLE IF EXISTS zc_map;
CREATE TEMPORARY TABLE zc_map (old_id INT, new_id INT);
INSERT INTO zc_map VALUES (911001,4427),(911002,5041),(911003,23700),(911004,23701);

DELETE it FROM item_template it JOIN zc_map m ON it.entry = m.new_id;
DROP TEMPORARY TABLE IF EXISTS zc_items;
CREATE TEMPORARY TABLE zc_items SELECT it.* FROM item_template it JOIN zc_map m ON it.entry = m.old_id;
UPDATE zc_items z JOIN zc_map m ON z.entry = m.old_id SET z.entry = m.new_id;
INSERT INTO item_template SELECT * FROM zc_items;
UPDATE item_template SET spellid_1 = 24340, spellcooldown_1 = -1, spellcategory_1 = 0, spellcategorycooldown_1 = -1 WHERE entry = 23701;

UPDATE playercreateinfo_item p JOIN zc_map m ON p.itemid = m.old_id SET p.itemid = m.new_id;
UPDATE acore_characters.item_instance i JOIN zc_map m ON i.itemEntry = m.old_id SET i.itemEntry = m.new_id;
DELETE it FROM item_template it JOIN zc_map m ON it.entry = m.old_id;

SELECT entry, name, class, subclass, spellid_1, ScriptName FROM item_template WHERE entry IN (4427,5041,23700,23701);
