-- ZeroCraft: Destructor's Rod (60419) - opens a list of everything your guild built nearby; click one to destroy it.
USE acore_world;
DELETE FROM item_dbc WHERE ID = 60419;
INSERT INTO item_dbc (ID, ClassID, SubclassID, Sound_Override_Subclassid, Material, DisplayInfoID, InventoryType, SheatheType) VALUES (60419, 15, 0, -1, 1, 13435, 0, 0);
DELETE FROM item_template WHERE entry = 60419;
DROP TEMPORARY TABLE IF EXISTS zc_dr; CREATE TEMPORARY TABLE zc_dr SELECT * FROM item_template WHERE entry = 8164;
UPDATE zc_dr SET entry = 60419, class = 15, subclass = 0, name = 'Destructor''s Rod', displayid = 13435, Quality = 3, bonding = 1, stackable = 1, maxcount = 1,
  spellid_1 = 16872, spelltrigger_1 = 0, BuyPrice = 0, SellPrice = 0, ScriptName = 'item_zerocraft_destructor',
  description = 'Lists everything your guild built within 100 yards. Click one and it''s gone.';
INSERT INTO item_template SELECT * FROM zc_dr; DROP TEMPORARY TABLE zc_dr;
SELECT entry, name, ScriptName FROM item_template WHERE entry = 60419;
