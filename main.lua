-- Fix for WOW API Changes
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local GetNumAddOns = C_AddOns.GetNumAddOns or GetNumAddOns
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded;
local IsAddOnLoadOnDemand = C_AddOns.IsAddOnLoadOnDemand or IsAddOnLoadOnDemand;
local GetAddOnInfo = C_AddOns.GetAddOnInfo or GetAddOnInfo
local GetAddOnDependencies = C_AddOns.GetAddOnDependencies or GetAddOnDependencies


-- constants
local playerName = UnitName("player")
local defaultMpThreshold = 50
local antiSpamThresholdValue = 20

-- Saved vars (config)
local mpThreshold -- mp = mana percentage

-- vars
local antiSpam = false
local antiSpamThreshold

local version = GetAddOnMetadata("OutOfMana2","Version")
-- Addon loaded message
print("|c0003fc07OOM |r[|c0003fc07" .. version .. "|r] loaded: /mana")

-- Handle Events
local f = CreateFrame("Frame");
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("UNIT_POWER_UPDATE")

function f:OnEvent(event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "OutOfMana2" then
        if not OutOfManaDB2 then
            OutOfManaDB2 = {}
            OutOfManaDB2.mpThreshold = defaultMpThreshold
        end
        mpThreshold = OutOfManaDB2.mpThreshold
        antiSpamThreshold = mpThreshold + antiSpamThresholdValue
    end
    if event == "PLAYER_LOGOUT" then
        OutOfManaDB2.mpThreshold = mpThreshold
    end
    if event == "UNIT_POWER_UPDATE" then
        local mp = (UnitPower("player", 0) / UnitPowerMax("player")) * 100 -- current player mana percentage
        if (arg1 == "player") and (arg2 == "MANA") and (mp <= mpThreshold) and (not antiSpam) then          
            DoEmote("OOM")
            SendChatMessage(playerName .. " - I have " .. round(mp) .. "% mana!", IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
            antiSpam = true
        end
        if (arg1 == "player") and (arg2 == "MANA") and (mp >= antiSpamThreshold) and antiSpam then
             antiSpam = false 
        end
    end
end

AddonCompartmentFrame:RegisterAddon({
    text = "|c0003fc07OutOfMana2|r",
    icon = "Interface\\AddOns\\OutOfMana2\\Textures\\OOM_Logo",
    notCheckable = true,
    func = function()
        print("|c0003fc07OutOfMana2|r by: |cFFE6CC80Gonzo Inc", version)
    end,
})

f:SetScript("OnEvent", f.OnEvent)

function round(number)
  if (number - (number % 0.1)) - (number - (number % 1)) < 0.5 then
    number = number - (number % 1)
  else
    number = (number - (number % 1)) + 1
  end
 return number
end

-- Commands
SLASH_SAVED1 = "/mana";
function SlashCmdList.SAVED(msg)
    if msg ~= "" then 
        mpThreshold = tonumber(msg)
        print("Changed limit to: " .. mpThreshold .. "%")      
        if (mpThreshold + antiSpamThresholdValue > 100) then
            antiSpamThreshold = 100
        else
            antiSpamThreshold = mpThreshold + antiSpamThresholdValue 
        end
    else 
        print("Limit: " .. mpThreshold .. "%" .. " (\"/mana number\" to change)")
    end
end
