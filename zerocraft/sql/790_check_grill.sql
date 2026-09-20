-- ZeroCraft diagnostic: the grill that can't be clicked
USE acore_world;
SELECT entry, type, displayId, name, IconName, size, Data0, Data1, Data2, Data3 FROM gameobject_template WHERE entry IN (194490, 2194490, 181686, 2181686, 2719, 2002719, 152079, 2152079);
SELECT * FROM gameobject_template_addon WHERE entry IN (194490, 2194490, 181686, 2181686, 2002719, 2152079);
SELECT g.guid, g.id, g.position_x, g.position_y, g.position_z, p.scale, p.owner_guild FROM gameobject g JOIN zerocraft_placed p ON p.kind = 0 AND p.spawn_id = g.guid WHERE g.id IN (2194490, 194490, 2181686, 181686) ORDER BY g.guid DESC LIMIT 5;
