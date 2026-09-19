#include "ScriptMgr.h"
#include "Player.h"
#include "Item.h"

// Every character spawns with its BiS kit already sitting in playercreateinfo_item,
// but Blizzard's client hardcodes level-1 starter items (robe/pants/boots/weapon)
// into the equip slots before those rows are ever applied, so the BiS items land
// unequipped in the backpack instead. This hook runs the server's own auto-equip
// logic (the same one used when a player double-clicks an item) over every item
// still sitting in the backpack right after creation, so anything epic+ takes over
// its equip slot immediately - no client addon, no login required.
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

            uint16 dest = ((INVENTORY_SLOT_BAG_0 << 8) | equipSlot);
            if (dest == item->GetPos())
                continue;

            player->SwapItem(item->GetPos(), dest);
        }
    }
};

void Addmod_instant_60_bisScripts()
{
    new ModInstant60BisPlayerScript();
}
