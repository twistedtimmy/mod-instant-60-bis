-- ZeroCraft: Doomhammer, Mace of the Warchief (item 60411) - Thrall's own hammer model (display 65921, new icon as 68801). Shamans only.
USE acore_world;
DELETE FROM item_dbc WHERE ID = 60411;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60411, 2, 5, -1, 1, 68801, 17, 1);
DELETE FROM item_template WHERE entry = 60411;
DROP TEMPORARY TABLE IF EXISTS zc_dh;
CREATE TEMPORARY TABLE zc_dh SELECT * FROM item_template WHERE entry = 17182;   -- Sulfuras: a level 60 legendary two-handed mace
UPDATE zc_dh SET entry = 60411, name = 'Doomhammer, Mace of the Warchief', description = 'For Doomhammer!',
  displayid = 68801, Quality = 5, class = 2, subclass = 5, InventoryType = 17, bonding = 1, maxcount = 1,
  AllowableClass = 64, AllowableRace = -1, RequiredLevel = 60, ItemLevel = 100, BuyPrice = 0, SellPrice = 250000,
  stat_type1 = 4,  stat_value1 = 35,    -- Strength
  stat_type2 = 3,  stat_value2 = 25,    -- Agility
  stat_type3 = 7,  stat_value3 = 40,    -- Stamina
  stat_type4 = 5,  stat_value4 = 25,    -- Intellect
  stat_type5 = 45, stat_value5 = 40,    -- Spell Power
  stat_type6 = 32, stat_value6 = 20,    -- Critical Strike
  stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0, stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0,
  spellid_1 = 0, spelltrigger_1 = 0, spellid_2 = 0, spelltrigger_2 = 0, spellid_3 = 0, spelltrigger_3 = 0,
  ScriptName = '';
INSERT INTO item_template SELECT * FROM zc_dh;
DROP TEMPORARY TABLE zc_dh;
SELECT entry, name, Quality, AllowableClass, displayid, dmg_min1, dmg_max1, description FROM item_template WHERE entry = 60411;
