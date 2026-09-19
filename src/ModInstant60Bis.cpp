#include "ScriptMgr.h"
#include "Player.h"
#include "Item.h"
#include "SpellMgr.h"
#include "SpellInfo.h"
#include "SpellAuraDefines.h"
#include <vector>

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
// already set via playercreateinfo_action) plus the four fixed multi-bars
// (72-119) - with every spell the character actually knows, skipping passives and
// skipping mount spells (there can be 200+ of those; one is plenty for a button).
// Slots 12-71 are stance/shapeshift pages that only render while in that specific
// stance, so they're deliberately left alone.
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
            72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83,
            84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
            96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107,
            108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119
        };

        for (uint8 slot : fillableSlots)
            player->removeActionButton(slot);

        std::vector<uint32> spellsToPlace;
        for (auto const& itr : player->GetSpellMap())
        {
            if (!itr.second->Active)
                continue;

            SpellInfo const* info = sSpellMgr->GetSpellInfo(itr.first);
            if (!info || info->IsPassive())
                continue;

            if (info->HasAura(SPELL_AURA_MOUNTED))
                continue;

            spellsToPlace.push_back(itr.first);
        }

        size_t maxSlots = sizeof(fillableSlots) / sizeof(fillableSlots[0]);
        for (size_t i = 0; i < spellsToPlace.size() && i < maxSlots; ++i)
            player->addActionButton(fillableSlots[i], spellsToPlace[i], ACTION_BUTTON_SPELL);

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
