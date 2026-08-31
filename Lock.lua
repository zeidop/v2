-- Target Lock + Custom Button Manager
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- ==================== CONFIGURACIÓN ====================
local config = {
    targetLock = false,
    lockedPlayer = nil,
    buttonSize = 50,        -- Tamaño inicial del botón flotante
    dragLocked = false,     -- Modo block: bloquea/desbloquea arrastre
    menuOpen = true,        -- Estado del menú principal
    buttonVisible = false   -- Si el botón flotante está generado
}

-- ==================== LÓGICA DE TARGET LOCK ====================
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local torso = player.Character:FindFirstChild("HumanoidRootPart")
            local screenPos = workspace.CurrentCamera:WorldToScreenPoint(torso.Position)
            local mousePos = Vector2.new(mouse.X, mouse.Y)
            local distance = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude

            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

local function lockOntoPlayer()
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character then
        local torso = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
        if torso then
            mouse.TargetFilter = torso
            config.lockedPlayer = closestPlayer
            config.targetLock = true
        end
    end
end

local function updateLock()
    if config.lockedPlayer and config.lockedPlayer.Character then
        local torso = config.lockedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if torso then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, torso.Position)
        end
    end
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.C then
        if not config.targetLock then
            lockOntoPlayer()
        else
            mouse.TargetFilter = nil
            config.lockedPlayer = nil
            config.targetLock = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if config.targetLock then
        updateLock()
    end
end)

-- ==================== INTERFAZ GRÁFICA ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TargetLock_Manager"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = localPlayer:WaitForChild("PlayerGui", 5)

-- Menú Principal
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 220, 0, 260)
menuFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
menuFrame.BorderSizePixel = 0
menuFrame.Active = true
menuFrame.Visible = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(70, 130, 220)
menuStroke.Thickness = 1.5
menuStroke.Parent = menuFrame

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 30)
titleLabel.Position = UDim2.new(0, 8, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎯 Target Lock Manager"
titleLabel.TextColor3 = Color3.fromRGB(130, 180, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = menuFrame

-- Botón Minimizar (-)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -32, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 22
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = menuFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

-- Estado del Lock
local lockStatusLabel = Instance.new("TextLabel")
lockStatusLabel.Size = UDim2.new(1, -16, 0, 22)
lockStatusLabel.Position = UDim2.new(0, 8, 0, 38)
lockStatusLabel.BackgroundTransparency = 1
lockStatusLabel.Text = "Lock: OFF | Tecla: C"
lockStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
lockStatusLabel.TextSize = 11
lockStatusLabel.Font = Enum.Font.Gotham
lockStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
lockStatusLabel.Parent = menuFrame

-- Generar / Destruir Botón Flotante
local genBtn = Instance.new("TextButton")
genBtn.Size = UDim2.new(1, -16, 0, 32)
genBtn.Position = UDim2.new(0, 8, 0, 65)
genBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
genBtn.Text = "Generar Botón Flotante"
genBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
genBtn.TextSize = 12
genBtn.Font = Enum.Font.GothamBold
genBtn.BorderSizePixel = 0
genBtn.Parent = menuFrame

local genCorner = Instance.new("UICorner")
genCorner.CornerRadius = UDim.new(0, 8)
genCorner.Parent = genBtn

-- Ajuste de Tamaño del Botón
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(1, -16, 0, 20)
sizeLabel.Position = UDim2.new(0, 8, 0, 102)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "Tamaño del botón:"
sizeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
sizeLabel.TextSize = 11
sizeLabel.Font = Enum.Font.Gotham
sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
sizeLabel.Parent = menuFrame

local sizeMinus = Instance.new("TextButton")
sizeMinus.Size = UDim2.new(0, 40, 0, 30)
sizeMinus.Position = UDim2.new(0, 8, 0, 125)
sizeMinus.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
sizeMinus.Text = "-5"
sizeMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeMinus.TextSize = 13
sizeMinus.Font = Enum.Font.GothamBold
sizeMinus.BorderSizePixel = 0
sizeMinus.Parent = menuFrame

local sizeMinusCorner = Instance.new("UICorner")
sizeMinusCorner.CornerRadius = UDim.new(0, 6)
sizeMinusCorner.Parent = sizeMinus

local sizeValue = Instance.new("TextLabel")
sizeValue.Size = UDim2.new(0, 50, 0, 30)
sizeValue.Position = UDim2.new(0, 58, 0, 125)
sizeValue.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
sizeValue.Text = "50px"
sizeValue.TextColor3 = Color3.fromRGB(255, 255, 120)
sizeValue.TextSize = 13
sizeValue.Font = Enum.Font.GothamBold
sizeValue.BorderSizePixel = 0
sizeValue.Parent = menuFrame

local sizeValueCorner = Instance.new("UICorner")
sizeValueCorner.CornerRadius = UDim.new(0, 6)
sizeValueCorner.Parent = sizeValue

local sizePlus = Instance.new("TextButton")
sizePlus.Size = UDim2.new(0, 40, 0, 30)
sizePlus.Position = UDim2.new(0, 118, 0, 125)
sizePlus.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
sizePlus.Text = "+5"
sizePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
sizePlus.TextSize = 13
sizePlus.Font = Enum.Font.GothamBold
sizePlus.BorderSizePixel = 0
sizePlus.Parent = menuFrame

local sizePlusCorner = Instance.new("UICorner")
sizePlusCorner.CornerRadius = UDim.new(0, 6)
sizePlusCorner.Parent = sizePlus

-- Modo Block (Bloquear Arrastre)
local blockBtn = Instance.new("TextButton")
blockBtn.Size = UDim2.new(1, -16, 0, 32)
blockBtn.Position = UDim2.new(0, 8, 0, 162)
blockBtn.BackgroundColor3 = Color3.fromRGB(140, 100, 40)
blockBtn.Text = "🔓 Arrastre: DESBLOQUEADO"
blockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
blockBtn.TextSize = 11
blockBtn.Font = Enum.Font.GothamBold
blockBtn.BorderSizePixel = 0
blockBtn.Parent = menuFrame

local blockCorner = Instance.new("UICorner")
blockCorner.CornerRadius = UDim.new(0, 8)
blockCorner.Parent = blockBtn

-- Info adicional
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -16, 0, 40)
infoLabel.Position = UDim2.new(0, 8, 0, 200)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "C = Lock/Unlock\nBotón flotante ejecuta Lock"
infoLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
infoLabel.TextSize = 10
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextWrapped = true
infoLabel.Parent = menuFrame

-- Botón Flotante (se genera dinámicamente)
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, config.buttonSize, 0, config.buttonSize)
floatBtn.Position = UDim2.new(0.85, 0, 0.4, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
floatBtn.Text = "🎯"
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.TextSize = 18
floatBtn.Font = Enum.Font.GothamBold
floatBtn.BorderSizePixel = 0
floatBtn.Visible = false
floatBtn.Parent = screenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = floatBtn

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Color3.fromRGB(0, 0, 0)
floatStroke.Thickness = 2
floatStroke.Transparency = 0.4
floatStroke.Parent = floatBtn

-- Mini botón para restaurar menú cuando está minimizado
local restoreBtn = Instance.new("TextButton")
restoreBtn.Size = UDim2.new(0, 32, 0, 32)
restoreBtn.Position = UDim2.new(0.02, 0, 0.3, 0)
restoreBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
restoreBtn.Text = "TL"
restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreBtn.TextSize = 11
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.BorderSizePixel = 0
restoreBtn.Visible = false
restoreBtn.Parent = screenGui

local restoreCorner = Instance.new("UICorner")
restoreCorner.CornerRadius = UDim.new(0, 8)
restoreCorner.Parent = restoreBtn

-- ==================== SISTEMA DE ARRASTRE ====================
local function makeDraggable(guiObject)
    local dragging, dragStart, startPos = false, nil, nil

    guiObject.InputBegan:Connect(function(input)
        if config.dragLocked then return end
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

    UIS.InputChanged:Connect(function(input)
        if config.dragLocked then return end
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(menuFrame)
makeDraggable(floatBtn)
makeDraggable(restoreBtn)

-- ==================== FUNCIONES DE ACTUALIZACIÓN VISUAL ====================
local function updateMenuVisuals()
    lockStatusLabel.Text = string.format("Lock: %s | Tecla: C", config.targetLock and "ON 🟢" or "OFF 🔴")
    lockStatusLabel.TextColor3 = config.targetLock and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 120, 120)

    sizeValue.Text = string.format("%dpx", config.buttonSize)

    if config.dragLocked then
        blockBtn.Text = "🔒 Arrastre: BLOQUEADO"
        blockBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    else
        blockBtn.Text = "🔓 Arrastre: DESBLOQUEADO"
        blockBtn.BackgroundColor3 = Color3.fromRGB(140, 100, 40)
    end

    if config.buttonVisible then
        genBtn.Text = "❌ Destruir Botón Flotante"
        genBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    else
        genBtn.Text = "✅ Generar Botón Flotante"
        genBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
    end
end

local function updateFloatBtnAppearance()
    floatBtn.Size = UDim2.new(0, config.buttonSize, 0, config.buttonSize)
    floatBtn.TextSize = math.max(10, config.buttonSize * 0.36)
    floatBtn.BackgroundColor3 = config.targetLock
        and Color3.fromRGB(50, 200, 80)
        or Color3.fromRGB(70, 130, 220)
end

-- ==================== EVENTOS DEL MENÚ ====================

-- Minimizar / Restaurar
minBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    restoreBtn.Visible = true
    restoreBtn.Position = menuFrame.Position
    config.menuOpen = false
end)

restoreBtn.MouseButton1Click:Connect(function()
    restoreBtn.Visible = false
    menuFrame.Visible = true
    menuFrame.Position = restoreBtn.Position
    config.menuOpen = true
end)

-- Generar / Destruir botón flotante
genBtn.MouseButton1Click:Connect(function()
    config.buttonVisible = not config.buttonVisible
    floatBtn.Visible = config.buttonVisible
    if config.buttonVisible then
        floatBtn.Position = UDim2.new(0.85, 0, 0.4, 0)
        updateFloatBtnAppearance()
    end
    updateMenuVisuals()
end)

-- Ajuste de tamaño
sizeMinus.MouseButton1Click:Connect(function()
    config.buttonSize = math.max(20, config.buttonSize - 5)
    updateFloatBtnAppearance()
    updateMenuVisuals()
end)

sizePlus.MouseButton1Click:Connect(function()
    config.buttonSize = math.min(120, config.buttonSize + 5)
    updateFloatBtnAppearance()
    updateMenuVisuals()
end)

-- Modo Block
blockBtn.MouseButton1Click:Connect(function()
    config.dragLocked = not config.dragLocked
    updateMenuVisuals()
end)

-- Botón flotante ejecuta toggle lock
floatBtn.MouseButton1Click:Connect(function()
    if not config.targetLock then
        lockOntoPlayer()
    else
        mouse.TargetFilter = nil
        config.lockedPlayer = nil
        config.targetLock = false
    end
    updateFloatBtnAppearance()
    updateMenuVisuals()
end)

-- Actualizar visuals cuando cambia el lock por tecla C
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.C then
        task.defer(function()
            updateFloatBtnAppearance()
            updateMenuVisuals()
        end)
    end
end)

-- Inicializar
updateMenuVisuals()
updateFloatBtnAppearance()
print("✅ Target Lock Manager cargado")
print("📌 C = Lock/Unlock | Menú con '-' para minimizar")
print("🔘 Genera botón flotante arrastrable con tamaño ajustable")
print("🔒 Modo Block para fijar posición del botón")
