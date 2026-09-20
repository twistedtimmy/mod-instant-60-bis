-- ZeroCraft: new characters start with 5 Flight Master scrolls and 3 Banker scrolls
USE acore_world;
UPDATE playercreateinfo_item SET amount = 5 WHERE itemid = 3504;
UPDATE playercreateinfo_item SET amount = 3 WHERE itemid = 3513;
SELECT i.itemid, t.name, MIN(i.amount) AS amount FROM playercreateinfo_item i JOIN item_template t ON t.entry = i.itemid WHERE i.itemid IN (3504, 3513) GROUP BY i.itemid, t.name;
