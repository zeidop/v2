local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", 10)
if not playerGui then return end
local Camera = workspace.CurrentCamera

-- ============================================
-- CONFIGURACIÓN GUARDADA
-- ============================================
local SAVE_FILE = "zeidop_hub_config.json"
local config = {
    buttonSize = 55, buttonVisible = true, isDraggable = true,
    predictEnabled = false, predictAmount = 0.090,
    useDistance3D = true, smoothMode = false, smoothAmount = 0.35,
    menuTransparency = 0, lockPart = "torso", lockKeyName = "L",
    jumpPower = 50, dashForce = 60, jumpBtnSize = 62, dashBtnSize = 62,
    dashMultiplier = 1.5, dashEnabled = true, instantDash = false,
    antiStun = false, dashAssist = true,
    lockBtnXScale = 0.75, lockBtnXOffset = 0,
    lockBtnYScale = 0.65, lockBtnYOffset = 0
}

local function loadConfig()
    pcall(function()
        if readfile and isfile and isfile(SAVE_FILE) then
            local d = HttpService:JSONDecode(readfile(SAVE_FILE))
            if type(d) == "table" then
                for k, v in pairs(d) do
                    if config[k] ~= nil then config[k] = v end
                end
            end
        end
    end)
end

local function saveConfig()
    pcall(function()
        if writefile then
            writefile(SAVE_FILE, HttpService:JSONEncode(config))
        end
    end)
end

loadConfig()

-- Variables de estado
local targetLock = false
local lockedPlayer = nil
local whitelist = {}
local blacklist = {}
local listeningForKey = false
local lockKey = Enum.KeyCode[config.lockKeyName] or Enum.KeyCode.L
local jumping = true
local stunLocked = false
local instantDashLastVel = Vector3.new(0, 0, 0)
local smoothedVelocity = Vector3.new(0, 0, 0)
local lastTargetPos = nil
local PREDICT_TIME = config.predictAmount
local CAMERA_LOCK_NAME = "ZeidopCameraLock"
local LOGO_ID = 97991220544918
local LOAD_SOUND_ID = 0

-- ============================================
-- LIMPIEZA Y PANTALLA DE CARGA
-- ============================================
pcall(function() RunService:UnbindFromRenderStep(CAMERA_LOCK_NAME) end)
local oldGui = playerGui:FindFirstChild("ZeidopHub")
if oldGui then oldGui:Destroy() end
local oldLoad = playerGui:FindFirstChild("ZeidopLoad")
if oldLoad then oldLoad:Destroy() end

local loadGui = Instance.new("ScreenGui")
loadGui.Name = "ZeidopLoad"
loadGui.ResetOnSpawn = false
loadGui.IgnoreGuiInset = true
loadGui.DisplayOrder = 999999
loadGui.Parent = playerGui

local loadBg = Instance.new("Frame")
loadBg.Size = UDim2.new(1, 0, 1, 0)
loadBg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
loadBg.BorderSizePixel = 0
loadBg.Active = false
loadBg.Parent = loadGui

local loadLogo = Instance.new("ImageLabel")
loadLogo.Size = UDim2.new(0, 90, 0, 90)
loadLogo.Position = UDim2.new(0.5, -45, 0.10, 0)
loadLogo.BackgroundTransparency = 1
loadLogo.Image = LOGO_ID > 0 and ("rbxassetid://" .. LOGO_ID) or ""
loadLogo.Parent = loadBg
Instance.new("UICorner", loadLogo).CornerRadius = UDim.new(1, 0)
local loadLogoStroke = Instance.new("UIStroke")
loadLogoStroke.Color = Color3.fromRGB(160, 120, 255)
loadLogoStroke.Thickness = 3
loadLogoStroke.Parent = loadLogo

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(0.9, 0, 0, 45)
loadTitle.Position = UDim2.new(0.05, 0, 0.36, 0)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "zeidop"
loadTitle.TextColor3 = Color3.fromRGB(160, 120, 255)
loadTitle.TextSize = 38
loadTitle.Font = Enum.Font.GothamBlack
loadTitle.Parent = loadBg

local loadSubtitle = Instance.new("TextLabel")
loadSubtitle.Size = UDim2.new(0.9, 0, 0, 30)
loadSubtitle.Position = UDim2.new(0.05, 0, 0.50, 0)
loadSubtitle.BackgroundTransparency = 1
loadSubtitle.Text = "ohh estas usando un script de zeidop"
loadSubtitle.TextColor3 = Color3.fromRGB(220, 220, 230)
loadSubtitle.TextSize = 16
loadSubtitle.Font = Enum.Font.GothamBold
loadSubtitle.Parent = loadBg

local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0.5, 0, 0, 4)
loadBarBg.Position = UDim2.new(0.25, 0, 0.60, 0)
loadBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
loadBarBg.BorderSizePixel = 0
loadBarBg.Parent = loadGui
Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(1, 0)

local loadBar = Instance.new("Frame")
loadBar.Size = UDim2.new(0, 0, 1, 0)
loadBar.BackgroundColor3 = Color3.fromRGB(160, 120, 255)
loadBar.BorderSizePixel = 0
loadBar.Parent = loadBarBg
Instance.new("UICorner", loadBar).CornerRadius = UDim.new(1, 0)

if LOAD_SOUND_ID > 0 then
    local loadSound = Instance.new("Sound")
    loadSound.SoundId = "rbxassetid://" .. LOAD_SOUND_ID
    loadSound.Volume = 1
    loadSound.Parent = loadGui
    loadSound:Play()
end

spawn(function()
    local startTime = tick()
    while tick() - startTime < 2 do
        local progress = (tick() - startTime) / 2
        if progress > 1 then progress = 1 end
        loadBar.Size = UDim2.new(progress, 0, 1, 0)
        wait(0.03)
    end
end)

-- ============================================
-- GUI PRINCIPAL
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZeidopHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 210, 0, 290)
menuFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
menuFrame.BackgroundTransparency = config.menuTransparency
menuFrame.BorderSizePixel = 0
menuFrame.Active = true
menuFrame.Visible = false
menuFrame.Parent = screenGui
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 12)

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(60, 60, 75)
menuStroke.Thickness = 1.5
menuStroke.Parent = menuFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = menuFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLogo = Instance.new("ImageLabel")
titleLogo.Size = UDim2.new(0, 22, 0, 22)
titleLogo.Position = UDim2.new(0, 6, 0, 4)
titleLogo.BackgroundTransparency = 1
titleLogo.Image = LOGO_ID > 0 and ("rbxassetid://" .. LOGO_ID) or ""
titleLogo.Parent = titleBar
Instance.new("UICorner", titleLogo).CornerRadius = UDim.new(1, 0)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 0, 30)
titleLabel.Position = UDim2.new(0, 32, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "zeidop hub"
titleLabel.TextColor3 = Color3.fromRGB(160, 120, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -28, 0, 3)
minBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 0, 30)
accentLine.BackgroundColor3 = Color3.fromRGB(160, 120, 255)
accentLine.BorderSizePixel = 0
accentLine.Parent = menuFrame

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 26)
tabBar.Position = UDim2.new(0, 8, 0, 36)
tabBar.BackgroundTransparency = 1
tabBar.Parent = menuFrame

local tabW = 46
local tabGap = 3

local function createTab(name, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, tabW, 1, 0)
    btn.Position = UDim2.new(0, (tabW + tabGap) * (index - 1), 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local tabLock = createTab("LOCK", 1)
local tabNoStun = createTab("STUN", 2)
local tabDash = createTab("DASH", 3)
local tabList = createTab("LISTA", 4)

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -16, 1, -70)
contentArea.Position = UDim2.new(0, 8, 0, 66)
contentArea.BackgroundTransparency = 1
contentArea.Parent = menuFrame

-- ============================================
-- PÁGINA LOCK
-- ============================================
local lockPage = Instance.new("Frame")
lockPage.Size = UDim2.new(1, 0, 1, 0)
lockPage.BackgroundTransparency = 1
lockPage.Visible = true
lockPage.Parent = contentArea

local function halfBtn(text, y, isRight, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, -2, 0, 24)
    b.Position = UDim2.new(isRight and 0.5 or 0, isRight and 2 or 0, 0, y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = lockPage
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local function smallLabel(text, y, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, 0, 0, 16)
    l.Position = UDim2.new(0, 0, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Color3.fromRGB(200, 200, 210)
    l.TextSize = 10
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = lockPage
    return l
end

local function smallBtn(text, x, y, w, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w, 0, 22)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = color or Color3.fromRGB(45, 45, 60)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = lockPage
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local showBtn = halfBtn("Boton: Visible", 0, false, Color3.fromRGB(45, 160, 70))
local dragBtn = halfBtn("Arrastrable: ON", 0, true, Color3.fromRGB(45, 160, 70))
local sizeLabel = smallLabel("Tamano: " .. config.buttonSize, 30)
local sizeMinus = smallBtn("-", 110, 28, 28)
local sizePlus = smallBtn("+", 142, 28, 28)

local predictLabel = smallLabel(string.format("Predict: %.3fs", config.predictAmount), 58, Color3.fromRGB(255, 220, 130))
local predictMinus = smallBtn("-0.001", 80, 56, 28)
local predictPlus = smallBtn("+0.001", 112, 56, 28)
local predictToggle = smallBtn(config.predictEnabled and "ON" or "OFF", 144, 56, 28, config.predictEnabled and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50))

local dist3DBtn = halfBtn("Direct 3D: " .. (config.useDistance3D and "ON" or "OFF"), 86, false, config.useDistance3D and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50))
local transBtn = halfBtn("Transp: " .. math.floor(config.menuTransparency * 100) .. "%", 86, true, Color3.fromRGB(45, 45, 60))

local aimSep = Instance.new("TextLabel")
aimSep.Size = UDim2.new(1, 0, 0, 14)
aimSep.Position = UDim2.new(0, 0, 0, 114)
aimSep.BackgroundTransparency = 1
aimSep.Text = "--- APUNTADO / TECLA ---"
aimSep.TextColor3 = Color3.fromRGB(160, 120, 255)
aimSep.TextSize = 9
aimSep.Font = Enum.Font.GothamBold
aimSep.Parent = lockPage

local partBtn = halfBtn("Parte: " .. (config.lockPart == "head" and "Cabeza" or "Torso"), 132, false, config.lockPart == "head" and Color3.fromRGB(160, 50, 50) or Color3.fromRGB(70, 130, 220))
local keyBtn = halfBtn("Tecla: " .. lockKey.Name, 132, true, Color3.fromRGB(70, 130, 220))

-- ============================================
-- PÁGINA STUN
-- ============================================
local noStunPage = Instance.new("Frame")
noStunPage.Size = UDim2.new(1, 0, 1, 0)
noStunPage.BackgroundTransparency = 1
noStunPage.Visible = false
noStunPage.Parent = contentArea

local function nsBtn(text, y, isRight, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, -2, 0, 22)
    b.Position = UDim2.new(isRight and 0.5 or 0, isRight and 2 or 0, 0, y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 9
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = noStunPage
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local function nsLabel(text, y, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.6, 0, 0, 14)
    l.Position = UDim2.new(0, 0, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Color3.fromRGB(200, 200, 210)
    l.TextSize = 9
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = noStunPage
    return l
end

local function nsSmallBtn(text, x, y, w, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w, 0, 20)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = color or Color3.fromRGB(45, 45, 60)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = noStunPage
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local nsToggleBtn = Instance.new("TextButton")
nsToggleBtn.Size = UDim2.new(1, 0, 0, 24)
nsToggleBtn.Position = UDim2.new(0, 0, 0, 0)
nsToggleBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
nsToggleBtn.Text = "ANTI-STUN: OFF"
nsToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nsToggleBtn.TextSize = 11
nsToggleBtn.Font = Enum.Font.GothamBold
nsToggleBtn.BorderSizePixel = 0
nsToggleBtn.Parent = noStunPage
Instance.new("UICorner", nsToggleBtn).CornerRadius = UDim.new(0, 6)

local nsJumpLabel = nsLabel("Jump Power: " .. config.jumpPower, 30)
local nsJumpMinus = nsSmallBtn("-", 75, 28, 24)
local nsJumpPlus = nsSmallBtn("+", 103, 28, 24)
local nsJumpGenBtn = nsSmallBtn("GEN", 131, 28, 32, Color3.fromRGB(80, 60, 140))

local nsDashLabel = nsLabel("Dash Force: " .. config.dashForce, 54)
local nsDashMinus = nsSmallBtn("-", 75, 52, 24)
local nsDashPlus = nsSmallBtn("+", 103, 52, 24)
local nsDashGenBtn = nsSmallBtn("GEN", 131, 52, 32, Color3.fromRGB(70, 130, 220))

local nsJumpSizeLabel = nsLabel("Jump Size: " .. config.jumpBtnSize, 78)
local nsJumpSizeMinus = nsSmallBtn("-", 75, 76, 24)
local nsJumpSizePlus = nsSmallBtn("+", 103, 76, 24)

local nsDashSizeLabel = nsLabel("Dash Size: " .. config.dashBtnSize, 102)
local nsDashSizeMinus = nsSmallBtn("-", 75, 100, 24)
local nsDashSizePlus = nsSmallBtn("+", 103, 100, 24)

local nsLockBtn = Instance.new("TextButton")
nsLockBtn.Size = UDim2.new(1, 0, 0, 22)
nsLockBtn.Position = UDim2.new(0, 0, 0, 128)
nsLockBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
nsLockBtn.Text = "LOCK FLOAT: OFF"
nsLockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nsLockBtn.TextSize = 10
nsLockBtn.Font = Enum.Font.GothamBold
nsLockBtn.BorderSizePixel = 0
nsLockBtn.Parent = noStunPage
Instance.new("UICorner", nsLockBtn).CornerRadius = UDim.new(0, 6)

local nsInfoLabel = Instance.new("TextLabel")
nsInfoLabel.Size = UDim2.new(1, 0, 0, 20)
nsInfoLabel.Position = UDim2.new(0, 0, 0, 154)
nsInfoLabel.BackgroundTransparency = 1
nsInfoLabel.Text = "Hotkeys: X=toggle Z=off Space=jump Q=dash"
nsInfoLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
nsInfoLabel.TextSize = 8
nsInfoLabel.Font = Enum.Font.Gotham
nsInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
nsInfoLabel.Parent = noStunPage

-- ============================================
-- PÁGINA DASH
-- ============================================
local dashPage = Instance.new("Frame")
dashPage.Size = UDim2.new(1, 0, 1, 0)
dashPage.BackgroundTransparency = 1
dashPage.Visible = false
dashPage.Parent = contentArea

local dashTitle = Instance.new("TextLabel")
dashTitle.Size = UDim2.new(1, -10, 0, 20)
dashTitle.Position = UDim2.new(0, 5, 0, 0)
dashTitle.BackgroundTransparency = 1
dashTitle.Text = "Dash Speed"
dashTitle.TextColor3 = Color3.fromRGB(160, 120, 255)
dashTitle.TextSize = 14
dashTitle.Font = Enum.Font.GothamBold
dashTitle.TextXAlignment = Enum.TextXAlignment.Left
dashTitle.Parent = dashPage

local dashValueLabel = Instance.new("TextLabel")
dashValueLabel.Size = UDim2.new(1, -10, 0, 18)
dashValueLabel.Position = UDim2.new(0, 5, 0, 24)
dashValueLabel.BackgroundTransparency = 1
dashValueLabel.Text = string.format("Multiplicador: %.1fx", config.dashMultiplier)
dashValueLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
dashValueLabel.TextSize = 11
dashValueLabel.Font = Enum.Font.Gotham
dashValueLabel.TextXAlignment = Enum.TextXAlignment.Left
dashValueLabel.Parent = dashPage

local dashMinusBtn = Instance.new("TextButton")
dashMinusBtn.Size = UDim2.new(0.5, -4, 0, 28)
dashMinusBtn.Position = UDim2.new(0, 0, 0, 50)
dashMinusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
dashMinusBtn.Text = "-"
dashMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dashMinusBtn.TextSize = 16
dashMinusBtn.Font = Enum.Font.GothamBold
dashMinusBtn.BorderSizePixel = 0
dashMinusBtn.Parent = dashPage
Instance.new("UICorner", dashMinusBtn).CornerRadius = UDim.new(0, 6)

local dashPlusBtn = Instance.new("TextButton")
dashPlusBtn.Size = UDim2.new(0.5, -4, 0, 28)
dashPlusBtn.Position = UDim2.new(0.5, 4, 0, 50)
dashPlusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
dashPlusBtn.Text = "+"
dashPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dashPlusBtn.TextSize = 16
dashPlusBtn.Font = Enum.Font.GothamBold
dashPlusBtn.BorderSizePixel = 0
dashPlusBtn.Parent = dashPage
Instance.new("UICorner", dashPlusBtn).CornerRadius = UDim.new(0, 6)

local dashToggleBtn = Instance.new("TextButton")
dashToggleBtn.Size = UDim2.new(1, 0, 0, 28)
dashToggleBtn.Position = UDim2.new(0, 0, 0, 86)
dashToggleBtn.BackgroundColor3 = config.dashEnabled and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
dashToggleBtn.Text = config.dashEnabled and "ACTIVADO" or "DESACTIVADO"
dashToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dashToggleBtn.TextSize = 12
dashToggleBtn.Font = Enum.Font.GothamBold
dashToggleBtn.BorderSizePixel = 0
dashToggleBtn.Parent = dashPage
Instance.new("UICorner", dashToggleBtn).CornerRadius = UDim.new(0, 6)

local instantDashBtn = Instance.new("TextButton")
instantDashBtn.Size = UDim2.new(1, 0, 0, 28)
instantDashBtn.Position = UDim2.new(0, 0, 0, 120)
instantDashBtn.BackgroundColor3 = config.instantDash and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
instantDashBtn.Text = config.instantDash and "INSTANT DASH: ON" or "INSTANT DASH: OFF"
instantDashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
instantDashBtn.TextSize = 12
instantDashBtn.Font = Enum.Font.GothamBold
instantDashBtn.BorderSizePixel = 0
instantDashBtn.Parent = dashPage
Instance.new("UICorner", instantDashBtn).CornerRadius = UDim.new(0, 6)

local dashDesc = Instance.new("TextLabel")
dashDesc.Size = UDim2.new(1, -10, 0, 50)
dashDesc.Position = UDim2.new(0, 5, 0, 152)
dashDesc.BackgroundTransparency = 1
dashDesc.Text = "Multiplica el impulso del dash. INSTANT DASH detecta el dash del juego y lo vuelve instantaneo."
dashDesc.TextColor3 = Color3.fromRGB(120, 120, 130)
dashDesc.TextSize = 10
dashDesc.Font = Enum.Font.Gotham
dashDesc.TextXAlignment = Enum.TextXAlignment.Left
dashDesc.TextWrapped = true
dashDesc.Parent = dashPage

-- ============================================
-- PÁGINA LISTA
-- ============================================
local listPage = Instance.new("Frame")
listPage.Size = UDim2.new(1, 0, 1, 0)
listPage.BackgroundTransparency = 1
listPage.Visible = false
listPage.Parent = contentArea

local function lpBtn(text, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 26)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = listPage
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local wlBtn = lpBtn("WHITELIST: 0", 0, Color3.fromRGB(45, 160, 70))
local blBtn = lpBtn("BLACKLIST: 0", 30, Color3.fromRGB(190, 45, 45))

local listHint = Instance.new("TextLabel")
listHint.Size = UDim2.new(1, 0, 0, 44)
listHint.Position = UDim2.new(0, 0, 0, 62)
listHint.BackgroundTransparency = 1
listHint.Text = "Whitelist = aliados (nunca lock)\nBlacklist = objetivos prioritarios"
listHint.TextColor3 = Color3.fromRGB(120, 120, 140)
listHint.TextSize = 8
listHint.Font = Enum.Font.Gotham
listHint.TextXAlignment = Enum.TextXAlignment.Left
listHint.TextYAlignment = Enum.TextYAlignment.Top
listHint.TextWrapped = true
listHint.Parent = listPage

-- Selector de jugadores
local pickerGui = Instance.new("Frame")
pickerGui.Name = "ZeidopPicker"
pickerGui.Size = UDim2.new(0, 190, 0, 250)
pickerGui.Position = UDim2.new(0.5, -95, 0.5, -125)
pickerGui.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
pickerGui.BorderSizePixel = 0
pickerGui.Active = true
pickerGui.Visible = false
pickerGui.ZIndex = 50
pickerGui.Parent = screenGui
Instance.new("UICorner", pickerGui).CornerRadius = UDim.new(0, 10)

local pickerStroke = Instance.new("UIStroke")
pickerStroke.Color = Color3.fromRGB(160, 120, 255)
pickerStroke.Thickness = 1.5
pickerStroke.Parent = pickerGui

local pickerTitle = Instance.new("TextLabel")
pickerTitle.Size = UDim2.new(1, -34, 0, 22)
pickerTitle.Position = UDim2.new(0, 8, 0, 4)
pickerTitle.BackgroundTransparency = 1
pickerTitle.Text = "WHITELIST"
pickerTitle.TextColor3 = Color3.fromRGB(110, 255, 130)
pickerTitle.TextSize = 11
pickerTitle.Font = Enum.Font.GothamBold
pickerTitle.TextXAlignment = Enum.TextXAlignment.Left
pickerTitle.Parent = pickerGui

local pickerClose = Instance.new("TextButton")
pickerClose.Size = UDim2.new(0, 22, 0, 22)
pickerClose.Position = UDim2.new(1, -26, 0, 4)
pickerClose.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
pickerClose.Text = "X"
pickerClose.TextColor3 = Color3.fromRGB(255, 255, 255)
pickerClose.TextSize = 12
pickerClose.Font = Enum.Font.GothamBold
pickerClose.BorderSizePixel = 0
pickerClose.Parent = pickerGui
Instance.new("UICorner", pickerClose).CornerRadius = UDim.new(0, 5)

local pickerScroll = Instance.new("ScrollingFrame")
pickerScroll.Size = UDim2.new(1, -12, 1, -34)
pickerScroll.Position = UDim2.new(0, 6, 0, 30)
pickerScroll.BackgroundTransparency = 1
pickerScroll.BorderSizePixel = 0
pickerScroll.ScrollBarThickness = 3
pickerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
pickerScroll.Parent = pickerGui

local pickerLayout = Instance.new("UIListLayout")
pickerLayout.Padding = UDim.new(0, 3)
pickerLayout.Parent = pickerScroll

local pickerMode = "white"

local function inList(list, name)
    for _, n in ipairs(list) do if n == name then return true end end
    return false
end

local function toggleInList(list, name)
    if inList(list, name) then
        for i = #list, 1, -1 do if list[i] == name then table.remove(list, i) end end
    else
        table.insert(list, name)
    end
end

local function updateListCounts()
    wlBtn.Text = "WHITELIST: " .. #whitelist
    blBtn.Text = "BLACKLIST: " .. #blacklist
end

local rebuildPicker
rebuildPicker = function()
    for _, ch in ipairs(pickerScroll:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end
    if pickerMode == "white" then
        pickerTitle.Text = "WHITELIST (aliados)"
        pickerTitle.TextColor3 = Color3.fromRGB(110, 255, 130)
    else
        pickerTitle.Text = "BLACKLIST (objetivos)"
        pickerTitle.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localPlayer then
            local list = (pickerMode == "white") and whitelist or blacklist
            local member = inList(list, pl.Name)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -4, 0, 22)
            row.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            row.BorderSizePixel = 0
            row.Parent = pickerScroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
            
            local nm = Instance.new("TextLabel")
            nm.Size = UDim2.new(1, -70, 1, 0)
            nm.Position = UDim2.new(0, 6, 0, 0)
            nm.BackgroundTransparency = 1
            nm.Text = pl.Name
            nm.TextColor3 = Color3.fromRGB(220, 220, 230)
            nm.TextSize = 9
            nm.Font = Enum.Font.Gotham
            nm.TextXAlignment = Enum.TextXAlignment.Left
            nm.TextTruncate = Enum.TextTruncate.AtEnd
            nm.Parent = row
            
            local act = Instance.new("TextButton")
            act.Size = UDim2.new(0, 62, 0, 16)
            act.Position = UDim2.new(1, -66, 0, 3)
            act.BackgroundColor3 = member and Color3.fromRGB(160, 50, 50) or Color3.fromRGB(45, 160, 70)
            act.Text = member and "QUITAR" or "AGREGAR"
            act.TextColor3 = Color3.fromRGB(255, 255, 255)
            act.TextSize = 8
            act.Font = Enum.Font.GothamBold
            act.BorderSizePixel = 0
            act.Parent = row
            
            act.MouseButton1Click:Connect(function()
                toggleInList(list, pl.Name)
                updateListCounts()
                rebuildPicker()
            end)
        end
    end
end

local function openPicker(mode)
    pickerMode = mode
    pickerGui.Visible = true
    rebuildPicker()
end

wlBtn.MouseButton1Click:Connect(function() openPicker("white") end)
blBtn.MouseButton1Click:Connect(function() openPicker("black") end)
pickerClose.MouseButton1Click:Connect(function() pickerGui.Visible = false end)

-- IMAN / LUNGE
local reachOn = true
local imanOn = false
local lungeOn = true
local fuerza = 4
local lungeReach = 6
local maxRange = 14
local stopRange = 5
local lastLunge = 0

local function rBtn(text, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 22)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = listPage
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local imanBtn = rBtn("IMAN: OFF", 106, Color3.fromRGB(160, 50, 50))
local lungeBtn = rBtn("LUNGE: ON", 130, Color3.fromRGB(45, 160, 70))
local fuerzaBtn = rBtn("Fuerza: 4", 154, Color3.fromRGB(70, 130, 220))

local function myRoot()
    local c = localPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function myHum()
    local c = localPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function nearestEnemy()
    local r0 = myRoot()
    if not r0 then return nil, math.huge end
    local best, bd = nil, math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localPlayer and pl.Character then
            local r = pl.Character:FindFirstChild("HumanoidRootPart")
            local h = pl.Character:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 then
                if not inList(whitelist, pl.Name) then
                    local d = (r.Position - r0.Position).Magnitude
                    if d < bd then bd = d best = r end
                end
            end
        end
    end
    return best, bd
end

RunService.Heartbeat:Connect(function()
    if not reachOn or not imanOn then return end
    local hum = myHum(); local r0 = myRoot()
    if not hum or not r0 or hum.Health <= 0 then return end
    local t, d = nearestEnemy()
    if not t or d > maxRange or d <= stopRange then return end
    local dir = t.Position - r0.Position
    dir = Vector3.new(dir.X, 0, dir.Z)
    if dir.Magnitude > 0 then
        dir = dir.Unit
        local step = math.min(d - stopRange, fuerza * 0.05)
        pcall(function() r0.CFrame = r0.CFrame + dir * step end)
    end
end)

local function doLunge()
    if not reachOn or not lungeOn then return end
    if tick() - lastLunge < 0.25 then return end
    local hum = myHum(); local r0 = myRoot()
    if not hum or not r0 or hum.Health <= 0 then return end
    local t, d = nearestEnemy()
    if not t then return end
    local melee = 6
    local maxL = melee + lungeReach + 4
    if d < melee or d > maxL then return end
    local step = math.min(lungeReach, d - melee + 1)
    local dir = t.Position - r0.Position
    dir = Vector3.new(dir.X, 0, dir.Z)
    if dir.Magnitude > 0 then
        dir = dir.Unit
        lastLunge = tick()
        pcall(function() r0.CFrame = r0.CFrame + dir * step end)
    end
end

local function hookAnims(hum)
    local anim = hum and hum:FindFirstChildOfClass("Animator")
    if not anim then return end
    anim.AnimationPlayed:Connect(function(track)
        local n = (track.Animation and track.Animation.Name or ""):lower()
        if n:match("attack") or n:match("punch") or n:match("m1") or n:match("slash") or n:match("swing") or n:match("combo") or n:match("jab") or n:match("hit") or n:match("strike") then
            doLunge()
        end
    end)
end

if localPlayer.Character then hookAnims(localPlayer.Character:FindFirstChildOfClass("Humanoid")) end
localPlayer.CharacterAdded:Connect(function(c) hookAnims(c:FindFirstChildOfClass("Humanoid")) end)

local atkConn = false
local function tryAtkBtn()
    if atkConn then return end
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "ZeidopHub" then
            for _, o in ipairs(gui:GetDescendants()) do
                if (o:IsA("TextButton") or o:IsA("ImageButton")) then
                    local n = o.Name:lower()
                    if n:match("attack") or n:match("m1") or n:match("punch") or n:match("combat") or n:match("fight") or n:match("swing") or n:match("hit") or n:match("strike") or n:match("melee") then
                        o.Activated:Connect(doLunge)
                        atkConn = true
                        return
                    end
                end
            end
        end
    end
end
task.spawn(function() while not atkConn do task.wait(3) tryAtkBtn() end end)

imanBtn.MouseButton1Click:Connect(function()
    imanOn = not imanOn
    imanBtn.Text = "IMAN: " .. (imanOn and "ON" or "OFF")
    imanBtn.BackgroundColor3 = imanOn and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
end)

lungeBtn.MouseButton1Click:Connect(function()
    lungeOn = not lungeOn
    lungeBtn.Text = "LUNGE: " .. (lungeOn and "ON" or "OFF")
    lungeBtn.BackgroundColor3 = lungeOn and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
end)

fuerzaBtn.MouseButton1Click:Connect(function()
    fuerza = fuerza + 1
    if fuerza > 10 then fuerza = 1 end
    fuerzaBtn.Text = "Fuerza: " .. fuerza
end)

-- ============================================
-- SISTEMA DE PESTAÑAS
-- ============================================
local tabs = {
    {btn = tabLock, page = lockPage},
    {btn = tabNoStun, page = noStunPage},
    {btn = tabDash, page = dashPage},
    {btn = tabList, page = listPage}
}

local function setActiveTab(index)
    for i, data in ipairs(tabs) do
        if i == index then
            data.page.Visible = true
            data.btn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
            data.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            data.page.Visible = false
            data.btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            data.btn.TextColor3 = Color3.fromRGB(180, 180, 190)
        end
    end
end

tabLock.MouseButton1Click:Connect(function() setActiveTab(1) end)
tabNoStun.MouseButton1Click:Connect(function() setActiveTab(2) end)
tabDash.MouseButton1Click:Connect(function() setActiveTab(3) end)
tabList.MouseButton1Click:Connect(function() setActiveTab(4) end)

-- ============================================
-- BOTONES FLOTANTES
-- ============================================
local lockButton = Instance.new("TextButton")
lockButton.Size = UDim2.new(0, config.buttonSize, 0, config.buttonSize)
lockButton.Position = UDim2.new(config.lockBtnXScale, config.lockBtnXOffset, config.lockBtnYScale, config.lockBtnYOffset)
lockButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
lockButton.Text = "LOCK"
lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
lockButton.TextSize = 14
lockButton.Font = Enum.Font.GothamBold
lockButton.BorderSizePixel = 0
lockButton.Active = true
lockButton.Visible = config.buttonVisible
lockButton.Parent = screenGui
Instance.new("UICorner", lockButton).CornerRadius = UDim.new(1, 0)

local lockStroke = Instance.new("UIStroke")
lockStroke.Color = Color3.fromRGB(0, 0, 0)
lockStroke.Thickness = 1.5
lockStroke.Transparency = 0.3
lockStroke.Parent = lockButton

local miniMenuBtn = Instance.new("TextButton")
miniMenuBtn.Size = UDim2.new(0, 46, 0, 46)
miniMenuBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
miniMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
miniMenuBtn.Text = LOGO_ID > 0 and "" or "Z"
miniMenuBtn.TextColor3 = Color3.fromRGB(160, 120, 255)
miniMenuBtn.TextSize = 18
miniMenuBtn.Font = Enum.Font.GothamBlack
miniMenuBtn.BorderSizePixel = 0
miniMenuBtn.Visible = false
miniMenuBtn.Active = true
miniMenuBtn.Parent = screenGui
Instance.new("UICorner", miniMenuBtn).CornerRadius = UDim.new(1, 0)

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(160, 120, 255)
miniStroke.Thickness = 2
miniStroke.Parent = miniMenuBtn

local miniLogo = Instance.new("ImageLabel")
miniLogo.Size = UDim2.new(1, -8, 1, -8)
miniLogo.Position = UDim2.new(0, 4, 0, 4)
miniLogo.BackgroundTransparency = 1
miniLogo.Image = LOGO_ID > 0 and ("rbxassetid://" .. LOGO_ID) or ""
miniLogo.Parent = miniMenuBtn
Instance.new("UICorner", miniLogo).CornerRadius = UDim.new(1, 0)

local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0, config.jumpBtnSize, 0, config.jumpBtnSize)
jumpBtn.Position = UDim2.new(0.72, 0, 0.68, 0)
jumpBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
jumpBtn.Text = "JUMP"
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.TextSize = 14
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.BorderSizePixel = 0
jumpBtn.Visible = false
jumpBtn.Parent = screenGui
Instance.new("UICorner", jumpBtn).CornerRadius = UDim.new(1, 0)

local jbStroke = Instance.new("UIStroke")
jbStroke.Color = Color3.fromRGB(0, 0, 0)
jbStroke.Thickness = 1.5
jbStroke.Transparency = 0.3
jbStroke.Parent = jumpBtn

local dashFloatBtn = Instance.new("TextButton")
dashFloatBtn.Size = UDim2.new(0, config.dashBtnSize, 0, config.dashBtnSize)
dashFloatBtn.Position = UDim2.new(0.72, 0, 0.55, 0)
dashFloatBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
dashFloatBtn.Text = "DASH"
dashFloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dashFloatBtn.TextSize = 14
dashFloatBtn.Font = Enum.Font.GothamBold
dashFloatBtn.BorderSizePixel = 0
dashFloatBtn.Visible = false
dashFloatBtn.Parent = screenGui
Instance.new("UICorner", dashFloatBtn).CornerRadius = UDim.new(1, 0)

local dfStroke = Instance.new("UIStroke")
dfStroke.Color = Color3.fromRGB(0, 0, 0)
dfStroke.Thickness = 1.5
dfStroke.Transparency = 0.3
dfStroke.Parent = dashFloatBtn

-- ============================================
-- ARRASTRE
-- ============================================
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
                    if gui == lockButton then
                        config.lockBtnXScale = lockButton.Position.X.Scale
                        config.lockBtnXOffset = lockButton.Position.X.Offset
                        config.lockBtnYScale = lockButton.Position.Y.Scale
                        config.lockBtnYOffset = lockButton.Position.Y.Offset
                        saveConfig()
                    end
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
makeDraggable(lockButton, function() return config.isDraggable end)
makeDraggable(jumpBtn, function() return not stunLocked end)
makeDraggable(dashFloatBtn, function() return not stunLocked end)
makeDraggable(pickerGui, function() return true end)

-- ============================================
-- FUNCIONES ANTI-STUN Y DASH
-- ============================================
local character = nil
local humanoid = nil
local rootPart = nil

task.spawn(function()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    character = char
    humanoid = char:FindFirstChildOfClass("Humanoid")
    rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end)

local function jump()
    if not humanoid or not rootPart or not jumping then return end
    jumping = false
    pcall(function()
        humanoid.PlatformStand = true
        rootPart.Velocity = Vector3.zero
        task.wait()
        rootPart.Velocity = Vector3.new(0, config.jumpPower, 0)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.05)
        humanoid.PlatformStand = false
    end)
    task.wait(1.2)
    jumping = true
end

local function dash()
    if not humanoid or not rootPart then return end
    pcall(function()
        local lookVector = rootPart.CFrame.LookVector
        rootPart.Velocity = Vector3.new(lookVector.X * config.dashForce, rootPart.Velocity.Y, lookVector.Z * config.dashForce)
    end)
end

local function hookDash()
    local char = localPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.ChildAdded:Connect(function(child)
        if not config.dashEnabled then return end
        if child:IsA("BodyVelocity") or child:IsA("LinearVelocity") then
            task.wait()
            pcall(function()
                if child:IsA("BodyVelocity") then
                    child.Velocity = child.Velocity * config.dashMultiplier
                elseif child:IsA("LinearVelocity") then
                    child.VectorVelocity = child.VectorVelocity * config.dashMultiplier
                end
            end)
        end
    end)
end

-- ============================================
-- CEREBRO AUTO LOCK (Distancia 3D + Cámara Directa)
-- ============================================
local function getClosestPlayer()
    Camera = workspace.CurrentCamera
    if not Camera then return nil end
    local vp = Camera.ViewportSize
    local screenCenter = Vector2.new(vp.X / 2, vp.Y / 2)
    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    local function valid(pl)
        if pl == localPlayer or not pl.Character then return nil end
        if inList(whitelist, pl.Name) then return nil end
        local root = pl.Character:FindFirstChild("HumanoidRootPart")
        local hum = pl.Character:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then return root end
        return nil
    end
    
    if #blacklist > 0 then
        local best, bestDist = nil, math.huge
        for _, name in ipairs(blacklist) do
            local pl = Players:FindFirstChild(name)
            if pl then
                local root = valid(pl)
                if root and myRoot then
                    local d = (root.Position - myRoot.Position).Magnitude
                    if d < bestDist then bestDist = d best = pl end
                end
            end
        end
        if best then return best end
    end
    
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        local root = valid(player)
        if root then
            local distance
            if config.useDistance3D and myRoot then
                distance = (root.Position - myRoot.Position).Magnitude
            else
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen and screenPos.Z > 0 then
                    distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                else
                    distance = math.huge
                end
            end
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

local function resetLock()
    targetLock = false
    lockedPlayer = nil
    lockButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
    lockButton.Text = "LOCK"
    lastTargetPos = nil
    smoothedVelocity = Vector3.new(0, 0, 0)
end

local function toggleLock()
    if not targetLock then
        local closest = getClosestPlayer()
        if closest then
            lockedPlayer = closest
            targetLock = true
            lockButton.BackgroundColor3 = Color3.fromRGB(45, 170, 70)
            lockButton.Text = "ON"
            lastTargetPos = nil
            smoothedVelocity = Vector3.new(0, 0, 0)
        end
    else
        resetLock()
    end
end

lockButton.MouseButton1Click:Connect(toggleLock)

-- ============================================
-- LOOP DE CÁMARA (PREDICT MILIMÉTRICO + SNAP DIRECTO)
-- ============================================
local lastDeltaTime = 1/60

local function cameraLockStep(dt)
    lastDeltaTime = dt or (1/60)
    if not targetLock or not lockedPlayer or not lockedPlayer.Character then return end
    
    if inList(whitelist, lockedPlayer.Name) then resetLock() return end
    if #blacklist > 0 and not inList(blacklist, lockedPlayer.Name) then
        local b = getClosestPlayer()
        if b then lockedPlayer = b else resetLock() return end
    end
    
    Camera = workspace.CurrentCamera
    if not Camera then return end
    
    local root = lockedPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = lockedPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then resetLock() return end
    
    local aimPart = root
    if config.lockPart == "head" then
        local head = lockedPlayer.Character:FindFirstChild("Head")
        if head then aimPart = head end
    end
    
    local targetPos = aimPart.Position
    local aimPosition = targetPos
    
    if config.predictEnabled then
        local dtt = math.max(lastDeltaTime, 0.001)
        local vel = root.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
        vel = Vector3.new(vel.X, 0, vel.Z)
        
        if vel.Magnitude < 1 and lastTargetPos then
            local delta = targetPos - lastTargetPos
            vel = Vector3.new(delta.X, 0, delta.Z) / dtt
        end
        
        if vel.Magnitude > 150 then vel = vel.Unit * 150 end
        
        smoothedVelocity = smoothedVelocity:Lerp(vel, 0.6)
        
        if smoothedVelocity.Magnitude >= 1.5 then
            local lead = smoothedVelocity * PREDICT_TIME
            local distToTarget = (Camera.CFrame.Position - targetPos).Magnitude
            local dynamicMax = math.clamp(distToTarget * 0.5, 6, 16)
            if lead.Magnitude > dynamicMax then lead = lead.Unit * dynamicMax end
            aimPosition = targetPos + lead
        end
    end
    
    lastTargetPos = targetPos
    
    local targetCFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
    if config.smoothMode then
        local exponential = 1 - math.exp(-config.smoothAmount * 60 * dt)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, math.clamp(exponential, 0.01, 1))
    else
        Camera.CFrame = targetCFrame
    end
end

RunService:BindToRenderStep(CAMERA_LOCK_NAME, Enum.RenderPriority.Camera.Value + 1, cameraLockStep)

-- ============================================
-- EVENTOS DEL MENÚ LOCK
-- ============================================
showBtn.MouseButton1Click:Connect(function()
    config.buttonVisible = not config.buttonVisible
    lockButton.Visible = config.buttonVisible
    showBtn.Text = config.buttonVisible and "Boton: Visible" or "Boton: Oculto"
    showBtn.BackgroundColor3 = config.buttonVisible and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    saveConfig()
end)

dragBtn.MouseButton1Click:Connect(function()
    config.isDraggable = not config.isDraggable
    dragBtn.Text = config.isDraggable and "Arrastrable: ON" or "Arrastrable: OFF"
    dragBtn.BackgroundColor3 = config.isDraggable and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    saveConfig()
end)

sizeMinus.MouseButton1Click:Connect(function()
    config.buttonSize = math.max(35, config.buttonSize - 5)
    lockButton.Size = UDim2.new(0, config.buttonSize, 0, config.buttonSize)
    sizeLabel.Text = "Tamano: " .. tostring(config.buttonSize)
    saveConfig()
end)

sizePlus.MouseButton1Click:Connect(function()
    config.buttonSize = math.min(90, config.buttonSize + 5)
    lockButton.Size = UDim2.new(0, config.buttonSize, 0, config.buttonSize)
    sizeLabel.Text = "Tamano: " .. tostring(config.buttonSize)
    saveConfig()
end)

predictMinus.MouseButton1Click:Connect(function()
    config.predictAmount = math.max(0, config.predictAmount - 0.001)
    config.predictAmount = math.floor(config.predictAmount * 1000 + 0.5) / 1000
    PREDICT_TIME = config.predictAmount
    predictLabel.Text = string.format("Predict: %.3fs", config.predictAmount)
    saveConfig()
end)

predictPlus.MouseButton1Click:Connect(function()
    config.predictAmount = math.min(0.5, config.predictAmount + 0.001)
    config.predictAmount = math.floor(config.predictAmount * 1000 + 0.5) / 1000
    PREDICT_TIME = config.predictAmount
    predictLabel.Text = string.format("Predict: %.3fs", config.predictAmount)
    saveConfig()
end)

predictToggle.MouseButton1Click:Connect(function()
    config.predictEnabled = not config.predictEnabled
    predictToggle.Text = config.predictEnabled and "ON" or "OFF"
    predictToggle.BackgroundColor3 = config.predictEnabled and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    predictLabel.TextColor3 = config.predictEnabled and Color3.fromRGB(255, 220, 130) or Color3.fromRGB(150, 150, 150)
    smoothedVelocity = Vector3.new(0, 0, 0)
    saveConfig()
end)

dist3DBtn.MouseButton1Click:Connect(function()
    config.useDistance3D = not config.useDistance3D
    dist3DBtn.Text = "Direct 3D: " .. (config.useDistance3D and "ON" or "OFF")
    dist3DBtn.BackgroundColor3 = config.useDistance3D and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    saveConfig()
end)

transBtn.MouseButton1Click:Connect(function()
    config.menuTransparency = config.menuTransparency + 0.15
    if config.menuTransparency > 0.75 then config.menuTransparency = 0 end
    menuFrame.BackgroundTransparency = config.menuTransparency
    transBtn.Text = "Transp: " .. tostring(math.floor(config.menuTransparency * 100 + 0.5)) .. "%"
    saveConfig()
end)

partBtn.MouseButton1Click:Connect(function()
    config.lockPart = (config.lockPart == "torso") and "head" or "torso"
    partBtn.Text = "Parte: " .. (config.lockPart == "head" and "Cabeza" or "Torso")
    partBtn.BackgroundColor3 = config.lockPart == "head" and Color3.fromRGB(160, 50, 50) or Color3.fromRGB(70, 130, 220)
    saveConfig()
end)

keyBtn.MouseButton1Click:Connect(function()
    listeningForKey = not listeningForKey
    keyBtn.Text = listeningForKey and "Presiona..." or ("Tecla: " .. lockKey.Name)
    keyBtn.BackgroundColor3 = listeningForKey and Color3.fromRGB(255, 220, 130) or Color3.fromRGB(70, 130, 220)
    keyBtn.TextColor3 = listeningForKey and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
end)

minBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    miniMenuBtn.Visible = true
    miniMenuBtn.Position = menuFrame.Position
    saveConfig()
end)

miniMenuBtn.MouseButton1Click:Connect(function()
    miniMenuBtn.Visible = false
    menuFrame.Visible = true
    menuFrame.Position = miniMenuBtn.Position
end)

-- ============================================
-- EVENTOS STUN
-- ============================================
local function updateNsToggle()
    nsToggleBtn.Text = config.antiStun and "ANTI-STUN: ON" or "ANTI-STUN: OFF"
    nsToggleBtn.BackgroundColor3 = config.antiStun and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
end

nsToggleBtn.MouseButton1Click:Connect(function()
    config.antiStun = not config.antiStun
    jumping = true
    updateNsToggle()
    saveConfig()
end)

nsJumpMinus.MouseButton1Click:Connect(function()
    config.jumpPower = math.max(10, config.jumpPower - 5)
    nsJumpLabel.Text = "Jump Power: " .. config.jumpPower
    saveConfig()
end)
nsJumpPlus.MouseButton1Click:Connect(function()
    config.jumpPower = math.min(150, config.jumpPower + 5)
    nsJumpLabel.Text = "Jump Power: " .. config.jumpPower
    saveConfig()
end)
nsDashMinus.MouseButton1Click:Connect(function()
    config.dashForce = math.max(10, config.dashForce - 5)
    nsDashLabel.Text = "Dash Force: " .. config.dashForce
    saveConfig()
end)
nsDashPlus.MouseButton1Click:Connect(function()
    config.dashForce = math.min(150, config.dashForce + 5)
    nsDashLabel.Text = "Dash Force: " .. config.dashForce
    saveConfig()
end)
nsJumpSizeMinus.MouseButton1Click:Connect(function()
    config.jumpBtnSize = math.max(30, config.jumpBtnSize - 2)
    jumpBtn.Size = UDim2.new(0, config.jumpBtnSize, 0, config.jumpBtnSize)
    nsJumpSizeLabel.Text = "Jump Size: " .. config.jumpBtnSize
    saveConfig()
end)
nsJumpSizePlus.MouseButton1Click:Connect(function()
    config.jumpBtnSize = math.min(100, config.jumpBtnSize + 2)
    jumpBtn.Size = UDim2.new(0, config.jumpBtnSize, 0, config.jumpBtnSize)
    nsJumpSizeLabel.Text = "Jump Size: " .. config.jumpBtnSize
    saveConfig()
end)
nsDashSizeMinus.MouseButton1Click:Connect(function()
    config.dashBtnSize = math.max(30, config.dashBtnSize - 2)
    dashFloatBtn.Size = UDim2.new(0, config.dashBtnSize, 0, config.dashBtnSize)
    nsDashSizeLabel.Text = "Dash Size: " .. config.dashBtnSize
    saveConfig()
end)
nsDashSizePlus.MouseButton1Click:Connect(function()
    config.dashBtnSize = math.min(100, config.dashBtnSize + 2)
    dashFloatBtn.Size = UDim2.new(0, config.dashBtnSize, 0, config.dashBtnSize)
    nsDashSizeLabel.Text = "Dash Size: " .. config.dashBtnSize
    saveConfig()
end)
nsJumpGenBtn.MouseButton1Click:Connect(function() jumpBtn.Visible = not jumpBtn.Visible end)
nsDashGenBtn.MouseButton1Click:Connect(function() dashFloatBtn.Visible = not dashFloatBtn.Visible end)
nsLockBtn.MouseButton1Click:Connect(function()
    stunLocked = not stunLocked
    nsLockBtn.Text = stunLocked and "LOCK FLOAT: ON" or "LOCK FLOAT: OFF"
    nsLockBtn.BackgroundColor3 = stunLocked and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(90, 90, 100)
end)
jumpBtn.MouseButton1Click:Connect(function() jump() end)
dashFloatBtn.MouseButton1Click:Connect(function() dash() end)

-- ============================================
-- EVENTOS DASH
-- ============================================
dashMinusBtn.MouseButton1Click:Connect(function()
    config.dashMultiplier = math.max(0.5, config.dashMultiplier - 0.1)
    dashValueLabel.Text = string.format("Multiplicador: %.1fx", config.dashMultiplier)
    saveConfig()
end)
dashPlusBtn.MouseButton1Click:Connect(function()
    config.dashMultiplier = math.min(4, config.dashMultiplier + 0.1)
    dashValueLabel.Text = string.format("Multiplicador: %.1fx", config.dashMultiplier)
    saveConfig()
end)
dashToggleBtn.MouseButton1Click:Connect(function()
    config.dashEnabled = not config.dashEnabled
    dashToggleBtn.BackgroundColor3 = config.dashEnabled and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    dashToggleBtn.Text = config.dashEnabled and "ACTIVADO" or "DESACTIVADO"
    saveConfig()
end)
instantDashBtn.MouseButton1Click:Connect(function()
    config.instantDash = not config.instantDash
    instantDashBtn.BackgroundColor3 = config.instantDash and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    instantDashBtn.Text = config.instantDash and "INSTANT DASH: ON" or "INSTANT DASH: OFF"
    instantDashLastVel = Vector3.new(0, 0, 0)
    saveConfig()
end)

-- ============================================
-- HEARTBEAT ANTI-STUN
-- ============================================
RunService.Heartbeat:Connect(function()
    if not config.antiStun or not humanoid or not humanoid.Parent or not jumping then return end
    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.FallingDown
    or state == Enum.HumanoidStateType.GettingUp
    or state == Enum.HumanoidStateType.PlatformStanding
    or state == Enum.HumanoidStateType.Ragdoll
    or state == Enum.HumanoidStateType.Physics then
        jump()
    end
end)

-- ============================================
-- HEARTBEAT INSTANT DASH
-- ============================================
RunService.Heartbeat:Connect(function()
    if not config.instantDash then return end
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local currentVel = hrp.AssemblyLinearVelocity
    local horizontalVel = Vector3.new(currentVel.X, 0, currentVel.Z)
    
    if horizontalVel.Magnitude > 65 and instantDashLastVel.Magnitude < 50 then
        local dir = horizontalVel.Unit
        pcall(function()
            hrp.CFrame = hrp.CFrame + dir * (18 * 0.6)
            hrp.AssemblyLinearVelocity = dir * 140
        end)
    end
    instantDashLastVel = horizontalVel
end)

-- ============================================
-- HOTKEYS
-- ============================================
UserInputService.InputBegan:Connect(function(input, processed)
    if listeningForKey then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            lockKey = input.KeyCode
            config.lockKeyName = lockKey.Name
            listeningForKey = false
            keyBtn.Text = "Tecla: " .. lockKey.Name
            keyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
            keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            saveConfig()
        end
        return
    end
    if processed then return end
    
    if input.KeyCode == lockKey then
        toggleLock()
    elseif input.KeyCode == Enum.KeyCode.X then
        config.antiStun = not config.antiStun
        jumping = true
        updateNsToggle()
        saveConfig()
    elseif input.KeyCode == Enum.KeyCode.Z then
        config.antiStun = false
        updateNsToggle()
        saveConfig()
    elseif input.KeyCode == Enum.KeyCode.Space and config.antiStun then
        jump()
    elseif input.KeyCode == Enum.KeyCode.Q then
        dash()
    end
end)

-- ============================================
-- SEGURIDAD Y LIMPIEZA
-- ============================================
Players.PlayerRemoving:Connect(function(pl)
    for i = #whitelist, 1, -1 do if whitelist[i] == pl.Name then table.remove(whitelist, i) end end
    for i = #blacklist, 1, -1 do if blacklist[i] == pl.Name then table.remove(blacklist, i) end end
    updateListCounts()
    if pickerGui.Visible then rebuildPicker() end
    if lockedPlayer == pl then resetLock() end
end)

localPlayer.CharacterAdded:Connect(function(c)
    character = c
    humanoid = c:WaitForChild("Humanoid")
    rootPart = c:WaitForChild("HumanoidRootPart", 3) or c:FindFirstChild("Torso")
    jumping = true
    instantDashLastVel = Vector3.new(0, 0, 0)
    task.wait(0.5)
    if targetLock then resetLock() end
    hookDash()
end)

if localPlayer.Character then hookDash() end

-- Mostrar menú
task.delay(2, function()
    if loadGui and loadGui.Parent then loadGui:Destroy() end
    menuFrame.Visible = true
end)

-- Aplicar visuales iniciales
local function refreshAllVisuals()
    lockButton.Size = UDim2.new(0, config.buttonSize, 0, config.buttonSize)
    lockButton.Visible = config.buttonVisible
    sizeLabel.Text = "Tamano: " .. tostring(config.buttonSize)
    showBtn.Text = config.buttonVisible and "Boton: Visible" or "Boton: Oculto"
    showBtn.BackgroundColor3 = config.buttonVisible and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    dragBtn.Text = config.isDraggable and "Arrastrable: ON" or "Arrastrable: OFF"
    dragBtn.BackgroundColor3 = config.isDraggable and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    predictLabel.Text = string.format("Predict: %.3fs", config.predictAmount)
    PREDICT_TIME = config.predictAmount
    predictToggle.Text = config.predictEnabled and "ON" or "OFF"
    predictToggle.BackgroundColor3 = config.predictEnabled and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    predictLabel.TextColor3 = config.predictEnabled and Color3.fromRGB(255, 220, 130) or Color3.fromRGB(150, 150, 150)
    dist3DBtn.Text = "Direct 3D: " .. (config.useDistance3D and "ON" or "OFF")
    dist3DBtn.BackgroundColor3 = config.useDistance3D and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    partBtn.Text = "Parte: " .. (config.lockPart == "head" and "Cabeza" or "Torso")
    partBtn.BackgroundColor3 = config.lockPart == "head" and Color3.fromRGB(160, 50, 50) or Color3.fromRGB(70, 130, 220)
    keyBtn.Text = "Tecla: " .. lockKey.Name
    transBtn.Text = "Transp: " .. math.floor(config.menuTransparency * 100) .. "%"
    updateNsToggle()
    updateListCounts()
    nsJumpLabel.Text = "Jump Power: " .. config.jumpPower
    nsDashLabel.Text = "Dash Force: " .. config.dashForce
    nsJumpSizeLabel.Text = "Jump Size: " .. config.jumpBtnSize
    nsDashSizeLabel.Text = "Dash Size: " .. config.dashBtnSize
    jumpBtn.Size = UDim2.new(0, config.jumpBtnSize, 0, config.jumpBtnSize)
    dashFloatBtn.Size = UDim2.new(0, config.dashBtnSize, 0, config.dashBtnSize)
    dashValueLabel.Text = string.format("Multiplicador: %.1fx", config.dashMultiplier)
    dashToggleBtn.BackgroundColor3 = config.dashEnabled and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    dashToggleBtn.Text = config.dashEnabled and "ACTIVADO" or "DESACTIVADO"
    instantDashBtn.Text = config.instantDash and "INSTANT DASH: ON" or "INSTANT DASH: OFF"
    instantDashBtn.BackgroundColor3 = config.instantDash and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
end

refreshAllVisuals()

-- Autoguardado
task.spawn(function()
    while true do
        task.wait(5)
        saveConfig()
    end
end)

print("Zeidop Hub cargado OK - LOCK + INSTANT DASH + STUN + DASH + LISTA")

-- FIX SCROLL DEL SELECTOR
task.spawn(function()
    local pg2 = Players.LocalPlayer:WaitForChild("PlayerGui")
    local hub2 = pg2:FindFirstChild("ZeidopHub")
    local picker2 = hub2 and hub2:FindFirstChild("ZeidopPicker")
    if picker2 then
        local scroll2 = picker2:FindFirstChildOfClass("ScrollingFrame")
        if scroll2 then
            pcall(function()
                scroll2.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
            end)
            local layout2 = scroll2:FindFirstChildOfClass("UIListLayout")
            if layout2 then
                local function fit()
                    scroll2.CanvasSize = UDim2.new(0, 0, 0, layout2.AbsoluteContentSize.Y + 8)
                end
                fit()
                layout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fit)
            end
        end
    end
end)

-- ============================================
-- DASH ASSIST (CORREGIDO: variable 'c' renombrada a 'cc')
-- ============================================
do
    local STEER_MAX_ANGLE = math.rad(50)
    local MAX_T = 0.45
    local STOP_DIST = 3
    local SPIKE_ON, SPIKE_OFF = 50, 35
    local WINDOW = 0.35

    if config.dashAssist == nil then config.dashAssist = true end

    local assistBtn = Instance.new("TextButton")
    assistBtn.Size = UDim2.new(1, 0, 0, 24)
    assistBtn.Position = UDim2.new(0, 0, 0, 190)
    assistBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    assistBtn.TextSize = 11
    assistBtn.Font = Enum.Font.GothamBold
    assistBtn.BorderSizePixel = 0
    assistBtn.Parent = dashPage
    Instance.new("UICorner", assistBtn).CornerRadius = UDim.new(0, 6)

    local function refreshAssistBtn()
        assistBtn.Text = "DASH ASSIST: " .. (config.dashAssist and "ON" or "OFF")
        assistBtn.BackgroundColor3 = config.dashAssist and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    end
    refreshAssistBtn()
    assistBtn.MouseButton1Click:Connect(function()
        config.dashAssist = not config.dashAssist
        refreshAssistBtn()
        saveConfig()
    end)

    local active = false
    local driver = nil
    local origDir = nil
    local untilT = 0
    local lastH = 0

    local function usable(c)
        if c:IsA("BodyVelocity") then return true end
        if c:IsA("LinearVelocity") then
            local ok, rel = pcall(function() return c.RelativeTo end)
            return ok and rel == Enum.ActuatorRelativeTo.World
        end
        return false
    end
    local function getVel(c) return c:IsA("BodyVelocity") and c.Velocity or c.VectorVelocity end
    local function setVel(c, v)
        if c:IsA("BodyVelocity") then c.Velocity = v else c.VectorVelocity = v end
    end
    local function findDriver(hrp)
        for _, c in ipairs(hrp:GetChildren()) do
            if usable(c) then return c end
        end
        return nil
    end

    local function getTargetRoot()
        if not targetLock or not lockedPlayer then return nil end
        local ch = lockedPlayer.Character
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        local h = ch and ch:FindFirstChildOfClass("Humanoid")
        if r and h and h.Health > 0 then return r end
        return nil
    end

    -- CORRECCIÓN: variable 'c' renombrada a 'cc' para evitar conflicto con parámetro
    local function interceptDir(myPos, tRoot, speed)
        local r = Vector3.new(tRoot.Position.X - myPos.X, 0, tRoot.Position.Z - myPos.Z)
        local tv = tRoot.AssemblyLinearVelocity
        local v = Vector3.new(tv.X, 0, tv.Z)
        local a = v:Dot(v) - speed * speed
        local b = 2 * r:Dot(v)
        local cc = r:Dot(r)  -- ← AQUÍ ESTABA EL BUG: antes era 'c', ahora es 'cc'
        local t = nil
        if math.abs(a) < 1e-4 then
            if b < 0 then t = -cc / b end
        else
-- ============================================
-- DASH ASSIST (valores ajustables desde el menú)
-- ============================================
do
    -- Cargar valores guardados del archivo
    pcall(function()
        if readfile and isfile and isfile(SAVE_FILE) then
            local d = HttpService:JSONDecode(readfile(SAVE_FILE))
            if type(d) == "table" then
                if type(d.assistMaxT) == "number" then config.assistMaxT = d.assistMaxT end
                if type(d.assistAngle) == "number" then config.assistAngle = d.assistAngle end
                if type(d.assistStopDist) == "number" then config.assistStopDist = d.assistStopDist end
                if type(d.assistSpikeOn) == "number" then config.assistSpikeOn = d.assistSpikeOn end
                if type(d.assistSpikeOff) == "number" then config.assistSpikeOff = d.assistSpikeOff end
                if type(d.assistWindow) == "number" then config.assistWindow = d.assistWindow end
            end
        end
    end)

    -- Defaults si no hay nada guardado
    if config.assistMaxT == nil then config.assistMaxT = 0.44 end
    if config.assistAngle == nil then config.assistAngle = 50 end
    if config.assistStopDist == nil then config.assistStopDist = 3 end
    if config.assistSpikeOn == nil then config.assistSpikeOn = 50 end
    if config.assistSpikeOff == nil then config.assistSpikeOff = 35 end
    if config.assistWindow == nil then config.assistWindow = 0.35 end
    if config.dashAssist == nil then config.dashAssist = true end

    -- Variables activas (la lógica lee estas)
    local MAX_T = config.assistMaxT
    local STEER_MAX_ANGLE = math.rad(config.assistAngle)
    local STOP_DIST = config.assistStopDist
    local SPIKE_ON = config.assistSpikeOn
    local SPIKE_OFF = config.assistSpikeOff
    local WINDOW = config.assistWindow

    -- Botón ON/OFF (más corto para dejar espacio al ⚙)
    local assistBtn = Instance.new("TextButton")
    assistBtn.Size = UDim2.new(0, 150, 0, 24)
    assistBtn.Position = UDim2.new(0, 5, 0, 190)
    assistBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    assistBtn.TextSize = 11
    assistBtn.Font = Enum.Font.GothamBold
    assistBtn.BorderSizePixel = 0
    assistBtn.Parent = dashPage
    Instance.new("UICorner", assistBtn).CornerRadius = UDim.new(0, 6)

    -- Botón ⚙ para abrir configuración
    local assistCfgBtn = Instance.new("TextButton")
    assistCfgBtn.Size = UDim2.new(0, 34, 0, 24)
    assistCfgBtn.Position = UDim2.new(0, 159, 0, 190)
    assistCfgBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    assistCfgBtn.Text = "⚙"
    assistCfgBtn.TextColor3 = Color3.fromRGB(160, 120, 255)
    assistCfgBtn.TextSize = 14
    assistCfgBtn.Font = Enum.Font.GothamBold
    assistCfgBtn.BorderSizePixel = 0
    assistCfgBtn.Parent = dashPage
    Instance.new("UICorner", assistCfgBtn).CornerRadius = UDim.new(0, 6)

    local function refreshAssistBtn()
        assistBtn.Text = "DASH ASSIST: " .. (config.dashAssist and "ON" or "OFF")
        assistBtn.BackgroundColor3 = config.dashAssist and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    end
    refreshAssistBtn()

    assistBtn.MouseButton1Click:Connect(function()
        config.dashAssist = not config.dashAssist
        refreshAssistBtn()
        saveConfig()
    end)

    -- ============================================
    -- POPUP DE CONFIGURACIÓN
    -- ============================================
    local cfgGui = Instance.new("Frame")
    cfgGui.Name = "AssistCfgPanel"
    cfgGui.Size = UDim2.new(0, 190, 0, 210)
    cfgGui.Position = UDim2.new(0.5, -95, 0.5, -105)
    cfgGui.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    cfgGui.BorderSizePixel = 0
    cfgGui.Active = true
    cfgGui.Visible = false
    cfgGui.ZIndex = 50
    cfgGui.Parent = screenGui
    Instance.new("UICorner", cfgGui).CornerRadius = UDim.new(0, 10)

    local cfgStroke = Instance.new("UIStroke")
    cfgStroke.Color = Color3.fromRGB(160, 120, 255)
    cfgStroke.Thickness = 1.5
    cfgStroke.Parent = cfgGui

    local cfgTitle = Instance.new("TextLabel")
    cfgTitle.Size = UDim2.new(1, -30, 0, 22)
    cfgTitle.Position = UDim2.new(0, 8, 0, 4)
    cfgTitle.BackgroundTransparency = 1
    cfgTitle.Text = "ASSIST CONFIG"
    cfgTitle.TextColor3 = Color3.fromRGB(160, 120, 255)
    cfgTitle.TextSize = 11
    cfgTitle.Font = Enum.Font.GothamBold
    cfgTitle.TextXAlignment = Enum.TextXAlignment.Left
    cfgTitle.Parent = cfgGui

    local cfgClose = Instance.new("TextButton")
    cfgClose.Size = UDim2.new(0, 22, 0, 22)
    cfgClose.Position = UDim2.new(1, -26, 0, 4)
    cfgClose.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
    cfgClose.Text = "X"
    cfgClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    cfgClose.TextSize = 12
    cfgClose.Font = Enum.Font.GothamBold
    cfgClose.BorderSizePixel = 0
    cfgClose.Parent = cfgGui
    Instance.new("UICorner", cfgClose).CornerRadius = UDim.new(0, 5)

    -- Helper para redondear al paso
    local function roundStep(v, step)
        return math.floor(v / step + 0.5) * step
    end

    -- Helper para crear filas de ajuste
    local cfgY = 30
    local function makeCfgRow(name, getVal, setVal, step, min, max, fmt)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 92, 0, 20)
        label.Position = UDim2.new(0, 8, 0, cfgY + 2)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. fmt(getVal())
        label.TextColor3 = Color3.fromRGB(200, 200, 210)
        label.TextSize = 9
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = cfgGui

        local minus = Instance.new("TextButton")
        minus.Size = UDim2.new(0, 28, 0, 20)
        minus.Position = UDim2.new(0, 104, 0, cfgY)
        minus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        minus.Text = "-"
        minus.TextColor3 = Color3.fromRGB(255, 255, 255)
        minus.TextSize = 12
        minus.Font = Enum.Font.GothamBold
        minus.BorderSizePixel = 0
        minus.Parent = cfgGui
        Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 4)

        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0, 28, 0, 20)
        plus.Position = UDim2.new(0, 136, 0, cfgY)
        plus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        plus.Text = "+"
        plus.TextColor3 = Color3.fromRGB(255, 255, 255)
        plus.TextSize = 12
        plus.Font = Enum.Font.GothamBold
        plus.BorderSizePixel = 0
        plus.Parent = cfgGui
        Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)

        local function update()
            label.Text = name .. ": " .. fmt(getVal())
        end

        minus.MouseButton1Click:Connect(function()
            local v = roundStep(getVal() - step, step)
            if v < min then v = min end
            setVal(v)
            update()
            saveConfig()
        end)

        plus.MouseButton1Click:Connect(function()
            local v = roundStep(getVal() + step, step)
            if v > max then v = max end
            setVal(v)
            update()
            saveConfig()
        end)

        cfgY = cfgY + 26
    end

    -- Filas de ajuste
    makeCfgRow("Tiempo", function() return MAX_T end,
        function(v) MAX_T = v; config.assistMaxT = v end,
        0.01, 0.10, 1.50, function(v) return string.format("%.2f", v) end)

    makeCfgRow("Ángulo", function() return config.assistAngle end,
        function(v) config.assistAngle = v; STEER_MAX_ANGLE = math.rad(v) end,
        5, 10, 90, function(v) return string.format("%d°", v) end)

    makeCfgRow("Freno", function() return STOP_DIST end,
        function(v) STOP_DIST = v; config.assistStopDist = v end,
        1, 1, 10, function(v) return string.format("%d", v) end)

    makeCfgRow("Spike ON", function() return SPIKE_ON end,
        function(v) SPIKE_ON = v; config.assistSpikeOn = v end,
        5, 20, 120, function(v) return string.format("%d", v) end)

    makeCfgRow("Spike OFF", function() return SPIKE_OFF end,
        function(v) SPIKE_OFF = v; config.assistSpikeOff = v end,
        5, 10, 100, function(v) return string.format("%d", v) end)

    makeCfgRow("Ventana", function() return WINDOW end,
        function(v) WINDOW = v; config.assistWindow = v end,
        0.05, 0.10, 1.00, function(v) return string.format("%.2f", v) end)

    -- Abrir/cerrar popup
    assistCfgBtn.MouseButton1Click:Connect(function()
        cfgGui.Visible = not cfgGui.Visible
    end)
    cfgClose.MouseButton1Click:Connect(function()
        cfgGui.Visible = false
    end)

    -- Hacer popup arrastrable
    makeDraggable(cfgGui, function() return true end)

    -- ============================================
    -- LÓGICA DEL DASH ASSIST
    -- ============================================
    local active = false
    local driver = nil
    local origDir = nil
    local untilT = 0
    local lastH = 0

    local function usable(c)
        if c:IsA("BodyVelocity") then return true end
        if c:IsA("LinearVelocity") then
            local ok, rel = pcall(function() return c.RelativeTo end)
            return ok and rel == Enum.ActuatorRelativeTo.World
        end
        return false
    end

    local function getVel(c) return c:IsA("BodyVelocity") and c.Velocity or c.VectorVelocity end
    local function setVel(c, v)
        if c:IsA("BodyVelocity") then c.Velocity = v else c.VectorVelocity = v end
    end

    local function findDriver(hrp)
        for _, c in ipairs(hrp:GetChildren()) do
            if usable(c) then return c end
        end
        return nil
    end

    local function getTargetRoot()
        if not targetLock or not lockedPlayer then return nil end
        local ch = lockedPlayer.Character
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        local h = ch and ch:FindFirstChildOfClass("Humanoid")
        if r and h and h.Health > 0 then return r end
        return nil
    end

    local function interceptDir(myPos, tRoot, speed)
        local r = Vector3.new(tRoot.Position.X - myPos.X, 0, tRoot.Position.Z - myPos.Z)
        local tv = tRoot.AssemblyLinearVelocity
        local v = Vector3.new(tv.X, 0, tv.Z)
        local a = v:Dot(v) - speed * speed
        local b = 2 * r:Dot(v)
        local cc = r:Dot(r)
        local t = nil
        if math.abs(a) < 1e-4 then
            if b < 0 then t = -cc / b end
        else
            local disc = b * b - 4 * a * cc
            if disc >= 0 then
                local sq = math.sqrt(disc)
                local t1, t2 = (-b - sq) / (2 * a), (-b + sq) / (2 * a)
                if t1 > 0 and t2 > 0 then t = math.min(t1, t2)
                elseif t1 > 0 then t = t1
                elseif t2 > 0 then t = t2 end
            end
        end
        t = math.clamp(t or 0, 0, MAX_T)
        local aim = r + v * t
        if aim.Magnitude < 0.01 then return nil end
        return aim.Unit
    end

    local function startAssist(hrp, drv)
        if active then
            if drv and not driver then
                driver = drv
                untilT = tick() + 1.5
            end
            return
        end
        local v = drv and getVel(drv) or hrp.AssemblyLinearVelocity
        local h = Vector3.new(v.X, 0, v.Z)
        if h.Magnitude < 10 then return end
        active = true
        driver = drv
        origDir = h.Unit
        untilT = tick() + (drv and 1.5 or WINDOW)
    end

    local function steer(hrp)
        local tRoot = getTargetRoot()
        if not tRoot or not origDir then return end
        local cur = (driver and driver.Parent) and getVel(driver) or hrp.AssemblyLinearVelocity
        local speedH = Vector3.new(cur.X, 0, cur.Z).Magnitude
        if speedH < 10 then return end
        local toT = Vector3.new(tRoot.Position.X - hrp.Position.X, 0, tRoot.Position.Z - hrp.Position.Z)
        if toT.Magnitude < STOP_DIST then return end
        local ang = math.acos(math.clamp(origDir:Dot(toT.Unit), -1, 1))
        if ang > STEER_MAX_ANGLE then return end
        local dir = interceptDir(hrp.Position, tRoot, speedH)
        if not dir then return end
        local nv = Vector3.new(dir.X * speedH, cur.Y, dir.Z * speedH)
        if driver and driver.Parent then
            setVel(driver, nv)
        else
            hrp.AssemblyLinearVelocity = nv
        end
    end

    local conn = nil
    local function hookChar(char)
        if conn then conn:Disconnect() conn = nil end
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        conn = hrp.ChildAdded:Connect(function(child)
            if not config.dashAssist or not usable(child) then return end
            RunService.Heartbeat:Wait()
            RunService.Heartbeat:Wait()
            if child.Parent and getTargetRoot() then startAssist(hrp, child) end
        end)
    end

    if localPlayer.Character then task.spawn(hookChar, localPlayer.Character) end
    localPlayer.CharacterAdded:Connect(function(c)
        active = false
        driver = nil
        task.spawn(hookChar, c)
    end)

    RunService.Heartbeat:Connect(function()
        if not config.dashAssist then active = false driver = nil return end
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local v = hrp.AssemblyLinearVelocity
        local h = Vector3.new(v.X, 0, v.Z).Magnitude
        if not active then
            if h > SPIKE_ON and lastH < SPIKE_OFF and getTargetRoot() then
                startAssist(hrp, findDriver(hrp))
            end
        else
            if (driver and not driver.Parent) or tick() > untilT then
                active = false
                driver = nil
            else
                steer(hrp)
            end
        end
        lastH = h
    end)
            end
