-- ZeroCraft: strip Kalimdor (map 1) and the Eastern Kingdoms (map 0) of their game objects.
-- Everything goes (backed up in zerocraft_removed_gameobjects) EXCEPT:
--   * elevators and moving platforms (types 11, 15) - otherwise Undercity / Thunder Bluff can't be reached
--   * herb, ore and treasure nodes (type 3) and fishing pools (type 25) - so professions still work
--   * anything a player built with a Builder's Scroll (zerocraft_placed)
-- Mailboxes, forges, anvils, meeting stones, portals, chairs, books, posters etc. all go - they live in the Builder's Scrolls now.
USE acore_world;
CREATE TABLE IF NOT EXISTS zerocraft_removed_gameobjects LIKE gameobject;
DROP TEMPORARY TABLE IF EXISTS zc_go;
CREATE TEMPORARY TABLE zc_go (guid INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_go
SELECT g.guid FROM gameobject g
JOIN gameobject_template t ON t.entry = g.id
WHERE g.map IN (0, 1)
  AND t.type NOT IN (3, 11, 15, 25)
  AND g.guid NOT IN (SELECT spawn_id FROM zerocraft_placed WHERE kind = 0);
INSERT IGNORE INTO zerocraft_removed_gameobjects SELECT g.* FROM gameobject g JOIN zc_go a ON a.guid = g.guid;
DELETE ga  FROM gameobject_addon ga       JOIN zc_go a ON a.guid = ga.guid;
DELETE geg FROM game_event_gameobject geg JOIN zc_go a ON a.guid = geg.guid;
DELETE pg  FROM pool_gameobject pg        JOIN zc_go a ON a.guid = pg.guid;
DELETE lr  FROM linked_respawn lr         JOIN zc_go a ON a.guid = lr.guid       WHERE lr.linkType IN (2, 3);
DELETE lr  FROM linked_respawn lr         JOIN zc_go a ON a.guid = lr.linkedGuid WHERE lr.linkType IN (1, 2);
DELETE g   FROM gameobject g              JOIN zc_go a ON a.guid = g.guid;
SELECT COUNT(*) AS objects_removed FROM zc_go;
SELECT t.type, COUNT(*) AS objects_left FROM gameobject g JOIN gameobject_template t ON t.entry = g.id WHERE g.map IN (0, 1) GROUP BY t.type;
DROP TEMPORARY TABLE zc_go;
-- ZeroCraft: extra Builder's Scrolls made from the one-of-a-kind objects that were standing around the old world
-- (books, plaques, graves, wanted posters, ribbon pole, wind stones...). Same rules: one useful thing + decorations.
USE acore_world;
DELETE FROM zerocraft_bscroll WHERE item_entry IN (16108,16109,16173,16174,16175);
DELETE FROM zerocraft_bscroll_items WHERE item_entry IN (16108,16109,16173,16174,16175);
INSERT INTO zerocraft_bscroll (item_entry, quality, name, description) VALUES
(16108,3,'Builder''s Scroll: Notices and Wanted Posters','Builds Mailbox: Human (Stormwind) and 24 decorations. Click a spot on the ground.'),
(16109,4,'Builder''s Scroll: Graves and Remembrance','Builds Spirit Healer and 19 decorations. Click a spot on the ground.'),
(16173,3,'Builder''s Scroll: Festival and Fire','Builds Dancer and 20 decorations. Click a spot on the ground.'),
(16174,5,'Builder''s Scroll: Crystals and Wind Stones','Builds Portal to Theramore and 27 decorations. Click a spot on the ground.'),
(16175,2,'Builder''s Scroll: Wilds and Oddities','Builds Moonwell and 34 decorations. Click a spot on the ground.');
INSERT INTO zerocraft_bscroll_items (item_entry, idx, kind, entry, name, useful) VALUES
(16108,0,0,142075,'Mailbox: Human (Stormwind)',1),
(16108,1,0,179707,'Military Ranks of the Horde & Alliance',0),
(16108,2,0,21042,'Theramore Guard Badge',0),
(16108,3,0,179827,'Wanted/Missing/Lost & Found',0),
(16108,4,0,2083,'Bloodsail Correspondence',0),
(16108,5,0,186426,'Wanted Poster',0),
(16108,6,0,164868,'KILL ON SIGHT',0),
(16108,7,0,256,'WANTED',0),
(16108,8,0,3972,'WANTED',0),
(16108,9,0,2713,'Wanted Board',0),
(16108,10,0,176115,'Wanted Poster - Arnak Grimtotem',0),
(16108,11,0,177226,'Book "Soothsaying for Dummies"',0),
(16108,12,0,179735,'Alliance Military Ranks',0),
(16108,13,0,1726,'Missing: Corporal Keeshan',0),
(16108,14,0,60,'Wanted: Gath''Ilzogg',0),
(16108,15,0,175926,'Mrs. Dalson''s Diary',0),
(16108,16,0,175894,'Janice''s Parcel',0),
(16108,17,0,175924,'Locked Cabinet',0),
(16108,18,0,177667,'Torn Scroll',0),
(16108,19,0,181649,'Featherbeard''s Journal',0),
(16108,20,0,179551,'Hydraxis'' Coffer',0),
(16108,21,0,12666,'Twilight Tome',0),
(16108,22,0,175587,'Damaged Crate',0),
(16108,23,0,180503,'Sandy Cookbook',0),
(16108,24,0,164953,'Large Leather Backpacks',0),
(16109,0,1,6491,'Spirit Healer',1),
(16109,1,0,139852,'Memorial to Sully Balloo',0),
(16109,2,0,160445,'Sha''ni Proudtusk''s Remains',0),
(16109,3,0,2875,'Battered Dwarven Skeleton',0),
(16109,4,0,186332,'Ogre Remains',0),
(16109,5,0,37,'Eliza''s Tombstone',0),
(16109,6,0,61,'A Weathered Grave',0),
(16109,7,0,2703,'Trollbane''s Tomb',0),
(16109,8,0,175933,'Decorated Headstone',0),
(16109,9,0,148504,'A Conspicuous Gravestone',0),
(16109,10,0,177204,'Sorrow of the Earthmother',0),
(16109,11,0,51708,'Eliza''s Grave Dirt',0),
(16109,12,0,181062,'In Loving Memory',0),
(16109,13,0,124374,'Horatio Montgomery, M.D.',0),
(16109,14,0,20923,'Stone of Remembrance',0),
(16109,15,0,31,'Old Lion Statue',0),
(16109,16,0,2082,'Uther the Lightbringer',0),
(16109,17,0,181653,'Uther''s Statue',0),
(16109,18,0,21004,'Monument to Grom Hellscream',0),
(16109,19,0,103813,'Mausoleum Seal',0),
(16173,0,2,6213,'Dancer',1),
(16173,1,0,180437,'Wickerman Ember',0),
(16173,2,0,26449,'Recombobulator',0),
(16173,3,0,149030,'Sentry Brazier',0),
(16173,4,0,22234,'Signal Torch',0),
(16173,5,0,180764,'Firecrackers',0),
(16173,6,0,180870,'Firecrackers',0),
(16173,7,0,175948,'Booty Bay Alarm Bell',0),
(16173,8,0,175788,'Unadorned Stake',0),
(16173,9,0,181605,'Ribbon Pole',0),
(16173,10,0,180515,'Blastenheimer 5000 Ultra Cannon',0),
(16173,11,0,180524,'Tonk Control Console',0),
(16173,12,0,180728,'Firework, Show, Type 1 White',0),
(16173,13,0,186185,'Gordok Festive Keg',0),
(16173,14,0,1557,'Lillith''s Dinner Table',0),
(16173,15,0,176767,'Torch',0),
(16173,16,0,178247,'Naga Brazier',0),
(16173,17,0,142179,'Solarsal Gazebo',0),
(16173,18,0,187951,'Horde Bonfire',0),
(16173,19,0,202880,'Ritual Gong',0),
(16173,20,0,181332,'Flame of Stormwind',0),
(16174,0,0,189993,'Portal to Theramore',1),
(16174,1,0,148498,'Altar of Suntara',0),
(16174,2,0,2933,'Seal of the Earth',0),
(16174,3,0,178444,'Shrine of Sha''gri',0),
(16174,4,0,106529,'Cleansing Water Aura',0),
(16174,5,0,177644,'Moonkin Stone Aura',0),
(16174,6,0,2688,'Keystone',0),
(16174,7,0,2701,'Iridescent Shards',0),
(16174,8,0,153205,'Altar of the Defiler',0),
(16174,9,0,142343,'Uldum Pedestal',0),
(16174,10,0,169217,'Un''Goro Flat Rock',0),
(16174,11,0,164955,'Northern Crystal Pylon',0),
(16174,12,0,176581,'Hand of Iruxos Crystal',0),
(16174,13,0,178386,'Doodad_CentaurTeleporter01',0),
(16174,14,0,184503,'Orb of Translocation',0),
(16174,15,0,19025,'Ancient Inscription',0),
(16174,16,0,150140,'Arcane Focusing Crystal',0),
(16174,17,0,175524,'Mysterious Red Crystal',0),
(16174,18,0,180518,'Lesser Wind Stone',0),
(16174,19,0,180534,'Wind Stone',0),
(16174,20,0,180539,'Greater Wind Stone',0),
(16174,21,0,181598,'Silithyst Geyser',0),
(16174,22,0,180453,'Hive''Regal Glyphed Crystal',0),
(16174,23,0,180454,'Hive''Ashi Glyphed Crystal',0),
(16174,24,0,180455,'Hive''Zora Glyphed Crystal',0),
(16174,25,0,188148,'Ice Stone',0),
(16174,26,0,144063,'Equinex Monolith',0),
(16174,27,0,191364,'Doodad_Nox_portal_orange_bossroom01',0),
(16175,0,0,177232,'Moonwell',1),
(16175,1,0,21583,'The Kaldorei and the Well of Eternity',0),
(16175,2,0,178125,'Lotharian Lotus',0),
(16175,3,0,175761,'Civil War in the Plaguelands',0),
(16175,4,0,20985,'Loose Dirt',0),
(16175,5,0,17157,'Door Lever',0),
(16175,6,0,149502,'Hoard of the Black Dragonflight',0),
(16175,7,0,175856,'Wrath of Soulflayer',0),
(16175,8,0,175756,'The Scourge of Lordaeron',0),
(16175,9,0,2657,'Legends of the Earth',0),
(16175,10,0,123462,'The Jewel of the Southsea',0),
(16175,11,0,20359,'Egg of Onyxia',0),
(16175,12,0,4072,'Main Control Valve',0),
(16175,13,0,61935,'Regulator Valve',0),
(16175,14,0,6906,'Red Raptor Nest',0),
(16175,15,0,2704,'Cache of Explosives',0),
(16175,16,0,177207,'Mists of Dawn',0),
(16175,17,0,180056,'Mysterious Tree Stump',0),
(16175,18,0,177929,'Gaea Dirt Mound',0),
(16175,19,0,180025,'Mysterious Eastvale Haystack',0),
(16175,20,0,176393,'Scourge Cauldron',0),
(16175,21,0,182106,'Tower Banner',0),
(16175,22,0,149420,'Ani',0),
(16175,23,0,175227,'Beached Sea Creature',0),
(16175,24,0,176191,'Beached Sea Turtle',0),
(16175,25,0,176198,'Beached Sea Turtle',0),
(16175,26,0,175230,'Beached Sea Creature',0),
(16175,27,0,175226,'Beached Sea Creature',0),
(16175,28,0,174686,'Corrupted Whipper Root',0),
(16175,29,0,174608,'Corrupted Night Dragon',0),
(16175,30,0,174596,'Corrupted Songflower',0),
(16175,31,0,174708,'Corrupted Windblossom',0),
(16175,32,0,6752,'Strange Fronded Plant',0),
(16175,33,0,7923,'Denalan''s Planter',0),
(16175,34,0,164954,'Zukk''ash Pod',0);
DELETE FROM item_template WHERE entry = 16108;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16108 SET z.entry = 16108, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16109;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16109 SET z.entry = 16109, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16173;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16173 SET z.entry = 16173, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16174;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16174 SET z.entry = 16174, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DELETE FROM item_template WHERE entry = 16175;
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_bscroll b ON b.item_entry = 16175 SET z.entry = 16175, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 823), z.displayid), z.ScriptName = 'item_zerocraft_bscroll';
INSERT INTO item_template SELECT * FROM zc_b;
DROP TEMPORARY TABLE IF EXISTS zc_b;
-- add them to the boss Builder's Scroll drop, then re-balance so each tier still adds up to green 50 / rare 30 / epic 15 / legendary 5
DELETE FROM reference_loot_template WHERE Entry = 911050 AND Item IN (16108,16109,16173,16174,16175);
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) VALUES
(911050,16108,0,1,0,1,1,1,1,'Builder''s Scroll: Notices and Wanted Posters'),
(911050,16109,0,1,0,1,1,1,1,'Builder''s Scroll: Graves and Remembrance'),
(911050,16173,0,1,0,1,1,1,1,'Builder''s Scroll: Festival and Fire'),
(911050,16174,0,1,0,1,1,1,1,'Builder''s Scroll: Crystals and Wind Stones'),
(911050,16175,0,1,0,1,1,1,1,'Builder''s Scroll: Wilds and Oddities');
UPDATE reference_loot_template r JOIN zerocraft_bscroll b ON b.item_entry = r.Item
JOIN (SELECT quality, COUNT(*) AS n FROM zerocraft_bscroll GROUP BY quality) t ON t.quality = b.quality
SET r.Chance = ROUND(CASE b.quality WHEN 2 THEN 50 WHEN 3 THEN 30 WHEN 4 THEN 15 ELSE 5 END / t.n, 3)
WHERE r.Entry = 911050;
SELECT quality, COUNT(*) AS scrolls FROM zerocraft_bscroll GROUP BY quality;
