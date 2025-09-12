-- Full e-Fishery script with fixed Auto Weather (WEATHER TAB replaced)
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
    Title = "e-Fishery V1.5",
    Icon = "shrimp",
    Author = "by Zee (WindUI Edition)",
    Folder = "e-Fishery",
    Size = UDim2.fromOffset(600, 480),
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
        CFrame.new(1066.1864, 57.2025681, 5045.5542, -0.682534158,
