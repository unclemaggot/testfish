--========================================================--
-- Arcvour Hub (Rayfield Version, Stripped Down)
-- Features: Farming, Auto Trade, Auto Favorite, Teleports
--========================================================--

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Window Setup
local Window = Rayfield:CreateWindow({
    Name = "ArcvourHub",
    LoadingTitle = "Arcvour Hub",
    LoadingSubtitle = "Fish It",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ArcvourHub_Config",
        FileName = "Config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

--========================================================--
-- Sections
--========================================================--
local FarmingTab       = Window:CreateTab("Farming", 4483362458) -- fish icon
local AutoTradeTab     = Window:CreateTab("Auto Trade", 4483362458)
local AutoFavoriteTab  = Window:CreateTab("Auto Favorite", 4483362458)
local TeleportsTab     = Window:CreateTab("Teleports", 4483362458)

--========================================================--
-- Farming Features
--========================================================--
local featureState = {
    AutoFish = false,
    LockPosition = false,
    AutoSellMode = "Disabled",
    AutoSellDelay = 1800,
}
local selectedAutoFishMethod = "V2"

FarmingTab:CreateDropdown({
    Name = "Auto Fish Method",
    Options = {"Auto Fish V1 (Stable)", "Auto Fish V2 (Recommended)", "Auto Fish V3 (Beta)"},
    CurrentOption = "Auto Fish V2 (Recommended)",
    Flag = "AutoFishMethod",
    Callback = function(option)
        if option:find("V1") then
            selectedAutoFishMethod = "V1"
        elseif option:find("V3") then
            selectedAutoFishMethod = "V3"
        else
            selectedAutoFishMethod = "V2"
        end
    end
})

FarmingTab:CreateToggle({
    Name = "Enable Auto Fish",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(v)
        featureState.AutoFish = v
        -- TODO: Insert original Auto Fish logic (V1, V2, V3) here
    end
})

FarmingTab:CreateToggle({
    Name = "Lock Position",
    CurrentValue = false,
    Flag = "LockPosition",
    Callback = function(v)
        featureState.LockPosition = v
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = v
        end
    end
})

FarmingTab:CreateDropdown({
    Name = "Auto Sell All Fish",
    Options = {"Disabled", "Auto Sell All (No TP)", "Auto Sell All (TP)"},
    CurrentOption = "Disabled",
    Flag = "AutoSellMode",
    Callback = function(value)
        featureState.AutoSellMode = value
    end
})

FarmingTab:CreateInput({
    Name = "Auto Sell Delay (minutes)",
    PlaceholderText = "e.g., 30",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        local mins = tonumber(v)
        featureState.AutoSellDelay = (mins and mins > 0) and mins*60 or 1800
    end
})

--========================================================--
-- Auto Trade
--========================================================--
AutoTradeTab:CreateSection("Auto Trade")
AutoTradeTab:CreateParagraph({Title = "Info", Content = "Includes Auto Trade v1 & v2 with Mass Send."})

-- TODO: Add simplified auto trade logic here (V1, V2, Auto Accept)

--========================================================--
-- Auto Favorite
--========================================================--
AutoFavoriteTab:CreateSection("Auto Favorite")
AutoFavoriteTab:CreateParagraph({Title = "Feature", Content = "Automatically favorites selected fish tiers."})

AutoFavoriteTab:CreateDropdown({
    Name = "Favorite Fish Tiers",
    Options = {"Legendary", "Mythic", "SECRET"},
    CurrentOption = {},
    Multi = true,
    Flag = "FavoriteTiers",
    Callback = function(val)
        -- Save selected favorite tiers
    end
})

--========================================================--
-- Teleports
--========================================================--
TeleportsTab:CreateSection("Teleports")
TeleportsTab:CreateParagraph({Title = "Quick Travel", Content = "Teleport to islands, shops, NPCs, players, or spawn a boat."})

-- TODO: Add teleport logic here (TP Islands, TP NPC, TP Shop, TP Player, Spawn Boat)

