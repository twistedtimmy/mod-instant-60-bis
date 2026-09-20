-- ZeroCraft: a Summoning Stone IS the guild bank - click it and the guild bank window opens.
-- Summon / store gold / move / pick up live behind the "Stone Options" button on that window.
USE acore_world;
UPDATE gameobject_template SET type = 34, IconName = 'Speak', Data0 = 0, Data1 = 0, Data2 = 0, Data3 = 0, Data4 = 0, Data5 = 0,
  Data6 = 0, Data7 = 0, Data8 = 0, Data9 = 0, Data10 = 0, Data11 = 0, Data12 = 0, Data13 = 0, Data14 = 0, Data15 = 0
WHERE entry IN (SELECT go_entry FROM zerocraft_furniture WHERE stone = 1);
SELECT COUNT(*) AS stones_that_are_banks FROM gameobject_template WHERE type = 34 AND entry >= 2000000;
-- Builder's Rod gets its own ground-target spell (and its own green text in patch-Y)
UPDATE item_template SET spellid_1 = 24612, description = '' WHERE entry = 60407;
