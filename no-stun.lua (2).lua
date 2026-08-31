local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== CONFIG ====================
local enabled = true
local networkOwnerInterval = 2 -- Segundos entre cada intento de forzar Network Owner

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LowDelayGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 130)
frame.Position = UDim2.new(0.03, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(50, 50, 60)
stroke.Thickness = 1.5
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 28)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Low Delay MS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -32, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
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
statusLabel.Size = UDim2.new(1, -20, 0, 22)
statusLabel.Position = UDim2.new(0, 10, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Estado: Optimizando..."
statusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 36)
toggleBtn.Position = UDim2.new(0, 10, 0, 70)
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

-- Botón flotante minimizado
local miniBtnFloat = Instance.new("TextButton")
miniBtnFloat.Size = UDim2.new(0, 50, 0, 50)
miniBtnFloat.Position = UDim2.new(0.03, 0, 0.4, 0)
miniBtnFloat.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
miniBtnFloat.Text = "MS"
miniBtnFloat.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtnFloat.TextSize = 16
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

-- ==================== ARRASTRE (DRAGGABLE) ====================
local function makeDraggable(guiObject)
    local dragging, dragStart, startPos = false, nil, nil

    guiObject.InputBegan:Connect(function(input)
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X, 
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(frame)
makeDraggable(miniBtnFloat)

-- ==================== LÓGICA DE LOW DELAY ====================
local function updateVisuals(state)
    if state then
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

local function optimizeCharacter(char)
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        -- Previene tropiezos que causan micro-delays visuales
        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
        
        -- Ajuste de cámara para reducir interpolación del servidor
        pcall(function()
            local camera = workspace.CurrentCamera
            if camera then
                camera.CameraType = Enum.CameraType.Custom
            end
        end)
    end
    
    if root then
        -- Forzar Network Ownership UNA SOLA VEZ al spawnear
        pcall(function()
            root:SetNetworkOwner(player)
        end)
    end
end

-- Loop ligero para mantener Network Ownership (Cada X segundos, no en cada frame)
task.spawn(function()
    while true do
        task.wait(networkOwnerInterval)
        if enabled and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                pcall(function()
                    root:SetNetworkOwner(player)
                end)
            end
        end
    end
end)

-- Conexión de eventos de personaje
player.CharacterAdded:Connect(function(char)
    task.wait(0.5) -- Espera a que el personaje cargue completamente
    if enabled then
        optimizeCharacter(char)
    end
end)

if player.Character and enabled then
    optimizeCharacter(player.Character)
end

-- ==================== EVENTOS DE GUI ====================
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    updateVisuals(enabled)
    if enabled and player.Character then
        optimizeCharacter(player.Character)
    end
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

updateVisuals(enabled)
print("Low Delay Optimizado cargado correctamente")
