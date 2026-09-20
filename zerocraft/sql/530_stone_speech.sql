-- ZeroCraft: stones keep the guild-bank type on the server, but the client is told they're a normal
-- clickable object (speech bubble). Clicking opens the stone menu, which has "Open the Guild Vault".
USE acore_world;
UPDATE gameobject_template SET IconName = 'Speak' WHERE entry IN (SELECT go_entry FROM zerocraft_furniture WHERE stone = 1);
