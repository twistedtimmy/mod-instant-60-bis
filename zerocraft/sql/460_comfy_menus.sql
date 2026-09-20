-- ZeroCraft: menu headers for the ComfyCraft-style edit menus
USE acore_world;
DELETE FROM npc_text WHERE ID BETWEEN 911210 AND 911215;
INSERT INTO npc_text (ID, text0_0, text0_1, Probability0) VALUES
(911210, 'What would you like to do?', 'What would you like to do?', 1),
(911211, 'Move the object', 'Move the object', 1),
(911212, 'Turn the object', 'Turn the object', 1),
(911213, 'Resize the object', 'Resize the object', 1),
(911214, 'This Summoning Stone holds your guild''s claim on this land. Nobody else may build within 60 yards.', 'This Summoning Stone holds your guild''s claim on this land. Nobody else may build within 60 yards.', 1),
(911215, 'Which guildmate should the stone call?', 'Which guildmate should the stone call?', 1);
