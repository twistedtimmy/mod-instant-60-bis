-- ZeroCraft: remove every copy of the scrapped scrolls (60401-60406)
USE acore_characters;
DELETE ci FROM character_inventory ci JOIN item_instance ii ON ii.guid = ci.item WHERE ii.itemEntry IN (60401, 60402, 60403, 60404, 60405, 60406);
DELETE FROM item_instance WHERE itemEntry IN (60401, 60402, 60403, 60404, 60405, 60406);
SELECT COUNT(*) AS scrolls_left FROM item_instance WHERE itemEntry IN (60401, 60402, 60403, 60404, 60405, 60406);
SELECT COUNT(*) AS drops_left FROM acore_world.creature_loot_template WHERE Item IN (60401, 60402, 60403, 60404, 60405, 60406);
