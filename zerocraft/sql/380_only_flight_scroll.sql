-- ZeroCraft: the single NPC scrolls are retired - NPC Books replace them. Only the Flight Master scroll stays.
USE acore_world;
DELETE FROM playercreateinfo_item WHERE itemid IN (823, 842, 951, 1078, 3513, 25747, 25748, 1267, 6213, 17163);
DELETE FROM reference_loot_template WHERE Entry = 911000 AND Item IN (823, 842, 951, 1078, 3513, 25747, 25748, 1267, 6213, 17163);
DELETE FROM creature_loot_template WHERE Item IN (823, 842, 951, 1078, 3513, 25747, 25748, 1267, 6213, 17163) AND Reference = 0;
SELECT Item, Chance FROM reference_loot_template WHERE Entry = 911000;
SELECT itemid, MIN(amount) AS amount FROM playercreateinfo_item WHERE itemid = 3504 GROUP BY itemid;
