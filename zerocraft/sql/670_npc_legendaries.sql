-- ZeroCraft: seven legendaries made from NPC-only weapon models (items 60412-60418). Every new character carries them.
USE acore_world;
DELETE FROM item_dbc WHERE ID = 60412;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60412, 2, 6, -1, 1, 37410, 17, 2);
DELETE FROM item_template WHERE entry = 60412;
DROP TEMPORARY TABLE IF EXISTS zc_l; CREATE TEMPORARY TABLE zc_l SELECT * FROM item_template WHERE entry = 17182;
UPDATE zc_l SET entry = 60412, name = 'Spellbreaker, Glaive of Silvermoon', description = 'After the Scourge burned Quel''Thalas, the Spellbreakers of Silvermoon forged these blades to cut down the Scourge''s necromancers. Its first bearer swore that magic would never again enslave her people.', displayid = 37410, class = 2, subclass = 6, Material = 1,
  InventoryType = 17, sheath = 2, Quality = 5, bonding = 1, maxcount = 1, AllowableClass = -1, AllowableRace = -1,
  RequiredLevel = 60, ItemLevel = 100, BuyPrice = 0, SellPrice = 250000,
  dmg_min1 = 211, dmg_max1 = 352, dmg_type1 = 0, dmg_min2 = 0, dmg_max2 = 0, delay = 3500, armor = 0, block = 0,
  stat_type1 = 4, stat_value1 = 40,
  stat_type2 = 7, stat_value2 = 35,
  stat_type3 = 3, stat_value3 = 20,
  stat_type4 = 32, stat_value4 = 20,
  stat_type5 = 31, stat_value5 = 15,
  stat_type6 = 0, stat_value6 = 0, stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0, stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0,
  spellid_1 = 0, spelltrigger_1 = 0, spellid_2 = 0, spelltrigger_2 = 0, spellid_3 = 0, spelltrigger_3 = 0, ScriptName = '';
INSERT INTO item_template SELECT * FROM zc_l; DROP TEMPORARY TABLE zc_l;
DELETE FROM item_dbc WHERE ID = 60413;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60413, 4, 6, -1, 1, 48907, 14, 4);
DELETE FROM item_template WHERE entry = 60413;
DROP TEMPORARY TABLE IF EXISTS zc_l; CREATE TEMPORARY TABLE zc_l SELECT * FROM item_template WHERE entry = 17182;
UPDATE zc_l SET entry = 60413, name = 'Crest of Silvermoon, Shield of the Guardians', description = 'Carried by the Guardians of Silvermoon at the city gate. The phoenix on its face has never been lowered to an enemy, not even when the Scourge came.', displayid = 48907, class = 4, subclass = 6, Material = 1,
  InventoryType = 14, sheath = 4, Quality = 5, bonding = 1, maxcount = 1, AllowableClass = -1, AllowableRace = -1,
  RequiredLevel = 60, ItemLevel = 100, BuyPrice = 0, SellPrice = 250000,
  dmg_min1 = 0, dmg_max1 = 0, dmg_type1 = 0, dmg_min2 = 0, dmg_max2 = 0, delay = 0, armor = 3800, block = 120,
  stat_type1 = 7, stat_value1 = 45,
  stat_type2 = 4, stat_value2 = 20,
  stat_type3 = 12, stat_value3 = 20,
  stat_type4 = 15, stat_value4 = 15,
  stat_type5 = 0, stat_value5 = 0, stat_type6 = 0, stat_value6 = 0, stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0, stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0,
  spellid_1 = 0, spelltrigger_1 = 0, spellid_2 = 0, spelltrigger_2 = 0, spellid_3 = 0, spelltrigger_3 = 0, ScriptName = '';
INSERT INTO item_template SELECT * FROM zc_l; DROP TEMPORARY TABLE zc_l;
DELETE FROM item_dbc WHERE ID = 60414;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60414, 2, 5, -1, 2, 37525, 17, 1);
DELETE FROM item_template WHERE entry = 60414;
DROP TEMPORARY TABLE IF EXISTS zc_l; CREATE TEMPORARY TABLE zc_l SELECT * FROM item_template WHERE entry = 17182;
UPDATE zc_l SET entry = 60414, name = 'Earthmothers Fury, War Totem of the Chieftains', description = 'Carved from the oldest tree in Mulgore. Every chieftain of the Bloodhoof tribe has carried it into war, and it has never broken.', displayid = 37525, class = 2, subclass = 5, Material = 2,
  InventoryType = 17, sheath = 1, Quality = 5, bonding = 1, maxcount = 1, AllowableClass = -1, AllowableRace = -1,
  RequiredLevel = 60, ItemLevel = 100, BuyPrice = 0, SellPrice = 250000,
  dmg_min1 = 223, dmg_max1 = 372, dmg_type1 = 0, dmg_min2 = 0, dmg_max2 = 0, delay = 3700, armor = 0, block = 0,
  stat_type1 = 4, stat_value1 = 45,
  stat_type2 = 7, stat_value2 = 45,
  stat_type3 = 32, stat_value3 = 15,
  stat_type4 = 38, stat_value4 = 60,
  stat_type5 = 0, stat_value5 = 0, stat_type6 = 0, stat_value6 = 0, stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0, stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0,
  spellid_1 = 0, spelltrigger_1 = 0, spellid_2 = 0, spelltrigger_2 = 0, spellid_3 = 0, spelltrigger_3 = 0, ScriptName = '';
INSERT INTO item_template SELECT * FROM zc_l; DROP TEMPORARY TABLE zc_l;
DELETE FROM item_dbc WHERE ID = 60415;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60415, 2, 1, -1, 1, 46963, 17, 1);
DELETE FROM item_template WHERE entry = 60415;
DROP TEMPORARY TABLE IF EXISTS zc_l; CREATE TEMPORARY TABLE zc_l SELECT * FROM item_template WHERE entry = 17182;
UPDATE zc_l SET entry = 60415, name = 'Warbringer, Cleaver of the Amani', description = 'Zul''jin''s Warbringers carried these cleavers against the high elves in the Troll Wars. The Amani say the blood of a thousand elves still stains its edge.', displayid = 46963, class = 2, subclass = 1, Material = 1,
  InventoryType = 17, sheath = 1, Quality = 5, bonding = 1, maxcount = 1, AllowableClass = -1, AllowableRace = -1,
  RequiredLevel = 60, ItemLevel = 100, BuyPrice = 0, SellPrice = 250000,
  dmg_min1 = 230, dmg_max1 = 384, dmg_type1 = 0, dmg_min2 = 0, dmg_max2 = 0, delay = 3800, armor = 0, block = 0,
  stat_type1 = 4, stat_value1 = 50,
  stat_type2 = 7, stat_value2 = 30,
  stat_type3 = 32, stat_value3 = 25,
  stat_type4 = 31, stat_value4 = 10,
  stat_type5 = 0, stat_value5 = 0, stat_type6 = 0, stat_value6 = 0, stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0, stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0,
  spellid_1 = 0, spelltrigger_1 = 0, spellid_2 = 0, spelltrigger_2 = 0, spellid_3 = 0, spelltrigger_3 = 0, ScriptName = '';
INSERT INTO item_template SELECT * FROM zc_l; DROP TEMPORARY TABLE zc_l;
DELETE FROM item_dbc WHERE ID = 60416;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60416, 2, 6, -1, 1, 45598, 17, 2);
DELETE FROM item_template WHERE entry = 60416;
DROP TEMPORARY TABLE IF EXISTS zc_l; CREATE TEMPORARY TABLE zc_l SELECT * FROM item_template WHERE entry = 17182;
UPDATE zc_l SET entry = 60416, name = 'Doomspear, Glaive of the Pit Lord', description = 'Wrenched from the claws of a pit lord of the Burning Legion. The fel fire burning in its blade has not gone out in ten thousand years.', displayid = 45598, class = 2, subclass = 6, Material = 1,
  InventoryType = 17, sheath = 2, Quality = 5, bonding = 1, maxcount = 1, AllowableClass = -1, AllowableRace = -1,
  RequiredLevel = 60, ItemLevel = 100, BuyPrice = 0, SellPrice = 250000,
  dmg_min1 = 211, dmg_max1 = 352, dmg_type1 = 0, dmg_min2 = 0, dmg_max2 = 0, delay = 3500, armor = 0, block = 0,
  stat_type1 = 4, stat_value1 = 45,
  stat_type2 = 7, stat_value2 = 40,
  stat_type3 = 32, stat_value3 = 20,
  stat_type4 = 31, stat_value4 = 10,
  stat_type5 = 0, stat_value5 = 0, stat_type6 = 0, stat_value6 = 0, stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0, stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0,
  spellid_1 = 0, spelltrigger_1 = 0, spellid_2 = 0, spelltrigger_2 = 0, spellid_3 = 0, spelltrigger_3 = 0, ScriptName = '';
INSERT INTO item_template SELECT * FROM zc_l; DROP TEMPORARY TABLE zc_l;
DELETE FROM item_dbc WHERE ID = 60417;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60417, 2, 6, -1, 1, 46753, 17, 2);
DELETE FROM item_template WHERE entry = 60417;
DROP TEMPORARY TABLE IF EXISTS zc_l; CREATE TEMPORARY TABLE zc_l SELECT * FROM item_template WHERE entry = 17182;
UPDATE zc_l SET entry = 60417, name = 'Stormharpoon, Spear of the Ymirjar', description = 'The Ymirjar of Northrend hurled these harpoons at proto-drakes over the Howling Fjord. The runes on its shaft still hum with the storms of the Storm Peaks.', displayid = 46753, class = 2, subclass = 6, Material = 1,
  InventoryType = 17, sheath = 2, Quality = 5, bonding = 1, maxcount = 1, AllowableClass = -1, AllowableRace = -1,
  RequiredLevel = 60, ItemLevel = 100, BuyPrice = 0, SellPrice = 250000,
  dmg_min1 = 211, dmg_max1 = 352, dmg_type1 = 0, dmg_min2 = 0, dmg_max2 = 0, delay = 3500, armor = 0, block = 0,
  stat_type1 = 4, stat_value1 = 40,
  stat_type2 = 7, stat_value2 = 40,
  stat_type3 = 3, stat_value3 = 25,
  stat_type4 = 36, stat_value4 = 15,
  stat_type5 = 0, stat_value5 = 0, stat_type6 = 0, stat_value6 = 0, stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0, stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0,
  spellid_1 = 0, spelltrigger_1 = 0, spellid_2 = 0, spelltrigger_2 = 0, spellid_3 = 0, spelltrigger_3 = 0, ScriptName = '';
INSERT INTO item_template SELECT * FROM zc_l; DROP TEMPORARY TABLE zc_l;
DELETE FROM item_dbc WHERE ID = 60418;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60418, 2, 7, -1, 1, 4290, 13, 3);
DELETE FROM item_template WHERE entry = 60418;
DROP TEMPORARY TABLE IF EXISTS zc_l; CREATE TEMPORARY TABLE zc_l SELECT * FROM item_template WHERE entry = 17182;
UPDATE zc_l SET entry = 60418, name = 'Moonglaive of Elune, Blade of the Sentinels', description = 'Blessed beneath the full moon by the priestesses of Elune. The Sentinels of Ashenvale have carried moonglaives like this since the War of the Ancients.', displayid = 4290, class = 2, subclass = 7, Material = 1,
  InventoryType = 13, sheath = 3, Quality = 5, bonding = 1, maxcount = 1, AllowableClass = -1, AllowableRace = -1,
  RequiredLevel = 60, ItemLevel = 100, BuyPrice = 0, SellPrice = 250000,
  dmg_min1 = 130, dmg_max1 = 210, dmg_type1 = 0, dmg_min2 = 0, dmg_max2 = 0, delay = 2600, armor = 0, block = 0,
  stat_type1 = 3, stat_value1 = 30,
  stat_type2 = 7, stat_value2 = 25,
  stat_type3 = 32, stat_value3 = 18,
  stat_type4 = 31, stat_value4 = 12,
  stat_type5 = 38, stat_value5 = 40,
  stat_type6 = 0, stat_value6 = 0, stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0, stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0,
  spellid_1 = 0, spelltrigger_1 = 0, spellid_2 = 0, spelltrigger_2 = 0, spellid_3 = 0, spelltrigger_3 = 0, ScriptName = '';
INSERT INTO item_template SELECT * FROM zc_l; DROP TEMPORARY TABLE zc_l;
SELECT entry, name, class, subclass, InventoryType, displayid, dmg_min1, dmg_max1, armor FROM item_template WHERE entry BETWEEN 60412 AND 60418;
