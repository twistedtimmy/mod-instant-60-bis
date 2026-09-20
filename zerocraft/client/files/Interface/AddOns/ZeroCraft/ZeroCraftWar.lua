-- ZeroCraft Guild War: territory control.
-- Every flight point is a territory. Whoever has a Flight Master standing there holds it.
-- The server sends "ZCTERR:" lines with the owners; this file draws them on the world map
-- (green = your guild, red = another guild, grey = nobody) and keeps a war report (/war).

local owners = {}          -- nodeId -> guild name
local pending = nil

local function myGuild() return (GetGuildInfo("player")) end

local function summary()
    local mine, total, counts = 0, 0, {}
    local me = myGuild()
    for id in pairs(ZC_WAR_NODES) do
        total = total + 1
        local g = owners[id]
        if g then
            counts[g] = (counts[g] or 0) + 1
            if g == me then mine = mine + 1 end
        end
    end
    local board = {}
    for g, n in pairs(counts) do board[#board + 1] = { g, n } end
    table.sort(board, function(a, b) return a[2] > b[2] or (a[2] == b[2] and a[1] < b[1]) end)
    return mine, total, board
end

---------------------------------------------------------------- world map pins
local pins = {}
local banner

local function getPin(i)
    local p = pins[i]
    if p then return p end
    p = CreateFrame("Frame", nil, WorldMapButton)
    p:SetWidth(16); p:SetHeight(16)
    p:SetFrameLevel(WorldMapButton:GetFrameLevel() + 5)
    p.tex = p:CreateTexture(nil, "OVERLAY")
    p.tex:SetAllPoints()
    p:EnableMouse(true)
    p:SetScript("OnEnter", function(self)
        WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT")
        WorldMapTooltip:AddLine(self.name, 1, 0.82, 0)
        if self.owner then
            local r, g, b = 1, 0.25, 0.25
            if self.owner == myGuild() then r, g, b = 0.25, 1, 0.25 end
            WorldMapTooltip:AddLine("Held by <" .. self.owner .. ">", r, g, b)
            if self.owner ~= myGuild() then
                WorldMapTooltip:AddLine("Kill their Flight Master to take it.", 0.8, 0.8, 0.8)
            end
        else
            WorldMapTooltip:AddLine("Unclaimed - deploy a Flight Master here to take it.", 0.7, 0.7, 0.7)
        end
        WorldMapTooltip:Show()
    end)
    p:SetScript("OnLeave", function() WorldMapTooltip:Hide() end)
    pins[i] = p
    return p
end

local function drawPins()
    for _, p in ipairs(pins) do p:Hide() end
    if not WorldMapFrame:IsShown() then return end
    local file = GetMapInfo()
    local m = file and ZC_WAR_MAPS[file]
    local level = GetCurrentMapDungeonLevel and GetCurrentMapDungeonLevel() or 0
    local w, h = WorldMapButton:GetWidth(), WorldMapButton:GetHeight()
    local me = myGuild()
    local n = 0
    if m and level == 0 then
        local mapId, left, right, top, bottom = m[1], m[2], m[3], m[4], m[5]
        for id, node in pairs(ZC_WAR_NODES) do
            if node[2] == mapId then
                local x = (left - node[4]) / (left - right)
                local y = (top - node[3]) / (top - bottom)
                if x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                    n = n + 1
                    local p = getPin(n)
                    local g = owners[id]
                    p.name, p.owner = node[1], g
                    if not g then p.tex:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Gray")
                    elseif g == me then p.tex:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Green")
                    else p.tex:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Red") end
                    p:ClearAllPoints()
                    p:SetPoint("CENTER", WorldMapButton, "TOPLEFT", x * w, -y * h)
                    p:Show()
                end
            end
        end
    end
    if not banner then
        banner = WorldMapFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        banner:SetPoint("TOP", WorldMapButton, "TOP", 0, -6)
    end
    local mine, total, board = summary()
    local lead = board[1] and ("   |   Leading: <" .. board[1][1] .. "> with " .. board[1][2]) or ""
    banner:SetText("Guild War: your guild holds " .. mine .. " of " .. total .. " flight points" .. lead .. "   (/war)")
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("WORLD_MAP_UPDATE")
ev:SetScript("OnEvent", drawPins)
WorldMapFrame:HookScript("OnShow", drawPins)

---------------------------------------------------------------- war report (/war)
local report
local function showReport()
    if not report then
        report = CreateFrame("Frame", "ZeroCraftWarReport", UIParent)
        report:SetWidth(340); report:SetHeight(420)
        report:SetPoint("CENTER")
        report:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 } })
        report:EnableMouse(true); report:SetMovable(true)
        report:RegisterForDrag("LeftButton")
        report:SetScript("OnDragStart", report.StartMoving)
        report:SetScript("OnDragStop", report.StopMovingOrSizing)
        tinsert(UISpecialFrames, "ZeroCraftWarReport")
        local close = CreateFrame("Button", nil, report, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -6, -6)
        report.title = report:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        report.title:SetPoint("TOP", 0, -18)
        report.title:SetText("Guild War Report")
        report.text = report:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        report.text:SetPoint("TOPLEFT", 22, -48)
        report.text:SetWidth(296)
        report.text:SetJustifyH("LEFT"); report.text:SetJustifyV("TOP")
    end
    local mine, total, board = summary()
    local me = myGuild()
    local lines = { "|cffffd100Flight points held|r" }
    for i = 1, math.min(#board, 10) do
        local g, c = board[i][1], board[i][2]
        local col = (g == me) and "|cff40ff40" or "|cffff5050"
        lines[#lines + 1] = i .. ".  " .. col .. "<" .. g .. ">|r  " .. c
    end
    if #board == 0 then lines[#lines + 1] = "Nobody holds a flight point yet." end
    lines[#lines + 1] = " "
    lines[#lines + 1] = "|cffffd100Your territories (" .. mine .. " of " .. total .. ")|r"
    local names = {}
    for id, g in pairs(owners) do
        if g == me and ZC_WAR_NODES[id] then names[#names + 1] = ZC_WAR_NODES[id][1] end
    end
    table.sort(names)
    if #names == 0 then names[1] = "None - deploy a Flight Master at a flight point to claim it." end
    for _, nm in ipairs(names) do lines[#lines + 1] = "  " .. nm end
    lines[#lines + 1] = " "
    lines[#lines + 1] = "|cff999999Each flight point earns its guild 5 gold an hour.|r"
    report.text:SetText(table.concat(lines, "\n"))
    report:Show()
end
SLASH_ZCWAR1 = "/war"
SLASH_ZCWAR2 = "/territory"
SlashCmdList["ZCWAR"] = function() if report and report:IsShown() then report:Hide() else showReport() end end

---------------------------------------------------------------- server data
local function onSystem(msg)
    local body = msg:sub(8)
    if body == "!" then
        pending = {}
    elseif body == "." then
        if pending then owners = pending; pending = nil end
        drawPins()
        if report and report:IsShown() then showReport() end
    elseif pending then
        for id, g in body:gmatch("(%d+)=([^;]+)") do pending[tonumber(id)] = g end
    end
end
local sys = CreateFrame("Frame")
sys:RegisterEvent("CHAT_MSG_SYSTEM")
sys:SetScript("OnEvent", function(self, event, msg)
    if msg and msg:sub(1, 7) == "ZCTERR:" then onSystem(msg) end
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
    if msg and msg:sub(1, 7) == "ZCTERR:" then return true end
end)

---------------------------------------------------------------- conquered zones
-- server sends "ZCZONE:" lines: name=owner|topGuild|held|total|guildsPresent;
local zones, zpending = {}, nil
local function zoneInfo(name) return name and zones[name] end

-- colour + text for a zone, from the viewer's point of view
local function zoneLabel(z)
    if not z then return nil end
    local me = myGuild()
    if z.owner ~= "" then
        if z.owner == me then return "<" .. z.owner .. "> Territory - yours", 0.25, 1, 0.25 end
        return "<" .. z.owner .. "> Territory", 1, 0.2, 0.2
    end
    if z.held > 0 then
        local r, g, b = 1, 0.6, 0.1
        if z.top == me and z.guilds == 1 then r, g, b = 0.6, 1, 0.6 end
        local who = (z.guilds > 1) and "Contested" or ("<" .. z.top .. "> holds")
        return who .. " - " .. z.held .. " of " .. z.total .. " flight points", r, g, b
    end
    return nil
end

-- entering a zone: the big zone text gets a third line, red in enemy territory, green in yours
local function paintZoneText()
    local label, r, g, b = zoneLabel(zoneInfo(GetZoneText()))
    if not label then return end
    if PVPInfoTextString then
        PVPInfoTextString:SetText("(" .. label .. ")")
        PVPInfoTextString:SetTextColor(r, g, b)
    end
    if ZoneTextString and zoneInfo(GetZoneText()).owner ~= "" then ZoneTextString:SetTextColor(r, g, b) end
end
if SetZoneText then hooksecurefunc("SetZoneText", function(showZone) if showZone then paintZoneText() end end) end

-- minimap zone name: red in enemy territory, green in yours
local function paintMinimap()
    if not MinimapZoneText then return end
    local z = zoneInfo(GetZoneText())
    if z and z.owner ~= "" then
        if z.owner == myGuild() then MinimapZoneText:SetTextColor(0.25, 1, 0.25) else MinimapZoneText:SetTextColor(1, 0.2, 0.2) end
    end
end
if Minimap_Update then hooksecurefunc("Minimap_Update", paintMinimap) end
if MinimapZoneTextButton then
    MinimapZoneTextButton:HookScript("OnEnter", function()
        local label, r, g, b = zoneLabel(zoneInfo(GetZoneText()))
        if label then GameTooltip:AddLine(label, r, g, b); GameTooltip:Show() end
    end)
end

-- world map: conquered zones get their guild's name written across them on the continent map,
-- and the zone map shows the owner's name under its title
local zlabels, tint = {}, nil
local function drawZones()
    for _, l in ipairs(zlabels) do l:Hide() end
    if tint then tint:Hide() end
    if not WorldMapFrame:IsShown() then return end
    local file = GetMapInfo()
    local here = file and ZC_WAR_MAPS[file]
    if not here then return end
    local me = myGuild()
    local w, h = WorldMapButton:GetWidth(), WorldMapButton:GetHeight()
    local zname = ZC_WAR_ZONENAME and ZC_WAR_ZONENAME[file]
    if zname and zones[zname] then
        -- a single zone's map: tint it
        local z = zones[zname]
        if z.owner ~= "" then
            -- no tint: the guild's name sits under the map title instead
            if not tint then
                tint = WorldMapButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                tint:SetPoint("TOP", WorldMapButton, "TOP", 0, -62)
            end
            tint:SetText("Controlled by <" .. z.owner .. ">")
            if z.owner == me then tint:SetTextColor(0.25, 1, 0.25) else tint:SetTextColor(1, 0.25, 0.25) end
            tint:Show()
        end
        return
    end
    -- a continent: label each conquered zone at its centre
    local n = 0
    for mfile, zn in pairs(ZC_WAR_ZONENAME or {}) do
        local z, m = zones[zn], ZC_WAR_MAPS[mfile]
        if z and z.owner ~= "" and m and m[1] == here[1] and mfile ~= file then
            local cy = (m[2] + m[3]) / 2          -- world Y (left/right)
            local cx = (m[4] + m[5]) / 2          -- world X (top/bottom)
            local x = (here[2] - cy) / (here[2] - here[3])
            local y = (here[4] - cx) / (here[4] - here[5])
            if x > 0 and x < 1 and y > 0 and y < 1 then
                n = n + 1
                local l = zlabels[n]
                if not l then
                    l = WorldMapButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    zlabels[n] = l
                end
                l:ClearAllPoints()
                l:SetPoint("CENTER", WorldMapButton, "TOPLEFT", x * w, -y * h + 12)
                l:SetText("<" .. z.owner .. ">")
                if z.owner == me then l:SetTextColor(0.25, 1, 0.25) else l:SetTextColor(1, 0.25, 0.25) end
                l:Show()
            end
        end
    end
end
local zev = CreateFrame("Frame")
zev:RegisterEvent("WORLD_MAP_UPDATE")
zev:SetScript("OnEvent", drawZones)
WorldMapFrame:HookScript("OnShow", drawZones)

local zsys = CreateFrame("Frame")
zsys:RegisterEvent("CHAT_MSG_SYSTEM")
zsys:SetScript("OnEvent", function(self, event, msg)
    if not msg or msg:sub(1, 7) ~= "ZCZONE:" then return end
    local body = msg:sub(8)
    if body == "!" then zpending = {}
    elseif body == "." then
        if zpending then zones = zpending; zpending = nil end
        drawZones(); paintMinimap()
    elseif zpending then
        for name, owner, top, held, total, guilds in body:gmatch("([^=;]+)=([^|]*)|([^|]*)|(%d+)|(%d+)|(%d+);") do
            zpending[name] = { owner = owner, top = top, held = tonumber(held), total = tonumber(total), guilds = tonumber(guilds) }
        end
    end
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
    if msg and msg:sub(1, 7) == "ZCZONE:" then return true end
end)

-- /war also lists conquered zones
local baseWar = SlashCmdList["ZCWAR"]
SlashCmdList["ZCWAR"] = function()
    baseWar()
    if not (ZeroCraftWarReport and ZeroCraftWarReport:IsShown() and ZeroCraftWarReport.text) then return end
    local me = myGuild()
    local lines = { ZeroCraftWarReport.text:GetText(), " ", "|cffffd100Conquered zones|r" }
    local any = false
    for name, z in pairs(zones) do
        if z.owner ~= "" then
            any = true
            local col = (z.owner == me) and "|cff40ff40" or "|cffff5050"
            lines[#lines + 1] = "  " .. name .. " - " .. col .. "<" .. z.owner .. ">|r"
        end
    end
    if not any then lines[#lines + 1] = "  None yet - hold every flight point in a zone to conquer it." end
    lines[#lines + 1] = "|cff999999Each conquered zone pays 20 gold an hour on top.|r"
    ZeroCraftWarReport.text:SetText(table.concat(lines, "\n"))
    ZeroCraftWarReport:SetHeight(math.max(420, 60 + 13 * #lines + 180))
end

---------------------------------------------------------------- Summoning Stone bank
-- the stone opens the guild bank directly; this button brings up the stone's other options
local stoneBtn
local function addStoneButton()
    if stoneBtn or not GuildBankFrame then return end
    stoneBtn = CreateFrame("Button", "ZeroCraftStoneOptions", GuildBankFrame, "UIPanelButtonTemplate")
    stoneBtn:SetWidth(120); stoneBtn:SetHeight(22)
    stoneBtn:SetPoint("TOPLEFT", GuildBankFrame, "TOPLEFT", 24, -40)
    stoneBtn:SetText("Stone Options")
    stoneBtn:SetScript("OnClick", function()
        CloseGuildBankFrame()
        SendAddonMessage("ZCSTONE", "menu", "WHISPER", UnitName("player"))
    end)
end
local sb = CreateFrame("Frame")
sb:RegisterEvent("GUILDBANKFRAME_OPENED")
sb:RegisterEvent("ADDON_LOADED")
sb:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name ~= "Blizzard_GuildBankUI" then return end
    addStoneButton()
    if stoneBtn then stoneBtn:Show() end
end)

---------------------------------------------------------------- attack alerts
-- "ZCALERT:attack|map|x|y|npc|by" / "ZCALERT:fallen|..." - a mark on the world map (10 minutes),
-- a sound, and a chat line with the zone and map coordinates
local alerts = {}
local ALERT_TIME = 600

local function zoneAt(mapId, wx, wy)
    local best, bestArea, bx, by
    for file, m in pairs(ZC_WAR_MAPS) do
        if m[1] == mapId and ZC_WAR_ZONENAME and ZC_WAR_ZONENAME[file] then
            local x = (m[2] - wy) / (m[2] - m[3])
            local y = (m[4] - wx) / (m[4] - m[5])
            if x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                local area = math.abs((m[2] - m[3]) * (m[4] - m[5]))
                if not bestArea or area < bestArea then best, bestArea, bx, by = file, area, x, y end
            end
        end
    end
    return best, bx, by
end

local apins = {}
local function drawAlerts()
    for _, p in ipairs(apins) do p:Hide() end
    if not WorldMapFrame:IsShown() then return end
    local file = GetMapInfo()
    local m = file and ZC_WAR_MAPS[file]
    if not m then return end
    local w, h = WorldMapButton:GetWidth(), WorldMapButton:GetHeight()
    local now, n = GetTime(), 0
    for i = #alerts, 1, -1 do
        local a = alerts[i]
        if now - a.t > ALERT_TIME then table.remove(alerts, i)
        elseif a.map == m[1] then
            local x = (m[2] - a.y) / (m[2] - m[3])
            local y = (m[4] - a.x) / (m[4] - m[5])
            if x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                n = n + 1
                local p = apins[n]
                if not p then
                    p = CreateFrame("Frame", nil, WorldMapButton)
                    p:SetWidth(24); p:SetHeight(24)
                    p:SetFrameLevel(WorldMapButton:GetFrameLevel() + 7)
                    p.tex = p:CreateTexture(nil, "OVERLAY"); p.tex:SetAllPoints()
                    p:EnableMouse(true)
                    p:SetScript("OnEnter", function(self)
                        WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        WorldMapTooltip:AddLine(self.head, 1, 0.2, 0.2)
                        WorldMapTooltip:AddLine(self.body, 1, 1, 1)
                        WorldMapTooltip:AddLine(self.ago, 0.7, 0.7, 0.7)
                        WorldMapTooltip:Show()
                    end)
                    p:SetScript("OnLeave", function() WorldMapTooltip:Hide() end)
                    apins[n] = p
                end
                if a.kind == "fallen" then
                    p.tex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
                    p.head = "Fallen: " .. a.npc
                else
                    p.tex:SetTexture("Interface\\WorldStateFrame\\CombatSwords"); p.tex:SetTexCoord(0, 0.5, 0, 0.5)
                    p.head = "Under attack: " .. a.npc
                end
                if a.kind == "fallen" then p.tex:SetTexCoord(0, 1, 0, 1) end
                p.body = (a.kind == "fallen" and "Killed by " or "Attacked by ") .. a.by
                p.ago = math.floor((now - a.t) / 60) .. " min ago"
                p:ClearAllPoints()
                p:SetPoint("CENTER", WorldMapButton, "TOPLEFT", x * w, -y * h)
                p:Show()
            end
        end
    end
end
local aev = CreateFrame("Frame")
aev:RegisterEvent("WORLD_MAP_UPDATE")
aev:SetScript("OnEvent", drawAlerts)
WorldMapFrame:HookScript("OnShow", drawAlerts)

local asys = CreateFrame("Frame")
asys:RegisterEvent("CHAT_MSG_SYSTEM")
asys:SetScript("OnEvent", function(self, event, msg)
    if not msg or msg:sub(1, 8) ~= "ZCALERT:" then return end
    local kind, map, x, y, npc, by = msg:sub(9):match("([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|(.*)")
    if not kind then return end
    local a = { kind = kind, map = tonumber(map), x = tonumber(x), y = tonumber(y), npc = npc, by = by, t = GetTime() }
    table.insert(alerts, a)
    local file, zx, zy = zoneAt(a.map, a.x, a.y)
    local where = (file and ZC_WAR_ZONENAME[file] or "the wilds")
    if zx then where = where .. string.format(" (%d, %d)", zx * 100, zy * 100) end
    if kind == "fallen" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Guild Defense] " .. npc .. " has fallen at " .. where .. " - " .. by .. ". Marked on your map.|r")
        PlaySound("RaidWarning")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8020[Guild Defense] " .. npc .. " is under attack at " .. where .. " by " .. by .. ". Marked on your map.|r")
        PlaySound("PVPTHROUGHQUEUE")
    end
    drawAlerts()
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
    if msg and msg:sub(1, 8) == "ZCALERT:" then return true end
end)

-- "Open the Guild Vault" from a Summoning Stone's menu: show the guild bank window
local vsys = CreateFrame("Frame")
vsys:RegisterEvent("CHAT_MSG_SYSTEM")
vsys:SetScript("OnEvent", function(self, event, msg)
    if msg ~= "ZCVAULT:open" then return end
    if not GuildBankFrame then LoadAddOn("Blizzard_GuildBankUI") end
    addStoneButton()
    if not GuildBankFrame then return end
    if not GuildBankFrame.zcWrapped then
        GuildBankFrame.zcWrapped = true
        local orig = GuildBankFrame:GetScript("OnEvent")
        GuildBankFrame:SetScript("OnEvent", function(self, ev, ...)
            -- the game closes the window because no chest was clicked; the Summoning Stone is the chest
            if ev == "GUILDBANKFRAME_CLOSED" and self.zcStone then return end
            if orig then return orig(self, ev, ...) end
        end)
        GuildBankFrame:HookScript("OnHide", function(self) self.zcStone = nil; CloseGuildBankFrame() end)
    end
    GuildBankFrame.zcStone = true
    if not GuildBankFrame:IsShown() then ShowUIPanel(GuildBankFrame) end
    QueryGuildBankTab(GetCurrentGuildBankTab() or 1)
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
    if msg == "ZCVAULT:open" then return true end
end)

---------------------------------------------------------------- "Place it" -> Builder's Rod
-- WoW only lets a real click start ground targeting, so "Place it" pops a button under your
-- mouse: one click and the green circle appears. Esc or right-click cancels.
local rodBtn = CreateFrame("Button", "ZeroCraftPlaceNow", UIParent, "SecureActionButtonTemplate")
rodBtn:SetWidth(170); rodBtn:SetHeight(40)
rodBtn:SetFrameStrata("TOOLTIP")
rodBtn:SetAttribute("type", "item")
rodBtn:SetAttribute("item", "item:60407")
rodBtn:RegisterForClicks("LeftButtonUp")
rodBtn:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
rodBtn:SetBackdropBorderColor(0.2, 1, 0.2)
local rodTxt = rodBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rodTxt:SetPoint("CENTER"); rodTxt:SetText("|cff40ff40Click|r, then click the ground")
rodBtn:HookScript("OnClick", function(self) self.clicked = true; self:Hide() end)
rodBtn:SetScript("OnHide", function(self)
    self.t = nil
    -- closed with Esc (not clicked): stop stamping Duplicatron copies
    if not self.clicked then SendAddonMessage("ZCDUPEND", "stop", "WHISPER", UnitName("player")) end
    self.clicked = nil
end)
rodBtn:SetScript("OnUpdate", function(self, e)
    self.t = (self.t or 0) + e
    if self.t > 60 then self:Hide() end
end)
rodBtn:Hide()
local rsys = CreateFrame("Frame")
rsys:RegisterEvent("CHAT_MSG_SYSTEM")
rsys:SetScript("OnEvent", function(self, event, msg)
    if msg ~= "ZCROD:start" or InCombatLockdown() then return end
    local x, y = GetCursorPosition()
    local s = UIParent:GetEffectiveScale()
    rodBtn:ClearAllPoints()
    rodBtn:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / s, y / s)
    rodBtn:Show()
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
    if msg == "ZCROD:start" then return true end
end)
tinsert(UISpecialFrames, "ZeroCraftPlaceNow")

---------------------------------------------------------------- Profession Masters
-- The master opens your crafting window. If the game didn't open it by itself,
-- a button appears under your mouse: one click opens it.
local profBtn = CreateFrame("Button", "ZeroCraftOpenProfession", UIParent, "SecureActionButtonTemplate")
profBtn:SetWidth(190); profBtn:SetHeight(40)
profBtn:SetFrameStrata("TOOLTIP")
profBtn:SetAttribute("type", "spell")
profBtn:RegisterForClicks("LeftButtonUp")
profBtn:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
profBtn:SetBackdropBorderColor(1, 0.82, 0)
local profTxt = profBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
profTxt:SetPoint("CENTER")
profBtn:HookScript("OnClick", function(self) self:Hide() end)
profBtn:SetScript("OnHide", function(self) self.t = nil end)
profBtn:SetScript("OnUpdate", function(self, e)
    self.t = (self.t or 0) + e
    if self.t > 15 then self:Hide() end
end)
profBtn:Hide()
tinsert(UISpecialFrames, "ZeroCraftOpenProfession")
local pwait = CreateFrame("Frame"); pwait:Hide()
pwait:SetScript("OnUpdate", function(self, e)
    self.t = self.t + e
    if self.t < 0.8 then return end
    self:Hide()
    if (TradeSkillFrame and TradeSkillFrame:IsShown()) or InCombatLockdown() then return end
    local name = GetSpellInfo(self.spell)
    if not name then return end
    profBtn:SetAttribute("spell", name)
    profTxt:SetText("|cffffd100Open|r " .. name)
    local x, y = GetCursorPosition()
    local s = UIParent:GetEffectiveScale()
    profBtn:ClearAllPoints()
    profBtn:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / s, y / s)
    profBtn:Show()
end)
local psys = CreateFrame("Frame")
psys:RegisterEvent("CHAT_MSG_SYSTEM")
psys:RegisterEvent("TRADE_SKILL_SHOW")
psys:SetScript("OnEvent", function(self, event, msg)
    if event == "TRADE_SKILL_SHOW" then pwait:Hide(); profBtn:Hide(); return end
    local id = msg and msg:match("^ZCPROF:(%d+)$")
    if not id then return end
    pwait.spell = tonumber(id); pwait.t = 0; pwait:Show()
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
    if msg and msg:match("^ZCPROF:") then return true end
end)

---------------------------------------------------------------- icon picker helper
-- clicking an icon in the macro icon picker prints its name (and remembers it for the ZeroCraft team)
ZeroCraftSaved = ZeroCraftSaved or {}
local function hookMacroIcons()
    for i = 1, 20 do
        local b = _G["MacroPopupButton" .. i]
        if b and not b.zcHooked then
            b.zcHooked = true
            b:HookScript("OnClick", function(self)
                local idx = self:GetID() + (FauxScrollFrame_GetOffset(MacroPopupScrollFrame) * 5)
                local tex = GetMacroIconInfo(idx)
                if tex then
                    ZeroCraftSaved.lastIcon = tex
                    DEFAULT_CHAT_FRAME:AddMessage("|cff40ff40[ZeroCraft] Icon: " .. tex .. "|r")
                end
            end)
        end
    end
end
local mi = CreateFrame("Frame")
mi:RegisterEvent("ADDON_LOADED")
mi:SetScript("OnEvent", function(self, event, name) if name == "Blizzard_MacroUI" then hookMacroIcons() end end)
if MacroPopupButton1 then hookMacroIcons() end

---------------------------------------------------------------- new items glow in your bags
-- Anything that lands in your bags glows the next time you open them, until you hover it
-- or close the bag again.
local zcCount, zcNew, zcReady = {}, {}, false
local function zcScan(mark)
    local totals, where = {}, {}
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local id = tonumber(link:match("item:(%d+)"))
                local _, count = GetContainerItemInfo(bag, slot)
                if id then
                    totals[id] = (totals[id] or 0) + (count or 1)
                    where[id] = where[id] or {}
                    table.insert(where[id], bag .. ":" .. slot)
                end
            end
        end
    end
    if mark then
        for id, n in pairs(totals) do
            if n > (zcCount[id] or 0) then
                for _, k in ipairs(where[id]) do zcNew[k] = true end
            end
        end
    end
    zcCount = totals
end
local function zcGlow(frame)
    if not frame or not frame:IsShown() then return end
    local bag, name = frame:GetID(), frame:GetName()
    for i = 1, frame.size or 0 do
        local b = _G[name .. "Item" .. i]
        if b then
            if not b.zcGlow then
                b.zcGlow = b:CreateTexture(nil, "OVERLAY")
                b.zcGlow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
                b.zcGlow:SetBlendMode("ADD")
                b.zcGlow:SetVertexColor(1, 0.85, 0.2)
                b.zcGlow:SetWidth(70); b.zcGlow:SetHeight(70)
                b.zcGlow:SetPoint("CENTER", b, "CENTER", 0, 0)
                b:HookScript("OnEnter", function(self)
                    zcNew[self:GetParent():GetID() .. ":" .. self:GetID()] = nil
                    if self.zcGlow then self.zcGlow:Hide() end
                end)
            end
            if zcNew[bag .. ":" .. b:GetID()] then b.zcGlow:Show() else b.zcGlow:Hide() end
        end
    end
end
hooksecurefunc("ContainerFrame_Update", zcGlow)
local zcBag = CreateFrame("Frame")
zcBag:RegisterEvent("PLAYER_ENTERING_WORLD")
zcBag:RegisterEvent("BAG_UPDATE")
zcBag:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self.t, self.first = 0, not zcReady
        self:Show()
        return
    end
    self.t = 0
    self:Show()
end)
zcBag:SetScript("OnUpdate", function(self, e)
    self.t = (self.t or 0) + e
    if self.t < (self.first and 3 or 0.3) then return end
    self:Hide()
    zcScan(zcReady)          -- the very first look at your bags just remembers what's there
    zcReady, self.first = true, false
    for i = 1, NUM_CONTAINER_FRAMES do zcGlow(_G["ContainerFrame" .. i]) end
end)
zcBag:Hide()
-- closing a bag you've looked at: its items aren't new any more
for i = 1, NUM_CONTAINER_FRAMES do
    local f = _G["ContainerFrame" .. i]
    if f then
        f:HookScript("OnHide", function(self)
            local bag = self:GetID()
            for k in pairs(zcNew) do
                if k:match("^" .. bag .. ":") then zcNew[k] = nil end
            end
        end)
    end
end
