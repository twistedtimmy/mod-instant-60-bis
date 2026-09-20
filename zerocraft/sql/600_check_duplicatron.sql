-- ZeroCraft: who has a Duplicatron / Standard-Bearer right now (diagnostic only)
SELECT c.name, ii.itemEntry, ii.count FROM acore_characters.characters c
  JOIN acore_characters.item_instance ii ON ii.owner_guid = c.guid
  WHERE ii.itemEntry IN (60409, 60410);
SELECT c.name, g.item FROM acore_characters.zerocraft_granted g JOIN acore_characters.characters c ON c.guid = g.guid;
SELECT entry, name, class, subclass, flags, AllowableClass, AllowableRace, RequiredLevel, maxcount, stackable, bonding FROM acore_world.item_template WHERE entry IN (60409, 60410);
