-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Controllers & Utilities
local FishingController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("FishingController"))
local AnimationController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("AnimationController"))
local Replion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Replion"))
local ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))

-- State
local featureState = {
    AutoFish = false,
    AutoFavourite = false,
    AutoSell = false,
    SelectedTP = "None"
}

-- === Auto Fish V3 (1.7s delay) ===
local autoFishV3Connection, timeoutThread
local function playCastingAnimation()
    pcall(function()
        AnimationController:PlayAnimation("CastFromFullChargePosition1Hand")
    end)
end

local function startAutoFishV3()
    task.spawn(function()
        local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
        local equipEvent = netFolder:WaitForChild("RE/EquipToolFromHotbar")
        local chargeFunc = netFolder:WaitForChild("RF/ChargeFishingRod")
        local startMinigameFunc = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
        local completeEvent = netFolder:WaitForChild("RE/FishingCompleted")
        local fishCaughtEvent = netFolder:WaitForChild("RE/FishCaught")

        local function castSequence()
            if not featureState.AutoFish then return end
            if timeoutThread then task.cancel(timeoutThread) end

            pcall(function()
                playCastingAnimation()
                equipEvent:FireServer(1)
                task.wait(0.1)
                chargeFunc:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.1)
                startMinigameFunc:InvokeServer(-0.75, 1)
                task.wait(0.2)
                completeEvent:FireServer()
            end)

            timeoutThread = task.delay(1.7, function()
                if featureState.AutoFish then castSequence() end
            end)
        end

        if autoFishV3Connection and autoFishV3Connection.Connected then
            autoFishV3Connection:Disconnect()
        end

        autoFishV3Connection = fishCaughtEvent.OnClientEvent:Connect(function()
            if featureState.AutoFish then
                if timeoutThread then task.cancel(timeoutThread) end
                timeoutThread = task.delay(1.7, function()
                    if featureState.AutoFish then castSequence() end
                end)
            end
        end)

        castSequence()
    end)
end

local function stopAutoFishV3()
    if autoFishV3Connection and autoFishV3Connection.Connected then
        autoFishV3Connection:Disconnect()
        autoFishV3Connection = nil
    end
    if timeoutThread then
        task.cancel(timeoutThread)
        timeoutThread = nil
    end
end

-- === Auto Favourite (Legendary, Mythic, Secret only) ===
local allowedTiers = {
    [5] = true, -- Legendary
    [6] = true, -- Mythic
    [7] = true  -- Secret
}

local function startAutoFavourite()
    task.spawn(function()
        while featureState.AutoFavourite do
            pcall(function()
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory", "Items"})
                if not items then return end

                for _, item in ipairs(items) do
                    local baseData = ItemUtility:GetItemData(item.Id)
                    if baseData and baseData.Data and allowedTiers[baseData.Data.Tier] then
                        if not item.Favorited then
                            item.Favorited = true
                        end
                    end
                end
            end)
            task.wait(5)
        end
    end)
end

-- === Auto Sell (except Legendary/Mythic/Secret) ===
local function startAutoSell()
    task.spawn(function()
        while featureState.AutoSell do
            pcall(function()
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory", "Items"})
                if not items then return end

                for _, item in ipairs(items) do
                    local baseData = ItemUtility:GetItemData(item.Id)
                    if baseData and baseData.Data and not allowedTiers[baseData.Data.Tier] then
                        local SellFishEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SellFish")
                        SellFishEvent:FireServer(item.Uuid, item.Count or 1)
                    end
                end
            end)
            task.wait(5) -- 5s delay
        end
    end)
end

-- === Teleport Locations ===
local main_islands = {
    { Name = "Fisherman Island (Home)", Position = Vector3.new(34, 10, 2814) },
    { Name = "Kohana", Position = Vector3.new(-632, 16, 599) },
    { Name = "Kohana Volcano", Position = Vector3.new(-531, 24, 187) },
    { Name = "Crater Island", Position = Vector3.new(1016, 23, 5078) },
    { Name = "Esoteric Depths", Position = Vector3.new(2011, 22, 1395) },
    { Name = "Tropical Grove", Position = Vector3.new(-2095, 197, 3718) },
    { Name = "Lost Isle", Position = Vector3.new(-3608, 5, -1292) },
    { Name = "Coral Reefs", Position = Vector3.new(-3023.97, 337.81, 2195.60) },
}

local secret_locations = {
    { Name = "Sisyphus Statue", Position = Vector3.new(-3742, -136, -1033) },
    { Name = "Treasure Room", Position = Vector3.new(-3600, -270, -1642) },
}

local function doTP(locationName, list)
    for _, loc in ipairs(list) do
        if loc.Name == locationName then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(loc.Position)
            end
            featureState.SelectedTP = locationName
            break
        end
    end
end

-- === Rayfield UI ===
local Window = Rayfield:CreateWindow({
    Name = "FishIt Lite",
    LoadingTitle = "FishIt Lite Script",
    LoadingSubtitle = "by ChatGPT",
    ConfigurationSaving = {
       Enabled = false
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458) -- fish icon

-- Status Label
local StatusLabel = MainTab:CreateLabel("Status: Initializing...")

local function updateStatus()
    StatusLabel:Set("Auto Fish: " .. (featureState.AutoFish and "ON" or "OFF")
        .. " | Auto Fav: " .. (featureState.AutoFavourite and "ON" or "OFF")
        .. " | Auto Sell: " .. (featureState.AutoSell and "ON" or "OFF")
        .. " | Last TP: " .. featureState.SelectedTP)
end

-- Toggles
MainTab:CreateToggle({
    Name = "Auto Fish V3 (1.7s)",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(state)
        featureState.AutoFish = state
        if state then startAutoFishV3() else stopAutoFishV3() end
        updateStatus()
    end
})

MainTab:CreateToggle({
    Name = "Auto Favourite (Legendary+)",
    CurrentValue = false,
    Flag = "AutoFavourite",
    Callback = function(state)
        featureState.AutoFavourite = state
        if state then startAutoFavourite() end
        updateStatus()
    end
})

MainTab:CreateToggle({
    Name = "Auto Sell (except Legendary+)",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(state)
        featureState.AutoSell = state
        if state then startAutoSell() end
        updateStatus()
    end
})

-- Dropdowns
local mainNames, secretNames = {}, {}
for _, island in ipairs(main_islands) do table.insert(mainNames, island.Name) end
for _, secret in ipairs(secret_locations) do table.insert(secretNames, secret.Name) end

MainTab:CreateDropdown({
    Name = "Teleport to Island",
    Options = mainNames,
    CurrentOption = "Fisherman Island (Home)",
    Callback = function(choice)
        doTP(choice, main_islands)
        updateStatus()
    end
})

MainTab:CreateDropdown({
    Name = "Teleport to Secret Location",
    Options = secretNames,
    CurrentOption = "Sisyphus Statue",
    Callback = function(choice)
        doTP(choice, secret_locations)
        updateStatus()
    end
})

updateStatus()
