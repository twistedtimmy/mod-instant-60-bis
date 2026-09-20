-- ZeroCraft: the starting bags become Jaina's Dimensional Pocket - 30 slots, arcane-orb icon.
-- Item 14156 (the old 18-slot Bottomless Bag) is re-made in place, so every character's existing bags upgrade too.
USE acore_world;
UPDATE item_template SET
  name = 'Jaina''s Dimensional Pocket',
  description = 'A pocket folded through the Twisting Nether by the Lady of Theramore herself.',
  ContainerSlots = 30,
  displayid = 41178,          -- Spell_Arcane_Blast: white core, violet burst
  Quality = 1,
  bonding = 1,
  RequiredSkill = 0, RequiredSkillRank = 0, RequiredLevel = 0,
  BuyPrice = 0, SellPrice = 0
WHERE entry = 14156;
SELECT entry, name, ContainerSlots, displayid FROM item_template WHERE entry = 14156;
