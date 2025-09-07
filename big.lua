-- =========================
-- e-Fishery V.1 - Full Script
-- =========================

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
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

-- Controllers
local FishingController = safeRequire({"Controllers","FishingController"})
local AnimationController = safeRequire({"Controllers","AnimationController"})
local Replion = safeRequire({"Packages","Replion"}) or safeRequire({"Packages","replion"})
local ItemUtility = safeRequire({"Shared","ItemUtility"})

-- =========================
-- State
-- =========================
local state = {
    AutoFish = false,
    AutoFavourite = false,
    SelectedTP = "None",
}

local featureState = {
    AutoSell = false,
    AutoSellDelay = 300 -- default 5 minutes
}

-- Legendary, Mythic, Secret tiers
local allowedTiers = { [5]=true, [6]=true, [7]=true }

-- =========================
-- Teleport
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
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
    end
end

-- =========================
-- Auto Favourite
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
-- Auto Fish
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
        local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):FindFirstChild("sleitnick_net@0.2.0"):WaitForChild("net")
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
                chargeFunc:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.1)
                startMini:InvokeServer(-0.75, 1)
                task.wait(0.2)
                for i=1,20 do
                    complete:FireServer()
                    task.wait(0.05)
                end

                -- Webhook notification for Legendary/Mythic/Secret fish
                if Replion and ItemUtility then
                    local DataReplion = Replion.Client:WaitReplion("Data")
                    local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                    if type(items) == "table" then
                        for _, item in ipairs(items) do
                            local base = ItemUtility:GetItemData(item.Id)
                            if base and base.Data and allowedTiers[base.Data.Tier] then
                                pcall(function()
                                    if webhookConfig.Enabled and webhookConfig.URL ~= "" then
                                        local msg = string.format(
                                            "%s\nRarity: %s\nWeight: %skg\nSell Value: %s\nDate: %s",
                                            base.Data.Name or "Unknown Fish",
                                            base.Data.Rarity or "Unknown",
                                            base.Data.Weight or "Unknown",
                                            base.Data.SellValue or "Unknown",
                                            os.date("%Y-%m-%d %H:%M:%S")
                                        )
                                        HttpService:PostAsync(webhookConfig.URL, HttpService:JSONEncode({content=msg}), Enum.HttpContentType.ApplicationJson)
                                    end
                                end)
                            end
                        end
                    end
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
-- Auto Sell Anywhere (Fixed)
-- =========================
local autoSellLoop
local function startAutoSell()
    if autoSellLoop then task.cancel(autoSellLoop) end
    autoSellLoop = task.spawn(function()
        local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):FindFirstChild("sleitnick_net@0.2.0"):WaitForChild("net")
        local sellItemFunc = netFolder:WaitForChild("RF/SellItem")
        
        while featureState.AutoSell do
            pcall(function()
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) == "table" then
                    for _, item in ipairs(items) do
                        if not item.Favorited then
                            task.spawn(function()
                                pcall(function()
                                    sellItemFunc:InvokeServer(item.Uuid or item.Id, item.Count or 1)
                                end)
                            end)
                        end
                    end
                end
            end)

            -- Wait for dynamic delay (default 5 minutes)
            local t0 = os.clock()
            while os.clock() - t0 < featureState.AutoSellDelay and featureState.AutoSell do
                task.wait(1)
            end
        end
    end)
end

local function stopAutoSell()
    if autoSellLoop then task.cancel(autoSellLoop); autoSellLoop = nil end
end

-- =========================
-- Webhook Auto-Save
-- =========================
local webhookConfig = { URL = "", Enabled = false }
local webhookFileName = "eFishery_WebhookConfig.json"

-- Load saved config
if pcall(function() readfile(webhookFileName) end) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(webhookFileName))
    end)
    if ok and type(data) == "table" then
        webhookConfig.URL = data.URL or ""
        webhookConfig.Enabled = data.Enabled or false
    end
end

local function saveWebhookConfig()
    pcall(function()
        writefile(webhookFileName, HttpService:JSONEncode(webhookConfig))
    end)
end

-- =========================
-- Rayfield UI
-- =========================
local Window = Rayfield:CreateWindow({
    Name = "e-Fishery V.1",
    LoadingTitle = "e-Fishery V.1",
    LoadingSubtitle = "Rayfield Edition",
    KeySystem = false
})

-- Tabs
local Main = Window:CreateTab("Main", 4483362458)
local Teleport = Window:CreateTab("Teleport", 4483362458)
local WebhookTab = Window:CreateTab("Webhook Settings", 4483362458)

-- ===== Main Tab =====
Main:CreateToggle({
    Name = "Auto Fish V3 (Perfect Cast, 1.7s)",
    Description = "Automatically fish with perfect cast every 1.7s.",
    CurrentValue = false,
    Callback = function(v)
        state.AutoFish = v
        if v then startAutoFish() else stopAutoFish() end
    end
})

Main:CreateToggle({
    Name = "Auto Favourite (Legendary/Mythic/Secret)",
    Description = "Automatically favorite Legendary, Mythic, and Secret fish.",
    CurrentValue = false,
    Callback = function(v)
        state.AutoFavourite = v
        if v then startAutoFavourite() end
    end
})

Main:CreateToggle({
    Name = "Auto Sell (except favorite fish)",
    Description = "Automatically sell unfavorited fish according to delay.",
    CurrentValue = false,
    Callback = function(v)
        featureState.AutoSell = v
        if v then startAutoSell() else stopAutoSell() end
    end
})

Main:CreateInput({
    Name = "Auto Sell Delay (minutes)",
    Description = "Set the time interval between auto sell actions.",
    Placeholder = "5",
    Callback = function(v)
        local minutes = tonumber(v)
        if minutes and minutes > 0 then
            featureState.AutoSellDelay = minutes * 60
        else
            featureState.AutoSellDelay = 300
        end
    end
})

-- ===== Teleport Tab =====
for _, loc in ipairs(island_locations) do
    Teleport:CreateButton({
        Name = loc.Name,
        Description = "Teleport to " .. loc.Name,
        Callback = function()
            teleportTo(loc.Position)
            state.SelectedTP = loc.Name
        end
    })
end

-- ===== Webhook Tab =====
WebhookTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "Enter your Discord webhook URL",
    Callback = function(v)
        webhookConfig.URL = v
        saveWebhookConfig()
    end
})

WebhookTab:CreateToggle({
    Name = "Enable Webhook Notifications",
    Description = "Send notifications to Discord when Legendary/Mythic/Secret fish are caught.",
    CurrentValue = webhookConfig.Enabled,
    Callback = function(v)
        webhookConfig.Enabled = v
        saveWebhookConfig()
    end
})

WebhookTab:CreateButton({
    Name = "Test Webhook",
    Description = "Send a test message to your webhook.",
    Callback = function()
        if webhookConfig.URL == "" then
            warn("Webhook URL is empty!")
            return
        end
        if not webhookConfig.Enabled then
            warn("Webhook notifications are disabled!")
            return
        end
        task.spawn(function()
            pcall(function()
                HttpService:PostAsync(webhookConfig.URL, HttpService:JSONEncode({content = "Test message from e-Fishery V.1!"}), Enum.HttpContentType.ApplicationJson)
            end)
        end)
    end
})
