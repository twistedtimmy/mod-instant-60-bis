USE acore_world;
DELETE FROM spell_script_names WHERE spell_id = 5505 AND ScriptName = 'spell_zerocraft_deploy_conjure';
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES (5505, 'spell_zerocraft_deploy_conjure');
SELECT * FROM spell_script_names WHERE ScriptName = 'spell_zerocraft_deploy_conjure';
SELECT COUNT(DISTINCT r.id) AS guard_types_left FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.flags_extra & 0x8000) <> 0 AND ct.minlevel >= 50 AND ct.`rank` <> 3;
