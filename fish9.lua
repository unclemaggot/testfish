-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Safe require helper
local function safeRequire(pathTbl)
    local ptr = ReplicatedStorage
    for _, seg in ipairs(pathTbl) do
        ptr = ptr:FindFirstChild(seg)
        if not ptr then return nil end
    end
    local ok, mod = pcall(require, ptr)
    return ok and mod or nil
end

local FishingController = safeRequire({"Controllers","FishingController"})
local AnimationController = safeRequire({"Controllers","AnimationController"})
local Replion = safeRequire({"Packages","Replion"}) or safeRequire({"Packages","replion"})
local ItemUtility = safeRequire({"Shared","ItemUtility"})

-- Net folder
local function getNetFolder()
    local packages = ReplicatedStorage:WaitForChild("Packages", 10)
    if not packages then return nil end
    local index = packages:FindFirstChild("_Index")
    if index then
        for _, child in ipairs(index:GetChildren()) do
            if child.Name:match("^sleitnick_net@") then
                return child:FindFirstChild("net")
            end
        end
    end
    return ReplicatedStorage:FindFirstChild("net") or ReplicatedStorage:FindFirstChild("Net")
end

-- =========================
-- STATE
-- =========================
local state = {
    AutoFish = false,
    AutoFavourite = false,
    AutoSell = false,
    TPEnabled = false,
    SelectedTP = "None",
}

local allowedTiers = { [5]=true, [6]=true, [7]=true }

-- =========================
-- SAFE TELEPORT
-- =========================
local function safeTeleport(vec3)
    if not state.TPEnabled then return end
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp then return end
    if hum then hum.Sit = false end
    local cf = CFrame.new(vec3 + Vector3.new(0, 5, 0))
    for _=1,3 do
        hrp.CFrame = cf
        task.wait(0.12)
    end
end

-- =========================
-- AUTO FAVOURITE
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
                    local base = ItemUtility:GetItemData(item.Id)
                    if base and base.Data and allowedTiers[base.Data.Tier] and not item.Favorited then
                        item.Favorited = true
                    end
                end
            end)
            task.wait(5)
        end
    end)
end

-- =========================
-- AUTO SELL
-- =========================
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
-- AUTO FISH V3 (always perfect cast)
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
        local net = getNetFolder(); if not net then return end
        local equipEvent = net:WaitForChild("RE/EquipToolFromHotbar")
        local chargeFunc = net:WaitForChild("RF/ChargeFishingRod")
        local startMini  = net:WaitForChild("RF/RequestFishingMinigameStarted")
        local complete   = net:WaitForChild("RE/FishingCompleted")

        while state.AutoFish do
            if FishingController and FishingController.OnCooldown and FishingController:OnCooldown() then
                repeat task.wait(0.2) until not (FishingController:OnCooldown()) or not state.AutoFish
            end
            if not state.AutoFish then break end

            pcall(function()
                playCastAnim()
                equipEvent:FireServer(1)
                task.wait(0.1)

                -- ✅ Perfect cast every time
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
            while os.clock() - t < 1.7 and state.AutoFish do task.wait() end
        end
    end)
end

local function stopAutoFish()
    if autoFishLoop then task.cancel(autoFishLoop); autoFishLoop = nil end
end

-- =========================
-- TELEPORT LOCATIONS
-- =========================
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

local function getByName(name, list)
    for _, v in ipairs(list) do if v.Name == name then return v end end
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
local Status = Main:CreateLabel("Status: Initializing...")

local function updateStatus()
    Status:Set(("AutoFish: %s | AutoFav: %s | AutoSell: %s | TP: %s | LastTP: %s")
        :format(state.AutoFish and "ON" or "OFF",
                state.AutoFavourite and "ON" or "OFF",
                state.AutoSell and "ON" or "OFF",
                state.TPEnabled and "ON" or "OFF",
                state.SelectedTP))
end

Main:CreateToggle({
    Name = "Auto Fish V3 (1.7s, Perfect Cast)",
    CurrentValue = false,
    Callback = function(v)
        state.AutoFish = v
        if v then startAutoFish() else stopAutoFish() end
        updateStatus()
    end
})

Main:CreateToggle({
    Name = "Auto Favourite (Legendary/Mythic/Secret)",
    CurrentValue = false,
    Callback = function(v)
        state.AutoFavourite = v
        if v then startAutoFavourite() end
        updateStatus()
    end
})

Main:CreateToggle({
    Name = "Auto Sell (except Legendary/Mythic/Secret)",
    CurrentValue = false,
    Callback = function(v)
        state.AutoSell = v
        if v then startAutoSell() end
        updateStatus()
    end
})

Main:CreateToggle({
    Name = "Enable Teleport",
    CurrentValue = false,
    Callback = function(v)
        state.TPEnabled = v
        updateStatus()
    end
})

-- Dropdowns
local islandNames, secretNames = {}, {}
for _, i in ipairs(main_islands) do table.insert(islandNames, i.Name) end
for _, s in ipairs(secret_locations) do table.insert(secretNames, s.Name) end

Main:CreateDropdown({
    Name = "Teleport to Island",
    Options = islandNames,
    CurrentOption = "Fisherman Island (Home)",
    Callback = function(choice)
        state.SelectedTP = choice
        if state.TPEnabled then
            local tgt = getByName(choice, main_islands)
            if tgt then safeTeleport(tgt.Position) end
        end
        updateStatus()
    end
})

Main:CreateDropdown({
    Name = "Teleport to Secret Location",
    Options = secretNames,
    CurrentOption = "Sisyphus Statue",
    Callback = function(choice)
        state.SelectedTP = choice
        if state.TPEnabled then
            local tgt = getByName(choice, secret_locations)
            if tgt then safeTeleport(tgt.Position) end
        end
        updateStatus()
    end
})

updateStatus()
