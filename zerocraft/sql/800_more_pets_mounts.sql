-- ZeroCraft: many more companion pets and mounts from bosses.
-- Every dungeon and raid boss: 30% pet, 20% mount. Raid bosses roll a second time (so about 51% pet, 36% mount).
USE acore_world;
DROP TEMPORARY TABLE IF EXISTS zc_allboss;
CREATE TEMPORARY TABLE zc_allboss SELECT DISTINCT Entry FROM creature_loot_template WHERE Reference = 911000;
DROP TEMPORARY TABLE IF EXISTS zc_raid;
CREATE TEMPORARY TABLE zc_raid (lootid INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_raid SELECT DISTINCT ct.lootid FROM creature c JOIN creature_template ct ON ct.entry = c.id
  JOIN zc_allboss b ON b.Entry = ct.lootid
  WHERE c.map IN (249,309,409,469,509,531,532,533,534,544,548,550,564,565,568,580,603,615,616,624,631,649,724);
-- heroic / 25-man versions of raid bosses
INSERT IGNORE INTO zc_raid SELECT d.lootid FROM creature_template b JOIN zc_raid r ON r.lootid = b.lootid
  JOIN creature_template d ON d.entry IN (b.difficulty_entry_1, b.difficulty_entry_2, b.difficulty_entry_3) WHERE d.lootid > 0;
DELETE FROM creature_loot_template WHERE Reference IN (911070, 911080);
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT Entry, 911070, 911070, 30, 0, 1, 0, 1, 1, 'ZeroCraft companion pet' FROM zc_allboss;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT Entry, 911080, 911080, 20, 0, 1, 0, 1, 1, 'ZeroCraft mount' FROM zc_allboss;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911071, 911070, 30, 0, 1, 0, 1, 1, 'ZeroCraft companion pet (raid bonus)' FROM zc_raid;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911081, 911080, 20, 0, 1, 0, 1, 1, 'ZeroCraft mount (raid bonus)' FROM zc_raid;
SELECT COUNT(*) AS bosses_dropping_pets_and_mounts FROM zc_allboss;
SELECT COUNT(*) AS raid_bosses_with_bonus FROM zc_raid;
SELECT (SELECT COUNT(*) FROM reference_loot_template WHERE Entry = 911070) AS pets_in_pool, (SELECT COUNT(*) FROM reference_loot_template WHERE Entry = 911080) AS mounts_in_pool;
-- Raid bosses are worth it: two cool furniture pieces every time, and a 5% shot at a random legendary.
-- Dungeon bosses: 1% shot at a random legendary. (Each legendary's own boss still drops it at its usual rate too.)
DELETE FROM reference_loot_template WHERE Entry = 911096;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) VALUES
 (911096, 17182, 0, 0, 0, 1, 1, 1, 1, 'Sulfuras'),
 (911096, 32837, 0, 0, 0, 1, 1, 1, 1, 'Warglaive MH'), (911096, 32838, 0, 0, 0, 1, 1, 1, 1, 'Warglaive OH'),
 (911096, 22589, 0, 0, 0, 1, 1, 1, 1, 'Atiesh mage'), (911096, 22630, 0, 0, 0, 1, 1, 1, 1, 'Atiesh warlock'),
 (911096, 22631, 0, 0, 0, 1, 1, 1, 1, 'Atiesh priest'), (911096, 22632, 0, 0, 0, 1, 1, 1, 1, 'Atiesh druid'),
 (911096, 60411, 0, 0, 0, 1, 1, 1, 1, 'Doomhammer'), (911096, 60412, 0, 0, 0, 1, 1, 1, 1, 'Spellbreaker'),
 (911096, 60413, 0, 0, 0, 1, 1, 1, 1, 'Crest of Silvermoon'), (911096, 60414, 0, 0, 0, 1, 1, 1, 1, 'Earthmother''s Fury'),
 (911096, 60415, 0, 0, 0, 1, 1, 1, 1, 'Warbringer'), (911096, 60417, 0, 0, 0, 1, 1, 1, 1, 'Stormharpoon'),
 (911096, 60418, 0, 0, 0, 1, 1, 1, 1, 'Moonglaive of Elune');
DELETE FROM creature_loot_template WHERE Reference = 911096;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT Entry, 911096, 911096, 1, 0, 1, 0, 1, 1, 'ZeroCraft random legendary' FROM zc_allboss;
UPDATE creature_loot_template t JOIN zc_raid r ON r.lootid = t.Entry SET t.Chance = 5 WHERE t.Reference = 911096;
-- raid bosses: the second cool furniture piece is certain
UPDATE creature_loot_template t JOIN zc_raid r ON r.lootid = t.Entry SET t.Chance = 100 WHERE t.Reference = 911110 AND t.Item = 911112;
SELECT COUNT(*) AS raid_bosses_two_cool_pieces FROM creature_loot_template t JOIN zc_raid r ON r.lootid = t.Entry WHERE t.Reference = 911110 AND t.Item = 911112 AND t.Chance = 100;
-- Raid bosses: exactly one mount every kill (instead of the 20% + 20% rolls)
DELETE t FROM creature_loot_template t JOIN zc_raid r ON r.lootid = t.Entry WHERE t.Reference = 911080 AND t.Item = 911081;
UPDATE creature_loot_template t JOIN zc_raid r ON r.lootid = t.Entry SET t.Chance = 100 WHERE t.Reference = 911080 AND t.Item = 911080;
SELECT COUNT(*) AS raid_bosses_one_mount_each FROM creature_loot_template t JOIN zc_raid r ON r.lootid = t.Entry WHERE t.Reference = 911080 AND t.Chance = 100;
-- no mounts sold anywhere: every vendor item that teaches a mount is removed from vendors
DELETE v FROM npc_vendor v JOIN item_template i ON i.entry = v.item
WHERE (i.class = 15 AND i.subclass = 5) AND i.entry NOT IN (SELECT Item FROM reference_loot_template WHERE Entry = 0);
SELECT ROW_COUNT() AS mount_vendor_rows_removed;
