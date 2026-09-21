-- ZeroCraft: the Builder's Catalog (item 23656) becomes the Master Builder's Tome.
-- Click a spot on the ground and the Master Builder window opens: every object and every NPC, with previews.
USE acore_world;
UPDATE item_template SET name = 'Master Builder''s Tome', Quality = 5, bonding = 1, stackable = 1, maxcount = 1,
  description = 'Click a spot on the ground. Every object and every NPC you can build or recruit, with a preview of each.',
  ScriptName = 'item_zerocraft_master' WHERE entry = 23656;
SELECT entry, name, ScriptName FROM item_template WHERE entry = 23656;
