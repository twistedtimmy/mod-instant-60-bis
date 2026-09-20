-- ZeroCraft: Summoning Stones are plain clickable objects (speech bubble -> menu); the bank lives in a hidden chest inside.
USE acore_world;
UPDATE gameobject_template SET type = 10, IconName = 'Speak', Data0 = 0, Data1 = 0, Data2 = 0, Data3 = 0, Data4 = 0, Data5 = 0,
  Data6 = 0, Data7 = 0, Data8 = 0, Data9 = 0, Data10 = 0, Data11 = 0, Data12 = 0, Data13 = 0, Data14 = 0, Data15 = 0
WHERE entry IN (SELECT go_entry FROM zerocraft_furniture WHERE stone = 1);
UPDATE gameobject_template t JOIN zerocraft_furniture f ON f.go_entry = t.entry JOIN gameobject_template src ON src.entry = f.src_entry
SET t.name = src.name WHERE f.stone = 1;
SELECT type, COUNT(*) FROM gameobject_template WHERE entry IN (SELECT go_entry FROM zerocraft_furniture WHERE stone = 1) GROUP BY type;
