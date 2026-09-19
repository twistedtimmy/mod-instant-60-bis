# mod-instant-60-bis

An open-source custom module for **AzerothCore (3.3.5a)** that equips all new characters with instant Level 60 endgame BiS gear, Tier 3 sets, epic mounts, and auto-configured action bars.

---

## Features

* **Full Naxxramas Tier 3 Sets:** Automatically equips the complete armor set, matching BiS weapons, shields, wands, rings, trinkets, cloaks, and amulets for all 9 classes.
* **4x Netherweave Bags:** 16-slot bags auto-slotted directly into container slots upon world entry.
* **1,000 Starting Gold:** Spawns characters with currency immediately available.
* **10 Cross-Faction Epic Mounts:** Unlocks 10 epic ground mounts directly in the companion journal (`Shift + P`), paired with pre-learned Artisan Riding.
* **Universal Weapon & Armor Masteries:** Grants Bows, Crossbows, Guns, Polearms, Dual Wield, Plate, Mail, and Leather across all classes.
* **Micro-Addon Automation:** Bundles `AutoActionBars` to force open all 5 action bars and equip bagged items automatically.

---

## Installation

1. Clone this repository into your `azerothcore/modules/` directory.
2. Copy `client-addon/AutoActionBars` into your client `Interface/AddOns/` folder.
3. Configure `worldserver.conf` with the required Level 60 and money multipliers, then restart your server.
4. Set `SkipCinematics = 2` in `worldserver.conf` to disable the character-creation intro cinematic for every class (skipped automatically once the module is built in; new-player tutorial hint popups are suppressed by the compiled hook itself, no config needed).
5. Recompile the worldserver (`docker compose build ac-worldserver` or your platform's equivalent) so the compiled `OnPlayerCreate` hook in `src/ModInstant60Bis.cpp` is included in the binary - the SQL/addon alone are not enough, this module relies on compiled code for gear auto-equip, action bar filling, and tutorial suppression.
