-- ZeroCraft: you may carry and wield two Frostmournes (Titan's Grip: Swords)
UPDATE acore_world.item_template SET maxcount = 2, Flags = Flags & ~0x80000 WHERE entry = 36942;
SELECT entry, name, maxcount, Flags FROM acore_world.item_template WHERE entry = 36942;
