return function(gameStatusData)
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    if not WindUI then return end

    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    local MarketplaceService = game:GetService("MarketplaceService")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer
    local startTime = os.time()
    
    local GAME_ID = "fi"
    local VALIDATION_URL = "https://arcvourhub.my.id/api/user"

    local introScreenGui, introBlur, introFrame, introBg, introGlowFrame, introLogo, introLetters
    
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
        
        introGlowFrame = Instance.new("Frame", introFrame)
        introGlowFrame.Size = UDim2.new(1, 0, 1, 0)
        introGlowFrame.BackgroundTransparency = 1
        introGlowFrame.ZIndex = 1

        local glowAsset = "rbxassetid://5036224375" 
        local glowColor = Color3.fromHex("#8C46FF")

        local glowParts = {
            Top = { Size = UDim2.new(1, 40, 0, 100), Position = UDim2.new(0.5, 0, 0, 0) },
            Bottom = { Size = UDim2.new(1, 40, 0, 100), Position = UDim2.new(0.5, 0, 1, 0) },
            Left = { Size = UDim2.new(0, 100, 1, 40), Position = UDim2.new(0, 0, 0.5, 0) },
            Right = { Size = UDim2.new(0, 100, 1, 40), Position = UDim2.new(1, 0, 0.5, 0) }
        }

        for _, props in pairs(glowParts) do
            local glow = Instance.new("ImageLabel", introGlowFrame)
            glow.Image = glowAsset
            glow.ImageColor3 = glowColor
            glow.ImageTransparency = 1
            glow.Size = props.Size
            glow.Position = props.Position
            glow.AnchorPoint = Vector2.new(0.5, 0.5)
            glow.BackgroundTransparency = 1
            TweenService:Create(glow, TweenInfo.new(1), {ImageTransparency = 0.5}):Play()
        end

        introLogo = Instance.new("ImageLabel", introFrame)
        introLogo.Image = "rbxassetid://90566677928169"
        introLogo.Size = UDim2.new(0, 150, 0, 150)
        introLogo.Position = UDim2.new(0.5, 0, 0.3, 0)
        introLogo.AnchorPoint = Vector2.new(0.5, 0.5)
        introLogo.BackgroundTransparency = 1
        introLogo.ImageTransparency = 1
        introLogo.Rotation = 0
        introLogo.ZIndex = 2

        TweenService:Create(introLogo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0, Size = UDim2.new(0, 200, 0, 200), Rotation = 15 }):Play()
        task.delay(0.5, function()
            TweenService:Create(introLogo, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 150, 0, 150), Rotation = 0 }):Play()
        end)

        local word = "ArcvourHub"
        
        task.wait(1)

        for i = 1, #word do
            local char = word:sub(i, i)
            local label = Instance.new("TextLabel")
            label.Text = char
            label.Font = Enum.Font.GothamBlack
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextStrokeTransparency = 1
            label.TextTransparency = 1
            label.TextScaled = false
            label.TextSize = 30
            label.Size = UDim2.new(0, 60, 0, 60)
            label.AnchorPoint = Vector2.new(0.5, 0.5)
            label.Position = UDim2.new(0.5, (i - (#word / 2 + 0.5)) * 45, 0.6, 0)
            label.BackgroundTransparency = 1
            label.Parent = introFrame
            label.ZIndex = 2
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHex("#8C46FF")), ColorSequenceKeypoint.new(1, Color3.fromHex("#BE78FF")) })
            gradient.Rotation = 90
            gradient.Parent = label
            TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60}):Play()
            table.insert(introLetters, label)
            task.wait(0.15)
        end
    end

    local function tweenOutAndDestroy()
        if not introScreenGui or not introScreenGui.Parent then return end
        for _, label in ipairs(introLetters) do
            TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 20}):Play()
        end
        for _, glow in ipairs(introGlowFrame:GetChildren()) do
            if glow:IsA("ImageLabel") then
                TweenService:Create(glow, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
            end
        end
        TweenService:Create(introBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(introBlur, TweenInfo.new(0.5), {Size = 0}):Play()
        TweenService:Create(introLogo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
        task.wait(0.6)
        pcall(function() introScreenGui:Destroy() end)
        pcall(function() introBlur:Destroy() end)
    end
    
    local function InitializeMainScript()
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

        function formatPrice(price)
            if price >= 1000000 then
                return string.format("%.1fM Coins", price / 1000000):gsub("%.0M", "M")
            elseif price >= 1000 then
                return string.format("%dk Coins", price / 1000)
            else
                return tostring(price) .. " Coins"
            end
        end

        WindUI:AddTheme({ Name = "Arcvour", Accent = "#4B2D82", Dialog = "#1E142D", Outline = "#46375A", Text = "#E5DCEA", Placeholder = "#A898C2", Background = "#221539", Button = "#8C46FF", Icon = "#A898C2" })
        WindUI:SetTheme("Arcvour")
        
        local Window = WindUI:CreateWindow({
            Title = gradient("ArcvourHUB", Color3.fromHex("#8C46FF"), Color3.fromHex("#BE78FF")),
            Icon = "rbxassetid://90566677928169",
            Author = "Fish It",
            Size = UDim2.fromOffset(500, 320),
            Folder = "ArcvourHUB_Config",
            Transparent = false,
            Theme = "Arcvour",
            ToggleKey = Enum.KeyCode.K,
            SideBarWidth = 160
        })

        if not Window then return end

        local floatingButtonGui = Instance.new("ScreenGui")
        floatingButtonGui.Name = "ArcvourToggleGUI"
        floatingButtonGui.IgnoreGuiInset = true
        floatingButtonGui.ResetOnSpawn = false
        floatingButtonGui.Parent = game.CoreGui
        floatingButtonGui.Enabled = false

        local floatingButton = Instance.new("ImageButton", floatingButtonGui)
        floatingButton.Name = "ArcvourToggle"
        floatingButton.Size = UDim2.new(0, 40, 0, 40)
        floatingButton.Position = UDim2.new(0, 70, 0, 70)
        floatingButton.BackgroundColor3 = Color3.fromHex("#1E142D")
        floatingButton.Image = "rbxassetid://90566677928169"
        floatingButton.AutoButtonColor = true

        Instance.new("UICorner", floatingButton).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", floatingButton)
        stroke.Thickness = 1.5
        stroke.Color = Color3.fromHex("#BE78FF")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local gradientStroke = Instance.new("UIGradient", stroke)
        gradientStroke.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromHex("#8C46FF")), ColorSequenceKeypoint.new(1, Color3.fromHex("#BE78FF"))}
        gradientStroke.Rotation = 45

        local dragging, dragStart, startPos
        floatingButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging, dragStart, startPos = true, input.Position, floatingButton.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
        game:GetService("UserInputService").InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; floatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
        floatingButton.MouseButton1Click:Connect(function() floatingButtonGui.Enabled = false; Window:Open() end)

        Window:OnDestroy(function() floatingButtonGui:Destroy() end)
        Window:DisableTopbarButtons({"Close", "Minimize"})
        Window:CreateTopbarButton("HideButton", "x", function() Window:Close(); floatingButtonGui.Enabled = true end, 999)

        local HubSection = Window:Section({ Title = "Arcvour Hub", Opened = true })
        local GameSection = Window:Section({ Title = "Game Features", Opened = true })
        
        local HubTabs = {
            Home = HubSection:Tab({ Title = "Home", Icon = "layout-dashboard", ShowTabTitle = true }),
            GameStatus = HubSection:Tab({ Title = "Game Status", Icon = "server-cog", ShowTabTitle = true }),
            ServerInfo = HubSection:Tab({ Title = "Server Info", Icon = "server", ShowTabTitle = true }),
            WebhookFish = HubSection:Tab({ Title = "Webhook Fish", Icon = "webhook", ShowTabTitle = true }),
            WebhookTrade = HubSection:Tab({ Title = "Webhook Trade", Icon = "arrow-right-left", ShowTabTitle = true }),
            WebhookInventory = HubSection:Tab({ Title = "Webhook Inventory", Icon = "box", ShowTabTitle = true }),
            Movement = HubSection:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true }),
            BoostFps = HubSection:Tab({ Title = "Boost Fps", Icon = "rocket", ShowTabTitle = true }),
            Config = HubSection:Tab({ Title = "Config", Icon = "file-cog", ShowTabTitle = true })
        }

        do
            HubTabs.Home:Paragraph({ Title = "Welcome to ArcvourHUB", Desc = "ArcvourHUB is a universal script hub designed to provide the best experience across various Roblox games. Enjoy powerful, user-friendly, and consistently updated features.", Image = "rbxassetid://90566677928169", ImageSize = 24, Color = Color3.fromHex("#BE78FF") })
            HubTabs.Home:Section({ Title = "Developer Team" })
            HubTabs.Home:Paragraph({ Title = "Arcvour", Desc = "Owner", Image = "rbxassetid://126197686455127", ImageSize = 32 })
            HubTabs.Home:Paragraph({ Title = "Fmanha", Desc = "Owner 2", Image = "rbxassetid://72647963301851", ImageSize = 32 })
            HubTabs.Home:Paragraph({ Title = "Solehudin", Desc = "Partner", Image = "rbxassetid://130653496711990", ImageSize = 32 })
            HubTabs.Home:Section({ Title = "Community" })
            local discordInviteCode, discordApiUrl = "UJMwhrrvxt", "https://discord.com/api/v9/invites/UJMwhrrvxt?with_counts=true"
            local DiscordInfo = HubTabs.Home:Paragraph({ Title = "Discord Server", Desc = "Loading...", Image = "rbxassetid://73242804704566", ImageSize = 32 })
            local telegramUsername = "arcvourscript"
            local TelegramInfo = HubTabs.Home:Paragraph({ Title = "Telegram Channel", Desc = "Loading...", Image = "rbxassetid://73242804704566", ImageSize = 32 })
            
            task.spawn(function()
                while task.wait(10) do
                    if Window.Destroyed then break end
                    local success, response = pcall(game.HttpGet, game, discordApiUrl, true)
                    if success and response then
                        local data = HttpService:JSONDecode(response)
                        if data and data.guild then
                            local desc = string.format('<font color="#52525b">•</font> Members : %d\n<font color="#16a34a">•</font> Online : %d', data.approximate_member_count, data.approximate_presence_count)
                            DiscordInfo:SetTitle(data.guild.name)
                            DiscordInfo:SetDesc(desc)
                        else DiscordInfo:SetDesc("Failed to load data.") end
                    else DiscordInfo:SetDesc("Failed to connect to Discord API.") end
                end
            end)

            task.spawn(function()
                local telegramApiUrl = "http://104.248.153.156:4000/telegram-info"
                while task.wait(10) do
                    if Window.Destroyed then break end
                    local success, response = pcall(game.HttpGet, game, telegramApiUrl, true)
                    if success and response then
                        local data = HttpService:JSONDecode(response)
                        if data and data.name and data.members then
                            TelegramInfo:SetTitle(data.name)
                            TelegramInfo:SetDesc(string.format("Members: %d", data.members))
                        else
                            TelegramInfo:SetDesc("Failed to parse data.")
                        end
                    else
                        TelegramInfo:SetDesc("Failed to connect to API.")
                    end
                end
            end)

            HubTabs.Home:Section({ Title = "Links" })
            HubTabs.Home:Paragraph({ Title = "YouTube", Desc = "youtube.com/@arcvour", Image = "youtube", Color = Color3.fromHex("#FF0000"), Buttons = {{ Title = "Copy Link", Icon = "copy", Variant = "Tertiary", Callback = function() setclipboard("https://youtube.com/@arcvour"); WindUI:Notify({ Title = "Copied!", Content = "YouTube link copied to clipboard.", Duration = 3 }) end }} })
            HubTabs.Home:Paragraph({ Title = "Discord", Desc = "discord.gg/"..discordInviteCode, Image = "message-square", Color = Color3.fromHex("#5865F2"), Buttons = {{ Title = "Copy Link", Icon = "copy", Variant = "Tertiary", Callback = function() setclipboard("https://discord.gg/"..discordInviteCode); WindUI:Notify({ Title = "Copied!", Content = "Discord link copied to clipboard.", Duration = 3 }) end }} })
            HubTabs.Home:Paragraph({ Title = "Telegram", Desc = "t.me/"..telegramUsername, Image = "send", Color = Color3.fromHex("#2AABEE"), Buttons = {{ Title = "Copy Link", Icon = "copy", Variant = "Tertiary", Callback = function() setclipboard("https.me/"..telegramUsername); WindUI:Notify({ Title = "Copied!", Content = "Telegram link copied to clipboard.", Duration = 3 }) end }} })
        end

        do
            if gameStatusData and type(gameStatusData) == "table" then
                local currentGameInfo = nil
                for _, gameInfo in ipairs(gameStatusData) do
                    for _, placeId in ipairs(gameInfo.PlaceIds) do
                        if placeId == game.PlaceId then
                            currentGameInfo = gameInfo
                            break
                        end
                    end
                    if currentGameInfo then break end
                end

                HubTabs.GameStatus:Section({ Title = "Current Game" })
                if currentGameInfo then
                    HubTabs.GameStatus:Paragraph({
                        Title = currentGameInfo.Name,
                        Desc = string.format("Version: %s\nStatus: %s", currentGameInfo.Version, currentGameInfo.Status),
                        Image = currentGameInfo.Icon,
                        ImageSize = 32
                    })
                end
                
                HubTabs.GameStatus:Section({ Title = "Other Games" })
                for _, gameInfo in ipairs(gameStatusData) do
                    if gameInfo ~= currentGameInfo then
                        HubTabs.GameStatus:Paragraph({
                            Title = gameInfo.Name,
                            Desc = string.format("Version: %s\nStatus: %s", gameInfo.Version, gameInfo.Status),
                            Image = gameInfo.Icon,
                            ImageSize = 32
                        })
                    end
                end
            end
        end

        do
            HubTabs.ServerInfo:Section({ Title = "Local Player" })
            local runtimeLabel = HubTabs.ServerInfo:Paragraph({ Title = "Run Time", Desc = "0 minute(s), 0 second(s)" })
            HubTabs.ServerInfo:Paragraph({ Title = "Player ID", Desc = tostring(player.UserId), Buttons = {{ Title = "Copy", Icon = "copy", Variant = "Tertiary", Callback = function() setclipboard(tostring(player.UserId)) end }} })
            HubTabs.ServerInfo:Paragraph({ Title = "Appearance ID", Desc = tostring(player.CharacterAppearanceId), Buttons = {{ Title = "Copy", Icon = "copy", Variant = "Tertiary", Callback = function() setclipboard(tostring(player.CharacterAppearanceId)) end }} })
            HubTabs.ServerInfo:Section({ Title = "Statistics" })
            local playerCountLabel = HubTabs.ServerInfo:Paragraph({ Title = "Players", Desc = #Players:GetPlayers().."/"..Players.MaxPlayers })
            local pingLabel = HubTabs.ServerInfo:Paragraph({ Title = "Ping", Desc = "Loading..." })
            HubTabs.ServerInfo:Paragraph({ Title = "Place ID", Desc = tostring(game.PlaceId), Buttons = {{ Title = "Copy", Icon = "copy", Variant = "Tertiary", Callback = function() setclipboard(tostring(game.PlaceId)) end }} })
            local success, placeInfo = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
            local placeName = success and placeInfo.Name or "Unknown"
            HubTabs.ServerInfo:Paragraph({ Title = "Place Name", Desc = placeName, Buttons = {{ Title = "Copy", Icon = "copy", Variant = "Tertiary", Callback = function() setclipboard(placeName) end }} })
            task.spawn(function()
                while task.wait(1) do
                    if Window.Destroyed then break end
                    local elapsed = os.time() - startTime; local minutes = math.floor(elapsed / 60); local seconds = elapsed % 60
                    runtimeLabel:SetDesc(string.format("%d minute(s), %d second(s)", minutes, seconds))
                    playerCountLabel:SetDesc(tostring(#Players:GetPlayers()).."/"..tostring(Players.MaxPlayers))
                    pingLabel:SetDesc(tostring(math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())).." ms")
                end
            end)
        end
        
        local WalkSpeedSlider, walkSpeedToggle, infiniteJumpToggle, noClipToggle
        do
            local movementState = { WalkSpeed = false, InfiniteJump = false, NoClip = false }
            walkSpeedToggle = HubTabs.Movement:Toggle({ Title = "Enable WalkSpeed", Value = false, Callback = function(s) movementState.WalkSpeed = s; if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = s and (tonumber(WalkSpeedSlider.Value.Default) or 16) or 16 end end })
            WalkSpeedSlider = HubTabs.Movement:Slider({ Title = "WalkSpeed Value", Value = { Min = 16, Max = 200, Default = 100 }, Step = 1, Callback = function(v) if movementState.WalkSpeed and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end end })
            infiniteJumpToggle = HubTabs.Movement:Toggle({ Title = "Enable Infinite Jump", Value = false, Callback = function(v) movementState.InfiniteJump = v end })
            game:GetService("UserInputService").JumpRequest:Connect(function() if movementState.InfiniteJump and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
            noClipToggle = HubTabs.Movement:Toggle({ Title = "Enable No Clip", Value = false, Callback = function(s) movementState.NoClip = s; if not s and player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end })
            task.spawn(function() while task.wait(0.1) do if Window.Destroyed then break end; if movementState.NoClip and player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end end)
            player.CharacterAdded:Connect(function(c) local h = c:WaitForChild("Humanoid", 5); if movementState.WalkSpeed and h then h.WalkSpeed = tonumber(WalkSpeedSlider.Value.Default) or 16 end end)
        end
        
        local lowGfxToggle
        do
            local lowGfxState = { enabled = false, originalSettings = {}, connection = nil }

            local function applyLowGfx()
                if not next(lowGfxState.originalSettings) then
                    local terrain = workspace:FindFirstChildOfClass('Terrain')
                    if terrain then
                        lowGfxState.originalSettings.WaterWaveSize = terrain.WaterWaveSize
                        lowGfxState.originalSettings.WaterWaveSpeed = terrain.WaterWaveSpeed
                        lowGfxState.originalSettings.WaterReflectance = terrain.WaterReflectance
                        lowGfxState.originalSettings.WaterTransparency = terrain.WaterTransparency
                    end
                    lowGfxState.originalSettings.GlobalShadows = Lighting.GlobalShadows
                    lowGfxState.originalSettings.FogEnd = Lighting.FogEnd
                    lowGfxState.originalSettings.FogStart = Lighting.FogStart
                end

                local terrain = workspace:FindFirstChildOfClass('Terrain')
                if terrain then
                    terrain.WaterWaveSize = 0
                    terrain.WaterWaveSpeed = 0
                    terrain.WaterReflectance = 0
                    terrain.WaterTransparency = 1
                end
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                Lighting.FogStart = 9e9
                
                for _, v in ipairs(game:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.Plastic
                        v.Reflectance = 0
                        v.CastShadow = false
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") then
                        v.Lifetime = NumberRange.new(0)
                    elseif v:IsA("Trail") then
                        v.Lifetime = 0
                    end
                end

                for _, v in ipairs(Lighting:GetChildren()) do
                    if v:IsA("PostEffect") then
                        v.Enabled = false
                    end
                end

                if lowGfxState.connection then lowGfxState.connection:Disconnect() end
                lowGfxState.connection = workspace.DescendantAdded:Connect(function(child)
                    task.spawn(function()
                        if child:IsA('ForceField') or child:IsA('Sparkles') or child:IsA('Smoke') or child:IsA('Fire') or child:IsA('Beam') then
                            child:Destroy()
                        elseif child:IsA("Decal") or child:IsA("Texture") then
                            child.Transparency = 1
                        end
                    end)
                end)
            end

            local function restoreGfx()
                if not next(lowGfxState.originalSettings) then return end

                local terrain = workspace:FindFirstChildOfClass('Terrain')
                if terrain then
                    terrain.WaterWaveSize = lowGfxState.originalSettings.WaterWaveSize
                    terrain.WaterWaveSpeed = lowGfxState.originalSettings.WaterWaveSpeed
                    terrain.WaterReflectance = lowGfxState.originalSettings.WaterReflectance
                    terrain.WaterTransparency = lowGfxState.originalSettings.WaterTransparency
                end
                Lighting.GlobalShadows = lowGfxState.originalSettings.GlobalShadows
                Lighting.FogEnd = lowGfxState.originalSettings.FogEnd
                Lighting.FogStart = lowGfxState.originalSettings.FogStart
                
                if lowGfxState.connection then
                    lowGfxState.connection:Disconnect()
                    lowGfxState.connection = nil
                end
                
                WindUI:Notify({ Title = "Graphics Restored", Content = "Rejoin for a full visual restoration of all parts.", Duration = 5 })
            end
            
            HubTabs.BoostFps:Section({ Title = "Graphics Optimization" })
            lowGfxToggle = HubTabs.BoostFps:Toggle({
                Title = "Enable Low Graphics",
                Desc = "Reduces graphics quality to improve performance. Reversible.",
                Value = false,
                Callback = function(value)
                    lowGfxState.enabled = value
                    if value then
                        applyLowGfx()
                        WindUI:Notify({ Title = "Performance", Content = "Low Graphics mode enabled.", Duration = 3 })
                    else
                        restoreGfx()
                    end
                end
            })
        end
        
        local webhookEnabledToggle, webhookTiersDropdown, webhookIdInput, webhookUrlInput
        local webhookTradeEnabledToggle, webhookTradeUrlInput, webhookTradeIdInput
        local webhookInvEnabledToggle, webhookInvDelayInput, webhookInvUrlInput, webhookInvIdInput
        do
            local webhookState = { 
                enabled = false, 
                connection = nil, 
                lastFish = "", 
                lastSend = 0,
                selectedTiers = {},
                discordId = "",
                customUrl = ""
            }
            local proxyUrl = "http://178.128.23.196:4007/notify"

            local tierMap = {
                [1] = "Common",
                [2] = "Uncommon",
                [3] = "Rare",
                [4] = "Epic",
                [5] = "Legendary",
                [6] = "Mythic",
                [7] = "SECRET"
            }
            local highTiers = {5, 6, 7}

            local function findItemModule(fullName)
                local itemsFolder = replicatedStorage:FindFirstChild("Items")
                if not itemsFolder then return nil end
                local cleanedName = fullName:gsub("%s*%b()", ""):gsub("^%s*(.-)%s*$", "%1")
                local bestMatch = nil
                local longestMatchLength = 0
                for _, itemModule in ipairs(itemsFolder:GetChildren()) do
                    if itemModule:IsA("ModuleScript") then
                        if cleanedName:find(itemModule.Name, 1, true) then
                            if #itemModule.Name > longestMatchLength then
                                longestMatchLength = #itemModule.Name
                                bestMatch = itemModule
                            end
                        end
                    end
                end
                return bestMatch
            end

            local function sendDataToProxy(data)
                task.spawn(function()
                    pcall(function()
                        data.customUrl = webhookState.customUrl
                        HttpService:RequestAsync({
                            Url = proxyUrl,
                            Method = "POST",
                            Headers = { ["Content-Type"] = "application/json" },
                            Body = HttpService:JSONEncode(data)
                        })
                    end)
                end)
            end
            
            HubTabs.WebhookFish:Section({ Title = "Discord Fish Notifications" })
            webhookEnabledToggle = HubTabs.WebhookFish:Toggle({
                Title = "Enable Fish Catch Notifications",
                Desc = "Sends a notification to Discord for high-tier fish.",
                Value = false,
                Callback = function(value)
                    webhookState.enabled = value
                    if value then
                        if webhookState.connection and webhookState.connection.Connected then return end
                        task.spawn(function()
                            local itemNameLabel, rarityLabel
                            repeat task.wait(1) 
                                local smallNotif = player.PlayerGui:FindFirstChild("Small Notification")
                                if smallNotif then
                                    local container = smallNotif:FindFirstChild("Display", true) and smallNotif.Display:FindFirstChild("Container", true)
                                    if container then
                                        itemNameLabel = container:FindFirstChild("ItemName", true)
                                        rarityLabel = container:FindFirstChild("Rarity", true)
                                    end
                                end
                            until (itemNameLabel and rarityLabel) or not webhookState.enabled
                            
                            if not webhookState.enabled then return end

                            webhookState.connection = itemNameLabel:GetPropertyChangedSignal("Text"):Connect(function()
                                if not webhookState.enabled then return end
                                
                                local currentTime = os.time()
                                if currentTime - webhookState.lastSend < 2 then return end

                                local fullFishName = itemNameLabel.Text
                                if fullFishName == "" or fullFishName == webhookState.lastFish then return end
                                
                                webhookState.lastFish = fullFishName
                                webhookState.lastSend = currentTime
                                
                                local itemModule = findItemModule(fullFishName)
                                if not itemModule then return end

                                local s, itemData = pcall(require, itemModule)
                                if not (s and itemData and itemData.Data) then return end
                                
                                local tierNumber = itemData.Data.Tier
                                if not table.find(highTiers, tierNumber) then return end
                                
                                local tierName = tierMap[tierNumber]
                                if #webhookState.selectedTiers > 0 and not table.find(webhookState.selectedTiers, tierName) then
                                    return
                                end
                                
                                local assetId = itemData.Data.Icon and itemData.Data.Icon:match("%d+")
                                local sellPrice = itemData.SellPrice
                                local rarity = rarityLabel.Text
                                local weight = fullFishName:match("%((.+)%)")
                                local cleanedFishName = fullFishName:gsub("%s*%b()%s*$", "")
                                
                                local totalCaught, bagSize = "N/A", "N/A"
                                local leaderstats = player:FindFirstChild("leaderstats")
                                if leaderstats and leaderstats:FindFirstChild("Caught") then
                                    totalCaught = tostring(leaderstats.Caught.Value)
                                end

                                local backpackGui = player.PlayerGui:WaitForChild("Backpack", 1)
                                if backpackGui then
                                    local display = backpackGui:FindFirstChild("Display")
                                    local inventory = display and display:FindFirstChild("Inventory")
                                    local bagSizeLabel = inventory and inventory:FindFirstChild("BagSize")
                                    
                                    if bagSizeLabel and bagSizeLabel:IsA("TextLabel") then
                                        bagSize = bagSizeLabel.Text
                                    end
                                end
                                
                                sendDataToProxy({
                                    discordId = webhookState.discordId,
                                    robloxUsername = player.Name,
                                    fishName = cleanedFishName,
                                    weight = weight,
                                    rarity = rarity,
                                    assetId = assetId,
                                    tierName = tierName,
                                    sellPrice = sellPrice,
                                    totalCaught = totalCaught,
                                    bagSize = bagSize
                                })
                            end)
                        end)
                    elseif not value and webhookState.connection and webhookState.connection.Connected then
                        webhookState.connection:Disconnect()
                        webhookState.connection = nil
                    end
                end
            })

            webhookTiersDropdown = HubTabs.WebhookFish:Dropdown({
                Title = "Notify for Tiers",
                Desc = "Select tiers to notify for. (None = All Legendary+)",
                Values = {"Legendary", "Mythic", "SECRET"},
                Multi = true,
                AllowNone = true,
                Callback = function(value)
                    webhookState.selectedTiers = value
                end
            })

            HubTabs.WebhookFish:Section({ Title = "Advanced Settings (Optional)" })
            webhookIdInput = HubTabs.WebhookFish:Input({
                Title = "Discord User ID (Optional)",
                Placeholder = "Enter your ID to get tagged",
                Type = "Input",
                Callback = function(value)
                    webhookState.discordId = value:match("%d+") or ""
                end
            })
            webhookUrlInput = HubTabs.WebhookFish:Input({
                Title = "Custom Webhook URL (Optional)",
                Placeholder = "Enter your own Discord webhook URL",
                Type = "Input",
                Callback = function(value)
                    webhookState.customUrl = value:match("^%s*(.-)%s*$") or ""
                end
            })
        end
        
        do
            local webhookTradeState = { enabled = false, url = "", discordId = "" }
            local proxyTradeUrl = "http://178.128.23.196:4007/notify-trade"

            function sendPerTradeWebhook(tradeData)
                if not webhookTradeState.enabled or webhookTradeState.url == "" then return end
                task.spawn(function()
                    pcall(function()
                        HttpService:RequestAsync({
                            Url = proxyTradeUrl,
                            Method = "POST",
                            Headers = { ["Content-Type"] = "application/json" },
                            Body = HttpService:JSONEncode({
                                sender = tradeData.sender,
                                receiver = tradeData.receiver,
                                itemName = tradeData.itemName,
                                progress = tradeData.progress,
                                status = tradeData.status,
                                successCount = tradeData.successCount,
                                failCount = tradeData.failCount,
                                discordId = webhookTradeState.discordId,
                                webhookUrl = webhookTradeState.url
                            })
                        })
                    end)
                end)
            end

            HubTabs.WebhookTrade:Section({ Title = "Discord Trade Notifications" })
            webhookTradeEnabledToggle = HubTabs.WebhookTrade:Toggle({
                Title = "Enable Mass Trade Notifications",
                Desc = "Sends a notification for each item in a mass trade.",
                Value = false,
                Callback = function(value)
                    webhookTradeState.enabled = value
                end
            })
            webhookTradeUrlInput = HubTabs.WebhookTrade:Input({
                Title = "Discord Webhook URL (Required)",
                Placeholder = "Enter your Discord webhook URL",
                Type = "Input",
                Callback = function(value)
                    webhookTradeState.url = value:match("^%s*(.-)%s*$") or ""
                end
            })
            webhookTradeIdInput = HubTabs.WebhookTrade:Input({
                Title = "Discord User ID (Optional)",
                Placeholder = "Enter your ID to get tagged",
                Type = "Input",
                Callback = function(value)
                    webhookTradeState.discordId = value:match("%d+") or ""
                end
            })
        end

        do
            local webhookInventoryState = { enabled = false, delay = 30, url = "", discordId = "", inventoryLoopThread = nil }
            local proxyInventoryUrl = "http://178.128.23.196:4007/notify-inventory"

            local tierMap = {
                [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic", [5] = "Legendary", [6] = "Mythic", [7] = "SECRET"
            }

            local function collectAndSendInventoryData()
                if not webhookInventoryState.enabled or webhookInventoryState.url == "" then return end

                local ItemUtility, ItemStringUtility, Replion
                local modulesLoaded = pcall(function()
                    Replion = require(replicatedStorage:WaitForChild("Packages"):WaitForChild("Replion"))
                    ItemUtility = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
                    ItemStringUtility = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("ItemStringUtility"))
                end)
                if not modulesLoaded then return end

                local DataReplion = Replion.Client:WaitReplion("Data")
                if not DataReplion then return end
                
                local inventoryItems = DataReplion:Get({"Inventory", "Items"})
                if not inventoryItems then return end

                local totalInventoryCount = #inventoryItems
                local categorizedFish = {}
                local groupedFish = {}

                for _, itemData in ipairs(inventoryItems) do
                    local baseItemData = ItemUtility:GetItemData(itemData.Id)
                    if baseItemData and baseItemData.Data and baseItemData.Data.Type == "Fishes" then
                        local dynamicName = ItemStringUtility.GetItemName(itemData, baseItemData)
                        local tierName = (baseItemData.Data.Tier and tierMap[baseItemData.Data.Tier]) or "Other"

                        if not groupedFish[tierName] then groupedFish[tierName] = {} end
                        if not groupedFish[tierName][dynamicName] then
                            groupedFish[tierName][dynamicName] = 0
                        end
                        groupedFish[tierName][dynamicName] = groupedFish[tierName][dynamicName] + 1
                    end
                end

                for tier, items in pairs(groupedFish) do
                    categorizedFish[tier] = {}
                    for name, count in pairs(items) do
                        table.insert(categorizedFish[tier], { name = name, count = count })
                    end
                    table.sort(categorizedFish[tier], function(a, b) return a.count > b.count end)
                end

                if not next(categorizedFish) then return end

                task.spawn(function()
                    pcall(function()
                        HttpService:RequestAsync({
                            Url = proxyInventoryUrl,
                            Method = "POST",
                            Headers = { ["Content-Type"] = "application/json" },
                            Body = HttpService:JSONEncode({
                                robloxUsername = player.Name,
                                discordId = webhookInventoryState.discordId,
                                webhookUrl = webhookInventoryState.url,
                                totalInventory = totalInventoryCount,
                                inventoryData = categorizedFish
                            })
                        })
                    end)
                end)
            end

            HubTabs.WebhookInventory:Section({ Title = "Discord Inventory Summary" })
            webhookInvEnabledToggle = HubTabs.WebhookInventory:Toggle({
                Title = "Enable Inventory Webhook",
                Desc = "Periodically sends a summary of your fish inventory.",
                Value = false,
                Callback = function(value)
                    webhookInventoryState.enabled = value
                    if value then
                        if webhookInventoryState.url == "" then
                            WindUI:Notify({Title = "Error", Content = "Webhook URL is required.", Duration = 4})
                            webhookInventoryState.enabled = false
                            return
                        end
                        if webhookInventoryState.inventoryLoopThread then task.cancel(webhookInventoryState.inventoryLoopThread) end
                        
                        collectAndSendInventoryData()
                        
                        webhookInventoryState.inventoryLoopThread = task.spawn(function()
                            while webhookInventoryState.enabled do
                                task.wait(webhookInventoryState.delay * 60)
                                if not webhookInventoryState.enabled then break end
                                collectAndSendInventoryData()
                            end
                        end)
                    else
                        if webhookInventoryState.inventoryLoopThread then
                            task.cancel(webhookInventoryState.inventoryLoopThread)
                            webhookInventoryState.inventoryLoopThread = nil
                        end
                    end
                end
            })

            webhookInvDelayInput = HubTabs.WebhookInventory:Input({
                Title = "Webhook Delay (minutes)",
                Placeholder = "Default: 30",
                Type = "Input",
                Callback = function(value)
                    local num = tonumber(value)
                    webhookInventoryState.delay = (num and num > 0) and num or 30
                end
            })

            webhookInvUrlInput = HubTabs.WebhookInventory:Input({
                Title = "Discord Webhook URL (Required)",
                Placeholder = "Enter your Discord webhook URL",
                Type = "Input",
                Callback = function(value)
                    webhookInventoryState.url = value:match("^%s*(.-)%s*$") or ""
                end
            })

            webhookInvIdInput = HubTabs.WebhookInventory:Input({
                Title = "Discord User ID (Optional)",
                Placeholder = "Enter your ID to get tagged",
                Type = "Input",
                Callback = function(value)
                    webhookInventoryState.discordId = value:match("%d+") or ""
                end
            })
        end

        do
            local GameTabs = {
                Farming = GameSection:Tab({ Title = "Farming", Icon = "fish", ShowTabTitle = true }),
                Edit_Stats = GameSection:Tab({ Title = "Edit Stats", Icon = "file-pen", ShowTabTitle = true }),
                Auto_Trade = GameSection:Tab({ Title = "Auto Trade", Icon = "repeat", ShowTabTitle = true }),
                Auto_Favorite = GameSection:Tab({ Title = "Auto Favorite", Icon = "star", ShowTabTitle = true }),
                Auto_Enchant = GameSection:Tab({ Title = "Auto Enchant", Icon = "sparkles", ShowTabTitle = true }),
                Auto_TP_Event = GameSection:Tab({ Title = "Auto TP Event", Icon = "radio-tower", ShowTabTitle = true }),
                Spawn_Boat = GameSection:Tab({ Title = "Spawn Boat", Icon = "ship", ShowTabTitle = true }),
                Buy_Rod = GameSection:Tab({ Title = "Buy Rod", Icon = "anchor", ShowTabTitle = true }),
                Buy_Weather = GameSection:Tab({ Title = "Buy Weather", Icon = "cloud", ShowTabTitle = true }),
                Buy_Baits = GameSection:Tab({ Title = "Buy Baits", Icon = "bug", ShowTabTitle = true }),
                Buy_Gears = GameSection:Tab({ Title = "Buy Gears", Icon = "shopping-bag", ShowTabTitle = true }),
                TP_Islands = GameSection:Tab({ Title = "TP Islands", Icon = "map-pin", ShowTabTitle = true }),
                TP_Shop = GameSection:Tab({ Title = "TP Shop", Icon = "shopping-cart", ShowTabTitle = true }),
                TP_NPC = GameSection:Tab({ Title = "TP NPC", Icon = "users", ShowTabTitle = true }),
                TP_Player = GameSection:Tab({ Title = "TP Player", Icon = "user-round-search", ShowTabTitle = true })
            }

            local featureState = { AutoFish = false, LockPosition = false, AutoSellMode = "Disabled", AutoSellOnEquip = false, AutoTradeOnEquip = false, AutoSellDelay = 1800, AutoAcceptTrade = false }
            local statValues = { FishingLuck = nil, ShinyChance = nil, MutationChance = nil }
            local tradeState = { selectedPlayerName = nil, selectedPlayerId = nil, selectedItemName = nil, tradeAmount = 0, autoTradeV2 = false, filterUnfavorited = false }
            local savedLockPosition = nil
            local selectedAutoFishMethod = "V2"
            local lastSellTime = 0
            
            local eventTPState = { enabled = false, selectedEvent = nil, originalPosition = nil, platform = nil, wasAutoFishing = false, isAtEvent = false }
            
            local autoFishToggle, lockPositionToggle, autoFishMethodDropdown
            local autoSellModeDropdown, autoSellDelayInput
            local autoBuyWeatherToggle, autoBuyWeatherDropdown
            local favTiersDropdown, autoFavToggle, favDelaySlider, unfavTiersDropdown
            local autoTPEventToggle, autoTPEventDropdown
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
                    if featureState.AutoFish then
                        return
                    end
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

            local function startAutoFishMethod_V1_Stable()
                task.spawn(function()
                    local netFolder = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
                    local equipEvent = netFolder:WaitForChild("RE/EquipToolFromHotbar")

                    while featureState.AutoFish and player do
                        pcall(function()
                            if FishingController and FishingController.OnCooldown and FishingController:OnCooldown() then
                                task.wait(0.5)
                                return
                            end
                            
                            playCastingAnimation()
                            equipEvent:FireServer(1)
                            task.wait(0.1)
                            
                            netFolder:WaitForChild("RF/ChargeFishingRod"):InvokeServer(1752984487.133336)
                            task.wait(0.1)
                            netFolder:WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(-0.7499996423721313, 1)
                            task.wait(0.2)
                            
                            local sellFunc = netFolder:WaitForChild("RF/SellAllItems")
                            if featureState.AutoSellMode == "Auto Sell All (No TP)" then
                                if os.time() - lastSellTime >= featureState.AutoSellDelay then
                                    task.spawn(sellFunc.InvokeServer, sellFunc)
                                    lastSellTime = os.time()
                                end
                            end
                            
                            local fishingCompletedEvent = netFolder:WaitForChild("RE/FishingCompleted")
                            for i = 1, 25 do
                                if not featureState.AutoFish then break end
                                fishingCompletedEvent:FireServer()
                                task.wait(0.1)
                            end
                        end)
                        if featureState.AutoFish then task.wait(1) end
                    end
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
                        
                        local sellFunc = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems")
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
            
            local function startAutoFishMethod_V3_EventDriven()
                task.spawn(function()
                    local netFolder = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
                    local equipEvent = netFolder:WaitForChild("RE/EquipToolFromHotbar")
                    local chargeFunc = netFolder:WaitForChild("RF/ChargeFishingRod")
                    local startMinigameFunc = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
                    local completeEvent = netFolder:WaitForChild("RE/FishingCompleted")
                    local fishCaughtEvent = netFolder:WaitForChild("RE/FishCaught")

                    local function castSequence()
                        if not featureState.AutoFish then return end

                        if timeoutThread then task.cancel(timeoutThread); timeoutThread = nil end
                        
                        pcall(function()
                            playCastingAnimation()
                            equipEvent:FireServer(1)
                            task.wait(0.1)

                            chargeFunc:InvokeServer(workspace:GetServerTimeNow())
                            task.wait(0.1)
                            startMinigameFunc:InvokeServer(-0.75, 1)
                            task.wait(0.2)
                            
                            local sellFunc = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems")
                            if featureState.AutoSellMode == "Auto Sell All (No TP)" then
                                if os.time() - lastSellTime >= featureState.AutoSellDelay then
                                    task.spawn(sellFunc.InvokeServer, sellFunc)
                                    lastSellTime = os.time()
                                end
                            end
                            
                            for i = 1, 25 do
                                if not featureState.AutoFish then break end
                                completeEvent:FireServer()
                                task.wait(0.1)
                            end
                        end)

                        timeoutThread = task.delay(20, function()
                            if featureState.AutoFish and selectedAutoFishMethod == "V3" then
                                castSequence()
                            end
                        end)
                    end
            
                    if autoFishV3Connection and autoFishV3Connection.Connected then
                        autoFishV3Connection:Disconnect()
                    end
            
                    autoFishV3Connection = fishCaughtEvent.OnClientEvent:Connect(function()
                        if featureState.AutoFish and selectedAutoFishMethod == "V3" then
                            if timeoutThread then task.cancel(timeoutThread); timeoutThread = nil end
                            task.wait(0.5)
                            castSequence()
                        end
                    end)
            
                    castSequence()
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
            
            local function startAutoFishProcess()
                lastSellTime = os.time()
                if selectedAutoFishMethod == "V1" then
                    startAutoFishMethod_V1_Stable()
                elseif selectedAutoFishMethod == "V2" then
                    startAutoFishMethod_V2_Smart()
                elseif selectedAutoFishMethod == "V3" then
                    startAutoFishMethod_V3_EventDriven()
                end
            end

            GameTabs.Farming:Section({ Title = "Auto Features" })
            
            autoFishMethodDropdown = GameTabs.Farming:Dropdown({
                Title = "Select Auto Fish Method",
                Values = {"Auto Fish V1 (Stable) (Slower)", "Auto Fish V2 (Recommended) (Faster)", "Auto Fish V3 (Beta) (Faster+)"},
                Value = "Auto Fish V2 (Recommended) (Faster)",
                Callback = function(value)
                    if value == "Auto Fish V1 (Stable) (Slower)" then
                        selectedAutoFishMethod = "V1"
                    elseif value == "Auto Fish V3 (Beta) (Faster+)" then
                         selectedAutoFishMethod = "V3"
                    else
                        selectedAutoFishMethod = "V2"
                    end
                end
            })

            autoFishToggle = GameTabs.Farming:Toggle({
                Title = "Enable Auto Fish", Desc = "Uses a smart, fast, and reliable method.", Value = false,
                Callback = function(value)
                    featureState.AutoFish = value
                    if value then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            savedLockPosition = player.Character.HumanoidRootPart.CFrame
                        end
                        startAutoFishProcess()
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
                    
                    hrp.CFrame = CFrame.new(56.78, 17.41, 2880.67)
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
                        featureState.AutoSellDelay = 1800 
                    end
                end
            })
            
            local oldNamecall
            local function UpdateHook()
                if (featureState.AutoSellOnEquip or featureState.AutoTradeOnEquip) and not oldNamecall then
                    pcall(function()
                        local netFolder = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
                        local equipItemEvent = netFolder:WaitForChild("RE/EquipItem")
                        local sellItemFunc = netFolder:WaitForChild("RF/SellItem")
                        local initiateTradeFunc = netFolder:WaitForChild("RF/InitiateTrade")
                        
                        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                            if featureState.AutoTradeOnEquip and self == equipItemEvent and tradeState.selectedPlayerId and getnamecallmethod() == "FireServer" then
                                local args = {...}
                                local itemId = args[1]
                                if type(itemId) == "string" then
                                    task.spawn(function()
                                        local tradeArgs = {tradeState.selectedPlayerId, itemId}
                                        initiateTradeFunc:InvokeServer(unpack(tradeArgs))
                                    end)
                                    return nil 
                                end
                            end
                            
                            local originalReturn = oldNamecall(self, ...)

                            if featureState.AutoSellOnEquip and self == equipItemEvent and getnamecallmethod() == "FireServer" then
                                local args = {...}
                                local itemId = args[1]
                                if type(itemId) == "string" then
                                    task.spawn(function()
                                        task.wait(0.1) 
                                        if featureState.AutoSellOnEquip then
                                            pcall(sellItemFunc.InvokeServer, sellItemFunc, itemId)
                                        end
                                    end)
                                end
                            end
                            
                            return originalReturn
                        end)
                    end)
                elseif not featureState.AutoSellOnEquip and not featureState.AutoTradeOnEquip and oldNamecall then
                    if unhookmetamethod then
                        unhookmetamethod(game, "__namecall")
                        oldNamecall = nil
                    end
                end
            end

            GameTabs.Farming:Toggle({
                Title = "Auto Sell Equipped Fish", Desc = "Warning: Make sure to click the fish you want to sell", Value = false,
                Callback = function(value)
                    featureState.AutoSellOnEquip = value
                    UpdateHook()
                end
            })
            
            GameTabs.Edit_Stats:Section({ Title = "Edit Visual Stats" })
            GameTabs.Edit_Stats:Input({ Title = "Fishing Luck", Placeholder = "Enter a number (e.g., 99999)", Type = "Input", Callback = function(v) statValues.FishingLuck = tonumber(v) end })
            GameTabs.Edit_Stats:Button({ Title = "Set Fishing Luck", Callback = function() end })
            GameTabs.Edit_Stats:Input({ Title = "Shiny Chance", Placeholder = "Enter a number (e.g., 99999)", Type = "Input", Callback = function(v) statValues.ShinyChance = tonumber(v) end })
            GameTabs.Edit_Stats:Button({ Title = "Set Shiny Chance", Callback = function() end })
            GameTabs.Edit_Stats:Input({ Title = "Mutation Chance", Placeholder = "Enter a number (e.g., 99999)", Type = "Input", Callback = function(v) statValues.MutationChance = tonumber(v) end })
            GameTabs.Edit_Stats:Button({ Title = "Set Mutation Chance", Callback = function() end })
            GameTabs.Edit_Stats:Section({ Title = "Rod Modifier" })
            GameTabs.Edit_Stats:Button({
                Title = "Apply Max Stats to Skinned Rod", Desc = "Modifies the stats of your currently equipped skinned rod.",
                Callback = function()
                    local backpackDisplay = player.PlayerGui:FindFirstChild("Backpack", true) and player.PlayerGui.Backpack:FindFirstChild("Display", true)
                    if not backpackDisplay then return end
                    local itemsFolder = replicatedStorage:FindFirstChild("Items")
                    if not itemsFolder then return end
                    for _, tile in ipairs(backpackDisplay:GetChildren()) do
                        if tile.Name == "Tile" then
                            local skinActiveLabel = tile:FindFirstChild("Inner", true) and tile.Inner:FindFirstChild("Tags", true) and tile.Inner.Tags:FindFirstChild("SkinActive", true)
                            local itemNameLabel = tile:FindFirstChild("Inner", true) and tile.Inner:FindFirstChild("Tags", true) and tile.Inner.Tags:FindFirstChild("ItemName", true)
                            if skinActiveLabel and itemNameLabel and skinActiveLabel.Text == "★ SKIN ★" then
                                local moduleName = "!!! " .. itemNameLabel.Text
                                local rodModule = itemsFolder:FindFirstChild(moduleName)
                                if rodModule then
                                    local success, rodData = pcall(require, rodModule)
                                    if success and type(rodData) == "table" then
                                        rodData.VisualClickPowerPercent, rodData.MaxWeight = 99999999, 99999999
                                        if rodData.RollData then rodData.RollData.BaseLuck = 99999999 end
                                     end
                                end
                            end
                        end
                    end
                end
            })

            do
                GameTabs.Auto_Trade:Section({ Title = "Auto Trade v1 (Click to Trade)" })
                local function getPlayerList() local list = {}; for _, p in ipairs(Players:GetPlayers()) do if p ~= player then table.insert(list, p.Name) end end; table.sort(list); return list end
                local playerDropdownV1 = GameTabs.Auto_Trade:Dropdown({ Title = "Select Player", Values = getPlayerList(), AllowNone = true, Callback = function(v) 
                    tradeState.selectedPlayerName = v
                    if v then
                        local targetPlayer = Players:FindFirstChild(v)
                        tradeState.selectedPlayerId = targetPlayer and targetPlayer.UserId or nil
                    else
                        tradeState.selectedPlayerId = nil
                    end
                end })
                
                GameTabs.Auto_Trade:Toggle({
                    Title = "Enable Auto Trade on Equip",
                    Desc = "Clicking an item in your inventory will initiate a trade instead of equipping it.",
                    Value = false,
                    Callback = function(value)
                        featureState.AutoTradeOnEquip = value
                        UpdateHook()
                    end
                })
                Players.PlayerAdded:Connect(function() if playerDropdownV1 and not playerDropdownV1.Opened then playerDropdownV1:Refresh(getPlayerList()) end end)
                Players.PlayerRemoving:Connect(function() if playerDropdownV1 and not playerDropdownV1.Opened then playerDropdownV1:Refresh(getPlayerList()) end end)
            end
            
            do
                GameTabs.Auto_Trade:Section({ Title = "Auto Trade v2 (Mass Send)" })

                local ItemUtility, ItemStringUtility, Replion, Promise, PromptController
                local modulesLoaded = pcall(function()
                    Replion = require(replicatedStorage:WaitForChild("Packages"):WaitForChild("Replion"))
                    Promise = require(replicatedStorage:WaitForChild("Packages"):WaitForChild("Promise"))
                    ItemUtility = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
                    ItemStringUtility = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("ItemStringUtility"))
                    PromptController = require(replicatedStorage:WaitForChild("Controllers"):WaitForChild("PromptController"))
                end)
                if not modulesLoaded then 
                    GameTabs.Auto_Trade:Paragraph({ Title = "Error", Desc = "Failed to load essential modules for this feature."})
                    return 
                end

                local inventoryCache = {}
                local fullInventoryDropdownList = {}

                local itemSearchInput = GameTabs.Auto_Trade:Input({ Title = "Search Item (Optional)", Placeholder = "e.g., Hirjim", Type = "Input", Callback = function() end })
                local filterToggle = GameTabs.Auto_Trade:Toggle({ Title = "Filter Unfavorited Items Only", Value = false, Callback = function(val) tradeState.filterUnfavorited = val end })
                local inventoryDropdown = GameTabs.Auto_Trade:Dropdown({ Title = "Select Item from Inventory", Values = {"- Refresh to load -"}, AllowNone = true, Callback = function(val)
                    tradeState.selectedItemName = val
                end})

                local function filterInventoryDropdown(searchText)
                    searchText = searchText and searchText:lower() or ""
                    if searchText == "" then
                        inventoryDropdown:Refresh(fullInventoryDropdownList)
                        return
                    end
                    
                    local filteredList = {}
                    for _, itemName in ipairs(fullInventoryDropdownList) do
                        if itemName:lower():find(searchText, 1, true) then
                            table.insert(filteredList, itemName)
                        end
                    end
                    inventoryDropdown:Refresh(filteredList)
                end

                itemSearchInput.Callback = filterInventoryDropdown

                local function getPlayerListV2() local list = {}; for _, p in ipairs(Players:GetPlayers()) do if p ~= player then table.insert(list, p.Name) end end; table.sort(list); return list end

                local playerDropdownV2 = GameTabs.Auto_Trade:Dropdown({ Title = "Select Player to Send", Values = getPlayerListV2(), AllowNone = true, Callback = function(v) 
                    tradeState.selectedPlayerName = v
                    if v then
                        local targetPlayer = Players:FindFirstChild(v)
                        tradeState.selectedPlayerId = targetPlayer and targetPlayer.UserId or nil
                    else
                        tradeState.selectedPlayerId = nil
                    end
                end })

                local function refreshInventory()
                    local DataReplion = Replion.Client:WaitReplion("Data")
                    if not DataReplion then return end
                    local inventoryItems = DataReplion:Get({"Inventory", "Items"})
                    local groupedItems = {}
                    inventoryCache = {}
                    fullInventoryDropdownList = {}

                    for _, itemData in ipairs(inventoryItems) do
                        if tradeState.filterUnfavorited and itemData.Favorited then continue end
                        local baseItemData = ItemUtility:GetItemData(itemData.Id)
                        if baseItemData then
                            local dynamicName = ItemStringUtility.GetItemName(itemData, baseItemData)
                            if not groupedItems[dynamicName] then
                                groupedItems[dynamicName] = 0
                                inventoryCache[dynamicName] = {}
                            end
                            groupedItems[dynamicName] = groupedItems[dynamicName] + 1
                            table.insert(inventoryCache[dynamicName], itemData.UUID)
                        end
                    end
                    
                    for name, count in pairs(groupedItems) do
                        table.insert(fullInventoryDropdownList, string.format("%s (%dx)", name, count))
                    end
                    table.sort(fullInventoryDropdownList)
                    
                    filterInventoryDropdown(itemSearchInput.Value)
                    playerDropdownV2:Refresh(getPlayerListV2())
                end

                filterToggle.Callback = function(val)
                    tradeState.filterUnfavorited = val
                    refreshInventory()
                end

                GameTabs.Auto_Trade:Button({Title = "Refresh Inventory & Players", Callback = refreshInventory})
                
                local amountInput = GameTabs.Auto_Trade:Input({Title = "Amount to Trade", Placeholder = "e.g., 5", Type="Input", Callback = function(val)
                    tradeState.tradeAmount = tonumber(val) or 0
                end})

                Players.PlayerAdded:Connect(function() if playerDropdownV2 and not playerDropdownV2.Opened then playerDropdownV2:Refresh(getPlayerListV2()) end end)
                Players.PlayerRemoving:Connect(function() if playerDropdownV2 and not playerDropdownV2.Opened then playerDropdownV2:Refresh(getPlayerListV2()) end end)

                local statusParagraph = GameTabs.Auto_Trade:Paragraph({Title = "Status", Desc = "Waiting to start..."})
                
                GameTabs.Auto_Trade:Toggle({
                    Title = "Start Mass Trade",
                    Value = false,
                    Callback = function(value)
                        tradeState.autoTradeV2 = value
                        if value then
                            task.spawn(function()
                                if not tradeState.selectedItemName or not tradeState.selectedPlayerId or tradeState.tradeAmount <= 0 then
                                    statusParagraph:SetDesc("Error: Please select an item, amount, and player.")
                                    tradeState.autoTradeV2 = false
                                    return
                                end

                                local cleanItemName = tradeState.selectedItemName:match("^(.*)%s%(%d+x%)$")
                                local uuidsToSend = inventoryCache[cleanItemName]
                                
                                if not uuidsToSend or #uuidsToSend < tradeState.tradeAmount then
                                    statusParagraph:SetDesc("Error: Not enough items or item not found in cache.")
                                    tradeState.autoTradeV2 = false
                                    return
                                end

                                local initiateTradeFunc = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/InitiateTrade")
                                local successCount, failCount = 0, 0
                                
                                for i = 1, tradeState.tradeAmount do
                                    if not tradeState.autoTradeV2 then 
                                        statusParagraph:SetDesc("Process stopped by user.")
                                        break 
                                    end
                                    
                                    local uuid = uuidsToSend[i]
                                    local targetName = tradeState.selectedPlayerName
                                    statusParagraph:SetDesc(string.format("Progress: %d/%d\nSending to: %s\nStatus: <font color='#eab308'>Waiting for server...</font>\nSuccess: %d | Failed: %d", i, tradeState.tradeAmount, targetName, successCount, failCount))
                                    
                                    local success, result = pcall(initiateTradeFunc.InvokeServer, initiateTradeFunc, tradeState.selectedPlayerId, uuid)
                                    
                                    local statusText
                                    if success and result then
                                        successCount = successCount + 1
                                        statusText = "Accepted"
                                        statusParagraph:SetDesc(string.format("Progress: %d/%d\nSending to: %s\nStatus: <font color='#4ade80'>Accepted</font>\nSuccess: %d | Failed: %d", i, tradeState.tradeAmount, targetName, successCount, failCount))
                                    else
                                        failCount = failCount + 1
                                        statusText = "Rejected"
                                        statusParagraph:SetDesc(string.format("Progress: %d/%d\nSending to: %s\nStatus: <font color='#f87171'>Rejected</font>\nSuccess: %d | Failed: %d", i, tradeState.tradeAmount, targetName, successCount, failCount))
                                    end

                                    sendPerTradeWebhook({
                                        sender = player.Name,
                                        receiver = tradeState.selectedPlayerName,
                                        itemName = cleanItemName,
                                        progress = string.format("%d/%d", i, tradeState.tradeAmount),
                                        status = statusText,
                                        successCount = successCount,
                                        failCount = failCount
                                    })

                                    task.wait(5) 
                                end
                                statusParagraph:SetDesc(string.format("Process Complete.\nTotal Sent: %d\nSuccessful: %d | Failed: %d", successCount + failCount, successCount, failCount))
                                
                                tradeState.autoTradeV2 = false
                                refreshInventory()
                            end)
                        end
                    end
                })

                GameTabs.Auto_Trade:Section({ Title = "Auto Accept Trade" })
                local autoAcceptTradeToggle = GameTabs.Auto_Trade:Toggle({
                    Title = "Enable Auto Accept Trade",
                    Desc = "Automatically accepts incoming trade requests from other players.",
                    Value = false,
                    Callback = function(value)
                        featureState.AutoAcceptTrade = value
                    end
                })

                if modulesLoaded and PromptController and Promise then
                    local oldFirePrompt
                    oldFirePrompt = hookfunction(PromptController.FirePrompt, function(self, promptText, ...)
                        if featureState.AutoAcceptTrade and type(promptText) == "string" and promptText:find("Accept") and promptText:find("from:") then
                            return Promise.resolve(true)
                        end
                        return oldFirePrompt(self, promptText, ...)
                    end)
                else
                    GameTabs.Auto_Trade:Paragraph({Title = "Auto Accept Failed", Desc = "Could not hook trade prompt."})
                end
            end

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
                    if not modulesLoaded then statusParagraph:SetDesc("Error: Gagal memuat modul penting."); return end
                    statusParagraph:SetDesc("Memindai inventaris...")
                    local DataReplion = Replion.Client:WaitReplion("Data")
                    if not DataReplion then statusParagraph:SetDesc("Error: Gagal mendapatkan data pemain."); return end
                    local inventoryItems = DataReplion:Get({"Inventory", "Items"})
                    if not inventoryItems then statusParagraph:SetDesc("Inventaris kosong."); return end
                    
                    local favoriteQueue = {}
                    for _, itemData in ipairs(inventoryItems) do
                        if not itemData.Favorited then
                            local baseItemData = ItemUtility:GetItemData(itemData.Id)
                            if baseItemData and baseItemData.Data and baseItemData.Data.Tier and table.find(favoriteState.selectedTiers, baseItemData.Data.Tier) then
                                table.insert(favoriteQueue, itemData.UUID)
                            end
                        end
                    end

                    if #favoriteQueue == 0 then statusParagraph:SetDesc("Selesai. Tidak ada item baru untuk difavoritkan."); return end
                    statusParagraph:SetDesc(string.format("Menemukan %d item untuk difavoritkan. Memproses...", #favoriteQueue))
                    local favoriteEvent = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/FavoriteItem")
                    for i, uuid in ipairs(favoriteQueue) do
                        if not isManualRun and not favoriteState.enabled then break end
                        local args = {uuid}
                        favoriteEvent:FireServer(unpack(args))
                        statusParagraph:SetDesc(string.format("Memfavoritkan... (%d/%d)", i, #favoriteQueue))
                        task.wait(0.2)
                    end
                    statusParagraph:SetDesc(string.format("Selesai. %d item telah difavoritkan.", #favoriteQueue))
                end
                
                local function processUnfavoriteAllLogic()
                    if not statusParagraph then return end
                    local Replion = require(replicatedStorage:WaitForChild("Packages"):WaitForChild("Replion"))
                    statusParagraph:SetDesc("Memindai item yang difavoritkan...")
                    local DataReplion = Replion.Client:WaitReplion("Data")
                    if not DataReplion then statusParagraph:SetDesc("Error: Gagal mendapatkan data pemain."); return end
                    local inventoryItems = DataReplion:Get({"Inventory", "Items"})
                    if not inventoryItems then statusParagraph:SetDesc("Inventaris kosong."); return end
                    
                    local unfavoriteQueue = {}
                    for _, itemData in ipairs(inventoryItems) do
                        if itemData.Favorited then
                            table.insert(unfavoriteQueue, itemData.UUID)
                        end
                    end

                    if #unfavoriteQueue == 0 then statusParagraph:SetDesc("Selesai. Tidak ada item yang difavoritkan."); return end
                    statusParagraph:SetDesc(string.format("Menemukan %d item untuk di-unfavorite. Memproses...", #unfavoriteQueue))
                    local favoriteEvent = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/FavoriteItem")
                    for i, uuid in ipairs(unfavoriteQueue) do
                        local args = {uuid}
                        favoriteEvent:FireServer(unpack(args))
                        statusParagraph:SetDesc(string.format("Meng-unfavorite... (%d/%d)", i, #unfavoriteQueue))
                        task.wait(0.2)
                    end
                    statusParagraph:SetDesc(string.format("Selesai. %d item telah di-unfavorite.", #unfavoriteQueue))
                end

                local function processUnfavoriteByTierLogic()
                    if not statusParagraph then return end
                    local ItemUtility, Replion = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility")), require(replicatedStorage:WaitForChild("Packages"):WaitForChild("Replion"))
                    if #favoriteState.selectedUnfavoriteTiers == 0 then statusParagraph:SetDesc("Pilih tier terlebih dahulu untuk di-unfavorite."); return end
                    statusParagraph:SetDesc("Memindai inventaris untuk unfavorite berdasarkan tier...")
                    local DataReplion = Replion.Client:WaitReplion("Data")
                    if not DataReplion then statusParagraph:SetDesc("Error: Gagal mendapatkan data pemain."); return end
                    local inventoryItems = DataReplion:Get({"Inventory", "Items"})
                    if not inventoryItems then statusParagraph:SetDesc("Inventaris kosong."); return end

                    local unfavoriteQueue = {}
                    for _, itemData in ipairs(inventoryItems) do
                        if itemData.Favorited then
                            local baseItemData = ItemUtility:GetItemData(itemData.Id)
                            if baseItemData and baseItemData.Data and baseItemData.Data.Tier and table.find(favoriteState.selectedUnfavoriteTiers, baseItemData.Data.Tier) then
                                table.insert(unfavoriteQueue, itemData.UUID)
                            end
                        end
                    end

                    if #unfavoriteQueue == 0 then statusParagraph:SetDesc("Tidak ada item favorit yang cocok dengan tier yang dipilih."); return end
                    statusParagraph:SetDesc(string.format("Menemukan %d item untuk di-unfavorite. Memproses...", #unfavoriteQueue))
                    local favoriteEvent = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/FavoriteItem")
                    for i, uuid in ipairs(unfavoriteQueue) do
                        local args = {uuid}
                        favoriteEvent:FireServer(unpack(args))
                        statusParagraph:SetDesc(string.format("Meng-unfavorite... (%d/%d)", i, #unfavoriteQueue))
                        task.wait(0.2)
                    end
                    statusParagraph:SetDesc(string.format("Selesai. %d item telah di-unfavorite.", #unfavoriteQueue))
                end

                GameTabs.Auto_Favorite:Section({ Title = "Favorite by Tier" })
                favTiersDropdown = GameTabs.Auto_Favorite:Dropdown({
                    Title = "Select Tiers to Favorite", Values = tierNames, Multi = true, AllowNone = true,
                    Callback = function(selectedNames)
                        favoriteState.selectedTiers = {}
                        for _, name in ipairs(selectedNames) do if tierMap[name] then table.insert(favoriteState.selectedTiers, tierMap[name]) end end
                    end
                })
                autoFavToggle = GameTabs.Auto_Favorite:Toggle({
                    Title = "Enable Auto Favorite", Desc = "Automatically favorites items based on selected tiers.", Value = false,
                    Callback = function(value)
                        favoriteState.enabled = value
                        if value then task.spawn(function() while favoriteState.enabled do processFavoriteLogic(false); task.wait(favoriteState.delay) end end) end
                    end
                })
                favDelaySlider = GameTabs.Auto_Favorite:Slider({
                    Title = "Delay (seconds)", Value = { Min = 1, Max = 60, Default = 5 }, Step = 1,
                    Callback = function(value) 
                        favoriteState.delay = tonumber(value) or 5 
                    end
                })
                GameTabs.Auto_Favorite:Button({ Title = "Favorite Now", Desc = "Run the favorite process once manually.", Icon = "star", Callback = function() processFavoriteLogic(true) end })

                GameTabs.Auto_Favorite:Section({ Title = "Unfavorite Items" })
                unfavTiersDropdown = GameTabs.Auto_Favorite:Dropdown({
                    Title = "Select Tiers to Unfavorite", Values = tierNames, Multi = true, AllowNone = true,
                    Callback = function(selectedNames)
                        favoriteState.selectedUnfavoriteTiers = {}
                        for _, name in ipairs(selectedNames) do if tierMap[name] then table.insert(favoriteState.selectedUnfavoriteTiers, tierMap[name]) end end
                    end
                })
                GameTabs.Auto_Favorite:Button({ Title = "Unfavorite by Selected Tiers", Icon = "star-off", Callback = processUnfavoriteByTierLogic })
                GameTabs.Auto_Favorite:Button({ Title = "Unfavorite All Items", Icon = "trash-2", Callback = processUnfavoriteAllLogic })
                
                statusParagraph = GameTabs.Auto_Favorite:Paragraph({Title = "Status", Desc = "Menunggu untuk memulai..."})
            end
            
            do
                local autoEnchantState = { enabled = false, targetEnchant = nil, stoneLimit = math.huge, stonesUsed = 0 }
                local enchantStatusParagraph, enchantStoneCountParagraph

                local function getEnchantmentList()
                    local enchants = {}
                    local success, enchantsModule = pcall(require, replicatedStorage:WaitForChild("Enchants"))
                    if success then
                        for name, data in pairs(enchantsModule) do
                            if type(data) == "table" and data.Data and data.Data.Name then
                                table.insert(enchants, data.Data.Name)
                            end
                        end
                    end
                    table.sort(enchants)
                    return enchants
                end
                
                GameTabs.Auto_Enchant:Section({ Title = "Auto Enchantment" })
                
                GameTabs.Auto_Enchant:Dropdown({
                    Title = "Select Target Enchantment",
                    Values = getEnchantmentList(),
                    AllowNone = true,
                    Callback = function(value)
                        autoEnchantState.targetEnchant = value
                    end
                })

                GameTabs.Auto_Enchant:Input({
                    Title = "Max Enchant Stones to Use",
                    Placeholder = "Leave empty for no limit",
                    Type = "Input",
                    Callback = function(value)
                        local num = tonumber(value)
                        autoEnchantState.stoneLimit = (num and num > 0) and num or math.huge
                    end
                })
                
                enchantStoneCountParagraph = GameTabs.Auto_Enchant:Paragraph({ Title = "Stones Owned", Desc = "Loading..." })
                enchantStatusParagraph = GameTabs.Auto_Enchant:Paragraph({ Title = "Status", Desc = "Idle. Make sure to equip a fishing rod." })

                task.spawn(function()
                    while task.wait(5) do
                        if Window.Destroyed then break end
                        pcall(function()
                            local Replion = require(replicatedStorage.Packages.Replion)
                            local ItemUtility = require(replicatedStorage.Shared.ItemUtility)
                            local DataReplion = Replion.Client:WaitReplion("Data")
                            local inventoryItems = DataReplion:Get({"Inventory", "Items"})
                            local count = 0
                            if inventoryItems then
                                for _, itemData in ipairs(inventoryItems) do
                                    local baseItemData = ItemUtility:GetItemData(itemData.Id)
                                    if baseItemData and baseItemData.Data and baseItemData.Data.Type == "EnchantStones" then
                                        count = count + (itemData.Quantity or 1)
                                    end
                                end
                            end
                            enchantStoneCountParagraph:SetDesc("You have: " .. count .. " stones")
                        end)
                    end
                end)

                GameTabs.Auto_Enchant:Toggle({
                    Title = "Enable Auto Enchant",
                    Value = false,
                    Callback = function(value)
                        autoEnchantState.enabled = value
                        if value then
                            task.spawn(function()
                                if not autoEnchantState.targetEnchant then
                                    enchantStatusParagraph:SetDesc("Error: Please select a target enchantment.")
                                    autoEnchantState.enabled = false
                                    return
                                end

                                local ItemUtility = require(replicatedStorage.Shared.ItemUtility)
                                local Replion = require(replicatedStorage.Packages.Replion)
                                local DataReplion = Replion.Client:WaitReplion("Data")

                                local function getEquippedRod()
                                    local equippedId = DataReplion:Get("EquippedId")
                                    if not equippedId or equippedId == "" then return nil end
                                    
                                    local inventory = DataReplion:Get({"Inventory", "Fishing Rods"})
                                    for _, item in ipairs(inventory) do
                                        if item.UUID == equippedId then
                                            local itemData = ItemUtility:GetItemData(item.Id)
                                            if itemData and itemData.Data.Type == "Fishing Rods" then
                                                return item, itemData
                                            end
                                        end
                                    end
                                    return nil
                                end
                                
                                local function getStoneCount()
                                    local inventoryItems = DataReplion:Get({"Inventory", "Items"})
                                    local count = 0
                                    if inventoryItems then
                                        for _, itemData in ipairs(inventoryItems) do
                                            local baseItemData = ItemUtility:GetItemData(itemData.Id)
                                            if baseItemData and baseItemData.Data and baseItemData.Data.Type == "EnchantStones" then
                                                count = count + (itemData.Quantity or 1)
                                            end
                                        end
                                    end
                                    return count
                                end

                                local equippedRod, _ = getEquippedRod()
                                if not equippedRod then
                                    enchantStatusParagraph:SetDesc("Error: No fishing rod equipped.")
                                    autoEnchantState.enabled = false
                                    return
                                end

                                autoEnchantState.stonesUsed = 0
                                local applyEnchantFunc = replicatedStorage.Packages["_Index"]["sleitnick_net@0.2.0"].net["RF/ApplyEnchantment"]

                                while autoEnchantState.enabled do
                                    local currentRod, _ = getEquippedRod()
                                    if not currentRod then
                                        enchantStatusParagraph:SetDesc("Process stopped. Rod was unequipped.")
                                        autoEnchantState.enabled = false
                                        break
                                    end

                                    local stoneCount = getStoneCount()
                                    if stoneCount == 0 then
                                        enchantStatusParagraph:SetDesc("Process stopped. Out of Enchant Stones.")
                                        autoEnchantState.enabled = false
                                        break
                                    end

                                    if autoEnchantState.stonesUsed >= autoEnchantState.stoneLimit then
                                        enchantStatusParagraph:SetDesc("Process stopped. Reached stone limit.")
                                        autoEnchantState.enabled = false
                                        break
                                    end
                                    
                                    if currentRod.Enchantments and #currentRod.Enchantments > 0 then
                                        local enchantData = ItemUtility:GetEnchantData(currentRod.Enchantments[1])
                                        if enchantData and enchantData.Data.Name == autoEnchantState.targetEnchant then
                                            enchantStatusParagraph:SetDesc(string.format("Success! Found '%s' after using %d stones.", autoEnchantState.targetEnchant, autoEnchantState.stonesUsed))
                                            autoEnchantState.enabled = false
                                            break
                                        end
                                    end

                                    autoEnchantState.stonesUsed = autoEnchantState.stonesUsed + 1
                                    enchantStatusParagraph:SetDesc(string.format("Attempting enchant... Stones used: %d", autoEnchantState.stonesUsed))
                                    
                                    pcall(applyEnchantFunc.InvokeServer, applyEnchantFunc, currentRod.UUID)
                                    
                                    task.wait(1.5)
                                end
                            end)
                        end
                    end
                })
            end

            do
                GameTabs.Auto_TP_Event:Section({ Title = "Automatic Event Teleport" })

                local eventNames = {"Ghost Worm", "Worm Hunt", "Shark Hunt", "Ghost Shark Hunt", "Shocked", "Black Hole", "Meteor Rain"}

                autoTPEventDropdown = GameTabs.Auto_TP_Event:Dropdown({
                    Title = "Select Event",
                    Values = eventNames,
                    AllowNone = true,
                    Callback = function(value)
                        eventTPState.selectedEvent = value
                    end
                })

                autoTPEventToggle = GameTabs.Auto_TP_Event:Toggle({
                    Title = "Enable Auto TP to Event",
                    Desc = "Automatically teleports you to the selected event when it appears.",
                    Value = false,
                    Callback = function(value)
                        eventTPState.enabled = value
                        if not value and eventTPState.isAtEvent then
                            if player and player.Character and player.Character.PrimaryPart and eventTPState.originalPosition then
                                local hrp = player.Character.PrimaryPart
                                local wasLocked = featureState.LockPosition
                                if hrp.Anchored then hrp.Anchored = false; task.wait(0.1) end
                                hrp.CFrame = eventTPState.originalPosition
                                if wasLocked then task.wait(0.1); hrp.Anchored = true end
                            end
                            if eventTPState.platform then eventTPState.platform:Destroy() end
                            eventTPState.platform = nil
                            eventTPState.isAtEvent = false
                        end
                    end
                })

                local function findEventPart(eventName)
                    local propsFolder = workspace:FindFirstChild("Props")
                    if not propsFolder then return nil end
                    local eventNameLower = eventName:lower()
                
                    for _, descendant in ipairs(propsFolder:GetDescendants()) do
                        if descendant.Name == "DisplayName" and descendant:IsA("TextLabel") then
                            if descendant.Text:lower() == eventNameLower then
                                local currentAncestor = descendant
                                while currentAncestor and currentAncestor ~= propsFolder do
                                    if currentAncestor:IsA("BasePart") then
                                        return currentAncestor
                                    end
                                    currentAncestor = currentAncestor.Parent
                                end
                            end
                        end
                    end
                    
                    return nil
                end

                task.spawn(function()
                    while task.wait(5) do
                        if not eventTPState.enabled or not eventTPState.selectedEvent or not player.Character or not player.Character.PrimaryPart then continue end

                        local hrp = player.Character.PrimaryPart
                        local eventPart = findEventPart(eventTPState.selectedEvent)

                        if eventPart and not eventTPState.isAtEvent then
                            eventTPState.isAtEvent = true
                            eventTPState.wasAutoFishing = featureState.AutoFish
                            if eventTPState.wasAutoFishing then featureState.AutoFish = false end

                            eventTPState.originalPosition = hrp.CFrame
                            
                            eventTPState.platform = Instance.new("Part", workspace)
                            eventTPState.platform.Name = "ArcvourEventPlatform"
                            eventTPState.platform.Size = Vector3.new(30, 1, 30)
                            eventTPState.platform.Position = eventPart.Position + Vector3.new(0, 50, 0)
                            eventTPState.platform.Anchored = true
                            eventTPState.platform.CanCollide = true
                            eventTPState.platform.Transparency = 1

                            local wasLocked = featureState.LockPosition
                            if wasLocked then hrp.Anchored = false; task.wait(0.1) end
                            hrp.CFrame = eventTPState.platform.CFrame * CFrame.new(0, 3, 0)
                            if wasLocked then task.wait(0.1); hrp.Anchored = true end
                            
                            if eventTPState.wasAutoFishing then
                                featureState.AutoFish = true
                                startAutoFishProcess()
                            end

                        elseif not eventPart and eventTPState.isAtEvent then
                            eventTPState.wasAutoFishing = featureState.AutoFish
                            if eventTPState.wasAutoFishing then featureState.AutoFish = false end

                            if eventTPState.platform then eventTPState.platform:Destroy(); eventTPState.platform = nil end
                            
                            local wasLocked = featureState.LockPosition
                            if wasLocked then hrp.Anchored = false; task.wait(0.1) end
                            hrp.CFrame = eventTPState.originalPosition
                            if wasLocked then task.wait(0.1); hrp.Anchored = true end
                            
                            if eventTPState.wasAutoFishing then
                                task.wait(1)
                                featureState.AutoFish = true
                                startAutoFishProcess()
                            end
                            eventTPState.isAtEvent = false
                        end
                    end
                end)
            end
            
            GameTabs.Spawn_Boat:Section({ Title = "Standard Boats" })
            local standard_boats = { { Name = "Small Boat", ID = 1 }, { Name = "Kayak", ID = 2 }, { Name = "Jetski", ID = 3 }, { Name = "Highfield Boat", ID = 4 }, { Name = "Speed Boat", ID = 5 }, { Name = "Fishing Boat", ID = 6 }, { Name = "Mini Yacht", ID = 14 }, { Name = "Hyper Boat", ID = 7 }, { Name = "Frozen Boat", ID = 11 }, { Name = "Cruiser Boat", ID = 13 } }
            for _, boatData in ipairs(standard_boats) do GameTabs.Spawn_Boat:Button({ Title = boatData.Name, Callback = function() pcall(function() local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"); net:WaitForChild("RF/DespawnBoat"):InvokeServer(); task.wait(3); net:WaitForChild("RF/SpawnBoat"):InvokeServer(boatData.ID) end) end }) end
            GameTabs.Spawn_Boat:Section({ Title = "Other Boats" })
            local other_boats = { { Name = "Alpha Floaty", ID = 8 }, { Name = "DEV Evil Duck 9000", ID = 9 }, { Name = "Festive Duck", ID = 10 }, { Name = "Santa Sleigh", ID = 12 } }
            for _, boatData in ipairs(other_boats) do GameTabs.Spawn_Boat:Button({ Title = boatData.Name, Callback = function() pcall(function() local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"); net:WaitForChild("RF/DespawnBoat"):InvokeServer(); task.wait(3); net:WaitForChild("RF/SpawnBoat"):InvokeServer(boatData.ID) end) end }) end

            do
                local autoBuyState = { rodEnabled = false }
                local nextRodParagraph
                local autoBuyNextRodToggle
                local nextRodToBuy = nil

                local function updateNextRodDisplay()
                    local ItemUtility, Replion
                    local modulesLoaded = pcall(function()
                        Replion = require(replicatedStorage:WaitForChild("Packages"):WaitForChild("Replion"))
                        ItemUtility = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
                    end)
                    if not modulesLoaded then
                        nextRodParagraph:SetDesc("Error: Failed to load game modules.")
                        return
                    end
                    
                    local allRods = {}
                    local itemsFolder = replicatedStorage:FindFirstChild("Items")
                    if itemsFolder then
                        for _, itemModule in ipairs(itemsFolder:GetChildren()) do
                            if itemModule:IsA("ModuleScript") then
                                local s, itemData = pcall(require, itemModule)
                                if s and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fishing Rods" and itemData.Price then
                                    table.insert(allRods, itemData)
                                end
                            end
                        end
                    end
                    table.sort(allRods, function(a, b) return a.Price < b.Price end)

                    local DataReplion = Replion.Client:WaitReplion("Data")
                    local ownedRods = DataReplion:Get({"Inventory", "Fishing Rods"})
                    local ownedRodIds = {}
                    for _, rod in ipairs(ownedRods) do
                        ownedRodIds[rod.Id] = true
                    end
                    
                    nextRodToBuy = nil
                    for _, rodData in ipairs(allRods) do
                        if not ownedRodIds[rodData.Data.Id] then
                            nextRodToBuy = rodData
                            break
                        end
                    end
                    
                    if nextRodToBuy then
                        local stats = nextRodToBuy.RollData
                        local luck = stats and (stats.BaseLuck or 1) * 100 or 0
                        local speed = nextRodToBuy.VisualClickPowerPercent and math.round(nextRodToBuy.VisualClickPowerPercent * 100) or math.round(((nextRodToBuy.ClickPower or 0.05) * 25) ^ 2.5)
                        local weight = nextRodToBuy.MaxWeight or 5

                        local desc = string.format("Price: %s\nLuck: %d%%\nSpeed: %d%%\nMax Weight: %.2fkg",
                            formatPrice(nextRodToBuy.Price), math.floor(luck), speed, weight)
                        nextRodParagraph:SetTitle(nextRodToBuy.Data.Name)
                        nextRodParagraph:SetDesc(desc)
                    else
                        nextRodParagraph:SetTitle("All Rods Owned")
                        nextRodParagraph:SetDesc("You have purchased all available fishing rods.")
                        if autoBuyState.rodEnabled then
                            autoBuyState.rodEnabled = false
                            autoBuyNextRodToggle:SetValue(false)
                        end
                    end
                end
                
                GameTabs.Buy_Rod:Section({ Title = "Auto Buy Next Rod" })
                nextRodParagraph = GameTabs.Buy_Rod:Paragraph({ Title = "Next Rod to Buy", Desc = "Loading..." })
                autoBuyNextRodToggle = GameTabs.Buy_Rod:Toggle({
                    Title = "Enable Auto Buy Next Rod",
                    Value = false,
                    Callback = function(value)
                        autoBuyState.rodEnabled = value
                        if value then
                            task.spawn(function()
                                while autoBuyState.rodEnabled do
                                    if nextRodToBuy then
                                        local DataReplion = require(replicatedStorage.Packages.Replion).Client:WaitReplion("Data")
                                        local playerCoins = DataReplion:Get("Coins")
                                        if playerCoins >= nextRodToBuy.Price then
                                            pcall(function()
                                                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseFishingRod"):InvokeServer(nextRodToBuy.Data.Id)
                                            end)
                                            task.wait(2)
                                            updateNextRodDisplay()
                                        end
                                    end
                                    task.wait(5)
                                end
                            end)
                        end
                    end
                })
                task.spawn(updateNextRodDisplay)
            end

            GameTabs.Buy_Rod:Section({ Title = "Purchase Rods" })
            local itemsFolder = replicatedStorage:FindFirstChild("Items")
            if itemsFolder then
                local rodItems = {}
                for _, itemModule in ipairs(itemsFolder:GetChildren()) do
                    if itemModule:IsA("ModuleScript") then
                        local s, itemData = pcall(require, itemModule)
                        if s and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fishing Rods" and itemData.Price then
                            table.insert(rodItems, {Name = itemData.Data.Name, ID = itemData.Data.Id, Price = itemData.Price})
                        end
                    end
                end
                table.sort(rodItems, function(a, b) return a.Price < b.Price end)
                for _, rodData in ipairs(rodItems) do
                    local buttonTitle = string.format("%s (%s)", rodData.Name, formatPrice(rodData.Price))
                    GameTabs.Buy_Rod:Button({ Title = buttonTitle, Callback = function() pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseFishingRod"):InvokeServer(rodData.ID) end) end })
                end
            end

            local weatherState = { enabled = false, selectedWeathers = {} }
            
            local weathersData = {
                { Name = "Wind", Price = 10000 }, { Name = "Snow", Price = 15000 }, { Name = "Cloudy", Price = 20000 },
                { Name = "Storm", Price = 35000 }, { Name = "Radiant", Price = 50000 }, { Name = "Shark Hunt", Price = 300000 }
            }
            table.sort(weathersData, function(a, b) return a.Price < b.Price end)

            local weatherNames = {}
            for _, weather in ipairs(weathersData) do
                table.insert(weatherNames, weather.Name)
            end

            local function purchaseSelectedWeathers()
                if not weatherState.enabled or #weatherState.selectedWeathers == 0 then return end
                for _, weatherName in ipairs(weatherState.selectedWeathers) do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseWeatherEvent"):InvokeServer(weatherName)
                    end)
                    task.wait(1)
                end
            end
            autoBuyWeatherToggle = GameTabs.Buy_Weather:Toggle({
                Title = "Enable Auto Buy Weather",
                Value = false,
                Callback = function(value)
                    weatherState.enabled = value
                    if value then
                        purchaseSelectedWeathers()
                        task.spawn(function()
                            while weatherState.enabled do
                                task.wait(1000)
                                if not weatherState.enabled then break end
                                purchaseSelectedWeathers()
                            end
                        end)
                    end
                end
            })
            autoBuyWeatherDropdown = GameTabs.Buy_Weather:Dropdown({
                Title = "Select Weather to Auto Buy",
                Values = weatherNames,
                Multi = true,
                AllowNone = true,
                Callback = function(value)
                    weatherState.selectedWeathers = value
                end
            })
            GameTabs.Buy_Weather:Section({ Title = "Manual Purchase" })
            for _, weatherData in ipairs(weathersData) do 
                local buttonTitle = string.format("%s (%s)", weatherData.Name, formatPrice(weatherData.Price))
                GameTabs.Buy_Weather:Button({ Title = buttonTitle, Callback = function() pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseWeatherEvent"):InvokeServer(weatherData.Name) end) end }) 
            end

            do
                local autoBuyState = { baitEnabled = false }
                local nextBaitParagraph
                local autoBuyNextBaitToggle
                local nextBaitToBuy = nil

                local function updateNextBaitDisplay()
                    local ItemUtility, Replion, PlayerStatsUtility
                    local modulesLoaded = pcall(function()
                        Replion = require(replicatedStorage:WaitForChild("Packages"):WaitForChild("Replion"))
                        ItemUtility = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
                        PlayerStatsUtility = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("PlayerStatsUtility"))
                    end)
                    if not modulesLoaded then
                        nextBaitParagraph:SetDesc("Error: Failed to load game modules.")
                        return
                    end
                    
                    local allBaits = ItemUtility:GetBaits()
                    table.sort(allBaits, function(a, b) return (a.Price or 0) < (b.Price or 0) end)
                    
                    local DataReplion = Replion.Client:WaitReplion("Data")
                    local ownedBaits = DataReplion:Get({"Inventory", "Baits"})
                    local ownedBaitIds = {}
                    for _, bait in ipairs(ownedBaits) do
                        ownedBaitIds[bait.Id] = true
                    end
                    
                    nextBaitToBuy = nil
                    for _, baitData in ipairs(allBaits) do
                        if baitData.Price and not ownedBaitIds[baitData.Data.Id] then
                            nextBaitToBuy = baitData
                            break
                        end
                    end
                    
                    if nextBaitToBuy then
                        local desc = string.format("Price: %s\n", formatPrice(nextBaitToBuy.Price))
                        if nextBaitToBuy.Modifiers then
                            local visualStats, visualColors = PlayerStatsUtility:GetVisualStats()
                            for stat, value in pairs(nextBaitToBuy.Modifiers) do
                                local statName = visualStats[stat] or stat
                                local modifierText
                                if tostring(statName):find("Multi") then
                                    modifierText = string.format("x%.1f", 1 + value)
                                else
                                    modifierText = string.format("+%d%%", value * 100)
                                end
                                desc = desc .. string.format("%s: %s\n", statName, modifierText)
                            end
                        end
                        nextBaitParagraph:SetTitle(nextBaitToBuy.Data.Name)
                        nextBaitParagraph:SetDesc(desc)
                    else
                        nextBaitParagraph:SetTitle("All Baits Owned")
                        nextBaitParagraph:SetDesc("You have purchased all available baits.")
                        if autoBuyState.baitEnabled then
                            autoBuyState.baitEnabled = false
                            autoBuyNextBaitToggle:SetValue(false)
                        end
                    end
                end

                GameTabs.Buy_Baits:Section({ Title = "Auto Buy Next Bait" })
                nextBaitParagraph = GameTabs.Buy_Baits:Paragraph({ Title = "Next Bait to Buy", Desc = "Loading..." })
                autoBuyNextBaitToggle = GameTabs.Buy_Baits:Toggle({
                    Title = "Enable Auto Buy Next Bait",
                    Value = false,
                    Callback = function(value)
                        autoBuyState.baitEnabled = value
                        if value then
                            task.spawn(function()
                                while autoBuyState.baitEnabled do
                                    if nextBaitToBuy then
                                        local DataReplion = require(replicatedStorage.Packages.Replion).Client:WaitReplion("Data")
                                        local playerCoins = DataReplion:Get("Coins")
                                        if playerCoins >= nextBaitToBuy.Price then
                                            pcall(function()
                                                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseBait"):InvokeServer(nextBaitToBuy.Data.Id)
                                            end)
                                            task.wait(2)
                                            updateNextBaitDisplay()
                                        end
                                    end
                                    task.wait(5)
                                end
                            end)
                        end
                    end
                })
                task.spawn(updateNextBaitDisplay)
            end

            GameTabs.Buy_Baits:Section({ Title = "Purchase Baits" })
            local baitsFolder = replicatedStorage:FindFirstChild("Baits")
            if baitsFolder then
                local baitItems = {}
                for _, itemModule in ipairs(baitsFolder:GetChildren()) do
                    if itemModule:IsA("ModuleScript") then
                        local s, itemData = pcall(require, itemModule)
                        if s and type(itemData) == "table" and itemData.Data and itemData.Price then
                            table.insert(baitItems, {Name = itemData.Data.Name, ID = itemData.Data.Id, Price = itemData.Price})
                        end
                    end
                end
                table.sort(baitItems, function(a, b) return a.Price < b.Price end)
                for _, baitData in ipairs(baitItems) do
                    local buttonTitle = string.format("%s (%s)", baitData.Name, formatPrice(baitData.Price))
                    GameTabs.Buy_Baits:Button({ Title = buttonTitle, Callback = function() pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseBait"):InvokeServer(baitData.ID) end) end })
                end
            end

            GameTabs.Buy_Gears:Section({ Title = "Gear Purchases" })
            GameTabs.Buy_Gears:Button({ Title = "Buy Fishing Radar (3k Coins)", Callback = function() 
                pcall(function() 
                    local args = { 81 }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseGear"):InvokeServer(unpack(args))
                end) 
            end })
            GameTabs.Buy_Gears:Button({ Title = "Buy Diving Gear (75k Coins)", Callback = function() 
                pcall(function() 
                    local args = { 105 }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseGear"):InvokeServer(unpack(args))
                end) 
            end })

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

            GameTabs.TP_Shop:Section({ Title = "Shop Locations" })
            local shop_locations = { 
                { Name = "Bait Shop", Position = Vector3.new(117.78, 17.41, 2878.15) }, 
                { Name = "Skin Crates", Position = Vector3.new(80.32, 17.41, 2877.07) }, 
                { Name = "Rod Shop", Position = Vector3.new(47.90, 17.41, 2878.41) },
                { Name = "Boats Shop", Position = Vector3.new(30.12, 9.63, 2785.03) },
                { Name = "Utility Store", Position = Vector3.new(-35, 20, 2871) },
                { Name = "Spin Wheel", Position = Vector3.new(-139, 17, 2826) },
                { Name = "Enchant", Position = Vector3.new(3234, -1300, 1401) }
            }
            for _, loc_data in ipairs(shop_locations) do GameTabs.TP_Shop:Button({ Title = loc_data.Name, Callback = function() if player.Character and player.Character.PrimaryPart then player.Character.PrimaryPart.CFrame = CFrame.new(loc_data.Position) end end }) end
            GameTabs.TP_Shop:Button({ Title = "Weather Machine", Callback = function() if player.Character and player.Character.PrimaryPart then local islandPart = workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!") and workspace["!!!! ISLAND LOCATIONS !!!!"]:FindFirstChild("Weather Machine"); if islandPart then player.Character.PrimaryPart.CFrame = CFrame.new(islandPart.Position) end end end })

            GameTabs.TP_NPC:Section({ Title = "NPC Locations" })
            local npc_names = { "Alex", "Billy Bob", "Boat Expert", "Burt", "Esoteric Gatekeeper", "Jed", "Jeffery", "Jess", "Joe", "Jones", "Lava Fisherman", "Lonely Fisherman", "McBoatson", "Ram", "Sam", "Santa", "Scientist", "Scott", "Seth", "Silly Fisherman", "Spokesperson", "Tim" }; table.sort(npc_names)
            for _, npc_name in ipairs(npc_names) do GameTabs.TP_NPC:Button({ Title = npc_name, Callback = function() if player.Character and player.Character.PrimaryPart then local npc_model = replicatedStorage:FindFirstChild("NPC") and replicatedStorage.NPC:FindFirstChild(npc_name); if npc_model and npc_model.WorldPivot then player.Character.PrimaryPart.CFrame = CFrame.new(npc_model.WorldPivot.Position) end end end }) end

            GameTabs.TP_Player:Section({ Title = "Teleport to Player" })
            local selectedPlayerName = nil
            local function getPlayerList() local list = {}; for _, p in ipairs(Players:GetPlayers()) do if p ~= player then table.insert(list, p.Name) end end; table.sort(list); return list end
            local playerDropdown = GameTabs.TP_Player:Dropdown({ Title = "Select Player", Values = getPlayerList(), AllowNone = true, Callback = function(v) selectedPlayerName = v end })
            GameTabs.TP_Player:Button({ Title = "Teleport to Selected Player", Callback = function() pcall(function() if not selectedPlayerName then return end; if player.Character and player.Character.PrimaryPart then local targetChar = workspace.Characters:FindFirstChild(selectedPlayerName); if targetChar and targetChar.PrimaryPart then player.Character.PrimaryPart.CFrame = targetChar.PrimaryPart.CFrame end end end) end })
            Players.PlayerAdded:Connect(function() if playerDropdown and not playerDropdown.Opened then playerDropdown:Refresh(getPlayerList()) end end)
            Players.PlayerRemoving:Connect(function() if playerDropdown and not playerDropdown.Opened then playerDropdown:Refresh(getPlayerList()) end end)

            do
                HubTabs.Config:Section({ Title = "Configuration Management" })
                HubTabs.Config:Paragraph({Title = "Save & Load", Desc = "Save your settings. To auto-teleport and start fishing, load a config where 'Enable Auto Fish' was saved as ON."})
            
                local ConfigManager = Window.ConfigManager
                if ConfigManager then
                    local myConfig = ConfigManager:CreateConfig("ArcvourFishItConfig")
                    
                    myConfig:Register("webhookEnabled", webhookEnabledToggle)
                    myConfig:Register("webhookTiers", webhookTiersDropdown)
                    myConfig:Register("webhookDiscordId", webhookIdInput)
                    myConfig:Register("webhookCustomUrl", webhookUrlInput)
                    myConfig:Register("webhookTradeEnabled", webhookTradeEnabledToggle)
                    myConfig:Register("webhookTradeUrl", webhookTradeUrlInput)
                    myConfig:Register("webhookTradeId", webhookTradeIdInput)
                    myConfig:Register("webhookInvEnabled", webhookInvEnabledToggle)
                    myConfig:Register("webhookInvDelay", webhookInvDelayInput)
                    myConfig:Register("webhookInvUrl", webhookInvUrlInput)
                    myConfig:Register("webhookInvId", webhookInvIdInput)
                    
                    myConfig:Register("walkSpeedToggle", walkSpeedToggle)
                    myConfig:Register("infiniteJumpToggle", infiniteJumpToggle)
                    myConfig:Register("noClipToggle", noClipToggle)
                    myConfig:Register("walkSpeedSlider", WalkSpeedSlider)
                    
                    myConfig:Register("autoSellMode", autoSellModeDropdown)
                    myConfig:Register("autoSellDelay", autoSellDelayInput)
                    myConfig:Register("autoBuyWeatherEnabled", autoBuyWeatherToggle)
                    myConfig:Register("autoBuyWeatherSelection", autoBuyWeatherDropdown)
                    myConfig:Register("autoFishMethod", autoFishMethodDropdown)
                    myConfig:Register("autoFishEnabled", autoFishToggle)
                    myConfig:Register("lockPositionEnabled", lockPositionToggle)
                    myConfig:Register("autoFavEnabled", autoFavToggle)
                    myConfig:Register("autoFavTiers", favTiersDropdown)
                    myConfig:Register("autoFavDelay", favDelaySlider)
                    myConfig:Register("autoUnfavTiers", unfavTiersDropdown)
                    
                    myConfig:Register("autoTPEventEnabled", autoTPEventToggle)
                    myConfig:Register("autoTPEventSelection", autoTPEventDropdown)
                    myConfig:Register("lowGfxEnabled", lowGfxToggle)

                    local autoLoadConfigPath = "ArcvourHUB_Config/Arcvour_AutoLoad.json"
                    local autoLoadToggle
                    local function getAutoLoadState()
                        if isfile and isfile(autoLoadConfigPath) then
                            local success, data = pcall(function() return HttpService:JSONDecode(readfile(autoLoadConfigPath)) end)
                            return success and data and data.enabled or false
                        end
                        return false
                    end

                    autoLoadToggle = HubTabs.Config:Toggle({
                        Title = "Enable Auto Load Config",
                        Desc = "Automatically loads config.",
                        Value = getAutoLoadState(),
                        Callback = function(value)
                            if writefile then
                                local data = HttpService:JSONEncode({ enabled = value })
                                writefile(autoLoadConfigPath, data)
                                WindUI:Notify({ Title = "Setting Saved", Content = "Auto Load Config is now " .. (value and "ON" or "OFF"), Duration = 3 })
                            end
                        end
                    })

                    HubTabs.Config:Button({
                        Title = "Save Config",
                        Icon = "save",
                        Callback = function()
                            if featureState.AutoFish and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                savedLockPosition = {player.Character.HumanoidRootPart.CFrame:GetComponents()}
                            else
                                savedLockPosition = nil
                            end
                            myConfig:Set("savedLockPosition", savedLockPosition)
                            myConfig:Save()
                            WindUI:Notify({ Title = "Success", Content = "Configuration saved successfully!", Duration = 3, Icon = "check-circle" })
                        end
                    })
                    
                    local function executeLoad()
                        local loadedData = myConfig:Load()
                        if not loadedData then
                            WindUI:Notify({ Title = "Error", Content = "Failed to load configuration file.", Duration = 4, Icon = "x-circle" })
                            return
                        end
                        
                        if loadedData.autoSellDelay then
                            local minutes = tonumber(loadedData.autoSellDelay)
                            if minutes and minutes > 0 then
                                featureState.AutoSellDelay = minutes * 60
                            end
                        end

                        WindUI:Notify({ Title = "Success", Content = "Configuration loaded successfully!", Duration = 3, Icon = "check-circle" })
                        
                        local posData = myConfig:Get("savedLockPosition")
                        if loadedData.autoFishEnabled and posData and type(posData) == "table" then
                            WindUI:Notify({Title = "Auto Fish", Content = "Teleporting to saved position...", Duration = 3, Icon = "map-pin"})
                            task.spawn(function()
                                local char = player.Character or player.CharacterAdded:Wait()
                                local hrp = char:WaitForChild("HumanoidRootPart")
                                
                                autoFishToggle:SetValue(false)
                                lockPositionToggle:SetValue(false)
                                task.wait(0.1)

                                local posToLoad = CFrame.new(unpack(posData))
                                hrp.CFrame = posToLoad
                                
                                task.wait(3)
                                
                                lockPositionToggle:SetValue(loadedData.lockPositionEnabled)
                                autoFishToggle:SetValue(true)
                            end)
                        end
                    end
            
                    HubTabs.Config:Button({
                        Title = "Load Config",
                        Icon = "folder-open",
                        Callback = executeLoad
                    })

                    if getAutoLoadState() then
                        task.wait(1) 
                        executeLoad()
                    end
                else
                    HubTabs.Config:Paragraph({Title = "Error", Desc = "ConfigManager could not be loaded."})
                end
            end

            task.spawn(function()
                while task.wait(0.5) do
                    if Window and Window.Destroyed then break end
                    pcall(function()
                        if not player or not player.PlayerGui then return end
                        local function findAndSetStat(statName, statValue, formatString, prefix)
                            if statValue then
                                local statTile = player.PlayerGui:FindFirstChild("Settings") and player.PlayerGui.Settings:FindFirstChild("StatTile", true)
                                if not statTile then return end
                                local labelToUpdate; if statName == "Fishing Luck" then local statFrame = statTile:FindFirstChild("Stat"); if statFrame and statFrame:FindFirstChild("Label") then labelToUpdate = statFrame.Label end else for _, child in ipairs(statTile:GetChildren()) do if child:IsA("Frame") and child:FindFirstChild("Label") and child.Label.Text:find(statName) then labelToUpdate = child.Label; break end end end
                                if labelToUpdate then local newText = string.format(formatString, prefix or "", statValue); if labelToUpdate.Text ~= newText then labelToUpdate.Text = newText end end
                            end
                        end
                        findAndSetStat("Fishing Luck", statValues.FishingLuck, "%sFishing Luck: +%s%%", ""); findAndSetStat("Shiny Chance", statValues.ShinyChance, "%sShiny Chance: %s%%", ""); findAndSetStat("Mutation Chance", statValues.MutationChance, "%sMutation Chance: +%s%%", "")
                    end)
                end
            end)
        end

        local VirtualUser = game:GetService("VirtualUser")
        if player and VirtualUser then
            player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end

        if Window then
            Window:SelectTab(1)
            WindUI:Notify({ Title = "ArcvourHUB Ready", Content = "All features have been loaded. Enjoy!", Duration = 8, Icon = "check-circle" })
        end
    end

    local function ValidateUser()
        WindUI:Notify({Title = "Authenticating...", Content = "Verifying premium access for Fish It...", Duration = 3, Icon = "loader"})
        
        local payload = HttpService:JSONEncode({
            user_id = tostring(player.UserId),
            game_id = GAME_ID
        })

        local success, response_body = pcall(function()
            return game:HttpPost(VALIDATION_URL, payload, "application/json")
        end)

        if not success then
            WindUI:Notify({Title = "Authentication Failed", Content = "Could not connect to the server. Please check your internet and try again.", Duration = 10, Icon = "alert-triangle"})
            return false
        end
        
        local success_decode, response_data = pcall(HttpService.JSONDecode, HttpService, response_body)
        if not success_decode then
            WindUI:Notify({Title = "Authentication Failed", Content = "Invalid server response. Please contact support.", Duration = 10, Icon = "alert-triangle"})
            return false
        end

        if response_data and response_data.success then
            WindUI:Notify({Title = "Authentication Successful", Content = "Welcome, " .. player.Name .. "!", Duration = 8, Icon = "check-circle"})
            return true
        else
            local error_message = response_data and response_data.message or "You are not whitelisted for this script."
            WindUI:Notify({Title = "Access Denied", Content = error_message, Duration = 10, Icon = "x-circle"})
            return false
        end
    end
    
    createIntro()
    task.wait(2.5)
    
    if ValidateUser() then
        tweenOutAndDestroy()
        InitializeMainScript()
    end
end

