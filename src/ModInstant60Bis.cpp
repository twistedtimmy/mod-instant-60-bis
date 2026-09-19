#include "ScriptMgr.h"
#include "Player.h"
#include "Item.h"
#include "SpellMgr.h"
#include "SpellInfo.h"
#include "SpellAuraDefines.h"
#include "SharedDefines.h"
#include "WorldSession.h"
#include "Common.h"
#include <vector>
#include <algorithm>
#include <utility>

// Every character spawns with its BiS kit already sitting in playercreateinfo_item,
// but Blizzard's client hardcodes level-1 starter items (robe/pants/boots/weapon)
// into the equip slots before those rows are ever applied, so the BiS items land
// unequipped in the backpack instead. This hook runs the server's own auto-equip
// logic (the same one used when a player double-clicks an item) over every item
// still sitting in the backpack right after creation, so anything epic+ takes over
// its equip slot immediately - no client addon, no login required.
//
// It also fills every action bar the client always shows regardless of stance or
// form - the main bar (slots 0-10, slot 11 is reserved for the single mount button
// already set via playercreateinfo_action) plus the four fixed multi-bars, with
// every spell the character actually knows, skipping passives and skipping mount
// spells (there can be 200+ of those; one is plenty for a button). Slots 12-23 are
// the stance/shapeshift bonus page that only renders while in that specific
// stance, so it's deliberately left alone. The four multi-bar ranges below were
// confirmed against the live client (reading each bar's real action slot via
// button:GetAttribute("action")), not guessed: RightActionBar=24-35,
// LeftActionBar=36-47, BottomRightActionBar=48-59, BottomLeftActionBar=60-71.
class ModInstant60BisPlayerScript : public PlayerScript
{
public:
    ModInstant60BisPlayerScript() : PlayerScript("ModInstant60BisPlayerScript") { }

    void OnPlayerCreate(Player* player) override
    {
        for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
        {
            Item* item = player->GetItemByPos(INVENTORY_SLOT_BAG_0, slot);
            if (!item)
                continue;

            ItemTemplate const* proto = item->GetTemplate();
            if (!proto || proto->Quality < ITEM_QUALITY_EPIC)
                continue;

            uint8 equipSlot = player->FindEquipSlot(proto, NULL_SLOT, true);
            if (equipSlot == NULL_SLOT)
                continue;

            // Don't fight over a slot that already holds an epic+ item from an
            // earlier iteration this pass (e.g. two competing weapon options) -
            // first one found wins, rather than flip-flopping between them.
            if (Item* current = player->GetItemByPos(INVENTORY_SLOT_BAG_0, equipSlot))
            {
                ItemTemplate const* currentProto = current->GetTemplate();
                if (currentProto && currentProto->Quality >= ITEM_QUALITY_EPIC)
                    continue;
            }

            uint16 dest = ((INVENTORY_SLOT_BAG_0 << 8) | equipSlot);
            if (dest == item->GetPos())
                continue;

            player->SwapItem(item->GetPos(), dest);
        }

        static const uint8 fillableSlots[] = {
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
            24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
            36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
            48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
            60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71
        };

        for (uint8 slot : fillableSlots)
            player->removeActionButton(slot);

        // These are the universal weapon/armor proficiency and riding-skill spells
        // granted to every class - they exist only to unlock permission to use gear
        // or ride mounts, Blizzard never gave them a real icon (they render as a
        // generic gear/cog placeholder), and they were never meant to sit on an
        // action bar. Excluded outright rather than merely deprioritized.
        static const uint32 utilitySpells[] = {
            750, 8737, 9078,                                            // armor
            196, 197, 198, 199, 201, 202, 1180, 227, 15590,             // melee weapons
            264, 5011, 266, 2567, 5009, 674,                            // ranged/dual wield
            33388, 33391, 34090, 34091, 54197                          // riding
        };
        auto isUtilitySpell = [](uint32 spellId)
        {
            for (uint32 id : utilitySpells)
                if (id == spellId)
                    return true;
            return false;
        };

        std::vector<std::pair<uint32, uint32>> spellsToPlace; // spellId, cooldownMs
        for (auto const& itr : player->GetSpellMap())
        {
            if (!itr.second->Active)
                continue;

            SpellInfo const* info = sSpellMgr->GetSpellInfo(itr.first);
            if (!info || info->IsPassive())
                continue;

            if (info->HasAura(SPELL_AURA_MOUNTED))
                continue;

            if (isUtilitySpell(itr.first))
                continue;

            // System/interaction spells every character has regardless of class
            // (Attack, Duel, Remove Insignia, lockpicking Opening/Closing) - these
            // were never given a real player-facing icon (the "yellow cog"
            // placeholder) because they're triggered contextually, not meant to be
            // cast from a bar. Identified by mechanical effect, not by ID, since
            // AlwaysMaxSkillForLevel can grant several ID variants of these
            // (different lockpicking skill thresholds, etc).
            if (info->HasEffect(SPELL_EFFECT_OPEN_LOCK) ||
                info->HasEffect(SPELL_EFFECT_SKIN_PLAYER_CORPSE) ||
                info->HasEffect(SPELL_EFFECT_ATTACK) ||
                info->HasEffect(SPELL_EFFECT_DUEL) ||
                info->HasEffect(SPELL_EFFECT_TALENT_SPEC_SELECT)) // Activate Primary/Secondary Spec
                continue;

            if (itr.first == 7267) // Grovel - real spell, but not useful on an auto-filled bar
                continue;

            // Skip anything that consumes a reagent - not something you want an
            // action bar auto-filled with, since running out silently breaks it.
            bool needsReagent = false;
            for (int32 reagent : info->Reagent)
            {
                if (reagent > 0)
                {
                    needsReagent = true;
                    break;
                }
            }
            if (needsReagent)
                continue;

            spellsToPlace.emplace_back(itr.first, info->GetRecoveryTime());
        }

        // Short/no-cooldown spells (the spam-every-fight rotation abilities) fill
        // the main bar first; long-cooldown and situational spells spill into the
        // overflow bars.
        std::sort(spellsToPlace.begin(), spellsToPlace.end(),
            [](std::pair<uint32, uint32> const& a, std::pair<uint32, uint32> const& b)
            {
                return a.second < b.second;
            });

        size_t maxSlots = sizeof(fillableSlots) / sizeof(fillableSlots[0]);
        for (size_t i = 0; i < spellsToPlace.size() && i < maxSlots; ++i)
            player->addActionButton(fillableSlots[i], spellsToPlace[i].first, ACTION_BUTTON_SPELL);

        // Belt-and-suspenders: make sure the mount button on the main bar survives
        // regardless of anything above.
        player->addActionButton(11, 23229, ACTION_BUTTON_SPELL);

        // Suppress every "new player" tutorial hint popup (bags, action bar, quest
        // log, etc.) by marking all 256 tutorial flag bits as already-seen. These
        // are stored per account, not per character, so this silences them for
        // every character on the account, not just this one.
        if (WorldSession* session = player->GetSession())
        {
            for (uint8 i = 0; i < MAX_ACCOUNT_TUTORIAL_VALUES; ++i)
                session->SetTutorialInt(i, 0xFFFFFFFF);
        }

        // OnPlayerCreate fires after the character has already been saved once and
        // the Player object is about to be destroyed with no further save - every
        // change made above only ever existed in memory and would otherwise be
        // silently lost. This is the save that actually makes it stick.
        player->SaveToDB(false, false);
    }
};

void Addmod_instant_60_bisScripts()
{
    new ModInstant60BisPlayerScript();
}
