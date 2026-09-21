-- ZeroCraft: the Master Recruiter's Orders (item 28099, an unused retail quest item with a sealed-orders icon).
-- A second tome that opens the Master Builder straight on the Recruit tab: every soldier and NPC, with previews.
USE acore_world;
DELETE FROM item_template WHERE entry = 28099;
DROP TEMPORARY TABLE IF EXISTS zc_mr; CREATE TEMPORARY TABLE zc_mr SELECT * FROM item_template WHERE entry = 23656;
UPDATE zc_mr SET entry = 28099, name = 'Master Recruiter''s Orders', displayid = 6270, Quality = 5, bonding = 1, stackable = 1, maxcount = 1,
  description = 'Click a spot on the ground. Every soldier, hero and NPC you can recruit, with a preview of each.',
  ScriptName = 'item_zerocraft_master';
INSERT INTO item_template SELECT * FROM zc_mr; DROP TEMPORARY TABLE zc_mr;
SELECT entry, name, ScriptName FROM item_template WHERE entry IN (23656, 28099);
