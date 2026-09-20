-- ZeroCraft: the Curiosities Merchant (NPC 911173) - free fun items: transformations, fireworks, toys.
-- Called with the item "NPC: Curiosities Merchant" (65003).
USE acore_world;
SET @src = (SELECT entry FROM creature_template WHERE name = 'Innkeeper Allison' LIMIT 1);
SET @src = COALESCE(@src, (SELECT entry FROM creature_template WHERE subname = 'Trade Supplies' AND entry < 100000 ORDER BY entry LIMIT 1));
DELETE FROM creature_template WHERE entry = 911173;
DROP TEMPORARY TABLE IF EXISTS zc_cm; CREATE TEMPORARY TABLE zc_cm SELECT * FROM creature_template WHERE entry = @src;
UPDATE zc_cm SET entry = 911173, name = 'Curiosities Merchant', subname = 'Toys & Oddities', npcflag = 129, faction = 35, minlevel = 60, maxlevel = 60,
  unit_flags = 0, unit_flags2 = 0, flags_extra = 0, gossip_menu_id = 0, AIName = '', ScriptName = '';
INSERT INTO creature_template SELECT * FROM zc_cm; DROP TEMPORARY TABLE zc_cm;
DELETE FROM creature_template_model WHERE CreatureID = 911173;
DROP TEMPORARY TABLE IF EXISTS zc_cmm; CREATE TEMPORARY TABLE zc_cmm SELECT * FROM creature_template_model WHERE CreatureID = @src;
UPDATE zc_cmm SET CreatureID = 911173; INSERT INTO creature_template_model SELECT * FROM zc_cmm; DROP TEMPORARY TABLE zc_cmm;
DELETE FROM npc_vendor WHERE entry = 911173;
DROP TEMPORARY TABLE IF EXISTS zc_fun;
CREATE TEMPORARY TABLE zc_fun (item INT UNSIGNED PRIMARY KEY);
INSERT IGNORE INTO zc_fun VALUES
 (12820),  -- Winterfall Firewater (bigger)
 (1973),   -- Orb of Deception
 (8529),   -- Noggenfogger Elixir
 (6657),   -- Savory Deviate Delight
 (18258),  -- Gordok Ogre Suit
 (18660),  -- World Enlarger
 (17712),  -- Winter Veil Disguise Kit
 (21213),  -- Preserved Holly
 (17202),  -- Snowball
 (21519),  -- Mistletoe
 (21540),  -- Elune's Lantern
 (21744),  -- Lucky Rocket Cluster
 (9312), (9313), (9314),   -- fireworks
 (13379),  -- Piccolo of the Flaming Fire
 (32782),  -- Time-Lost Figurine (arakkoa)
 (38233),  -- Path of Illidan
 (46779),  -- Path of Cenarius
 (43499),  -- Iron Boot Flask (dwarf)
 (44719),  -- Frenzyheart Brew (wolvar)
 (37254),  -- Super Simian Sphere (monkey)
 (35227),  -- Goblin Weather Machine
 (34686),  -- Brazier of Dancing Flames
 (44430),  -- Titanium Seal of Dalaran
 (45984),  -- Unusual Compass
 (46780),  -- Ogre Pinata
 (45063),  -- Foam Sword Rack
 (33223),  -- Fishing Chair
 (36863),  -- Decahedral Dwarven Dice
 (32566),  -- Picnic Basket
 (34480),  -- Romantic Picnic Basket
 (49703),  -- Perpetual Purple Firework
 (43824),  -- The Schools of Arcane Magic - Mastery
 (44481),  -- Grindgear Toy Gorilla
 (40768);  -- MOLL-E
-- plus anything that turns you into a furbolg
INSERT IGNORE INTO zc_fun SELECT entry FROM item_template WHERE spellid_1 IN (6405, 20631) OR spellid_2 IN (6405, 20631);
INSERT IGNORE INTO npc_vendor (entry, item, maxcount, incrtime, ExtendedCost)
SELECT 911173, f.item, 0, 0, 0 FROM zc_fun f JOIN item_template it ON it.entry = f.item;
-- the item that calls him
DELETE FROM zerocraft_npcitem WHERE item_entry = 65003 OR entry = 911173;
INSERT INTO zerocraft_npcitem (item_entry, kind, entry, name) VALUES (65003, 842, 911173, 'Curiosities Merchant');
DELETE FROM item_dbc WHERE ID = 65003;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (65003, 15, 0, -1, 1, 918, 0, 0);
DELETE FROM item_template WHERE entry = 65003;
DROP TEMPORARY TABLE IF EXISTS zc_ci; CREATE TEMPORARY TABLE zc_ci SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_ci SET entry = 65003, class = 15, subclass = 0, name = 'NPC: Curiosities Merchant', displayid = 918, Quality = 4, bonding = 0, stackable = 20, maxcount = 0,
  spellid_1 = 22275, spelltrigger_1 = 0, BuyPrice = 0, SellPrice = 0, ScriptName = 'item_zerocraft_npcitem',
  description = 'Click the ground and the Curiosities Merchant arrives: toys, fireworks and transformations - all free.';
INSERT INTO item_template SELECT * FROM zc_ci; DROP TEMPORARY TABLE zc_ci;
INSERT IGNORE INTO reference_loot_template (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES (911090, 65003, 0, 0, 0, 1, 1, 1, 1, 'NPC: Curiosities Merchant'), (5911090, 65003, 0, 0, 0, 1, 1, 1, 1, 'NPC: Curiosities Merchant');
SELECT it.entry, it.name FROM npc_vendor v JOIN item_template it ON it.entry = v.item WHERE v.entry = 911173 ORDER BY it.name;
