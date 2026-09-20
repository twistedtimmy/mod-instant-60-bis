-- ZeroCraft: Titan's Grip, Shield Mastery and Beastmaster scrolls (60401-60406) are scrapped - no drops, and every copy is removed
DELETE FROM acore_world.creature_loot_template WHERE Item IN (60401, 60402, 60403, 60404, 60405, 60406);
DELETE FROM acore_world.reference_loot_template WHERE Item IN (60401, 60402, 60403, 60404, 60405, 60406);
DELETE FROM acore_world.gameobject_loot_template WHERE Item IN (60401, 60402, 60403, 60404, 60405, 60406);
DELETE ci FROM acore_characters.character_inventory ci JOIN acore_characters.item_instance ii ON ii.guid = ci.item WHERE ii.itemEntry IN (60401, 60402, 60403, 60404, 60405, 60406);
DELETE FROM acore_characters.item_instance WHERE itemEntry IN (60401, 60402, 60403, 60404, 60405, 60406);
SELECT COUNT(*) AS titan_scrolls_left FROM acore_characters.item_instance WHERE itemEntry IN (60401, 60402, 60403, 60404, 60405, 60406);
