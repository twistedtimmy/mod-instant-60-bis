-- ZeroCraft: dying drops everything in your bags (not what you wear) as lootable packs on the ground.
USE acore_world;
DELETE FROM gameobject_template WHERE entry = 911200;
DROP TEMPORARY TABLE IF EXISTS zc_pk;
CREATE TEMPORARY TABLE zc_pk SELECT * FROM gameobject_template WHERE entry = 186736;
UPDATE zc_pk SET entry = 911200, name = 'Fallen Adventurer''s Pack', size = 1.5, Data0 = 0, Data1 = 0, Data2 = 0, Data3 = 1,
  Data15 = 0, AIName = '', ScriptName = '';
INSERT INTO gameobject_template SELECT * FROM zc_pk;
DROP TEMPORARY TABLE zc_pk;
DELETE FROM gameobject_template_addon WHERE entry = 911200;
SELECT entry, type, displayId, name FROM gameobject_template WHERE entry = 911200;

-- Summoning Stone claims now cover a whole area (Theramore Isle etc.)
UPDATE npc_text SET text0_0 = 'This Summoning Stone holds your guild''s claim on this whole area. Nobody else may build or deploy here.',
  text0_1 = 'This Summoning Stone holds your guild''s claim on this whole area. Nobody else may build or deploy here.' WHERE ID = 911214;
UPDATE item_template SET description = 'Place it to claim this whole area for your guild: nobody else can build or deploy here. Talk to it to summon guildmates or open the guild bank.'
WHERE entry IN (SELECT item_entry FROM zerocraft_furniture WHERE stone = 1);
