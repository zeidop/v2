local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local enabled = false
local smoothness = 0.16
local prediction = 0.11
local maxDistance = 110

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CameraLockGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local button = Instance.new("TextButton")
button.Name = "LockButton"
button.Size = UDim2.new(0, 115, 0, 44)
button.Position = UDim2.new(0.5, -57, 0.76, 0)
button.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
button.Text = "LOCK: OFF"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 15
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 0, 0)
stroke.Thickness = 1.5
stroke.Transparency = 0.35
stroke.Parent = button

-- Arrastre del botón
local dragging = false
local dragStart = nil
local startPos = nil

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
		button.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- ==================== FUNCIONES ====================
local function getClosestToCenter()
	local closestPart = nil
	local shortest = math.huge
	local screenCenter = Camera.ViewportSize / 2

	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer \~= player and otherPlayer.Character then
			local char = otherPlayer.Character
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoid.Health > 0 and torso then
				local screenPos, onScreen = Camera:WorldToViewportPoint(torso.Position)

				if onScreen and screenPos.Z > 0 then
					local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
					local worldDist = (torso.Position - Camera.CFrame.Position).Magnitude

					if distFromCenter < shortest and worldDist <= maxDistance then
						shortest = distFromCenter
						closestPart = torso
					end
				end
			end
		end
	end

	return closestPart
end

-- ==================== LOOP ====================
RunService.RenderStepped:Connect(function()
	if not enabled then return end

	local target = getClosestToCenter()
	if not target then return end

	local velocity = target.AssemblyLinearVelocity
	if typeof(velocity) \~= "Vector3" then
		velocity = Vector3.zero
	end

	local predicted = target.Position + (velocity * prediction)
	local current = Camera.CFrame
	local lookAt = CFrame.new(current.Position, predicted)

	Camera.CFrame = current:Lerp(lookAt, smoothness)
end)

-- ==================== TOGGLE ====================
button.MouseButton1Click:Connect(function()
	enabled = not enabled

	if enabled then
		button.BackgroundColor3 = Color3.fromRGB(45, 175, 75)
		button.Text = "LOCK: ON"
	else
		button.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
		button.Text = "LOCK: OFF"
	end
end)

print("Camera Lock cargado correctamente")
