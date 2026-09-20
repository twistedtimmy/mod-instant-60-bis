-- ZeroCraft: report deployed heroes and their template flags (diagnostic only, changes nothing)
USE acore_world;
SELECT d.spawn_id, ct.entry, ct.name, ct.unit_flags, ct.unit_flags2, ct.VehicleId, ct.ScriptName
FROM zerocraft_deployables d JOIN creature_template ct ON ct.entry = d.entry
WHERE d.entry IN (SELECT entry FROM zerocraft_hero_pool);
