-- Anti-Stun Quinto Golpe (Solo Knockdown)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)
if not playerGui then return end

-- ==================== CONFIG ====================
local settings = {
    enabled = true,
    recoveryTime = 0.2, -- Tiempo antes de levantarse (0.1 a 0.5)
    minimized = false
}

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KnockdownAnti_GUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 160)
frame.Position = UDim2.new(0.02, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 80, 80)
stroke.Thickness = 1.5
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -35, 0, 30)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "⚡ Anti 5to Golpe"
title.TextColor3 = Color3.fromRGB(255, 150, 150)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -28, 0, 7)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
minBtn.Text = "_"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = frame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 20)
statusLabel.Position = UDim2.new(0, 5, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Estado: Activo | Levantarse: 0.2s"
statusLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -10, 0, 35)
toggleBtn.Position = UDim2.new(0, 5, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
toggleBtn.Text = "ANTI-KNOCKDOWN: ON"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, -10, 0, 20)
timeLabel.Position = UDim2.new(0, 5, 0, 100)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "Tiempo de recuperación:"
timeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
timeLabel.TextSize = 11
timeLabel.Font = Enum.Font.Gotham
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Parent = frame

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 40, 0, 30)
minusBtn.Position = UDim2.new(0, 5, 0, 123)
minusBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
minusBtn.Text = "-0.1"
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.TextSize = 12
minusBtn.Font = Enum.Font.GothamBold
minusBtn.BorderSizePixel = 0
minusBtn.Parent = frame

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 6)
minusCorner.Parent = minusBtn

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 40, 0, 30)
plusBtn.Position = UDim2.new(0, 55, 0, 123)
plusBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
plusBtn.Text = "+0.1"
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.TextSize = 12
plusBtn.Font = Enum.Font.GothamBold
plusBtn.BorderSizePixel = 0
plusBtn.Parent = frame

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 6)
plusCorner.Parent = plusBtn

local timeValue = Instance.new("TextLabel")
timeValue.Size = UDim2.new(0, 40, 0, 30)
timeValue.Position = UDim2.new(0, 105, 0, 123)
timeValue.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
timeValue.Text = "0.2s"
timeValue.TextColor3 = Color3.fromRGB(255, 255, 100)
timeValue.TextSize = 14
timeValue.Font = Enum.Font.GothamBold
timeValue.BorderSizePixel = 0
timeValue.Parent = frame

local timeValueCorner = Instance.new("UICorner")
timeValueCorner.CornerRadius = UDim.new(0, 6)
timeValueCorner.Parent = timeValue

-- Botón flotante
local miniBtnFloat = Instance.new("TextButton")
miniBtnFloat.Size = UDim2.new(0, 40, 0, 40)
miniBtnFloat.Position = UDim2.new(0.02, 0, 0.4, 0)
miniBtnFloat.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
miniBtnFloat.Text = "5G"
miniBtnFloat.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtnFloat.TextSize = 12
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

-- Arrastre
local function makeDraggable(gui)
    local dragging, dragStart, startPos = false, nil, nil
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

-- ==================== LÓGICA ESPECÍFICA ====================
-- SOLO detectar cuando caes al suelo y levantarte rápido

local function setupKnockdownDetection(char)
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Conectar al cambio de estado del Humanoid
    humanoid.StateChanged:Connect(function(oldState, newState)
        if not settings.enabled then return end
        
        -- Detectar cuando cae al suelo (FallingDown o Physics después de un golpe)
        if newState == Enum.HumanoidStateType.FallingDown or 
           newState == Enum.HumanoidStateType.Physics then
            
            -- Esperar el tiempo configurado antes de levantarse
            task.delay(settings.recoveryTime, function()
                if humanoid and humanoid.Parent then
                    pcall(function()
                        -- Forzar el estado de levantarse
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        task.wait(0.03)
                        -- Asegurar que vuelve a correr
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end)
                end
            end)
        end
    end)
    
    -- También detectar animaciones específicas de knockdown
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            if not settings.enabled then return end
            
            local animName = track.Animation and track.Animation.Name:lower() or ""
            -- Buscar animaciones de knockdown/lanzamiento
            if string.find(animName, "knockdown") or string.find(animName, "launch") or 
               string.find(animName, "throw") or string.find(animName, "fall") or
               string.find(animName, "combo") and string.find(animName, "5") then
                
                -- Acelerar la animación de caída
                task.delay(0.01, function()
                    if track and track.IsPlaying then
                        pcall(function()
                            -- Hacer la animación más rápida
                            track:AdjustSpeed(1 + (settings.recoveryTime * 2))
                        end)
                    end
                end)
            end
        end)
    end
end

-- Aplicar al spawn del personaje
player.CharacterAdded:Connect(function(char)
    task.wait(1)
    setupKnockdownDetection(char)
end)

if player.Character then
    setupKnockdownDetection(player.Character)
end

-- ==================== EVENTOS DE GUI ====================
local function updateVisuals()
    if settings.enabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
        toggleBtn.Text = "ANTI-KNOCKDOWN: ON"
        statusLabel.Text = string.format("Estado: Activo | Levantarse: %.1fs", settings.recoveryTime)
        statusLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 60)
        toggleBtn.Text = "ANTI-KNOCKDOWN: OFF"
        statusLabel.Text = "Estado: Inactivo"
        statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
    
    timeValue.Text = string.format("%.1fs", settings.recoveryTime)
end

toggleBtn.MouseButton1Click:Connect(function()
    settings.enabled = not settings.enabled
    updateVisuals()
end)

minusBtn.MouseButton1Click:Connect(function()
    settings.recoveryTime = math.max(0.1, settings.recoveryTime - 0.1)
    settings.recoveryTime = math.floor(settings.recoveryTime * 10 + 0.5) / 10
    updateVisuals()
end)

plusBtn.MouseButton1Click:Connect(function()
    settings.recoveryTime = math.min(0.5, settings.recoveryTime + 0.1)
    settings.recoveryTime = math.floor(settings.recoveryTime * 10 + 0.5) / 10
    updateVisuals()
end)

minBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    miniBtnFloat.Visible = true
    miniBtnFloat.Position = frame.Position
    settings.minimized = true
end)

miniBtnFloat.MouseButton1Click:Connect(function()
    miniBtnFloat.Visible = false
    frame.Visible = true
    frame.Position = miniBtnFloat.Position
    settings.minimized = false
end)

updateVisuals()
print("✅ Anti-Knockdown v1.0 - Solo reduce tiempo en el suelo")
print("⚙️ Configuración: ", settings.recoveryTime, "s antes de levantarse")
print("🎯 Este script NO afecta tus acciones normales")
