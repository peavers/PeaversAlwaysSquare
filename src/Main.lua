local addonName, PAS = ...
local frame = CreateFrame("Frame")
local SQUARE_ICON = 6
local checkFrequency = 1.0 -- Check every 1 second
local debugMode = false

-- Initialize addon when ADDON_LOADED event fires
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize configuration UI if available
        if PAS.ConfigUI and PAS.ConfigUI.Initialize then
            PAS.ConfigUI:Initialize()
        end

        -- Initialize support UI if available
        if PAS.SupportUI and PAS.SupportUI.Initialize then
            PAS.SupportUI:Initialize()
        end

        -- Unregister the ADDON_LOADED event as we don't need it anymore
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Icon names for reference
local iconNames = {
    [1] = "Star", [2] = "Circle", [3] = "Diamond", [4] = "Triangle",
    [5] = "Moon", [6] = "Square", [7] = "Cross", [8] = "Skull"
}

-- Register events
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("READY_CHECK")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Function to find and mark the tank
local function MarkTank()
    if not IsInGroup() then
        if debugMode then print("PeaversAlwaysSquare: Not in group") end
        return
    end

    if IsInRaid() then
        if debugMode then print("PeaversAlwaysSquare: In raid - disabled") end
        return
    end

    local numMembers = GetNumGroupMembers()
    for i = 1, numMembers do
        local unit = i < numMembers and "party" .. i or "player"
        if UnitGroupRolesAssigned(unit) == "TANK" then
            local name = UnitName(unit)
            local currentMark = GetRaidTargetIndex(unit)
            if currentMark ~= SQUARE_ICON then
                SetRaidTarget(unit, SQUARE_ICON)
                if debugMode then
                    print("PeaversAlwaysSquare: Marked " .. name .. " with Square")
                end
            end
            return
        end
    end

    if debugMode then print("PeaversAlwaysSquare: No tank found") end
end


-- Timer for periodic checking
local elapsed = 0
frame:SetScript("OnUpdate", function(self, sinceLastUpdate)
    elapsed = elapsed + sinceLastUpdate
    if elapsed >= checkFrequency then
        MarkTank()
        elapsed = 0
    end
end)

-- Event handler
frame:SetScript("OnEvent", function(self, event, ...)
    if debugMode then print("PeaversAlwaysSquare: Event: " .. event) end
    MarkTank()
end)

-- Slash command
SLASH_TANKMARKER1 = "/tm"
SlashCmdList["TANKMARKER"] = function(msg)
    if msg == "debug" then
        debugMode = not debugMode
        print("PeaversAlwaysSquare: Debug mode " .. (debugMode and "enabled" or "disabled"))
    elseif msg:match("^icon%s+(%d)$") then
        local iconId = tonumber(msg:match("^icon%s+(%d)$"))
        if iconId and iconId >= 1 and iconId <= 8 then
            SQUARE_ICON = iconId
            print("PeaversAlwaysSquare: Using icon: " .. iconNames[iconId])
        else
            print("PeaversAlwaysSquare: Invalid icon (use 1-8)")
        end
    else
        print("PeaversAlwaysSquare: Manual check performed")
        MarkTank()
    end
end

-- Initialization message
print("|cFF00FF00PeaversAlwaysSquare loaded.|r Disabled in raids.")
print("Commands: /tm, /tm icon N (1-8), /tm debug")
