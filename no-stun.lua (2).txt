local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local enabled = false
local jumping = true
local jumpPower = 50
local dashForce = 60
local hitRegEnabled = false
local hitReg = 8
local minimized = false
local locked = false

local jumpBtnSize = 62
local dashBtnSize = 62
local originalSizes = {}

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")

player.CharacterAdded:Connect(function(c)
	character = c
	humanoid = c:WaitForChild("Humanoid")
	root = c:WaitForChild("HumanoidRootPart", 3) or c:FindFirstChild("Torso")
	jumping = true
end)

local function jump()
	if not humanoid or not root or not jumping then return end
	jumping = false
	humanoid.PlatformStand = true
	root.Velocity = Vector3.zero
	task.wait()
	root.Velocity = Vector3.new(0, jumpPower, 0)
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	task.wait(0.05)
	humanoid.PlatformStand = false
	task.wait(1.2)
	jumping = true
end

local function dash()
	if not humanoid or not root then return end
	local lookVector = root.CFrame.LookVector
	root.Velocity = Vector3.new(lookVector.X * dashForce, root.Velocity.Y, lookVector.Z * dashForce)
end

local function applyHitReg()
	if not hitRegEnabled then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr \~= player and plr.Character then
			local char = plr.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				if not originalSizes[hrp] then
					originalSizes[hrp] = hrp.Size
				end
				hrp.Size = Vector3.new(hitReg, hitReg, hitReg)
				hrp.Transparency = 0.65
				hrp.CanCollide = false
				hrp.Massless = true
			end
		end
	end
end

local function restoreHitReg()
	for part, size in pairs(originalSizes) do
		if part and part.Parent then
			part.Size = size
			part.Transparency = 0
			part.CanCollide = true
			part.Massless = false
		end
	end
	originalSizes = {}
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiStunMobile"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 170, 0, 400)
mainFrame.Position = UDim2.new(0.03, 0, 0.16, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 70)
mainStroke.Thickness = 1.2
mainStroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 28)
title.Position = UDim2.new(0, 8, 0, 4)
title.BackgroundTransparency = 1
title.Text = "Anti-Stun"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -28, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
minBtn.Text = "–"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -16, 0, 34)
toggleBtn.Position = UDim2.new(0, 8, 0, 36)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 55, 55)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(1, -16, 0, 18)
jumpLabel.Position = UDim2.new(0, 8, 0, 78)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "Jump Power: 50"
jumpLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
jumpLabel.TextSize = 12
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpLabel.Parent = mainFrame

local jumpMinus = Instance.new("TextButton")
jumpMinus.Size = UDim2.new(0, 32, 0, 26)
jumpMinus.Position = UDim2.new(0, 8, 0, 98)
jumpMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
jumpMinus.Text = "-"
jumpMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpMinus.TextSize = 16
jumpMinus.Font = Enum.Font.GothamBold
jumpMinus.BorderSizePixel = 0
jumpMinus.Parent = mainFrame

local jumpPlus = Instance.new("TextButton")
jumpPlus.Size = UDim2.new(0, 32, 0, 26)
jumpPlus.Position = UDim2.new(0, 44, 0, 98)
jumpPlus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
jumpPlus.Text = "+"
jumpPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpPlus.TextSize = 16
jumpPlus.Font = Enum.Font.GothamBold
jumpPlus.BorderSizePixel = 0
jumpPlus.Parent = mainFrame

local generateJumpBtn = Instance.new("TextButton")
generateJumpBtn.Size = UDim2.new(0, 70, 0, 26)
generateJumpBtn.Position = UDim2.new(0, 84, 0, 98)
generateJumpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
generateJumpBtn.Text = "JUMP"
generateJumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
generateJumpBtn.TextSize = 12
generateJumpBtn.Font = Enum.Font.GothamBold
generateJumpBtn.BorderSizePixel = 0
generateJumpBtn.Parent = mainFrame

local jumpCorner1 = Instance.new("UICorner")
jumpCorner1.CornerRadius = UDim.new(0, 6)
jumpCorner1.Parent = jumpMinus
local jumpCorner2 = Instance.new("UICorner")
jumpCorner2.CornerRadius = UDim.new(0, 6)
jumpCorner2.Parent = jumpPlus
local generateJumpCorner = Instance.new("UICorner")
generateJumpCorner.CornerRadius = UDim.new(0, 6)
generateJumpCorner.Parent = generateJumpBtn

local dashLabel = Instance.new("TextLabel")
dashLabel.Size = UDim2.new(1, -16, 0, 18)
dashLabel.Position = UDim2.new(0, 8, 0, 132)
dashLabel.BackgroundTransparency = 1
dashLabel.Text = "Dash Force: 60"
dashLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
dashLabel.TextSize = 12
dashLabel.Font = Enum.Font.Gotham
dashLabel.TextXAlignment = Enum.TextXAlignment.Left
dashLabel.Parent = mainFrame

local dashMinus = Instance.new("TextButton")
dashMinus.Size = UDim2.new(0, 32, 0, 26)
dashMinus.Position = UDim2.new(0, 8, 0, 152)
dashMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
dashMinus.Text = "-"
dashMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
dashMinus.TextSize = 16
dashMinus.Font = Enum.Font.GothamBold
dashMinus.BorderSizePixel = 0
dashMinus.Parent = mainFrame

local dashPlus = Instance.new("TextButton")
dashPlus.Size = UDim2.new(0, 32, 0, 26)
dashPlus.Position = UDim2.new(0, 44, 0, 152)
dashPlus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
dashPlus.Text = "+"
dashPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
dashPlus.TextSize = 16
dashPlus.Font = Enum.Font.GothamBold
dashPlus.BorderSizePixel = 0
dashPlus.Parent = mainFrame

local generateDashBtn = Instance.new("TextButton")
generateDashBtn.Size = UDim2.new(0, 70, 0, 26)
generateDashBtn.Position = UDim2.new(0, 84, 0, 152)
generateDashBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
generateDashBtn.Text = "DASH"
generateDashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
generateDashBtn.TextSize = 12
generateDashBtn.Font = Enum.Font.GothamBold
generateDashBtn.BorderSizePixel = 0
generateDashBtn.Parent = mainFrame

local dashCorner1 = Instance.new("UICorner")
dashCorner1.CornerRadius = UDim.new(0, 6)
dashCorner1.Parent = dashMinus
local dashCorner2 = Instance.new("UICorner")
dashCorner2.CornerRadius = UDim.new(0, 6)
dashCorner2.Parent = dashPlus
local generateDashCorner = Instance.new("UICorner")
generateDashCorner.CornerRadius = UDim.new(0, 6)
generateDashCorner.Parent = generateDashBtn

local jumpSizeLabel = Instance.new("TextLabel")
jumpSizeLabel.Size = UDim2.new(1, -16, 0, 18)
jumpSizeLabel.Position = UDim2.new(0, 8, 0, 188)
jumpSizeLabel.BackgroundTransparency = 1
jumpSizeLabel.Text = "Jump Size: 62"
jumpSizeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
jumpSizeLabel.TextSize = 12
jumpSizeLabel.Font = Enum.Font.Gotham
jumpSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpSizeLabel.Parent = mainFrame

local jumpSizeMinus = Instance.new("TextButton")
jumpSizeMinus.Size = UDim2.new(0, 32, 0, 26)
jumpSizeMinus.Position = UDim2.new(0, 8, 0, 208)
jumpSizeMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
jumpSizeMinus.Text = "-"
jumpSizeMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpSizeMinus.TextSize = 16
jumpSizeMinus.Font = Enum.Font.GothamBold
jumpSizeMinus.BorderSizePixel = 0
jumpSizeMinus.Parent = mainFrame

local jumpSizePlus = Instance.new("TextButton")
jumpSizePlus.Size = UDim2.new(0, 32, 0, 26)
jumpSizePlus.Position = UDim2.new(0, 44, 0, 208)
jumpSizePlus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
jumpSizePlus.Text = "+"
jumpSizePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpSizePlus.TextSize = 16
jumpSizePlus.Font = Enum.Font.GothamBold
jumpSizePlus.BorderSizePixel = 0
jumpSizePlus.Parent = mainFrame

local jumpSizeCorner1 = Instance.new("UICorner")
jumpSizeCorner1.CornerRadius = UDim.new(0, 6)
jumpSizeCorner1.Parent = jumpSizeMinus
local jumpSizeCorner2 = Instance.new("UICorner")
jumpSizeCorner2.CornerRadius = UDim.new(0, 6)
jumpSizeCorner2.Parent = jumpSizePlus

local dashSizeLabel = Instance.new("TextLabel")
dashSizeLabel.Size = UDim2.new(1, -16, 0, 18)
dashSizeLabel.Position = UDim2.new(0, 8, 0, 242)
dashSizeLabel.BackgroundTransparency = 1
dashSizeLabel.Text = "Dash Size: 62"
dashSizeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
dashSizeLabel.TextSize = 12
dashSizeLabel.Font = Enum.Font.Gotham
dashSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
dashSizeLabel.Parent = mainFrame

local dashSizeMinus = Instance.new("TextButton")
dashSizeMinus.Size = UDim2.new(0, 32, 0, 26)
dashSizeMinus.Position = UDim2.new(0, 8, 0, 262)
dashSizeMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
dashSizeMinus.Text = "-"
dashSizeMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
dashSizeMinus.TextSize = 16
dashSizeMinus.Font = Enum.Font.GothamBold
dashSizeMinus.BorderSizePixel = 0
dashSizeMinus.Parent = mainFrame

local dashSizePlus = Instance.new("TextButton")
dashSizePlus.Size = UDim2.new(0, 32, 0, 26)
dashSizePlus.Position = UDim2.new(0, 44, 0, 262)
dashSizePlus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
dashSizePlus.Text = "+"
dashSizePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
dashSizePlus.TextSize = 16
dashSizePlus.Font = Enum.Font.GothamBold
dashSizePlus.BorderSizePixel = 0
dashSizePlus.Parent = mainFrame

local dashSizeCorner1 = Instance.new("UICorner")
dashSizeCorner1.CornerRadius = UDim.new(0, 6)
dashSizeCorner1.Parent = dashSizeMinus
local dashSizeCorner2 = Instance.new("UICorner")
dashSizeCorner2.CornerRadius = UDim.new(0, 6)
dashSizeCorner2.Parent = dashSizePlus

local hitRegToggle = Instance.new("TextButton")
hitRegToggle.Size = UDim2.new(1, -16, 0, 32)
hitRegToggle.Position = UDim2.new(0, 8, 0, 296)
hitRegToggle.BackgroundColor3 = Color3.fromRGB(160, 70, 30)
hitRegToggle.Text = "Hit Reg Fix: OFF"
hitRegToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
hitRegToggle.TextSize = 13
hitRegToggle.Font = Enum.Font.GothamBold
hitRegToggle.BorderSizePixel = 0
hitRegToggle.Parent = mainFrame

local hitRegToggleCorner = Instance.new("UICorner")
hitRegToggleCorner.CornerRadius = UDim.new(0, 8)
hitRegToggleCorner.Parent = hitRegToggle

local hitRegLabel = Instance.new("TextLabel")
hitRegLabel.Size = UDim2.new(1, -16, 0, 18)
hitRegLabel.Position = UDim2.new(0, 8, 0, 334)
hitRegLabel.BackgroundTransparency = 1
hitRegLabel.Text = "Hit Reg Value: 8"
hitRegLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
hitRegLabel.TextSize = 12
hitRegLabel.Font = Enum.Font.Gotham
hitRegLabel.TextXAlignment = Enum.TextXAlignment.Left
hitRegLabel.Parent = mainFrame

local hitRegMinus = Instance.new("TextButton")
hitRegMinus.Size = UDim2.new(0, 32, 0, 26)
hitRegMinus.Position = UDim2.new(0, 8, 0, 354)
hitRegMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
hitRegMinus.Text = "-"
hitRegMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
hitRegMinus.TextSize = 16
hitRegMinus.Font = Enum.Font.GothamBold
hitRegMinus.BorderSizePixel = 0
hitRegMinus.Parent = mainFrame

local hitRegPlus = Instance.new("TextButton")
hitRegPlus.Size = UDim2.new(0, 32, 0, 26)
hitRegPlus.Position = UDim2.new(0, 44, 0, 354)
hitRegPlus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
hitRegPlus.Text = "+"
hitRegPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
hitRegPlus.TextSize = 16
hitRegPlus.Font = Enum.Font.GothamBold
hitRegPlus.BorderSizePixel = 0
hitRegPlus.Parent = mainFrame

local hitRegCorner1 = Instance.new("UICorner")
hitRegCorner1.CornerRadius = UDim.new(0, 6)
hitRegCorner1.Parent = hitRegMinus
local hitRegCorner2 = Instance.new("UICorner")
hitRegCorner2.CornerRadius = UDim.new(0, 6)
hitRegCorner2.Parent = hitRegPlus

local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(1, -16, 0, 28)
lockBtn.Position = UDim2.new(0, 8, 0, 390)
lockBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
lockBtn.Text = "LOCK: OFF"
lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lockBtn.TextSize = 13
lockBtn.Font = Enum.Font.GothamBold
lockBtn.BorderSizePixel = 0
lockBtn.Parent = mainFrame

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(0, 7)
lockCorner.Parent = lockBtn

local miniBtn = Instance.new("TextButton")
miniBtn.Name = "MiniButton"
miniBtn.Size = UDim2.new(0, 48, 0, 48)
miniBtn.Position = UDim2.new(0.03, 0, 0.16, 0)
miniBtn.BackgroundColor3 = Color3.fromRGB(200, 55, 55)
miniBtn.Text = "AS"
miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtn.TextSize = 16
miniBtn.Font = Enum.Font.GothamBold
miniBtn.BorderSizePixel = 0
miniBtn.Visible = false
miniBtn.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniBtn

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(0, 0, 0)
miniStroke.Thickness = 1.5
miniStroke.Transparency = 0.3
miniStroke.Parent = miniBtn

local jumpBtn = Instance.new("TextButton")
jumpBtn.Name = "JumpButton"
jumpBtn.Size = UDim2.new(0, jumpBtnSize, 0, jumpBtnSize)
jumpBtn.Position = UDim2.new(0.72, 0, 0.68, 0)
jumpBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
jumpBtn.Text = "JUMP"
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.TextSize = 14
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.BorderSizePixel = 0
jumpBtn.Visible = false
jumpBtn.Parent = screenGui

local jumpBtnCorner = Instance.new("UICorner")
jumpBtnCorner.CornerRadius = UDim.new(1, 0)
jumpBtnCorner.Parent = jumpBtn

local jumpBtnStroke = Instance.new("UIStroke")
jumpBtnStroke.Color = Color3.fromRGB(80, 80, 80)
jumpBtnStroke.Thickness = 1.8
jumpBtnStroke.Parent = jumpBtn

local dashFloatBtn = Instance.new("TextButton")
dashFloatBtn.Name = "DashButton"
dashFloatBtn.Size = UDim2.new(0, dashBtnSize, 0, dashBtnSize)
dashFloatBtn.Position = UDim2.new(0.72, 0, 0.55, 0)
dashFloatBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
dashFloatBtn.Text = "DASH"
dashFloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dashFloatBtn.TextSize = 14
dashFloatBtn.Font = Enum.Font.GothamBold
dashFloatBtn.BorderSizePixel = 0
dashFloatBtn.Visible = false
dashFloatBtn.Parent = screenGui

local dashFloatCorner = Instance.new("UICorner")
dashFloatCorner.CornerRadius = UDim.new(1, 0)
dashFloatCorner.Parent = dashFloatBtn

local dashFloatStroke = Instance.new("UIStroke")
dashFloatStroke.Color = Color3.fromRGB(0, 0, 0)
dashFloatStroke.Thickness = 1.5
dashFloatStroke.Transparency = 0.3
dashFloatStroke.Parent = dashFloatBtn

local function makeDraggable(guiObject, isFloating)
	local dragging = false
	local dragStart, startPos

	guiObject.InputBegan:Connect(function(input)
		if locked and isFloating then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if locked and isFloating then return end
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

makeDraggable(mainFrame, false)
makeDraggable(miniBtn, false)
makeDraggable(jumpBtn, true)
makeDraggable(dashFloatBtn, true)

local function updateToggleVisual()
	if enabled then
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
		toggleBtn.Text = "ON"
		miniBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
	else
		toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 55, 55)
		toggleBtn.Text = "OFF"
		miniBtn.BackgroundColor3 = Color3.fromRGB(200, 55, 55)
	end
end

local function updateHitRegVisual()
	if hitRegEnabled then
		hitRegToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
		hitRegToggle.Text = "Hit Reg Fix: ON"
	else
		hitRegToggle.BackgroundColor3 = Color3.fromRGB(160, 70, 30)
		hitRegToggle.Text = "Hit Reg Fix: OFF"
	end
end

local function setEnabled(state)
	enabled = state
	jumping = true
	updateToggleVisual()
end

local function updateJumpSize()
	jumpBtn.Size = UDim2.new(0, jumpBtnSize, 0, jumpBtnSize)
	jumpSizeLabel.Text = "Jump Size: " .. jumpBtnSize
end

local function updateDashSize()
	dashFloatBtn.Size = UDim2.new(0, dashBtnSize, 0, dashBtnSize)
	dashSizeLabel.Text = "Dash Size: " .. dashBtnSize
end

toggleBtn.MouseButton1Click:Connect(function()
	setEnabled(not enabled)
end)

hitRegToggle.MouseButton1Click:Connect(function()
	hitRegEnabled = not hitRegEnabled
	updateHitRegVisual()
	if hitRegEnabled then
		applyHitReg()
	else
		restoreHitReg()
	end
end)

minBtn.MouseButton1Click:Connect(function()
	minimized = true
	mainFrame.Visible = false
	miniBtn.Visible = true
	miniBtn.Position = mainFrame.Position
end)

miniBtn.MouseButton1Click:Connect(function()
	minimized = false
	miniBtn.Visible = false
	mainFrame.Visible = true
	mainFrame.Position = miniBtn.Position
end)

jumpMinus.MouseButton1Click:Connect(function()
	jumpPower = math.max(10, jumpPower - 5)
	jumpLabel.Text = "Jump Power: " .. jumpPower
end)

jumpPlus.MouseButton1Click:Connect(function()
	jumpPower = math.min(150, jumpPower + 5)
	jumpLabel.Text = "Jump Power: " .. jumpPower
end)

dashMinus.MouseButton1Click:Connect(function()
	dashForce = math.max(10, dashForce - 5)
	dashLabel.Text = "Dash Force: " .. dashForce
end)

dashPlus.MouseButton1Click:Connect(function()
	dashForce = math.min(150, dashForce + 5)
	dashLabel.Text = "Dash Force: " .. dashForce
end)

hitRegMinus.MouseButton1Click:Connect(function()
	hitReg = math.max(1, hitReg - 1)
	hitRegLabel.Text = "Hit Reg Value: " .. hitReg
	if hitRegEnabled then applyHitReg() end
end)

hitRegPlus.MouseButton1Click:Connect(function()
	hitReg = math.min(100, hitReg + 1)
	hitRegLabel.Text = "Hit Reg Value: " .. hitReg
	if hitRegEnabled then applyHitReg() end
end)

jumpSizeMinus.MouseButton1Click:Connect(function()
	jumpBtnSize = math.max(1, jumpBtnSize - 2)
	updateJumpSize()
end)

jumpSizePlus.MouseButton1Click:Connect(function()
	jumpBtnSize = math.min(100, jumpBtnSize + 2)
	updateJumpSize()
end)

dashSizeMinus.MouseButton1Click:Connect(function()
	dashBtnSize = math.max(1, dashBtnSize - 2)
	updateDashSize()
end)

dashSizePlus.MouseButton1Click:Connect(function()
	dashBtnSize = math.min(100, dashBtnSize + 2)
	updateDashSize()
end)

generateJumpBtn.MouseButton1Click:Connect(function()
	jumpBtn.Visible = not jumpBtn.Visible
end)

generateDashBtn.MouseButton1Click:Connect(function()
	dashFloatBtn.Visible = not dashFloatBtn.Visible
end)

lockBtn.MouseButton1Click:Connect(function()
	locked = not locked
	if locked then
		lockBtn.Text = "LOCK: ON"
		lockBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	else
		lockBtn.Text = "LOCK: OFF"
		lockBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
	end
end)

jumpBtn.MouseButton1Click:Connect(function()
	jump()
end)

dashFloatBtn.MouseButton1Click:Connect(function()
	dash()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.X then
		setEnabled(not enabled)
	elseif input.KeyCode == Enum.KeyCode.Z then
		setEnabled(false)
	elseif input.KeyCode == Enum.KeyCode.Space and enabled then
		jump()
	elseif input.KeyCode == Enum.KeyCode.Q then
		dash()
	end
end)

RunService.Heartbeat:Connect(function()
	if not enabled or not humanoid or not jumping then return end
	local state = humanoid:GetState()
	if state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.GettingUp or state == Enum.HumanoidStateType.Stunned then
		jump()
	end
end)

task.spawn(function()
	while true do
		task.wait(0.4)
		if hitRegEnabled then
			applyHitReg()
		end
	end
end)

print("Anti-Stun Mobile + Hit Reg Fix cargado correctamente")
