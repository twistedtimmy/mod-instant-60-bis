---------------------------------------------------------------- New-item glow
-- Anything that lands in your bags for the first time gets a pulsing golden border until you
-- hover it once. What you have already looked at is remembered per character (ZeroCraftSaved).
ZeroCraftSaved = ZeroCraftSaved or {}
local seen            -- itemID -> true, for this character
local glows = {}      -- button -> glow texture
local pulse = 0

local function charKey() return (GetRealmName() or "") .. ":" .. (UnitName("player") or "") end
local function ensureSeen()
    if seen then return true end
    if not UnitName("player") then return false end
    ZeroCraftSaved.seen = ZeroCraftSaved.seen or {}
    local k = charKey()
    if not ZeroCraftSaved.seen[k] then
        -- first run for this character: everything already in the bags counts as seen
        local t = {}
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, (GetContainerNumSlots(bag) or 0) do
                local id = GetContainerItemID(bag, slot)
                if id then t[id] = true end
            end
        end
        ZeroCraftSaved.seen[k] = t
    end
    seen = ZeroCraftSaved.seen[k]
    return true
end

local function glowFor(button)
    local g = glows[button]
    if not g then
        g = button:CreateTexture(nil, "OVERLAY")
        g:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        g:SetBlendMode("ADD")
        g:SetVertexColor(1, 0.82, 0.25)
        g:SetPoint("CENTER", button, "CENTER", 0, 0)
        g:SetWidth(button:GetWidth() * 1.7); g:SetHeight(button:GetHeight() * 1.7)
        g:Hide()
        glows[button] = g
    end
    return g
end

local function refreshBag(frame)
    if not ensureSeen() then return end
    local bag = frame:GetID()
    local name = frame:GetName()
    for i = 1, frame.size do
        local button = _G[name .. "Item" .. i]
        if button then
            local id = GetContainerItemID(bag, button:GetID())
            local g = glowFor(button)
            if id and not seen[id] then g:Show() else g:Hide() end
        end
    end
end
hooksecurefunc("ContainerFrame_Update", refreshBag)

-- looked at it: remembered, glow gone
hooksecurefunc("ContainerFrameItemButton_OnEnter", function(button)
    if not ensureSeen() then return end
    local bag = button:GetParent():GetID()
    local id = GetContainerItemID(bag, button:GetID())
    if id and not seen[id] then
        seen[id] = true
        local g = glows[button]
        if g then g:Hide() end
    end
end)

-- one gentle pulse for every glow
local pulser = CreateFrame("Frame")
pulser:SetScript("OnUpdate", function(self, e)
    pulse = pulse + e * 2.2
    local a = 0.45 + 0.4 * math.sin(pulse)
    for _, g in pairs(glows) do if g:IsShown() then g:SetAlpha(a) end end
end)

-- bags that are already open when something arrives
local ev = CreateFrame("Frame")
ev:RegisterEvent("BAG_UPDATE")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function(self, event)
    if not ensureSeen() then return end
    for i = 1, NUM_CONTAINER_FRAMES do
        local f = _G["ContainerFrame" .. i]
        if f and f:IsShown() then refreshBag(f) end
    end
end)
