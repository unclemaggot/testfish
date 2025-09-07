local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local net = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")

local autofish = false
local perfectCast = true
local ijump = false

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)


local islandCoords = {
	["Weather Machine"] = Vector3.new(-1471, -3, 1929),
	["Esoteric Depths"] = Vector3.new(3157, -1303, 1439),
	["Tropical Grove"] = Vector3.new(-2038, 3, 3650),
	["Stingray Shores"] = Vector3.new(-32, 4, 2773),
	["Kohana Volcano"] = Vector3.new(-519, 24, 189),
	["Coral Reefs"] = Vector3.new(-3095, 1, 2177),
	["Crater Island"] = Vector3.new(968, 1, 4854),
	["Kohana"] = Vector3.new(-658, 3, 719)
}


local Window = Rayfield:CreateWindow({
	Name = "Fish It Script",
	LoadingTitle = " AutoFish",
	LoadingSubtitle = " ",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = "FishIt",
		FileName = "AutoFishSave"
	},
	KeySystem = false
})



local function NotifySuccess(title, message)
	Rayfield:Notify({
		Title = "✅ | " .. title,
		Content = "━━━━━━━━━━━━━━━━━━\n" .. message .. "\n━━━━━━━━━━━━━━━━━━",
		Duration = 3
	})
end

local function NotifyError(title, message)
	Rayfield:Notify({
		Title = "❌ | " .. title,
		Content = "━━━━━━━━━━━━━━━━━━\n" .. message .. "\n━━━━━━━━━━━━━━━━━━",
		Duration = 3
	})
end

local function NotifyInfo(title, message)
	Rayfield:Notify({
		Title = "ℹ️ | " .. title,
		Content = "━━━━━━━━━━━━━━━━━━\n" .. message .. "\n━━━━━━━━━━━━━━━━━━",
		Duration = 3
	})
end

local function NotifyWarning(title, message)
	Rayfield:Notify({
		Title = "⚠️ | " .. title,
		Content = "━━━━━━━━━━━━━━━━━━\n" .. message .. "\n━━━━━━━━━━━━━━━━━━",
		Duration = 3
	})
end

})


local MainTab = Window:CreateTab("Auto Fish", "rabbit")

MainTab:CreateToggle({
	Name = "Enable Auto Fish",
	CurrentValue = false,
	Flag = "AutoFishToggle",
	Callback = function(value)
		autofish = value
		if value then
			task.spawn(function()
				while autofish do
					pcall(function()
						local args = {1}
						ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
							:WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
							:WaitForChild("RE/EquipToolFromHotbar"):FireServer(unpack(args))

						task.wait(0.2) 

						local timestamp = perfectCast and 9999999999 or (tick() + math.random())
						rodRemote:InvokeServer(timestamp)
						task.wait(0.1)

						local x, y = -1.238, 0.969
						if not perfectCast then
							x = math.random(-1000, 1000) / 1000
							y = math.random(0, 1000) / 1000
						end
						miniGameRemote:InvokeServer(x, y)
						task.wait(1.5)

						finishRemote:FireServer()
					end)
					task.wait(2)
				end

				ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
					:WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
					:WaitForChild("RE/UnequipToolFromHotbar"):FireServer()
			end)
		end
	end,
})

MainTab:CreateToggle({
	Name = "Use Perfect Cast",
	CurrentValue = true,
	Flag = "PerfectCast",
	Callback = function(val)
		perfectCast = val
	end,
})

MainTab:CreateButton({
	Name = "Manual Perfect Cast Now",
	Callback = function()
		pcall(function()
			if not isRodEquipped() then
				tryEquipRod()
			end
			rodRemote:InvokeServer(9999999999)
			wait(0.1)
			miniGameRemote:InvokeServer(-1.238, 0.969)
			wait(1.3)
			finishRemote:FireServer()
		end)
	end,
})

MainTab:CreateButton({
	Name = "Sell All Fishes (Beta)",
	Info = "Must be close to the seller",
	Callback = function()
		local sellRemote = net:WaitForChild("RF/SellAllItems")
		pcall(function()
			sellRemote:InvokeServer()
			NotifySuccess("Sold!", "All the fish were sold successfully!")
		end)
	end,
})


local PlayerTab = Window:CreateTab("Player", "users-round")

PlayerTab:CreateToggle({
	Name = "Infinity Jump",
	CurrentValue = false,
	Flag = "InfinityJump",
	Callback = function(val)
		ijump = val
	end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
	if ijump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end
end)


local floatPlatform = nil

PlayerTab:CreateToggle({
	Name = "Enable Float",
	CurrentValue = false,
	Callback = function(enabled)
		if enabled then
			local charFolder = workspace:WaitForChild("Characters", 5)
			local char = charFolder:FindFirstChild(LocalPlayer.Name)
			if not char then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			floatPlatform = Instance.new("Part")
			floatPlatform.Anchored = true
			floatPlatform.Size = Vector3.new(10, 1, 10)
			floatPlatform.Transparency = 1
			floatPlatform.CanCollide = true
			floatPlatform.Name = "FloatPlatform"
			floatPlatform.Parent = workspace

			task.spawn(function()
				while floatPlatform and floatPlatform.Parent do
					pcall(function()
						floatPlatform.Position = hrp.Position - Vector3.new(0, 3.5, 0)
					end)
					task.wait(0.1)
				end
			end)

			Rayfield:Notify({
				Title = "☁️ Float Enabled",
				Content = "This feature has been successfully activated!",
				Duration = 3
			})
		else
			if floatPlatform then
				floatPlatform:Destroy()
				floatPlatform = nil
			end
			Rayfield:Notify({
				Title = "☁️ Float Disabled",
				Content = "Feature disabled",
				Duration = 2
			})
		end
	end,
})


local universalNoclip = false

local originalCollisionState = {}


PlayerTab:CreateToggle({
	Name = "Universal No Clip",
	CurrentValue = false,
	Flag = "UniversalNoclip",
	Callback = function(val)
		universalNoclip = val

		if val then
			NotifySuccess("Universal Noclip Active", "You & your vehicle can penetrate all objects.")
		else

			for part, state in pairs(originalCollisionState) do
				if part and part:IsA("BasePart") then
					part.CanCollide = state
				end
			end
			originalCollisionState = {}
			NotifyWarning("Universal Noclip Disabled", "All collisions are returned to their original state.")
		end
	end,
})

game:GetService("RunService").Stepped:Connect(function()
	if not universalNoclip then return end

	local char = LocalPlayer.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide == true then
				originalCollisionState[part] = true
				part.CanCollide = false
			end
		end
	end

	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChildWhichIsA("VehicleSeat", true) then
			for _, part in ipairs(model:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide == true then
					originalCollisionState[part] = true
					part.CanCollide = false
				end
			end
		end
	end
end)

PlayerTab:CreateInput({
	Name = "Bring Player (Stabil)",
	PlaceholderText = "Masukkan DisplayName / Username",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local targetPlayer = nil

		for _, p in pairs(Players:GetPlayers()) do
			if p.DisplayName:lower() == text:lower() or p.Name:lower() == text:lower() then
				targetPlayer = p
				break
			end
		end

		if not targetPlayer then
			NotifyError("Pemain Tidak Ditemukan", "Tidak ada pemain dengan nama tersebut.")
			return
		end

		local charFolder = workspace:FindFirstChild("Characters")
		if not charFolder then
			NotifyError("Gagal", "Folder karakter tidak ditemukan.")
			return
		end

		local targetChar = charFolder:FindFirstChild(targetPlayer.Name)
		local myChar = charFolder:FindFirstChild(LocalPlayer.Name)

		if not (targetChar and myChar) then
			NotifyError("Gagal", "Karakter tidak ditemukan.")
			return
		end

		local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
		local myHRP = myChar:FindFirstChild("HumanoidRootPart")

		if not (targetHRP and myHRP) then
			NotifyError("Gagal", "HumanoidRootPart tidak ditemukan.")
			return
		end

		-- Looping Bring: supaya tidak dikembalikan oleh server
		task.spawn(function()
			for i = 1, 15 do
				pcall(function()
					targetHRP.CFrame = myHRP.CFrame + Vector3.new(2, 0, 0)
				end)
				task.wait(0.1)
			end
			NotifySuccess("Berhasil", "Berhasil membawa " .. targetPlayer.DisplayName .. " ke posisimu.")
		end)
	end
})


PlayerTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 150},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = 16,
	Flag = "WalkSpeed",
	Callback = function(val)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val end
	end,
})

PlayerTab:CreateSlider({
	Name = "Jump Power",
	Range = {50, 500},
	Increment = 10,
	Suffix = "JP",
	CurrentValue = 35,
	Flag = "JumpPower",
	Callback = function(val)
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.UseJumpPower = true
				hum.JumpPower = val
			end
		end
	end,
})



local TeleportTab = Window:CreateTab("Teleport", "step-forward"
)

TeleportTab:CreateParagraph({
	Title = "Teleport Guide",
	Content = [[
Enter the code or name according to the target:

📍 Island Code (Use numeric input):
  01 = Weather Machine
  02 = Esoteric Depths
  03 = Tropical Grove
  04 = Stingray Shores
  05 = Kohana Volcano
  06 = Coral Reefs
  07 = Crater Island
  08 = Kohana
  09 = Winter Fest

🚶 For players, type the username manually.
Make sure the name matches what appears on the leaderboard.
]]
})

local islandCodes = {
	["01"] = { name = "Weather Machine", position = Vector3.new(-1471, -3, 1929) },
	["02"] = { name = "Esoteric Depths", position = Vector3.new(3157, -1303, 1439) },
	["03"] = { name = "Tropical Grove", position = Vector3.new(-2038, 3, 3650) },
	["04"] = { name = "Stingray Shores", position = Vector3.new(-32, 4, 2773) },
	["05"] = { name = "Kohana Volcano", position = Vector3.new(-519, 24, 189) },
	["06"] = { name = "Coral Reefs", position = Vector3.new(-3095, 1, 2177) },
	["07"] = { name = "Crater Island", position = Vector3.new(968, 1, 4854) },
	["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
	["09"] = { name = "Winter Fest", position = Vector3.new(1611, 4, 3280) },
}


TeleportTab:CreateInput({
	Name = "Teleport to the Island",
	PlaceholderText = "Example: 01",
	RemoveTextAfterFocusLost = false,
	Callback = function(input)
		local data = islandCodes[input]
		if data then
			local success, err = pcall(function()
				local charFolder = workspace:WaitForChild("Characters", 5)
				local char = charFolder:FindFirstChild(LocalPlayer.Name)
				if not char then error("Character not found") end
				local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
				if not hrp then error("HRP not found") end
				hrp.CFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
			end)

			if success then
				NotifySuccess("Teleport Successful", "You have teleported to " .. data.name .. "!")
			else
				NotifyError("Teleport Failed", tostring(err))
			end
		else
			NotifyError("Invalid Code", "Use codes from 01 to 09 according to the list.")
		end
	end,
})

local function teleportToPlayerExact(target)
    local characters = workspace:FindFirstChild("Characters")
    if not characters then return end

    local targetChar = characters:FindFirstChild(target)
    local myChar = characters:FindFirstChild(LocalPlayer.Name)

    if targetChar and myChar then
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            myHRP.CFrame = targetHRP.CFrame + Vector3.new(2, 0, 0)
        end
    end
end


local function getPlayer(name)
	for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
		if p.Name:lower() == name:lower() then
			return p
		end
	end
end

TeleportTab:CreateInput({
    Name = "Player Name",
    PlaceholderText = "Example: Prince",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        for _, p in pairs(Players:GetPlayers()) do
            if p.DisplayName:lower() == text:lower() then
                teleportToPlayerExact(p.Name)
                NotifySuccess("Teleport Successfully", "Successfully Teleported to " .. p.displayName .. "!")
                break
            end
        end
    end
})


Window:CreateTab("Settings", "cog"):CreateButton({
	Name = "Close GUI",
	Callback = function()
		Rayfield:Destroy()
	end,
})
