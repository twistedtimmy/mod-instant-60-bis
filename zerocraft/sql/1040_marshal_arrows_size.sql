-- ZeroCraft: the Marshal's Arrow was far too small to see (the model is ~1.7 yards tall at 1.0). Make it big.
USE acore_world;
UPDATE gameobject_template SET size = 1.8 WHERE entry = 911301;
SELECT entry, name, displayId, size FROM gameobject_template WHERE entry = 911301;
