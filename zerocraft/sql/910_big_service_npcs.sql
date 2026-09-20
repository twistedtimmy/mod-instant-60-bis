-- ZeroCraft: Bankers, Flight Masters and Auctioneers are giants (3x) - the ones already placed too
USE acore_world;
UPDATE zerocraft_deployables d JOIN creature_template ct ON ct.entry = d.entry
SET d.scale = 3 WHERE (ct.npcflag & (0x2000 | 0x20000 | 0x200000)) <> 0;
SELECT ROW_COUNT() AS service_npcs_made_giant;
