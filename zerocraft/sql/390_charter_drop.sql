-- ZeroCraft: the Founder's Charter now drops from dungeon and raid bosses (3%) instead of being handed out.
USE acore_world;
SET @charter = (SELECT entry FROM item_template WHERE ScriptName = 'item_zerocraft_guild_charter' LIMIT 1);
DELETE FROM creature_loot_template WHERE Item = @charter AND Reference = 0;
INSERT IGNORE INTO creature_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
SELECT DISTINCT Entry, @charter, 0, 3, 0, 1, 0, 1, 1, 'ZeroCraft Founder''s Charter' FROM creature_loot_template WHERE Reference = 911000;
SELECT @charter AS charter_item, COUNT(*) AS bosses_dropping_charter FROM creature_loot_template WHERE Item = @charter;
