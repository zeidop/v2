local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local Camera = workspace.CurrentCamera

-- ==================== CONFIG ====================
local targetLock = false
local lockedPlayer = nil
local buttonVisible = true
local buttonSize = 55
local isDraggable = true

-- PREDICT CONFIG
local predictEnabled = true
local predictAmount = 0.18 -- segundos de prediccion (0.05 a 0.4)
local lastTargetPos = nil
local smoothedVelocity = Vector3.new(0, 0, 0)

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileCameraLock"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 170, 0, 290) -- Altura aumentada para predict
menuFrame.Position = UDim2.new(0.03, 0, 0.25, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
menuFrame.BorderSizePixel = 0
menuFrame.Active = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menuFrame

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(55, 55, 65)
menuStroke.Thickness = 1.2
menuStroke.Parent = menuFrame

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

local minMenuBtn = Instance.new("TextButton")
minMenuBtn.Size = UDim2.new(0, 26, 0, 26)
minMenuBtn.Position = UDim2.new(1, -32, 0, 6)
minMenuBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
minMenuBtn.Text = "-"
minMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minMenuBtn.TextSize = 18
minMenuBtn.Font = Enum.Font.GothamBold
minMenuBtn.BorderSizePixel = 0
minMenuBtn.Parent = menuFrame

local minMenuCorner = Instance.new("UICorner")
minMenuCorner.CornerRadius = UDim.new(0, 6)
minMenuCorner.Parent = minMenuBtn

-- BOTON VISIBLE
local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.new(1, -20, 0, 32)
showBtn.Position = UDim2.new(0, 10, 0, 42)
showBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
showBtn.Text = "Boton: Visible"
showBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
showBtn.TextSize = 13
showBtn.Font = Enum.Font.GothamBold
showBtn.BorderSizePixel = 0
showBtn.Parent = menuFrame

local showBtnCorner = Instance.new("UICorner")
showBtnCorner.CornerRadius = UDim.new(0, 8)
showBtnCorner.Parent = showBtn

-- TAMANO
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(1, -20, 0, 20)
sizeLabel.Position = UDim2.new(0, 10, 0, 82)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "Tamano: 55"
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

local sizeMinusCorner = Instance.new("UICorner")
sizeMinusCorner.CornerRadius = UDim.new(0, 6)
sizeMinusCorner.Parent = sizeMinus

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

local sizePlusCorner = Instance.new("UICorner")
sizePlusCorner.CornerRadius = UDim.new(0, 6)
sizePlusCorner.Parent = sizePlus

-- ARRASTRABLE
local dragBtn = Instance.new("TextButton")
dragBtn.Size = UDim2.new(1, -20, 0, 32)
dragBtn.Position = UDim2.new(0, 10, 0, 145)
dragBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
dragBtn.Text = "Arrastrable: Si"
dragBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dragBtn.TextSize = 13
dragBtn.Font = Enum.Font.GothamBold
dragBtn.BorderSizePixel = 0
dragBtn.Parent = menuFrame

local dragBtnCorner = Instance.new("UICorner")
dragBtnCorner.CornerRadius = UDim.new(0, 8)
dragBtnCorner.Parent = dragBtn

-- ==================== NUEVO: PREDICT ====================
local predictLabel = Instance.new("TextLabel")
predictLabel.Size = UDim2.new(1, -20, 0, 20)
predictLabel.Position = UDim2.new(0, 10, 0, 185)
predictLabel.BackgroundTransparency = 1
predictLabel.Text = "Predict: 0.18s"
predictLabel.TextColor3 = Color3.fromRGB(255, 220, 130)
predictLabel.TextSize = 12
predictLabel.Font = Enum.Font.GothamBold
predictLabel.TextXAlignment = Enum.TextXAlignment.Left
predictLabel.Parent = menuFrame

local predictMinus = Instance.new("TextButton")
predictMinus.Size = UDim2.new(0, 40, 0, 28)
predictMinus.Position = UDim2.new(0, 10, 0, 208)
predictMinus.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
predictMinus.Text = "-"
predictMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
predictMinus.TextSize = 16
predictMinus.Font = Enum.Font.GothamBold
predictMinus.BorderSizePixel = 0
predictMinus.Parent = menuFrame

local predictMinusCorner = Instance.new("UICorner")
predictMinusCorner.CornerRadius = UDim.new(0, 6)
predictMinusCorner.Parent = predictMinus

local predictPlus = Instance.new("TextButton")
predictPlus.Size = UDim2.new(0, 40, 0, 28)
predictPlus.Position = UDim2.new(0, 56, 0, 208)
predictPlus.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
predictPlus.Text = "+"
predictPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
predictPlus.TextSize = 16
predictPlus.Font = Enum.Font.GothamBold
predictPlus.BorderSizePixel = 0
predictPlus.Parent = menuFrame

local predictPlusCorner = Instance.new("UICorner")
predictPlusCorner.CornerRadius = UDim.new(0, 6)
predictPlusCorner.Parent = predictPlus

local predictToggle = Instance.new("TextButton")
predictToggle.Size = UDim2.new(0, 48, 0, 28)
predictToggle.Position = UDim2.new(0, 102, 0, 208)
predictToggle.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
predictToggle.Text = "ON"
predictToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
predictToggle.TextSize = 12
predictToggle.Font = Enum.Font.GothamBold
predictToggle.BorderSizePixel = 0
predictToggle.Parent = menuFrame

local predictToggleCorner = Instance.new("UICorner")
predictToggleCorner.CornerRadius = UDim.new(0, 6)
predictToggleCorner.Parent = predictToggle

-- Info predict
local predictInfo = Instance.new("TextLabel")
predictInfo.Size = UDim2.new(1, -20, 0, 30)
predictInfo.Position = UDim2.new(0, 10, 0, 240)
predictInfo.BackgroundTransparency = 1
predictInfo.Text = "Adelanta la camara al\nmovimiento del enemigo"
predictInfo.TextColor3 = Color3.fromRGB(140, 140, 150)
predictInfo.TextSize = 9
predictInfo.Font = Enum.Font.Gotham
predictInfo.TextXAlignment = Enum.TextXAlignment.Left
predictInfo.TextYAlignment = Enum.TextYAlignment.Top
predictInfo.TextWrapped = true
predictInfo.Parent = menuFrame

-- ==================== BOTON LOCK ====================
local lockButton = Instance.new("TextButton")
lockButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
lockButton.Position = UDim2.new(0.75, 0, 0.65, 0)
lockButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
lockButton.Text = "LOCK"
lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
lockButton.TextSize = 14
lockButton.Font = Enum.Font.GothamBold
lockButton.BorderSizePixel = 0
lockButton.Active = true
lockButton.Parent = screenGui

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(1, 0)
lockCorner.Parent = lockButton

local lockStroke = Instance.new("UIStroke")
lockStroke.Color = Color3.fromRGB(0, 0, 0)
lockStroke.Thickness = 1.5
lockStroke.Transparency = 0.3
lockStroke.Parent = lockButton

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
miniMenuBtn.Active = true
miniMenuBtn.Parent = screenGui

local miniMenuCorner = Instance.new("UICorner")
miniMenuCorner.CornerRadius = UDim.new(1, 0)
miniMenuCorner.Parent = miniMenuBtn

-- ==================== ARRASTRE ====================
local function makeDraggable(gui, condition)
    local dragging = false
    local dragStart = nil
    local startPos = nil

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
        if not dragging then return end
        if not condition() then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(menuFrame, function() return true end)
makeDraggable(miniMenuBtn, function() return true end)
makeDraggable(lockButton, function() return isDraggable end)

-- ==================== LOGICA ====================
local function getClosestPlayer()
    Camera = workspace.CurrentCamera
    if not Camera then return nil end

    local closestPlayer = nil
    local shortestDistance = math.huge
    local vp = Camera.ViewportSize
    local screenCenter = Vector2.new(vp.X / 2, vp.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen and screenPos.Z > 0 then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

lockButton.MouseButton1Click:Connect(function()
    if not targetLock then
        local closest = getClosestPlayer()
        if closest then
            lockedPlayer = closest
            targetLock = true
            lockButton.BackgroundColor3 = Color3.fromRGB(45, 170, 70)
            lockButton.Text = "ON"
            -- Resetear prediccion al cambiar de objetivo
            lastTargetPos = nil
            smoothedVelocity = Vector3.new(0, 0, 0)
        end
    else
        lockedPlayer = nil
        targetLock = false
        lockButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
        lockButton.Text = "LOCK"
        lastTargetPos = nil
        smoothedVelocity = Vector3.new(0, 0, 0)
    end
end)

showBtn.MouseButton1Click:Connect(function()
    buttonVisible = not buttonVisible
    lockButton.Visible = buttonVisible
    if buttonVisible then
        showBtn.Text = "Boton: Visible"
        showBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
    else
        showBtn.Text = "Boton: Oculto"
        showBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
    end
end)

sizeMinus.MouseButton1Click:Connect(function()
    buttonSize = math.max(35, buttonSize - 5)
    lockButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    sizeLabel.Text = "Tamano: " .. tostring(buttonSize)
end)

sizePlus.MouseButton1Click:Connect(function()
    buttonSize = math.min(90, buttonSize + 5)
    lockButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    sizeLabel.Text = "Tamano: " .. tostring(buttonSize)
end)

dragBtn.MouseButton1Click:Connect(function()
    isDraggable = not isDraggable
    if isDraggable then
        dragBtn.Text = "Arrastrable: Si"
        dragBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
    else
        dragBtn.Text = "Arrastrable: No"
        dragBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
    end
end)

-- PREDICT CONTROLES
predictMinus.MouseButton1Click:Connect(function()
    predictAmount = math.max(0.05, predictAmount - 0.02)
    predictAmount = math.floor(predictAmount * 100 + 0.5) / 100
    predictLabel.Text = string.format("Predict: %.2fs", predictAmount)
end)

predictPlus.MouseButton1Click:Connect(function()
    predictAmount = math.min(0.4, predictAmount + 0.02)
    predictAmount = math.floor(predictAmount * 100 + 0.5) / 100
    predictLabel.Text = string.format("Predict: %.2fs", predictAmount)
end)

predictToggle.MouseButton1Click:Connect(function()
    predictEnabled = not predictEnabled
    if predictEnabled then
        predictToggle.Text = "ON"
        predictToggle.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
        predictLabel.TextColor3 = Color3.fromRGB(255, 220, 130)
    else
        predictToggle.Text = "OFF"
        predictToggle.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
        predictLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

minMenuBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    miniMenuBtn.Visible = true
    miniMenuBtn.Position = menuFrame.Position
end)

miniMenuBtn.MouseButton1Click:Connect(function()
    miniMenuBtn.Visible = false
    menuFrame.Visible = true
    menuFrame.Position = miniMenuBtn.Position
end)

-- ==================== CAMERA LOCK CON PREDICT ====================
local lastDeltaTime = 1/60

RunService.RenderStepped:Connect(function(dt)
    lastDeltaTime = dt or (1/60)
    
    if targetLock and lockedPlayer and lockedPlayer.Character then
        Camera = workspace.CurrentCamera
        if not Camera then return end
        
        local root = lockedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = lockedPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if root and hum and hum.Health > 0 then
            local targetPos = root.Position
            local aimPosition = targetPos -- por defecto apuntar a posicion actual
            
            -- SISTEMA DE PREDICCION
            if predictEnabled then
                -- Calcular velocidad del objetivo
                local currentVelocity = Vector3.new(0, 0, 0)
                
                -- Metodo 1: Usar AssemblyLinearVelocity (mas preciso si existe)
                local vel = root.AssemblyLinearVelocity or root.Velocity
                if vel and vel.Magnitude > 1 then
                    currentVelocity = vel
                -- Metodo 2: Calcular desde posicion anterior (fallback)
                elseif lastTargetPos then
                    local delta = targetPos - lastTargetPos
                    local elapsed = math.max(0.01, lastDeltaTime)
                    currentVelocity = delta / elapsed
                end
                
                -- Solo predecir si el objetivo se esta moviendo
                if currentVelocity.Magnitude > 1 then
                    -- Suavizar la velocidad para evitar saltos bruscos
                    local smoothFactor = 0.25 -- 25% nueva velocidad, 75% anterior
                    smoothedVelocity = smoothedVelocity * (1 - smoothFactor) + currentVelocity * smoothFactor
                    
                    -- Calcular posicion predicha
                    -- Ignorar Y vertical para que la camara no se vaya al cielo
                    local flatVelocity = Vector3.new(smoothedVelocity.X, 0, smoothedVelocity.Z)
                    local predictedPos = targetPos + (flatVelocity * predictAmount)
                    
                    aimPosition = predictedPos
                end
            end
            
            -- Guardar posicion actual para siguiente frame
            lastTargetPos = targetPos
            
            -- Apuntar camara a la posicion (actual o predicha)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
        else
            targetLock = false
            lockedPlayer = nil
            lockButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
            lockButton.Text = "LOCK"
            lastTargetPos = nil
            smoothedVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

print("Mobile Camera Lock + Predict cargado OK")
