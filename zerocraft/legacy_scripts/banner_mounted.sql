USE acore_world;
-- Commander's Banner: ground circle from ground circle, instant, no cooldown, usable mounted and flying, unlimited range
UPDATE item_template SET spellid_1 = 35070 WHERE entry = 23701;
SELECT entry, name, spellid_1 FROM item_template WHERE entry = 23701;
