---------------------------------------------------------------- Master GM Codex
-- Every Game Master command as a button, in the same two-column window as the Master Builder.
-- The server opens it ("ZCGM:open|level") when a GM uses the Codex. Commands are sent as chat lines.
-- A row's cmd may contain {arg}: the box below fills it. {target} means it acts on your target.
local ZC_GM = {
    { "Me", {
        -- toggle rows: { label, nil, description, nil, nil, { { buttonText, command }, { buttonText, command } } }
        { "God mode",       nil, "Nothing can hurt you.",                       nil, nil, { { "On", ".cheat god on" },   { "Off", ".cheat god off" } } },
        { "Fly",            nil, "Space to rise, X to sink.",                   nil, nil, { { "On", ".gm fly on" },      { "Off", ".gm fly off" } } },
        { "GM mode",        nil, "Untouchable, <GM> tag, invisible to players.", nil, nil, { { "On", ".gm on" },          { "Off", ".gm off" } } },
        { "Infinite power", nil, "Mana, rage and energy never run out.",        nil, nil, { { "On", ".cheat power on" }, { "Off", ".cheat power off" } } },
        { "Speed",          nil, "Steps: 1, 2, 3, 5, 8, 12, 20, 30, 50.",       nil, nil, { { "Faster", "speed+" },      { "Slower", "speed-" } } },
        { "Size",           nil, "Steps: 0.25 to 5x.",                          nil, nil, { { "Bigger", "size+" },       { "Smaller", "size-" } } },
    } },
    { "Teleport: players", {
        { "Teleport to place...",   ".tele {arg}",          "Any .tele name (see the Teleport groups above).", "" },
        { "Find a place",           ".lookup tele {arg}",   "Lists teleport names containing the text.", "" },
        { "Go to player",           ".appear {arg}",        "Teleports you to them.", "" },
        { "Bring player to me",     ".summon {arg}",        "Teleports them to you.", "" },
        { "Send player to place",   ".tele name {arg}",     "player place", "" },
        { "Back where I was",       ".recall" },
        { "Summon my group",        ".group summon" },
        { "Go to coordinates",      ".go xyz {arg}",        "x y z [map]", "" },
    } },
    { "Character", {
        { "Level up",               ".levelup {arg}",       "Levels to add (negative to remove).", "1", { "1", "5", "10" } },
        { "Give gold",              ".modify money {arg}",  "In copper: 10000 = 1 gold.", "1000000", { "10000", "1000000", "100000000" } },
        { "Add item by id",         ".additem {arg}",       "Item id, optionally a count: 6948 5", "" },
        { "Add whole item set",     ".additemset {arg}",    "Item set id.", "" },
        { "Learn spell",            ".learn {arg}",         "Spell id.", "" },
        { "Learn all my class spells", ".learn all my spells" },
        { "Learn all my talents",   ".learn all my talents" },
        { "Unlearn spell",          ".unlearn {arg}",       "Spell id.", "" },
        { "Max all skills",         ".maxskill" },
        { "Reset talents",          ".reset talents" },
        { "Reset spells",           ".reset spells" },
        { "Full health",            ".modify hp {arg}",     "Sets max health.", "50000" },
        { "Full mana",              ".modify mana {arg}",   "Sets max mana.", "50000" },
        { "Morph into display",     ".morph {arg}",         "A creature display id.", "" },
        { "Demorph",                ".demorph" },
        { "Give aura (spell)",      ".aura {arg}",          "Spell id.", "" },
        { "Remove aura (spell)",    ".unaura {arg}",        "Spell id.", "" },
        { "Cast spell",             ".cast {arg}",          "Spell id, at your target.", "" },
        { "Player info",            ".pinfo {arg}",         "Name (blank = your target).", "" },
        { "Rename on next login",   ".character rename {arg}", "Player name.", "" },
    } },
    { "Target (NPC)", {
        { "NPC info",               ".npc info",            "Entry, display, faction, flags of your target." },
        { "Delete NPC",             ".npc delete",          "Removes the targeted NPC for good." },
        { "Set NPC level",          ".npc set level {arg}", "", "60" },
        { "NPC follows me",         ".npc follow" },
        { "NPC stops following",    ".npc unfollow" },
        { "NPC says...",            ".npc say {arg}",       "", "" },
        { "NPC yells...",           ".npc yell {arg}",      "", "" },
        { "Set NPC faction",        ".npc set faction {arg}", "Faction template id (35 = friendly to all).", "35" },
        { "Spawn NPC by entry",     ".npc add {arg}",       "Creature entry - a permanent spawn where you stand.", "" },
        { "Spawn temp NPC",         ".npc add temp {arg}",  "Creature entry - gone on restart.", "" },
        { "Kill target",            ".damage 99999999" },
        { "Revive target",          ".revive" },
        { "Freeze target",          ".freeze" },
        { "Unfreeze target",        ".unfreeze" },
        { "Kick player",            ".kick {arg}",          "Player name.", "" },
        { "Find creature",          ".lookup creature {arg}", "Name text -> entries.", "" },
        { "List spawns of entry",   ".list creature {arg}", "Creature entry.", "" },
    } },
    { "Objects", {
        { "Spawn object by entry",  ".gobject add {arg}",   "Gameobject entry, where you stand.", "" },
        { "Spawn temp object",      ".gobject add temp {arg}", "Gone on restart.", "" },
        { "Objects near me",        ".gobject near {arg}",  "Radius in yards.", "10" },
        { "Delete object by guid",  ".gobject delete {arg}", "GUID from 'Objects near me'.", "" },
        { "Turn object",            ".gobject turn {arg}",  "guid [degrees]", "" },
        { "Move object to me",      ".gobject move {arg}",  "GUID.", "" },
        { "Find object",            ".lookup object {arg}", "Name text -> entries.", "" },
        { "Find item",              ".lookup item {arg}",   "Name text -> item ids.", "" },
        { "Find spell",             ".lookup spell {arg}",  "Name text -> spell ids.", "" },
    } },
    { "World", {
        { "Server info",            ".server info" },
        { "Announce to everyone",   ".announce {arg}",      "Yellow system line for all.", "" },
        { "Screen notify everyone", ".notify {arg}",        "Big text on every screen.", "" },
        { "Weather: clear",         ".wchange 0 0" },
        { "Weather: rain",          ".wchange 1 0.8" },
        { "Weather: snow",          ".wchange 2 0.8" },
        { "Weather: storm",         ".wchange 3 0.8" },
        { "Start event",            ".event start {arg}",   "Game event id (.event list).", "" },
        { "Stop event",             ".event stop {arg}",    "", "" },
        { "List events",            ".event list" },
        { "Save everyone",          ".saveall" },
        { "GMs online",             ".gm ingame" },
        { "Open tickets",           ".ticket list" },
        { "Restart server in 60s",  ".server restart 60",   "Careful: kicks everyone." },
        { "Cancel restart",         ".server restart cancel" },
        { "All commands",           ".commands" },
        { "Help on a command",      ".help {arg}",          "e.g. npc add", "" },
    } },
}

-- Teleport: the player commands, then every .tele location on the server under group headers (rows with no command)
do
    local list = { { "Players" } }
    for _, cat in ipairs(ZC_GM) do if cat[1] == "Teleport: players" then for _, d in ipairs(cat[2]) do tinsert(list, d) end end end
    for _, g in ipairs(ZC_TELE or {}) do
        tinsert(list, { g[1] })
        for _, t in ipairs(g[2]) do tinsert(list, { t[1], ".tele " .. t[2], "Teleports you to " .. t[1] .. ".", t[3] or 7 }) end
    end
    for i, cat in ipairs(ZC_GM) do if cat[1] == "Teleport: players" then ZC_GM[i] = { "Teleport", list } end end
end

ZeroCraftSaved = ZeroCraftSaved or {}
local SPEEDS = { 1, 2, 3, 5, 8, 12, 20, 30, 50 }
local SIZES = { 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 5 }
local function stepped(kind, dir)
    local list = kind == "speed" and SPEEDS or SIZES
    local key = kind == "speed" and "gmSpeedIdx" or "gmSizeIdx"
    local idx = ZeroCraftSaved[key] or (kind == "speed" and 1 or 4)
    idx = math.max(1, math.min(#list, idx + dir))
    ZeroCraftSaved[key] = idx
    return (kind == "speed" and ".modify speed " or ".modify scale ") .. list[idx], list[idx]
end

local GM = CreateFrame("Frame", "ZeroCraftGMCodex", UIParent)
local status   -- the line at the bottom of the window (created further down)
GM:SetWidth(396); GM:SetHeight(600)
GM:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
GM:SetFrameStrata("DIALOG")
GM:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } })
GM:SetMovable(true); GM:EnableMouse(true); GM:RegisterForDrag("LeftButton"); GM:SetClampedToScreen(true)
GM:SetScript("OnDragStart", GM.StartMoving); GM:SetScript("OnDragStop", GM.StopMovingOrSizing)
GM:Hide()
tinsert(UISpecialFrames, "ZeroCraftGMCodex")

local title = GM:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); title:SetPoint("TOP", 0, -12); title:SetText("Master GM Codex")
local subtitle = GM:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); subtitle:SetPoint("TOP", title, "BOTTOM", 0, -1)
local closeBtn = CreateFrame("Button", nil, GM, "UIPanelCloseButton"); closeBtn:SetPoint("TOPRIGHT", -2, -2)

GM.cat = 1; GM.sel = nil; GM.search = ""
local PANEL = { bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } }
local TOP, COL_H = -44, 380

-- categories
local catFrame = CreateFrame("Frame", nil, GM); catFrame:SetPoint("TOPLEFT", 16, TOP); catFrame:SetWidth(134); catFrame:SetHeight(COL_H)
catFrame:SetBackdrop(PANEL); catFrame:SetBackdropColor(0, 0, 0, 0.5)
local catRows = {}
for i = 1, #ZC_GM do
    local r = CreateFrame("Button", nil, catFrame)
    r:SetHeight(22); r:SetPoint("TOPLEFT", 6, -8 - (i - 1) * 22); r:SetPoint("RIGHT", catFrame, "RIGHT", -6, 0)
    r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    r.text = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); r.text:SetPoint("LEFT", 3, 0); r.text:SetPoint("RIGHT", -3, 0); r.text:SetJustifyH("LEFT"); r.text:SetHeight(20); r.text:SetNonSpaceWrap(false)
    local n = 0; for _, d in ipairs(ZC_GM[i][2]) do if d[2] or d[6] then n = n + 1 end end
    r.text:SetText(ZC_GM[i][1] .. " (" .. n .. ")")
    r:SetScript("OnClick", function() GM.cat = i; GM.sel = nil; GM.search = ""; GM.searchBox:SetText(""); FauxScrollFrame_SetOffset(ZeroCraftGMListScroll, 0); GM:Refresh() end)
    catRows[i] = r
end

-- commands
local listFrame = CreateFrame("Frame", nil, GM); listFrame:SetPoint("TOPLEFT", 154, TOP); listFrame:SetWidth(226); listFrame:SetHeight(COL_H)
listFrame:SetBackdrop(PANEL); listFrame:SetBackdropColor(0, 0, 0, 0.5)
local searchBox = CreateFrame("EditBox", "ZeroCraftGMSearch", listFrame, "InputBoxTemplate")
searchBox:SetPoint("TOPLEFT", 12, -7); searchBox:SetWidth(200); searchBox:SetHeight(18); searchBox:SetAutoFocus(false); searchBox:SetFontObject(GameFontHighlightSmall)
searchBox:SetScript("OnTextChanged", function(self) GM.search = (self:GetText() or ""):lower(); FauxScrollFrame_SetOffset(ZeroCraftGMListScroll, 0); GM:RefreshList() end)
searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
GM.searchBox = searchBox
local hint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall"); hint:SetPoint("LEFT", 4, 0); hint:SetText("Search all commands...")
searchBox:HookScript("OnTextChanged", function(self) if self:GetText() ~= "" then hint:Hide() else hint:Show() end end)
local ROWS, ROW_H = 17, 20
local listScroll = CreateFrame("ScrollFrame", "ZeroCraftGMListScroll", listFrame, "FauxScrollFrameTemplate")
listScroll:SetPoint("TOPLEFT", 4, -30); listScroll:SetPoint("BOTTOMRIGHT", -24, 6)
local rows = {}
for i = 1, ROWS do
    local r = CreateFrame("Button", nil, listFrame)
    r:SetHeight(ROW_H); r:SetPoint("TOPLEFT", 8, -32 - (i - 1) * ROW_H); r:SetPoint("RIGHT", listFrame, "RIGHT", -26, 0)
    r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    r.sel = r:CreateTexture(nil, "BACKGROUND"); r.sel:SetAllPoints(); r.sel:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight"); r.sel:SetVertexColor(1, 0.8, 0.2, 0.35); r.sel:Hide()
    r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); r.text:SetPoint("LEFT", 3, 0); r.text:SetPoint("RIGHT", -3, 0); r.text:SetJustifyH("LEFT"); r.text:SetHeight(18); r.text:SetNonSpaceWrap(false)
    r:SetScript("OnClick", function(self) if not self.row or not (self.row[2] or self.row[6]) then return end; GM.sel = self.row; GM:RefreshList(); GM:RefreshDetail() end)
    r.btn = {}
    for k = 1, 2 do
        local b = CreateFrame("Button", nil, r, "UIPanelButtonTemplate")
        b:SetWidth(58); b:SetHeight(18); b:SetPoint("RIGHT", r, "RIGHT", -2 - (2 - k) * 60, 0)
        b:SetNormalFontObject(GameFontNormalSmall); b:SetHighlightFontObject(GameFontHighlightSmall)
        b:SetScript("OnClick", function(self)
            local cmd = self.cmd
            if cmd == "speed+" or cmd == "speed-" then cmd = stepped("speed", cmd == "speed+" and 1 or -1)
            elseif cmd == "size+" or cmd == "size-" then cmd = stepped("size", cmd == "size+" and 1 or -1) end
            SendChatMessage(cmd, "SAY")
            GM.sel = self:GetParent().row; GM:RefreshList(); GM:RefreshDetail()
            status:SetText("|cff80ff80Sent: " .. cmd .. "|r")
        end)
        b:Hide(); r.btn[k] = b
    end
    r:SetScript("OnDoubleClick", function(self) if not self.row or not self.row[2] then return end; GM.sel = self.row; GM:RefreshDetail(); GM:Run() end)
    rows[i] = r
end
listScroll:SetScript("OnVerticalScroll", function(self, off) FauxScrollFrame_OnVerticalScroll(self, off, ROW_H, function() GM:RefreshList() end) end)
local function commandText()
    local d = GM.sel
    if not d or not d[2] then return "" end
    local cmd = d[2]
    if cmd:find("{arg}", 1, true) then
        local v = (argBox:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")   -- gsub returns (text, count): keep only the text
        v = v:gsub("%%", "%%%%")
        cmd = (cmd:gsub("{arg}", v))
    end
    return cmd
end
function GM:RefreshCommandLine() cmdLine:SetText(commandText()) end
local function filtered()
    local out = {}
    if GM.search ~= "" then
        for _, cat in ipairs(ZC_GM) do for _, d in ipairs(cat[2]) do if (d[2] or d[6]) and (d[1]:lower():find(GM.search, 1, true) or (d[2] and d[2]:lower():find(GM.search, 1, true))) then tinsert(out, d) end end end
    else
        for _, d in ipairs(ZC_GM[GM.cat][2]) do tinsert(out, d) end
    end
    return out
end
function GM:RefreshList()
    local list = filtered()
    FauxScrollFrame_Update(listScroll, #list, ROWS, ROW_H)
    local off = FauxScrollFrame_GetOffset(listScroll)
    for i = 1, ROWS do
        local d = list[i + off]; local r = rows[i]
        if d then
            r.row = d
            if d[6] then
                r.text:SetFontObject(GameFontHighlightSmall); r.text:SetText(d[1])
                for k = 1, 2 do r.btn[k]:SetText(d[6][k][1]); r.btn[k].cmd = d[6][k][2]; r.btn[k]:Show() end
            else
                for k = 1, 2 do r.btn[k]:Hide() end
                if d[2] then r.text:SetFontObject(GameFontHighlightSmall); r.text:SetText(d[1]) else r.text:SetFontObject(GameFontNormalSmall); r.text:SetText("|cffffd100- " .. d[1] .. " -|r") end
            end
            if d == GM.sel then r.sel:Show() else r.sel:Hide() end
            r:Show()
        else r:Hide(); for k = 1, 2 do r.btn[k]:Hide() end end
    end
    for i, r in ipairs(catRows) do r.text:SetFontObject(i == GM.cat and GM.search == "" and GameFontHighlightSmall or GameFontNormalSmall) end
    local n = 0; for _, d in ipairs(list) do if d[2] or d[6] then n = n + 1 end end
    subtitle:SetText(n .. " commands" .. (GM.search ~= "" and (" matching \"" .. GM.search .. "\"") or (" in " .. ZC_GM[GM.cat][1])))
end
function GM:RefreshDetail()
    local d = GM.sel
    for _, b in ipairs(presets) do b:Hide() end
    if not d then nameText:SetText(""); infoText:SetText("Pick a command."); argBox:Hide(); cmdLine:SetText(""); runBtn:Disable(); return end
    nameText:SetText(d[1]); infoText:SetText(d[3] or "")
    if d[6] then argBox:Hide(); cmdLine:SetText(d[6][1][2]:sub(1, 1) == "." and (d[6][1][2] .. "  /  " .. d[6][2][2]) or ""); runBtn:Disable(); return end
    local needsArg = d[2]:find("{arg}", 1, true) ~= nil
    if needsArg then
        argBox:Show(); argBox:SetText(d[4] or "")
        if d[5] then for i, v in ipairs(d[5]) do if presets[i] then presets[i].value = v; presets[i]:SetText(v); presets[i]:Show() end end end
    else
        argBox:Hide(); argBox:SetText("")
    end
    runBtn:Enable(); GM:RefreshCommandLine()
end
function GM:Refresh() GM:RefreshList(); GM:RefreshDetail() end
function GM:Run()
    local d = GM.sel
    if not d or not d[2] then return end
    local cmd = commandText()
    if d[2]:find("{arg}", 1, true) and (argBox:GetText() or "") == "" then status:SetText("|cffff8a7aThat one needs a value in the box.|r"); argBox:SetFocus(); return end
    SendChatMessage(cmd, "SAY")
    status:SetText("|cff80ff80Sent: " .. cmd .. "|r")
end

local sys = CreateFrame("Frame")
sys:RegisterEvent("CHAT_MSG_SYSTEM")
sys:SetScript("OnEvent", function(self, event, msg)
    if msg and msg:sub(1, 10) == "ZCGM:open|" then
        if GM:IsShown() then GM:Hide() else GM:Show(); GM:Refresh(); status:SetText("Double-click a command to run it, or press Run. Commands go out as chat lines, like typing them.") end
    end
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg) if msg and msg:sub(1, 5) == "ZCGM:" then return true end end)
SLASH_ZCGMCODEX1 = "/gmc"
SlashCmdList["ZCGMCODEX"] = function() if GM:IsShown() then GM:Hide() else GM:Show(); GM:Refresh() end end
