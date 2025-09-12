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
    AutoBuyWeather = false,
    SelectedWeathers = {},
}
local lastFarmPosition = nil 
local lastCatchTimestamp = 0
local respawnTimerLoop = nil
local autoBuyWeatherLoop

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
                for _, item in ipairs(items) do if not item.Favorited then unfavoritedCount = unfavoritedCount
