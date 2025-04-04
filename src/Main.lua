local addonName, PeaversAlwaysSquare = ...
local frame = CreateFrame("Frame")
local SQUARE_ICON = 6
local checkFrequency = 1.0 -- Check every 1 second
local debugMode = false

-- Icon names for reference
local iconNames = {
    [1] = "Star",
    [2] = "Circle",
    [3] = "Diamond",
    [4] = "Triangle",
    [5] = "Moon",
    [6] = "Square",
    [7] = "Cross",
    [8] = "Skull"
}

-- Register events we need to track
frame:RegisterEvent("GROUP_ROSTER_UPDATE") -- When group composition changes
frame:RegisterEvent("READY_CHECK") -- Additional trigger points
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Function to find and mark the tank
local function MarkTank()
    -- Only run if in a group
    if not IsInGroup() then
        if debugMode then print("PeaversAlwaysSquare: Not in group, nothing to do") end
        return
    end

    -- Check for raid target permissions
    if not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") and GetNumGroupMembers() > 5 then
        print("PeaversAlwaysSquare: You need to be leader or assistant to set markers in raids")
        return
    end

    -- Iterate through group members to find the tank
    local numMembers = GetNumGroupMembers()
    local foundTank = false

    for i = 1, numMembers do
        local unit
        if IsInRaid() then
            unit = "raid" .. i
        else
            if i < numMembers then
                unit = "party" .. i
            else
                unit = "player" -- Include player in party check
            end
        end

        -- Check if this unit is a tank
        local role = UnitGroupRolesAssigned(unit)
        if role == "TANK" then
            foundTank = true
            local name = UnitName(unit)
            local currentMark = GetRaidTargetIndex(unit)

            -- If tank doesn't have the designated icon, set it
            if currentMark ~= SQUARE_ICON then
                -- Set the tank's raid icon
                SetRaidTarget(unit, SQUARE_ICON)
                print("PeaversAlwaysSquare: Marked " .. name .. " with icon ID " .. SQUARE_ICON ..
                      " (" .. (iconNames[SQUARE_ICON] or "Unknown") .. ")")
            elseif debugMode then
                print("PeaversAlwaysSquare: " .. name .. " already has correct icon " .. SQUARE_ICON)
            end
        end
    end

    if not foundTank and debugMode then
        print("PeaversAlwaysSquare: No tank found in the group")
    end
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
    -- Mark the tank when relevant events occur
    if debugMode then print("PeaversAlwaysSquare: Event triggered: " .. event) end
    MarkTank()
end)

-- Function to test all raid icons on player
local function TestAllIcons()
    print("|cFF00FF00TankMarker: Testing all raid icons on player|r")
    local originalMark = GetRaidTargetIndex("player")

    -- Test each icon in sequence
    for i = 1, 8 do
        C_Timer.After((i-1) * 1.5, function()
            print("Setting icon " .. i .. " (" .. (iconNames[i] or "Unknown") .. ")")
            SetRaidTarget("player", i)
        end)
    end

    -- Restore original mark after all tests
    C_Timer.After(12, function()
        SetRaidTarget("player", originalMark or 0)
        print("Test complete. Restored original mark.")
    end)
end

-- Slash command to manually trigger marking
SLASH_TANKMARKER1 = "/tankmarker"
SLASH_TANKMARKER2 = "/tm"
SlashCmdList["TANKMARKER"] = function(msg)
    if msg == "debug" then
        debugMode = not debugMode
        print("PeaversAlwaysSquare: Debug mode " .. (debugMode and "enabled" or "disabled"))
    elseif msg == "test" then
        TestAllIcons()
    elseif msg:match("^icon%s+(%d)$") then
        local iconId = tonumber(msg:match("^icon%s+(%d)$"))
        if iconId and iconId >= 1 and iconId <= 8 then
            SQUARE_ICON = iconId
            print("PeaversAlwaysSquare: Will now use icon ID " .. iconId .. " (" .. (iconNames[iconId] or "Unknown") .. ")")
        else
            print("PeaversAlwaysSquare: Invalid icon ID. Use a number between 1 and 8.")
        end
    else
        print("PeaversAlwaysSquare: Manual mark check performed")
        MarkTank()
    end
end

-- Print reference table and initialization message
print("|cFF00FF00TankMarker loaded.|r")
print("Available icons:")
for i = 1, 8 do
    print("ID " .. i .. ": " .. (iconNames[i] or "Unknown"))
end
print("Will mark tanks with ID " .. SQUARE_ICON .. " (" .. (iconNames[SQUARE_ICON] or "Unknown") .. ")")
print("Commands:")
print("/tm - Mark tanks now")
print("/tm icon N - Change icon ID to N (1-8)")
print("/tm test - Test all icons on yourself")
print("/tm debug - Toggle debug mode")
