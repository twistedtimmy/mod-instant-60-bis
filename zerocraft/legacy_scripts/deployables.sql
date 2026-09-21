-- ZeroCraft deployable NPCs (test): tables, faction slot pool, two deploy items, starting kit.
USE acore_world;

CREATE TABLE IF NOT EXISTS zerocraft_faction_slots (
  faction_template INT UNSIGNED NOT NULL PRIMARY KEY,
  owner_key BIGINT NULL COMMENT 'guild id (>0) or -(player guid)'
);
-- client-known faction templates: hostile to all players by default, used by no creature
INSERT IGNORE INTO zerocraft_faction_slots (faction_template) VALUES
(1294),(1739),(1740),(1742),(1762),(1763),(1764),(1765),(1834),(1842),(1879),(1889),(1906),(2057);

CREATE TABLE IF NOT EXISTS zerocraft_deployables (
  spawn_id INT UNSIGNED NOT NULL PRIMARY KEY,
  entry INT UNSIGNED NOT NULL,
  owner_player INT UNSIGNED NOT NULL,
  owner_guild INT UNSIGNED NOT NULL DEFAULT 0,
  faction_template INT UNSIGNED NOT NULL,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Deploy items, cloned from the Hearthstone row so every column is valid, then reshaped.
DELETE FROM item_template WHERE entry IN (911001, 911002);
DROP TEMPORARY TABLE IF EXISTS zc_tmp_item;
CREATE TEMPORARY TABLE zc_tmp_item SELECT * FROM item_template WHERE entry = 6948;
UPDATE zc_tmp_item SET
  entry = 911001, name = 'Deployable Guard', description = 'Deploys a random guard loyal to you and your guild.',
  class = 0, subclass = 8, Quality = 3, Flags = 0, bonding = 0, stackable = 20, maxcount = 0,
  SellPrice = 0, BuyPrice = 0, ItemLevel = 1, RequiredLevel = 0,
  spellid_1 = 13567, spelltrigger_1 = 0, spellcharges_1 = 0, spellcooldown_1 = -1, spellcategory_1 = 0, spellcategorycooldown_1 = -1,
  displayid = COALESCE((SELECT displayid FROM item_template WHERE entry = 3012), displayid),
  ScriptName = 'item_zerocraft_deploy';
INSERT INTO item_template SELECT * FROM zc_tmp_item;
UPDATE zc_tmp_item SET entry = 911002, name = 'Deployable Vendor', description = 'Deploys a random vendor loyal to you and your guild.';
INSERT INTO item_template SELECT * FROM zc_tmp_item;
DROP TEMPORARY TABLE zc_tmp_item;

-- Starting kit for NEW characters: 2 guards + 1 vendor
DELETE FROM playercreateinfo_item WHERE itemid IN (911001, 911002);
INSERT INTO playercreateinfo_item (race, class, itemid, amount)
SELECT DISTINCT race, class, 911001, 2 FROM playercreateinfo;
INSERT INTO playercreateinfo_item (race, class, itemid, amount)
SELECT DISTINCT race, class, 911002, 1 FROM playercreateinfo;

SELECT entry, name, spellid_1, ScriptName FROM item_template WHERE entry IN (911001, 911002);
SELECT COUNT(*) AS guard_candidates FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id WHERE (ct.flags_extra & 0x8000) <> 0;
SELECT COUNT(*) AS vendor_candidates FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id WHERE (ct.npcflag & 128) <> 0;
