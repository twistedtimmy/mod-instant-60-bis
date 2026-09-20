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

-- ZeroCraft: no glyphs. Hide the Glyphs tab on the talent window.
local g = CreateFrame("Frame")
g:RegisterEvent("ADDON_LOADED")
g:SetScript("OnEvent", function(self, event, name)
    if name == "Blizzard_TalentUI" and PlayerTalentFrameTab4 then
        PlayerTalentFrameTab4:HookScript("OnShow", function(tab) tab:Hide() end)
        PlayerTalentFrameTab4:Hide()
        PlayerTalentFrame:HookScript("OnShow", function()
            PlayerTalentFrameTab4:Hide()
            if GlyphFrame and GlyphFrame:IsShown() then PlayerTalentFrameTab1:Click() end
        end)
    end
end)

-- ZeroCraft: hide the flood of "You have learned..." / "You have gained the ... skill"
-- messages during a character's first 5 minutes played.
local zcQuietUntil = GetTime() + 300   -- assume new until the server says otherwise
local function zcFilter(self, event, msg)
    if GetTime() < zcQuietUntil and msg and (msg:find("^You have learned") or msg:find("^You have gained the") or msg:find("^You have unlearned")) then
        return true
    end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", zcFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SKILL", zcFilter)

local zcTime = CreateFrame("Frame")
zcTime:RegisterEvent("PLAYER_ENTERING_WORLD")
zcTime:RegisterEvent("TIME_PLAYED_MSG")
zcTime:SetScript("OnEvent", function(self, event, total)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        for i = 1, NUM_CHAT_WINDOWS do local f = _G["ChatFrame"..i]; if f then f:UnregisterEvent("TIME_PLAYED_MSG") end end
        RequestTimePlayed()
    else
        zcQuietUntil = GetTime() + math.max(0, 300 - (total or 300))
        for i = 1, NUM_CHAT_WINDOWS do local f = _G["ChatFrame"..i]; if f then f:RegisterEvent("TIME_PLAYED_MSG") end end
    end
end)

-- ZeroCraft: keep bags clear of the right-side action bars.
local function zcBagOffset()
    local need = 0
    if MultiBarLeft and MultiBarLeft:IsShown() then need = 90
    elseif MultiBarRight and MultiBarRight:IsShown() then need = 45 end
    if (CONTAINER_OFFSET_X or 0) < need then CONTAINER_OFFSET_X = need end
end
hooksecurefunc("UIParent_ManageFramePositions", zcBagOffset)
local zcBags = CreateFrame("Frame")
zcBags:RegisterEvent("PLAYER_ENTERING_WORLD")
zcBags:SetScript("OnEvent", function() zcBagOffset(); if updateContainerFrameAnchors then updateContainerFrameAnchors() end end)

-- ZeroCraft: show "Deploying Guard" / "Deploying Vendor" / etc. on the cast bar
-- instead of the borrowed "Conjure Water" name.
local zcDeployWhat, zcDeployTime
local function zcRemember(name)
    if name then
        local what = name:match("^Deployable (.+)$")
        if what then zcDeployWhat, zcDeployTime = what, GetTime() end
    end
end
hooksecurefunc("UseContainerItem", function(bag, slot)
    local link = GetContainerItemLink(bag, slot)
    if link then zcRemember(GetItemInfo(link)) end
end)
hooksecurefunc("UseAction", function(slot)
    local kind, id = GetActionInfo(slot)
    if kind == "item" and id then zcRemember(GetItemInfo(id)) end
end)
hooksecurefunc("UseItemByName", function(name) zcRemember(GetItemInfo(name) or name) end)

local zcCast = CreateFrame("Frame")
zcCast:RegisterEvent("UNIT_SPELLCAST_START")
zcCast:SetScript("OnEvent", function(self, event, unit)
    if unit ~= "player" or not zcDeployWhat then return end
    local name = UnitCastingInfo("player")
    if name == "Conjure Water" and GetTime() - (zcDeployTime or 0) < 60 then
        CastingBarFrameText:SetText("Deploying " .. zcDeployWhat)
        zcDeployWhat = nil
    end
end)

-- ZeroCraft: replace the borrowed Flamestrike "Use:" text on deploy items.
local function zcFixTooltip(tip)
    local name = tip:GetItem()
    local what = name and name:match("^Deployable (.+)$")
    if not what then return end
    local tname = tip:GetName()
    for i = 2, tip:NumLines() do
        local line = _G[tname .. "TextLeft" .. i]
        local text = line and line:GetText()
        if text then
            if text:find("^Use:") then
                line:SetText("Use: Place on the ground, then cast for 5 seconds to deploy a random " .. what:lower() .. " loyal to you and your guild. Deployed NPCs die permanently.")
            elseif text:find("^\"Place it") then
                line:SetText("")
            end
        end
    end
    tip:Show()
end
for _, t in ipairs({GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2}) do
    if t then t:HookScript("OnTooltipSetItem", zcFixTooltip) end
end

-- ZeroCraft: tooltip for the Commander's Banner
local function zcBannerTip(tip)
    local name = tip:GetItem()
    if name ~= "Commander's Banner" then return end
    local tname = tip:GetName()
    for i = 2, tip:NumLines() do
        local line = _G[tname .. "TextLeft" .. i]
        local text = line and line:GetText()
        if text and text:find("^Use:") then
            line:SetText("Use: Target one of your NPCs (or nothing for all of yours), then click the ground. They move there and hold that post.")
        elseif text and text:find("^\"Target your NPC") then
            line:SetText("")
        end
    end
    tip:Show()
end
for _, t in ipairs({GameTooltip, ItemRefTooltip}) do if t then t:HookScript("OnTooltipSetItem", zcBannerTip) end end

-- ZeroCraft: the "Meteor" spell is really the Command spell - relabel its tooltip.
local function zcCmdTip(tip)
    local name, _, id = tip:GetSpell()
    if id ~= 24340 and name ~= "Meteor" then return end
    _G[tip:GetName() .. "TextLeft1"]:SetText("Command")
    for i = 2, tip:NumLines() do
        local l = _G[tip:GetName() .. "TextLeft" .. i]
        if l then l:SetText("") end
    end
    tip:AddLine("Target one of your NPCs (or nothing for all of yours), then click the ground. They move there and hold that post. Instant, no cooldown.", 0, 1, 0, true)
    tip:Show()
end
GameTooltip:HookScript("OnTooltipSetSpell", zcCmdTip)

-- ZeroCraft: max camera distance, fully zoomed out on login
local zcCam = CreateFrame("Frame")
zcCam:RegisterEvent("PLAYER_LOGIN")
zcCam:SetScript("OnEvent", function()
    SetCVar("cameraDistanceMax", 50)
    SetCVar("cameraDistanceMaxFactor", 4)
    CameraZoomOut(50)
end)

-- ZeroCraft: server error messages shown as red screen text instead of chat
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
    if msg and msg:sub(1, 6) == "ZCERR:" then
        if self == DEFAULT_CHAT_FRAME then UIErrorsFrame:AddMessage(msg:sub(7), 1.0, 0.1, 0.1, 1.0) end
        return true
    end
end)
