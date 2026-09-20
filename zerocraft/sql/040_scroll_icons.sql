-- ZeroCraft: move deploy items to retired IDs that have scroll icons in the client
USE acore_world;
DROP TEMPORARY TABLE IF EXISTS zc_map;
CREATE TEMPORARY TABLE zc_map (old_id INT, new_id INT, cls INT, sub INT);
INSERT INTO zc_map VALUES
 (4427, 823,   15, 0),   -- Guard:          INV_Scroll_01
 (5041, 842,   15, 0),   -- Vendor:         INV_Scroll_02
 (23700, 951,   0, 8),   -- Hero:           INV_Scroll_07
 (8164, 1078,  12, 0),   -- Auctioneer:     INV_Scroll_03
 (17163, 3504, 12, 0),   -- Flight Master:  INV_Scroll_05
 (23656, 3513, 12, 0),   -- Banker:         INV_Scroll_04
 (1267, 25747, 12, 0),   -- Innkeeper:      INV_Misc_Note_03
 (6213, 25748, 12, 0);   -- Repair Vendor:  INV_Misc_Note_04

DELETE it FROM item_template it JOIN zc_map m ON it.entry = m.new_id;
DROP TEMPORARY TABLE IF EXISTS zc_items;
CREATE TEMPORARY TABLE zc_items SELECT it.* FROM item_template it JOIN zc_map m ON it.entry = m.old_id;
UPDATE zc_items z JOIN zc_map m ON z.entry = m.old_id SET z.entry = m.new_id, z.class = m.cls, z.subclass = m.sub;
INSERT INTO item_template SELECT * FROM zc_items;

UPDATE playercreateinfo_item p JOIN zc_map m ON p.itemid = m.old_id SET p.itemid = m.new_id;
UPDATE reference_loot_template r JOIN zc_map m ON r.Item = m.old_id SET r.Item = m.new_id WHERE r.Entry = 911000;
UPDATE acore_characters.item_instance i JOIN zc_map m ON i.itemEntry = m.old_id SET i.itemEntry = m.new_id;
DELETE it FROM item_template it JOIN zc_map m ON it.entry = m.old_id;

SELECT entry, name, class, Quality FROM item_template WHERE entry IN (823,842,951,1078,3504,3513,25747,25748);
