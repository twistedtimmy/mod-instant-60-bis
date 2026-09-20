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
    -- upkeep, paid every hour from the guild bank
    local upkeep = { ["Hero"] = "5 gold", ["Flight Master"] = "2 gold", ["Banker"] = "2 gold",
                     ["Auctioneer"] = "1 gold", ["Innkeeper"] = "1 gold", ["Repair Vendor"] = "1 gold",
                     ["Vendor"] = "1 gold", ["Guard"] = "50 silver",
                     ["Stable Master"] = "1 gold", ["Musician"] = "50 silver", ["Dancer"] = "50 silver" }
    tip:AddLine("Upkeep: " .. (upkeep[what] or "1 gold") .. " per hour from your guild bank. If the bank can't pay, your NPCs lose 25% health per hour until they die.", 1, 0.82, 0, true)
    if what == "Banker" then
        tip:AddLine("Only one Banker per guild. If it is killed, its corpse holds your whole guild bank.", 1, 0.3, 0.3, true)
    end
    tip:Show()
end
for _, t in ipairs({GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2}) do
    if t then t:HookScript("OnTooltipSetItem", zcFixTooltip) end
end

-- ZeroCraft: tooltip for the Commander's Banner
local function zcBannerTip(tip)
    local name = tip:GetItem()
    local use
    if name == "Commander's Banner: Target" then
        use = "Use: Target one of your NPCs, then click the ground. Only that NPC moves there and holds that post."
    elseif name == "Commander's Banner: All" then
        use = "Use: Click the ground. All of your NPCs move there and hold that post."
    else
        return
    end
    local tname = tip:GetName()
    for i = 2, tip:NumLines() do
        local line = _G[tname .. "TextLeft" .. i]
        local text = line and line:GetText()
        if text and text:find("^Use:") then
            line:SetText(use)
        elseif text and text:find("^\"") then
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

-- ZeroCraft: everyone is 60 and every dungeon is squished to 60, so the
-- Dungeon Finder lists every dungeon and every "Random ..." option.
local function zcLFDFilter(dungeonID)
    local _, _, _, _, _, _, _, expansionLevel, groupID = GetLFGDungeonInfo(dungeonID)
    return (groupID or 0) ~= 0 and (EXPANSION_LEVEL or 2) >= (expansionLevel or 0)
end
LFDList_DefaultFilterFunction = zcLFDFilter
LFD_CURRENT_FILTER = zcLFDFilter

local function zcLFDTypeInit()
    local info = UIDropDownMenu_CreateInfo()
    info.text = SPECIFIC_DUNGEONS
    info.value = "specific"
    info.func = LFDQueueFrameTypeDropDownButton_OnClick
    info.checked = LFDQueueFrame.type == info.value
    UIDropDownMenu_AddButton(info)
    for i = 1, GetNumRandomDungeons() do
        local id, name = GetLFGRandomDungeonInfo(i)
        local _, _, _, _, _, _, _, expansionLevel = GetLFGDungeonInfo(id)
        if (EXPANSION_LEVEL or 2) >= (expansionLevel or 0) then
            info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.value = id
            if IsLFGDungeonJoinable(id) then
                info.func = LFDQueueFrameTypeDropDownButton_OnClick
                info.checked = LFDQueueFrame.type == id
            else
                info.disabled = 1
                info.tooltipWhileDisabled = 1
                info.tooltipOnButton = 1
                info.tooltipTitle = YOU_MAY_NOT_QUEUE_FOR_THIS
                if LFDConstructDeclinedMessage then info.tooltipText = LFDConstructDeclinedMessage(id) end
            end
            UIDropDownMenu_AddButton(info)
        end
    end
end
LFDQueueFrameTypeDropDown_Initialize = zcLFDTypeInit
if LFDQueueFrameTypeDropDown then
    LFDQueueFrameTypeDropDown.initialize = zcLFDTypeInit
end

-- ZeroCraft: only two queues. "Random Dungeon" = every normal dungeon of every
-- expansion, "Random Heroic" = every heroic (the server builds those pools).
local ZC_RANDOM, ZC_HEROIC = 261, 262
local zcNames = { [ZC_RANDOM] = "Random Dungeon", [ZC_HEROIC] = "Random Heroic" }
local zcOrigInfo = GetLFGDungeonInfo
local function zcRename(id, name, ...)
    if zcNames[id] then name = zcNames[id] end
    return name, ...
end
GetLFGDungeonInfo = function(id, ...) return zcRename(id, zcOrigInfo(id, ...)) end
local zcOrigRandom = GetLFGRandomDungeonInfo
GetLFGRandomDungeonInfo = function(i, ...)
    local id, name = zcOrigRandom(i, ...)
    return id, zcNames[id] or name
end

local function zcLFDTypeInit2()
    for _, id in ipairs({ ZC_RANDOM, ZC_HEROIC }) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = zcNames[id]
        info.value = id
        info.func = LFDQueueFrameTypeDropDownButton_OnClick
        info.checked = LFDQueueFrame.type == id
        UIDropDownMenu_AddButton(info)
    end
end
LFDQueueFrameTypeDropDown_Initialize = zcLFDTypeInit2
if LFDQueueFrameTypeDropDown then LFDQueueFrameTypeDropDown.initialize = zcLFDTypeInit2 end

-- anything else the UI tries to select becomes Random Dungeon
if LFDQueueFrame_SetType then
    hooksecurefunc("LFDQueueFrame_SetType", function(value)
        if value ~= ZC_RANDOM and value ~= ZC_HEROIC then LFDQueueFrame_SetType(ZC_RANDOM) end
    end)
end

-- ZeroCraft: world map - only Kalimdor and Eastern Kingdoms in the continent
-- dropdown. You can zoom out to the Azeroth view (its art still shows Northrend;
-- the 1.12 picture needs a client patch). Clicking Northrend there, or zooming
-- out to the Outland/Azeroth view, just stays on Azeroth. Dungeon maps are untouched.
if WorldMap_LoadContinents then
    local zcOrigLoadContinents = WorldMap_LoadContinents
    WorldMap_LoadContinents = function(kalimdor, easternKingdoms)
        zcOrigLoadContinents(kalimdor, easternKingdoms)
    end
end

local zcMapBusy = false
local zcMap = CreateFrame("Frame")
zcMap:RegisterEvent("WORLD_MAP_UPDATE")
zcMap:SetScript("OnEvent", function()
    if zcMapBusy or not WorldMapFrame:IsShown() or IsInInstance() then return end
    local c = GetCurrentMapContinent()
    if c == 3 or c == 4 or c == -1 then
        zcMapBusy = true
        SetMapZoom(0)
        zcMapBusy = false
    end
end)

-- ZeroCraft: Northrend is painted out of the world picture (Data\patch-Z.MPQ);
-- don't name it when the mouse passes over where it used to be.
if WorldMapButton and WorldMapFrameAreaLabel then
    WorldMapButton:HookScript("OnUpdate", function()
        local t = WorldMapFrameAreaLabel:GetText()
        if t == "Northrend" or t == "Outland" then WorldMapFrameAreaLabel:SetText("") end
    end)
end

-- ZeroCraft: always show names and guilds over players' heads (your own too).
local zcNames = CreateFrame("Frame")
zcNames:RegisterEvent("PLAYER_ENTERING_WORLD")
zcNames:SetScript("OnEvent", function()
    for _, cvar in ipairs({ "UnitNameOwn", "UnitNamePlayerGuild", "UnitNamePlayerPVPTitle",
                            "UnitNameFriendlyPlayerName", "UnitNameEnemyPlayerName" }) do
        if GetCVar(cvar) ~= "1" then SetCVar(cvar, "1") end
    end
end)

-- ZeroCraft: the flight map only shows your guild's flight points. The server
-- sends "ZCTAXI:name;name;..." right before the map opens; every other flight
-- point is only a stopover your flight passes through, so its button is hidden.
local zcTaxiAllowed = nil
local zcTaxi = CreateFrame("Frame")
zcTaxi:RegisterEvent("CHAT_MSG_SYSTEM")
zcTaxi:RegisterEvent("TAXIMAP_OPENED")
local function zcTaxiHide()
    if not zcTaxiAllowed then return end
    for i = 1, NumTaxiNodes() do
        local b = _G["TaxiButton" .. i]
        if b and TaxiNodeGetType(i) ~= "CURRENT" and not zcTaxiAllowed[TaxiNodeName(i)] then b:Hide() end
    end
end
zcTaxi:SetScript("OnEvent", function(self, event, msg)
    if event == "CHAT_MSG_SYSTEM" then
        if msg and msg:sub(1, 7) == "ZCTAXI:" then
            zcTaxiAllowed = {}
            for name in msg:sub(8):gmatch("([^;]+)") do zcTaxiAllowed[name] = true end
        end
    else
        zcTaxiHide()
    end
end)
if TaxiFrame then TaxiFrame:HookScript("OnShow", zcTaxiHide) end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
    if msg and msg:sub(1, 7) == "ZCTAXI:" then return true end
end)

-- ZeroCraft: the flight map draws lines to every stopover the moment it opens,
-- which looks messy. Hide them; the route still draws when you hover a destination.
local function zcTaxiHideLines()
    for i = 1, 64 do
        local line = _G["TaxiRoute" .. i]
        if line then line:Hide() end
    end
end
if TaxiFrame then TaxiFrame:HookScript("OnShow", function() zcTaxiHideLines() end) end
local zcTaxiLines = CreateFrame("Frame")
zcTaxiLines:RegisterEvent("TAXIMAP_OPENED")
zcTaxiLines:SetScript("OnEvent", function() zcTaxiHideLines() end)
if TaxiNodeOnButtonLeave then hooksecurefunc("TaxiNodeOnButtonLeave", zcTaxiHideLines) end

-- ZeroCraft: a new character's first 10 minutes are quiet. The server sends
-- "ZCQUIET:<seconds>" at login; until then only the "You are ..." line shows.
local zcQuietUntil = 0
local zcQuietEvents = { "CHAT_MSG_SYSTEM", "CHAT_MSG_ACHIEVEMENT", "CHAT_MSG_GUILD_ACHIEVEMENT",
    "CHAT_MSG_COMBAT_FACTION_CHANGE", "CHAT_MSG_SKILL", "CHAT_MSG_LOOT", "CHAT_MSG_MONEY",
    "CHAT_MSG_CHANNEL_NOTICE", "CHAT_MSG_CHANNEL_NOTICE_USER", "CHAT_MSG_TRADESKILLS", "CHAT_MSG_OPENING" }
for _, ev in ipairs(zcQuietEvents) do
    ChatFrame_AddMessageEventFilter(ev, function(self, event, msg)
        if event == "CHAT_MSG_SYSTEM" and msg and msg:sub(1, 8) == "ZCQUIET:" then
            zcQuietUntil = GetTime() + (tonumber(msg:sub(9)) or 0)
            return true
        end
        if GetTime() < zcQuietUntil then
            if event == "CHAT_MSG_SYSTEM" and msg and msg:sub(1, 8) == "You are " and msg:find("Sworn enemies") then
                return false
            end
            return true
        end
    end)
end

-- ZeroCraft: free talents. Left click = +1 point, right click = -1 point
-- (no cost, change any time). "Builds" button applies a full build in one click.
local ZC_BUILDS = {
    WARRIOR = { { "[Vanilla] Arms (Two-Hander)", "35 / 8 / 8" }, { "[Vanilla] Fury (Dual Wield)", "19 / 32 / 0" }, { "[Vanilla] Protection (One-Hander + Shield)", "15 / 5 / 31" } },
    PALADIN = { { "[Vanilla] Holy (One-Hander + Shield)", "31 / 20 / 0" }, { "[Vanilla] Protection (One-Hander + Shield)", "0 / 33 / 18" }, { "[Vanilla] Retribution (Two-Hander)", "11 / 5 / 35" }, { "[Vanilla] Retribution (Two-Hander, Protection utility)", "3 / 17 / 31" } },
    HUNTER = { { "[Vanilla] Beast Mastery (Pet)", "34 / 17 / 0" }, { "[Vanilla] Marksmanship (Shots)", "7 / 34 / 10" }, { "[Vanilla] Survival (Wyvern Sting)", "0 / 15 / 36" } },
    ROGUE = { { "[Vanilla] Assassination (Seal Fate, Daggers)", "31 / 13 / 7" }, { "[Vanilla] Combat (Dual Swords / Axes)", "20 / 31 / 0" }, { "[Vanilla] Combat (Dual Fist Weapons)", "20 / 31 / 0" }, { "[Vanilla] Subtlety (Daggers)", "20 / 0 / 31" } },
    PRIEST = { { "[Vanilla] Discipline (Healer)", "33 / 18 / 0" }, { "[Vanilla] Holy (Healer)", "18 / 33 / 0" }, { "[Vanilla] Shadow (Damage)", "14 / 0 / 37" }, { "[Vanilla] Shadow (Damage, Discipline support)", "20 / 0 / 31" } },
    SHAMAN = { { "[Vanilla] Elemental (Caster)", "37 / 14 / 0" }, { "[Vanilla] Enhancement (Dual Wield)", "19 / 32 / 0" }, { "[Vanilla] Restoration (Group Healing)", "0 / 13 / 38" }, { "[Vanilla] Restoration (Tank Healing)", "0 / 16 / 35" } },
    MAGE = { { "[Vanilla] Arcane", "36 / 3 / 12" }, { "[Vanilla] Fire", "18 / 33 / 0" }, { "[Vanilla] Frost", "18 / 0 / 33" } },
    WARLOCK = { { "[Vanilla] Affliction", "35 / 0 / 16" }, { "[Vanilla] Demonology", "0 / 34 / 17" }, { "[Vanilla] Destruction", "0 / 13 / 38" } },
    DRUID = { { "[Vanilla] Balance (Moonkin)", "38 / 0 / 13" }, { "[Vanilla] Feral (Cat)", "0 / 35 / 16" }, { "[Vanilla] Restoration (Swiftmend)", "18 / 0 / 33" }, { "[Vanilla] Restoration (Deep Restoration)", "11 / 0 / 40" } },
}

local function zcTalentSend(cmd)
    SendAddonMessage("ZCT", cmd, "WHISPER", UnitName("player"))
end

local function zcTalentHook()
    if not PlayerTalentFrame or PlayerTalentFrame.zcHooked then return end
    PlayerTalentFrame.zcHooked = true
    SetCVar("previewTalents", "0")

    local original = PlayerTalentFrameTalent_OnClick
    local function onClick(self, button)
        if button == "RightButton" and not IsModifiedClick("CHATLINK") and not PlayerTalentFrame.pet and not PlayerTalentFrame.inspect then
            local link = GetTalentLink(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID(), false, false, PlayerTalentFrame.talentGroup)
            local id = link and link:match("talent:(%d+)")
            if id then zcTalentSend("del:" .. id) end
            return
        end
        original(self, button)
    end
    for i = 1, (MAX_NUM_TALENTS or 40) do
        local b = _G["PlayerTalentFrameTalent" .. i]
        if b then
            b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            b:SetScript("OnClick", onClick)
        end
    end

    -- Builds button + menu
    local _, class = UnitClass("player")
    local builds = ZC_BUILDS[class]
    local btn = CreateFrame("Button", "ZeroCraftBuildsButton", PlayerTalentFrame, "UIPanelButtonTemplate")
    btn:SetSize(80, 22)
    btn:SetText("Builds")
    btn:SetPoint("TOPRIGHT", PlayerTalentFrame, "TOPRIGHT", -42, -44)
    local menu = CreateFrame("Frame", "ZeroCraftBuildsMenu", UIParent, "UIDropDownMenuTemplate")
    local function init()
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Vanilla builds (51 points)"; info.isTitle = 1; info.notCheckable = 1
        UIDropDownMenu_AddButton(info)
        for i, b in ipairs(builds or {}) do
            info = UIDropDownMenu_CreateInfo()
            info.text = b[1]
            info.notCheckable = 1
            info.tooltipTitle = b[1]
            info.tooltipText = b[2]
            info.tooltipOnButton = 1
            info.func = function()
                zcTalentSend("build:" .. (i - 1))
                DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ZeroCraft:|r " .. b[1] .. " build applied (" .. b[2] .. ").")
            end
            UIDropDownMenu_AddButton(info)
        end
        info = UIDropDownMenu_CreateInfo()
        info.text = "Reset all talents"; info.notCheckable = 1
        info.tooltipTitle = "Reset"; info.tooltipText = "Takes back every point. Free."; info.tooltipOnButton = 1
        info.func = function() zcTalentSend("reset") end
        UIDropDownMenu_AddButton(info)
    end
    btn:SetScript("OnClick", function(self)
        UIDropDownMenu_Initialize(menu, init, "MENU")
        ToggleDropDownMenu(1, nil, menu, self, 0, 0)
    end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Talent builds")
        GameTooltip:AddLine("Pick a proven build to fill your talents in one click. Left click a talent to add a point, right click to take one back. Always free.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local zcTal = CreateFrame("Frame")
zcTal:RegisterEvent("ADDON_LOADED")
zcTal:SetScript("OnEvent", function(self, event, name)
    if name == "Blizzard_TalentUI" then zcTalentHook() end
end)
if IsAddOnLoaded and IsAddOnLoaded("Blizzard_TalentUI") then zcTalentHook() end
