-- ZeroCraft: NPC Books v3 - organized by where the NPCs come from. Dungeon and raid NPCs get a book named
-- after their instance (Scholomance, Utgarde Keep...); world NPCs are grouped by their nearest town.
-- No Flight Masters in books: Flight Master scrolls drop throughout dungeons instead. At most 90 books: every place gets one book before any gets a second.
-- Use the book, pick an NPC, and it appears right in front of you, facing you. Books are never used up.
USE acore_world;
CREATE TABLE IF NOT EXISTS zerocraft_nbook (item_entry INT UNSIGNED NOT NULL PRIMARY KEY, quality TINYINT UNSIGNED NOT NULL, name VARCHAR(80) NOT NULL, description VARCHAR(255) NOT NULL) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS zerocraft_nbook_npcs (item_entry INT UNSIGNED NOT NULL, idx INT UNSIGNED NOT NULL, kind INT UNSIGNED NOT NULL, entry INT UNSIGNED NOT NULL, name VARCHAR(100) NOT NULL, PRIMARY KEY (item_entry, idx)) ENGINE=InnoDB;
DELETE FROM zerocraft_nbook; DELETE FROM zerocraft_nbook_npcs;

DROP TEMPORARY TABLE IF EXISTS zc_ids;
CREATE TEMPORARY TABLE zc_ids (n INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, item INT UNSIGNED NOT NULL);
INSERT INTO zc_ids (item) VALUES (16176),(16177),(16178),(16179),(16180),(16181),(16182),(16183),(16184),(16185),(16186),(16187),(16188),(17889),(17890),(17910),(17911),(18063),(19322),(19932),(20364),(21274),(21628),(21629),(21630),(21631),(21632),(21633),(21634),(21636),(21637),(21638),(21641),(21642),(21643),(21644),(21646),(21649),(21653),(21655),(21656),(21657),(21658),(21659),(21660),(21661),(21662),(21811),(21923),(21930),(21962),(21963),(21964),(22026),(22027),(22045),(23228),(23245),(23325),(23696),(23698),(23699),(28209),(29225),(31716),(33183),(34484),(34486),(38265),(39163),(41605),(41606),(42590),(44114),(45026),(45028),(45029),(45030),(45031),(45032),(45033),(45034),(45035),(45036),(45199),(45229),(45230),(45231),(45568),(45569);

DROP TEMPORARY TABLE IF EXISTS zc_cand;
CREATE TEMPORARY TABLE zc_cand (id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, catord INT, cat VARCHAR(40), kind INT UNSIGNED, entry INT UNSIGNED, name VARCHAR(100));
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 1, 'Heroes', 951, MIN(h.entry), ct.name FROM zerocraft_hero_pool h JOIN creature_template ct ON ct.entry = h.entry WHERE h.villain = 0 GROUP BY ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 2, 'Villains', 951, MIN(h.entry), ct.name FROM zerocraft_hero_pool h JOIN creature_template ct ON ct.entry = h.entry WHERE h.villain <> 0 GROUP BY ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 3, 'City Guards', 823, MIN(g.entry), ct.name FROM zerocraft_guard_pool g JOIN creature_template ct ON ct.entry = g.entry WHERE g.kind = 'guard' GROUP BY ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 4, 'Soldiers', 823, MIN(g.entry), ct.name FROM zerocraft_guard_pool g JOIN creature_template ct ON ct.entry = g.entry WHERE g.kind = 'faction' GROUP BY ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 5, 'Dungeon Elites', 823, MIN(g.entry), ct.name FROM zerocraft_guard_pool g JOIN creature_template ct ON ct.entry = g.entry WHERE g.kind = 'dungeon' GROUP BY ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 6, 'Entertainers', p.item_entry, MIN(p.npc_entry), ct.name FROM zerocraft_deploy_pool p JOIN creature_template ct ON ct.entry = p.npc_entry WHERE p.item_entry IN (1267, 6213, 17163) GROUP BY p.item_entry, ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 7, 'Bankers', 3513, MIN(ct.entry), ct.name FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.npcflag & 0x20000) <> 0 AND ct.`rank` <> 3 AND ct.entry NOT IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540)  GROUP BY ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 8, 'Auctioneers', 1078, MIN(ct.entry), ct.name FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.npcflag & 0x200000) <> 0 AND ct.`rank` <> 3 AND ct.entry NOT IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540)  GROUP BY ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 9, 'Innkeepers', 25747, MIN(ct.entry), ct.name FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.npcflag & 0x10000) <> 0 AND ct.`rank` <> 3 AND ct.entry NOT IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540)  GROUP BY ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 10, 'Stable Masters', 17163, MIN(ct.entry), ct.name FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.npcflag & 0x400000) <> 0 AND ct.`rank` <> 3 AND ct.entry NOT IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540)  GROUP BY ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 11, 'Smiths and Repairers', 25748, MIN(ct.entry), ct.name FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.npcflag & 0x1000) <> 0 AND ct.`rank` <> 3 AND ct.entry NOT IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540)  GROUP BY ct.name;
INSERT INTO zc_cand (catord, cat, kind, entry, name)
SELECT 12, 'Merchants', 842, MIN(ct.entry), ct.name FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.npcflag & 128) <> 0 AND ct.`rank` <> 3 AND ct.entry NOT IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540) AND (ct.npcflag & (0x1000|0x10000|0x20000|0x200000|0x400000|0x2000)) = 0 GROUP BY ct.name;

-- where each NPC comes from: its first instance spawn, else its world spawn
DROP TEMPORARY TABLE IF EXISTS zc_maps;
CREATE TEMPORARY TABLE zc_maps (id INT UNSIGNED PRIMARY KEY, name VARCHAR(80), inst TINYINT);
INSERT INTO zc_maps VALUES (0,'Eastern Kingdoms',0),(1,'Kalimdor',0),(13,'Testing',0),(25,'Scott Test',0),(30,'Alterac Valley',0),(33,'Shadowfang Keep',1),(34,'Stormwind Stockade',1),(35,'<unused>StormwindPrison',0),(36,'Deadmines',1),(37,'Azshara Crater',0),(42,'Collin''s Test',0),(43,'Wailing Caverns',1),(44,'<unused> Monastery',1),(47,'Razorfen Kraul',1),(48,'Blackfathom Deeps',1),(70,'Uldaman',1),(90,'Gnomeregan',1),(109,'Sunken Temple',1),(129,'Razorfen Downs',1),(169,'Emerald Dream',1),(189,'Scarlet Monastery',1),(209,'Zul''Farrak',1),(229,'Blackrock Spire',1),(230,'Blackrock Depths',1),(249,'Onyxia''s Lair',1),(269,'Opening of the Dark Portal',1),(289,'Scholomance',1),(309,'Zul''Gurub',1),(329,'Stratholme',1),(349,'Maraudon',1),(369,'Deeprun Tram',0),(389,'Ragefire Chasm',1),(409,'Molten Core',1),(429,'Dire Maul',1),(449,'Alliance PVP Barracks',0),(450,'Horde PVP Barracks',0),(451,'Development Land',0),(469,'Blackwing Lair',1),(489,'Warsong Gulch',0),(509,'Ruins of Ahn''Qiraj',1),(529,'Arathi Basin',0),(530,'Outland',0),(531,'Ahn''Qiraj Temple',1),(532,'Karazhan',1),(533,'Naxxramas',1),(534,'The Battle for Mount Hyjal',1),(540,'Hellfire Citadel: The Shattered Halls',1),(542,'Hellfire Citadel: The Blood Furnace',1),(543,'Hellfire Citadel: Ramparts',1),(544,'Magtheridon''s Lair',1),(545,'Coilfang: The Steamvault',1),(546,'Coilfang: The Underbog',1),(547,'Coilfang: The Slave Pens',1),(548,'Coilfang: Serpentshrine Cavern',1),(550,'Tempest Keep',1),(552,'Tempest Keep: The Arcatraz',1),(553,'Tempest Keep: The Botanica',1),(554,'Tempest Keep: The Mechanar',1),(555,'Auchindoun: Shadow Labyrinth',1),(556,'Auchindoun: Sethekk Halls',1),(557,'Auchindoun: Mana-Tombs',1),(558,'Auchindoun: Auchenai Crypts',1),(559,'Nagrand Arena',0),(560,'The Escape From Durnholde',1),(562,'Blade''s Edge Arena',0),(564,'Black Temple',1),(565,'Gruul''s Lair',1),(566,'Eye of the Storm',0),(568,'Zul''Aman',1),(571,'Northrend',0),(572,'Ruins of Lordaeron',0),(573,'ExteriorTest',0),(574,'Utgarde Keep',1),(575,'Utgarde Pinnacle',1),(576,'The Nexus',1),(578,'The Oculus',1),(580,'The Sunwell',1),(582,'Transport: Rut''theran to Auberdine',0),(584,'Transport: Menethil to Theramore',0),(585,'Magister''s Terrace',1),(586,'Transport: Exodar to Auberdine',0),(587,'Transport: Feathermoon Ferry',0),(588,'Transport: Menethil to Auberdine',0),(589,'Transport: Orgrimmar to Grom''Gol',0),(590,'Transport: Grom''Gol to Undercity',0),(591,'Transport: Undercity to Orgrimmar',0),(592,'Transport: Borean Tundra Test',0),(593,'Transport: Booty Bay to Ratchet',0),(594,'Transport: Howling Fjord Sister Mercy (Quest)',0),(595,'The Culling of Stratholme',1),(596,'Transport: Naglfar',0),(597,'Craig Test',0),(598,'Sunwell Fix (Unused)',1),(599,'Halls of Stone',1),(600,'Drak''Tharon Keep',1),(601,'Azjol-Nerub',1),(602,'Halls of Lightning',1),(603,'Ulduar',1),(604,'Gundrak',1),(605,'Development Land (non-weighted textures)',0),(606,'QA and DVD',0),(607,'Strand of the Ancients',0),(608,'Violet Hold',1),(609,'Ebon Hold',0),(610,'Transport: Tirisfal to Vengeance Landing',0),(612,'Transport: Menethil to Valgarde',0),(613,'Transport: Orgrimmar to Warsong Hold',0),(614,'Transport: Stormwind to Valiance Keep',0),(615,'The Obsidian Sanctum',1),(616,'The Eye of Eternity',1),(617,'Dalaran Sewers',0),(618,'The Ring of Valor',0),(619,'Ahn''kahet: The Old Kingdom',1),(620,'Transport: Moa''ki to Unu''pe',0),(621,'Transport: Moa''ki to Kamagua',0),(622,'Transport: Orgrim''s Hammer',0),(623,'Transport: The Skybreaker',0),(624,'Vault of Archavon',1),(628,'Isle of Conquest',0),(631,'Icecrown Citadel',1),(632,'The Forge of Souls',1),(641,'Transport: Alliance Airship BG',0),(642,'Transport: HordeAirshipBG',0),(647,'Transport: Orgrimmar to Thunder Bluff',0),(649,'Trial of the Crusader',1),(650,'Trial of the Champion',1),(658,'Pit of Saron',1),(668,'Halls of Reflection',1),(672,'Transport: The Skybreaker (Icecrown Citadel Raid)',0),(673,'Transport: Orgrim''s Hammer (Icecrown Citadel Raid)',0),(712,'Transport: The Skybreaker (IC Dungeon)',0),(713,'Transport: Orgrim''s Hammer (IC Dungeon)',0),(718,'Trasnport: The Mighty Wind (Icecrown Citadel Raid)',0),(723,'Stormwind',0),(724,'The Ruby Sanctum',1);
DROP TEMPORARY TABLE IF EXISTS zc_taxi;
CREATE TEMPORARY TABLE zc_taxi (map INT UNSIGNED, x FLOAT, y FLOAT, name VARCHAR(80));
INSERT INTO zc_taxi VALUES (0,-8889.0,-0.5,'Northshire Abbey'),(0,-8840.6,489.7,'Stormwind'),(0,-10629.3,1036.9,'Sentinel Hill'),(0,-9429.1,-2231.4,'Lakeshire'),(0,-4821.8,-1155.4,'Ironforge'),(0,-3792.3,-783.3,'Menethil Harbor'),(0,-5421.9,-2930.0,'Thelsamar'),(0,-14271.8,299.9,'Booty Bay'),(0,478.9,1536.6,'The Sepulcher'),(0,1568.6,268.0,'Undercity'),(0,-10515.5,-1261.7,'Darkshire'),(0,-0.1,-859.9,'Tarren Mill'),(0,-711.5,-515.5,'Southshore'),(0,2253.4,-5344.9,'Eastern Plaguelands'),(0,-1240.5,-2515.1,'Refuge Pointe'),(0,-916.3,-3496.9,'Hammerfall'),(0,-14444.3,509.6,'Booty Bay'),(0,-14473.0,464.1,'Booty Bay'),(0,-12414.2,146.3,'Grom''gol'),(0,-6634.0,-2180.1,'Kargath'),(1,-1197.2,29.7,'Thunder Bluff'),(1,1677.6,-4315.7,'Orgrimmar'),(1,-441.8,-2596.1,'Crossroads'),(1,6341.4,557.7,'Auberdine'),(1,8643.6,841.0,'Rut''theran Village'),(1,2827.3,-289.2,'Astranaar'),(1,966.6,1040.3,'Sun Rock Retreat'),(1,-5407.7,-2414.3,'Freewind Post'),(1,-4491.9,-775.9,'Thalanaar'),(1,-3825.4,-4516.6,'Theramore'),(1,2681.1,1461.7,'Stonetalon Peak'),(0,-8644.6,433.3,'Generic'),(1,139.2,1325.8,'Nijel''s Point'),(1,-1767.6,3263.9,'Shadowprey Village'),(1,-7224.0,-3734.6,'Gadgetzan'),(1,-7048.9,-3780.4,'Gadgetzan'),(1,-4373.8,3338.6,'Feathermoon'),(1,-4419.9,199.3,'Camp Mojache'),(0,283.7,-2002.8,'Aerie Peak'),(1,3661.5,-4390.4,'Valormok'),(0,-11112.2,-3435.7,'Nethergarde Keep'),(1,5068.4,-337.2,'Bloodvenom Post'),(1,7458.5,-2487.2,'Moonglade'),(1,6796.8,-4742.4,'Everlook'),(1,6813.1,-4611.1,'Everlook'),(1,-3147.4,-2842.2,'Brackenwall Village'),(0,-10457.0,-3279.2,'Stonard'),(1,8701.5,991.4,'Fishing Village'),(1,3374.7,997.0,'Zoram''gar Outpost'),(30,574.2,-46.7,'Dun Baldar'),(30,-1335.4,-319.7,'Frostwolf Keep'),(1,2302.4,-2524.6,'Splintertree Post'),(1,7793.6,-2403.5,'Nighthaven'),(1,7787.7,-2404.1,'Nighthaven'),(1,2722.0,-3880.6,'Talrendis Point'),(1,6205.9,-1949.6,'Talonbranch Glade'),(0,931.3,-1430.1,'Chillwind Camp'),(0,2271.1,-5340.8,'Light''s Hope Chapel'),(0,2327.4,-5286.9,'Light''s Hope Chapel'),(1,7470.4,-2123.4,'Moonglade'),(0,-7504.0,-2187.5,'Flame Crest'),(0,-8364.6,-2738.4,'Morgan''s Vigil'),(1,-6811.4,836.7,'Cenarion Hold'),(1,-6761.8,772.0,'Cenarion Hold'),(0,-6552.6,-1168.3,'Thorium Point'),(0,-6554.9,-1100.1,'Thorium Point'),(0,-635.3,-4720.5,'Revantusk Village'),(1,-2380.7,-1882.7,'Camp Taurajo'),(1,-6113.8,-1142.7,'Marshal''s Refuge'),(1,-894.6,-3773.0,'Ratchet'),(530,9375.2,-7165.9,'Silvermoon City'),(530,7594.5,-6784.3,'Tranquillien'),(0,2998.7,-3050.1,'Plaguewood Tower'),(0,3109.3,-4285.1,'Northpass Tower'),(0,2499.2,-4742.9,'Eastwall Tower'),(0,1857.6,-3658.5,'Crown Guard Tower'),(530,-1933.3,-11954.6,'Blood Watch'),(530,-4054.9,-11793.3,'The Exodar'),(530,228.5,2633.6,'Thrallmar'),(530,-673.4,2717.3,'Honor Hold'),(530,199.2,4241.6,'Temple of Telhamat'),(530,-587.4,4101.0,'Falcon Watch'),(530,-1810.2,8032.1,'Nagrand - PvP - Attack Run Start 1'),(530,-1824.2,8049.3,'Nagrand - PvP - Attack Run End 1'),(530,-1513.4,8140.9,'Nagrand - PvP - Attack Run Start 2'),(530,-1511.3,8149.7,'Nagrand - PvP - Attack Run End 2'),(530,-1387.1,7782.4,'Nagrand - PvP - Attack Run Start 3'),(530,-1376.7,7771.2,'Nagrand - PvP - Attack Run End 3'),(530,-1656.6,7724.9,'Nagrand - PvP - Attack Run Start 4'),(530,-1658.9,7724.7,'Nagrand - PvP - Attack Run End 4'),(530,9335.8,-7883.1,'Eversong - Duskwither Teleport'),(530,9335.7,-7809.7,'Eversong - Duskwither Teleport End'),(530,213.8,6063.8,'Telredor'),(530,219.4,7816.0,'Zabra''jin'),(530,-2729.0,7305.3,'Telaar'),(530,-1261.1,7133.4,'Garadar'),(530,-2987.2,3872.8,'Allerian Stronghold'),(530,3082.3,3596.1,'Area 52'),(530,-3018.6,2557.1,'Shadowmoon Village'),(530,-3982.1,2156.5,'Wildhammer Stronghold'),(530,2183.6,6794.5,'Sylvanaar'),(530,2446.4,6020.9,'Thunderlord Stronghold'),(530,-2567.3,4423.8,'Stonebreaker Hold'),(530,-1837.2,5301.9,'Shattrath'),(530,-327.4,1020.5,'Hellfire Peninsula'),(530,-178.1,1026.7,'Hellfire Peninsula'),(530,4157.6,2959.7,'The Stormspire'),(530,-3065.6,749.4,'Altar of Sha''tar'),(530,-1316.8,2358.6,'Spinebreaker Ridge'),(530,-29.2,2125.7,'Hellfire Peninsula - Reaver''s Fall'),(530,509.2,1988.7,'Hellfire Peninsula - Force Camp Beach Head'),(530,298.5,1501.2,'Shatter Point'),(530,276.2,1486.9,'Shatter Point'),(530,2974.9,1848.2,'Cosmowrench'),(530,91.7,5214.9,'Swamprat Post'),(530,1857.3,5531.9,'Toshley''s Station'),(530,-4073.2,1123.6,'Sanctum of the Stars'),(530,2976.0,5501.1,'Evergrove'),(530,2028.8,4705.3,'Mok''Nathal Village'),(530,966.7,7399.2,'Orebor Harborage'),(1,3978.7,-1316.4,'Emerald Sanctuary'),(1,3000.2,-3202.4,'Forest Song'),(0,-9441.2,65.1,'Filming'),(530,-3364.7,3650.2,'Skettis'),(530,2531.1,7322.1,'Ogri''La'),(1,-4566.2,-3226.1,'Mudsprocket'),(571,567.4,-5011.0,'Valgarde Port'),(571,2468.8,-5029.8,'Fort Wildervar'),(571,1342.8,-3287.9,'Westguard Keep'),(571,401.1,-4544.3,'New Agamand'),(571,1918.6,-6175.9,'Vengeance Landing'),(571,2652.9,-4392.7,'Camp Winterhoof'),(0,-11344.0,-216.8,'Rebel Camp'),(451,15992.4,-16371.9,'Development Land - Kyle Radue Start'),(530,6789.8,-7747.6,'Zul''Aman'),(530,13012.7,-6908.4,'Shattered Sun Staging Area'),(571,3465.7,5901.8,'Amber Ledge'),(571,3213.7,6084.7,'Beryl Point'),(571,3574.1,5971.0,'Amber Ledge'),(571,3575.4,6661.6,'Transitus Shield'),(571,2774.7,6258.1,'Borean Tundra - Warsong Hold Wolf Start'),(571,4130.6,7372.3,'Coldarra Ledge'),(571,3575.6,6651.8,'Transitus Shield'),(571,4026.9,7085.5,'Coldarra'),(571,3712.4,-694.9,'Wintergarde Keep'),(571,2269.5,5173.7,'Valiance Keep'),(571,4127.2,5313.1,'Fizzcrank Airstrip'),(571,3504.1,1992.0,'Stars'' Rest'),(571,2108.1,-2970.6,'Apothecary Camp'),(571,3876.3,-4520.1,'Camp Oneqwah'),(571,3258.9,-2263.1,'Conquest Hold'),(571,4612.2,1406.6,'Fordragon Hold'),(571,3653.2,247.6,'Wyrmrest Temple'),(571,3446.4,-2754.1,'Amberpine Lodge'),(571,3243.0,-666.2,'Venomspite'),(571,4585.0,-4254.7,'Westfall Brigade'),(571,3865.9,1525.6,'Agmar''s Hammer'),(571,2920.3,6242.9,'Warsong Hold'),(571,3449.5,4089.5,'Taunka''le Village'),(571,4474.8,5712.1,'Bor''gorok Outpost'),(571,4946.7,1165.9,'Kor''koron Vanguard'),(571,4267.4,-3050.9,'Grizzly Hills'),(571,4272.1,-3248.3,'Grizzly Hills'),(571,4311.2,-2956.6,'Grizzly Hills'),(571,3547.2,381.5,'Wyrmrest Temple - bottom to top'),(571,3587.6,279.2,'Wyrmrest Temple - top to bottom'),(571,3587.6,279.1,'Wyrmrest Temple - top to middle'),(571,3545.6,273.6,'Wyrmrest Temple - middle to top'),(571,3545.6,273.6,'Wyrmrest Temple - middle to bottom'),(571,3548.1,381.0,'Wyrmrest Temple - bottom to middle'),(571,3587.8,5973.3,'Amber Ledge'),(571,5450.3,-2606.3,'Argent Stand'),(0,-8338.4,1107.0,'Flavor - Stormwind Harbor  - Start'),(571,2792.4,909.0,'Moa''ki'),(571,785.3,-2887.7,'Kamagua'),(571,2919.2,4046.1,'Unu''pe'),(571,5100.8,2185.6,'Valiance Landing Camp'),(571,5521.6,-2672.2,'The Argent Stand'),(571,5218.9,-1302.2,'Ebon Watch'),(571,5190.1,-2206.5,'Light''s Breach'),(571,5777.4,-3594.9,'Zim''Torga'),(571,5506.2,4748.1,'River''s Heart'),(571,5596.1,5824.4,'Nesingwary Base Camp'),(571,5813.9,449.1,'Dalaran'),(0,2352.4,-5666.9,'Acherus: The Ebon Hold'),(0,0.0,0.0,'Ebon Hold - Acherus -> Death''s Breach Start'),(0,0.0,0.0,'Ebon Hold - Death''s Breach -> Acherus Start'),(571,6186.8,-1052.9,'K3'),(571,6667.0,-258.7,'Frosthold'),(571,7308.0,-2607.6,'Dun Nifflelem'),(571,7857.3,-735.0,'Grom''arsh Crash-Site'),(571,7793.9,-2810.1,'Camp Tunka''lo'),(571,7427.3,4224.2,'Death''s Rise'),(571,8864.7,-1324.3,'Ulduar'),(571,8472.5,-336.0,'Bouldercrag''s Refuge'),(571,6897.6,-4118.2,'Gundrak'),(571,5025.0,3685.6,'Warsong Camp'),(571,8408.1,2702.7,'The Shadow Vault'),(571,6164.5,-61.3,'The Argent Vanguard'),(571,6402.1,467.9,'Crusaders'' Pinnacle'),(571,5035.6,-520.0,'Windrunner''s Overlook'),(571,5590.5,-693.2,'Sunreaver''s Command'),(571,8475.8,891.2,'Argent Tournament Grounds'),(603,-749.2,-100.0,'Ulduar Raid - Interior - Insertion Point'),(603,120.0,-71.6,'Ulduar Raid - Iron Concourse'),(0,1942.5,-2559.2,'Thondoril River'),(0,1726.9,-740.8,'The Bulwark'),(0,-5451.5,-667.7,'CC Prologue - GT - Battle Flight - Start'),(1,-839.6,-4985.4,'Durotar - ET - CC Prologue Spy Frog Start'),(1,-838.0,-4986.3,'Durotar - ET - CC Prologue Spy Frog End'),(1,-838.8,-4986.0,'Durotar - ET - CC Prologue Troll Taxi Bat Start'),(1,284.4,-4762.4,'Durotar - ET - CC Prologue Troll Recruit End');

SET @idcol = (SELECT IF(COUNT(*) > 0, 'id1', 'id') FROM information_schema.columns
              WHERE table_schema = 'acore_world' AND table_name = 'creature' AND column_name = 'id1');
DROP TEMPORARY TABLE IF EXISTS zc_allspawn;
CREATE TEMPORARY TABLE zc_allspawn (entry INT UNSIGNED, map INT UNSIGNED, x FLOAT, y FLOAT, KEY (entry));
SET @q = CONCAT('INSERT INTO zc_allspawn SELECT ', @idcol, ', map, position_x, position_y FROM creature');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
SET @q = CONCAT('INSERT INTO zc_allspawn SELECT ', @idcol, ', map, position_x, position_y FROM zerocraft_removed_creatures');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
DROP TEMPORARY TABLE IF EXISTS zc_spawn;
CREATE TEMPORARY TABLE zc_spawn (entry INT UNSIGNED PRIMARY KEY, map INT UNSIGNED, x FLOAT, y FLOAT, loc VARCHAR(80), inst TINYINT DEFAULT 0);
INSERT IGNORE INTO zc_spawn (entry, map, x, y) SELECT a.entry, a.map, a.x, a.y FROM zc_allspawn a JOIN zc_maps m ON m.id = a.map WHERE m.inst = 1;
INSERT IGNORE INTO zc_spawn (entry, map, x, y) SELECT a.entry, a.map, a.x, a.y FROM zc_allspawn a;
UPDATE zc_spawn s JOIN zc_maps m ON m.id = s.map SET s.loc = m.name, s.inst = m.inst;
UPDATE zc_spawn s SET s.loc = COALESCE((SELECT t.name FROM zc_taxi t WHERE t.map = s.map
       ORDER BY (t.x - s.x) * (t.x - s.x) + (t.y - s.y) * (t.y - s.y) LIMIT 1), s.loc) WHERE s.inst = 0;

DELETE FROM zc_taxi WHERE name LIKE '%Prologue%' OR name LIKE '%Filming%' OR name LIKE '%Generic%';
UPDATE zc_maps SET name = 'Wanderers', inst = 0 WHERE inst = 0 AND id NOT IN (0, 1, 530, 571);
-- one row per NPC (its most important role), with its home
DROP TEMPORARY TABLE IF EXISTS zc_one;
CREATE TEMPORARY TABLE zc_one (entry INT UNSIGNED PRIMARY KEY, catord INT, kind INT UNSIGNED, name VARCHAR(100), loc VARCHAR(80), inst TINYINT);
INSERT IGNORE INTO zc_one SELECT c.entry, c.catord, c.kind, c.name, COALESCE(s.loc, 'Wanderers'), COALESCE(s.inst, 0)
FROM zc_cand c LEFT JOIN zc_spawn s ON s.entry = c.entry ORDER BY c.catord;
-- tiny world groups (under 6 NPCs) fold into their continent
DROP TEMPORARY TABLE IF EXISTS zc_small;
CREATE TEMPORARY TABLE zc_small SELECT loc FROM zc_one WHERE inst = 0 GROUP BY loc HAVING COUNT(*) < 6;
UPDATE zc_one o JOIN zc_small sm ON sm.loc = o.loc LEFT JOIN zc_spawn s ON s.entry = o.entry LEFT JOIN zc_maps m ON m.id = s.map
SET o.loc = COALESCE(m.name, 'Wanderers');

DROP TEMPORARY TABLE IF EXISTS zc_cand2;
CREATE TEMPORARY TABLE zc_cand2
SELECT entry, catord, kind, name, loc, inst,
       (ROW_NUMBER() OVER (PARTITION BY loc ORDER BY catord, name, entry) - 1) DIV 14 AS b,
       (ROW_NUMBER() OVER (PARTITION BY loc ORDER BY catord, name, entry) - 1) MOD 14 + 1 AS idx
FROM zc_one;
DROP TEMPORARY TABLE IF EXISTS zc_loccount;
CREATE TEMPORARY TABLE zc_loccount SELECT loc, MAX(inst) AS inst, COUNT(*) AS npcs, MAX(b) + 1 AS books, MIN(catord) AS best FROM zc_cand2 GROUP BY loc;
DROP TEMPORARY TABLE IF EXISTS zc_books;
CREATE TEMPORARY TABLE zc_books
SELECT x.loc, x.b, ROW_NUMBER() OVER (ORDER BY x.b, lc.inst DESC, lc.npcs DESC, x.loc) AS n
FROM (SELECT DISTINCT loc, b FROM zc_cand2) x JOIN zc_loccount lc ON lc.loc = x.loc;
DROP TEMPORARY TABLE IF EXISTS zc_bookq;
CREATE TEMPORARY TABLE zc_bookq SELECT loc, b, MIN(catord) AS mn, MAX(catord) AS mx FROM zc_cand2 GROUP BY loc, b;

DROP TEMPORARY TABLE IF EXISTS zc_multi;
CREATE TEMPORARY TABLE zc_multi SELECT DISTINCT loc FROM zc_books WHERE b = 1 AND n <= 90;
INSERT INTO zerocraft_nbook (item_entry, quality, name, description)
SELECT i.item,
       CASE WHEN bq.mn <= 2 THEN 4 WHEN lc.inst = 1 THEN 3 ELSE 2 END,
       LEFT(CONCAT('NPC Book: ', bk.loc, IF(mb.loc IS NOT NULL, CONCAT(' ', COALESCE(ELT(bk.b + 1, 'I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII','XIII','XIV','XV','XVI','XVII','XVIII','XIX','XX'), CAST(bk.b + 1 AS CHAR))), '')), 80),
       'Calls NPCs from this place. They arrive right in front of you.'
FROM zc_books bk JOIN zc_ids i ON i.n = bk.n JOIN zc_loccount lc ON lc.loc = bk.loc JOIN zc_bookq bq ON bq.loc = bk.loc AND bq.b = bk.b LEFT JOIN zc_multi mb ON mb.loc = bk.loc;

INSERT INTO zerocraft_nbook_npcs (item_entry, idx, kind, entry, name)
SELECT i.item, c.idx, c.kind, c.entry, LEFT(c.name, 100)
FROM zc_cand2 c JOIN zc_books bk ON bk.loc = c.loc AND bk.b = c.b JOIN zc_ids i ON i.n = bk.n;
UPDATE zerocraft_nbook b SET description = CONCAT('Calls any of ', (SELECT COUNT(*) FROM zerocraft_nbook_npcs n WHERE n.item_entry = b.item_entry), ' NPCs from this place. They arrive right in front of you.');

-- the book items (cloned from the Builder's Kit, never used up)
DELETE FROM item_template WHERE entry = 16176 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16176);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16176 SET z.entry = 16176, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16176;
DELETE FROM item_template WHERE entry = 16177 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16177);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16177 SET z.entry = 16177, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16177;
DELETE FROM item_template WHERE entry = 16178 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16178);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16178 SET z.entry = 16178, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16178;
DELETE FROM item_template WHERE entry = 16179 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16179);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16179 SET z.entry = 16179, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16179;
DELETE FROM item_template WHERE entry = 16180 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16180);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16180 SET z.entry = 16180, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16180;
DELETE FROM item_template WHERE entry = 16181 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16181);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16181 SET z.entry = 16181, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16181;
DELETE FROM item_template WHERE entry = 16182 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16182);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16182 SET z.entry = 16182, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16182;
DELETE FROM item_template WHERE entry = 16183 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16183);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16183 SET z.entry = 16183, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16183;
DELETE FROM item_template WHERE entry = 16184 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16184);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16184 SET z.entry = 16184, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16184;
DELETE FROM item_template WHERE entry = 16185 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16185);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16185 SET z.entry = 16185, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16185;
DELETE FROM item_template WHERE entry = 16186 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16186);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16186 SET z.entry = 16186, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16186;
DELETE FROM item_template WHERE entry = 16187 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16187);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16187 SET z.entry = 16187, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16187;
DELETE FROM item_template WHERE entry = 16188 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 16188);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 16188 SET z.entry = 16188, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 16188;
DELETE FROM item_template WHERE entry = 17889 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 17889);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 17889 SET z.entry = 17889, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 17889;
DELETE FROM item_template WHERE entry = 17890 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 17890);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 17890 SET z.entry = 17890, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 17890;
DELETE FROM item_template WHERE entry = 17910 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 17910);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 17910 SET z.entry = 17910, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 17910;
DELETE FROM item_template WHERE entry = 17911 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 17911);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 17911 SET z.entry = 17911, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 17911;
DELETE FROM item_template WHERE entry = 18063 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 18063);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 18063 SET z.entry = 18063, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 18063;
DELETE FROM item_template WHERE entry = 19322 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 19322);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 19322 SET z.entry = 19322, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 19322;
DELETE FROM item_template WHERE entry = 19932 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 19932);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 19932 SET z.entry = 19932, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 19932;
DELETE FROM item_template WHERE entry = 20364 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 20364);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 20364 SET z.entry = 20364, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 20364;
DELETE FROM item_template WHERE entry = 21274 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21274);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21274 SET z.entry = 21274, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21274;
DELETE FROM item_template WHERE entry = 21628 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21628);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21628 SET z.entry = 21628, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21628;
DELETE FROM item_template WHERE entry = 21629 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21629);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21629 SET z.entry = 21629, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21629;
DELETE FROM item_template WHERE entry = 21630 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21630);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21630 SET z.entry = 21630, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21630;
DELETE FROM item_template WHERE entry = 21631 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21631);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21631 SET z.entry = 21631, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21631;
DELETE FROM item_template WHERE entry = 21632 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21632);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21632 SET z.entry = 21632, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21632;
DELETE FROM item_template WHERE entry = 21633 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21633);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21633 SET z.entry = 21633, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21633;
DELETE FROM item_template WHERE entry = 21634 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21634);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21634 SET z.entry = 21634, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21634;
DELETE FROM item_template WHERE entry = 21636 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21636);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21636 SET z.entry = 21636, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21636;
DELETE FROM item_template WHERE entry = 21637 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21637);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21637 SET z.entry = 21637, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21637;
DELETE FROM item_template WHERE entry = 21638 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21638);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21638 SET z.entry = 21638, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21638;
DELETE FROM item_template WHERE entry = 21641 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21641);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21641 SET z.entry = 21641, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21641;
DELETE FROM item_template WHERE entry = 21642 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21642);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21642 SET z.entry = 21642, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21642;
DELETE FROM item_template WHERE entry = 21643 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21643);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21643 SET z.entry = 21643, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21643;
DELETE FROM item_template WHERE entry = 21644 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21644);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21644 SET z.entry = 21644, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21644;
DELETE FROM item_template WHERE entry = 21646 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21646);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21646 SET z.entry = 21646, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21646;
DELETE FROM item_template WHERE entry = 21649 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21649);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21649 SET z.entry = 21649, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21649;
DELETE FROM item_template WHERE entry = 21653 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21653);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21653 SET z.entry = 21653, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21653;
DELETE FROM item_template WHERE entry = 21655 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21655);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21655 SET z.entry = 21655, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21655;
DELETE FROM item_template WHERE entry = 21656 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21656);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21656 SET z.entry = 21656, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21656;
DELETE FROM item_template WHERE entry = 21657 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21657);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21657 SET z.entry = 21657, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21657;
DELETE FROM item_template WHERE entry = 21658 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21658);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21658 SET z.entry = 21658, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21658;
DELETE FROM item_template WHERE entry = 21659 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21659);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21659 SET z.entry = 21659, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21659;
DELETE FROM item_template WHERE entry = 21660 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21660);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21660 SET z.entry = 21660, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21660;
DELETE FROM item_template WHERE entry = 21661 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21661);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21661 SET z.entry = 21661, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21661;
DELETE FROM item_template WHERE entry = 21662 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21662);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21662 SET z.entry = 21662, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21662;
DELETE FROM item_template WHERE entry = 21811 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21811);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21811 SET z.entry = 21811, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21811;
DELETE FROM item_template WHERE entry = 21923 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21923);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21923 SET z.entry = 21923, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21923;
DELETE FROM item_template WHERE entry = 21930 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21930);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21930 SET z.entry = 21930, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21930;
DELETE FROM item_template WHERE entry = 21962 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21962);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21962 SET z.entry = 21962, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21962;
DELETE FROM item_template WHERE entry = 21963 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21963);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21963 SET z.entry = 21963, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21963;
DELETE FROM item_template WHERE entry = 21964 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 21964);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 21964 SET z.entry = 21964, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 21964;
DELETE FROM item_template WHERE entry = 22026 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 22026);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 22026 SET z.entry = 22026, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 22026;
DELETE FROM item_template WHERE entry = 22027 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 22027);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 22027 SET z.entry = 22027, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 22027;
DELETE FROM item_template WHERE entry = 22045 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 22045);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 22045 SET z.entry = 22045, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 22045;
DELETE FROM item_template WHERE entry = 23228 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 23228);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 23228 SET z.entry = 23228, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 23228;
DELETE FROM item_template WHERE entry = 23245 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 23245);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 23245 SET z.entry = 23245, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 23245;
DELETE FROM item_template WHERE entry = 23325 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 23325);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 23325 SET z.entry = 23325, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 23325;
DELETE FROM item_template WHERE entry = 23696 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 23696);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 23696 SET z.entry = 23696, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 23696;
DELETE FROM item_template WHERE entry = 23698 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 23698);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 23698 SET z.entry = 23698, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 23698;
DELETE FROM item_template WHERE entry = 23699 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 23699);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 23699 SET z.entry = 23699, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 23699;
DELETE FROM item_template WHERE entry = 28209 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 28209);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 28209 SET z.entry = 28209, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 28209;
DELETE FROM item_template WHERE entry = 29225 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 29225);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 29225 SET z.entry = 29225, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 29225;
DELETE FROM item_template WHERE entry = 31716 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 31716);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 31716 SET z.entry = 31716, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 31716;
DELETE FROM item_template WHERE entry = 33183 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 33183);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 33183 SET z.entry = 33183, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 33183;
DELETE FROM item_template WHERE entry = 34484 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 34484);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 34484 SET z.entry = 34484, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 34484;
DELETE FROM item_template WHERE entry = 34486 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 34486);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 34486 SET z.entry = 34486, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 34486;
DELETE FROM item_template WHERE entry = 38265 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 38265);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 38265 SET z.entry = 38265, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 38265;
DELETE FROM item_template WHERE entry = 39163 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 39163);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 39163 SET z.entry = 39163, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 39163;
DELETE FROM item_template WHERE entry = 41605 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 41605);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 41605 SET z.entry = 41605, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 41605;
DELETE FROM item_template WHERE entry = 41606 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 41606);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 41606 SET z.entry = 41606, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 41606;
DELETE FROM item_template WHERE entry = 42590 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 42590);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 42590 SET z.entry = 42590, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 42590;
DELETE FROM item_template WHERE entry = 44114 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 44114);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 44114 SET z.entry = 44114, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 44114;
DELETE FROM item_template WHERE entry = 45026 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45026);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45026 SET z.entry = 45026, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45026;
DELETE FROM item_template WHERE entry = 45028 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45028);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45028 SET z.entry = 45028, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45028;
DELETE FROM item_template WHERE entry = 45029 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45029);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45029 SET z.entry = 45029, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45029;
DELETE FROM item_template WHERE entry = 45030 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45030);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45030 SET z.entry = 45030, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45030;
DELETE FROM item_template WHERE entry = 45031 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45031);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45031 SET z.entry = 45031, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45031;
DELETE FROM item_template WHERE entry = 45032 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45032);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45032 SET z.entry = 45032, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45032;
DELETE FROM item_template WHERE entry = 45033 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45033);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45033 SET z.entry = 45033, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45033;
DELETE FROM item_template WHERE entry = 45034 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45034);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45034 SET z.entry = 45034, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45034;
DELETE FROM item_template WHERE entry = 45035 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45035);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45035 SET z.entry = 45035, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45035;
DELETE FROM item_template WHERE entry = 45036 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45036);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45036 SET z.entry = 45036, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45036;
DELETE FROM item_template WHERE entry = 45199 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45199);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45199 SET z.entry = 45199, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45199;
DELETE FROM item_template WHERE entry = 45229 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45229);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45229 SET z.entry = 45229, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45229;
DELETE FROM item_template WHERE entry = 45230 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45230);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45230 SET z.entry = 45230, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45230;
DELETE FROM item_template WHERE entry = 45231 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45231);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45231 SET z.entry = 45231, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45231;
DELETE FROM item_template WHERE entry = 45568 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45568);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45568 SET z.entry = 45568, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45568;
DELETE FROM item_template WHERE entry = 45569 AND EXISTS (SELECT 1 FROM zerocraft_nbook WHERE item_entry = 45569);
DROP TEMPORARY TABLE IF EXISTS zc_b;
CREATE TEMPORARY TABLE zc_b SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_b z JOIN zerocraft_nbook b ON b.item_entry = 45569 SET z.entry = 45569, z.name = b.name, z.description = b.description, z.Quality = b.quality, z.stackable = 1, z.maxcount = 0, z.bonding = 0, z.displayid = 918, z.spellid_1 = 16872, z.ScriptName = 'item_zerocraft_nbook';
INSERT INTO item_template SELECT * FROM zc_b WHERE entry = 45569;
DROP TEMPORARY TABLE IF EXISTS zc_b;

-- bosses: 25% chance of an NPC Book (green 50 / blue 35 / purple 15)
DELETE FROM reference_loot_template WHERE Entry = 911090;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911090, b.item_entry, 0, 0, 0, 1, 1, 1, 1, b.name FROM zerocraft_nbook b;
DROP TEMPORARY TABLE IF EXISTS zc_q;
CREATE TEMPORARY TABLE zc_q SELECT quality, COUNT(*) AS n FROM zerocraft_nbook GROUP BY quality;
UPDATE reference_loot_template r JOIN zerocraft_nbook b ON b.item_entry = r.Item JOIN zc_q q ON q.quality = b.quality
SET r.Chance = ROUND(CASE b.quality WHEN 2 THEN 50 WHEN 3 THEN 35 ELSE 15 END / q.n, 3) WHERE r.Entry = 911090;
DELETE FROM creature_loot_template WHERE Reference = 911090;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT Entry, 911090, 911090, 25, 0, 1, 0, 1, 1, 'ZeroCraft NPC book' FROM creature_loot_template WHERE Reference = 911000;

SELECT name, quality FROM zerocraft_nbook ORDER BY item_entry;
SELECT COUNT(*) AS places, SUM(inst) AS dungeons_and_raids, SUM(npcs) AS npcs_total FROM zc_loccount;
SELECT COUNT(*) AS npcs_in_books FROM zerocraft_nbook_npcs WHERE idx > 0;
SELECT COUNT(*) AS book_items FROM item_template WHERE ScriptName = 'item_zerocraft_nbook';
SELECT quality, COUNT(*) AS books FROM zerocraft_nbook GROUP BY quality;

-- Flight Master scrolls sprinkled through dungeons and raids: every elite there has a 2% chance to drop one
-- (bosses already drop them through the NPC scroll roll).
DROP TEMPORARY TABLE IF EXISTS zc_instelite;
CREATE TEMPORARY TABLE zc_instelite (lootid INT UNSIGNED PRIMARY KEY);
SET @q = CONCAT('INSERT IGNORE INTO zc_instelite SELECT ct.lootid FROM creature c JOIN creature_template ct ON ct.entry = c.', @idcol,
  ' WHERE c.map IN (SELECT id FROM zc_maps WHERE inst = 1) AND ct.`rank` >= 1 AND ct.lootid > 0');
PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
DELETE FROM creature_loot_template WHERE Item = 3504 AND Reference = 0 AND Comment = 'ZeroCraft Flight Master scroll';
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 3504, 0, 2, 0, 1, 0, 1, 1, 'ZeroCraft Flight Master scroll' FROM zc_instelite;
SELECT COUNT(*) AS dungeon_elites_dropping_flight_scrolls FROM zc_instelite;
