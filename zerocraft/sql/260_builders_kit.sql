-- ZeroCraft: Builder's Kit (place useful things and decorations) + Musician, Dancer and Stable Master scrolls.
-- All four use item IDs freed when the deploy scrolls moved (they exist in the client, so they get icons).
USE acore_world;

CREATE TABLE IF NOT EXISTS zerocraft_placed (
  kind TINYINT UNSIGNED NOT NULL,           -- 0 = game object, 1 = creature
  spawn_id INT UNSIGNED NOT NULL,
  owner_guild INT UNSIGNED NOT NULL DEFAULT 0,
  owner_player INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (kind, spawn_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS zerocraft_deploy_pool (
  item_entry INT UNSIGNED NOT NULL,
  npc_entry INT UNSIGNED NOT NULL,
  emote INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (item_entry, npc_entry)
) ENGINE=InnoDB;

-- clone the Guard scroll (ground circle + deploy cast) for the three new NPC scrolls
DELETE FROM item_template WHERE entry IN (1267, 6213, 17163, 8164);
DROP TEMPORARY TABLE IF EXISTS zc_s;
CREATE TEMPORARY TABLE zc_s SELECT * FROM item_template WHERE entry = 823;
UPDATE zc_s SET entry = 1267,  name = 'Deployable Musician',      Quality = 2;
INSERT INTO item_template SELECT * FROM zc_s;
UPDATE zc_s SET entry = 6213,  name = 'Deployable Dancer',        Quality = 2;
INSERT INTO item_template SELECT * FROM zc_s;
UPDATE zc_s SET entry = 17163, name = 'Deployable Stable Master', Quality = 3;
INSERT INTO item_template SELECT * FROM zc_s;
-- Builder's Kit: same ground circle, never used up, own script, hammer icon
UPDATE zc_s SET entry = 8164, name = 'Builder''s Kit', Quality = 3, stackable = 1, maxcount = 1, bonding = 1,
  displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 5956), displayid),
  description = 'Click a spot on the ground, then choose what to build there.',
  ScriptName = 'item_zerocraft_builder';
INSERT INTO item_template SELECT * FROM zc_s;
DROP TEMPORARY TABLE zc_s;

DELETE FROM zerocraft_deploy_pool WHERE item_entry IN (1267, 6213, 17163);
-- musicians: the Tauren Chieftains and the wandering minstrel
INSERT INTO zerocraft_deploy_pool (item_entry, npc_entry, emote) VALUES
 (1267, 23619, 0), (1267, 23623, 0), (1267, 23625, 0), (1267, 23626, 0), (1267, 1451, 0);
-- dancers (always dancing: emote 10)
INSERT INTO zerocraft_deploy_pool (item_entry, npc_entry, emote) VALUES
 (6213, 25970, 10), (6213, 25974, 10), (6213, 33291, 10), (6213, 40356, 10);
-- stable masters: any removed stable master
INSERT IGNORE INTO zerocraft_deploy_pool (item_entry, npc_entry, emote)
SELECT DISTINCT 17163, r.id, 0 FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id
WHERE (ct.npcflag & 0x400000) <> 0 AND ct.`rank` <> 3;

-- every new character starts with the kit and one of each new scroll
DELETE FROM playercreateinfo_item WHERE itemid IN (1267, 6213, 17163, 8164);
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 1267, 1 FROM playercreateinfo;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 6213, 1 FROM playercreateinfo;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 17163, 1 FROM playercreateinfo;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) SELECT DISTINCT race, class, 8164, 1 FROM playercreateinfo;

SELECT entry, name, spellid_1, ScriptName FROM item_template WHERE entry IN (1267, 6213, 17163, 8164);
SELECT item_entry, COUNT(*) AS npcs FROM zerocraft_deploy_pool GROUP BY item_entry;
