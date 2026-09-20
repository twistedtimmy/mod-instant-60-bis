-- ZeroCraft: Builder's Scrolls are simply used - no ground circle; things build right in front of you.
USE acore_world;
UPDATE item_template SET spellid_1 = 21342 WHERE entry IN (SELECT item_entry FROM zerocraft_bscroll);
SELECT COUNT(*) AS scrolls_self_use FROM item_template WHERE spellid_1 = 21342;
