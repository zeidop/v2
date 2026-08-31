local success, err = pcall(function()
    local UIS = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        warn("[TargetLock] LocalPlayer no existe")
        return
    end

    local mouse = localPlayer:GetMouse()
    if not mouse then
        warn("[TargetLock] Mouse no disponible")
        return
    end

    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        playerGui = localPlayer:WaitForChild("PlayerGui", 10)
    end

    if not playerGui then
        warn("[TargetLock] No se pudo encontrar PlayerGui")
        return
    end

    local config = {
        targetLock = false,
        lockedPlayer = nil,
        buttonSize = 50,
        dragLocked = false,
        buttonVisible = false,
        maxCenterDistance = 0,
        showCenterDot = true
    }

    local CAMERA_LOCK_NAME = "TargetLockCamera_Center"

    pcall(function()
        RunService:UnbindFromRenderStep(CAMERA_LOCK_NAME)
    end)

    local function getCamera()
        return workspace.CurrentCamera
    end

    local function isAlive(plr)
        if not plr then
            return false, nil, nil
        end

        local char = plr.Character
        if not char then
            return false, nil, nil
        end

        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        if not root or not hum or hum.Health <= 0 then
            return false, nil, nil
        end

        return true, root, hum
    end

    local function getClosestPlayerToScreenCenter()
        local camera = getCamera()
        if not camera then
            return nil, math.huge
        end

        local viewportSize = camera.ViewportSize
        if not viewportSize or viewportSize.X <= 0 or viewportSize.Y <= 0 then
            return nil, math.huge
        end

        local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

        local bestPlayer = nil
        local bestDistance = math.huge

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer then
                local alive, root = isAlive(plr)

                if alive and root then
                    local offset = root.Position - camera.CFrame.Position
                    local inFront = offset:Dot(camera.CFrame.LookVector) > 0

                    if inFront then
                        local screenPos = camera:WorldToViewportPoint(root.Position)
                        local screen2D = Vector2.new(screenPos.X, screenPos.Y)
                        local dist = (screen2D - screenCenter).Magnitude

                        local allowed = config.maxCenterDistance <= 0 or dist <= config.maxCenterDistance

                        if allowed and dist < bestDistance then
                            bestDistance = dist
                            bestPlayer = plr
                        end
                    end
                end
            end
        end

        return bestPlayer, bestDistance
    end

    local oldGui = playerGui:FindFirstChild("TargetLockCenterMenu")
    if oldGui then
        oldGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TargetLockCenterMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    screenGui.Parent = playerGui

    local centerDot = Instance.new("Frame")
    centerDot.Size = UDim2.new(0, 6, 0, 6)
    centerDot.Position = UDim2.new(0.5, -3, 0.5, -3)
    centerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    centerDot.BackgroundTransparency = 0.15
    centerDot.BorderSizePixel = 0
    centerDot.InputTransparent = true
    centerDot.Visible = config.showCenterDot
    centerDot.Parent = screenGui

    local centerDotCorner = Instance.new("UICorner")
    centerDotCorner.CornerRadius = UDim.new(1, 0)
    centerDotCorner.Parent = centerDot

    local centerDotStroke = Instance.new("UIStroke")
    centerDotStroke.Color = Color3.fromRGB(0, 0, 0)
    centerDotStroke.Thickness = 1
    centerDotStroke.Transparency = 0.35
    centerDotStroke.Parent = centerDot

    local menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(0, 230, 0, 290)
    menuFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
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

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -42, 0, 30)
    titleLabel.Position = UDim2.new(0, 8, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Camera Lock Centro"
    titleLabel.TextColor3 = Color3.fromRGB(130, 180, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = menuFrame

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

    local lockStatusLabel = Instance.new("TextLabel")
    lockStatusLabel.Size = UDim2.new(1, -16, 0, 22)
    lockStatusLabel.Position = UDim2.new(0, 8, 0, 38)
    lockStatusLabel.BackgroundTransparency = 1
    lockStatusLabel.Text = "Lock: OFF | Objetivo: Nadie"
    lockStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    lockStatusLabel.TextSize = 11
    lockStatusLabel.Font = Enum.Font.Gotham
    lockStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    lockStatusLabel.Parent = menuFrame

    local genBtn = Instance.new("TextButton")
    genBtn.Size = UDim2.new(1, -16, 0, 32)
    genBtn.Position = UDim2.new(0, 8, 0, 65)
    genBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
    genBtn.Text = "Generar boton flotante"
    genBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    genBtn.TextSize = 12
    genBtn.Font = Enum.Font.GothamBold
    genBtn.BorderSizePixel = 0
    genBtn.Parent = menuFrame

    local genCorner = Instance.new("UICorner")
    genCorner.CornerRadius = UDim.new(0, 8)
    genCorner.Parent = genBtn

    local sizeLabel = Instance.new("TextLabel")
    sizeLabel.Size = UDim2.new(1, -16, 0, 20)
    sizeLabel.Position = UDim2.new(0, 8, 0, 102)
    sizeLabel.BackgroundTransparency = 1
    sizeLabel.Text = "Tamano del boton:"
    sizeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    sizeLabel.TextSize = 11
    sizeLabel.Font = Enum.Font.Gotham
    sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    sizeLabel.Parent = menuFrame

    local sizeMinus = Instance.new("TextButton")
    sizeMinus.Size = UDim2.new(0, 45, 0, 30)
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
    sizeValue.Size = UDim2.new(0, 60, 0, 30)
    sizeValue.Position = UDim2.new(0, 63, 0, 125)
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
    sizePlus.Size = UDim2.new(0, 45, 0, 30)
    sizePlus.Position = UDim2.new(0, 133, 0, 125)
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

    local blockBtn = Instance.new("TextButton")
    blockBtn.Size = UDim2.new(1, -16, 0, 32)
    blockBtn.Position = UDim2.new(0, 8, 0, 162)
    blockBtn.BackgroundColor3 = Color3.fromRGB(130, 100, 40)
    blockBtn.Text = "Arrastre boton: LIBRE"
    blockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    blockBtn.TextSize = 11
    blockBtn.Font = Enum.Font.GothamBold
    blockBtn.BorderSizePixel = 0
    blockBtn.Parent = menuFrame

    local blockCorner = Instance.new("UICorner")
    blockCorner.CornerRadius = UDim.new(0, 8)
    blockCorner.Parent = blockBtn

    local centerBtn = Instance.new("TextButton")
    centerBtn.Size = UDim2.new(1, -16, 0, 32)
    centerBtn.Position = UDim2.new(0, 8, 0, 198)
    centerBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 160)
    centerBtn.Text = "Punto central: ON"
    centerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    centerBtn.TextSize = 11
    centerBtn.Font = Enum.Font.GothamBold
    centerBtn.BorderSizePixel = 0
    centerBtn.Parent = menuFrame

    local centerBtnCorner = Instance.new("UICorner")
    centerBtnCorner.CornerRadius = UDim.new(0, 8)
    centerBtnCorner.Parent = centerBtn

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -16, 0, 45)
    infoLabel.Position = UDim2.new(0, 8, 0, 234)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "C = activar/desactivar lock\nBoton flotante tambien activa el lock\nSelecciona jugador en centro de pantalla"
    infoLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
    infoLabel.TextSize = 10
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextWrapped = true
    infoLabel.Parent = menuFrame

    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.new(0, config.buttonSize, 0, config.buttonSize)
    floatBtn.Position = UDim2.new(0.82, 0, 0.42, 0)
    floatBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
    floatBtn.Text = "LOCK"
    floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.TextSize = 14
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.BorderSizePixel = 0
    floatBtn.Visible = false
    floatBtn.Active = true
    floatBtn.Parent = screenGui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatBtn

    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Color3.fromRGB(0, 0, 0)
    floatStroke.Thickness = 2
    floatStroke.Transparency = 0.35
    floatStroke.Parent = floatBtn

    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(0, 34, 0, 34)
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

    local restoreCorner = Instance.new("UICorner")
    restoreCorner.CornerRadius = UDim.new(0, 8)
    restoreCorner.Parent = restoreBtn

local function makeDraggable(guiObject, canDragCheck)
        local dragging = false
        local dragStart = nil
        local startPos = nil

        guiObject.InputBegan:Connect(function(input)
            if canDragCheck and not canDragCheck() then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then

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
            if not dragging then
                return
            end

            if canDragCheck and not canDragCheck() then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then

                local delta = input.Position - dragStart

                guiObject.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    makeDraggable(menuFrame, function()
        return true
    end)

    makeDraggable(restoreBtn, function()
        return true
    end)

    makeDraggable(floatBtn, function()
        return not config.dragLocked
    end)

    local function updateMenuVisuals()
        local lockText = config.targetLock and "ON" or "OFF"
        local targetText = config.lockedPlayer and config.lockedPlayer.Name or "Nadie"

        lockStatusLabel.Text = "Lock: " .. lockText .. " | Objetivo: " .. targetText

        if config.targetLock then
            lockStatusLabel.TextColor3 = Color3.fromRGB(110, 255, 130)
        else
            lockStatusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
        end

        sizeValue.Text = tostring(config.buttonSize) .. "px"

        if config.dragLocked then
            blockBtn.Text = "Arrastre boton: BLOQUEADO"
            blockBtn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
        else
            blockBtn.Text = "Arrastre boton: LIBRE"
            blockBtn.BackgroundColor3 = Color3.fromRGB(130, 100, 40)
        end

        if config.buttonVisible then
            genBtn.Text = "Destruir boton flotante"
            genBtn.BackgroundColor3 = Color3.fromRGB(170, 60, 60)
        else
            genBtn.Text = "Generar boton flotante"
            genBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
        end

        if config.showCenterDot then
            centerBtn.Text = "Punto central: ON"
            centerBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 160)
        else
            centerBtn.Text = "Punto central: OFF"
            centerBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
        end

        centerDot.Visible = config.showCenterDot
    end

    local function updateFloatBtnAppearance()
        floatBtn.Size = UDim2.new(0, config.buttonSize, 0, config.buttonSize)

        local textSize = math.floor(config.buttonSize * 0.28)
        if textSize < 10 then
            textSize = 10
        end
        if textSize > 35 then
            textSize = 35
        end

        floatBtn.TextSize = textSize

        if config.targetLock then
            floatBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        else
            floatBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
        end
    end

    local function refreshVisuals()
        updateMenuVisuals()
        updateFloatBtnAppearance()
    end

    local setTargetLock

    local function stopCameraLock()
        pcall(function()
            RunService:UnbindFromRenderStep(CAMERA_LOCK_NAME)
        end)
    end

    local function updateCameraLock()
        if not config.targetLock or not config.lockedPlayer then
            return
        end

        local camera = getCamera()
        if not camera then
            return
        end

        local localAlive = isAlive(localPlayer)
        if not localAlive then
            task.defer(function()
                if setTargetLock then
                    setTargetLock(false)
                end
            end)
            return
        end

        local targetAlive, targetRoot = isAlive(config.lockedPlayer)
        if not targetAlive then
            task.defer(function()
                if setTargetLock then
                    setTargetLock(false)
                end
            end)
            return
        end

        camera.CFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position)
    end

    local function startCameraLock()
        stopCameraLock()

        RunService:BindToRenderStep(
            CAMERA_LOCK_NAME,
            Enum.RenderPriority.Camera.Value + 1,
            updateCameraLock
        )
    end

    setTargetLock = function(state)
        if state then
            local localAlive = isAlive(localPlayer)
            if not localAlive then
                config.targetLock = false
                config.lockedPlayer = nil
                mouse.TargetFilter = nil
                stopCameraLock()
                refreshVisuals()
                return
            end

            local bestPlayer = getClosestPlayerToScreenCenter()

            if bestPlayer then
                local targetAlive, targetRoot = isAlive(bestPlayer)

                if targetAlive then
                    config.targetLock = true
                    config.lockedPlayer = bestPlayer
                    mouse.TargetFilter = targetRoot
                    startCameraLock()
                else
                    config.targetLock = false
                    config.lockedPlayer = nil
                    mouse.TargetFilter = nil
                    stopCameraLock()
                end
            else
                config.targetLock = false
                config.lockedPlayer = nil
                mouse.TargetFilter = nil
                stopCameraLock()
            end
        else
            config.targetLock = false
            config.lockedPlayer = nil
            mouse.TargetFilter = nil
            stopCameraLock()
        end

        refreshVisuals()
    end

    minBtn.MouseButton1Click:Connect(function()
        menuFrame.Visible = false
        restoreBtn.Visible = true
        restoreBtn.Position = menuFrame.Position
    end)

    restoreBtn.MouseButton1Click:Connect(function()
        restoreBtn.Visible = false
        menuFrame.Visible = true
        menuFrame.Position = restoreBtn.Position
    end)

    genBtn.MouseButton1Click:Connect(function()
        config.buttonVisible = not config.buttonVisible
        floatBtn.Visible = config.buttonVisible

        if config.buttonVisible then
            floatBtn.Position = UDim2.new(0.82, 0, 0.42, 0)
        end

        refreshVisuals()
    end)

    sizeMinus.MouseButton1Click:Connect(function()
        config.buttonSize = math.max(20, config.buttonSize - 5)
        refreshVisuals()
    end)

    sizePlus.MouseButton1Click:Connect(function()
        config.buttonSize = math.min(130, config.buttonSize + 5)
        refreshVisuals()
    end)

    blockBtn.MouseButton1Click:Connect(function()
        config.dragLocked = not config.dragLocked
        refreshVisuals()
    end)

    centerBtn.MouseButton1Click:Connect(function()
        config.showCenterDot = not config.showCenterDot
        refreshVisuals()
    end)

    floatBtn.MouseButton1Click:Connect(function()
        setTargetLock(not config.targetLock)
    end)

    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if input.KeyCode == Enum.KeyCode.C then
            setTargetLock(not config.targetLock)
        end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if config.lockedPlayer == plr then
            setTargetLock(false)
        end
    end)

    localPlayer.CharacterAdded:Connect(function()
        task.wait(0.25)
        if config.targetLock then
            setTargetLock(false)
        end
    end)

    refreshVisuals()
    print("Camera Lock Centro cargado correctamente")
end)

if not success then
    warn("[TargetLock] ERROR AL CARGAR: " .. tostring(err))
end		
