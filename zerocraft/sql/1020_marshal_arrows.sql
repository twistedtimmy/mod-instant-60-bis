-- ZeroCraft: the Marshal's Arrow - a glowing floor arrow (Azjol-Nerub direction arrow, display 8094).
-- Three of them point at a march destination for two seconds, like the old click-to-move marker.
USE acore_world;
DELETE FROM gameobject_template WHERE entry = 911301;
DROP TEMPORARY TABLE IF EXISTS zc_ar; CREATE TEMPORARY TABLE zc_ar SELECT * FROM gameobject_template WHERE entry = 187691;
UPDATE zc_ar SET entry = 911301, name = 'Marshal''s Arrow', displayId = 8094, type = 5, size = 0.35, ScriptName = '';
INSERT INTO gameobject_template SELECT * FROM zc_ar; DROP TEMPORARY TABLE zc_ar;
SELECT entry, name, displayId, size FROM gameobject_template WHERE entry = 911301;
