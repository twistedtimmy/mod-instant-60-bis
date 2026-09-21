-- ZeroCraft: service-NPC deploy items on retired item IDs + Hero becomes Legendary
USE acore_world;
DELETE FROM item_template WHERE entry = 8164;
DROP TEMPORARY TABLE IF EXISTS zc_tmp;
CREATE TEMPORARY TABLE zc_tmp SELECT * FROM item_template WHERE entry = 4427;
UPDATE zc_tmp SET entry = 8164, name = 'Deployable Auctioneer', Quality = 4, stackable = 20, description = 'Deploys a random auctioneer loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp;
DELETE FROM playercreateinfo_item WHERE itemid = 8164;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 8164, 1 FROM playercreateinfo;
DELETE FROM item_template WHERE entry = 17163;
DROP TEMPORARY TABLE IF EXISTS zc_tmp;
CREATE TEMPORARY TABLE zc_tmp SELECT * FROM item_template WHERE entry = 4427;
UPDATE zc_tmp SET entry = 17163, name = 'Deployable Flight Master', Quality = 4, stackable = 20, description = 'Deploys a random flight master loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp;
DELETE FROM playercreateinfo_item WHERE itemid = 17163;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 17163, 1 FROM playercreateinfo;
DELETE FROM item_template WHERE entry = 23656;
DROP TEMPORARY TABLE IF EXISTS zc_tmp;
CREATE TEMPORARY TABLE zc_tmp SELECT * FROM item_template WHERE entry = 4427;
UPDATE zc_tmp SET entry = 23656, name = 'Deployable Banker', Quality = 4, stackable = 20, description = 'Deploys a random banker loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp;
DELETE FROM playercreateinfo_item WHERE itemid = 23656;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 23656, 1 FROM playercreateinfo;
DELETE FROM item_template WHERE entry = 1267;
DROP TEMPORARY TABLE IF EXISTS zc_tmp;
CREATE TEMPORARY TABLE zc_tmp SELECT * FROM item_template WHERE entry = 4427;
UPDATE zc_tmp SET entry = 1267, name = 'Deployable Innkeeper', Quality = 3, stackable = 20, description = 'Deploys a random innkeeper loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp;
DELETE FROM playercreateinfo_item WHERE itemid = 1267;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 1267, 1 FROM playercreateinfo;
DELETE FROM item_template WHERE entry = 6213;
DROP TEMPORARY TABLE IF EXISTS zc_tmp;
CREATE TEMPORARY TABLE zc_tmp SELECT * FROM item_template WHERE entry = 4427;
UPDATE zc_tmp SET entry = 6213, name = 'Deployable Repair Vendor', Quality = 3, stackable = 20, description = 'Deploys a random repair vendor loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp;
DELETE FROM playercreateinfo_item WHERE itemid = 6213;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 6213, 1 FROM playercreateinfo;
UPDATE item_template SET Quality = 5 WHERE entry = 23700;  -- Deployable Hero: Legendary
SELECT entry, name, Quality, ScriptName FROM item_template WHERE entry IN (4427,5041,23700,8164,17163,23656,1267,6213);
SELECT 'auctioneers' t, COUNT(DISTINCT r.id) FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry=r.id WHERE ct.npcflag & 0x200000
UNION ALL SELECT 'flight', COUNT(DISTINCT r.id) FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry=r.id WHERE ct.npcflag & 0x2000
UNION ALL SELECT 'bankers', COUNT(DISTINCT r.id) FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry=r.id WHERE ct.npcflag & 0x20000
UNION ALL SELECT 'innkeepers', COUNT(DISTINCT r.id) FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry=r.id WHERE ct.npcflag & 0x10000
UNION ALL SELECT 'repair', COUNT(DISTINCT r.id) FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry=r.id WHERE ct.npcflag & 0x1000;
