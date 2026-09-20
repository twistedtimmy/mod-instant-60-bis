-- ZeroCraft: every Builder's Scroll gets the diamond icon and a builder's "Use:" line (spell 42362, text patched in patch-Y.MPQ).
USE acore_world;
UPDATE item_template SET displayid = 4775, spellid_1 = 42362
WHERE entry IN (SELECT item_entry FROM zerocraft_bscroll);
SELECT COUNT(*) AS scrolls_with_diamond_icon FROM item_template WHERE displayid = 4775 AND spellid_1 = 42362;
