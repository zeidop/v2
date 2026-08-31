-- Anti-Stun Rogue Demon v2.1 (Corregido)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)
if not playerGui then return end

-- ==================== CONFIG ====================
local settings = {
    enabled = true,
    stunReduction = 0.2,
    useAnimationHook = true,
    useValueHook = true,
    useStateHook = false, -- DESACTIVADO POR DEFECTO - puede causar problemas
    useNamecallHook = false, -- DESACTIVADO POR DEFECTO - rompe acciones
    minimized = false
}

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiStun_GUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 280)
frame.Position = UDim2.new(0.02, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 40, 150)
stroke.Thickness = 1.5
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -35, 0, 30)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "⚡ Anti-Stun Rogue"
title.TextColor3 = Color3.fromRGB(180, 120, 255)
title.TextSize = 14
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
statusLabel.Text = "Estado: Activo"
statusLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
toggleBtn.Text = "ANTI-STUN: ON"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local reductionLabel = Instance.new("TextLabel")
reductionLabel.Size = UDim2.new(1, -10, 0, 20)
reductionLabel.Position = UDim2.new(0, 5, 0, 95)
reductionLabel.BackgroundTransparency = 1
reductionLabel.Text = "Reducción: -0.2s"
reductionLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
reductionLabel.TextSize = 12
reductionLabel.Font = Enum.Font.Gotham
reductionLabel.TextXAlignment = Enum.TextXAlignment.Left
reductionLabel.Parent = frame

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 40, 0, 30)
minusBtn.Position = UDim2.new(0, 5, 0, 120)
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
plusBtn.Position = UDim2.new(0, 55, 0, 120)
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

-- Toggles de métodos
local animToggle = Instance.new("TextButton")
animToggle.Size = UDim2.new(1, -10, 0, 25)
animToggle.Position = UDim2.new(0, 5, 0, 155)
animToggle.BackgroundColor3 = Color3.fromRGB(50, 130, 50)
animToggle.Text = "Anim Hook: ON"
animToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
animToggle.TextSize = 11
animToggle.Font = Enum.Font.GothamBold
animToggle.BorderSizePixel = 0
animToggle.Parent = frame

local animCorner = Instance.new("UICorner")
animCorner.CornerRadius = UDim.new(0, 6)
animCorner.Parent = animToggle

local valueToggle = Instance.new("TextButton")
valueToggle.Size = UDim2.new(1, -10, 0, 25)
valueToggle.Position = UDim2.new(0, 5, 0, 183)
valueToggle.BackgroundColor3 = Color3.fromRGB(50, 130, 50)
valueToggle.Text = "Value Hook: ON"
valueToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
valueToggle.TextSize = 11
valueToggle.Font = Enum.Font.GothamBold
valueToggle.BorderSizePixel = 0
valueToggle.Parent = frame

local valueCorner = Instance.new("UICorner")
valueCorner.CornerRadius = UDim.new(0, 6)
valueCorner.Parent = valueToggle

local stateToggle = Instance.new("TextButton")
stateToggle.Size = UDim2.new(1, -10, 0, 25)
stateToggle.Position = UDim2.new(0, 5, 0, 211)
stateToggle.BackgroundColor3 = Color3.fromRGB(130, 50, 50)
stateToggle.Text = "State Hook: OFF"
stateToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
stateToggle.TextSize = 11
stateToggle.Font = Enum.Font.GothamBold
stateToggle.BorderSizePixel = 0
stateToggle.Parent = frame

local stateCorner = Instance.new("UICorner")
stateCorner.CornerRadius = UDim.new(0, 6)
stateCorner.Parent = stateToggle

local namecallToggle = Instance.new("TextButton")
namecallToggle.Size = UDim2.new(1, -10, 0, 25)
namecallToggle.Position = UDim2.new(0, 5, 0, 239)
namecallToggle.BackgroundColor3 = Color3.fromRGB(130, 50, 50)
namecallToggle.Text = "Namecall: OFF ⚠️"
namecallToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
namecallToggle.TextSize = 11
namecallToggle.Font = Enum.Font.GothamBold
namecallToggle.BorderSizePixel = 0
namecallToggle.Parent = frame

local namecallCorner = Instance.new("UICorner")
namecallCorner.CornerRadius = UDim.new(0, 6)
namecallCorner.Parent = namecallToggle

-- Botón flotante cuando está minimizado
local miniBtnFloat = Instance.new("TextButton")
miniBtnFloat.Size = UDim2.new(0, 40, 0, 40)
miniBtnFloat.Position = UDim2.new(0.02, 0, 0.3, 0)
miniBtnFloat.BackgroundColor3 = Color3.fromRGB(80, 40, 150)
miniBtnFloat.Text = "AS"
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

-- ==================== LÓGICA CORREGIDA ====================

-- Método 1: Interrupción de animaciones (SEGURO)
local function interruptStunAnimations(char)
    if not settings.enabled or not settings.useAnimationHook then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end
    
    animator.AnimationPlayed:Connect(function(track)
        if not settings.enabled or not settings.useAnimationHook then return end
        
        local animName = track.Animation and track.Animation.Name:lower() or ""
        -- Solo animaciones ESPECÍFICAS de stun
        local stunKeywords = {"stunned", "knocked", "ragdoll", "falldown", "recoil"}
        local isStunAnim = false
        
        for _, keyword in ipairs(stunKeywords) do
            if string.find(animName, keyword) then
                isStunAnim = true
                break
            end
        end
        
        if isStunAnim then
            local speedMultiplier = 1 + (settings.stunReduction * 3)
            task.delay(0.01, function()
                if track and track.IsPlaying then
                    pcall(function()
                        track:AdjustSpeed(speedMultiplier)
                    end)
                end
            end)
        end
    end)
end

-- Método 2: Modificación de valores (CORREGIDO - solo afecta al personaje, no cooldowns)
local function modifyStunValues(char)
    if not settings.enabled or not settings.useValueHook then return end
    
    char.DescendantAdded:Connect(function(descendant)
        if not settings.enabled or not settings.useValueHook then return end
        
        -- Verificar que el descendiente pertenece a NUESTRO personaje
        if not descendant:IsDescendantOf(char) then return end
        
        -- NO modificar cooldowns de habilidades (generalmente están en carpetas separadas)
        local parent = descendant.Parent
        if parent and (parent.Name == "Cooldowns" or parent.Name == "Skills" or 
                       parent.Name == "Abilities" or string.find(parent.Name:lower(), "skill")) then
            return -- Ignorar estos valores
        end
        
        if descendant:IsA("NumberValue") or descendant:IsA("IntValue") or descendant:IsA("DoubleConstrainedValue") then
            local name = descendant.Name:lower()
            -- Solo valores EXACTAMENTE relacionados con stun del personaje
            local stunKeywords = {"stun", "stunntime", "stunduration", "knockdownduration"}
            local isStunValue = false
            
            for _, keyword in ipairs(stunKeywords) do
                if string.find(name, keyword) then
                    isStunValue = true
                    break
                end
            end
            
            if isStunValue then
                task.delay(0.01, function()
                    if descendant and descendant.Parent then
                        pcall(function()
                            if descendant.Value > 0 then
                                local newValue = math.max(0, descendant.Value - settings.stunReduction)
                                descendant.Value = newValue
                            end
                        end)
                    end
                end)
            end
        end
    end)
end

-- Método 3: Forzado de estados (OPCIONAL - puede causar problemas)
local function forceStateChanges(char)
    if not settings.enabled or not settings.useStateHook then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid.StateChanged:Connect(function(oldState, newState)
        if not settings.enabled or not settings.useStateHook then return end
        
        if newState == Enum.HumanoidStateType.FallingDown or 
           newState == Enum.HumanoidStateType.Ragdoll then
            
            local delayTime = math.max(0.05, settings.stunReduction * 0.5)
            task.delay(delayTime, function()
                if humanoid and humanoid.Parent then
                    pcall(function()
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end)
                end
            end)
        end
    end)
end

-- Método 4: Hook de namecall (PELIGROSO - rompe acciones)
local function setupNamecallHook()
    if not settings.enabled or not settings.useNamecallHook then return end
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if not settings.enabled or not settings.useNamecallHook then
            return oldNamecall(self, ...)
        end
        
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" and self:IsA("RemoteEvent") then
            local remoteName = self.Name:lower()
            -- Solo interceptar RemoteEvents ESPECÍFICOS de stun recibido
            if string.find(remoteName, "stunned") or string.find(remoteName, "knockdown") or 
               string.find(remoteName, "playerstun") then
                
                for i, arg in ipairs(args) do
                    if type(arg) == "number" and arg > 0 and arg < 5 then
                        args[i] = math.max(0, arg - settings.stunReduction)
                    end
                end
            end
        end
        
        return oldNamecall(self, unpack(args))
    end))
end

-- Aplicar al personaje
local function applyAntiStun(char)
    if not char then return end
    
    task.wait(0.5)
    
    if settings.enabled then
        if settings.useAnimationHook then
            interruptStunAnimations(char)
        end
        if settings.useValueHook then
            modifyStunValues(char)
        end
        if settings.useStateHook then
            forceStateChanges(char)
        end
        if settings.useNamecallHook then
            pcall(function()
                setupNamecallHook()
            end)
        end
    end
end

player.CharacterAdded:Connect(function(char)
    task.wait(1)
    applyAntiStun(char)
end)

if player.Character then
    applyAntiStun(player.Character)
end

-- ==================== EVENTOS DE GUI ====================
local function updateVisuals()
    if settings.enabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
        toggleBtn.Text = "ANTI-STUN: ON"
        statusLabel.Text = "Estado: Activo"
        statusLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 60)
        toggleBtn.Text = "ANTI-STUN: OFF"
        statusLabel.Text = "Estado: Inactivo"
        statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
    
    reductionLabel.Text = string.format("Reducción: -%.1fs", settings.stunReduction)
    
    animToggle.Text = string.format("Anim Hook: %s", settings.useAnimationHook and "ON" or "OFF")
    animToggle.BackgroundColor3 = settings.useAnimationHook and Color3.fromRGB(50, 130, 50) or Color3.fromRGB(130, 50, 50)
    
    valueToggle.Text = string.format("Value Hook: %s", settings.useValueHook and "ON" or "OFF")
    valueToggle.BackgroundColor3 = settings.useValueHook and Color3.fromRGB(50, 130, 50) or Color3.fromRGB(130, 50, 50)
    
    stateToggle.Text = string.format("State Hook: %s", settings.useStateHook and "ON" or "OFF")
    stateToggle.BackgroundColor3 = settings.useStateHook and Color3.fromRGB(50, 130, 50) or Color3.fromRGB(130, 50, 50)
    
    namecallToggle.Text = string.format("Namecall: %s ⚠️", settings.useNamecallHook and "ON" or "OFF")
    namecallToggle.BackgroundColor3 = settings.useNamecallHook and Color3.fromRGB(180, 100, 40) or Color3.fromRGB(130, 50, 50)
end

toggleBtn.MouseButton1Click:Connect(function()
    settings.enabled = not settings.enabled
    if settings.enabled and player.Character then
        applyAntiStun(player.Character)
    end
    updateVisuals()
end)

minusBtn.MouseButton1Click:Connect(function()
    settings.stunReduction = math.max(0.1, settings.stunReduction - 0.1)
    settings.stunReduction = math.floor(settings.stunReduction * 10 + 0.5) / 10
    updateVisuals()
end)

plusBtn.MouseButton1Click:Connect(function()
    settings.stunReduction = math.min(0.5, settings.stunReduction + 0.1)
    settings.stunReduction = math.floor(settings.stunReduction * 10 + 0.5) / 10
    updateVisuals()
end)

animToggle.MouseButton1Click:Connect(function()
    settings.useAnimationHook = not settings.useAnimationHook
    updateVisuals()
end)

valueToggle.MouseButton1Click:Connect(function()
    settings.useValueHook = not settings.useValueHook
    updateVisuals()
end)

stateToggle.MouseButton1Click:Connect(function()
    settings.useStateHook = not settings.useStateHook
    updateVisuals()
end)

namecallToggle.MouseButton1Click:Connect(function()
    settings.useNamecallHook = not settings.useNamecallHook
    if settings.useNamecallHook then
        pcall(function()
            setupNamecallHook()
        end)
    end
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
print("✅ Anti-Stun v2.1 - Anim y Value Hook activos (seguros)")
print("⚠️ State y Namecall desactivados por defecto (pueden causar problemas)")
