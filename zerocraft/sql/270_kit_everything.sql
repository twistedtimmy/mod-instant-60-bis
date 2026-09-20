-- ZeroCraft: musician/dancer/stable master now come from the Builder's Kit, so new characters don't get separate scrolls
USE acore_world;
DELETE FROM playercreateinfo_item WHERE itemid IN (1267, 6213, 17163);
SELECT COUNT(*) AS separate_npc_scrolls_at_start FROM playercreateinfo_item WHERE itemid IN (1267, 6213, 17163);
