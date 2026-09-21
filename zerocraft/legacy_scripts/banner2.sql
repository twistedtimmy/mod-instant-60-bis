USE acore_world;
DELETE FROM spell_script_names WHERE ScriptName = 'spell_zerocraft_command';
UPDATE item_template SET displayid = 31257, ScriptName = 'item_zerocraft_command' WHERE entry = 911004;
SELECT entry, name, displayid, spellid_1, ScriptName FROM item_template WHERE entry = 911004;
