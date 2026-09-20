-- ZeroCraft: Illidan's Warglaives of Azzinoth squished for level 60 (were item level 156, level 70).
-- Rogues start wielding both; warriors get the pair in their bags. The twin-blade set bonus and +44 attack power stay.
USE acore_world;
UPDATE item_template SET ItemLevel = 100, RequiredLevel = 60,
  stat_type1 = 3, stat_value1 = 14, stat_type2 = 7, stat_value2 = 18, stat_type3 = 31, stat_value3 = 13,
  dmg_min1 = 150, dmg_max1 = 280, delay = 2800
WHERE entry = 32837;   -- main hand: Agility, Stamina, Hit
UPDATE item_template SET ItemLevel = 100, RequiredLevel = 60,
  stat_type1 = 3, stat_value1 = 13, stat_type2 = 7, stat_value2 = 17, stat_type3 = 32, stat_value3 = 14,
  dmg_min1 = 75, dmg_max1 = 140, delay = 1400
WHERE entry = 32838;   -- off hand: Agility, Stamina, Crit
SELECT entry, name, ItemLevel, RequiredLevel, dmg_min1, dmg_max1 FROM item_template WHERE entry IN (32837, 32838);
