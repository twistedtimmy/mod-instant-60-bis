-- ZeroCraft: only Warsong Gulch and Arathi Basin are open.
-- Disable Alterac Valley (1), Eye of the Storm (7), Strand of the Ancients (9), Isle of Conquest (30).
USE acore_world;
DELETE FROM disables WHERE sourceType = 3 AND entry IN (1, 7, 9, 30);
INSERT INTO disables (sourceType, entry, flags, params_0, params_1, comment) VALUES
 (3, 1,  0, '', '', 'ZeroCraft: Alterac Valley closed'),
 (3, 7,  0, '', '', 'ZeroCraft: Eye of the Storm closed'),
 (3, 9,  0, '', '', 'ZeroCraft: Strand of the Ancients closed'),
 (3, 30, 0, '', '', 'ZeroCraft: Isle of Conquest closed');
SELECT entry, comment FROM disables WHERE sourceType = 3;
