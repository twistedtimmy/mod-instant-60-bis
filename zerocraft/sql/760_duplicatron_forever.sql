-- ZeroCraft: the Duplicatron is never used up; one per character is enough
UPDATE acore_world.item_template SET maxcount = 1, stackable = 1,
  description = '"Patent pending. Do not lick." Click something you built, choose Duplicate, then click the ground to place a copy. Never wears out.'
WHERE entry = 60410;
DELETE FROM acore_world.creature_loot_template WHERE Item = 60410;   -- everyone already has one
SELECT entry, name, maxcount, description FROM acore_world.item_template WHERE entry = 60410;
