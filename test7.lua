------------------------------------------
----- =======[ Load WindUI ]
-------------------------------------------

local Version = "1.6.45"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"))()

-------------------------------------------
----- =======[ GLOBAL & CORE FUNCTIONS ]
-------------------------------------------

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

-- Initialize controllers and utilities
local FishingController = safeRequire({"Controllers","FishingController"})
local AnimationController = safeRequire({"Controllers","AnimationController"})
local Replion = safeRequire({"Packages","Replion"}) or safeRequire({"Packages","replion"})
local ItemUtility = safeRequire({"Shared","ItemUtility"})

-- Net folder helper
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
-- STATE MANAGEMENT
-- =========================
local state = {
    AutoFish = false,
    AutoFavourite = false,
    AutoSell = false,
    AutoWeather = false,
    SelectedWeathers = {},
}
local lastFarmPosition = nil 
local lastCatchTimestamp = 0
local respawnTimerLoop = nil
local autoWeatherLoop

-- Include Epic, Legendary, Mythic, Secret fish
local allowedTiers = { [4]=true, [5]=true, [6]=true, [7]=true }

-------------------------------------------
----- =======[ NOTIFY FUNCTION ]
-------------------------------------------

local function NotifySuccess(title, message, duration)
    WindUI:Notify({ Title = title, Content = message, Duration = duration or 5, Icon = "circle-check" })
end

local function NotifyError(title, message, duration)
    WindUI:Notify({ Title = title, Content = message, Duration = duration or 5, Icon = "ban" })
end

local function NotifyInfo(title, message, duration)
    WindUI:Notify({ Title = title, Content = message, Duration = duration or 5, Icon = "info" })
end

local function NotifyWarning(title, message, duration)
    WindUI:Notify({ Title = title, Content = message, Duration = duration or 5, Icon = "triangle-alert" })
end

-- =========================
-- CORE FEATURE FUNCTIONS
-- =========================

local function stopAutoWeather()
    if autoWeatherLoop then task.cancel(autoWeatherLoop); autoWeatherLoop = nil end
end

local function startAutoWeather()
    if autoWeatherLoop then stopAutoWeather() end

    autoWeatherLoop = task.spawn(function()
        local net = getNetFolder()
        if not net then
            NotifyError("Auto Weather", "Could not find the game's network folder.")
            return 
        end
        local weatherRemote = net:FindFirstChild("RF/PurchaseWeatherEvent")
        if not weatherRemote then
            NotifyError("Auto Weather", "Could not find 'RF/PurchaseWeatherEvent' remote.")
            return
        end
        
        NotifySuccess("Auto Weather", "System is now active and detecting weather via UI.")

        while state.AutoWeather do
            pcall(function()
                -- DETECT WEATHER VIA UI: Look for the on-screen weather display.
                local weatherGui = player.PlayerGui:FindFirstChild("Weather")
                local isWeatherActiveOnScreen = weatherGui and weatherGui.Enabled and weatherGui:FindFirstChild("Display") and weatherGui.Display.Visible

                if not isWeatherActiveOnScreen and #state.SelectedWeathers > 0 then
                    NotifyInfo("Auto Weather", "No active weather UI detected. Activating a new one...")
                    local chosenWeather = state.SelectedWeathers[math.random(1, #state.SelectedWeathers)]
                    
                    weatherRemote:InvokeServer(chosenWeather)
                    
                    -- Wait for a few seconds after activating to give the UI time to appear.
                    task.wait(5) 
                end
            end)
            task.wait(1) -- Check every second
        end
    end)
end

local function activateFpsBoost()
    if fpsBoostActive then return end 
    pcall(function()
        for _, v in pairs(game:GetDescendants()) do
			if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0
			elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
		end
		local Lighting = game:GetService("Lighting")
		for _, effect in pairs(Lighting:GetChildren()) do if effect:IsA("PostEffect") then effect.Enabled = false end end
		Lighting.GlobalShadows = false; Lighting.FogEnd = 1e10; settings().Rendering.QualityLevel = "Level01"
    end)
    NotifyInfo("Performance", "FPS Boost activated for smooth farming."); fpsBoostActive = true
end

local function startAutoFavourite()
    task.spawn(function()
        while state.AutoFavourite do
            pcall(function()
                if not Replion or not ItemUtility then return end
                local favoriteRemote = getNetFolder() and getNetFolder():FindFirstChild("RE/FavoriteItem")
                if not favoriteRemote then return end
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) ~= "table" then return end
                for _, item in ipairs(items) do
                    local base = ItemUtility:GetItemData(item.Id)
                    if base and base.Data and allowedTiers[base.Data.Tier] and not item.Favorited then
                        favoriteRemote:FireServer(item.UUID); item.Favorited = true
                    end
                end
            end); task.wait(5)
        end
    end)
end

local function startAutoSell()
    task.spawn(function()
        while state.AutoSell do
            pcall(function()
                if not Replion then return end
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) ~= "table" then return end
                local unfavoritedCount = 0
                for _, item in ipairs(items) do if not item.Favorited then unfavoritedCount = unfavoritedCount + (item.Count or 1) end end
                if unfavoritedCount >= 60 and os.time() - (lastSellTime or 0) >= 60 then
                    local sellFunc = getNetFolder() and getNetFolder():FindFirstChild("RF/SellAllItems")
                    if sellFunc then task.spawn(sellFunc.InvokeServer, sellFunc); lastSellTime = os.time() end
                end
            end); task.wait(10)
        end
    end)
end

local autoFishLoop
local function startAutoFish()
    activateFpsBoost() 
    if autoFishLoop then task.cancel(autoFishLoop) end
    if respawnTimerLoop then task.cancel(respawnTimerLoop) end
    lastCatchTimestamp = os.time()
    respawnTimerLoop = task.spawn(function()
        while state.AutoFish do
            if os.time() - lastCatchTimestamp > 60 then
                NotifyWarning("Anti-Stuck Triggered", "Resetting character...")
                if player.Character then player.Character:BreakJoints() end
                lastCatchTimestamp = os.time() 
            end; task.wait(1)
        end
    end)
    autoFishLoop = task.spawn(function()
        local net = getNetFolder(); if not net then return end
        local equipEvent, chargeFunc, startMini, complete = net:WaitForChild("RE/EquipToolFromHotbar"), net:WaitForChild("RF/ChargeFishingRod"), net:WaitForChild("RF/RequestFishingMinigameStarted"), net:WaitForChild("RE/FishingCompleted")
        while state.AutoFish do
            if FishingController and FishingController.OnCooldown and FishingController:OnCooldown() then repeat task.wait(0.2) until not (FishingController:OnCooldown()) or not state.AutoFish end
            if not state.AutoFish then break end
            pcall(function()
                if AnimationController and AnimationController.PlayAnimation then AnimationController:PlayAnimation("CastFromFullChargePosition1Hand") end
                equipEvent:FireServer(1); task.wait(0.1)
                chargeFunc:InvokeServer(workspace:GetServerTimeNow()); task.wait(0.1)
                startMini:InvokeServer(-0.75, 1)
                if AnimationController and AnimationController.PlayAnimation then AnimationController:PlayAnimation("Reel") end
                task.wait(0.2)
                for i=1,20 do complete:FireServer(); task.wait(0.05) end
            end)
            local t = os.clock(); while os.clock() - t < 0.7 and state.AutoFish do task.wait() end
        end
    end)
end

local function stopAutoFish()
    if autoFishLoop then task.cancel(autoFishLoop); autoFishLoop = nil end
    if respawnTimerLoop then task.cancel(respawnTimerLoop); respawnTimerLoop = nil end
end

local function teleportTo(posList)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    if hrp then hrp.CFrame = (typeof(posList) == "table") and posList[math.random(1, #posList)] or posList end
end

player.CharacterAdded:Connect(function(character)
    task.wait(2)
    if state.AutoFish and lastFarmPosition then NotifyInfo("Respawn Detected", "Returning to last farm location..."); teleportTo(lastFarmPosition) end
end)


-------------------------------------------
----- =======[ LOAD WINDOW ]
-------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "e-Fishery V2.0", Author = "by Zee (WindUI Edition)", Folder = "e-Fishery",
    Size = UDim2.fromOffset(600, 520), Transparent = true, Theme = "Dark", ScrollBarEnabled = true, HideSearchBar = true,
    User = { Enabled = true, Anonymous = false, Callback = function() end }
})

Window:EditOpenButton({
    Title = "e-Fishery", Icon = "shrimp", CornerRadius = UDim.new(0,19), StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("9600FF"), Color3.fromHex("AEBAF8")), Draggable = true,
})

Window:Tag({ Title = "STABLE", Color = Color3.fromHex("#30ff6a") }); WindUI:SetNotificationLower(true)

-------------------------------------------
----- =======[ ALL TABS ]
-------------------------------------------

local Home = Window:Tab({ Title = "Developer Info", Icon = "hard-drive" })
local Main = Window:Tab({ Title = "Main", Icon = "toggle-right" })
local AutoFarm = Window:Tab({ Title = "Auto Farm", Icon = "map" })
local FishNotif = Window:Tab({ Title = "Fish Notification", Icon = "bell-ring" })

-------------------------------------------
----- =======[ HOME / DEVELOPER INFO TAB ]
-------------------------------------------

local function LookupDiscordInvite(inviteCode)
    local s, r = pcall(game.HttpGet, game, "https://discord.com/api/v10/invites/" .. inviteCode .. "?with_counts=true")
    if s then local data = HttpService:JSONDecode(r); return { name = data.guild and data.guild.name, online = data.approximate_presence_count, members = data.approximate_member_count, icon = data.guild and data.guild.icon and "https://cdn.discordapp.com/icons/"..data.guild.id.."/"..data.guild.icon..".png" } end
end
local inviteData = LookupDiscordInvite("UyscFN7q7J")
if inviteData then Home:Paragraph({ Title = string.format("[DISCORD] %s", inviteData.name or "Unknown"), Desc = string.format("Members: %d\nOnline: %d", inviteData.members or 0, inviteData.online or 0), Image = inviteData.icon or "", ImageSize = 50, Locked = true }) end

-------------------------------------------
----- =======[ CONFIG & SAVE/LOAD SYSTEM ]
-------------------------------------------
local savedData = { webhookUrl = "", autoFish = false, autoFavourite = false, autoSell = false, webhookCategories = {"Secret"}, lastFarmPosition = nil, autoWeather = false, selectedWeathers = {} }
local file_name = "e_fishery_session.json"
local webhookUrl, SelectedCategories

local function saveConfig()
    if writefile then
        savedData.webhookUrl, savedData.autoFish, savedData.autoFavourite, savedData.autoSell = webhookUrl, state.AutoFish, state.AutoFavourite, state.AutoSell
        savedData.webhookCategories, savedData.lastFarmPosition, savedData.autoWeather, savedData.selectedWeathers = SelectedCategories, lastFarmPosition, state.AutoWeather, state.SelectedWeathers
        writefile(file_name, HttpService:JSONEncode(savedData))
    end
end
local function loadConfig()
    if isfile and isfile(file_name) then
        local s, data = pcall(function() return HttpService:JSONDecode(readfile(file_name)) end)
        if s and type(data) == "table" then for k, v in pairs(data) do savedData[k] = v end end
    end
    webhookUrl, SelectedCategories, lastFarmPosition = savedData.webhookUrl, savedData.webhookCategories, savedData.lastFarmPosition
end

-------------------------------------------
----- =======[ MAIN TAB ]
-------------------------------------------

local autoFishToggle, autoFavouriteToggle, autoSellToggle, mainWeatherToggle, weatherDropdown

autoFishToggle = Main:Toggle({ Title = "Auto Fish", Callback = function(v) state.AutoFish = v; if v then startAutoFish() else stopAutoFish() end; saveConfig() end })
autoFavouriteToggle = Main:Toggle({ Title = "Auto Favourite", Callback = function(v) state.AutoFavourite = v; if v then startAutoFavourite() end; saveConfig() end })
autoSellToggle = Main:Toggle({ Title = "Auto Sell", Callback = function(v) state.AutoSell = v; if v then startAutoSell() end; saveConfig() end })

Main:Divider()

mainWeatherToggle = Main:Toggle({
    Title = "Enable Auto Weather", Desc = "Uses the most reliable UI detection method.",
    Callback = function(v) state.AutoWeather = v; if v then startAutoWeather() else stopAutoWeather() end; saveConfig() end
})
weatherDropdown = Main:Dropdown({
    Title = "Select Weather to Use", Desc = "Check boxes for weathers you want in the rotation.",
    Values = {"Cloudy", "Windy", "Storm", "Radiant"}, Multi = true, AllowNone = true,
    Callback = function(selected) state.SelectedWeathers = selected; saveConfig() end
})

-------------------------------------------
----- =======[ AUTO FARM TAB ]
-------------------------------------------
local island_locations = {
    ["Crater Islands"] = { CFrame.new(1066.18, 57.20, 5045.55, -0.68, 0, 0.73, 0, 1, 0, -0.73, 0, -0.68), CFrame.new(1057.28, 33.08, 5133.79, 0.83, 0, 0.55, 0, 1, 0, -0.55, 0, 0.83) },
    ["Tropical Grove"] = { CFrame.new(-2165.05, 2.77, 3639.87, -0.58, 0, -0.80, 0, 1, 0, 0.80, 0, -0.58) }, ["Vulcano"] = { CFrame.new(-701.44, 48.14, 93.15, -0.07, 0, -0.99, 0, 1, 0, 0.99, 0, -0.07) },
    ["Coral Reefs"] = { CFrame.new(-3118.39, 2.42, 2135.26, 0.92, 0, -0.38, 0, 1, 0, 0.38, 0, 0.92) }, ["Winter"] = { CFrame.new(2036.15, 6.54, 3381.88, 0.94, 0, -0.33, 0, 1, 0, 0.33, 0, 0.94) },
    ["Machine"] = { CFrame.new(-1459.37, 14.71, 1831.51, 0.77, 0, -0.62, 0, 1, 0, 0.62, 0, 0.77) }, ["Treasure Room"] = { CFrame.new(-3625.07, -279.07, -1594.57, 0.91, 0, -0.39, 0, 1, 0, 0.39, 0, 0.91) },
    ["Sisyphus Statue"] = { CFrame.new(-3777.43, -135.07, -975.19, -0.28, 0, -0.95, 0, 1, 0, 0.95, 0, -0.28) }, ["Fisherman Island"] = { CFrame.new(-75.24, 3.24, 3103.45, -0.99, 0, -0.08, 0, 1, 0, 0.08, 0, -0.99) }
}
for name, pos in pairs(island_locations) do AutoFarm:Button({ Title = name, Callback = function() lastFarmPosition = pos; teleportTo(pos); task.wait(0.8); state.AutoFish = true; startAutoFish(); if autoFishToggle then autoFishToggle:Set(true) end; saveConfig() end }) end

-------------------------------------------
----- =======[ FISH NOTIF TAB ]
-------------------------------------------
local categoriesDropdown
FishNotif:Paragraph({ Title = "Fish Notification", Color = "Green", Desc = [[Sends a notification to Discord when you catch a rare fish.]] })

local function validateWebhook(url)
    if not url or url == "" then return false, "URL is empty" end
    if not url:match("^https://discord.com/api/webhooks/%d+/.+") then return false, "Invalid URL format." end
    local s, r = pcall(game.HttpGet, game, url); if not s then return false, "Failed to connect" end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, r); if not ok or not data or not data.channel_id then return false, "Invalid" end
    return true, data.channel_id
end

FishNotif:Input({ Title = "Webhook URL", Desc = "Paste your full Discord webhook URL here.", Placeholder = "https://discord.com/api/webhooks/...", Default = savedData.webhookUrl,
    Callback = function(text)
        if text == "" then webhookUrl = nil; saveConfig(); NotifyInfo("Webhook Cleared", "Notifications disabled."); return end
        local isValid, result = validateWebhook(text)
        if isValid then webhookUrl = text; saveConfig(); NotifySuccess("Webhook Set", "Channel ID: "..tostring(result)) else webhookUrl = nil; NotifyError("URL Invalid", tostring(result)) end
    end
})

local FishDataById, VariantsByName = {}, {}; local rarityMap = { [1]="Common", [2]="Uncommon", [3]="Rare", [4]="Epic", [5]="Legendary", [6]="Mythic", [7]="Secret" }
pcall(function()
    for _, item in ipairs(ReplicatedStorage.Items:GetChildren()) do local ok, d = pcall(require, item); if ok and d.Data and d.Data.Type == "Fishes" then FishDataById[d.Data.Id] = { Name=d.Data.Name, SellPrice=d.SellPrice or 0, Tier=d.Data.Tier, Icon=d.IconId or d.Data.Icon or "" } end end
    for _, v in ipairs(ReplicatedStorage.Variants:GetChildren()) do local ok, d = pcall(require, v); if ok and d.Data and d.Data.Type == "Variant" then VariantsByName[d.Data.Name] = d.SellMultiplier or 1 end end
end)

categoriesDropdown = FishNotif:Dropdown({ Title = "Select Fish Categories", Desc = "Choose categories to send to webhook", Values = {"Secret", "Legendary", "Mythic", "Epic"}, Multi = true, Default = {"Secret"}, Callback = function(selected) SelectedCategories = selected; saveConfig() end })

local function GetRobloxImage(assetId)
    local s, r = pcall(game.HttpGet, game, "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&size=420x420&format=Png&isCircular=false")
    if s then local data = HttpService:JSONDecode(r); if data and data.data and data.data[1] then return data.data[1].imageUrl end end
end

local function sendFishWebhook(fishName, rarityText, assetId, itemId, variantId)
    if not webhookUrl or webhookUrl == "" then return end
    local username, imageUrl = player.DisplayName, GetRobloxImage(assetId); if not imageUrl then return end
    local caught, rarest = player:FindFirstChild("leaderstats") and player.leaderstats.Caught, player:FindFirstChild("leaderstats") and player.leaderstats["Rarest Fish"]
    local basePrice = (FishDataById[itemId] and FishDataById[itemId].SellPrice or 0) * (VariantsByName[variantId] or 1)
    local data = { username = "e-Fishery", embeds = {{ title = "Fish Caught!", description = string.format("Player **%s** caught a **%s** (%s)!", username, fishName, rarityText), color = tonumber("0x00bfff"), image = { url = imageUrl },
        fields = { { name = "Sell Price", value = tostring(basePrice), inline = true}, { name = "Total Caught", value = tostring(caught and caught.Value or "N/A"), inline = true}, { name = "Rarest Fish", value = tostring(rarest and rarest.Value or "N/A"), inline = true} },
        footer = { text = "e-Fishery Notifier | " .. os.date("%I:%M:%S %p", os.time()) } }} }
    local requestFunc = syn and syn.request or http and http.request or http_request or request or fluxus and fluxus.request
    if requestFunc then requestFunc({ Url = webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(data) }) end
end

local REObtainedNewFishNotification = getNetFolder() and getNetFolder():FindFirstChild("RE/ObtainedNewFishNotification")
if REObtainedNewFishNotification then
    REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, eventData)
        lastCatchTimestamp = os.time()
        if not webhookUrl or webhookUrl == "" then return end
        pcall(function()
            local fishInfo = FishDataById[itemId]; if not fishInfo then return end
            local rarityName = rarityMap[fishInfo.Tier] or "Unknown"
            local isTarget = false; for _, category in pairs(SelectedCategories) do if string.lower(category) == string.lower(rarityName) then isTarget = true; break end end
            if isTarget then
                local assetId = string.match(fishInfo.Icon or "", "%d+"); if not assetId then return end
                local variantId = eventData and eventData.InventoryItem and eventData.InventoryItem.Metadata and eventData.InventoryItem.Metadata.VariantId
                sendFishWebhook(fishInfo.Name, rarityName, assetId, itemId, variantId)
            end
        end)
    end)
end

-------------------------------------------
----- =======[ INITIALIZE AND RESTORE SESSION ]
-------------------------------------------

local function applyLoadedState()
    if categoriesDropdown and savedData.webhookCategories then categoriesDropdown:Set(savedData.webhookCategories) end
    if savedData.autoFavourite then state.AutoFavourite = true; autoFavouriteToggle:Set(true) end
    if savedData.autoSell then state.AutoSell = true; autoSellToggle:Set(true) end

    if weatherDropdown and savedData.selectedWeathers then weatherDropdown:Set(savedData.selectedWeathers); state.SelectedWeathers = savedData.selectedWeathers end
    if savedData.autoWeather and mainWeatherToggle then state.AutoWeather = true; mainWeatherToggle:Set(true) end
    
    if savedData.autoFish and savedData.lastFarmPosition then
        NotifyInfo("Session Restored", "Returning to last farm location...")
        teleportTo(savedData.lastFarmPosition); task.wait(1.5)
        state.AutoFish = true; autoFishToggle:Set(true)
    elseif savedData.autoFish then
         state.AutoFish = true; autoFishToggle:Set(true)
    end
end

loadConfig()
applyLoadedState()
