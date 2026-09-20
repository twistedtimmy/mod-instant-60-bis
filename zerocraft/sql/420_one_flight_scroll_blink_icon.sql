-- ZeroCraft: new characters start with 1 Flight Master scroll (was 5); Jaina's Dimensional Pocket uses the Blink icon.
USE acore_world;
UPDATE playercreateinfo_item SET amount = 1 WHERE itemid = 3504;
UPDATE item_template SET displayid = 22485 WHERE entry = 14156;
SELECT MIN(amount) AS flight_scrolls FROM playercreateinfo_item WHERE itemid = 3504;
SELECT name, displayid FROM item_template WHERE entry = 14156;
-- Frostmourne: the NPC version had no weapon material / an odd sound class, which can upset sheathing. Make it a normal metal two-hander.
UPDATE item_template SET Material = 1, SoundOverrideSubclass = -1, sheath = 1 WHERE entry = 36942;
SELECT entry, Material, SoundOverrideSubclass, sheath FROM item_template WHERE entry = 36942;
