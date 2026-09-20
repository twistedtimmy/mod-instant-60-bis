-- ZeroCraft: new characters start in their faction capital
-- Horde (orc 2, undead 5, tauren 6, troll 8, blood elf 10) -> Orgrimmar
-- Alliance (human 1, dwarf 3, night elf 4, gnome 7, draenei 11) -> Stormwind
USE acore_world;
UPDATE playercreateinfo SET map = 1, zone = 1637, position_x = 1629.36, position_y = -4373.39, position_z = 31.2564, orientation = 3.54839
WHERE race IN (2, 5, 6, 8, 10);
UPDATE playercreateinfo SET map = 0, zone = 1519, position_x = -8833.38, position_y = 628.628, position_z = 94.0066, orientation = 1.06535
WHERE race IN (1, 3, 4, 7, 11);
SELECT race, map, zone, COUNT(*) AS classes FROM playercreateinfo GROUP BY race, map, zone;
