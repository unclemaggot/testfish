------------------------------------------
----- =======[ Load WindUI ]
-------------------------------------------

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    error("e-Fishery: Could not load the WindUI library. The script cannot continue.")
    return
end

-------------------------------------------
----- =======[ GLOBAL & CORE FUNCTIONS ]
-------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local function formatPrice(price)
    price = tonumber(price) or 0
    if price >= 1000000 then
        return string.format("%.1fM", price / 1000000):gsub("%.0M", "M")
    elseif price >= 1000 then
        return string.format("%.1fK", price / 1000):gsub("%.0K", "K")
    else
        return tostring(price)
    end
end

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
    AutoBuyWeather = false,
    SelectedWeathers = {},
    PerfectCast = true
}
local lastFarmPosition = nil 
local lastCatchTimestamp = 0
local autoBuyWeatherLoop
local autoFishLoop

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

-- =========================
-- CORE FEATURE FUNCTIONS
-- =========================

local function startAutoFavourite()
    task.spawn(function()
        while state.AutoFavourite do
            pcall(function()
                local net = getNetFolder(); if not net or not Replion or not ItemUtility then return end
                local favoriteRemote = net:FindFirstChild("RE/FavoriteItem"); if not favoriteRemote then return end
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

-- ## NEW ADVANCED AUTO FISH FUNCTION ##
local function startAutoFish()
    if autoFishLoop then return end

    autoFishLoop = task.spawn(function()
        local net = getNetFolder()
        if not net then NotifyError("Auto Fish", "Network folder not found."); return end

        local equipRemote = net:FindFirstChild("RE/EquipToolFromHotbar")
        local chargeRemote = net:FindFirstChild("RF/ChargeFishingRod")
        local miniGameRemote = net:FindFirstChild("RF/RequestFishingMinigameStarted")
        local finishRemote = net:FindFirstChild("RE/FishingCompleted")
        local textEffectRemote = net:FindFirstChild("RE/ReplicateTextEffect")

        if not (equipRemote and chargeRemote and miniGameRemote and finishRemote and textEffectRemote) then
            NotifyError("Auto Fish", "One or more fishing remotes could not be found.")
            return
        end

        local fishingActive = false
        local fishBiteConnection

        fishBiteConnection = textEffectRemote.OnClientEvent:Connect(function(data)
            if state.AutoFish and fishingActive and data and data.TextData and data.TextData.EffectType == "Exclaim" then
                local myHead = player.Character and player.Character:FindFirstChild("Head")
                if myHead and data.Container == myHead then
                    -- Fish on the line, complete the catch
                    task.spawn(function()
                        for i = 1, 3 do
                            task.wait()
                            finishRemote:FireServer()
                        end
                    end)
                end
            end
        end)
        
        NotifySuccess("Auto Fish", "Advanced auto-fish initiated.")

        while state.AutoFish do
            pcall(function()
                fishingActive = true
                
                equipRemote:FireServer(1)
                task.wait(0.1)
                
                chargeRemote:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.5)

                local x, y
                if state.PerfectCast then
                    x = -0.749999 + (math.random(-500, 500) / 10000000)
                    y = 0.991067 + (math.random(-500, 500) / 10000000)
                else
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end
                
                miniGameRemote:InvokeServer(x, y)
                
                -- Wait for the fish to bite. The OnClientEvent connection will handle the rest.
                -- We add a timeout to recast if no fish bites after a while.
                task.wait(15) 
                fishingActive = false
            end)
            task.wait(1) -- Short delay before recasting
        end

        -- Cleanup when autofish is turned off
        if fishBiteConnection then
            fishBiteConnection:Disconnect()
        end
    end)
end

local function stopAutoFish()
    if autoFishLoop then
        state.AutoFish = false
        task.cancel(autoFishLoop)
        autoFishLoop = nil
        NotifyInfo("Auto Fish", "Advanced auto-fish stopped.")
    end
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
    Title = "e-Fishery V4.0", Author = "by Zee (WindUI Edition)", Folder = "e-Fishery",
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
local BuyWeather = Window:Tab({ Title = "Buy Weather", Icon = "cloud-sun" })
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
local savedData = { webhookUrl = "", autoFish = false, autoFavourite = false, autoSell = false, webhookCategories = {"Secret"}, lastFarmPosition = nil, autoBuyWeather = false, selectedWeathers = {}, perfectCast = true }
local file_name = "e_fishery_session.json"
local webhookUrl, SelectedCategories

local function saveConfig()
    if writefile then
        savedData.webhookUrl, savedData.autoFish, savedData.autoFavourite, savedData.autoSell = webhookUrl, state.AutoFish, state.AutoFavourite, state.AutoSell
        savedData.webhookCategories, savedData.lastFarmPosition, savedData.autoBuyWeather, savedData.selectedWeathers = SelectedCategories, lastFarmPosition, state.AutoBuyWeather, state.SelectedWeathers
        savedData.perfectCast = state.PerfectCast
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

local autoFishToggle, autoFavouriteToggle, autoSellToggle, perfectCastToggle

autoFishToggle = Main:Toggle({ Title = "Enable Auto Fish (Advanced)", Desc = "Uses a smart, event-driven method for fishing.", Callback = function(v) state.AutoFish = v; if v then startAutoFish() else stopAutoFish() end; saveConfig() end })
perfectCastToggle = Main:Toggle({ Title = "Auto Perfect Cast", Callback = function(v) state.PerfectCast = v; saveConfig() end })
autoFavouriteToggle = Main:Toggle({ Title = "Auto Favourite", Callback = function(v) state.AutoFavourite = v; if v then startAutoFavourite() end; saveConfig() end })
autoSellToggle = Main:Toggle({ Title = "Auto Sell", Callback = function(v) state.AutoSell = v; if v then startAutoSell() end; saveConfig() end })

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
for name, pos in pairs(island_locations) do AutoFarm:Button({ Title = name, Callback = function() lastFarmPosition = pos; teleportTo(pos); task.wait(0.8); state.AutoFish = true; if autoFishToggle then autoFishToggle:Set(true) end; startAutoFish(); saveConfig() end }) end

-------------------------------------------
----- =======[ BUY WEATHER TAB ]
-------------------------------------------
local autoBuyWeatherToggle, autoBuyWeatherDropdown

local function purchaseSelectedWeathers()
    if not state.AutoBuyWeather or #state.SelectedWeathers == 0 then return end
    NotifyInfo("Auto Buy Weather", "Attempting to activate a selected weather...")
    local chosenWeather = state.SelectedWeathers[math.random(1, #state.SelectedWeathers)]
    local remote = getNetFolder() and getNetFolder():FindFirstChild("RF/PurchaseWeatherEvent")
    if remote then pcall(remote.InvokeServer, remote, chosenWeather) end
end

autoBuyWeatherToggle = BuyWeather:Toggle({
    Title = "Enable Auto Buy Weather",
    Callback = function(value)
        state.AutoBuyWeather = value
        if value then
            if autoBuyWeatherLoop then task.cancel(autoBuyWeatherLoop) end
            autoBuyWeatherLoop = task.spawn(function()
                purchaseSelectedWeathers()
                while state.AutoBuyWeather do
                    task.wait(990)
                    if state.AutoBuyWeather then purchaseSelectedWeathers() end
                end
            end)
        else
            if autoBuyWeatherLoop then task.cancel(autoBuyWeatherLoop); autoBuyWeatherLoop = nil end
        end
        saveConfig()
    end
})

local weathersData = {
    { Name = "Windy", Price = 10000 }, { Name = "Snow", Price = 15000 }, { Name = "Cloudy", Price = 20000 },
    { Name = "Storm", Price = 35000 }, { Name = "Radiant", Price = 50000 }, { Name = "Shark Hunt", Price = 300000 }
}
table.sort(weathersData, function(a, b) return a.Price < b.Price end)
local weatherNames = {}; for _, weather in ipairs(weathersData) do if weather.Name ~= "Snow" and weather.Name ~= "Shark Hunt" then table.insert(weatherNames, weather.Name) end end

autoBuyWeatherDropdown = BuyWeather:Dropdown({
    Title = "Select Weather to Auto Buy", Values = weatherNames, Multi = true, AllowNone = true,
    Callback = function(value) state.SelectedWeathers = value; saveConfig() end
})

BuyWeather:Divider()
BuyWeather:Paragraph({Title = "Manual Purchase", Desc = "Instantly buy a weather effect."})

for _, weatherData in ipairs(weathersData) do 
    local buttonTitle = string.format("%s (%s Coins)", weatherData.Name, formatPrice(weatherData.Price))
    BuyWeather:Button({ Title = buttonTitle, Callback = function() 
        local remote = getNetFolder() and getNetFolder():FindFirstChild("RF/PurchaseWeatherEvent")
        if remote then pcall(remote.InvokeServer, remote, weatherData.Name); NotifyInfo("Manual Purchase", "Sent request to buy " .. weatherData.Name) end
    end })
end

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
    if savedData.perfectCast and perfectCastToggle then state.PerfectCast = true; perfectCastToggle:Set(true) end

    -- Restore state for the Buy Weather tab
    if autoBuyWeatherDropdown and savedData.selectedWeathers then autoBuyWeatherDropdown:Set(savedData.selectedWeathers); state.SelectedWeathers = savedData.selectedWeathers end
    if autoBuyWeatherToggle and savedData.autoBuyWeather then state.AutoBuyWeather = true; autoBuyWeatherToggle:Set(true) end
    
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
