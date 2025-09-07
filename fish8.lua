-- FishIt Lite (Rayfield Edition)
-- AutoFish V3 (Perfect Cast, 1.4s) + AutoFav (all fish) + AutoSell + Teleport buttons

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Safe require helper
local function safeRequire(pathTbl)
    local ptr = ReplicatedStorage
    for _, seg in ipairs(pathTbl) do
        ptr = ptr and ptr:FindFirstChild(seg)
        if not ptr then return nil end
    end
    local ok, mod = pcall(require, ptr)
    return ok and mod or nil
end

local FishingController = safeRequire({"Controllers","FishingController"})
local AnimationController = safeRequire({"Controllers","AnimationController"})
local Replion = safeRequire({"Packages","Replion"}) or safeRequire({"Packages","replion"})
local ItemUtility = safeRequire({"Shared","ItemUtility"})

-- State
local state = {
    AutoFish = false,
    AutoFavourite = false,
    AutoSell = false,
}

-- =========================
-- AUTO FAVOURITE (All Fish)
-- =========================
local function startAutoFavourite()
    task.spawn(function()
        while state.AutoFavourite do
            pcall(function()
                if not Replion or not ItemUtility then return end
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) ~= "table" then return end
                for _, item in ipairs(items) do
                    if not item.Favorited then
                        item.Favorited = true
                    end
                end
            end)
            task.wait(5)
        end
    end)
end

-- =========================
-- AUTO SELL (except Legendary/Mythic/Secret)
-- =========================
local allowedTiers = { [5]=true, [6]=true, [7]=true }

local function startAutoSell()
    task.spawn(function()
        while state.AutoSell do
            pcall(function()
                if not Replion or not ItemUtility then return end
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) ~= "table" then return end
                local evt = ReplicatedStorage:FindFirstChild("Events")
                evt = evt and evt:FindFirstChild("SellFish")
                if not evt then return end
                for _, item in ipairs(items) do
                    local base = ItemUtility:GetItemData(item.Id)
                    if base and base.Data and not allowedTiers[base.Data.Tier] then
                        evt:FireServer(item.Uuid, item.Count or 1)
                    end
                end
            end)
            task.wait(5)
        end
    end)
end

-- =========================
-- AUTO FISH (Perfect Cast, 1.4s)
-- =========================
local autoFishLoop

local function playCastAnim()
    pcall(function()
        if AnimationController and AnimationController.PlayAnimation then
            AnimationController:PlayAnimation("CastFromFullChargePosition1Hand")
        end
    end)
end

local function startAutoFish()
    if autoFishLoop then task.cancel(autoFishLoop) end
    autoFishLoop = task.spawn(function()
        local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):FindFirstChildOfClass("Folder")
        local equipEvent = netFolder:WaitForChild("RE/EquipToolFromHotbar")
        local chargeFunc = netFolder:WaitForChild("RF/ChargeFishingRod")
        local startMini  = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
        local complete   = netFolder:WaitForChild("RE/FishingCompleted")

        while state.AutoFish do
            if FishingController and FishingController.OnCooldown and FishingController:OnCooldown() then
                repeat task.wait(0.2) until not (FishingController:OnCooldown()) or not state.AutoFish
            end
            if not state.AutoFish then break end

            pcall(function()
                playCastAnim()
                equipEvent:FireServer(1)
                task.wait(0.1)

                -- Perfect cast
                chargeFunc:InvokeServer(workspace:GetServerTimeNow())

                task.wait(0.1)
                startMini:InvokeServer(-0.75, 1)
                task.wait(0.2)

                for i=1,20 do
                    complete:FireServer()
                    task.wait(0.05)
                end
            end)

            local t = os.clock()
            while os.clock() - t < 1.4 and state.AutoFish do task.wait() end
        end
    end)
end

local function stopAutoFish()
    if autoFishLoop then task.cancel(autoFishLoop); autoFishLoop = nil end
end

-- =========================
-- TELEPORT LOCATIONS
-- =========================
local island_locations = {
    { Name = "Fisherman Island (Home)", Position = Vector3.new(34, 10, 2814) },
    { Name = "Kohana", Position = Vector3.new(-632, 16, 599) },
    { Name = "Kohana Volcano", Position = Vector3.new(-531, 24, 187) },
    { Name = "Crater Island", Position = Vector3.new(1016, 23, 5078) },
    { Name = "Esoteric Depths", Position = Vector3.new(2011, 22, 1395) },
    { Name = "Tropical Grove", Position = Vector3.new(-2095, 197, 3718) },
    { Name = "Lost Isle", Position = Vector3.new(-3608, 5, -1292) },
    { Name = "Sisyphus Statue", Position = Vector3.new(-3742, -136, -1033) },
    { Name = "Treasure Room", Position = Vector3.new(-3600, -270, -1642) },
    { Name = "Coral Reefs", Position = Vector3.new(-3023.97, 337.81, 2195.60) },
}

local function teleportTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
    end
end

-- =========================
-- RAYFIELD UI
-- =========================
local Window = Rayfield:CreateWindow({
    Name = "FishIt Lite",
    LoadingTitle = "FishIt Lite",
    LoadingSubtitle = "Rayfield Edition",
    KeySystem = false
})

local Main = Window:CreateTab("Main", 4483362458)
local TP = Window:CreateTab("Teleport", 4483362458)

-- Toggles
Main:CreateToggle({
    Name = "Auto Fish V3 (Perfect Cast, 1.4s)",
    CurrentValue = false,
    Callback = function(v)
        state.AutoFish = v
        if v then startAutoFish() else stopAutoFish() end
    end
})

Main:CreateToggle({
    Name = "Auto Favourite (All Fish)",
    CurrentValue = false,
    Callback = function(v)
        state.AutoFavourite = v
        if v then startAutoFavourite() end
    end
})

Main:CreateToggle({
    Name = "Auto Sell (except Legendary/Mythic/Secret)",
    CurrentValue = false,
    Callback = function(v)
        state.AutoSell = v
        if v then startAutoSell() end
    end
})

-- Teleport buttons
for _, loc in ipairs(island_locations) do
    TP:CreateButton({
        Name = loc.Name,
        Callback = function()
            teleportTo(loc.Position)
        end
    })
end
