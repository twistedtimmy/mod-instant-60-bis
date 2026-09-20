-- ZeroCraft: the Horde/Alliance faction tabards can be worn by anyone at any PvP rank, and can't be sold or lost
USE acore_world;
UPDATE item_template SET requiredhonorrank = 0, RequiredReputationFaction = 0, RequiredReputationRank = 0, AllowableRace = -1, AllowableClass = -1, bonding = 1
WHERE entry IN (15196, 15197, 5976);
SELECT entry, name, requiredhonorrank, AllowableRace, bonding FROM item_template WHERE entry IN (15196, 15197, 5976);
