USE acore_world;
DELETE FROM spell_script_names WHERE spell_id = 24340 AND ScriptName = 'spell_zerocraft_command';
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES (24340, 'spell_zerocraft_command');
SELECT * FROM spell_script_names WHERE spell_id = 24340;
