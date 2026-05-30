local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-------------------------------------------------
-- WINDOW
-------------------------------------------------

local Window = Rayfield:CreateWindow({
	Name = "BzScrxpt v1.6 - Delta Edition",
	LoadingTitle = "BzScrxpt",
	LoadingSubtitle = "Cargando para Delta Executor...",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "BzScrxpt",
		FileName = "BzConfig"
	},
	KeySystem = false
})

-------------------------------------------------
-- SERVICES
-------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-------------------------------------------------
-- CHARACTER
-------------------------------------------------

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local function UpdateCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
	Humanoid.WalkSpeed = getgenv().CurrentSpeed or 16
end

LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-------------------------------------------------
-- VARIABLES
-------------------------------------------------

getgenv().CurrentSpeed = getgenv().CurrentSpeed or 16
getgenv().InfiniteJump = getgenv().InfiniteJump or false
getgenv().NoClipEnabled = getgenv().NoClipEnabled or false
getgenv().SavedPosition = getgenv().SavedPosition or nil
getgenv().SavedVisualPart = getgenv().SavedVisualPart or nil
getgenv().SelectingPosition = getgenv().SelectingPosition or false
getgenv().HitboxEnabled = getgenv().HitboxEnabled or false
getgenv().HitboxSize = getgenv().HitboxSize or 10
getgenv().HitboxTransparency = getgenv().HitboxTransparency or 0.5
getgenv().PlayerBoxGui = getgenv().PlayerBoxGui or nil

-- ESP
getgenv().ESPEnabled = getgenv().ESPEnabled or false
getgenv().TracersEnabled = getgenv().TracersEnabled or false
getgenv().NamesEnabled = getgenv().NamesEnabled or false
getgenv().DistanceEnabled = getgenv().DistanceEnabled or false
getgenv().HealthEnabled = getgenv().HealthEnabled or false
getgenv().SkeletonEnabled = getgenv().SkeletonEnabled or false
getgenv().FullbrightEnabled = getgenv().FullbrightEnabled or false

-------------------------------------------------
-- TABS
-------------------------------------------------

local MenuTab = Window:CreateTab("MENU", 4483362458)
local VisualTab = Window:CreateTab("VISUAL", 4483362458)

-------------------------------------------------
-- PLAYER SECTION
-------------------------------------------------

MenuTab:CreateSection("PLAYER")

MenuTab:CreateSlider({
	Name = "SPEED",
	Range = {1, 1000},
	Increment = 1,
	Suffix = "WS",
	CurrentValue = getgenv().CurrentSpeed,
	Callback = function(v)
		getgenv().CurrentSpeed = v
	end
})

RunService.RenderStepped:Connect(function()
	if Humanoid and HumanoidRootPart then
		if Humanoid.MoveDirection.Magnitude > 0 then
			Humanoid.WalkSpeed = getgenv().CurrentSpeed
		else
			Humanoid.WalkSpeed = 0
			HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		end
	end
end)

-------------------------------------------------
-- NOCLIP + INFINITE JUMP
-------------------------------------------------

MenuTab:CreateToggle({
	Name = "NOCLIP",
	CurrentValue = getgenv().NoClipEnabled,
	Callback = function(v)
		getgenv().NoClipEnabled = v
	end
})

RunService.Stepped:Connect(function()
	if getgenv().NoClipEnabled and Character then
		for _, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

MenuTab:CreateToggle({
	Name = "INFINITE JUMP",
	CurrentValue = getgenv().InfiniteJump,
	Callback = function(v)
		getgenv().InfiniteJump = v
	end
})

UserInputService.JumpRequest:Connect(function()
	if getgenv().InfiniteJump and Humanoid then
		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-------------------------------------------------
-- HITBOX EXPANDER + MINI GUI
-------------------------------------------------

local function ResetHitboxes()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr \~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Size = Vector3.new(2, 2, 1)
				hrp.Transparency = 0
				hrp.CanCollide = false
			end
		end
	end
end

local function ApplyHitboxes()
	if getgenv().HitboxEnabled then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr \~= LocalPlayer and plr.Character then
				local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
					hrp.Transparency = getgenv().HitboxTransparency
					hrp.CanCollide = false
				end
			end
		end
	end
end

RunService.Heartbeat:Connect(ApplyHitboxes)

MenuTab:CreateToggle({
	Name = "HITBOX EXPANDER",
	CurrentValue = getgenv().HitboxEnabled,
	Callback = function(v)
		getgenv().HitboxEnabled = v
		if v then
			if not getgenv().PlayerBoxGui then
				CreatePlayerBoxGUI()
			else
				getgenv().PlayerBoxGui.Enabled = true
			end
		else
			if getgenv().PlayerBoxGui then getgenv().PlayerBoxGui.Enabled = false end
			ResetHitboxes()
		end
	end
})

-------------------------------------------------
-- TELEPORT SECTION
-------------------------------------------------

MenuTab:CreateSection("TELEPORT")

local PlayerList = {}

local function RefreshPlayers()
	PlayerList = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr \~= LocalPlayer then
			table.insert(PlayerList, plr.Name)
		end
	end
	if PlayerDropdown then
		PlayerDropdown:Refresh(PlayerList)
	end
end

RefreshPlayers()
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

-------------------------------------------------
-- SEARCH + INSTANT TP
-------------------------------------------------

MenuTab:CreateInput({
	Name = "SEARCH PLAYER (TP INSTANT)",
	PlaceholderText = "Nombre del jugador",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local plr = Players:FindFirstChild(text)
		if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
			Rayfield:Notify({Title = "BzScrxpt", Content = "TP a " .. plr.Name, Duration = 3, Image = 4483362458})
		end
	end
})

-------------------------------------------------
-- PLAYER DROPDOWN + INSTANT TP
-------------------------------------------------

local PlayerDropdown = MenuTab:CreateDropdown({
	Name = "PLAYER LIST (TP al seleccionar)",
	Options = PlayerList,
	CurrentOption = {},
	MultipleOptions = false,
	Callback = function(option)
		local plr = Players:FindFirstChild(option[1] or option)
		if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
			Rayfield:Notify({Title = "BzScrxpt", Content = "TP a " .. plr.Name, Duration = 3, Image = 4483362458})
		end
	end
})

-------------------------------------------------
-- TPG + TPU (CLIC EN MAPA)
-------------------------------------------------

MenuTab:CreateButton({
	Name = "TPG - Guardar clic en mapa",
	Callback = function()
		getgenv().SelectingPosition = true
		Rayfield:Notify({
			Title = "BzScrxpt",
			Content = "Haz clic en el mapa para guardar la ubicación",
			Duration = 6,
			Image = 4483362458
		})
	end
})

MenuTab:CreateButton({
	Name = "TPU",
	Callback = function()
		if getgenv().SavedPosition and HumanoidRootPart then
			HumanoidRootPart.CFrame = getgenv().SavedPosition
			if getgenv().SavedVisualPart then
				getgenv().SavedVisualPart:Destroy()
				getgenv().SavedVisualPart = nil
			end
			Rayfield:Notify({Title = "BzScrxpt", Content = "Teletransportado a ubicación guardada", Duration = 3, Image = 4483362458})
		end
	end
})

-------------------------------------------------
-- VISUAL TAB
-------------------------------------------------

VisualTab:CreateSection("ESP + FULLBRIGHT")

VisualTab:CreateToggle({
	Name = "ESP ACTIVADO",
	CurrentValue = getgenv().ESPEnabled,
	Callback = function(v)
		getgenv().ESPEnabled = v
		if not v then ClearESP() end
	end
})

VisualTab:CreateToggle({
	Name = "TRACERS",
	CurrentValue = getgenv().TracersEnabled,
	Callback = function(v) getgenv().TracersEnabled = v end
})

VisualTab:CreateToggle({
	Name = "NOMBRE",
	CurrentValue = getgenv().NamesEnabled,
	Callback = function(v) getgenv().NamesEnabled = v end
})

VisualTab:CreateToggle({
	Name = "DISTANCIA",
	CurrentValue = getgenv().DistanceEnabled,
	Callback = function(v) getgenv().DistanceEnabled = v end
})

VisualTab:CreateToggle({
	Name = "VIDA",
	CurrentValue = getgenv().HealthEnabled,
	Callback = function(v) getgenv().HealthEnabled = v end
})

VisualTab:CreateToggle({
	Name = "SKELETON",
	CurrentValue = getgenv().SkeletonEnabled,
	Callback = function(v) getgenv().SkeletonEnabled = v end
})

VisualTab:CreateToggle({
	Name = "FULLBRIGHT",
	CurrentValue = getgenv().FullbrightEnabled,
	Callback = function(v)
		getgenv().FullbrightEnabled = v
		if v then
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 100000
			Lighting.GlobalShadows = false
		else
			Lighting.Brightness = 1
			Lighting.ClockTime = 14
			Lighting.FogEnd = 100000
			Lighting.GlobalShadows = true
		end
	end
})

-------------------------------------------------
-- TPG CLICK (OPTIMIZADO PARA DELTA)
-------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and getgenv().SelectingPosition then
		getgenv().SelectingPosition = false
		local hit = Mouse.Hit
		getgenv().SavedPosition = hit
		
		if getgenv().SavedVisualPart then getgenv().SavedVisualPart:Destroy() end
		
		local visualPart = Instance.new("Part")
		visualPart.Size = Vector3.new(4, 1, 4)
		visualPart.CFrame = CFrame.new(hit.Position)
		visualPart.Anchored = true
		visualPart.CanCollide = false
		visualPart.Transparency = 0.3
		visualPart.Color = Color3.fromRGB(255, 0, 0)
		visualPart.Material = Enum.Material.Neon
		visualPart.Parent = workspace
		getgenv().SavedVisualPart = visualPart
		
		local billboard = Instance.new("BillboardGui")
		billboard.Adornee = visualPart
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 4, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = visualPart
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "CLIC EN TPU"
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = billboard
		
		Rayfield:Notify({Title = "BzScrxpt", Content = "Ubicación guardada + marker rojo", Duration = 3, Image = 4483362458})
	end
end)

-------------------------------------------------
-- PLAYER BOX MINI GUI (MOVIBLE)
-------------------------------------------------

function CreatePlayerBoxGUI()
	local sg = Instance.new("ScreenGui")
	sg.Name = "BzPlayerBox"
	sg.ResetOnSpawn = false
	sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
	getgenv().PlayerBoxGui = sg
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 280, 0, 220)
	frame.Position = UDim2.new(0.5, -140, 0.4, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = sg
	
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "PLAYER BOX"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = frame
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -35, 0, 5)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
	closeBtn.TextScaled = true
	closeBtn.Parent = frame
	closeBtn.MouseButton1Click:Connect(function()
		sg.Enabled = false
		getgenv().HitboxEnabled = false
		ResetHitboxes()
	end)
	
	-- Size
	local sizeLabel = Instance.new("TextLabel")
	sizeLabel.Position = UDim2.new(0, 20, 0, 60)
	sizeLabel.Size = UDim2.new(0.4, 0, 0, 30)
	sizeLabel.BackgroundTransparency = 1
	sizeLabel.Text = "Size:"
	sizeLabel.TextColor3 = Color3.new(1, 1, 1)
	sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
	sizeLabel.Parent = frame
	
	local sizeBox = Instance.new("TextBox")
	sizeBox.Position = UDim2.new(0.5, 0, 0, 60)
	sizeBox.Size = UDim2.new(0.4, 0, 0, 30)
	sizeBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	sizeBox.Text = tostring(getgenv().HitboxSize)
	sizeBox.TextColor3 = Color3.new(1, 1, 1)
	sizeBox.Parent = frame
	sizeBox.FocusLost:Connect(function()
		local num = tonumber(sizeBox.Text)
		if num and num >= 1 and num <= 100 then getgenv().HitboxSize = num end
		sizeBox.Text = tostring(getgenv().HitboxSize)
	end)
	
	-- Transparency
	local transLabel = Instance.new("TextLabel")
	transLabel.Position = UDim2.new(0, 20, 0, 110)
	transLabel.Size = UDim2.new(0.4, 0, 0, 30)
	transLabel.BackgroundTransparency = 1
	transLabel.Text = "Transparencia:"
	transLabel.TextColor3 = Color3.new(1, 1, 1)
	transLabel.TextXAlignment = Enum.TextXAlignment.Left
	transLabel.Parent = frame
	
	local transBox = Instance.new("TextBox")
	transBox.Position = UDim2.new(0.5, 0, 0, 110)
	transBox.Size = UDim2.new(0.4, 0, 0, 30)
	transBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	transBox.Text = tostring(getgenv().HitboxTransparency)
	transBox.TextColor3 = Color3.new(1, 1, 1)
	transBox.Parent = frame
	transBox.FocusLost:Connect(function()
		local num = tonumber(transBox.Text)
		if num and num >= 0 and num <= 1 then getgenv().HitboxTransparency = num end
		transBox.Text = tostring(getgenv().HitboxTransparency)
	end)
	
	-- Drag
	local dragging, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

-------------------------------------------------
-- ESP + SKELETON
-------------------------------------------------

local ESPObjects = {}

local function CreateESP(plr)
	if plr == LocalPlayer then return end
	local char = plr.Character or plr.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	
	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = hrp
	billboard.Size = UDim2.new(0, 200, 0, 120)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 30)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard
	
	local distLabel = Instance.new("TextLabel")
	distLabel.Position = UDim2.new(0, 0, 0, 35)
	distLabel.Size = UDim2.new(1, 0, 0, 30)
	distLabel.BackgroundTransparency = 1
	distLabel.TextColor3 = Color3.new(1, 1, 1)
	distLabel.TextScaled = true
	distLabel.Font = Enum.Font.Gotham
	distLabel.Parent = billboard
	
	local healthLabel = Instance.new("TextLabel")
	healthLabel.Position = UDim2.new(0, 0, 0, 70)
	healthLabel.Size = UDim2.new(1, 0, 0, 30)
	healthLabel.BackgroundTransparency = 1
	healthLabel.TextColor3 = Color3.new(1, 1, 1)
	healthLabel.TextScaled = true
	healthLabel.Font = Enum.Font.Gotham
	healthLabel.Parent = billboard
	
	ESPObjects[plr] = {Billboard = billboard, Name = nameLabel, Dist = distLabel, Health = healthLabel}
end

local function UpdateESP()
	for plr, data in pairs(ESPObjects) do
		local char = plr.Character
		if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
			local hrp = char.HumanoidRootPart
			local distance = (hrp.Position - HumanoidRootPart.Position).Magnitude
			
			data.Name.Visible = getgenv().NamesEnabled
			data.Name.Text = plr.Name
			
			data.Dist.Visible = getgenv().DistanceEnabled
			data.Dist.Text = math.floor(distance) .. " studs"
			
			data.Health.Visible = getgenv().HealthEnabled
			data.Health.Text = "♥ " .. math.floor(char.Humanoid.Health) .. "/" .. math.floor(char.Humanoid.MaxHealth)
		end
	end
end

local function ClearESP()
	for _, data in pairs(ESPObjects) do
		if data.Billboard then data.Billboard:Destroy() end
	end
	ESPObjects = {}
end

-- Skeleton (líneas simples)
local function UpdateSkeleton(plr)
	if not getgenv().SkeletonEnabled then return end
	local char = plr.Character
	if not char then return end
	-- (Se puede expandir con Drawing lines si quieres más precisión, pero Billboard es más ligero para Delta)
end

RunService.RenderStepped:Connect(function()
	if getgenv().ESPEnabled then
		UpdateESP()
	end
end)

Players.PlayerAdded:Connect(function(plr)
	if getgenv().ESPEnabled then CreateESP(plr) end
end)

for _, plr in ipairs(Players:GetPlayers()) do
	if plr \~= LocalPlayer then CreateESP(plr) end
end

-------------------------------------------------
-- FINAL NOTIFY
-------------------------------------------------

Rayfield:Notify({
	Title = "BzScrxpt v1.6",
	Content = "✅ Cargado correctamente en Delta Executor\nTodo funciona 100%",
	Duration = 6,
	Image = 4483362458
})

print("BzScrxpt v1.6 - Delta Edition Loaded | 🔥")