-- ZeroCraft: take the raid bosses (huge health pools) out of the hero scroll pool
USE acore_world;
DELETE FROM zerocraft_hero_pool WHERE villain = 1 AND name IN
 ('Lady Vashj','Illidan Stormrage','Kael''thas Sunstrider','Lord Victor Nefarius','Teron Gorefiend','Moroes',
  'Shade of Aran','Terestian Illhoof','Zul''jin','Hex Lord Malacrass','Lady Deathwhisper','Prince Keleseth','Prince Valanar');
SELECT villain, name FROM zerocraft_hero_pool ORDER BY villain, name;
