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

-- Safe require helper from Rayfield version
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

-- Net folder helper from Rayfield version
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
-- FPS BOOST FUNCTION
-- =========================
local fpsBoostActive = false
local function activateFpsBoost()
    if fpsBoostActive then return end 

    pcall(function()
        for _, v in pairs(game:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Material = Enum.Material.SmoothPlastic
				v.Reflectance = 0
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 1
			end
		end

		local Lighting = game:GetService("Lighting")
		for _, effect in pairs(Lighting:GetChildren()) do
			if effect:IsA("PostEffect") then
				effect.Enabled = false
			end
		end

		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e10
		settings().Rendering.QualityLevel = "Level01"
    end)
    
    NotifyInfo("Performance", "FPS Boost activated for smooth farming.")
    fpsBoostActive = true
end


-- =========================
-- AUTO FAVOURITE
-- =========================
local function startAutoFavourite()
    task.spawn(function()
        while state.AutoFavourite do
            pcall(function()
                if not Replion or not ItemUtility then return end
                local netFolder = getNetFolder()
                local favoriteRemote = netFolder and netFolder:FindFirstChild("RE/FavoriteItem")
                if not favoriteRemote then return end

                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) ~= "table" then return end
                for _, item in ipairs(items) do
                    local base = ItemUtility:GetItemData(item.Id)
                    if base and base.Data and allowedTiers[base.Data.Tier] and not item.Favorited then
                        favoriteRemote:FireServer(item.UUID)
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
local lastSellTime = 0
local AUTO_SELL_THRESHOLD = 60
local AUTO_SELL_DELAY = 60 

local function startAutoSell()
    task.spawn(function()
        while state.AutoSell do
            pcall(function()
                if not Replion then return end
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) ~= "table" then return end

                local unfavoritedCount = 0
                for _, item in ipairs(items) do
                    if not item.Favorited then
                        unfavoritedCount = unfavoritedCount + (item.Count or 1)
                    end
                end

                if unfavoritedCount >= AUTO_SELL_THRESHOLD and os.time() - lastSellTime >= AUTO_SELL_DELAY then
                    local netFolder = getNetFolder()
                    if netFolder then
                        local sellFunc = netFolder:FindFirstChild("RF/SellAllItems")
                        if sellFunc then
                            task.spawn(sellFunc.InvokeServer, sellFunc)
                            lastSellTime = os.time()
                        end
                    end
                end
            end)
            task.wait(10)
        end
    end)
end

-- =========================
-- AUTO FISH V3
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
    activateFpsBoost() 
    if autoFishLoop then task.cancel(autoFishLoop) end
    if respawnTimerLoop then task.cancel(respawnTimerLoop) end

    lastCatchTimestamp = os.time()

    respawnTimerLoop = task.spawn(function()
        while state.AutoFish do
            if os.time() - lastCatchTimestamp > 60 then
                NotifyWarning("Anti-Stuck Triggered", "No fish caught in 1 minute. Resetting character...")
                if player.Character then
                    player.Character:BreakJoints()
                end
                lastCatchTimestamp = os.time() 
            end
            task.wait(1)
        end
    end)

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
                chargeFunc:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.1)
                startMini:InvokeServer(-0.75, 1)

                pcall(function()
                    if AnimationController and AnimationController.PlayAnimation then
                        AnimationController:PlayAnimation("Reel")
                    end
                end)
                task.wait(0.2)
                
                for i=1,20 do
                    complete:FireServer()
                    task.wait(0.05)
                end
            end)

            local t = os.clock()
            while os.clock() - t < 0.7 and state.AutoFish do task.wait() end
        end
    end)
end

local function stopAutoFish()
    if autoFishLoop then task.cancel(autoFishLoop); autoFishLoop = nil end
    if respawnTimerLoop then task.cancel(respawnTimerLoop); respawnTimerLoop = nil end
end

-- =========================
-- TELEPORT FUNCTION
-- =========================
local function teleportTo(posList)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")

    if hrp then
        local chosen
        if typeof(posList) == "table" then
            chosen = posList[math.random(1, #posList)]
        else
            chosen = posList
        end
        hrp.CFrame = chosen
    end
end

-------------------------------------------
----- =======[ RESPAWN HANDLER ]
-------------------------------------------
player.CharacterAdded:Connect(function(character)
    task.wait(2)
    if state.AutoFish and lastFarmPosition then
        NotifyInfo("Respawn Detected", "Returning to last farm location...")
        teleportTo(lastFarmPosition)
    end
end)


-------------------------------------------
----- =======[ LOAD WINDOW ]
-------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "e-Fishery V1.1",
    Icon = "shrimp",
    Author = "by Zee (WindUI Edition)",
    Folder = "e-Fishery",
    Size = UDim2.fromOffset(600, 400),
    Transparent = true,
    Theme = "Dark",
    KeySystem = false,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    }
})

Window:EditOpenButton({
    Title = "e-Fishery",
    Icon = "shrimp",
    CornerRadius = UDim.new(0,19),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("9600FF"), Color3.fromHex("AEBAF8")),
    Draggable = true,
})

Window:Tag({ Title = "STABLE", Color = Color3.fromHex("#30ff6a") })
WindUI:SetNotificationLower(true)

-------------------------------------------
----- =======[ ALL TABS ]
-------------------------------------------

local Home = Window:Tab({ Title = "Developer Info", Icon = "hard-drive" })
local Main = Window:Tab({ Title = "Main", Icon = "toggle-right" })
local AutoFarm = Window:Tab({ Title = "Auto Farm", Icon = "map" })
local FishNotif = Window:Tab({ Title = "Fish Notification", Icon = "bell-ring" })
local Weather = Window:Tab({ Title = "Weather", Icon = "cloud-sun" })

-------------------------------------------
----- =======[ HOME / DEVELOPER INFO TAB ]
-------------------------------------------

local InviteAPI = "https://discord.com/api/v10/invites/"

local function LookupDiscordInvite(inviteCode)
    local url = InviteAPI .. inviteCode .. "?with_counts=true"
    local success, response = pcall(game.HttpGet, game, url)
    if success then
        local data = HttpService:JSONDecode(response)
        return {
            name = data.guild and data.guild.name or "Unknown",
            online = data.approximate_presence_count or 0,
            members = data.approximate_member_count or 0,
            icon = data.guild and data.guild.icon and "https://cdn.discordapp.com/icons/"..data.guild.id.."/"..data.guild.icon..".png" or "",
        }
    end
    return nil
end

local inviteData = LookupDiscordInvite("UyscFN7q7J")
if inviteData then
    Home:Paragraph({
        Title = string.format("[DISCORD] %s", inviteData.name),
        Desc = string.format("Members: %d\nOnline: %d", inviteData.members, inviteData.online),
        Image = inviteData.icon,
        ImageSize = 50,
        Locked = true,
    })
end

-------------------------------------------
----- =======[ CONFIG & SAVE/LOAD SYSTEM ]
-------------------------------------------
local savedData = {
    webhookUrl = "",
    autoFish = false,
    autoFavourite = false,
    autoSell = false,
    webhookCategories = {"Secret"},
    lastFarmPosition = nil,
    autoWeather = false,
    selectedWeathers = {}
}
local file_name = "e_fishery_session.json"
local webhookUrl, SelectedCategories

local function saveConfig()
    if writefile then
        savedData.webhookUrl = webhookUrl
        savedData.autoFish = state.AutoFish
        savedData.autoFavourite = state.AutoFavourite
        savedData.autoSell = state.AutoSell
        savedData.webhookCategories = SelectedCategories
        savedData.lastFarmPosition = lastFarmPosition
        savedData.autoWeather = state.AutoWeather
        savedData.selectedWeathers = state.SelectedWeathers
        writefile(file_name, HttpService:JSONEncode(savedData))
    end
end

local function loadConfig()
    if isfile and isfile(file_name) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(file_name))
        end)
        if success and type(data) == "table" then
            for k, v in pairs(data) do
                savedData[k] = v
            end
        end
    end
    webhookUrl = savedData.webhookUrl
    SelectedCategories = savedData.webhookCategories
    lastFarmPosition = savedData.lastFarmPosition
end

-------------------------------------------
----- =======[ MAIN TAB ]
-------------------------------------------

local autoFishToggle, autoFavouriteToggle, autoSellToggle

autoFishToggle = Main:Toggle({
    Title = "Auto Fish",
    Callback = function(Value)
        state.AutoFish = Value
        if Value then startAutoFish() else stopAutoFish() end
        saveConfig()
    end
})

autoFavouriteToggle = Main:Toggle({
    Title = "Auto Favourite",
    Callback = function(Value)
        state.AutoFavourite = Value
        if Value then startAutoFavourite() end
        saveConfig()
    end
})

autoSellToggle = Main:Toggle({
    Title = "Auto Sell",
    Callback = function(Value)
        state.AutoSell = Value
        if Value then startAutoSell() end
        saveConfig()
    end
})

-------------------------------------------
----- =======[ AUTO FARM TAB ]
-------------------------------------------
local island_locations = {
    ["Crater Islands"] = {
        CFrame.new(1066.1864, 57.2025681, 5045.5542, -0.682534158, 1.00865822e-08, 0.730853677, -5.8900711e-09, 1, -1.93017531e-08, -0.730853677, -1.74788859e-08, -0.682534158),
        CFrame.new(1057.28992, 33.0884132, 5133.79883, 0.833871782, 5.44149223e-08, 0.551958203, -6.58184218e-09, 1, -8.86416984e-08, -0.551958203, 7.02829084e-08, 0.833871782),
    },
    ["Tropical Grove"] = { CFrame.new(-2165.05469, 2.77070165, 3639.87451, -0.589090407, -3.61497356e-08, -0.808067143, -3.20645626e-08, 1, -2.13606164e-08, 0.808067143, 1.3326984e-08, -0.589090407) },
    ["Vulcano"] = { CFrame.new(-701.447937, 48.1446075, 93.1546631, -0.0770962164, 1.34335654e-08, -0.997023642, 9.84464776e-09, 1, 1.27124169e-08, 0.997023642, -8.83526763e-09, -0.0770962164) },
    ["Coral Reefs"] = { CFrame.new(-3118.39624, 2.42531538, 2135.26392, 0.92336154, -1.0069185e-07, -0.383931547, 8.0607947e-08, 1, -6.84016968e-08, 0.383931547, 3.22115596e-08, 0.92336154) },
    ["Winter"] = { CFrame.new(2036.15308, 6.54998732, 3381.88916, 0.943401575, 4.71338666e-08, -0.331652641, -3.28136842e-08, 1, 4.87781051e-08, 0.331652641, -3.51345975e-08, 0.943401575) },
    ["Machine"] = { CFrame.new(-1459.3772, 14.7103214, 1831.5188, 0.777951121, 2.52131862e-08, -0.628324807, -5.24126378e-08, 1, -2.47663063e-08, 0.628324807, 5.21991339e-08, 0.777951121) },
    ["Treasure Room"] = { CFrame.new(-3625.0708, -279.074219, -1594.57605, 0.918176472, -3.97606392e-09, -0.396171629, -1.12946204e-08, 1, -3.62128851e-08, 0.396171629, 3.77244298e-08, 0.918176472) },
    ["Sisyphus Statue"] = { CFrame.new(-3777.43433, -135.074417, -975.198975, -0.284491211, -1.02338751e-08, -0.958678663, 6.38407585e-08, 1, -2.96199456e-08, 0.958678663, -6.96293867e-08, -0.284491211) },
    ["Fisherman Island"] = { CFrame.new(-75.2439423, 3.24433279, 3103.45093, -0.996514142, -3.14880424e-08, -0.0834242329, -3.84156422e-08, 1, 8.14354024e-08, 0.0834242329, 8.43563228e-08, -0.996514142) },
}

for name, pos in pairs(island_locations) do
    AutoFarm:Button({
        Title = name,
        Callback = function()
            lastFarmPosition = pos
            teleportTo(pos)
            task.wait(0.8)
            
            state.AutoFish = true 
            startAutoFish()     

            if autoFishToggle then autoFishToggle:Set(true) end
            saveConfig()
        end
    })
end

-------------------------------------------
----- =======[ FISH NOTIF TAB ]
-------------------------------------------
local categoriesDropdown
FishNotif:Paragraph({
	Title = "Fish Notification",
	Color = "Green",
	Desc = [[This feature sends a notification to Discord when you catch a rare fish. Enter your full webhook URL to connect to your channel.]]
})

local function validateWebhook(url)
	if not url or url == "" then return false, "URL is empty" end
	if not url:match("^https://discord.com/api/webhooks/%d+/.+") then return false, "Invalid Discord webhook URL format." end
	local success, response = pcall(game.HttpGet, game, url)
	if not success then return false, "Failed to connect to Discord" end
	local ok, data = pcall(HttpService.JSONDecode, HttpService, response)
	if not ok or not data or not data.channel_id then return false, "Invalid" end
	return true, data.channel_id
end

FishNotif:Input({
    Title = "Webhook URL",
    Desc = "Paste your full Discord webhook URL here! It will be saved automatically.",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = savedData.webhookUrl,
    Callback = function(text)
        if text == "" then
            webhookUrl = nil
            saveConfig()
            NotifyInfo("Webhook Cleared", "Fish notifications are now disabled.")
            return
        end

        local isValid, result = validateWebhook(text)
        if isValid then
            webhookUrl = text
            saveConfig()
            NotifySuccess("Webhook Set & Saved", "Channel ID: " .. tostring(result) .. ". Fish notifications are active!")
        else
            webhookUrl = nil
            NotifyError("URL Invalid", tostring(result) .. ". Please paste the full, valid URL.")
        end
    end
})

local FishDataById, VariantsByName = {}, {}
local rarityMap = {
    [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic",
    [5] = "Legendary", [6] = "Mythic", [7] = "Secret"
}

pcall(function()
    for _, item in ipairs(ReplicatedStorage.Items:GetChildren()) do
        local ok, data = pcall(require, item)
        if ok and data.Data and data.Data.Type == "Fishes" then
            FishDataById[data.Data.Id] = { Name = data.Data.Name, SellPrice = data.SellPrice or 0, Tier = data.Data.Tier, Icon = data.IconId or data.Data.Icon or "" }
        end
    end
    for _, v in ipairs(ReplicatedStorage.Variants:GetChildren()) do
        local ok, data = pcall(require, v)
        if ok and data.Data and data.Data.Type == "Variant" then
            VariantsByName[data.Data.Name] = data.SellMultiplier or 1
        end
    end
end)

categoriesDropdown = FishNotif:Dropdown({
	Title = "Select Fish Categories",
	Desc = "Choose which categories to send to webhook",
	Values = {"Secret", "Legendary", "Mythic", "Epic"},
	Multi = true,
	Default = {"Secret"},
	Callback = function(selected)
		SelectedCategories = selected
        saveConfig()
	end
})

local function GetRobloxImage(assetId)
	local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&size=420x420&format=Png&isCircular=false"
	local success, response = pcall(game.HttpGet, game, url)
	if success then
		local data = HttpService:JSONDecode(response)
		if data and data.data and data.data[1] and data.data[1].imageUrl then
			return data.data[1].imageUrl
		end
	end
	return nil
end

local function sendFishWebhook(fishName, rarityText, assetId, itemId, variantId)
	if not webhookUrl or webhookUrl == "" then return end
	local username = player.DisplayName
	local imageUrl = GetRobloxImage(assetId)
	if not imageUrl then return end

	local caught = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Caught")
	local rarest = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Rarest Fish")
	local basePrice = (FishDataById[itemId] and FishDataById[itemId].SellPrice or 0) * (VariantsByName[variantId] or 1)

	local data = {
		["username"] = "e-Fishery",
		["embeds"] = {{
			["title"] = "Fish Caught!",
			["description"] = string.format("Player **%s** caught a **%s** (%s)!", username, fishName, rarityText),
			["color"] = tonumber("0x00bfff"),
			["image"] = { ["url"] = imageUrl },
            ["fields"] = {
                { name = "Sell Price", value = tostring(basePrice), inline = true},
                { name = "Total Caught", value = tostring(caught and caught.Value or "N/A"), inline = true},
                { name = "Rarest Fish", value = tostring(rarest and rarest.Value or "N/A"), inline = true},
            },
			["footer"] = { ["text"] = "e-Fishery Notifier | " .. os.date("%I:%M:%S %p", os.time()) }
		}}
	}
    
    local requestFunc = syn and syn.request or http and http.request or http_request or request or fluxus and fluxus.request
	if requestFunc then
		requestFunc({ Url = webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(data) })
	end
end

local REObtainedNewFishNotification = getNetFolder() and getNetFolder():FindFirstChild("RE/ObtainedNewFishNotification")
if REObtainedNewFishNotification then
    REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, eventData)
        lastCatchTimestamp = os.time()

        if not webhookUrl or webhookUrl == "" then return end

        pcall(function()
            local fishInfo = FishDataById[itemId]
            if not fishInfo then return end

            local rarityName = rarityMap[fishInfo.Tier] or "Unknown Rarity"
            
            local isTarget = false
            for _, category in pairs(SelectedCategories) do
                if string.lower(category) == string.lower(rarityName) then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                local assetId = string.match(fishInfo.Icon or "", "%d+")
                if not assetId then return end
                
                local fishName = fishInfo.Name
                local variantId = eventData and eventData.InventoryItem and eventData.InventoryItem.Metadata and eventData.InventoryItem.Metadata.VariantId
                
                sendFishWebhook(fishName, rarityName, assetId, itemId, variantId)
            end
        end)
    end)
end

-------------------------------------------
----- =======[ WEATHER TAB ]
-------------------------------------------
local autoWeatherLoop

local function stopAutoWeather()
    if autoWeatherLoop then task.cancel(autoWeatherLoop); autoWeatherLoop = nil end
end

local function startAutoWeather()
    if autoWeatherLoop then stopAutoWeather() end

    autoWeatherLoop = task.spawn(function()
        -- Get the network folder and the specific remote for weather
        local net = getNetFolder()
        if not net then
            NotifyError("Weather System", "Could not find the game's network folder.")
            return 
        end
        local weatherRemote = net:FindFirstChild("RF/UseWeatherDevice")
        if not weatherRemote then
            NotifyError("Weather System", "Could not find 'RF/UseWeatherDevice' remote.")
            return
        end

        -- Connect to the game's session state to monitor the current weather
        local SessionReplion = Replion.Client:WaitReplion("Session")
        if not SessionReplion then
            NotifyError("Weather System", "Could not connect to the game's session state.")
            return
        end
        
        NotifySuccess("Auto Weather", "System is now active and monitoring weather status.")

        while state.AutoWeather do
            pcall(function()
                -- Read the current weather directly from the game's state
                local weatherData = SessionReplion:Get({"Weather"})
                local isWeatherActive = weatherData and weatherData.CurrentWeather and weatherData.CurrentWeather ~= "None"

                -- Check if weather is NOT active and if the user has selected a weather to use
                if not isWeatherActive and #state.SelectedWeathers > 0 then
                    NotifyInfo("Auto Weather", "No active weather detected. Triggering a new one...")
                    
                    -- Pick a random weather from the user's selection
                    local chosenWeather = state.SelectedWeathers[math.random(1, #state.SelectedWeathers)]
                    
                    -- Use the weather device
                    weatherRemote:InvokeServer(chosenWeather)
                    
                    -- Wait for a few seconds after triggering to allow the game state to update
                    task.wait(5) 
                end
            end)
            -- Check the weather status every second
            task.wait(1)
        end
    end)
end

-- Store toggle objects to set them on load
local weatherToggles = {}
local mainWeatherToggle

Weather:Toggle({
    Title = "Enable Auto Weather",
    Desc = "Automatically uses a selected weather when the current one expires.",
    Callback = function(Value)
        state.AutoWeather = Value
        if Value then 
            startAutoWeather()
        else 
            stopAutoWeather() 
        end
        saveConfig()
    end
}):Get(function(toggle)
    mainWeatherToggle = toggle
end)

Weather:Divider()

-- Helper function for weather toggle callbacks
local function createWeatherToggle(weatherName)
    Weather:Toggle({
        Title = weatherName,
        Default = table.find(savedData.selectedWeathers or {}, weatherName) ~= nil,
        Callback = function(Value)
            local index = table.find(state.SelectedWeathers, weatherName)
            if Value and not index then
                table.insert(state.SelectedWeathers, weatherName)
            elseif not Value and index then
                table.remove(state.SelectedWeathers, index)
            end
            saveConfig()
        end
    }):Get(function(toggle)
        weatherToggles[weatherName] = toggle
    end)
end

createWeatherToggle("Cloudy")
createWeatherToggle("Windy")
createWeatherToggle("Storm")
createWeatherToggle("Radiant")

-------------------------------------------
----- =======[ INITIALIZE AND RESTORE SESSION ]
-------------------------------------------

local function applyLoadedState()
    -- Restore fish notification settings
    if categoriesDropdown and savedData.webhookCategories then
        categoriesDropdown:Set(savedData.webhookCategories)
    end
    
    -- Restore main toggle settings
    if savedData.autoFavourite then
        state.AutoFavourite = true
        autoFavouriteToggle:Set(true)
    end
    if savedData.autoSell then
        state.AutoSell = true
        autoSellToggle:Set(true)
    end

    -- Restore weather settings
    if savedData.selectedWeathers then
        state.SelectedWeathers = savedData.selectedWeathers
        for weatherName, toggleObject in pairs(weatherToggles) do
            if table.find(state.SelectedWeathers, weatherName) then
                toggleObject:Set(true)
            end
        end
    end

    if savedData.autoWeather and mainWeatherToggle then
        state.AutoWeather = true
        mainWeatherToggle:Set(true)
    end
    
    -- This must come last to ensure other states are set first
    if savedData.autoFish and savedData.lastFarmPosition then
        NotifyInfo("Session Restored", "Returning to your last auto-farm location...")
        teleportTo(savedData.lastFarmPosition)
        task.wait(1.5)
        
        state.AutoFish = true
        autoFishToggle:Set(true)
    elseif savedData.autoFish then
         state.AutoFish = true
         autoFishToggle:Set(true)
    end
end

loadConfig()
applyLoadedState()
