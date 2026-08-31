-- Anti-Stun + Botón Arrastrable v1.0
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")

-- ==================== CONFIG ====================
local enabled = false
local jumping = true
local power = 100

-- Configuración del botón arrastrable
local btnVisible = false
local btnSize = 60
local btnLocked = false

player.CharacterAdded:Connect(function(c)
    character = c
    humanoid = c:WaitForChild("Humanoid")
    root = c:WaitForChild("HumanoidRootPart", 3) or c:FindFirstChild("Torso")
    jumping = true
end)

-- ==================== FUNCIÓN PRINCIPAL ====================
local function jump()
    if not humanoid or not root or not jumping then
        return
    end

    jumping = false

    humanoid.PlatformStand = true
    root.Velocity = Vector3.zero

    task.wait()

    root.Velocity = Vector3.new(0, power / 2, 0)
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

    task.wait(0.05)

    humanoid.PlatformStand = false

    task.wait(1.5)
    jumping = true
end

-- ==================== CONTROLES DE TECLADO ====================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.X then
        enabled = not enabled
        jumping = true
        print(enabled and "Anti stun enabled" or "Anti stun disabled")
    elseif input.KeyCode == Enum.KeyCode.Z then
        enabled = false
        jumping = true
        print("Anti stun disabled")
    elseif input.KeyCode == Enum.KeyCode.Space and enabled then
        jump()
    end
end)

-- ==================== ANTI-STUN AUTOMÁTICO ====================
RunService.Heartbeat:Connect(function()
    if not enabled or not humanoid or not jumping then
        return
    end

    local state = humanoid:GetState()

    if state == Enum.HumanoidStateType.FallingDown
        or state == Enum.HumanoidStateType.GettingUp
        or state == Enum.HumanoidStateType.Stunned then

        jump()
    end
end)

-- ==================== GUI ====================
local playerGui = player:WaitForChild("PlayerGui", 5)
if not playerGui then return end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiStunGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- ===== MENÚ PRINCIPAL =====
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MainMenu"
menuFrame.Size = UDim2.new(0, 200, 0, 280)
menuFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
menuFrame.BorderSizePixel = 0
menuFrame.Active = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(100, 60, 200)
menuStroke.Thickness = 1.5
menuStroke.Parent = menuFrame

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -40, 0, 30)
titleLabel.Position = UDim2.new(0, 8, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ Anti-Stun"
titleLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = menuFrame

-- Botón minimizar "-"
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinimizeBtn"
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -32, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = menuFrame

local minBtnCorner = Instance.new("UICorner")
minBtnCorner.CornerRadius = UDim.new(0, 6)
minBtnCorner.Parent = minBtn

-- Estado
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -16, 0, 22)
statusLabel.Position = UDim2.new(0, 8, 0, 38)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Estado: Desactivado"
statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = menuFrame

-- Toggle Anti-Stun
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(1, -16, 0, 32)
toggleBtn.Position = UDim2.new(0, 8, 0, 62)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
toggleBtn.Text = "ANTI-STUN: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 13
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = menuFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Separador
local sep1 = Instance.new("Frame")
sep1.Name = "Separator1"
sep1.Size = UDim2.new(1, -16, 0, 1)
sep1.Position = UDim2.new(0, 8, 0, 100)
sep1.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
sep1.BorderSizePixel = 0
sep1.Parent = menuFrame

-- Sección Botón Arrastrable
local btnSectionLabel = Instance.new("TextLabel")
btnSectionLabel.Name = "BtnSectionLabel"
btnSectionLabel.Size = UDim2.new(1, -16, 0, 20)
btnSectionLabel.Position = UDim2.new(0, 8, 0, 105)
btnSectionLabel.BackgroundTransparency = 1
btnSectionLabel.Text = "🎮 Botón de Salto"
btnSectionLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
btnSectionLabel.TextSize = 12
btnSectionLabel.Font = Enum.Font.GothamBold
btnSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
btnSectionLabel.Parent = menuFrame

-- Toggle Botón Visible
local btnToggle = Instance.new("TextButton")
btnToggle.Name = "BtnToggle"
btnToggle.Size = UDim2.new(1, -16, 0, 30)
btnToggle.Position = UDim2.new(0, 8, 0, 128)
btnToggle.BackgroundColor3 = Color3.fromRGB(50, 130, 50)
btnToggle.Text = "MOSTRAR BOTÓN"
btnToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
btnToggle.TextSize = 12
btnToggle.Font = Enum.Font.GothamBold
btnToggle.BorderSizePixel = 0
btnToggle.Parent = menuFrame

local btnToggleCorner = Instance.new("UICorner")
btnToggleCorner.CornerRadius = UDim.new(0, 6)
btnToggleCorner.Parent = btnToggle

-- Tamaño del botón
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Name = "SizeLabel"
sizeLabel.Size = UDim2.new(1, -16, 0, 20)
sizeLabel.Position = UDim2.new(0, 8, 0, 163)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "Tamaño: 60px"
sizeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
sizeLabel.TextSize = 11
sizeLabel.Font = Enum.Font.Gotham
sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
sizeLabel.Parent = menuFrame

-- Botón menos tamaño
local sizeMinusBtn = Instance.new("TextButton")
sizeMinusBtn.Name = "SizeMinus"
sizeMinusBtn.Size = UDim2.new(0, 35, 0, 28)
sizeMinusBtn.Position = UDim2.new(0, 8, 0, 185)
sizeMinusBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
sizeMinusBtn.Text = "-"
sizeMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeMinusBtn.TextSize = 16
sizeMinusBtn.Font = Enum.Font.GothamBold
sizeMinusBtn.BorderSizePixel = 0
sizeMinusBtn.Parent = menuFrame

local sizeMinusCorner = Instance.new("UICorner")
sizeMinusCorner.CornerRadius = UDim.new(0, 6)
sizeMinusCorner.Parent = sizeMinusBtn

-- Botón más tamaño
local sizePlusBtn = Instance.new("TextButton")
sizePlusBtn.Name = "SizePlus"
sizePlusBtn.Size = UDim2.new(0, 35, 0, 28)
sizePlusBtn.Position = UDim2.new(0, 50, 0, 185)
sizePlusBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
sizePlusBtn.Text = "+"
sizePlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sizePlusBtn.TextSize = 16
sizePlusBtn.Font = Enum.Font.GothamBold
sizePlusBtn.BorderSizePixel = 0
sizePlusBtn.Parent = menuFrame

local sizePlusCorner = Instance.new("UICorner")
sizePlusCorner.CornerRadius = UDim.new(0, 6)
sizePlusCorner.Parent = sizePlusBtn

-- Valor del tamaño
local sizeValueLabel = Instance.new("TextLabel")
sizeValueLabel.Name = "SizeValue"
sizeValueLabel.Size = UDim2.new(0, 50, 0, 28)
sizeValueLabel.Position = UDim2.new(0, 95, 0, 185)
sizeValueLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
sizeValueLabel.Text = "60"
sizeValueLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
sizeValueLabel.TextSize = 14
sizeValueLabel.Font = Enum.Font.GothamBold
sizeValueLabel.BorderSizePixel = 0
sizeValueLabel.Parent = menuFrame

local sizeValueCorner = Instance.new("UICorner")
sizeValueCorner.CornerRadius = UDim.new(0, 6)
sizeValueCorner.Parent = sizeValueLabel

-- Toggle Block (bloquear arrastre)
local blockToggle = Instance.new("TextButton")
blockToggle.Name = "BlockToggle"
blockToggle.Size = UDim2.new(1, -16, 0, 30)
blockToggle.Position = UDim2.new(0, 8, 0, 218)
blockToggle.BackgroundColor3 = Color3.fromRGB(180, 100, 40)
blockToggle.Text = "🔓 ARRASTRE: LIBRE"
blockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
blockToggle.TextSize = 11
blockToggle.Font = Enum.Font.GothamBold
blockToggle.BorderSizePixel = 0
blockToggle.Parent = menuFrame

local blockCorner = Instance.new("UICorner")
blockCorner.CornerRadius = UDim.new(0, 6)
blockCorner.Parent = blockToggle

-- ===== BOTÓN ARRASTRABLE =====
local dragBtn = Instance.new("TextButton")
dragBtn.Name = "DraggableJumpBtn"
dragBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
dragBtn.Position = UDim2.new(0.5, -btnSize/2, 0.7, -btnSize/2)
dragBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
dragBtn.Text = "⬆️"
dragBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dragBtn.TextSize = 24
dragBtn.Font = Enum.Font.GothamBold
dragBtn.BorderSizePixel = 0
dragBtn.Visible = btnVisible
dragBtn.Parent = screenGui

local dragBtnCorner = Instance.new("UICorner")
dragBtnCorner.CornerRadius = UDim.new(1, 0)
dragBtnCorner.Parent = dragBtn

local dragBtnStroke = Instance.new("UIStroke")
dragBtnStroke.Color = Color3.fromRGB(255, 255, 255)
dragBtnStroke.Thickness = 2
dragBtnStroke.Transparency = 0.3
dragBtnStroke.Parent = dragBtn

-- ===== FUNCIÓN PARA ACTUALIZAR TAMAÑO =====
local function updateBtnSize()
    dragBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
    dragBtn.TextSize = math.floor(btnSize * 0.4)
    sizeLabel.Text = string.format("Tamaño: %dpx", btnSize)
    sizeValueLabel.Text = tostring(btnSize)
end

-- ===== FUNCIÓN PARA ACTUALIZAR BLOQUEO =====
local function updateBlockState()
    if btnLocked then
        blockToggle.Text = "🔒 ARRASTRE: BLOQUEADO"
        blockToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    else
        blockToggle.Text = "🔓 ARRASTRE: LIBRE"
        blockToggle.BackgroundColor3 = Color3.fromRGB(180, 100, 40)
    end
end

-- ===== FUNCIÓN PARA ACTUALIZAR ESTADO =====
local function updateStatus()
    if enabled then
        toggleBtn.Text = "ANTI-STUN: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 70)
        statusLabel.Text = "Estado: Activado"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        toggleBtn.Text = "ANTI-STUN: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        statusLabel.Text = "Estado: Desactivado"
        statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
end

-- ===== FUNCIÓN PARA ACTUALIZAR VISIBILIDAD DEL BOTÓN =====
local function updateBtnVisibility()
    if btnVisible then
        dragBtn.Visible = true
        btnToggle.Text = "OCULTAR BOTÓN"
        btnToggle.BackgroundColor3 = Color3.fromRGB(180, 100, 40)
    else
        dragBtn.Visible = false
        btnToggle.Text = "MOSTRAR BOTÓN"
        btnToggle.BackgroundColor3 = Color3.fromRGB(50, 130, 50)
    end
end

-- ==================== EVENTOS DEL MENÚ ====================

-- Minimizar
minBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    
    -- Crear botón flotante para reabrir
    local reopenBtn = Instance.new("TextButton")
    reopenBtn.Name = "ReopenBtn"
    reopenBtn.Size = UDim2.new(0, 45, 0, 45)
    reopenBtn.Position = menuFrame.Position
    reopenBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
    reopenBtn.Text = "⚡"
    reopenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    reopenBtn.TextSize = 20
    reopenBtn.Font = Enum.Font.GothamBold
    reopenBtn.BorderSizePixel = 0
    reopenBtn.Parent = screenGui
    
    local reopenCorner = Instance.new("UICorner")
    reopenCorner.CornerRadius = UDim.new(1, 0)
    reopenCorner.Parent = reopenBtn
    
    local reopenStroke = Instance.new("UIStroke")
    reopenStroke.Color = Color3.fromRGB(255, 255, 255)
    reopenStroke.Thickness = 2
    reopenStroke.Transparency = 0.5
    reopenStroke.Parent = reopenBtn
    
    -- Arrastre del botón flotante
    local dragging, dragStart, startPos = false, nil, nil
    reopenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = reopenBtn.Position
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
            reopenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Click para reabrir
    reopenBtn.MouseButton1Click:Connect(function()
        menuFrame.Visible = true
        menuFrame.Position = reopenBtn.Position
        reopenBtn:Destroy()
    end)
end)

-- Toggle Anti-Stun
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    jumping = true
    updateStatus()
    print(enabled and "Anti stun enabled" or "Anti stun disabled")
end)

-- Toggle Botón Visible
btnToggle.MouseButton1Click:Connect(function()
    btnVisible = not btnVisible
    updateBtnVisibility()
end)

-- Tamaño menos
sizeMinusBtn.MouseButton1Click:Connect(function()
    btnSize = math.max(30, btnSize - 10)
    updateBtnSize()
end)

-- Tamaño más
sizePlusBtn.MouseButton1Click:Connect(function()
    btnSize = math.min(120, btnSize + 10)
    updateBtnSize()
end)

-- Toggle Block
blockToggle.MouseButton1Click:Connect(function()
    btnLocked = not btnLocked
    updateBlockState()
end)

-- ==================== FUNCIÓN DEL BOTÓN ARRASTRABLE ====================
dragBtn.MouseButton1Click:Connect(function()
    if enabled then
        jump()
    end
end)

-- ==================== ARRASTRE DEL BOTÓN ====================
local draggingBtn, dragBtnStart, btnStartPos = false, nil, nil

dragBtn.InputBegan:Connect(function(input)
    if btnLocked then return end -- No arrastrar si está bloqueado
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true
        dragBtnStart = input.Position
        btnStartPos = dragBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then 
                draggingBtn = false 
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingBtn and not btnLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragBtnStart
        dragBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
    end
end)

-- ==================== INICIALIZACIÓN ====================
updateStatus()
updateBtnVisibility()
updateBtnSize()
updateBlockState()

print("✅ Anti-Stun + Botón Arrastrable cargado")
print("📋 Controles:")
print("   X = Toggle Anti-Stun")
print("   Z = Desactivar")
print("   Space = Saltar (si está activado)")
print("   Botón flotante = Saltar")
