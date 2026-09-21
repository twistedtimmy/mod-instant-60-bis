USE acore_world;
SELECT entry, name, displayid FROM item_template WHERE entry IN (911001, 911002, 3012, 6948);
-- use a scroll icon the client definitely knows
UPDATE item_template SET displayid = (SELECT d FROM (SELECT displayid AS d FROM item_template WHERE name = 'Scroll of Agility' ORDER BY entry LIMIT 1) x) WHERE entry IN (911001, 911002);
SELECT entry, name, displayid FROM item_template WHERE entry IN (911001, 911002);
