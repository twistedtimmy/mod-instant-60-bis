-- ZeroCraft: Buru the Gorger (Ruins of Ahn'Qiraj) always drops one Scroll of Titan's Grip (swords, axes, maces or staves)
USE acore_world;
DELETE FROM reference_loot_template WHERE Entry = 911095;
INSERT INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) VALUES
 (911095, 60401, 0, 0, 0, 1, 1, 1, 1, 'Titan''s Grip: Swords'), (911095, 60402, 0, 0, 0, 1, 1, 1, 1, 'Titan''s Grip: Axes'),
 (911095, 60403, 0, 0, 0, 1, 1, 1, 1, 'Titan''s Grip: Maces'), (911095, 60404, 0, 0, 0, 1, 1, 1, 1, 'Titan''s Grip: Staves');
UPDATE creature_template SET lootid = entry WHERE name = 'Buru the Gorger' AND lootid = 0;
DELETE FROM creature_loot_template WHERE Reference = 911095;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT lootid, 911095, 911095, 100, 0, 1, 0, 1, 1, 'ZeroCraft Titan''s Grip scroll' FROM creature_template WHERE name = 'Buru the Gorger' AND lootid > 0;
SELECT ct.entry, ct.name, ct.lootid FROM creature_template ct JOIN creature_loot_template t ON t.Entry = ct.lootid AND t.Reference = 911095;
