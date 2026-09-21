-- ZeroCraft: the Potion Master and the Gadgeteer stop handing out beginner recipes (skill < 50).
-- Nothing that needs a level above 60 (all three crafters). What remains is ordered with the 200+ recipes first.
USE acore_world;
-- 911170: 6 dropped: Minor Healing Potion [1], Elixir of Lion's Strength [1], Minor Mana Potion [25], Minor Rejuvenation Potion [40], Weak Troll's Blood Elixir [15], Elixir of Minor Defense [1]
DELETE FROM npc_vendor WHERE entry = 911170 AND item IN (118,2454,2455,2456,3382,5997);
UPDATE npc_vendor SET slot = 1 WHERE entry = 911170 AND item = 22823; -- 305 Elixir of Camouflage
UPDATE npc_vendor SET slot = 2 WHERE entry = 911170 AND item = 22824; -- 305 Elixir of Major Strength
UPDATE npc_vendor SET slot = 3 WHERE entry = 911170 AND item = 13506; -- 300 Potion of Petrification
UPDATE npc_vendor SET slot = 4 WHERE entry = 911170 AND item = 13510; -- 300 Flask of the Titans
UPDATE npc_vendor SET slot = 5 WHERE entry = 911170 AND item = 13511; -- 300 Flask of Distilled Wisdom
UPDATE npc_vendor SET slot = 6 WHERE entry = 911170 AND item = 13512; -- 300 Flask of Supreme Power
UPDATE npc_vendor SET slot = 7 WHERE entry = 911170 AND item = 13513; -- 300 Flask of Chromatic Resistance
UPDATE npc_vendor SET slot = 8 WHERE entry = 911170 AND item = 18253; -- 300 Major Rejuvenation Potion
UPDATE npc_vendor SET slot = 9 WHERE entry = 911170 AND item = 28100; -- 300 Volatile Healing Potion
UPDATE npc_vendor SET slot = 10 WHERE entry = 911170 AND item = 28102; -- 300 Onslaught Elixir
UPDATE npc_vendor SET slot = 11 WHERE entry = 911170 AND item = 28103; -- 300 Adept's Elixir
UPDATE npc_vendor SET slot = 12 WHERE entry = 911170 AND item = 7068; -- 300 Elemental Fire
UPDATE npc_vendor SET slot = 13 WHERE entry = 911170 AND item = 13444; -- 295 Major Mana Potion
UPDATE npc_vendor SET slot = 14 WHERE entry = 911170 AND item = 13456; -- 290 Greater Frost Protection Potion
UPDATE npc_vendor SET slot = 15 WHERE entry = 911170 AND item = 13457; -- 290 Greater Fire Protection Potion
UPDATE npc_vendor SET slot = 16 WHERE entry = 911170 AND item = 13458; -- 290 Greater Nature Protection Potion
UPDATE npc_vendor SET slot = 17 WHERE entry = 911170 AND item = 13459; -- 290 Greater Shadow Protection Potion
UPDATE npc_vendor SET slot = 18 WHERE entry = 911170 AND item = 13461; -- 290 Greater Arcane Protection Potion
UPDATE npc_vendor SET slot = 19 WHERE entry = 911170 AND item = 20004; -- 290 Mighty Troll's Blood Elixir
UPDATE npc_vendor SET slot = 20 WHERE entry = 911170 AND item = 13454; -- 285 Greater Arcane Elixir
UPDATE npc_vendor SET slot = 21 WHERE entry = 911170 AND item = 13462; -- 285 Purification Potion
UPDATE npc_vendor SET slot = 22 WHERE entry = 911170 AND item = 20008; -- 285 Living Action Potion
UPDATE npc_vendor SET slot = 23 WHERE entry = 911170 AND item = 13452; -- 280 Elixir of the Mongoose
UPDATE npc_vendor SET slot = 24 WHERE entry = 911170 AND item = 13455; -- 280 Greater Stoneshield Potion
UPDATE npc_vendor SET slot = 25 WHERE entry = 911170 AND item = 20002; -- 275 Greater Dreamless Sleep Potion
UPDATE npc_vendor SET slot = 26 WHERE entry = 911170 AND item = 7076; -- 275 Essence of Earth
UPDATE npc_vendor SET slot = 27 WHERE entry = 911170 AND item = 7078; -- 275 Essence of Fire
UPDATE npc_vendor SET slot = 28 WHERE entry = 911170 AND item = 7080; -- 275 Essence of Water
UPDATE npc_vendor SET slot = 29 WHERE entry = 911170 AND item = 7082; -- 275 Essence of Air
UPDATE npc_vendor SET slot = 30 WHERE entry = 911170 AND item = 12360; -- 275 Arcanite Bar
UPDATE npc_vendor SET slot = 31 WHERE entry = 911170 AND item = 12803; -- 275 Living Essence
UPDATE npc_vendor SET slot = 32 WHERE entry = 911170 AND item = 12808; -- 275 Essence of Undeath
UPDATE npc_vendor SET slot = 33 WHERE entry = 911170 AND item = 13446; -- 275 Major Healing Potion
UPDATE npc_vendor SET slot = 34 WHERE entry = 911170 AND item = 13453; -- 275 Elixir of Brute Force
UPDATE npc_vendor SET slot = 35 WHERE entry = 911170 AND item = 20007; -- 275 Mageblood Elixir
UPDATE npc_vendor SET slot = 36 WHERE entry = 911170 AND item = 13447; -- 270 Elixir of the Sages
UPDATE npc_vendor SET slot = 37 WHERE entry = 911170 AND item = 13445; -- 265 Elixir of Superior Defense
UPDATE npc_vendor SET slot = 38 WHERE entry = 911170 AND item = 13443; -- 260 Superior Mana Potion
UPDATE npc_vendor SET slot = 39 WHERE entry = 911170 AND item = 13442; -- 255 Mighty Rage Potion
UPDATE npc_vendor SET slot = 40 WHERE entry = 911170 AND item = 3387; -- 250 Limited Invulnerability Potion
UPDATE npc_vendor SET slot = 41 WHERE entry = 911170 AND item = 9224; -- 250 Elixir of Demonslaying
UPDATE npc_vendor SET slot = 42 WHERE entry = 911170 AND item = 9233; -- 250 Elixir of Detect Demon
UPDATE npc_vendor SET slot = 43 WHERE entry = 911170 AND item = 9264; -- 250 Elixir of Shadow Power
UPDATE npc_vendor SET slot = 44 WHERE entry = 911170 AND item = 13423; -- 250 Stonescale Oil
UPDATE npc_vendor SET slot = 45 WHERE entry = 911170 AND item = 21546; -- 250 Elixir of Greater Firepower
UPDATE npc_vendor SET slot = 46 WHERE entry = 911170 AND item = 9210; -- 245 Ghost Dye
UPDATE npc_vendor SET slot = 47 WHERE entry = 911170 AND item = 9206; -- 245 Elixir of Giants
UPDATE npc_vendor SET slot = 48 WHERE entry = 911170 AND item = 9088; -- 240 Gift of Arthas
UPDATE npc_vendor SET slot = 49 WHERE entry = 911170 AND item = 9187; -- 240 Elixir of Greater Agility
UPDATE npc_vendor SET slot = 50 WHERE entry = 911170 AND item = 9197; -- 240 Elixir of Dream Vision
UPDATE npc_vendor SET slot = 51 WHERE entry = 911170 AND item = 9155; -- 235 Arcane Elixir
UPDATE npc_vendor SET slot = 52 WHERE entry = 911170 AND item = 9172; -- 235 Invisibility Potion
UPDATE npc_vendor SET slot = 53 WHERE entry = 911170 AND item = 9179; -- 235 Elixir of Greater Intellect
UPDATE npc_vendor SET slot = 54 WHERE entry = 911170 AND item = 9154; -- 230 Elixir of Detect Undead
UPDATE npc_vendor SET slot = 55 WHERE entry = 911170 AND item = 12190; -- 230 Dreamless Sleep Potion
UPDATE npc_vendor SET slot = 56 WHERE entry = 911170 AND item = 6037; -- 225 Truesilver Bar
UPDATE npc_vendor SET slot = 57 WHERE entry = 911170 AND item = 9144; -- 225 Wildvine Potion
UPDATE npc_vendor SET slot = 58 WHERE entry = 911170 AND item = 9149; -- 225 Philosopher's Stone
UPDATE npc_vendor SET slot = 59 WHERE entry = 911170 AND item = 3577; -- 225 Gold Bar
UPDATE npc_vendor SET slot = 60 WHERE entry = 911170 AND item = 3928; -- 215 Superior Healing Potion
UPDATE npc_vendor SET slot = 61 WHERE entry = 911170 AND item = 18294; -- 215 Elixir of Greater Water Breathing
UPDATE npc_vendor SET slot = 62 WHERE entry = 911170 AND item = 4623; -- 215 Lesser Stoneshield Potion
UPDATE npc_vendor SET slot = 63 WHERE entry = 911170 AND item = 9036; -- 210 Magic Resistance Potion
UPDATE npc_vendor SET slot = 64 WHERE entry = 911170 AND item = 9061; -- 210 Goblin Rocket Fuel
UPDATE npc_vendor SET slot = 65 WHERE entry = 911170 AND item = 6149; -- 205 Greater Mana Potion
UPDATE npc_vendor SET slot = 66 WHERE entry = 911170 AND item = 8956; -- 205 Oil of Immolation
UPDATE npc_vendor SET slot = 67 WHERE entry = 911170 AND item = 3829; -- 200 Frost Oil
UPDATE npc_vendor SET slot = 68 WHERE entry = 911170 AND item = 10592; -- 200 Catseye Elixir
UPDATE npc_vendor SET slot = 69 WHERE entry = 911170 AND item = 3828; -- 195 Elixir of Detect Lesser Invisibility
UPDATE npc_vendor SET slot = 70 WHERE entry = 911170 AND item = 8951; -- 195 Elixir of Greater Defense
UPDATE npc_vendor SET slot = 71 WHERE entry = 911170 AND item = 6050; -- 190 Frost Protection Potion
UPDATE npc_vendor SET slot = 72 WHERE entry = 911170 AND item = 6052; -- 190 Nature Protection Potion
UPDATE npc_vendor SET slot = 73 WHERE entry = 911170 AND item = 17708; -- 190 Elixir of Frost Power
UPDATE npc_vendor SET slot = 74 WHERE entry = 911170 AND item = 8949; -- 185 Elixir of Agility
UPDATE npc_vendor SET slot = 75 WHERE entry = 911170 AND item = 3826; -- 180 Major Troll's Blood Elixir
UPDATE npc_vendor SET slot = 76 WHERE entry = 911170 AND item = 3825; -- 175 Elixir of Fortitude
UPDATE npc_vendor SET slot = 77 WHERE entry = 911170 AND item = 5633; -- 175 Great Rage Potion
UPDATE npc_vendor SET slot = 78 WHERE entry = 911170 AND item = 3824; -- 165 Shadow Oil
UPDATE npc_vendor SET slot = 79 WHERE entry = 911170 AND item = 3823; -- 165 Lesser Invisibility Potion
UPDATE npc_vendor SET slot = 80 WHERE entry = 911170 AND item = 6049; -- 165 Fire Protection Potion
UPDATE npc_vendor SET slot = 81 WHERE entry = 911170 AND item = 3827; -- 160 Mana Potion
UPDATE npc_vendor SET slot = 82 WHERE entry = 911170 AND item = 1710; -- 155 Greater Healing Potion
UPDATE npc_vendor SET slot = 83 WHERE entry = 911170 AND item = 3391; -- 150 Elixir of Ogre's Strength
UPDATE npc_vendor SET slot = 84 WHERE entry = 911170 AND item = 5634; -- 150 Free Action Potion
UPDATE npc_vendor SET slot = 85 WHERE entry = 911170 AND item = 3390; -- 140 Elixir of Lesser Agility
UPDATE npc_vendor SET slot = 86 WHERE entry = 911170 AND item = 6373; -- 140 Elixir of Firepower
UPDATE npc_vendor SET slot = 87 WHERE entry = 911170 AND item = 6048; -- 135 Shadow Protection Potion
UPDATE npc_vendor SET slot = 88 WHERE entry = 911170 AND item = 45621; -- 135 Elixir of Minor Accuracy
UPDATE npc_vendor SET slot = 89 WHERE entry = 911170 AND item = 3389; -- 130 Elixir of Defense
UPDATE npc_vendor SET slot = 90 WHERE entry = 911170 AND item = 6371; -- 130 Fire Oil
UPDATE npc_vendor SET slot = 91 WHERE entry = 911170 AND item = 3388; -- 125 Strong Troll's Blood Elixir
UPDATE npc_vendor SET slot = 92 WHERE entry = 911170 AND item = 3386; -- 120 Potion of Curing
UPDATE npc_vendor SET slot = 93 WHERE entry = 911170 AND item = 3385; -- 120 Lesser Mana Potion
UPDATE npc_vendor SET slot = 94 WHERE entry = 911170 AND item = 929; -- 110 Healing Potion
UPDATE npc_vendor SET slot = 95 WHERE entry = 911170 AND item = 3384; -- 110 Minor Magic Resistance Potion
UPDATE npc_vendor SET slot = 96 WHERE entry = 911170 AND item = 6051; -- 100 Holy Protection Potion
UPDATE npc_vendor SET slot = 97 WHERE entry = 911170 AND item = 6372; -- 100 Swim Speed Potion
UPDATE npc_vendor SET slot = 98 WHERE entry = 911170 AND item = 3383; -- 90 Elixir of Wisdom
UPDATE npc_vendor SET slot = 99 WHERE entry = 911170 AND item = 5996; -- 90 Elixir of Water Breathing
UPDATE npc_vendor SET slot = 100 WHERE entry = 911170 AND item = 6662; -- 90 Elixir of Giant Growth
UPDATE npc_vendor SET slot = 101 WHERE entry = 911170 AND item = 6370; -- 80 Blackmouth Oil
UPDATE npc_vendor SET slot = 102 WHERE entry = 911170 AND item = 2459; -- 60 Swiftness Potion
UPDATE npc_vendor SET slot = 103 WHERE entry = 911170 AND item = 5631; -- 60 Rage Potion
UPDATE npc_vendor SET slot = 104 WHERE entry = 911170 AND item = 858; -- 55 Lesser Healing Potion
UPDATE npc_vendor SET slot = 105 WHERE entry = 911170 AND item = 4596; -- 50 Discolored Healing Potion
UPDATE npc_vendor SET slot = 106 WHERE entry = 911170 AND item = 2457; -- 50 Elixir of Minor Agility
UPDATE npc_vendor SET slot = 107 WHERE entry = 911170 AND item = 2458; -- 50 Elixir of Minor Fortitude
UPDATE npc_vendor SET slot = 108 WHERE entry = 911170 AND item = 13460; -- ? Greater Holy Protection Potion
UPDATE npc_vendor SET slot = 109 WHERE entry = 911170 AND item = 9030; -- ? Restorative Potion
UPDATE npc_vendor SET slot = 110 WHERE entry = 911170 AND item = 2460; -- ? Elixir of Tongues (NYI)
UPDATE npc_vendor SET slot = 111 WHERE entry = 911170 AND item = 19931; -- ? Gurubashi Mojo Madness
-- 911171: 5 dropped: Rough Blasting Powder [1], Rough Dynamite [1], Handful of Copper Bolts [30], Rough Copper Bomb [30], Crafted Light Shot [1]
DELETE FROM npc_vendor WHERE entry = 911171 AND item IN (4357,4358,4359,4360,8067);
UPDATE npc_vendor SET slot = 1 WHERE entry = 911171 AND item = 23772; -- 310 Fel Iron Shells
UPDATE npc_vendor SET slot = 2 WHERE entry = 911171 AND item = 23821; -- 305 Zapthrottle Mote Extractor
UPDATE npc_vendor SET slot = 3 WHERE entry = 911171 AND item = 18168; -- 300 Force Reactive Disk
UPDATE npc_vendor SET slot = 4 WHERE entry = 911171 AND item = 18282; -- 300 Core Marksman Rifle
UPDATE npc_vendor SET slot = 5 WHERE entry = 911171 AND item = 19998; -- 300 Bloodvine Lens
UPDATE npc_vendor SET slot = 6 WHERE entry = 911171 AND item = 19999; -- 300 Bloodvine Goggles
UPDATE npc_vendor SET slot = 7 WHERE entry = 911171 AND item = 16007; -- 300 Flawless Arcanite Rifle
UPDATE npc_vendor SET slot = 8 WHERE entry = 911171 AND item = 16022; -- 300 Arcanite Dragonling
UPDATE npc_vendor SET slot = 9 WHERE entry = 911171 AND item = 16040; -- 300 Arcane Bomb
UPDATE npc_vendor SET slot = 10 WHERE entry = 911171 AND item = 18283; -- 300 Biznicks 247x128 Accurascope
UPDATE npc_vendor SET slot = 11 WHERE entry = 911171 AND item = 18639; -- 300 Ultra-Flash Shadow Reflector
UPDATE npc_vendor SET slot = 12 WHERE entry = 911171 AND item = 23736; -- 300 Fel Iron Bomb
UPDATE npc_vendor SET slot = 13 WHERE entry = 911171 AND item = 23781; -- 300 Elemental Blasting Powder
UPDATE npc_vendor SET slot = 14 WHERE entry = 911171 AND item = 23782; -- 300 Fel Iron Casing
UPDATE npc_vendor SET slot = 15 WHERE entry = 911171 AND item = 23783; -- 300 Handful of Fel Iron Bolts
UPDATE npc_vendor SET slot = 16 WHERE entry = 911171 AND item = 16008; -- 290 Master Engineer's Goggles
UPDATE npc_vendor SET slot = 17 WHERE entry = 911171 AND item = 16009; -- 290 Voice Amplification Modulator
UPDATE npc_vendor SET slot = 18 WHERE entry = 911171 AND item = 18638; -- 290 Hyper-Radiant Flame Reflector
UPDATE npc_vendor SET slot = 19 WHERE entry = 911171 AND item = 16006; -- 285 Delicate Arcanite Converter
UPDATE npc_vendor SET slot = 20 WHERE entry = 911171 AND item = 15997; -- 285 Thorium Shells
UPDATE npc_vendor SET slot = 21 WHERE entry = 911171 AND item = 16005; -- 285 Dark Iron Bomb
UPDATE npc_vendor SET slot = 22 WHERE entry = 911171 AND item = 16004; -- 275 Dark Iron Rifle
UPDATE npc_vendor SET slot = 23 WHERE entry = 911171 AND item = 16023; -- 275 Masterwork Target Dummy
UPDATE npc_vendor SET slot = 24 WHERE entry = 911171 AND item = 18594; -- 275 Powerful Seaforium Charge
UPDATE npc_vendor SET slot = 25 WHERE entry = 911171 AND item = 18637; -- 275 Major Recombobulator
UPDATE npc_vendor SET slot = 26 WHERE entry = 911171 AND item = 22728; -- 275 Steam Tonk Controller
UPDATE npc_vendor SET slot = 27 WHERE entry = 911171 AND item = 16000; -- 275 Thorium Tube
UPDATE npc_vendor SET slot = 28 WHERE entry = 911171 AND item = 7191; -- 275 Fused Wiring
UPDATE npc_vendor SET slot = 29 WHERE entry = 911171 AND item = 21570; -- 275 Cluster Launcher
UPDATE npc_vendor SET slot = 30 WHERE entry = 911171 AND item = 21714; -- 275 Large Blue Rocket Cluster
UPDATE npc_vendor SET slot = 31 WHERE entry = 911171 AND item = 21716; -- 275 Large Green Rocket Cluster
UPDATE npc_vendor SET slot = 32 WHERE entry = 911171 AND item = 21718; -- 275 Large Red Rocket Cluster
UPDATE npc_vendor SET slot = 33 WHERE entry = 911171 AND item = 15999; -- 270 Spellpower Goggles Xtreme Plus
UPDATE npc_vendor SET slot = 34 WHERE entry = 911171 AND item = 15996; -- 265 Lifelike Mechanical Toad
UPDATE npc_vendor SET slot = 35 WHERE entry = 911171 AND item = 18587; -- 265 Goblin Jumper Cables XL
UPDATE npc_vendor SET slot = 36 WHERE entry = 911171 AND item = 18645; -- 265 Gnomish Alarm-o-Bot
UPDATE npc_vendor SET slot = 37 WHERE entry = 911171 AND item = 15993; -- 260 Thorium Grenade
UPDATE npc_vendor SET slot = 38 WHERE entry = 911171 AND item = 15994; -- 260 Thorium Widget
UPDATE npc_vendor SET slot = 39 WHERE entry = 911171 AND item = 15995; -- 260 Thorium Rifle
UPDATE npc_vendor SET slot = 40 WHERE entry = 911171 AND item = 18634; -- 260 Gyrofreeze Ice Reflector
UPDATE npc_vendor SET slot = 41 WHERE entry = 911171 AND item = 18631; -- 260 Truesilver Transformer
UPDATE npc_vendor SET slot = 42 WHERE entry = 911171 AND item = 18660; -- 260 World Enlarger
UPDATE npc_vendor SET slot = 43 WHERE entry = 911171 AND item = 45631; -- 250 High-powered Flashlight
UPDATE npc_vendor SET slot = 44 WHERE entry = 911171 AND item = 10576; -- 250 Mithril Mechanical Dragonling
UPDATE npc_vendor SET slot = 45 WHERE entry = 911171 AND item = 15846; -- 250 Salt Shaker
UPDATE npc_vendor SET slot = 46 WHERE entry = 911171 AND item = 15992; -- 250 Dense Blasting Powder
UPDATE npc_vendor SET slot = 47 WHERE entry = 911171 AND item = 19026; -- 250 Snake Burst Firework
UPDATE npc_vendor SET slot = 48 WHERE entry = 911171 AND item = 18641; -- 250 Dense Dynamite
UPDATE npc_vendor SET slot = 49 WHERE entry = 911171 AND item = 10504; -- 245 Green Lens
UPDATE npc_vendor SET slot = 50 WHERE entry = 911171 AND item = 10513; -- 245 Mithril Gyro-Shot
UPDATE npc_vendor SET slot = 51 WHERE entry = 911171 AND item = 10588; -- 245 Goblin Rocket Helmet
UPDATE npc_vendor SET slot = 52 WHERE entry = 911171 AND item = 10548; -- 240 Sniper Scope
UPDATE npc_vendor SET slot = 53 WHERE entry = 911171 AND item = 10645; -- 240 Gnomish Death Ray
UPDATE npc_vendor SET slot = 54 WHERE entry = 911171 AND item = 10727; -- 240 Goblin Dragon Gun
UPDATE npc_vendor SET slot = 55 WHERE entry = 911171 AND item = 10562; -- 235 Hi-Explosive Bomb
UPDATE npc_vendor SET slot = 56 WHERE entry = 911171 AND item = 10726; -- 235 Gnomish Mind Control Cap
UPDATE npc_vendor SET slot = 57 WHERE entry = 911171 AND item = 10586; -- 235 The Big One
UPDATE npc_vendor SET slot = 58 WHERE entry = 911171 AND item = 10503; -- 230 Rose Colored Goggles
UPDATE npc_vendor SET slot = 59 WHERE entry = 911171 AND item = 10506; -- 230 Deepdive Helmet
UPDATE npc_vendor SET slot = 60 WHERE entry = 911171 AND item = 10587; -- 230 Goblin Bomb Dispenser
UPDATE npc_vendor SET slot = 61 WHERE entry = 911171 AND item = 10725; -- 230 Gnomish Battle Chicken
UPDATE npc_vendor SET slot = 62 WHERE entry = 911171 AND item = 7189; -- 225 Goblin Rocket Boots
UPDATE npc_vendor SET slot = 63 WHERE entry = 911171 AND item = 10518; -- 225 Parachute Cloak
UPDATE npc_vendor SET slot = 64 WHERE entry = 911171 AND item = 10724; -- 225 Gnomish Rocket Boots
UPDATE npc_vendor SET slot = 65 WHERE entry = 911171 AND item = 10502; -- 225 Spellpower Goggles Xtreme
UPDATE npc_vendor SET slot = 66 WHERE entry = 911171 AND item = 21569; -- 225 Firework Launcher
UPDATE npc_vendor SET slot = 67 WHERE entry = 911171 AND item = 21571; -- 225 Blue Rocket Cluster
UPDATE npc_vendor SET slot = 68 WHERE entry = 911171 AND item = 21574; -- 225 Green Rocket Cluster
UPDATE npc_vendor SET slot = 69 WHERE entry = 911171 AND item = 21576; -- 225 Red Rocket Cluster
UPDATE npc_vendor SET slot = 70 WHERE entry = 911171 AND item = 10501; -- 220 Catseye Ultra Goggles
UPDATE npc_vendor SET slot = 71 WHERE entry = 911171 AND item = 10510; -- 220 Mithril Heavy-bore Rifle
UPDATE npc_vendor SET slot = 72 WHERE entry = 911171 AND item = 10514; -- 215 Mithril Frag Bomb
UPDATE npc_vendor SET slot = 73 WHERE entry = 911171 AND item = 10561; -- 215 Mithril Casing
UPDATE npc_vendor SET slot = 74 WHERE entry = 911171 AND item = 10721; -- 215 Gnomish Harm Prevention Belt
UPDATE npc_vendor SET slot = 75 WHERE entry = 911171 AND item = 10512; -- 210 Hi-Impact Mithril Slugs
UPDATE npc_vendor SET slot = 76 WHERE entry = 911171 AND item = 10545; -- 210 Gnomish Goggles
UPDATE npc_vendor SET slot = 77 WHERE entry = 911171 AND item = 10546; -- 210 Deadly Scope
UPDATE npc_vendor SET slot = 78 WHERE entry = 911171 AND item = 10720; -- 210 Gnomish Net-o-Matic Projector
UPDATE npc_vendor SET slot = 79 WHERE entry = 911171 AND item = 10644; -- 205 Recipe: Goblin Rocket Fuel
UPDATE npc_vendor SET slot = 80 WHERE entry = 911171 AND item = 10500; -- 205 Fire Goggles
UPDATE npc_vendor SET slot = 81 WHERE entry = 911171 AND item = 10508; -- 205 Mithril Blunderbuss
UPDATE npc_vendor SET slot = 82 WHERE entry = 911171 AND item = 10542; -- 205 Goblin Mining Helmet
UPDATE npc_vendor SET slot = 83 WHERE entry = 911171 AND item = 10543; -- 205 Goblin Construction Helmet
UPDATE npc_vendor SET slot = 84 WHERE entry = 911171 AND item = 10577; -- 205 Goblin Mortar
UPDATE npc_vendor SET slot = 85 WHERE entry = 911171 AND item = 10646; -- 205 Goblin Sapper Charge
UPDATE npc_vendor SET slot = 86 WHERE entry = 911171 AND item = 10716; -- 205 Gnomish Shrink Ray
UPDATE npc_vendor SET slot = 87 WHERE entry = 911171 AND item = 11825; -- 205 Pet Bombling
UPDATE npc_vendor SET slot = 88 WHERE entry = 911171 AND item = 11826; -- 205 Lil' Smoky
UPDATE npc_vendor SET slot = 89 WHERE entry = 911171 AND item = 4396; -- 200 Mechanical Dragonling
UPDATE npc_vendor SET slot = 90 WHERE entry = 911171 AND item = 4397; -- 200 Gnomish Cloaking Device
UPDATE npc_vendor SET slot = 91 WHERE entry = 911171 AND item = 4398; -- 200 Large Seaforium Charge
UPDATE npc_vendor SET slot = 92 WHERE entry = 911171 AND item = 10560; -- 200 Unstable Trigger
UPDATE npc_vendor SET slot = 93 WHERE entry = 911171 AND item = 10713; -- 200 Plans: Inlaid Mithril Cylinder
UPDATE npc_vendor SET slot = 94 WHERE entry = 911171 AND item = 11590; -- 200 Mechanical Repair Kit
UPDATE npc_vendor SET slot = 95 WHERE entry = 911171 AND item = 18588; -- 200 Ez-Thro Dynamite II
UPDATE npc_vendor SET slot = 96 WHERE entry = 911171 AND item = 4395; -- 195 Goblin Land Mine
UPDATE npc_vendor SET slot = 97 WHERE entry = 911171 AND item = 10559; -- 195 Mithril Tube
UPDATE npc_vendor SET slot = 98 WHERE entry = 911171 AND item = 4394; -- 190 Big Iron Bomb
UPDATE npc_vendor SET slot = 99 WHERE entry = 911171 AND item = 17716; -- 190 Snowmaster 9000
UPDATE npc_vendor SET slot = 100 WHERE entry = 911171 AND item = 4392; -- 185 Advanced Target Dummy
UPDATE npc_vendor SET slot = 101 WHERE entry = 911171 AND item = 4393; -- 185 Craftsman's Monocle
UPDATE npc_vendor SET slot = 102 WHERE entry = 911171 AND item = 4852; -- 185 Flash Bomb
UPDATE npc_vendor SET slot = 103 WHERE entry = 911171 AND item = 4407; -- 180 Accurate Scope
UPDATE npc_vendor SET slot = 104 WHERE entry = 911171 AND item = 4390; -- 175 Iron Grenade
UPDATE npc_vendor SET slot = 105 WHERE entry = 911171 AND item = 4391; -- 175 Compact Harvest Reaper Kit
UPDATE npc_vendor SET slot = 106 WHERE entry = 911171 AND item = 10498; -- 175 Gyromatic Micro-Adjustor
UPDATE npc_vendor SET slot = 107 WHERE entry = 911171 AND item = 10499; -- 175 Bright-Eye Goggles
UPDATE npc_vendor SET slot = 108 WHERE entry = 911171 AND item = 10505; -- 175 Solid Blasting Powder
UPDATE npc_vendor SET slot = 109 WHERE entry = 911171 AND item = 10507; -- 175 Solid Dynamite
UPDATE npc_vendor SET slot = 110 WHERE entry = 911171 AND item = 21589; -- 175 Large Blue Rocket
UPDATE npc_vendor SET slot = 111 WHERE entry = 911171 AND item = 21590; -- 175 Large Green Rocket
UPDATE npc_vendor SET slot = 112 WHERE entry = 911171 AND item = 21592; -- 175 Large Red Rocket
UPDATE npc_vendor SET slot = 113 WHERE entry = 911171 AND item = 4389; -- 170 Gyrochronatom
UPDATE npc_vendor SET slot = 114 WHERE entry = 911171 AND item = 4403; -- 165 Portable Bronze Mortar
UPDATE npc_vendor SET slot = 115 WHERE entry = 911171 AND item = 7148; -- 165 Goblin Jumper Cables
UPDATE npc_vendor SET slot = 116 WHERE entry = 911171 AND item = 4387; -- 160 Iron Strut
UPDATE npc_vendor SET slot = 117 WHERE entry = 911171 AND item = 4388; -- 160 Discombobulator Ray
UPDATE npc_vendor SET slot = 118 WHERE entry = 911171 AND item = 4386; -- 155 Ice Deflector
UPDATE npc_vendor SET slot = 119 WHERE entry = 911171 AND item = 4384; -- 150 Explosive Sheep
UPDATE npc_vendor SET slot = 120 WHERE entry = 911171 AND item = 4385; -- 150 Green Tinted Goggles
UPDATE npc_vendor SET slot = 121 WHERE entry = 911171 AND item = 6533; -- 150 Aquadynamic Fish Attractor
UPDATE npc_vendor SET slot = 122 WHERE entry = 911171 AND item = 10558; -- 150 Gold Power Core
UPDATE npc_vendor SET slot = 123 WHERE entry = 911171 AND item = 9312; -- 150 Blue Firework
UPDATE npc_vendor SET slot = 124 WHERE entry = 911171 AND item = 9313; -- 150 Green Firework
UPDATE npc_vendor SET slot = 125 WHERE entry = 911171 AND item = 9318; -- 150 Red Firework
UPDATE npc_vendor SET slot = 126 WHERE entry = 911171 AND item = 4382; -- 145 Bronze Framework
UPDATE npc_vendor SET slot = 127 WHERE entry = 911171 AND item = 4383; -- 145 Moonsight Rifle
UPDATE npc_vendor SET slot = 128 WHERE entry = 911171 AND item = 4380; -- 140 Big Bronze Bomb
UPDATE npc_vendor SET slot = 129 WHERE entry = 911171 AND item = 4381; -- 140 Minor Recombobulator
UPDATE npc_vendor SET slot = 130 WHERE entry = 911171 AND item = 5507; -- 135 Ornate Spyglass
UPDATE npc_vendor SET slot = 131 WHERE entry = 911171 AND item = 4379; -- 130 Silver-plated Shotgun
UPDATE npc_vendor SET slot = 132 WHERE entry = 911171 AND item = 8069; -- 125 Crafted Solid Shot
UPDATE npc_vendor SET slot = 133 WHERE entry = 911171 AND item = 4378; -- 125 Heavy Dynamite
UPDATE npc_vendor SET slot = 134 WHERE entry = 911171 AND item = 4375; -- 125 Whirring Bronze Gizmo
UPDATE npc_vendor SET slot = 135 WHERE entry = 911171 AND item = 4376; -- 125 Flame Deflector
UPDATE npc_vendor SET slot = 136 WHERE entry = 911171 AND item = 4377; -- 125 Heavy Blasting Powder
UPDATE npc_vendor SET slot = 137 WHERE entry = 911171 AND item = 7506; -- 125 Gnomish Universal Remote
UPDATE npc_vendor SET slot = 138 WHERE entry = 911171 AND item = 21557; -- 125 Small Red Rocket
UPDATE npc_vendor SET slot = 139 WHERE entry = 911171 AND item = 21558; -- 125 Small Blue Rocket
UPDATE npc_vendor SET slot = 140 WHERE entry = 911171 AND item = 21559; -- 125 Small Green Rocket
UPDATE npc_vendor SET slot = 141 WHERE entry = 911171 AND item = 4374; -- 120 Small Bronze Bomb
UPDATE npc_vendor SET slot = 142 WHERE entry = 911171 AND item = 4372; -- 120 Lovingly Crafted Boomstick
UPDATE npc_vendor SET slot = 143 WHERE entry = 911171 AND item = 4373; -- 120 Shadow Goggles
UPDATE npc_vendor SET slot = 144 WHERE entry = 911171 AND item = 4406; -- 110 Standard Scope
UPDATE npc_vendor SET slot = 145 WHERE entry = 911171 AND item = 4370; -- 105 Large Copper Bomb
UPDATE npc_vendor SET slot = 146 WHERE entry = 911171 AND item = 4369; -- 105 Deadly Blunderbuss
UPDATE npc_vendor SET slot = 147 WHERE entry = 911171 AND item = 4371; -- 105 Bronze Tube
UPDATE npc_vendor SET slot = 148 WHERE entry = 911171 AND item = 6714; -- 100 Ez-Thro Dynamite
UPDATE npc_vendor SET slot = 149 WHERE entry = 911171 AND item = 4367; -- 100 Small Seaforium Charge
UPDATE npc_vendor SET slot = 150 WHERE entry = 911171 AND item = 4368; -- 100 Flying Tiger Goggles
UPDATE npc_vendor SET slot = 151 WHERE entry = 911171 AND item = 6712; -- 100 Practice Lock
UPDATE npc_vendor SET slot = 152 WHERE entry = 911171 AND item = 4404; -- 90 Silver Contact
UPDATE npc_vendor SET slot = 153 WHERE entry = 911171 AND item = 4366; -- 85 Target Dummy
UPDATE npc_vendor SET slot = 154 WHERE entry = 911171 AND item = 4365; -- 75 Coarse Dynamite
UPDATE npc_vendor SET slot = 155 WHERE entry = 911171 AND item = 8068; -- 75 Crafted Heavy Shot
UPDATE npc_vendor SET slot = 156 WHERE entry = 911171 AND item = 4364; -- 75 Coarse Blasting Powder
UPDATE npc_vendor SET slot = 157 WHERE entry = 911171 AND item = 4401; -- 75 Mechanical Squirrel Box
UPDATE npc_vendor SET slot = 158 WHERE entry = 911171 AND item = 4363; -- 65 Copper Modulator
UPDATE npc_vendor SET slot = 159 WHERE entry = 911171 AND item = 4405; -- 60 Crude Scope
UPDATE npc_vendor SET slot = 160 WHERE entry = 911171 AND item = 4361; -- 50 Copper Tube
UPDATE npc_vendor SET slot = 161 WHERE entry = 911171 AND item = 4362; -- 50 Rough Boomstick
UPDATE npc_vendor SET slot = 162 WHERE entry = 911171 AND item = 6219; -- 50 Arclight Spanner
UPDATE npc_vendor SET slot = 163 WHERE entry = 911171 AND item = 18232; -- ? Field Repair Bot 74A
UPDATE npc_vendor SET slot = 164 WHERE entry = 911171 AND item = 21277; -- ? Tranquil Mechanical Yeti
UPDATE npc_vendor SET slot = 165 WHERE entry = 911171 AND item = 18984; -- ? Dimensional Ripper - Everlook
UPDATE npc_vendor SET slot = 166 WHERE entry = 911171 AND item = 18986; -- ? Ultrasafe Transporter: Gadgetzan
UPDATE npc_vendor SET slot = 167 WHERE entry = 911171 AND item = 10585; -- ? Goblin Radio
UPDATE npc_vendor SET slot = 168 WHERE entry = 911171 AND item = 10723; -- ? Gnomish Ham Radio
UPDATE npc_vendor SET slot = 169 WHERE entry = 911171 AND item = 10580; -- ? Goblin "Boom" Box
UPDATE npc_vendor SET slot = 170 WHERE entry = 911171 AND item = 10719; -- ? Mobile Alarm
-- 911173: 3 dropped: Time-Lost Figurine [level 68], Super Simian Sphere [level 80], Frenzyheart Brew [level 75]
DELETE FROM npc_vendor WHERE entry = 911173 AND item IN (32782,37254,44719);
UPDATE npc_vendor SET slot = 1 WHERE entry = 911173 AND item = 40768; -- 425 MOLL-E
UPDATE npc_vendor SET slot = 2 WHERE entry = 911173 AND item = 18660; -- 260 World Enlarger
UPDATE npc_vendor SET slot = 3 WHERE entry = 911173 AND item = 9312; -- 150 Blue Firework
UPDATE npc_vendor SET slot = 4 WHERE entry = 911173 AND item = 9313; -- 150 Green Firework
UPDATE npc_vendor SET slot = 5 WHERE entry = 911173 AND item = 45984; -- ? Unusual Compass
UPDATE npc_vendor SET slot = 6 WHERE entry = 911173 AND item = 1973; -- ? Orb of Deception
UPDATE npc_vendor SET slot = 7 WHERE entry = 911173 AND item = 13379; -- ? Piccolo of the Flaming Fire
UPDATE npc_vendor SET slot = 8 WHERE entry = 911173 AND item = 18258; -- ? Gordok Ogre Suit
UPDATE npc_vendor SET slot = 9 WHERE entry = 911173 AND item = 16768; -- ? Furbolg Medicine Pouch
UPDATE npc_vendor SET slot = 10 WHERE entry = 911173 AND item = 12820; -- ? Winterfall Firewater
UPDATE npc_vendor SET slot = 11 WHERE entry = 911173 AND item = 8529; -- ? Noggenfogger Elixir
UPDATE npc_vendor SET slot = 12 WHERE entry = 911173 AND item = 21540; -- ? Elune's Lantern
UPDATE npc_vendor SET slot = 13 WHERE entry = 911173 AND item = 9314; -- ? Red Streaks Firework
UPDATE npc_vendor SET slot = 14 WHERE entry = 911173 AND item = 21213; -- ? Preserved Holly
UPDATE npc_vendor SET slot = 15 WHERE entry = 911173 AND item = 49703; -- ? Perpetual Purple Firework
UPDATE npc_vendor SET slot = 16 WHERE entry = 911173 AND item = 6657; -- ? Savory Deviate Delight
UPDATE npc_vendor SET slot = 17 WHERE entry = 911173 AND item = 17202; -- ? Snowball
UPDATE npc_vendor SET slot = 18 WHERE entry = 911173 AND item = 5462; -- ? Dartol's Rod of Transformation
UPDATE npc_vendor SET slot = 19 WHERE entry = 911173 AND item = 17712; -- ? Winter Veil Disguise Kit
UPDATE npc_vendor SET slot = 20 WHERE entry = 911173 AND item = 21519; -- ? Mistletoe
UPDATE npc_vendor SET slot = 21 WHERE entry = 911173 AND item = 21744; -- ? Lucky Rocket Cluster
UPDATE npc_vendor SET slot = 22 WHERE entry = 911173 AND item = 32566; -- ? Picnic Basket
UPDATE npc_vendor SET slot = 23 WHERE entry = 911173 AND item = 33223; -- ? Fishing Chair
UPDATE npc_vendor SET slot = 24 WHERE entry = 911173 AND item = 34480; -- ? Romantic Picnic Basket
UPDATE npc_vendor SET slot = 25 WHERE entry = 911173 AND item = 34686; -- ? Brazier of Dancing Flames
UPDATE npc_vendor SET slot = 26 WHERE entry = 911173 AND item = 35227; -- ? Goblin Weather Machine - Prototype 01-B
UPDATE npc_vendor SET slot = 27 WHERE entry = 911173 AND item = 38233; -- ? Path of Illidan
UPDATE npc_vendor SET slot = 28 WHERE entry = 911173 AND item = 43499; -- ? Iron Boot Flask
UPDATE npc_vendor SET slot = 29 WHERE entry = 911173 AND item = 43824; -- ? The Schools of Arcane Magic - Mastery
UPDATE npc_vendor SET slot = 30 WHERE entry = 911173 AND item = 44430; -- ? Titanium Seal of Dalaran
UPDATE npc_vendor SET slot = 31 WHERE entry = 911173 AND item = 45063; -- ? Foam Sword Rack
UPDATE npc_vendor SET slot = 32 WHERE entry = 911173 AND item = 46779; -- ? Path of Cenarius
UPDATE npc_vendor SET slot = 33 WHERE entry = 911173 AND item = 46780; -- ? Ogre Pinata
UPDATE npc_vendor SET slot = 34 WHERE entry = 911173 AND item = 36863; -- ? Decahedral Dwarven Dice
UPDATE npc_vendor SET slot = 35 WHERE entry = 911173 AND item = 44481; -- ? Grindgear Toy Gorilla
SELECT entry, COUNT(*) FROM npc_vendor WHERE entry IN (911170, 911171, 911173) GROUP BY entry;
