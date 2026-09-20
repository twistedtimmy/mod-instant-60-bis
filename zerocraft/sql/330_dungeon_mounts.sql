-- ZeroCraft: ground mounts drop from dungeon bosses (uncommon, rare and epic mounts, by rarity).
-- Flying mounts and the Magic Rooster are left out. Every dungeon boss has a 5% chance to drop one.
USE acore_world;
DROP TEMPORARY TABLE IF EXISTS zc_ground;
CREATE TEMPORARY TABLE zc_ground (spell INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_ground VALUES (458),(459),(468),(470),(471),(472),(578),(579),(580),(581),(5784),(6648),(6653),(6654),(6777),(6896),(6897),(6898),(6899),(8394),(8395),(8396),(8980),(10787),(10788),(10789),(10790),(10792),(10793),(10795),(10796),(10798),(10799),(10800),(10801),(10802),(10803),(10804),(10873),(10969),(13819),(15779),(15780),(15781),(16055),(16056),(16058),(16059),(16060),(16080),(16081),(16082),(16083),(16084),(17229),(17450),(17453),(17454),(17455),(17456),(17458),(17459),(17460),(17461),(17462),(17463),(17464),(17465),(17481),(18363),(18989),(18990),(18991),(18992),(22717),(22718),(22719),(22720),(22721),(22722),(22723),(22724),(23161),(23214),(23219),(23220),(23221),(23222),(23223),(23225),(23227),(23228),(23229),(23238),(23239),(23240),(23241),(23242),(23243),(23246),(23247),(23248),(23249),(23250),(23251),(23252),(23338),(23509),(23510),(24242),(24252),(24576),(25675),(25858),(25859),(25863),(25953),(26054),(26055),(26056),(26332),(26655),(26656),(28828),(29059),(30174),(30829),(30837),(31973),(32420),(33630),(33631),(33660),(34068),(34406),(34407),(34767),(34769),(34790),(34795),(34896),(34897),(34898),(34899),(35018),(35020),(35022),(35025),(35027),(35028),(35710),(35711),(35712),(35713),(35714),(36702),(39315),(39316),(39317),(39318),(39319),(39450),(39910),(41252),(42363),(42387),(42680),(42683),(42692),(42776),(42777),(42929),(43688),(43880),(43883),(43899),(43900),(45177),(46628),(46980),(47037),(47977),(48024),(48025),(48027),(48778),(48954),(49322),(49378),(49379),(49908),(50281),(50869),(50870),(51412),(51621),(54729),(54753),(55293),(55531),(58819),(58983),(58997),(58999),(59572),(59573),(59785),(59788),(59791),(59793),(59797),(59799),(59802),(59804),(60114),(60116),(60118),(60119),(60120),(60136),(60140),(60424),(61289),(61425),(61442),(61444),(61446),(61447),(61465),(61467),(61469),(61470),(61983),(63232),(63635),(63636),(63637),(63638),(63639),(63640),(63641),(63642),(63643),(64656),(64657),(64658),(64659),(64731),(64977),(64992),(64993),(65637),(65638),(65639),(65640),(65641),(65642),(65643),(65644),(65645),(65646),(66090),(66091),(66846),(66847),(66906),(66907),(67466),(68056),(68057),(68187),(68188),(68768),(68769),(71342),(71343),(71344),(71345),(72281),(72282),(72286),(73313),(74856),(74918),(75387),(75614),(75619),(75620),(75973);
DROP TEMPORARY TABLE IF EXISTS zc_mounts;
CREATE TEMPORARY TABLE zc_mounts
SELECT entry, name, Quality, CASE Quality WHEN 2 THEN 10 WHEN 3 THEN 5 ELSE 1 END AS w
FROM item_template
WHERE class = 15 AND subclass = 5 AND Quality BETWEEN 2 AND 4
  AND EXISTS (SELECT 1 FROM zc_ground g WHERE g.spell IN (spellid_1, spellid_2))
  AND name NOT LIKE '%test%' AND name NOT LIKE '%deprecated%' AND name NOT LIKE '%[PH]%' AND name NOT LIKE '%unused%'
  AND name NOT LIKE '%Invincible%' AND name NOT LIKE '%Celestial Steed%' AND name NOT LIKE '%Headless Horseman%'
  AND name NOT LIKE '%Touring Rocket%' AND name NOT LIKE '%Rooster%';
-- anyone can learn them: no faction, race, class or reputation locks; riding 150 is enough; level 60 is enough
UPDATE item_template i JOIN zc_mounts m ON m.entry = i.entry SET
  i.AllowableRace = -1, i.AllowableClass = -1, i.FlagsExtra = i.FlagsExtra & ~3,
  i.RequiredReputationFaction = 0, i.RequiredReputationRank = 0,
  i.RequiredLevel = LEAST(i.RequiredLevel, 60),
  i.RequiredSkillRank = IF(i.RequiredSkill = 762, LEAST(i.RequiredSkillRank, 150), i.RequiredSkillRank),
  i.RequiredCityRank = 0, i.requiredhonorrank = 0;
SET @zc_total = (SELECT SUM(w) FROM zc_mounts);
DELETE FROM reference_loot_template WHERE Entry = 911080;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT 911080, m.entry, 0, ROUND(m.w * 100 / @zc_total, 3), 0, 1, 1, 1, 1, CONCAT('ZeroCraft mount - ', m.name)
FROM zc_mounts m;
DROP TEMPORARY TABLE IF EXISTS zc_dboss;
CREATE TEMPORARY TABLE zc_dboss (lootid INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_dboss
SELECT ct.lootid FROM creature_template ct
WHERE ct.rank = 3 AND ct.lootid > 0 AND ct.entry IN (SELECT id1 FROM creature WHERE map IN (33,34,36,43,47,48,70,90,109,129,189,209,229,230,289,329,349,389,429,269,540,542,543,545,546,547,552,553,554,555,556,557,558,560,585,574,575,576,578,595,599,600,601,602,604,608,619,632,650,658,668));
INSERT IGNORE INTO zc_dboss
SELECT d.lootid FROM creature_template ct
JOIN creature_template d ON d.entry IN (ct.difficulty_entry_1, ct.difficulty_entry_2, ct.difficulty_entry_3)
WHERE ct.rank = 3 AND d.lootid > 0 AND ct.entry IN (SELECT id1 FROM creature WHERE map IN (33,34,36,43,47,48,70,90,109,129,189,209,229,230,289,329,349,389,429,269,540,542,543,545,546,547,552,553,554,555,556,557,558,560,585,574,575,576,578,595,599,600,601,602,604,608,619,632,650,658,668));
DELETE FROM creature_loot_template WHERE Reference = 911080;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911080, 911080, 5, 0, 1, 0, 1, 1, 'ZeroCraft ground mount' FROM zc_dboss;
SELECT Quality, COUNT(*) AS ground_mounts FROM zc_mounts GROUP BY Quality;
SELECT COUNT(*) AS dungeon_bosses_dropping_mounts FROM zc_dboss;
DROP TEMPORARY TABLE zc_ground; DROP TEMPORARY TABLE zc_mounts; DROP TEMPORARY TABLE zc_dboss;

USE acore_characters;
CREATE TABLE IF NOT EXISTS zerocraft_mounts_reset (guid INT UNSIGNED NOT NULL PRIMARY KEY) ENGINE=InnoDB;
