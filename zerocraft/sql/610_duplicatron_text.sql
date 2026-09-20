-- ZeroCraft: Duplicatron always works now
UPDATE acore_world.item_template SET description = '"Patent pending. Do not lick." Click something you built, choose Duplicate, then click the ground to place a copy. Single use.' WHERE entry = 60410;
SELECT entry, description FROM acore_world.item_template WHERE entry = 60410;
