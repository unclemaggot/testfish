return function()
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    if not WindUI then return end

    --// Services
    local Players = game:GetService("Players")
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    
    --// Player Variables
    local player = Players.LocalPlayer
    
    --// Intro Animation Variables
    local introScreenGui, introBlur, introFrame, introBg, introGlowFrame, introLogo, introLetters
    
    --// Function to create the intro animation
    local function createIntro()
        introLetters = {}
        introBlur = Instance.new("BlurEffect", Lighting)
        introBlur.Size = 0
        TweenService:Create(introBlur, TweenInfo.new(0.5), {Size = 24}):Play()

        introScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
        introScreenGui.Name = "ArcvourIntro"
        introScreenGui.ResetOnSpawn = false
        introScreenGui.IgnoreGuiInset = true

        introFrame = Instance.new("Frame", introScreenGui)
        introFrame.Size = UDim2.new(1, 0, 1, 0)
        introFrame.BackgroundTransparency = 1

        introBg = Instance.new("Frame", introFrame)
        introBg.Size = UDim2.new(1, 0, 1, 0)
        introBg.BackgroundColor3 = Color3.fromHex("#1E142D")
        introBg.BackgroundTransparency = 1
        introBg.ZIndex = 0
        TweenService:Create(introBg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
        
        introLogo = Instance.new("ImageLabel", introFrame)
        introLogo.Image = "rbxassetid://90566677928169"
        introLogo.Size = UDim2.new(0, 150, 0, 150)
        introLogo.Position = UDim2.new(0.5, 0.3, 0)
        introLogo.AnchorPoint = Vector2.new(0.5, 0.5)
        introLogo.BackgroundTransparency = 1
        introLogo.ImageTransparency = 1
        introLogo.ZIndex = 2

        TweenService:Create(introLogo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0, Size = UDim2.new(0, 200, 0, 200)}):Play()
        task.delay(0.5, function()
            TweenService:Create(introLogo, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 150, 0, 150)}):Play()
        end)

        local word = "ArcvourHub Lite"
        task.wait(1)

        for i = 1, #word do
            local char = word:sub(i, i)
            local label = Instance.new("TextLabel", introFrame)
            label.Text = char
            label.Font = Enum.Font.GothamBlack
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextStrokeTransparency = 1
            label.TextTransparency = 1
            label.TextSize = 30
            label.Size = UDim2.new(0, 60, 0, 60)
            label.AnchorPoint = Vector2.new(0.5, 0.5)
            label.Position = UDim2.new(0.5, (i - (#word / 2 + 0.5)) * 45, 0.6, 0)
            label.BackgroundTransparency = 1
            label.ZIndex = 2
            local gradient = Instance.new("UIGradient", label)
            gradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHex("#8C46FF")), ColorSequenceKeypoint.new(1, Color3.fromHex("#BE78FF")) })
            gradient.Rotation = 90
            TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60}):Play()
            table.insert(introLetters, label)
            task.wait(0.15)
        end
    end

    --// Function to fade out and destroy the intro
    local function tweenOutAndDestroy()
        if not introScreenGui or not introScreenGui.Parent then return end
        for _, label in ipairs(introLetters) do
            TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 20}):Play()
        end
        TweenService:Create(introBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(introBlur, TweenInfo.new(0.5), {Size = 0}):Play()
        TweenService:Create(introLogo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
        task.wait(0.6)
        pcall(function() introScreenGui:Destroy() end)
        pcall(function() introBlur:Destroy() end)
    end
    
    --// Main script logic
    local function InitializeMainScript()
        --// Helper function for gradient text
        function gradient(text, startColor, endColor)
            if not text or not startColor or not endColor then return "" end
            local result = ""
            for i = 1, #text do
                local t = (i - 1) / math.max(#text - 1, 1)
                local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
                local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
                local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
                result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
            end
            return result
        end

        WindUI:AddTheme({ Name = "Arcvour", Accent = "#4B2D82", Dialog = "#1E142D", Outline = "#46375A", Text = "#E5DCEA", Placeholder = "#A898C2", Background = "#221539", Button = "#8C46FF", Icon = "#A898C2" })
        WindUI:SetTheme("Arcvour")
        
        local Window = WindUI:CreateWindow({
            Title = gradient("ArcvourHUB Lite", Color3.fromHex("#8C46FF"), Color3.fromHex("#BE78FF")),
            Icon = "rbxassetid://90566677928169",
            Author = "Fish It - Lite Version",
            Size = UDim2.fromOffset(500, 320),
            Folder = "ArcvourHUB_Lite_Config",
            Theme = "Arcvour",
            ToggleKey = Enum.KeyCode.K
        })

        if not Window then return end

        local GameSection = Window:Section({ Title = "Game Features", Opened = true })
        
        --// Define the tabs for the UI
        local GameTabs = {
            Farming = GameSection:Tab({ Title = "Farming", Icon = "fish", ShowTabTitle = true }),
            Auto_Favorite = GameSection:Tab({ Title = "Auto Favorite", Icon = "star", ShowTabTitle = true }),
            TP_Islands = GameSection:Tab({ Title = "TP Islands", Icon = "map-pin", ShowTabTitle = true }),
        }

        --// AUTO FISH AND AUTO SELL LOGIC
        do
            local featureState = { AutoFish = false, LockPosition = false, AutoSellMode = "Disabled", AutoSellDelay = 1800 }
            local savedLockPosition = nil
            local selectedAutoFishMethod = "V2"
            local lastSellTime = 0
            
            local autoFishToggle, lockPositionToggle, autoFishMethodDropdown
            local autoSellModeDropdown, autoSellDelayInput
            local autoFishV3Connection, timeoutThread = nil, nil
            
            local FishingController, AnimationController, CutsceneController
            pcall(function()
                FishingController = require(replicatedStorage:WaitForChild("Controllers"):WaitForChild("FishingController"))
                AnimationController = require(replicatedStorage:WaitForChild("Controllers"):WaitForChild("AnimationController"))
                CutsceneController = require(replicatedStorage:WaitForChild("Controllers"):WaitForChild("CutsceneController"))
            end)

            if CutsceneController then
                local oldPlay = CutsceneController.Play
                CutsceneController.Play = function(...)
                    if featureState.AutoFish then return end
                    return oldPlay(...)
                end
            end
            
            local function playCastingAnimation()
                task.spawn(function()
                    pcall(function()
                        if AnimationController then
                            AnimationController:PlayAnimation("CastFromFullChargePosition1Hand")
                        end
                    end)
                end)
            end
            
            local function startAutoFishMethod_V2_Smart()
                task.spawn(function()
                    local netFolder = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
                    local equipEvent = netFolder:WaitForChild("RE/EquipToolFromHotbar")
                    local chargeFunc = netFolder:WaitForChild("RF/ChargeFishingRod")
                    local startMinigameFunc = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
                    local completeEvent = netFolder:WaitForChild("RE/FishingCompleted")

                    while featureState.AutoFish and player do
                        while FishingController and FishingController.OnCooldown and FishingController:OnCooldown() do
                            task.wait(0.5)
                        end
                        if not featureState.AutoFish then break end
                        
                        playCastingAnimation()
                        pcall(equipEvent.FireServer, equipEvent, 1)
                        task.wait(0.1)
                        
                        pcall(chargeFunc.InvokeServer, chargeFunc, workspace:GetServerTimeNow())
                        task.wait(0.1)
                        pcall(startMinigameFunc.InvokeServer, startMinigameFunc, -0.75, 1)
                        task.wait(0.2)
                        
                        local sellFunc = netFolder:WaitForChild("RF/SellAllItems")
                        if featureState.AutoSellMode == "Auto Sell All (No TP)" then
                             if os.time() - lastSellTime >= featureState.AutoSellDelay then
                                task.spawn(sellFunc.InvokeServer, sellFunc)
                                lastSellTime = os.time()
                            end
                        end
                        
                        for i = 1, 25 do
                            if not featureState.AutoFish then break end
                            pcall(completeEvent.FireServer, completeEvent)
                            task.wait(0.1)
                        end
                        
                        if featureState.AutoFish then task.wait(2) end
                    end
                end)
            end
            
            local function stopAutoFishProcesses()
                if autoFishV3Connection and autoFishV3Connection.Connected then
                    autoFishV3Connection:Disconnect()
                    autoFishV3Connection = nil
                end
                if timeoutThread then
                    task.cancel(timeoutThread)
                    timeoutThread = nil
                end
                pcall(function()
                    if FishingController and FishingController.RequestClientStopFishing then
                        FishingController:RequestClientStopFishing(true)
                    end
                end)
            end

            GameTabs.Farming:Section({ Title = "Auto Features" })
            
            autoFishToggle = GameTabs.Farming:Toggle({
                Title = "Enable Auto Fish", Desc = "Uses a smart, fast, and reliable method.", Value = false,
                Callback = function(value)
                    featureState.AutoFish = value
                    if value then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            savedLockPosition = player.Character.HumanoidRootPart.CFrame
                        end
                        startAutoFishMethod_V2_Smart()
                    else
                         stopAutoFishProcesses()
                    end
                end
            })

            lockPositionToggle = GameTabs.Farming:Toggle({
                Title = "Lock Position",
                Desc = "Anchors the character in its current position.",
                Value = false,
                Callback = function(value)
                    featureState.LockPosition = value
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.Anchored = value
                    end
                end
            })

            player.CharacterAdded:Connect(function(character)
                local hrp = character:WaitForChild("HumanoidRootPart", 5)
                if featureState.LockPosition and hrp then
                    hrp.Anchored = true
                end
            end)
            
            local function performSellWithTP()
                pcall(function()
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    local originalCFrame = hrp.CFrame
                    local wasLocked = featureState.LockPosition

                    if wasLocked then
                        hrp.Anchored = false
                        task.wait(0.1)
                    end
                    
                    hrp.CFrame = CFrame.new(56.78, 17.41, 2880.67) -- Sell location CFrame
                    task.wait(1)
                    
                    replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems"):InvokeServer()
                    task.wait(1)
                    
                    hrp.CFrame = originalCFrame
                    task.wait(0.1)

                    if wasLocked then
                        hrp.Anchored = true
                    end
                end)
            end

            autoSellModeDropdown = GameTabs.Farming:Dropdown({
                Title = "Auto Sell All Fish",
                Desc = "Select the mode for auto selling.",
                Values = {"Disabled", "Auto Sell All (No TP)", "Auto Sell All (TP)"},
                Value = "Disabled",
                Callback = function(value)
                    featureState.AutoSellMode = value
                end
            })

            task.spawn(function()
                while task.wait(2) do
                    if Window.Destroyed then break end
                    if featureState.AutoSellMode ~= "Auto Sell All (TP)" or featureState.AutoFish then continue end
                    
                    if os.time() - lastSellTime >= featureState.AutoSellDelay then
                        performSellWithTP()
                        lastSellTime = os.time()
                    end
                end
            end)
            
            autoSellDelayInput = GameTabs.Farming:Input({
                Title = "Auto Sell Delay (minutes)",
                Desc = "Sets the time between each auto-sell action.",
                Placeholder = "Enter a number, e.g., 30",
                Type = "Input",
                Callback = function(v)
                    local minutes = tonumber(v)
                    if minutes and minutes > 0 then
                        featureState.AutoSellDelay = minutes * 60
                    else
                        featureState.AutoSellDelay = 1800 -- Default 30 minutes
                    end
                end
            })
        end

        --// AUTO FAVORITE LOGIC
        do
            local favoriteState = {
                enabled = false,
                selectedTiers = {},
                selectedUnfavoriteTiers = {},
                delay = 5
            }
            local tierMap = {
                ["Common"] = 1, ["Uncommon"] = 2, ["Rare"] = 3, ["Epic"] = 4, ["Legendary"] = 5, ["Mythic"] = 6, ["SECRET"] = 7
            }
            local tierNames = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"}
            local statusParagraph
            
            local function processFavoriteLogic(isManualRun)
                if not statusParagraph then return end
                isManualRun = isManualRun or false
                local ItemUtility, Replion
                local modulesLoaded = pcall(function()
                    Replion = require(replicatedStorage:WaitForChild("Packages"):WaitForChild("Replion"))
                    ItemUtility = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
                end)
                if not modulesLoaded then statusParagraph:SetDesc("Error: Failed to load required modules."); return end
                statusParagraph:SetDesc("Scanning inventory...")
                local DataReplion = Replion.Client:WaitReplion("Data")
                if not DataReplion then statusParagraph:SetDesc("Error: Failed to get player data."); return end
                local inventoryItems = DataReplion:Get({"Inventory", "Items"})
                if not inventoryItems then statusParagraph:SetDesc("Inventory is empty."); return end
                
                local favoriteQueue = {}
                for _, itemData in ipairs(inventoryItems) do
                    if not itemData.Favorited then
                        local baseItemData = ItemUtility:GetItemData(itemData.Id)
                        if baseItemData and baseItemData.Data and baseItemData.Data.Tier and table.find(favoriteState.selectedTiers, baseItemData.Data.Tier) then
                            table.insert(favoriteQueue, itemData.UUID)
                        end
                    end
                end

                if #favoriteQueue == 0 then statusParagraph:SetDesc("Done. No new items to favorite."); return end
                statusParagraph:SetDesc(string.format("Found %d items to favorite. Processing...", #favoriteQueue))
                local favoriteEvent = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/FavoriteItem")
                for i, uuid in ipairs(favoriteQueue) do
                    if not isManualRun and not favoriteState.enabled then break end
                    favoriteEvent:FireServer(uuid)
                    statusParagraph:SetDesc(string.format("Favoriting... (%d/%d)", i, #favoriteQueue))
                    task.wait(0.2)
                end
                statusParagraph:SetDesc(string.format("Done. %d items have been favorited.", #favoriteQueue))
            end

            GameTabs.Auto_Favorite:Section({ Title = "Favorite by Tier" })
            GameTabs.Auto_Favorite:Dropdown({
                Title = "Select Tiers to Favorite", Values = tierNames, Multi = true, AllowNone = true,
                Callback = function(selectedNames)
                    favoriteState.selectedTiers = {}
                    for _, name in ipairs(selectedNames) do if tierMap[name] then table.insert(favoriteState.selectedTiers, tierMap[name]) end end
                end
            })
            GameTabs.Auto_Favorite:Toggle({
                Title = "Enable Auto Favorite", Desc = "Automatically favorites items based on selected tiers.", Value = false,
                Callback = function(value)
                    favoriteState.enabled = value
                    if value then task.spawn(function() while favoriteState.enabled do processFavoriteLogic(false); task.wait(favoriteState.delay) end end) end
                end
            })
            GameTabs.Auto_Favorite:Slider({
                Title = "Delay (seconds)", Value = { Min = 1, Max = 60, Default = 5 }, Step = 1,
                Callback = function(value) 
                    favoriteState.delay = tonumber(value) or 5 
                end
            })
            GameTabs.Auto_Favorite:Button({ Title = "Favorite Now", Desc = "Run the favorite process once manually.", Icon = "star", Callback = function() processFavoriteLogic(true) end })
            
            statusParagraph = GameTabs.Auto_Favorite:Paragraph({Title = "Status", Desc = "Waiting to start..."})
        end
        
        --// TELEPORT ISLANDS LOGIC
        do
            GameTabs.TP_Islands:Section({ Title = "Island Locations" })
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
                { Name = "Coral Reefs", Position = Vector3.new(-3023.97, 337.81, 2195.60) }
            }
            for _, loc_data in ipairs(island_locations) do
                GameTabs.TP_Islands:Button({ Title = loc_data.Name, Callback = function() if player.Character and player.Character.PrimaryPart then player.Character.PrimaryPart.CFrame = CFrame.new(loc_data.Position) end end })
            end
        end

        --// Anti-AFK
        local VirtualUser = game:GetService("VirtualUser")
        if player and VirtualUser then
            player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end

        if Window then
            Window:SelectTab(1)
            WindUI:Notify({ Title = "ArcvourHUB Lite Ready", Content = "The script has loaded. Enjoy!", Duration = 8, Icon = "check-circle" })
        end
    end
    
    --// Start script execution
    createIntro()
    task.wait(2.5)
    tweenOutAndDestroy()
    InitializeMainScript()
end
