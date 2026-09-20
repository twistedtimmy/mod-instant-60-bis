-- ZeroCraft: faction soldiers join the Guard scroll pool (kind = 'faction')
USE acore_world;
DELETE FROM zerocraft_guard_pool WHERE kind = 'faction';

DROP TEMPORARY TABLE IF EXISTS zc_diff;
CREATE TEMPORARY TABLE zc_diff (entry INT PRIMARY KEY);
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_1 FROM creature_template WHERE difficulty_entry_1 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_2 FROM creature_template WHERE difficulty_entry_2 > 0;
INSERT IGNORE INTO zc_diff SELECT difficulty_entry_3 FROM creature_template WHERE difficulty_entry_3 > 0;

DROP TEMPORARY TABLE IF EXISTS zc_spawned;
CREATE TEMPORARY TABLE zc_spawned (entry INT PRIMARY KEY);
INSERT IGNORE INTO zc_spawned SELECT id FROM creature WHERE map IN (0,1,30,530,571);
INSERT IGNORE INTO zc_spawned SELECT id FROM zerocraft_removed_creatures;

INSERT IGNORE INTO zerocraft_guard_pool (entry, kind, name)
SELECT ct.entry, 'faction', ct.name FROM creature_template ct JOIN zc_spawned s ON s.entry = ct.entry
WHERE ct.type = 7 AND (ct.npcflag & ~1) = 0 AND ct.`rank` IN (0,1) AND ct.maxlevel >= 55
  AND (ct.unit_flags & 0x02000000) = 0 AND (ct.flags_extra & 0x80) = 0
  AND (ct.name LIKE 'Argent %' OR ct.name LIKE 'Kirin Tor %' OR ct.name LIKE '%Ebon Blade%' OR ct.name LIKE 'Knight of the Ebon%'
    OR ct.name LIKE 'Scarlet %' OR ct.name LIKE 'Cenarion %' OR ct.name LIKE 'Shattered Sun %' OR ct.name LIKE 'Wyrmrest %'
    OR ct.name LIKE 'Sunreaver %' OR ct.name LIKE 'Silver Covenant %' OR ct.name LIKE 'Kor''kron %' OR ct.name LIKE 'Warsong %'
    OR ct.name LIKE 'Valiance %' OR ct.name LIKE '7th Legion %' OR ct.name LIKE 'Skybreaker %' OR ct.name LIKE 'Aldor %'
    OR ct.name LIKE 'Scryer %' OR ct.name LIKE 'Sha''tar %' OR ct.name LIKE 'Honor Hold %' OR ct.name LIKE 'Thrallmar %'
    OR ct.name LIKE 'Frostwolf %' OR ct.name LIKE 'Stormpike %' OR ct.name LIKE 'Mag''har %' OR ct.name LIKE 'Kurenai %'
    OR ct.name LIKE 'Explorers'' League %' OR ct.name LIKE 'Timbermaw %' OR ct.name LIKE 'Frenzyheart %' OR ct.name LIKE 'Crusader %'
    OR ct.name LIKE 'Brewfest %' OR ct.name LIKE 'Netherwing %' OR ct.name LIKE 'Lower City %' OR ct.name LIKE 'Keepers of Time %'
    OR ct.name LIKE 'Alliance Vanguard %' OR ct.name LIKE 'Horde %' OR ct.name LIKE 'Dalaran %' OR ct.name LIKE 'Ravenholdt %')
  AND ct.name NOT REGEXP 'Recruit|Prisoner|Captive|Wounded|Injured|Dead|Corpse|Spirit|Ghost|Trigger|Bunny|Invisible|Credit|Dummy|Target|Image|Vehicle|Mount|Cannon|Siege|Kill|Quest|Citizen|Refugee|Civilian|Peasant|Child|Orphan|DND|Brewfest'
  AND ct.entry NOT IN (SELECT entry FROM zc_diff)
  AND ct.entry NOT IN (SELECT entry FROM zerocraft_hero_pool)
  AND ct.entry NOT IN (SELECT entry FROM zerocraft_guard_pool);

-- soldiers no longer standing anywhere in the world deploy as elites
UPDATE creature_template ct JOIN zerocraft_guard_pool g ON g.entry = ct.entry AND g.kind = 'faction'
SET ct.`rank` = 1 WHERE ct.`rank` = 0 AND ct.entry NOT IN (SELECT id FROM creature);

DROP TEMPORARY TABLE zc_diff;
DROP TEMPORARY TABLE zc_spawned;
SELECT kind, COUNT(*) AS npcs FROM zerocraft_guard_pool GROUP BY kind;
SELECT name FROM zerocraft_guard_pool WHERE kind = 'faction' ORDER BY RAND() LIMIT 25;
