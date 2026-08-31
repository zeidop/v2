local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

if not localPlayer or not mouse then return end

local playerGui = localPlayer:FindFirstChild("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 15)
if not playerGui then return end

-- CONFIG
local config = {
    targetLock = false,
    lockedPlayer = nil,
    buttonSize = 50,
    dragLocked = false,
    buttonVisible = false,
    maxCenterDistance = 0,
    showCenterDot = true
}

local CAMERA_LOCK_NAME = "TLC_Mobile"

-- LIMPIEZA
local old = playerGui:FindFirstChild("TLC_Mobile_GUI")
if old then old:Destroy() end
pcall(function() RunService:UnbindFromRenderStep(CAMERA_LOCK_NAME) end)

-- SCREEN GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TLC_Mobile_GUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = playerGui

-- PUNTO CENTRAL
local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.new(0, 8, 0, 8)
centerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
centerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
centerDot.BackgroundTransparency = 0.2
centerDot.BorderSizePixel = 0
centerDot.InputTransparent = true
centerDot.Visible = config.showCenterDot
centerDot.Parent = screenGui

-- MENU FRAME
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 210, 0, 270)
menu.Position = UDim2.new(0.02, 0, 0.25, 0)
menu.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
menu.BorderSizePixel = 0
menu.Active = true
menu.Visible = true
menu.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menu

-- TITULO + MINIMIZAR
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -36, 0, 28)
title.Position = UDim2.new(0, 8, 0, 4)
title.BackgroundTransparency = 1
title.Text = "Camera Lock Centro"
title.TextColor3 = Color3.fromRGB(130, 180, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = menu

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -30, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = menu

-- STATUS
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 20)
statusLabel.Position = UDim2.new(0, 8, 0, 34)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Lock: OFF | Nadie"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = menu

-- BOTONES DEL MENU
local function createMenuButton(name, text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -16, 0, 30)
    btn.Position = UDim2.new(0, 8, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = menu
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn
    return btn
end

local genBtn = createMenuButton("GenBtn", "Generar boton flotante", 58, Color3.fromRGB(50, 150, 80))
local blockBtn = createMenuButton("BlockBtn", "Arrastre: LIBRE", 92, Color3.fromRGB(130, 100, 40))
local centerBtn = createMenuButton("CenterBtn", "Punto central: ON", 126, Color3.fromRGB(50, 120, 160))

-- SIZE CONTROLS
local sizeLbl = Instance.new("TextLabel")
sizeLbl.Size = UDim2.new(1, -16, 0, 18)
sizeLbl.Position = UDim2.new(0, 8, 0, 160)
sizeLbl.BackgroundTransparency = 1
sizeLbl.Text = "Tamano boton:"
sizeLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
sizeLbl.TextSize = 11
sizeLbl.Font = Enum.Font.Gotham
sizeLbl.TextXAlignment = Enum.TextXAlignment.Left
sizeLbl.Parent = menu

local szMinus = Instance.new("TextButton")
szMinus.Size = UDim2.new(0, 40, 0, 28)
szMinus.Position = UDim2.new(0, 8, 0, 180)
szMinus.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
szMinus.Text = "-5"
szMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
szMinus.TextSize = 12
szMinus.Font = Enum.Font.GothamBold
szMinus.BorderSizePixel = 0
szMinus.Parent = menu

local szVal = Instance.new("TextLabel")
szVal.Size = UDim2.new(0, 50, 0, 28)
szVal.Position = UDim2.new(0, 56, 0, 180)
szVal.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
szVal.Text = "50px"
szVal.TextColor3 = Color3.fromRGB(255, 255, 120)
szVal.TextSize = 12
szVal.Font = Enum.Font.GothamBold
szVal.BorderSizePixel = 0
szVal.Parent = menu

local szPlus = Instance.new("TextButton")
szPlus.Size = UDim2.new(0, 40, 0, 28)
szPlus.Position = UDim2.new(0, 114, 0, 180)
szPlus.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
szPlus.Text = "+5"
szPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
szPlus.TextSize = 12
szPlus.Font = Enum.Font.GothamBold
szPlus.BorderSizePixel = 0
szPlus.Parent = menu

-- INFO
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -16, 0, 40)
info.Position = UDim2.new(0, 8, 0, 214)
info.BackgroundTransparency = 1
info.Text = "C = lock/unlock\nBoton flotante = toggle lock"
info.TextColor3 = Color3.fromRGB(110, 110, 120)
info.TextSize = 10
info.Font = Enum.Font.Gotham
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.TextWrapped = true
info.Parent = menu

-- FLOAT BUTTON
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, config.buttonSize, 0, config.buttonSize)
floatBtn.Position = UDim2.new(0.8, 0, 0.4, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
floatBtn.Text = "LOCK"
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.TextSize = 12
floatBtn.Font = Enum.Font.GothamBold
floatBtn.BorderSizePixel = 0
floatBtn.Visible = false
floatBtn.Active = true
floatBtn.Parent = screenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = floatBtn

-- RESTORE BUTTON
local restoreBtn = Instance.new("TextButton")
restoreBtn.Size = UDim2.new(0, 32, 0, 32)
restoreBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
restoreBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
restoreBtn.Text = "CL"
restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreBtn.TextSize = 11
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.BorderSizePixel = 0
restoreBtn.Visible = false
restoreBtn.Active = true
restoreBtn.Parent = screenGui

-- ARRASTRE TACTIL SIMPLIFICADO
local function makeDraggable(obj, canDragFn)
    local dragging = false
    local startTouchPos = nil
    local startPos = nil

    obj.InputBegan:Connect(function(input)
        if canDragFn and not canDragFn() then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startTouchPos = input.Position
            startPos = obj.Position
        end
    end)

    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            startTouchPos = nil
        end
    end)

    obj.InputChanged:Connect(function(input)
        if not dragging then return end
        if canDragFn and not canDragFn() then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startTouchPos
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(menu, function() return true end)
makeDraggable(restoreBtn, function() return true end)
makeDraggable(floatBtn, function() return not config.dragLocked end)

-- FUNCIONES CORE
local function getCamera()
    return workspace.CurrentCamera
end

local function isAlive(plr)
    if not plr then return false, nil end
    local char = plr.Character
    if not char then return false, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return false, nil end
    return true, root
end

local function getClosestToCenter()
    local cam = getCamera()
    if not cam then return nil end
    local vp = cam.ViewportSize
    if not vp or vp.X <= 0 then return nil end
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local best, bestDist = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local alive, root = isAlive(plr)
            if alive then
                local offset = root.Position - cam.CFrame.Position
                if offset:Dot(cam.CFrame.LookVector) > 0 then
                    local sp = cam:WorldToViewportPoint(root.Position)
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    local ok = config.maxCenterDistance <= 0 or d <= config.maxCenterDistance
                    if ok and d < bestDist then
                        bestDist = d
                        best = plr
                    end
                end
            end
        end
    end
    return best
end

-- VISUALES
local function updateVisuals()
    local lt = config.targetLock and "ON" or "OFF"
    local tn = config.lockedPlayer and config.lockedPlayer.Name or "Nadie"
    statusLabel.Text = "Lock: " .. lt .. " | " .. tn
    statusLabel.TextColor3 = config.targetLock and Color3.fromRGB(110, 255, 130) or Color3.fromRGB(255, 120, 120)

    szVal.Text = tostring(config.buttonSize) .. "px"

    blockBtn.Text = config.dragLocked and "Arrastre: BLOQUEADO" or "Arrastre: LIBRE"
    blockBtn.BackgroundColor3 = config.dragLocked and Color3.fromRGB(170, 50, 50) or Color3.fromRGB(130, 100, 40)

    genBtn.Text = config.buttonVisible and "Destruir boton" or "Generar boton"
    genBtn.BackgroundColor3 = config.buttonVisible and Color3.fromRGB(170, 60, 60) or Color3.fromRGB(50, 150, 80)

    centerBtn.Text = config.showCenterDot and "Punto central: ON" or "Punto central: OFF"
    centerBtn.BackgroundColor3 = config.showCenterDot and Color3.fromRGB(50, 120, 160) or Color3.fromRGB(80, 80, 95)

    centerDot.Visible = config.showCenterDot

    floatBtn.Size = UDim2.new(0, config.buttonSize, 0, config.buttonSize)
    local ts = math.clamp(math.floor(config.buttonSize * 0.28), 10, 35)
    floatBtn.TextSize = ts
    floatBtn.BackgroundColor3 = config.targetLock and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(70, 130, 220)
end

-- CAMERA LOCK
local function stopLock()
    pcall(function() RunService:UnbindFromRenderStep(CAMERA_LOCK_NAME) end)
end

local function doCameraLock()
    if not config.targetLock or not config.lockedPlayer then return end
    local cam = getCamera()
    if not cam then return end
    local alive, root = isAlive(config.lockedPlayer)
    if not alive then
        config.targetLock = false
        config.lockedPlayer = nil
        mouse.TargetFilter = nil
        stopLock()
        updateVisuals()
        return
    end
    cam.CFrame = CFrame.new(cam.CFrame.Position, root.Position)
end

local function startLock()
    stopLock()
    RunService:BindToRenderStep(CAMERA_LOCK_NAME, Enum.RenderPriority.Camera.Value + 1, doCameraLock)
end

local function setLock(state)
    if state then
        local la = isAlive(localPlayer)
        if not la then
            config.targetLock = false
            config.lockedPlayer = nil
            mouse.TargetFilter = nil
            stopLock()
            updateVisuals()
            return
        end
        local best = getClosestToCenter()
        if best then
            local ta, tr = isAlive(best)
            if ta then
                config.targetLock = true
                config.lockedPlayer = best
                mouse.TargetFilter = tr
                startLock()
            else
                config.targetLock = false
                config.lockedPlayer = nil
                mouse.TargetFilter = nil
                stopLock()
            end
        else
            config.targetLock = false
            config.lockedPlayer = nil
            mouse.TargetFilter = nil
            stopLock()
        end
    else
        config.targetLock = false
        config.lockedPlayer = nil
        mouse.TargetFilter = nil
        stopLock()
    end
    updateVisuals()
end

-- EVENTOS
minBtn.MouseButton1Click:Connect(function()
    menu.Visible = false
    restoreBtn.Visible = true
    restoreBtn.Position = menu.Position
end)

restoreBtn.MouseButton1Click:Connect(function()
    restoreBtn.Visible = false
    menu.Visible = true
    menu.Position = restoreBtn.Position
end)

genBtn.MouseButton1Click:Connect(function()
    config.buttonVisible = not config.buttonVisible
    floatBtn.Visible = config.buttonVisible
    if config.buttonVisible then floatBtn.Position = UDim2.new(0.8, 0, 0.4, 0) end
    updateVisuals()
end)

szMinus.MouseButton1Click:Connect(function()
    config.buttonSize = math.max(20, config.buttonSize - 5)
    updateVisuals()
end)

szPlus.MouseButton1Click:Connect(function()
    config.buttonSize = math.min(130, config.buttonSize + 5)
    updateVisuals()
end)

blockBtn.MouseButton1Click:Connect(function()
    config.dragLocked = not config.dragLocked
    updateVisuals()
end)

centerBtn.MouseButton1Click:Connect(function()
    config.showCenterDot = not config.showCenterDot
    updateVisuals()
end)

floatBtn.MouseButton1Click:Connect(function()
    setLock(not config.targetLock)
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.C then
        setLock(not config.targetLock)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if config.lockedPlayer == p then setLock(false) end
end)

localPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if config.targetLock then setLock(false) end
end)

updateVisuals()
print("[TLC] Camera Lock Centro Mobile cargado OK")
