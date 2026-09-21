-- ZeroCraft: the Master GM Codex opens like the Builder's Tome and Recruiter's Orders: the same ground-target
-- cast (the green circle), then the window. Without a Use spell the client never sends a click.
USE acore_world;
UPDATE item_template SET spellid_1 = 2120, spelltrigger_1 = 0, spellcooldown_1 = -1, spellcategory_1 = 0, spellcategorycooldown_1 = -1 WHERE entry = 6777;
SELECT entry, name, spellid_1 FROM item_template WHERE entry = 6777;
