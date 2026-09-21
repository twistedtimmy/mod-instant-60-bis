-- ZeroCraft: the Master GM Codex (item 6777, an unused retail quest item with a golden tome icon).
-- GM accounts carry it; it opens a window with every GM command as a button.
USE acore_world;
DELETE FROM item_template WHERE entry = 6777;
DROP TEMPORARY TABLE IF EXISTS zc_gm; CREATE TEMPORARY TABLE zc_gm SELECT * FROM item_template WHERE entry = 23656;
UPDATE zc_gm SET entry = 6777, name = 'Master GM Codex', displayid = 13006, Quality = 5, bonding = 1, stackable = 1, maxcount = 1,
  spellid_1 = 0, spelltrigger_1 = 0,
  description = 'Every Game Master command, as a button. Only a GM account can read it.',
  ScriptName = 'item_zerocraft_gm';
INSERT INTO item_template SELECT * FROM zc_gm; DROP TEMPORARY TABLE zc_gm;
SELECT entry, name, ScriptName FROM item_template WHERE entry = 6777;
