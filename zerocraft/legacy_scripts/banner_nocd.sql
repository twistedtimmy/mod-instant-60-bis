USE acore_world;
-- Commander's Banner: use an instant ground-target spell with no global cooldown
UPDATE item_template SET spellid_1 = 24340, spellcooldown_1 = -1, spellcategory_1 = 0, spellcategorycooldown_1 = -1 WHERE entry = 911004;
SELECT entry, name, spellid_1 FROM item_template WHERE entry = 911004;
