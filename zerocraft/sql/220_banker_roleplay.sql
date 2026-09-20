-- ZeroCraft: the guild Banker talks. No more vault chest; blue "!" floats over the Banker instead.
USE acore_world;
UPDATE creature_template SET name = 'Banker' WHERE entry = 911100;
DELETE FROM npc_text WHERE ID BETWEEN 911200 AND 911204;
INSERT INTO npc_text (ID, text0_0, text0_1, Probability0) VALUES
(911200,
 'Ah, $N. Pull up a crate and mind the ledgers.$B$BEvery blade standing out there wears our colors - and every one of them expects to be paid. Guards, smiths, that sour innkeeper, even the fellow who feeds the wyverns. Loyalty is a fine word, $C, but it does not fill a belly.$B$BThe coffers pay them every hour. Keep the gold coming, and they will hold the line for you until the end of days.',
 'Ah, $N. Pull up a crate and mind the ledgers.$B$BEvery blade standing out there wears our colors - and every one of them expects to be paid. Guards, smiths, that sour innkeeper, even the fellow who feeds the wyverns. Loyalty is a fine word, $C, but it does not fill a belly.$B$BThe coffers pay them every hour. Keep the gold coming, and they will hold the line for you until the end of days.',
 1),
(911201,
 'Here is the ledger, $N, line by line. I count it twice a day - three times when the drums start.$B$BWhen the coffers run dry, the soldiers stop eating. When they stop eating, they start dying. Slowly, a quarter of their strength each hour, until there is nothing left to bury.',
 'Here is the ledger, $N, line by line. I count it twice a day - three times when the drums start.$B$BWhen the coffers run dry, the soldiers stop eating. When they stop eating, they start dying. Slowly, a quarter of their strength each hour, until there is nothing left to bury.',
 1),
(911202,
 'Nobody here works for free, $C. Not even me.$B$BHeroes cost the most - legends have expensive tastes. The Flight Masters and I keep the whole network breathing, so we are not cheap either. Shopkeepers and smiths ask little, and a plain guard asks less.$B$BAnd mind this: if an enemy ever puts a blade through me, everything in these coffers goes with my corpse. Guard your Banker, $N.',
 'Nobody here works for free, $C. Not even me.$B$BHeroes cost the most - legends have expensive tastes. The Flight Masters and I keep the whole network breathing, so we are not cheap either. Shopkeepers and smiths ask little, and a plain guard asks less.$B$BAnd mind this: if an enemy ever puts a blade through me, everything in these coffers goes with my corpse. Guard your Banker, $N.',
 1),
(911203,
 'Counted, weighed, and locked away. The troops will drink to your name tonight, $N.',
 'Counted, weighed, and locked away. The troops will drink to your name tonight, $N.',
 1),
(911204,
 '$N! Thank the Light - or whatever you pray to. The coffers are EMPTY.$B$BThe soldiers have gone unpaid and they are wasting away out there. Every hour we wait, they lose another quarter of their strength. A few more hours and they will be corpses in our colors.$B$BGold, $C. Now. Please.',
 '$N! Thank the Light - or whatever you pray to. The coffers are EMPTY.$B$BThe soldiers have gone unpaid and they are wasting away out there. Every hour we wait, they lose another quarter of their strength. A few more hours and they will be corpses in our colors.$B$BGold, $C. Now. Please.',
 1);
SELECT ID, LEFT(text0_0, 60) FROM npc_text WHERE ID BETWEEN 911200 AND 911204;
