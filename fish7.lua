-- FishIt Lite (Rayfield) — Fixed AutoFish + 1.4s delay + TP buttons + Favourite all fish
-- Paste & run in Delta (Rayfield must be reachable)

-- Load Rayfield
local successRay, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not successRay or not Rayfield then
    warn("Failed to load Rayfield UI.")
    return
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Safe require helper (non-failing)
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

-- Robust net folder finder (searches Packages._Index for sleitnick_net@*)
local function getNetFolder()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if packages then
        local index = packages:FindFirstChild("_Index")
        if index then
            for _, child in ipairs(index:GetChildren()) do
                if child.Name:match("^sleitnick_net@") then
                    local net = child:FindFirstChild("net")
                    if net then return net end
                end
            end
        end
    end
    -- fallback
    local fallback = ReplicatedStorage:FindFirstChild("net") or ReplicatedStorage:FindFirstChild("Net")
    return fallback
end

-- find remote by a path like "RE/EquipToolFromHotbar" or "RF/ChargeFishingRod"
local function findRemote(net, path, timeout)
    if not net or type(path) ~= "string" then return nil end
    timeout = timeout or 5
    local cur = net
    for part in path:gmatch("[^/]+") do
        local found
        local waited = 0
        while not found and waited < timeout do
            found = cur:FindFirstChild(part)
            if not found then task.wait(0.1); waited = waited + 0.1 end
        end
        if not found then return nil end
        cur = found
    end
    return cur
end

-- safer remote caller (handles RemoteEvent / RemoteFunction)
local function remoteCall(remoteObj, ...)
    if not remoteObj then return nil end
    if remoteObj:IsA("RemoteFunction") then
        local ok, res = pcall(remoteObj.InvokeServer, remoteObj, ...)
        return ok and res or nil
    elseif remoteObj:IsA("RemoteEvent") then
        pcall(remoteObj.FireServer, remoteObj, ...)
        return true
    else
        -- fallback attempts
        pcall(function() remoteObj:FireServer(...) end)
        pcall(function() remoteObj:InvokeServer(...) end)
    end
end

-- server time utility
local function serverTime()
    if workspace and workspace.GetServerTimeNow then
        local ok, t = pcall(workspace.GetServerTimeNow, workspace)
        if ok and t then return t end
    end
    return os.time()
end

-- state
local state = {
    AutoFish = false,
    AutoFavourite = false,
    AutoSell = false,
}

-- =========================
-- AUTO FAVOURITE (ALL FISH)
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
local allowedTiers = { [5]=true, [6]=true, [7]=true } -- keep these
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
                        pcall(function()
                            evt:FireServer(item.Uuid, item.Count or 1)
                        end)
                    end
                end
            end)
            task.wait(5)
        end
    end)
end

-- =========================
-- AUTO FISH V3 (perfect cast integrated) — robust/fault tolerant
-- Delay between casts: 1.4 seconds as requested
-- =========================
local autoFishRunning = false

local function playCastAnim()
    pcall(function()
        if AnimationController and AnimationController.PlayAnimation then
            AnimationController:PlayAnimation("CastFromFullChargePosition1Hand")
        end
    end)
end

local function startAutoFish()
    if autoFishRunning then return end
    autoFishRunning = true
    task.spawn(function()
        local net = getNetFolder()
        if not net then
            warn("AutoFish: net folder not found.")
            autoFishRunning = false
            return
        end

        -- remote references (try to find within net)
        local equipRemote = findRemote(net, "RE/EquipToolFromHotbar") or findRemote(net, "RE"):FindFirstChild("EquipToolFromHotbar") or findRemote(net, "EquipToolFromHotbar")
        local chargeRemote = findRemote(net, "RF/ChargeFishingRod") or findRemote(net, "RF"):FindFirstChild("ChargeFishingRod") or findRemote(net, "ChargeFishingRod")
        local startMiniRemote = findRemote(net, "RF/RequestFishingMinigameStarted") or findRemote(net, "RF"):FindFirstChild("RequestFishingMinigameStarted") or findRemote(net, "RequestFishingMinigameStarted")
        local completeRemote = findRemote(net, "RE/FishingCompleted") or findRemote(net, "RE"):FindFirstChild("FishingCompleted") or findRemote(net, "FishingCompleted")
        -- fish caught event (optional)
        local fishCaughtRemote = findRemote(net, "RE/FishCaught") or (findRemote(net, "RE") and findRemote(net, "RE"):FindFirstChild("FishCaught"))

        if not equipRemote or not chargeRemote or not startMiniRemote or not completeRemote then
            warn("AutoFish: one or more remotes not found. equip/charge/startMini/complete required.")
            autoFishRunning = false
            return
        end

        -- helper to cast sequence safely
        local function castSequence()
            if not state.AutoFish then return end
            pcall(function()
                playCastAnim()
                -- equip
                remoteCall(equipRemote, 1)
                task.wait(0.10)

                -- perfect charge
                if chargeRemote then
                    -- prefer RemoteFunction invoke if available
                    if chargeRemote:IsA("RemoteFunction") then
                        pcall(chargeRemote.InvokeServer, chargeRemote, serverTime())
                    else
                        remoteCall(chargeRemote, serverTime())
                    end
                end
                task.wait(0.10)

                -- start minigame
                remoteCall(startMiniRemote, -0.75, 1)
                task.wait(0.20)

                -- attempt to complete a few times to increase reliability on weaker executors/servers
                for i = 1, 20 do
                    if not state.AutoFish then break end
                    remoteCall(completeRemote)
                    task.wait(0.05)
                end
            end)
        end

        -- Main loop
        while state.AutoFish and autoFishRunning do
            castSequence()
            -- wait 1.4 seconds between casts (precise)
            local t0 = os.clock()
            while (os.clock() - t0) < 1.4 and state.AutoFish and autoFishRunning do
                task.wait()
            end
        end

        autoFishRunning = false
    end)
end

local function stopAutoFish()
    state.AutoFish = false
    autoFishRunning = false
end

-- =========================
-- TELEPORT BUTTONS (as requested)
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
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Sit = false end
    if hrp then
        -- nudge up a bit to reduce anti-teleport snapping
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        task.wait(0.08)
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    end
end

-- =========================
-- RAYFIELD UI (Main + Teleport tabs)
-- =========================
local Window = Rayfield:CreateWindow({
    Name = "FishIt Lite",
    LoadingTitle = "FishIt Lite",
    LoadingSubtitle = "Rayfield Edition",
    KeySystem = false
})

local Main = Window:CreateTab("Main", 4483362458)
local TP = Window:CreateTab("Teleport", 4483362458)

-- Status Label
local statusLabel = Main:CreateLabel("Status: Idle")

local function updateStatus()
    local s = ("AutoFish: %s | AutoFav: %s | AutoSell: %s")
        :format((state.AutoFish and "ON" or "OFF"),
                (state.AutoFavourite and "ON" or "OFF"),
                (state.AutoSell and "ON" or "OFF"))
    statusLabel:Set(s)
end

-- Main toggles
Main:CreateToggle({
    Name = "Auto Fish V3 (Perfect Cast, 1.4s)",
    CurrentValue = false,
    Callback = function(v)
        state.AutoFish = v
        if v then startAutoFish() else stopAutoFish() end
        updateStatus()
    end
})

Main:CreateToggle({
    Name = "Auto Favourite (All Fish)",
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

-- Teleport buttons tab
for _, loc in ipairs(island_locations) do
    TP:CreateButton({
        Name = loc.Name,
        Callback = (function(pos)
            return function()
                teleportTo(pos)
            end
        end)(loc.Position)
    })
end

updateStatus()
