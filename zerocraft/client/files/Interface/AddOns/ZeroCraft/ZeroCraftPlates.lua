---------------------------------------------------------------- Battlefield nameplates
-- Health bars above heads, but no names: friendly nameplates on, the name text on every nameplate hidden.
local sys = CreateFrame("Frame")
sys:RegisterEvent("PLAYER_ENTERING_WORLD")
sys:SetScript("OnEvent", function()
    SetCVar("nameplateShowFriends", 1)
    SetCVar("nameplateShowEnemies", 1)
end)

local BORDER = "Interface\Tooltips\Nameplate-Border"
local seen = {}
local function isPlate(f)
    if f:GetName() then return false end
    local r = select(2, f:GetRegions())
    return r and r:GetObjectType() == "Texture" and r:GetTexture() == BORDER
end
local function quiet(f)
    -- regions: threat glow, border, cast border, cast shield, spell icon, highlight, NAME, level, boss, raid icon, elite
    local name = select(7, f:GetRegions())
    if name and name:GetObjectType() == "FontString" then name:SetAlpha(0) end
end
local scan = CreateFrame("Frame"); scan.t = 0; scan.n = 0
scan:SetScript("OnUpdate", function(self, e)
    self.t = self.t + e
    if self.t < 0.25 then return end
    self.t = 0
    local n = WorldFrame:GetNumChildren()
    if n == self.n then return end
    self.n = n
    for i = 1, n do
        local f = select(i, WorldFrame:GetChildren())
        if f and not seen[f] and isPlate(f) then
            seen[f] = true
            quiet(f)
            f:HookScript("OnShow", quiet)
        end
    end
end)
