-- ZeroCraft: Crest of Silvermoon becomes a caster shield for Elemental and Restoration shamans (Shaman only)
UPDATE acore_world.item_template SET AllowableClass = 64, armor = 2400, block = 60,
  stat_type1 = 5,  stat_value1 = 28,    -- Intellect
  stat_type2 = 7,  stat_value2 = 22,    -- Stamina
  stat_type3 = 45, stat_value3 = 70,    -- Spell Power
  stat_type4 = 43, stat_value4 = 8,     -- Mana every 5 seconds
  stat_type5 = 32, stat_value5 = 16,    -- Critical Strike
  stat_type6 = 36, stat_value6 = 16,    -- Haste
  stat_type7 = 0, stat_value7 = 0, stat_type8 = 0, stat_value8 = 0, stat_type9 = 0, stat_value9 = 0, stat_type10 = 0, stat_value10 = 0,
  holy_res = 0, fire_res = 0, nature_res = 0, frost_res = 0, shadow_res = 0, arcane_res = 0
WHERE entry = 60413;
SELECT entry, name, AllowableClass, armor, stat_value3 AS spell_power FROM acore_world.item_template WHERE entry = 60413;
