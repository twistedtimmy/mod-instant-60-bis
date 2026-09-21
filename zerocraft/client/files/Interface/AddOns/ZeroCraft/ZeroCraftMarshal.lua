---------------------------------------------------------------- Master Marshal
-- Three orders, two ways to pick who. The banner on the ground carries the armed order.
-- Server -> addon: "ZCCM:open|who|armed|count|routePoints|pickedName", "ZCCM:ok|text".  Addon -> server: "ZCCM" whispers.
local ITEM = 23701
local function send(...) SendAddonMessage("ZCCM", table.concat({ ... }, "\t"), "WHISPER", UnitName("player")) end

local MS = CreateFrame("Frame", "ZeroCraftMarshal", UIParent)
MS:SetWidth(300); MS:SetHeight(214)
MS:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
MS:SetFrameStrata("DIALOG")
MS:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } })
MS:SetMovable(true); MS:EnableMouse(true); MS:RegisterForDrag("LeftButton"); MS:SetClampedToScreen(true)
MS:SetScript("OnDragStart", MS.StartMoving); MS:SetScript("OnDragStop", MS.StopMovingOrSizing)
MS:Hide()
tinsert(UISpecialFrames, "ZeroCraftMarshal")
MS.who = "near"; MS.armed = "move"; MS.count = 0; MS.picked = ""

local title = MS:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); title:SetPoint("TOP", 0, -12); title:SetText("Master Marshal")
local subtitle = MS:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); subtitle:SetPoint("TOP", title, "BOTTOM", 0, -1)
local closeBtn = CreateFrame("Button", nil, MS, "UIPanelCloseButton"); closeBtn:SetPoint("TOPRIGHT", -2, -2)
local status
local function tip(b, text) b:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:SetText(text, 1, 1, 1, 1, true); GameTooltip:Show() end); b:SetScript("OnLeave", function() GameTooltip:Hide() end) end

-- WHO
local whoBtns = {}
for i, w in ipairs({ { "target", "Target", "The NPC you have targeted - it stays selected after you click away." }, { "near", "Within 150 yards", "Every marching NPC of yours within 150 yards." } }) do
    local b = CreateFrame("Button", nil, MS, "UIPanelButtonTemplate")
    b:SetWidth(132); b:SetHeight(24); b:SetPoint("TOPLEFT", 16 + (i - 1) * 136, -46); b:SetText(w[2])
    b.key = w[1]; tip(b, w[3])
    b:SetScript("OnClick", function(self) send("who", self.key) end)
    whoBtns[i] = b
end

-- ORDERS. The banner on the ground is always "go there and fight what you meet"; these two need no spot.
local followBtn = CreateFrame("Button", nil, MS, "UIPanelButtonTemplate")
followBtn:SetWidth(268); followBtn:SetHeight(28); followBtn:SetPoint("TOPLEFT", 16, -80); followBtn:SetText("Follow Me")
followBtn:SetScript("OnClick", function() send("do", "follow") end)
tip(followBtn, "They fall in behind you at your speed and follow wherever you go.")
local roamBtn = CreateFrame("Button", nil, MS, "UIPanelButtonTemplate")
roamBtn:SetWidth(132); roamBtn:SetHeight(28); roamBtn:SetPoint("TOPLEFT", 16, -112); roamBtn:SetText("Roam")
roamBtn:SetScript("OnClick", function() send("do", "roam") end)
tip(roamBtn, "Long wandering walks around their posts, inside your claim.")
local attackBtn = CreateFrame("Button", nil, MS, "UIPanelButtonTemplate")
attackBtn:SetWidth(132); attackBtn:SetHeight(28); attackBtn:SetPoint("TOPLEFT", 152, -112); attackBtn:SetText("Attack")
attackBtn:SetScript("OnClick", function() send("do", "attack") end)
tip(attackBtn, "Everyone attacks whatever you have targeted.")
local stopBtn = CreateFrame("Button", nil, MS, "UIPanelButtonTemplate")
stopBtn:SetWidth(268); stopBtn:SetHeight(28); stopBtn:SetPoint("TOPLEFT", 16, -144); stopBtn:SetText("Stop")
stopBtn:SetScript("OnClick", function() send("do", "stop") end)
tip(stopBtn, "Everything cancelled - follow, patrol, fight, movement. They stop dead, and that becomes their post.")

status = MS:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); status:SetPoint("BOTTOM", 0, 12); status:SetPoint("LEFT", 14, 0); status:SetPoint("RIGHT", -14, 0); status:SetJustifyH("CENTER"); status:SetHeight(24)

function MS:Refresh()
    for _, b in ipairs(whoBtns) do
        if b.key == MS.who then b:LockHighlight() else b:UnlockHighlight() end
    end
    local whoText = MS.who == "target" and ((MS.picked ~= "") and ("selected: " .. MS.picked) or "your target") or "within 150 yards"
    subtitle:SetText(MS.count .. " NPC" .. (MS.count == 1 and "" or "s") .. ": " .. whoText)
end

local sys = CreateFrame("Frame")
sys:RegisterEvent("CHAT_MSG_SYSTEM")
sys:SetScript("OnEvent", function(self, event, msg)
    if not msg then return end
    local who, armed, count, pts, picked = msg:match("^ZCCM:open|(%a+)|(%a+)|(%d+)|(%d*)|?(.*)$")
    if who then
        MS.who, MS.armed, MS.count, MS.picked = who, armed, tonumber(count) or 0, picked or ""
        if MS.who ~= "target" and MS.who ~= "near" then send("who", "near") end
        if not MS:IsShown() then MS:Show(); status:SetText("Banner on the ground = go there and fight what you meet.") end
        MS:Refresh(); return
    end
    local ok = msg:match("^ZCCM:ok|(.*)$")
    if ok then status:SetText("|cff80ff80" .. ok .. "|r") end
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg) if msg and msg:sub(1, 5) == "ZCCM:" then return true end end)
-- sticky selection: whenever you target one of your NPCs, tell the server
local pick = CreateFrame("Frame")
pick:RegisterEvent("PLAYER_TARGET_CHANGED")
pick:SetScript("OnEvent", function()
    if UnitExists("target") and not UnitIsPlayer("target") and UnitIsFriend("player", "target") then
        local g = UnitGUID("target")
        if g then send("pick", (g:gsub("^0x", ""))) end
    end
end)
local tick = CreateFrame("Frame"); tick.t = 0
tick:SetScript("OnUpdate", function(self, e) if MS:IsShown() then self.t = self.t + e; if self.t > 2 then self.t = 0; send("state") end end end)
SLASH_ZCMARSHAL1 = "/marshal"
SlashCmdList["ZCMARSHAL"] = function() if MS:IsShown() then MS:Hide() else send("state") end end
-- /ctm: Click-to-Move on or off (Interface Options > Mouse > Click-to-Move)
SLASH_ZCCTM1 = "/ctm"
SlashCmdList["ZCCTM"] = function()
    local on = GetCVar("autointeract") == "1"
    SetCVar("autointeract", on and "0" or "1")
    DEFAULT_CHAT_FRAME:AddMessage(on and "ZeroCraft: Click-to-Move OFF." or "ZeroCraft: Click-to-Move ON - left-click the ground to walk there.")
end
