USE acore_world;
-- deploy items now use Flamestrike (Rank 1) purely for its ground-targeting circle
UPDATE item_template SET spellid_1 = 2120, description = 'Place it, then cast for 5 seconds to deploy a loyal NPC.' WHERE entry IN (911001, 911002);
DELETE FROM spell_script_names WHERE spell_id = 5504 AND ScriptName = 'spell_zerocraft_deploy_conjure';
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES (5504, 'spell_zerocraft_deploy_conjure');
SELECT entry, name, spellid_1 FROM item_template WHERE entry IN (911001, 911002);
