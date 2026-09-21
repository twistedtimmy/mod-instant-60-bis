---------------------------------------------------------------- Master Builder
-- The Master Builder's Tome opens this window: every placeable object (Build) and every deployable NPC
-- (Recruit), with a live 3D preview. Data comes from ZeroCraftBuildData.lua (generated on the server).
-- Server -> addon: "ZCMB:open|spot", "ZCMB:own|item=count,...", "ZCMB:own+|..." (continued), "ZCMB:built|name"
-- Addon -> server: "ZCMB" addon whisper: obj <entry> [here] | thing <action> [here] | npc <item> <kind> <entry> [here] | own
local function mbSend(...) SendAddonMessage("ZCMB", table.concat({ ... }, "\t"), "WHISPER", UnitName("player")) end

local MB = CreateFrame("Frame", "ZeroCraftMasterBuilder", UIParent)
MB:SetWidth(396); MB:SetHeight(644)
MB:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
MB:SetFrameStrata("DIALOG")
MB:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } })
MB:SetMovable(true); MB:EnableMouse(true); MB:RegisterForDrag("LeftButton"); MB:SetClampedToScreen(true)
MB:SetScript("OnDragStart", MB.StartMoving); MB:SetScript("OnDragStop", MB.StopMovingOrSizing)
MB:Hide()
tinsert(UISpecialFrames, "ZeroCraftMasterBuilder")

local title = MB:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); title:SetPoint("TOP", 0, -12); title:SetText("Master Builder")
local subtitle = MB:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); subtitle:SetPoint("TOP", title, "BOTTOM", 0, -1)
local closeBtn = CreateFrame("Button", nil, MB, "UIPanelCloseButton"); closeBtn:SetPoint("TOPRIGHT", -2, -2)

-- state
MB.tab = "obj"          -- "obj" or "npc"
MB.cat = nil            -- selected category (nil = all)
MB.search = ""
MB.sel = nil            -- selected data row
MB.own = {}             -- scroll item -> count
MB.here = true          -- everything goes down about 10 yards in front of you

local PANEL_BACKDROP = { bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } }
local TOP = -44                       -- where the three columns start
local COL_H = 402

-- ---------- tabs ----------
local function tabBtn(text, x, key)
    local b = CreateFrame("Button", nil, MB, "UIPanelButtonTemplate")
    b:SetWidth(96); b:SetHeight(21); b:SetPoint("TOPLEFT", x, -40); b:SetText(text)
    b:SetScript("OnClick", function() MB.tab = key; MB.cat = nil; MB.sel = nil; MB.search = ""; MB.searchBox:SetText(""); MB:Refresh() end)
    return b
end
local tabObj = tabBtn("Build", 20, "obj")
local tabNpc = tabBtn("Recruit", 120, "npc")
tabObj:Hide(); tabNpc:Hide()

-- ---------- categories (left) ----------
local catFrame = CreateFrame("Frame", nil, MB)
catFrame:SetPoint("TOPLEFT", 16, TOP); catFrame:SetWidth(134); catFrame:SetHeight(COL_H)
catFrame:SetBackdrop(PANEL_BACKDROP); catFrame:SetBackdropColor(0, 0, 0, 0.5)
local CAT_ROWS, CAT_H = 19, 20
local catScroll = CreateFrame("ScrollFrame", "ZeroCraftMBCatScroll", catFrame, "FauxScrollFrameTemplate")
catScroll:SetPoint("TOPLEFT", 4, -6); catScroll:SetPoint("BOTTOMRIGHT", -24, 6)
local catRows = {}
for i = 1, CAT_ROWS do
    local r = CreateFrame("Button", nil, catFrame)
    r:SetHeight(CAT_H); r:SetPoint("TOPLEFT", 6, -8 - (i - 1) * CAT_H); r:SetPoint("RIGHT", catFrame, "RIGHT", -26, 0)
    r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    r.text = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); r.text:SetPoint("LEFT", 3, 0); r.text:SetPoint("RIGHT", -2, 0); r.text:SetJustifyH("LEFT")
    r:SetScript("OnClick", function(self) MB.cat = self.cat; FauxScrollFrame_SetOffset(ZeroCraftMBListScroll, 0); MB:Refresh() end)
    catRows[i] = r
end
catScroll:SetScript("OnVerticalScroll", function(self, off) FauxScrollFrame_OnVerticalScroll(self, off, CAT_H, function() MB:RefreshCats() end) end)

-- ---------- list (middle) ----------
local listFrame = CreateFrame("Frame", nil, MB)
listFrame:SetPoint("TOPLEFT", 154, TOP); listFrame:SetWidth(226); listFrame:SetHeight(COL_H)
listFrame:SetBackdrop(PANEL_BACKDROP); listFrame:SetBackdropColor(0, 0, 0, 0.5)
local searchBox = CreateFrame("EditBox", "ZeroCraftMBSearch", listFrame, "InputBoxTemplate")
searchBox:SetPoint("TOPLEFT", 12, -7); searchBox:SetWidth(200); searchBox:SetHeight(18); searchBox:SetAutoFocus(false); searchBox:SetFontObject(GameFontHighlightSmall)
searchBox:SetScript("OnTextChanged", function(self) MB.search = (self:GetText() or ""):lower(); FauxScrollFrame_SetOffset(ZeroCraftMBListScroll, 0); MB:RefreshList() end)
searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
MB.searchBox = searchBox
local searchHint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall"); searchHint:SetPoint("LEFT", 4, 0); searchHint:SetText("Search everything...")
searchBox:HookScript("OnTextChanged", function(self) if self:GetText() ~= "" then searchHint:Hide() else searchHint:Show() end end)
local LIST_ROWS, LIST_H = 18, 20
local listScroll = CreateFrame("ScrollFrame", "ZeroCraftMBListScroll", listFrame, "FauxScrollFrameTemplate")
listScroll:SetPoint("TOPLEFT", 4, -30); listScroll:SetPoint("BOTTOMRIGHT", -24, 6)
local listRows = {}
for i = 1, LIST_ROWS do
    local r = CreateFrame("Button", nil, listFrame)
    r:SetHeight(LIST_H); r:SetPoint("TOPLEFT", 8, -32 - (i - 1) * LIST_H); r:SetPoint("RIGHT", listFrame, "RIGHT", -26, 0)
    r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    r.sel = r:CreateTexture(nil, "BACKGROUND"); r.sel:SetAllPoints(); r.sel:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight"); r.sel:SetVertexColor(1, 0.8, 0.2, 0.35); r.sel:Hide()
    r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); r.text:SetPoint("LEFT", 3, 0); r.text:SetPoint("RIGHT", -46, 0); r.text:SetJustifyH("LEFT")
    r.right = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); r.right:SetPoint("RIGHT", -3, 0); r.right:SetJustifyH("RIGHT")
    r:SetScript("OnClick", function(self) MB.sel = self.row; MB:RefreshList(); MB:RefreshPreview() end)
    r:SetScript("OnDoubleClick", function(self) MB.sel = self.row; MB:RefreshPreview(); MB:Build() end)
    listRows[i] = r
end
listScroll:SetScript("OnVerticalScroll", function(self, off) FauxScrollFrame_OnVerticalScroll(self, off, LIST_H, function() MB:RefreshList() end) end)

-- ---------- details (below the two columns) ----------
local nameText = MB:CreateFontString(nil, "OVERLAY", "GameFontNormal")
nameText:SetPoint("TOPLEFT", catFrame, "BOTTOMLEFT", 0, -6); nameText:SetPoint("RIGHT", listFrame, "BOTTOMRIGHT", 0, 0); nameText:SetJustifyH("LEFT")
local infoText = MB:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
infoText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -4); infoText:SetPoint("RIGHT", listFrame, "BOTTOMRIGHT", 0, 0); infoText:SetJustifyH("LEFT"); infoText:SetHeight(40); infoText:SetJustifyV("TOP")
local status = MB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); status:SetPoint("BOTTOM", 0, 12); status:SetPoint("LEFT", 16, 0); status:SetPoint("RIGHT", -16, 0); status:SetJustifyH("CENTER")
local function say(text) status:SetText(text) end
-- the thing you just built stays 'in hand': resize it right here
local bigBtn = CreateFrame("Button", nil, MB, "UIPanelButtonTemplate")
bigBtn:SetWidth(180); bigBtn:SetHeight(22); bigBtn:SetPoint("TOPLEFT", infoText, "BOTTOMLEFT", 0, -8); bigBtn:SetText("Make bigger")
bigBtn:SetScript("OnClick", function() if not InCombatLockdown() then mbSend("bigger") end end)
local smallBtn = CreateFrame("Button", nil, MB, "UIPanelButtonTemplate")
smallBtn:SetWidth(180); smallBtn:SetHeight(22); smallBtn:SetPoint("TOPLEFT", bigBtn, "TOPRIGHT", 4, 0); smallBtn:SetText("Make smaller")
smallBtn:SetScript("OnClick", function() if not InCombatLockdown() then mbSend("smaller") end end)
local undoBtn = CreateFrame("Button", nil, MB, "UIPanelButtonTemplate")
undoBtn:SetWidth(364); undoBtn:SetHeight(22); undoBtn:SetText("Undo last build")
undoBtn:SetScript("OnClick", function() if not InCombatLockdown() then mbSend("undo"); say("|cffffd100Undoing...|r") end end)
undoBtn:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:SetText("Takes back the last thing you built or recruited (NPCs return to a scroll). Press again to keep going back."); GameTooltip:Show() end)
undoBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
local buildBtn = CreateFrame("Button", nil, MB, "UIPanelButtonTemplate")
buildBtn:SetWidth(364); buildBtn:SetHeight(26); buildBtn:SetPoint("TOPLEFT", bigBtn, "BOTTOMLEFT", 0, -6); buildBtn:SetText("Build it")
buildBtn:SetScript("OnClick", function() MB:Build() end)
undoBtn:SetPoint("TOPLEFT", buildBtn, "BOTTOMLEFT", 0, -6)

-- ---------- data helpers ----------
local function rows() return MB.tab == "obj" and ZC_MB_OBJECTS or ZC_MB_NPCS end
local function catsOf()
    local list, seen = {}, {}
    for _, r in ipairs(rows()) do
        local c = r[1]
        if not seen[c] then seen[c] = { name = c, n = 0 }; tinsert(list, seen[c]) end
        seen[c].n = seen[c].n + 1
    end
    return list
end
local function ownedOf(r)   -- how many scrolls place this NPC row: specific ones, then generic ones of the kind
    if MB.tab ~= "npc" then return nil end
    if r[9] and r[9] > 0 then return nil end   -- Builder's Kit things are free
    if MB.orders then return nil end           -- the Recruiter's Orders cover everyone
    return MB.own[r[3]] or 0, MB.own[r[4]] or 0
end
local function filtered()
    local out, q = {}, MB.search
    for _, r in ipairs(rows()) do
        if (q ~= "" and r[2]:lower():find(q, 1, true)) or (q == "" and (not MB.cat or r[1] == MB.cat)) then tinsert(out, r) end
    end
    return out
end

-- ---------- refreshers ----------
function MB:RefreshCats()
    local cats = catsOf()
    local total = #rows()
    table.insert(cats, 1, { name = nil, label = "Everything (" .. total .. ")", n = total })
    FauxScrollFrame_Update(catScroll, #cats, CAT_ROWS, CAT_H)
    local off = FauxScrollFrame_GetOffset(catScroll)
    for i = 1, CAT_ROWS do
        local c = cats[i + off]
        local r = catRows[i]
        if c then
            r.cat = c.name
            r.text:SetText((c.label or (c.name .. " (" .. c.n .. ")")))
            if c.name == MB.cat then r.text:SetFontObject(GameFontHighlightSmall) else r.text:SetFontObject(GameFontNormalSmall) end
            r:Show()
        else r:Hide() end
    end
end
function MB:RefreshList()
    local list = filtered()
    FauxScrollFrame_Update(listScroll, #list, LIST_ROWS, LIST_H)
    local off = FauxScrollFrame_GetOffset(listScroll)
    for i = 1, LIST_ROWS do
        local d = list[i + off]
        local r = listRows[i]
        if d then
            r.row = d
            r.text:SetText(d[2])
            if MB.tab == "npc" then
                local own, gen = ownedOf(d)
                if own == nil then r.right:SetText("|cff80ff80free|r")
                elseif own > 0 then r.right:SetText("|cff80ff80x" .. own .. "|r")
                elseif gen > 0 then r.right:SetText("|cffffd100any x" .. gen .. "|r")
                else r.right:SetText("|cff808080none|r") end
            else
                r.right:SetText(d[5] and d[5] > 0 and string.format("%.0f yd", d[5]) or "")
            end
            if d == MB.sel then r.sel:Show() else r.sel:Hide() end
            r:Show()
        else r:Hide() end
    end
    subtitle:SetText(#list .. (MB.tab == "obj" and " objects" or " NPCs") .. (MB.search ~= "" and (" matching \"" .. MB.search .. "\"") or (MB.cat and (" in " .. MB.cat) or "")))
end
function MB:RefreshPreview()
    local d = MB.sel
    if not d then nameText:SetText(""); infoText:SetText(""); buildBtn:Disable(); buildBtn:SetText(MB.tab == "obj" and "Build it" or "Recruit"); return end
    nameText:SetText(d[2])
    if MB.tab == "obj" then
        infoText:SetText((d[5] and d[5] > 0 and string.format("About %.1f yards across.  ", d[5]) or "") .. (d[6] == "obj" and "Free to build, as many as you like." or "A useful thing from the Builder's Kit."))
        buildBtn:SetText("Build it"); buildBtn:Enable()
    else
        local own, gen = ownedOf(d)
        local line = "Level " .. (d[7] or "?") .. ((d[8] and d[8] ~= "") and (" - " .. d[8]) or "")
        if own == nil then infoText:SetText(line .. (MB.orders and (d[9] or 0) == 0 and "\nYour Recruiter's Orders cover this - no scroll needed." or "\nFree to place.")); buildBtn:SetText("Recruit"); buildBtn:Enable()
        elseif own > 0 then infoText:SetText(line .. "\nYou carry " .. own .. " scroll" .. (own > 1 and "s" or "") .. " of exactly this one."); buildBtn:SetText("Recruit"); buildBtn:Enable()
        elseif gen > 0 then infoText:SetText(line .. "\nSpends one of your " .. gen .. " " .. (ZC_MB_GENERIC[d[4]] or "generic scroll") .. (gen > 1 and "s" or "") .. " - you choose instead of rolling."); buildBtn:SetText("Recruit"); buildBtn:Enable()
        else infoText:SetText(line .. "\nNo scroll for this one yet - bosses drop them."); buildBtn:SetText("Needs a scroll"); buildBtn:Disable() end
    end
end
-- "npc": the Recruiter's Orders - Recruit only, no tabs. "obj" or "": the Builder's Tome - both tabs, Build first.
function MB:SetMode(mode)
    MB.lock = (mode == "npc") and "npc" or "obj"
    MB.tab = MB.lock; MB.cat = nil; MB.sel = nil; MB.search = ""; MB.searchBox:SetText("")
    tabObj:Hide(); tabNpc:Hide()
    title:SetText(MB.lock == "npc" and "Master Recruiter" or "Master Builder")
end
function MB:Refresh()
    if MB.tab == "obj" then tabObj:SetNormalFontObject(GameFontHighlight); tabNpc:SetNormalFontObject(GameFontNormal)
    else tabNpc:SetNormalFontObject(GameFontHighlight); tabObj:SetNormalFontObject(GameFontNormal) end
    FauxScrollFrame_SetOffset(catScroll, 0)
    MB:RefreshCats(); MB:RefreshList(); MB:RefreshPreview()
end
function MB:Build()
    local d = MB.sel
    if not d or InCombatLockdown() then return end
    local here = MB.here and "here" or nil
    if MB.tab == "obj" then
        if d[6] == "obj" then mbSend("obj", d[3], here) else mbSend("thing", d[6], here) end
    else
        if d[9] and d[9] > 0 then mbSend("thing", d[9], here) else mbSend("npc", d[3], d[4], d[5], here) end
    end
    say("|cffffd100Building " .. d[2] .. "...|r")
end

-- ---------- server messages ----------
local sys = CreateFrame("Frame")
sys:RegisterEvent("CHAT_MSG_SYSTEM")
sys:SetScript("OnEvent", function(self, event, msg)
    if not msg then return end
    local spot, mode = msg:match("^ZCMB:open|(%d)|?(%a*)")
    if spot then
        MB:SetMode(mode)
        MB.here = true
        say("Everything goes down about 10 yards in front of you, facing your way.")
        MB:Show(); MB:Refresh(); return
    end
    local more, own = msg:match("^ZCMB:own(%+?)|(.*)$")
    if own then
        if more ~= "+" then MB.own = {}; MB.orders = (own:find("orders=1", 1, true) ~= nil) end
        for item, n in own:gmatch("(%d+)=(%d+)") do MB.own[tonumber(item)] = tonumber(n) end
        if MB:IsShown() then MB:RefreshList(); MB:RefreshPreview() end
        return
    end
    local sName, sScale = msg:match("^ZCMB:scaled|(.*)|([%d%.]+)$")
    if sScale then
        if sScale == "0" then say("|cffff8a7aNothing in hand to resize - build something first.|r") else say("|cff80ff80" .. sName .. " is now " .. sScale .. "x|r") end
        return
    end
    local undone = msg:match("^ZCMB:undone|(.*)$")
    if undone then say("|cffff9f40Undone: " .. undone .. "|r"); return end
    local built = msg:match("^ZCMB:built|(.*)$")
    if built then say("|cff80ff80Built: " .. built .. "|r") end
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
    if msg and msg:sub(1, 5) == "ZCMB:" then return true end
end)
SLASH_ZCMASTERBUILDER1 = "/mb"
SlashCmdList["ZCMASTERBUILDER"] = function() if MB:IsShown() then MB:Hide() else MB:SetMode("obj"); MB.here = true; say("Everything goes down about 10 yards in front of you, facing your way."); mbSend("own"); MB:Show(); MB:Refresh() end end
