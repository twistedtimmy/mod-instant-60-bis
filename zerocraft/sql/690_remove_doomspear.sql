-- ZeroCraft: the Pit Lord glaive (60416) rendered badly - gone for good
DELETE FROM acore_characters.item_instance WHERE itemEntry = 60416;
DELETE FROM acore_characters.character_inventory WHERE item NOT IN (SELECT guid FROM acore_characters.item_instance);
SELECT COUNT(*) AS doomspears_left FROM acore_characters.item_instance WHERE itemEntry = 60416;
