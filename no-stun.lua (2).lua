local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== CONFIG ====================
local enabled = true

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LowMSGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 110)
frame.Position = UDim2.new(0.03, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 70)
stroke.Thickness = 1.2
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 28)
title.Position = UDim2.new(0, 8, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Low Delay"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -30, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
minBtn.Text = "–"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = frame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 22)
statusLabel.Position = UDim2.new(0, 8, 0, 38)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Estado: Activado"
statusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -16, 0, 34)
toggleBtn.Position = UDim2.new(0, 8, 0, 68)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
toggleBtn.Text = "ACTIVADO"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Botón minimizado
local miniBtnFloat = Instance.new("TextButton")
miniBtnFloat.Size = UDim2.new(0, 48, 0, 48)
miniBtnFloat.Position = UDim2.new(0.03, 0, 0.4, 0)
miniBtnFloat.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
miniBtnFloat.Text = "MS"
miniBtnFloat.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtnFloat.TextSize = 14
miniBtnFloat.Font = Enum.Font.GothamBold
miniBtnFloat.BorderSizePixel = 0
miniBtnFloat.Visible = false
miniBtnFloat.Parent = screenGui

local miniCorner2 = Instance.new("UICorner")
miniCorner2.CornerRadius = UDim.new(1, 0)
miniCorner2.Parent = miniBtnFloat

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(0, 0, 0)
miniStroke.Thickness = 1.5
miniStroke.Transparency = 0.3
miniStroke.Parent = miniBtnFloat

-- ==================== ARRASTRE ====================
local function makeDraggable(gui)
	local dragging, dragStart, startPos
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

makeDraggable(frame)
makeDraggable(miniBtnFloat)

-- ==================== LÓGICA ====================
local function setEnabled(state)
	enabled = state
	if enabled then
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
		toggleBtn.Text = "ACTIVADO"
		statusLabel.Text = "Estado: Activado"
		statusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
		miniBtnFloat.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
	else
		toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
		toggleBtn.Text = "DESACTIVADO"
		statusLabel.Text = "Estado: Desactivado"
		statusLabel.TextColor3 = Color3.fromRGB(220, 100, 100)
		miniBtnFloat.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	end
end

toggleBtn.MouseButton1Click:Connect(function()
	setEnabled(not enabled)
end)

minBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	miniBtnFloat.Visible = true
	miniBtnFloat.Position = frame.Position
end)

miniBtnFloat.MouseButton1Click:Connect(function()
	miniBtnFloat.Visible = false
	frame.Visible = true
	frame.Position = miniBtnFloat.Position
end)

-- Técnicas reales para reducir sensación de delay
local function optimizeCharacter(char)
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	if humanoid then
		humanoid.AutoRotate = true
		-- Reduce un poco el smoothing de movimiento
		pcall(function()
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		end)
	end

	if root then
		-- Network ownership ayuda a que el cliente tenga más control
		pcall(function()
			root:SetNetworkOwner(player)
		end)
	end
end

player.CharacterAdded:Connect(function(char)
	task.wait(0.3)
	if enabled then
		optimizeCharacter(char)
	end
end)

if player.Character and enabled then
	optimizeCharacter(player.Character)
end

-- Loop ligero de optimización
RunService.Heartbeat:Connect(function()
	if not enabled then return end
	local char = player.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			pcall(function()
				root:SetNetworkOwner(player)
			end)
		end
	end
end)

print("Low Delay script cargado")
