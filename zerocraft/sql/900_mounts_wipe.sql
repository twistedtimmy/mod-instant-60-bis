-- ZeroCraft: no mounts handed out at creation; every character is wiped down to the Rooster + race mount once more
USE acore_world;
DELETE FROM playercreateinfo_spell_custom WHERE Spell IN (23229, 23238, 23241, 23225, 35710, 23250, 23246, 23249, 23257, 35025, 60025, 32242, 5784, 23161, 13819, 23214, 34769, 34767, 65917);
DELETE FROM acore_characters.zerocraft_mounts_reset;
SELECT COUNT(*) AS mount_spells_at_creation_now FROM playercreateinfo_spell_custom WHERE Spell IN (23229, 23238, 23241, 23225, 35710, 23250, 23246, 23249, 23257, 35025);
