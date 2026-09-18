local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    SetActionBarToggles(1,1,1,1,1)
    SHOW_MULTI_ACTIONBAR_1=1; SHOW_MULTI_ACTIONBAR_2=1; SHOW_MULTI_ACTIONBAR_3=1; SHOW_MULTI_ACTIONBAR_4=1
    ALWAYS_SHOW_MULTIBARS=1; MultiActionBar_Update()

    local single = {
        INVTYPE_HEAD=1, INVTYPE_NECK=2, INVTYPE_SHOULDER=3, INVTYPE_BODY=4,
        INVTYPE_CHEST=5, INVTYPE_ROBE=5, INVTYPE_WAIST=6, INVTYPE_LEGS=7,
        INVTYPE_FEET=8, INVTYPE_WRIST=9, INVTYPE_HAND=10, INVTYPE_CLOAK=15,
        INVTYPE_2HWEAPON=16, INVTYPE_WEAPONMAINHAND=16, INVTYPE_HOLDABLE=17,
        INVTYPE_SHIELD=17, INVTYPE_RANGED=18, INVTYPE_RANGEDRIGHT=18,
        INVTYPE_THROWN=18, INVTYPE_RELIC=18
    }
    local dual = {
        INVTYPE_FINGER  = {11, 12},
        INVTYPE_TRINKET = {13, 14},
        INVTYPE_WEAPON  = {16, 17}
    }

    for b = 0, 4 do
        for s = 1, GetContainerNumSlots(b) do
            local l = GetContainerItemLink(b, s)
            if l then
                local _, _, q, _, _, _, _, _, loc = GetItemInfo(l)
                if loc == "INVTYPE_BAG" then
                    for bg = 1, 4 do
                        if not GetInventoryItemLink("player", ContainerIDToInventoryID(bg)) then
                            UseContainerItem(b, s); break
                        end
                    end
                elseif q and q >= 4 then
                    if single[loc] then
                        local cl = GetInventoryItemLink("player", single[loc])
                        if not cl or (select(3, GetItemInfo(cl)) or -1) < 4 then
                            ClearCursor(); PickupContainerItem(b, s); EquipCursorItem(single[loc]); ClearCursor()
                        end
                    elseif dual[loc] then
                        for _, slot in ipairs(dual[loc]) do
                            local cl = GetInventoryItemLink("player", slot)
                            if not cl or (select(3, GetItemInfo(cl)) or -1) < 4 then
                                ClearCursor(); PickupContainerItem(b, s); EquipCursorItem(slot); ClearCursor()
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)
