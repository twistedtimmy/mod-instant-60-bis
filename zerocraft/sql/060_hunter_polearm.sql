-- ZeroCraft: hunters start with The Eye of Nerub (Naxxramas agility polearm)
USE acore_world;
INSERT IGNORE INTO playercreateinfo_item (race, class, itemid, amount)
SELECT DISTINCT race, class, 23039, 1 FROM playercreateinfo WHERE class = 3;
SELECT COUNT(*) AS hunter_kits_with_eye_of_nerub FROM playercreateinfo_item WHERE itemid = 23039;
