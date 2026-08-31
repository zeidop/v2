local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== CONFIG ====================
local enabled = false
local smoothness = 0.18          -- Qué tan suave sigue (más bajo = más rápido)
local prediction = 0.12          -- Fuerza de la predicción de movimiento
local maxDistance = 120          -- Distancia máxima para lockear

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CameraLockGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 110, 0, 42)
button.Position = UDim2.new(0.5, -55, 0.78, 0)
button.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
button.Text = "LOCK: OFF"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 15
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 0, 0)
stroke.Thickness = 1.4
stroke.Transparency = 0.3
stroke.Parent = button

-- Arrastrar el botón
local dragging = false
local dragStart, startPos

button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = button.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ==================== LÓGICA ====================
local function getClosestToCenter()
	local closest = nil
	local shortest = math.huge
	local screenCenter = Camera.ViewportSize / 2

	for _, plr in pairs(Players:GetPlayers()) do
		if plr \~= player and plr.Character then
			local char = plr.Character
			local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
			local humanoid = char:FindFirstChildOfClass("Humanoid")

			if torso and humanoid and humanoid.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(torso.Position)
				if onScreen and pos.Z > 0 then
					local distanceFromCenter = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
					local worldDistance = (torso.Position - Camera.CFrame.Position).Magnitude

					if distanceFromCenter < shortest and worldDistance <= maxDistance then
						shortest = distanceFromCenter
						closest = torso
					end
				end
			end
		end
	end

	return closest
end

local function getPredictedPosition(part)
	if not part then return nil end
	local velocity = part.AssemblyLinearVelocity or Vector3.zero
	return part.Position + (velocity * prediction)
end

-- Soft lock principal
RunService.RenderStepped:Connect(function()
	if not enabled then return end

	local target = getClosestToCenter()
	if not target then return end

	local predictedPos = getPredictedPosition(target)
	if not predictedPos then return end

	local currentCF = Camera.CFrame
	local targetCF = CFrame.new(currentCF.Position, predictedPos)

	-- Soft lock: mezcla la cámara actual con la dirección al objetivo
	Camera.CFrame = currentCF:Lerp(targetCF, smoothness)
end)

-- Toggle
button.MouseButton1Click:Connect(function()
	enabled = not enabled
	if enabled then
		button.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
		button.Text = "LOCK: ON"
	else
		button.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
		button.Text = "LOCK: OFF"
	end
end)

print("Camera Lock (Soft + Prediction) cargado")
