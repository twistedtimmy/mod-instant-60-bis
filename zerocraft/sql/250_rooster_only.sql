-- ZeroCraft: the Magic Rooster is the only mount - no other mounts at character creation
USE acore_world;
DELETE s FROM playercreateinfo_spell_custom s
WHERE s.Spell IN (23229, 23238, 23241, 23225, 35710, 23250, 23246, 23249, 23257, 35025, 60025, 32242, 5784, 23161, 13819, 23214, 34769, 34767);
DELETE FROM playercreateinfo_action WHERE type = 0 AND action IN (23229, 23249, 23241, 60025, 32242);
SELECT COUNT(*) AS mount_spells_left_at_creation FROM playercreateinfo_spell_custom WHERE Spell IN (23229, 23249, 23241, 60025, 32242);
