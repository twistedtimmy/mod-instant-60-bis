-- ZeroCraft: Frostmourne gets the Frozen Rune Weapon icon (new display 68800 = same sword model, new icon; client side in patch-Y)
USE acore_world;
DELETE FROM item_dbc WHERE ID = 36942;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (36942, 2, 8, -1, 1, 68800, 17, 1);
UPDATE item_template SET displayid = 68800 WHERE entry = 36942;
SELECT entry, name, displayid FROM item_template WHERE entry = 36942;
