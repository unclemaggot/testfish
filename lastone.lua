--// ArcvourHub Lite (Clean Version)
--// Features: Auto Fish, Auto Sell, Auto Favorite, Teleport Islands
--// Free to use - no validation

-- Load WindUI
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    if not WindUI then return end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "ArcvourHub Lite",
    Icon = "rbxassetid://6023426923", -- fish icon
    Size = UDim2.new(0, 500, 0, 350),
    ToggleKey = Enum.KeyCode.K,
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- Auto Fish Variables
local AutoFish = false
local FishingController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("FishingController"))

-- Auto Sell Variables
local AutoSell = false
local SellRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SellFish")

-- Auto Favorite Variables
local AutoFavorite = false
local Inventory = ReplicatedStorage:WaitForChild("Inventories"):WaitForChild(LocalPlayer.UserId)

-- Teleportation Locations
local Islands = {
    ["Main Island"] = CFrame.new(0, 50, 0),
    ["Fishing Spot"] = CFrame.new(200, 20, 500),
    ["Volcano Island"] = CFrame.new(-1000, 100, 800),
    ["Snow Island"] = CFrame.new(1200, 150, -600),
}

--// Auto Fish Tab
local TabFish = Window:CreateTab("Auto Fish")
TabFish:CreateToggle("Enable Auto Fish", false, function(state)
    AutoFish = state
    if AutoFish then
        task.spawn(function()
            while AutoFish do
                pcall(function()
                    FishingController:Cast()
                    task.wait(1.5)
                    FishingController:Reel()
                end)
                task.wait(2)
            end
        end)
    end
end)

--// Auto Sell Tab
local TabSell = Window:CreateTab("Auto Sell")
TabSell:CreateToggle("Enable Auto Sell", false, function(state)
    AutoSell = state
    if AutoSell then
        task.spawn(function()
            while AutoSell do
                pcall(function()
                    SellRemote:FireServer()
                end)
                task.wait(5)
            end
        end)
    end
end)

--// Auto Favorite Tab
local TabFav = Window:CreateTab("Auto Favorite")
TabFav:CreateToggle("Enable Auto Favorite (Tier 5+)", false, function(state)
    AutoFavorite = state
    if AutoFavorite then
        task.spawn(function()
            while AutoFavorite do
                pcall(function()
                    for _, item in pairs(Inventory:GetChildren()) do
                        if item:FindFirstChild("Tier") and item.Tier.Value >= 5 then
                            item.Favorited.Value = true
                        end
                    end
                end)
                task.wait(10)
            end
        end)
    end
end)

--// Teleport Tab
local TabTP = Window:CreateTab("Teleport")
for name, cf in pairs(Islands) do
    TabTP:CreateButton("TP to " .. name, function()
        LocalPlayer.Character:PivotTo(cf)
    end)
end

-- Done
WindUI:Init()
