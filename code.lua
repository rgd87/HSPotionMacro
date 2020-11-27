local MACRO_NAME = "HSPotion"
local itemSequence = { 5512, 177278, 171267, 169451 } -- Hs, Phial of Serenity, Spiritual Potion, Abyssal Potion
local fallback = 171267


local function UpdateMacro(macroname, newbody)
    local QUESTIONMARK = "INV_MISC_QUESTIONMARK" -- 134400
    local index = GetMacroIndexByName(macroname)
    if index == 0 then
        index = CreateMacro(macroname, QUESTIONMARK, nil, nil)
        if not index or index == 0 then return end
    end
    EditMacro(index, nil, nil, newbody)
end

local function FindContainerItemByID(itemID)
    for bag=0,NUM_BAG_SLOTS do
        for slot=1, GetContainerNumSlots(bag) do
            local slotItemID = GetContainerItemID(bag, slot)
            if slotItemID == itemID then
                return bag, slot
            end
        end
    end
    return nil
end

local currentMacroID = -1

local f = CreateFrame("Frame", nil, UIParent)
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- Bag item info also becomes progressively available and BAG_UPDATE is spammed during the loading screen
        self:RegisterEvent("BAG_UPDATE")
    end
    if not InCombatLockdown() then
        local strTable = {}
        local macroID = 0
        for _, itemID in ipairs(itemSequence) do
            if FindContainerItemByID(itemID) then
                macroID = macroID + 1
                table.insert(strTable, string.format("item:%d", itemID))
            end
            macroID = macroID * 2
        end

        local macroBase = "#showtooltip\n/castsequence reset=59 "
        if #strTable == 0 then
            macroBase = "#showtooltip\n/cast "
            table.insert(strTable, string.format("item:%d", fallback))
        end

        if currentMacroID ~= macroID then
            local newMacro = macroBase..table.concat(strTable, ", ")
            UpdateMacro(MACRO_NAME, newMacro)
            currentMacroID = macroID
        end

        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    else
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    end
end)
