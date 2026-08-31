local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ==================== VARIABLES ====================
local targetLock = false
local lockedPlayer = nil
local buttonVisible = true
local buttonSize = 55
local isDraggable = true
local menuOpen = true

-- ==================== GUI PRINCIPAL ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileCameraLock"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ========== MENÚ DE CONFIGURACIÓN ==========
local menuFrame = Instance.new("Frame")
menuFrame.Name = "Menu"
menuFrame.Size = UDim2.new(0, 170, 0, 210)
menuFrame.Position = UDim2.new(0.03, 0, 0.25, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
menuFrame.BorderSizePixel = 0
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menuFrame

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(55, 55, 65)
menuStroke.Thickness = 1.2
menuStroke.Parent = menuFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 28)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Camera Lock"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = menuFrame

-- Botón minimizar menú
local minMenuBtn = Instance.new("TextButton")
minMenuBtn.Size = UDim2.new(0, 26, 0, 26)
minMenuBtn.Position = UDim2.new(1, -32, 0, 6)
minMenuBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
minMenuBtn.Text = "–"
minMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minMenuBtn.TextSize = 18
minMenuBtn.Font = Enum.Font.GothamBold
minMenuBtn.BorderSizePixel = 0
minMenuBtn.Parent = menuFrame

local minMenuCorner = Instance.new("UICorner")
minMenuCorner.CornerRadius = UDim.new(0, 6)
minMenuCorner.Parent = minMenuBtn

-- Toggle mostrar botón
local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.new(1, -20, 0, 32)
showBtn.Position = UDim2.new(0, 10, 0, 42)
showBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
showBtn.Text = "Botón: Visible"
showBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
showBtn.TextSize = 13
showBtn.Font = Enum.Font.GothamBold
showBtn.BorderSizePixel = 0
showBtn.Parent = menuFrame

local showBtnCorner = Instance.new("UICorner")
showBtnCorner.CornerRadius = UDim.new(0, 8)
showBtnCorner.Parent = showBtn

-- Tamaño del botón
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(1, -20, 0, 20)
sizeLabel.Position = UDim2.new(0, 10, 0, 82)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "Tamaño: 55"
sizeLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
sizeLabel.TextSize = 12
sizeLabel.Font = Enum.Font.Gotham
sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
sizeLabel.Parent = menuFrame

local sizeMinus = Instance.new("TextButton")
sizeMinus.Size = UDim2.new(0, 40, 0, 28)
sizeMinus.Position = UDim2.new(0, 10, 0, 105)
sizeMinus.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
sizeMinus.Text = "-"
sizeMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeMinus.TextSize = 16
sizeMinus.Font = Enum.Font.GothamBold
sizeMinus.BorderSizePixel = 0
sizeMinus.Parent = menuFrame

local sizePlus = Instance.new("TextButton")
sizePlus.Size = UDim2.new(0, 40, 0, 28)
sizePlus.Position = UDim2.new(0, 56, 0, 105)
sizePlus.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
sizePlus.Text = "+"
sizePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
sizePlus.TextSize = 16
sizePlus.Font = Enum.Font.GothamBold
sizePlus.BorderSizePixel = 0
sizePlus.Parent = menuFrame

local sizeMinusCorner = Instance.new("UICorner")
sizeMinusCorner.CornerRadius = UDim.new(0, 6)
sizeMinusCorner.Parent = sizeMinus
local sizePlusCorner = Instance.new("UICorner")
sizePlusCorner.CornerRadius = UDim.new(0, 6)
sizePlusCorner.Parent = sizePlus

-- Arrastrable
local dragBtn = Instance.new("TextButton")
dragBtn.Size = UDim2.new(1, -20, 0, 32)
dragBtn.Position = UDim2.new(0, 10, 0, 145)
dragBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
dragBtn.Text = "Arrastrable: Sí"
dragBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dragBtn.TextSize = 13
dragBtn.Font = Enum.Font.GothamBold
dragBtn.BorderSizePixel = 0
dragBtn.Parent = menuFrame

local dragBtnCorner = Instance.new("UICorner")
dragBtnCorner.CornerRadius = UDim.new(0, 8)
dragBtnCorner.Parent = dragBtn

-- ========== BOTÓN DE LOCK ==========
local lockButton = Instance.new("TextButton")
lockButton.Name = "LockButton"
lockButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
lockButton.Position = UDim2.new(0.75, 0, 0.65, 0)
lockButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
lockButton.Text = "LOCK"
lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
lockButton.TextSize = 14
lockButton.Font = Enum.Font.GothamBold
lockButton.BorderSizePixel = 0
lockButton.Parent = screenGui

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(1, 0)
lockCorner.Parent = lockButton

local lockStroke = Instance.new("UIStroke")
lockStroke.Color = Color3.fromRGB(0, 0, 0)
lockStroke.Thickness = 1.5
lockStroke.Transparency = 0.3
lockStroke.Parent = lockButton

-- Botón minimizado del menú
local miniMenuBtn = Instance.new("TextButton")
miniMenuBtn.Size = UDim2.new(0, 46, 0, 46)
miniMenuBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
miniMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
miniMenuBtn.Text = "CL"
miniMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miniMenuBtn.TextSize = 14
miniMenuBtn.Font = Enum.Font.GothamBold
miniMenuBtn.BorderSizePixel = 0
miniMenuBtn.Visible = false
miniMenuBtn.Parent = screenGui

local miniMenuCorner = Instance.new("UICorner")
miniMenuCorner.CornerRadius = UDim.new(1, 0)
miniMenuCorner.Parent = miniMenuBtn

-- ==================== ARRASTRE ====================
local function makeDraggable(gui, condition)
	local dragging = false
	local dragStart, startPos

	gui.InputBegan:Connect(function(input)
		if not condition() then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and condition() and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

makeDraggable(menuFrame, function() return true end)
makeDraggable(miniMenuBtn, function() return true end)
makeDraggable(lockButton, function() return isDraggable end)

-- ==================== LÓGICA DEL LOCK ====================
local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local screenCenter = Camera.ViewportSize / 2

	for _, player in pairs(Players:GetPlayers()) do
		if player \~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local torso = player.Character.HumanoidRootPart
			local screenPos, onScreen = Camera:WorldToViewportPoint(torso.Position)

			if onScreen and screenPos.Z > 0 then
				local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end
	return closestPlayer
end

local function updateLock()
	if lockedPlayer and lockedPlayer.Character then
		local torso = lockedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if torso then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, torso.Position)
		end
	end
end

-- ==================== BOTONES ====================
lockButton.MouseButton1Click:Connect(function()
	if not targetLock then
		local closest = getClosestPlayer()
		if closest and closest.Character then
			lockedPlayer = closest
			targetLock = true
			lockButton.BackgroundColor3 = Color3.fromRGB(45, 170, 70)
			lockButton.Text = "ON"
		end
	else
		lockedPlayer = nil
		targetLock = false
		lockButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
		lockButton.Text = "LOCK"
	end
end)

showBtn.MouseButton1Click:Connect(function()
	buttonVisible = not buttonVisible
	lockButton.Visible = buttonVisible
	if buttonVisible then
		showBtn.Text = "Botón: Visible"
		showBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
	else
		showBtn.Text = "Botón: Oculto"
		showBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
	end
end)

sizeMinus.MouseButton1Click:Connect(function()
	buttonSize = math.max(35, buttonSize - 5)
	lockButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
	sizeLabel.Text = "Tamaño: " .. buttonSize
end)

sizePlus.MouseButton1Click:Connect(function()
	buttonSize = math.min(90, buttonSize + 5)
	lockButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
	sizeLabel.Text = "Tamaño: " .. buttonSize
end)

dragBtn.MouseButton1Click:Connect(function()
	isDraggable = not isDraggable
	if isDraggable then
		dragBtn.Text = "Arrastrable: Sí"
		dragBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
	else
		dragBtn.Text = "Arrastrable: No"
		dragBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
	end
end)

minMenuBtn.MouseButton1Click:Connect(function()
	menuOpen = false
	menuFrame.Visible = false
	miniMenuBtn.Visible = true
	miniMenuBtn.Position = menuFrame.Position
end)

miniMenuBtn.MouseButton1Click:Connect(function()
	menuOpen = true
	miniMenuBtn.Visible = false
	menuFrame.Visible = true
	menuFrame.Position = miniMenuBtn.Position
end)

-- ==================== LOOP ====================
RunService.RenderStepped:Connect(function()
	if targetLock then
		updateLock()
	end
end)

print("Mobile Camera Lock cargado")
