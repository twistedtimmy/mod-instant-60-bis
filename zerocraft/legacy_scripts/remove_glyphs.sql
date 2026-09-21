-- ZeroCraft: no glyphs
INSERT IGNORE INTO acore_world.disables (sourceType, entry, flags, comment)
SELECT DISTINCT 0, spellid_1, 1, 'ZeroCraft: no glyphs'
FROM acore_world.item_template
WHERE class = 16 AND spellid_1 > 0;

DELETE FROM acore_characters.character_glyphs;

SELECT COUNT(*) AS glyph_spells_disabled FROM acore_world.disables WHERE comment = 'ZeroCraft: no glyphs';
