-- ZeroCraft: Doomhammer becomes a one-handed (main hand) healer's mace for Restoration shamans
USE acore_world;
DELETE FROM item_dbc WHERE ID = 60411;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60411, 2, 4, -1, 1, 68801, 21, 3);
UPDATE item_template SET subclass = 4, InventoryType = 21, sheath = 3,
  dmg_min1 = 97, dmg_max1 = 181, delay = 2500,
  stat_type1 = 5,  stat_value1 = 30,    -- Intellect
  stat_type2 = 7,  stat_value2 = 20,    -- Stamina
  stat_type3 = 45, stat_value3 = 120,   -- Spell Power (healing)
  stat_type4 = 43, stat_value4 = 12,    -- Mana every 5 seconds
  stat_type5 = 32, stat_value5 = 18,    -- Critical Strike
  stat_type6 = 36, stat_value6 = 18,    -- Haste
  stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0, stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0
WHERE entry = 60411;
SELECT entry, name, subclass, InventoryType, dmg_min1, dmg_max1, delay, stat_value3 AS spell_power FROM item_template WHERE entry = 60411;
