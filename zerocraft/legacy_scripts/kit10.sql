USE acore_world;
UPDATE playercreateinfo_item SET amount = 7 WHERE itemid = 911001;
UPDATE playercreateinfo_item SET amount = 3 WHERE itemid = 911002;
SELECT itemid, amount, COUNT(*) AS race_class_combos FROM playercreateinfo_item WHERE itemid IN (911001, 911002) GROUP BY itemid, amount;
