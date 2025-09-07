-- 34_rayfield_fixed.lua
-- Cleaned and fixed version of the original script
-- Keeps only: Auto-Fish, Fish Notification (Discord webhook), Auto-Farm, Trade
-- Replaces WindUI with Rayfield UI
-- NOTE: Some remote names / paths in your specific game may differ. Adjust the remote names below if needed.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ====== Configuration / Remote detection ======
-- Try to find common remote objects; if your game's names differ, change them here.
local Remotes = {
    CastRemote = ReplicatedStorage:FindFirstChild("CastRod") or ReplicatedStorage:FindFirstChild("Cast") or ReplicatedStorage:FindFirstChild("Fishing") or ReplicatedStorage:FindFirstChild("RemoteCast"),
    ReelRemote = ReplicatedStorage:FindFirstChild("ReelRod") or ReplicatedStorage:FindFirstChild("Reel") or ReplicatedStorage:FindFirstChild("RemoteReel"),
    SellRemote = ReplicatedStorage:FindFirstChild("SellAll") or ReplicatedStorage:FindFirstChild("SellFish"),
    TradeRemote = ReplicatedStorage:FindFirstChild("TradeRequest") or ReplicatedStorage:FindFirstChild("TradeRemote"),
}

-- Fallbacks are allowed; the script will check before firing.

-- ====== Utility functions ======
local function safeFire(remote, ...)
    if remote and typeof(remote.FireServer) == "function" then
        pcall(function() remote:FireServer(...) end)
        return true
    end
    return false
end

local function notify(title, text)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = text,
            Duration = 4,
            Image = 281205310 -- optional small asset id
        })
    end)
end

-- ====== Rayfield UI loading ======
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/master/source'))()

local window = Rayfield:CreateWindow({
    Name = "Fish It Premium - Clean",
    LoadingTitle = "Fish It Premium",
    LoadingSubtitle = "Cleaned | Rayfield GUI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FishItPremium_Clean", -- Create a folder for configs
        FileName = "config"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Tabs
local autoFishTab = window:CreateTab("Auto-Fish")
local autoFarmTab = window:CreateTab("Auto-Farm")
local tradeTab = window:CreateTab("Trade")
local notifTab = window:CreateTab("Fish Notification")
local settingsTab = window:CreateTab("Settings")

-- ====== State ======
local state = {
    AutoFish = false,
    AutoFishDelay = 1.2, -- seconds between casts (adjustable)
    AutoFarm = false,
    FarmIsland = "Closest",
    AutoSellThreshold = 30, -- sell when inventory reaches this
    TradeTarget = nil,
    AutoTradeOnClick = false,
    Webhook = "", -- discord webhook url
    NotifyFish = false,
}

-- ====== Auto-Fish Implementation ======
local function attemptCast()
    -- Example generic cast: many games use :FireServer("Cast", position)
    -- As a safe generic attempt, try a few common remote signatures.
    if Remotes.CastRemote then
        -- Common pattern: FireServer(Vector3) or FireServer("Cast")
        pcall(function()
            safeFire(Remotes.CastRemote, "Cast")
        end)
    else
        -- Try to emulate click: look for a Tool named "Rod" and activate it
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
            end
        end
    end
end

local function attemptReel()
    if Remotes.ReelRemote then
        pcall(function()
            safeFire(Remotes.ReelRemote, "Reel")
        end)
    else
        -- try to simulate unequipping or activating again
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
            end
        end
    end
end

local lastCast = 0

spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if state.AutoFish then
            local now = tick()
            if now - lastCast >= state.AutoFishDelay then
                lastCast = now
                attemptCast()
                -- Wait for bite — many games send a Remote back; we can't reliably wait for that
                -- Use a simple delay then reel
                wait(math.clamp(state.AutoFishDelay * 0.9, 0.5, 5))
                attemptReel()
            end
        else
            wait(0.2)
        end
    end
end)

-- ====== Auto-Sell (basic) ======
local function sellAll()
    if Remotes.SellRemote then
        pcall(function() Remotes.SellRemote:FireServer() end)
    else
        -- Attempt to find a Sell NPC and touch it; this is game dependent — left as a no-op fallback
        -- Notify the user to adjust SellRemote variable.
        notify("Sell Failed", "Sell remote not detected. Please set Remotes.SellRemote path in script.")
    end
end

-- Auto-sell loop when farming inventory threshold reached
spawn(function()
    while true do
        RunService.Stepped:Wait()
        if state.AutoFarm then
            -- Basic inventory check: count Tools/Folder in Backpack or a PlayerGui folder named 'Inventory'
            local count = 0
            if LocalPlayer.Backpack then count = count + #LocalPlayer.Backpack:GetChildren() end
            if LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:IsA("Folder") then
                count = count + #LocalPlayer.Inventory:GetChildren()
            end
            if count >= state.AutoSellThreshold then
                sellAll()
                wait(1)
            end
        else
            wait(0.5)
        end
    end
end)

-- ====== Auto-Farm Implementation ======
-- Simple teleporter to predefined islands. Coordinates should be adjusted for your game.
local islands = {
    {Name = "Closest", CFrame = nil},
    {Name = "Tropical", CFrame = CFrame.new(100, 5, -50)},
    {Name = "Crater", CFrame = CFrame.new(-200, 10, 75)},
    {Name = "Ice", CFrame = CFrame.new(300, 8, 330)},
}

local function teleportTo(cframe)
    if not cframe then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        pcall(function()
            hrp.CFrame = cframe
        end)
    end
end

spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if state.AutoFarm then
            -- Teleport to selected island and enable AutoFish
            local chosen = islands[1]
            for _,v in pairs(islands) do
                if v.Name == state.FarmIsland then chosen = v; break end
            end
            if chosen and chosen.CFrame then
                teleportTo(chosen.CFrame)
            end
            -- Ensure AutoFish is enabled while farming
            state.AutoFish = true
            wait(2)
        else
            wait(0.5)
        end
    end
end)

-- ====== Trade Implementation (basic) ======
local function sendTradeTo(playerName)
    local target = Players:FindFirstChild(playerName)
    if not target then
        -- try to find by display name
        for _,p in pairs(Players:GetPlayers()) do
            if p.DisplayName == playerName then target = p; break end
        end
    end
    if not target then
        notify("Trade", "Target player not found: "..tostring(playerName))
        return
    end
    if Remotes.TradeRemote then
        pcall(function() Remotes.TradeRemote:FireServer(target) end)
        notify("Trade", "Trade request sent to "..target.Name)
    else
        notify("Trade", "Trade remote not detected. Please set Remotes.TradeRemote in script.")
    end
end

-- Optionally auto-accept trades if the game exposes a remote; not implemented by default for safety.

-- ====== Fish Notification (Discord webhook) ======
local function sendDiscordWebhook(webhookUrl, content, embed)
    if not webhookUrl or webhookUrl == "" then return end
    local data = {content = content}
    if embed then data.embeds = {embed} end
    local ok, err = pcall(function()
        HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
    if not ok then
        notify("Webhook Error", tostring(err))
    end
end

-- Example: Hook into a generic "FishCaught" remote if present
-- If your game has a remote that fires when you catch a fish, link it here.
local FishCaughtRemote = ReplicatedStorage:FindFirstChild("FishCaught") or ReplicatedStorage:FindFirstChild("OnFishCaught")
if FishCaughtRemote and FishCaughtRemote:IsA("RemoteEvent") then
    FishCaughtRemote.OnClientEvent:Connect(function(data)
        if state.NotifyFish and state.Webhook ~= "" then
            local fishName = tostring(data and data.Name or "Unknown Fish")
            local embed = {
                title = "Fish Caught: "..fishName,
                description = "Player: "..LocalPlayer.Name,
                fields = {{name = "Details", value = HttpService:JSONEncode(data or {})}},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
            sendDiscordWebhook(state.Webhook, nil, embed)
        end
    end)
end

-- If no such remote is found, we provide a helper for manual notify when the script detects large catches via other means.

-- ====== Rayfield UI Elements ======
-- Auto-Fish Tab
local afSection = autoFishTab:CreateSection("Auto-Fish Controls")

autoFishTab:CreateToggle({
    Name = "Enable Auto-Fish",
    CurrentValue = state.AutoFish,
    Flag = "AutoFishToggle",
    Callback = function(val)
        state.AutoFish = val
    end
})

autoFishTab:CreateSlider({
    Name = "Delay Between Casts (s)",
    Range = {0.3, 8},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = state.AutoFishDelay,
    Flag = "AutoFishDelay",
    Callback = function(val)
        state.AutoFishDelay = val
    end
})

autoFishTab:CreateButton({
    Name = "Manual Cast",
    Callback = function()
        attemptCast()
        wait(0.8)
        attemptReel()
    end
})

autoFishTab:CreateButton({
    Name = "Sell All Now",
    Callback = function()
        sellAll()
    end
})

-- Auto-Farm Tab
autoFarmTab:CreateToggle({
    Name = "Enable Auto-Farm",
    CurrentValue = state.AutoFarm,
    Callback = function(val)
        state.AutoFarm = val
    end
})

autoFarmTab:CreateDropdown({
    Name = "Select Farm Island",
    Options = (function() local t = {} for _,v in pairs(islands) do table.insert(t, v.Name) end; return t end)(),
    CurrentOption = state.FarmIsland,
    Callback = function(option)
        state.FarmIsland = option
    end
})

autoFarmTab:CreateSlider({
    Name = "AutoSell Inventory Threshold",
    Range = {5, 200},
    Increment = 1,
    CurrentValue = state.AutoSellThreshold,
    Callback = function(val)
        state.AutoSellThreshold = val
    end
})

-- Trade Tab
tradeTab:CreateTextBox({
    Name = "Trade Target Player",
    PlaceholderText = "PlayerName",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        state.TradeTarget = text
    end
})

tradeTab:CreateToggle({
    Name = "Auto Trade On Click (Send Request)",
    CurrentValue = state.AutoTradeOnClick,
    Callback = function(val)
        state.AutoTradeOnClick = val
    end
})

tradeTab:CreateButton({
    Name = "Send Trade Request Now",
    Callback = function()
        if state.TradeTarget and state.TradeTarget ~= "" then
            sendTradeTo(state.TradeTarget)
        else
            notify("Trade", "No target specified")
        end
    end
})

-- Fish Notification Tab
notifTab:CreateInput({
    Name = "Discord Webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        state.Webhook = text
    end
})

notifTab:CreateToggle({
    Name = "Enable Fish Webhook Notifications",
    CurrentValue = state.NotifyFish,
    Callback = function(val)
        state.NotifyFish = val
    end
})

notifTab:CreateButton({
    Name = "Test Webhook Notification",
    Callback = function()
        if state.Webhook == "" then
            notify("Webhook", "Please enter a webhook URL first.")
            return
        end
        sendDiscordWebhook(state.Webhook, "Test notification from Fish It Premium (clean)")
        notify("Webhook", "Test sent (if URL is valid).")
    end
})

-- Settings Tab
settingsTab:CreateButton({
    Name = "Open Config Folder",
    Callback = function()
        notify("Config", "Configs are saved automatically in the Roblox folder under Rayfield settings.")
    end
})

settingsTab:CreateParagraph({
    Title = "Notes",
    Content = "This cleaned script keeps only Auto-Fish, Auto-Farm, Trade and Fish Notification features.\nIf remotes or object names differ in your game, edit the Remotes table at the top of the script.\nUse responsibly."
})

-- ====== Safety and Final Notices ======
notify("Ready", "Cleaned script loaded. Only Auto-Fish, Auto-Farm, Trade & Fish Notif enabled.")

-- End of script
