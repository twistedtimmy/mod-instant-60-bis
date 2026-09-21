USE acore_world;
SELECT r.id, ct.name, ct.maxlevel, ct.`rank` FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.flags_extra & 0x8000) <> 0 AND (ct.`rank` = 3 OR ct.maxlevel > 70) GROUP BY r.id, ct.name, ct.maxlevel, ct.`rank`;
