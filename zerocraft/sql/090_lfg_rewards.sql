-- ZeroCraft: Dungeon Finder rewards are NPC scrolls instead of emblems.
-- The level-60 "Satchel of Helpful Goods" becomes "Satchel of Scrolls" and holds one random NPC scroll
-- (same pool bosses drop). Random Dungeon gives 1 satchel, Random Heroic gives 2 - every run, not just daily.
USE acore_world;
SET @sat := (SELECT RewardItem1 FROM quest_template WHERE ID = 24886);

UPDATE item_template SET name = 'Satchel of Scrolls', description = 'Contains a deployable NPC scroll.' WHERE entry = @sat;
DELETE FROM item_loot_template WHERE Entry = @sat;
INSERT INTO item_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES (@sat, 0, 911000, 100, 0, 1, 0, 1, 1, 'ZeroCraft: one NPC scroll');

UPDATE quest_template SET
  RewardItem1 = @sat, RewardAmount1 = IF(ID IN (24788, 24789), 2, 1),
  RewardItem2 = 0, RewardAmount2 = 0, RewardItem3 = 0, RewardAmount3 = 0, RewardItem4 = 0, RewardAmount4 = 0,
  RewardChoiceItemID1 = 0, RewardChoiceItemQuantity1 = 0, RewardChoiceItemID2 = 0, RewardChoiceItemQuantity2 = 0,
  RewardChoiceItemID3 = 0, RewardChoiceItemQuantity3 = 0, RewardChoiceItemID4 = 0, RewardChoiceItemQuantity4 = 0,
  RewardChoiceItemID5 = 0, RewardChoiceItemQuantity5 = 0, RewardChoiceItemID6 = 0, RewardChoiceItemQuantity6 = 0
WHERE ID IN (24790, 24791, 24788, 24789);

SELECT @sat AS satchel, (SELECT name FROM item_template WHERE entry = @sat) AS name;
SELECT ID, LogTitle, RewardItem1, RewardAmount1, RewardMoney FROM quest_template WHERE ID IN (24790, 24791, 24788, 24789);
