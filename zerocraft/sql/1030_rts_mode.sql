-- ZeroCraft: RTS Mode toggle - the Marshal's Spyglass (item 33336, an unused retail spyglass).
USE acore_world;
DELETE FROM item_template WHERE entry = 33336;
DROP TEMPORARY TABLE IF EXISTS zc_rts; CREATE TEMPORARY TABLE zc_rts SELECT * FROM item_template WHERE entry = 23656;
UPDATE zc_rts SET entry = 33336, name = 'RTS Mode: Marshal''s Spyglass', displayid = 7358, Quality = 5, bonding = 1, stackable = 1, maxcount = 1,
  spellid_1 = 21342, spelltrigger_1 = 0, spellcooldown_1 = -1,
  description = 'Use to switch RTS Mode on or off: fly over the battlefield, top-down camera, and your action bar becomes command hotkeys.',
  ScriptName = 'item_zerocraft_rts';
INSERT INTO item_template SELECT * FROM zc_rts; DROP TEMPORARY TABLE zc_rts;
SELECT entry, name, ScriptName FROM item_template WHERE entry = 33336;
