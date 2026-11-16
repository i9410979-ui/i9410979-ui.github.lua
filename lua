--[[
    Utility Script (Client-side) — Tabbed UI + 3D Auras + Save + Sky + ESP
    Halo: continuous neon ring | HSticks: 4, safe radius
    Orbit Player: fast run around target + Quick button + hotkey O
    Space sky: lighter | Collapsible: Players list & Orbit Player
    Radar: bottom-left minimap
    Added: Gray Fog Atmosphere
]]

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UIS             = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local Lighting        = game:GetService("Lighting")
local VirtualUser     = game:GetService("VirtualUser")
local LocalPlayer     = Players.LocalPlayer

local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ================== SETTINGS ==================
local SETTINGS_FILE = "UtilitySettings.json"

local defaultState = {
    espEnabled      = false,
    espOutline      = Color3.fromRGB(0, 255, 120),
    espFill         = Color3.fromRGB(0, 255, 120),
    espOutlineAlpha = 0,
    espFillAlpha    = 0.7,

    haloEnabled     = false,
    haloColor       = Color3.fromRGB(255, 215, 0),

    spiralEnabled   = false,
    spiralColor     = Color3.fromRGB(0, 200, 255),

    sticksEnabled   = false,
    sticksColor     = Color3.fromRGB(255, 140, 0),

    hSticksEnabled  = false,
    hSticksColor    = Color3.fromRGB(255, 50, 150),

    noclip          = false,
    antiAfk         = false,
    grayFogEnabled  = false, -- ДОБАВЛЕНО

    orbitEnabled    = false,
    orbitSpeed      = 3.5,
    orbitRadius     = 6,
    orbitTarget     = "",

    uiPlayersOpen   = true,
    uiOrbitOpen     = true,

    radarEnabled    = true,
    radarVisible    = true,

    skyMode         = "Default",
    skyColor        = Color3.fromRGB(128, 128, 128),

    uiBgColor       = Color3.fromRGB(18, 18, 24),
    uiHeaderColor   = Color3.fromRGB(25, 25, 35),
    uiAccentColor   = Color3.fromRGB(0, 255, 120),
    uiButtonColor   = Color3.fromRGB(32, 32, 42),
    uiTextColor     = Color3.fromRGB(220, 220, 220)
}

local state = {}

local function colorToTable(c) return {R = c.R, G = c.G, B = c.B} end
local function tableToColor(t)
    if type(t) == "table" and t.R and t.G and t.B then return Color3.new(t.R, t.G, t.B) end
    return Color3.new(1, 1, 1)
end

local function saveSettings()
    local dataToSave = {
        espEnabled = state.espEnabled, espOutline = colorToTable(state.espOutline),
        espFill = colorToTable(state.espFill), espOutlineAlpha = state.espOutlineAlpha,
        espFillAlpha = state.espFillAlpha, haloEnabled = state.haloEnabled,
        haloColor = colorToTable(state.haloColor), spiralEnabled = state.spiralEnabled,
        spiralColor = colorToTable(state.spiralColor), sticksEnabled = state.sticksEnabled,
        sticksColor = colorToTable(state.sticksColor), hSticksEnabled = state.hSticksEnabled,
        hSticksColor = colorToTable(state.hSticksColor),
        noclip = state.noclip, antiAfk = state.antiAfk,
        grayFogEnabled = state.grayFogEnabled, -- ДОБАВЛЕНО
        orbitEnabled = state.orbitEnabled, orbitSpeed = state.orbitSpeed,
        orbitRadius = state.orbitRadius, orbitTarget = state.orbitTarget,
        uiPlayersOpen = state.uiPlayersOpen, uiOrbitOpen = state.uiOrbitOpen,
        radarEnabled = state.radarEnabled, radarVisible = state.radarVisible,
        skyMode = state.skyMode, skyColor = colorToTable(state.skyColor),
        uiBgColor = colorToTable(state.uiBgColor), uiHeaderColor = colorToTable(state.uiHeaderColor),
        uiAccentColor = colorToTable(state.uiAccentColor), uiButtonColor = colorToTable(state.uiButtonColor),
        uiTextColor = colorToTable(state.uiTextColor)
    }
    pcall(function() writefile(SETTINGS_FILE, HttpService:JSONEncode(dataToSave)) end)
end

local function loadSettings()
    local loaded = {}
    local success, content = pcall(function()
        if isfile and isfile(SETTINGS_FILE) then return readfile(SETTINGS_FILE) end
        return nil
    end)
    if success and content then
        local decodeSuccess, decoded = pcall(function() return HttpService:JSONDecode(content) end)
        if decodeSuccess and type(decoded) == "table" then loaded = decoded end
    end
    state.espEnabled = loaded.espEnabled or defaultState.espEnabled
    state.espOutline = loaded.espOutline and tableToColor(loaded.espOutline) or defaultState.espOutline
    state.espFill = loaded.espFill and tableToColor(loaded.espFill) or defaultState.espFill
    state.espOutlineAlpha = loaded.espOutlineAlpha or defaultState.espOutlineAlpha
    state.espFillAlpha = loaded.espFillAlpha or defaultState.espFillAlpha
    state.haloEnabled = loaded.haloEnabled or defaultState.haloEnabled
    state.haloColor = loaded.haloColor and tableToColor(loaded.haloColor) or defaultState.haloColor
    state.spiralEnabled = loaded.spiralEnabled or defaultState.spiralEnabled
    state.spiralColor = loaded.spiralColor and tableToColor(loaded.spiralColor) or defaultState.spiralColor
    state.sticksEnabled = loaded.sticksEnabled or defaultState.sticksEnabled
    state.sticksColor = loaded.sticksColor and tableToColor(loaded.sticksColor) or defaultState.sticksColor
    state.hSticksEnabled = loaded.hSticksEnabled or defaultState.hSticksEnabled
    state.hSticksColor = loaded.hSticksColor and tableToColor(loaded.hSticksColor) or defaultState.hSticksColor
    state.noclip = loaded.noclip or defaultState.noclip
    state.antiAfk = loaded.antiAfk or defaultState.antiAfk
    state.grayFogEnabled = loaded.grayFogEnabled or defaultState.grayFogEnabled -- ДОБАВЛЕНО
    state.orbitEnabled = loaded.orbitEnabled or defaultState.orbitEnabled
    state.orbitSpeed = loaded.orbitSpeed or defaultState.orbitSpeed
    state.orbitRadius = loaded.orbitRadius or defaultState.orbitRadius
    state.orbitTarget = loaded.orbitTarget or defaultState.orbitTarget
    if loaded.uiPlayersOpen ~= nil then state.uiPlayersOpen = loaded.uiPlayersOpen else state.uiPlayersOpen = defaultState.uiPlayersOpen end
    if loaded.uiOrbitOpen ~= nil then state.uiOrbitOpen = loaded.uiOrbitOpen else state.uiOrbitOpen = defaultState.uiOrbitOpen end
    if loaded.radarEnabled ~= nil then state.radarEnabled = loaded.radarEnabled else state.radarEnabled = defaultState.radarEnabled end
    if loaded.radarVisible ~= nil then state.radarVisible = loaded.radarVisible else state.radarVisible = defaultState.radarVisible end
    state.skyMode = loaded.skyMode or defaultState.skyMode
    state.skyColor = loaded.skyColor and tableToColor(loaded.skyColor) or defaultState.skyColor
    state.uiBgColor = loaded.uiBgColor and tableToColor(loaded.uiBgColor) or defaultState.uiBgColor
    state.uiHeaderColor = loaded.uiHeaderColor and tableToColor(loaded.uiHeaderColor) or defaultState.uiHeaderColor
    state.uiAccentColor = loaded.uiAccentColor and tableToColor(loaded.uiAccentColor) or defaultState.uiAccentColor
    state.uiButtonColor = loaded.uiButtonColor and tableToColor(loaded.uiButtonColor) or defaultState.uiButtonColor
    state.uiTextColor = loaded.uiTextColor and tableToColor(loaded.uiTextColor) or defaultState.uiTextColor
end
loadSettings()

-- ================== HELPERS ==================
local palette = {
    Color3.fromRGB(255, 60, 60), Color3.fromRGB(60, 255, 100),
    Color3.fromRGB(60, 140, 255), Color3.fromRGB(255, 220, 60),
    Color3.fromRGB(60, 240, 240), Color3.fromRGB(255, 80, 220),
    Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 150, 40),
    Color3.fromRGB(18, 18, 24), Color3.fromRGB(0, 0, 0)
}

local function safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[Utility]", err) end
    return ok
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
    return c
end

-- ================== GUI ==================
local gui = Instance.new("ScreenGui")
gui.Name = "UtilityGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 10
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 999, 0, 500)
main.Position = UDim2.new(0, 30, 0.5, -240)
main.BackgroundColor3 = state.uiBgColor
main.BorderSizePixel = 0
main.Visible = false
main.Active = true
main.Parent = gui
corner(main, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = state.uiAccentColor
stroke.Thickness = 1.5
stroke.Transparency = 0.5
stroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = state.uiHeaderColor
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = main
corner(header, 12)

local headerLabel = Instance.new("TextLabel")
headerLabel.Size = UDim2.new(1, -20, 1, 0)
headerLabel.Position = UDim2.new(0, 12, 0, 0)
headerLabel.BackgroundTransparency = 1
headerLabel.Text = "VoidPulse"
headerLabel.TextColor3 = state.uiAccentColor
headerLabel.Font = Enum.Font.GothamBold
headerLabel.TextSize = 14
headerLabel.TextXAlignment = Enum.TextXAlignment.Left
headerLabel.ZIndex = 3
headerLabel.Parent = header

-- ================== TAB SWITCHER ==================
local tabSwitcher = Instance.new("Frame")
tabSwitcher.Size = UDim2.new(1, -20, 0, 36)
tabSwitcher.Position = UDim2.new(0, 10, 0, 40)
tabSwitcher.BackgroundTransparency = 1
tabSwitcher.Parent = main

local leftBtn = Instance.new("TextButton")
leftBtn.Size = UDim2.new(0, 36, 1, 0)
leftBtn.BackgroundColor3 = state.uiButtonColor
leftBtn.Text = "<"
leftBtn.TextColor3 = state.uiTextColor
leftBtn.Font = Enum.Font.GothamBold
leftBtn.TextSize = 18
leftBtn.Parent = tabSwitcher
corner(leftBtn, 8)

local rightBtn = Instance.new("TextButton")
rightBtn.Size = UDim2.new(0, 36, 1, 0)
rightBtn.Position = UDim2.new(1, -36, 0, 0)
rightBtn.BackgroundColor3 = state.uiButtonColor
rightBtn.Text = ">"
rightBtn.TextColor3 = state.uiTextColor
rightBtn.Font = Enum.Font.GothamBold
rightBtn.TextSize = 18
rightBtn.Parent = tabSwitcher
corner(rightBtn, 8)

local tabTitle = Instance.new("TextLabel")
tabTitle.Size = UDim2.new(1, -80, 1, 0)
tabTitle.Position = UDim2.new(0, 40, 0, 0)
tabTitle.BackgroundTransparency = 1
tabTitle.Text = "MAIN"
tabTitle.TextColor3 = state.uiTextColor
tabTitle.Font = Enum.Font.GothamBold
tabTitle.TextSize = 16
tabTitle.Parent = tabSwitcher

-- ================== DOTS ==================
local dotsFrame = Instance.new("Frame")
dotsFrame.Size = UDim2.new(1, 0, 0, 20)
dotsFrame.Position = UDim2.new(0, 0, 1, -25)
dotsFrame.BackgroundTransparency = 1
dotsFrame.Parent = main

local dotsLayout = Instance.new("UIListLayout")
dotsLayout.FillDirection = Enum.FillDirection.Horizontal
dotsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
dotsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
dotsLayout.Padding = UDim.new(0, 8)
dotsLayout.Parent = dotsFrame

local dots = {}
for i = 1, 3 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.BackgroundColor3 = state.uiButtonColor
    dot.Parent = dotsFrame
    corner(dot, 4)
    table.insert(dots, dot)
end

-- ================== PAGE CONTAINER ==================
local pageContainer = Instance.new("Frame")
pageContainer.Size = UDim2.new(1, -20, 1, -120)
pageContainer.Position = UDim2.new(0, 10, 0, 85)
pageContainer.BackgroundTransparency = 1
pageContainer.ClipsDescendants = true
pageContainer.Parent = main

local pages = {}
local currentPage = 1
local totalPages = 3

local function createPage(titleText)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = state.uiAccentColor
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = pageContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    page.Name = titleText
    table.insert(pages, page)
    return page
end

local page1 = createPage("ESP & Auras")
local page2 = createPage("Utilities")
local page3 = createPage("Settings & Players")

local function updateTabs()
    for i, p in ipairs(pages) do
        p.Visible = (i == currentPage)
    end
    tabTitle.Text = pages[currentPage].Name
    for i, d in ipairs(dots) do
        if i == currentPage then
            d.BackgroundColor3 = state.uiAccentColor
        else
            d.BackgroundColor3 = state.uiButtonColor
        end
    end
end

leftBtn.MouseButton1Click:Connect(function()
    currentPage -= 1
    if currentPage < 1 then currentPage = totalPages end
    updateTabs()
end)
rightBtn.MouseButton1Click:Connect(function()
    currentPage += 1
    if currentPage > totalPages then currentPage = 1 end
    updateTabs()
end)

-- ================== UI BUILDERS ==================
local orderCounter = 0
local function nextOrder() orderCounter += 1; return orderCounter end

local function sectionLabel(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -4, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = state.uiAccentColor
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = nextOrder()
    lbl.Parent = parent
    return lbl
end

local function makeButton(text, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 30)
    btn.BackgroundColor3 = state.uiButtonColor
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = state.uiTextColor
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.AutoButtonColor = true
    btn.LayoutOrder = nextOrder()
    btn.Parent = parent
    corner(btn, 6)
    return btn
end

local function toggleButton(text, initial, callback, parent)
    local btn = makeButton("", parent)
    local isOn = initial
    local function refresh()
        btn.Text = text .. ": " .. (isOn and "ON" or "OFF")
        btn.TextColor3 = isOn and state.uiAccentColor or state.uiTextColor
    end
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        refresh()
        safe(callback, isOn)
        saveSettings()
    end)
    refresh()
    return btn
end

local function colorRow(callback, parent)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 22)
    row.BackgroundTransparency = 1
    row.LayoutOrder = nextOrder()
    row.Parent = parent
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = row
    for i, c in ipairs(palette) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 18, 0, 18)
        b.BackgroundColor3 = c
        b.BorderSizePixel = 0
        b.Text = ""
        b.AutoButtonColor = false
        b.LayoutOrder = i
        b.Parent = row
        corner(b, 9)
        b.MouseButton1Click:Connect(function() safe(callback, c); saveSettings() end)
    end
    return row
end

-- ================== COLLAPSIBLE SECTION ==================
local function collapsibleSection(title, parent, startOpen, onToggle)
    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, -4, 0, 26)
    headerBtn.BackgroundColor3 = state.uiButtonColor
    headerBtn.BorderSizePixel = 0
    headerBtn.TextXAlignment = Enum.TextXAlignment.Left
    headerBtn.Font = Enum.Font.GothamBold
    headerBtn.TextSize = 12
    headerBtn.TextColor3 = state.uiAccentColor
    headerBtn.AutoButtonColor = true
    headerBtn.LayoutOrder = nextOrder()
    headerBtn.Parent = parent
    corner(headerBtn, 6)

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = headerBtn

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -4, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.LayoutOrder = headerBtn.LayoutOrder
    container.Parent = parent

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.Padding = UDim.new(0, 6)
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    local containerPad = Instance.new("UIPadding")
    containerPad.PaddingLeft = UDim.new(0, 6)
    containerPad.PaddingRight = UDim.new(0, 2)
    containerPad.Parent = container

    local isOpen = startOpen and true or false

    local function refresh()
        headerBtn.Text = (isOpen and "▼ " or "▶ ") .. title
        container.Visible = isOpen
        if onToggle then onToggle(isOpen) end
    end

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        refresh()
        saveSettings()
    end)

    refresh()
    return headerBtn, container, function() return isOpen end
end

-- ================== ESP ==================
local espCache = {}
local function removeESP(player) if espCache[player] then espCache[player]:Destroy() end; espCache[player] = nil end
local function applyESP(player)
    if player == LocalPlayer then return end
    if espCache[player] and espCache[player].Parent then return end
    local char = player.Character; if not char then return end
    local h = Instance.new("Highlight")
    h.Name = "ESP_HL"; h.Adornee = char
    h.OutlineColor = state.espOutline; h.FillColor = state.espFill
    h.OutlineTransparency = state.espOutlineAlpha; h.FillTransparency = state.espFillAlpha
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = playerGui
    espCache[player] = h
end
local function clearESP() for p, h in pairs(espCache) do if h then h:Destroy() end; espCache[p] = nil end end
local function refreshESP()
    clearESP()
    if state.espEnabled then for _, p in ipairs(Players:GetPlayers()) do safe(applyESP, p) end end
end
local function updateESPColors()
    for _, h in pairs(espCache) do
        if h and h.Parent then
            h.OutlineColor = state.espOutline; h.FillColor = state.espFill
            h.OutlineTransparency = state.espOutlineAlpha; h.FillTransparency = state.espFillAlpha
        end
    end
end
local function watchPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function() task.wait(0.25); if state.espEnabled then safe(applyESP, p) end end)
    p.CharacterRemoving:Connect(function() removeESP(p) end)
end
for _, p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(removeESP)

-- ================== 3D AURAS ==================
local haloParts, spiralParts, stickParts, hStickParts = {}, {}, {}, {}
local function destroyHalo() for _, d in ipairs(haloParts) do if d.part then d.part:Destroy() end end; haloParts = {} end
local function destroySpiral() for _, d in ipairs(spiralParts) do if d.part then d.part:Destroy() end end; spiralParts = {} end
local function destroySticks() for _, d in ipairs(stickParts) do if d.part then d.part:Destroy() end end; stickParts = {} end
local function destroyHSticks() for _, d in ipairs(hStickParts) do if d.part then d.part:Destroy() end end; hStickParts = {} end

local function setHaloColor(c) state.haloColor = c; for _, d in ipairs(haloParts) do if d.part then d.part.Color = c end end end
local function setSpiralColor(c) state.spiralColor = c; for _, d in ipairs(spiralParts) do if d.part then d.part.Color = c end end end
local function setSticksColor(c) state.sticksColor = c; for _, d in ipairs(stickParts) do if d.part then d.part.Color = c end end end
local function setHSticksColor(c) state.hSticksColor = c; for _, d in ipairs(hStickParts) do if d.part then d.part.Color = c end end end

local function createHalo(character)
    destroyHalo()
    local head = character:FindFirstChild("Head"); if not head then return end

    local segments = 32
    local radius = 1.1
    local thickness = 0.18
    local segmentLength = (2 * math.pi * radius) / segments + 0.05

    for i = 1, segments do
        local p = Instance.new("Part")
        p.Name = "UtilityHalo"
        p.Size = Vector3.new(thickness, thickness, segmentLength)
        p.Material = Enum.Material.Neon
        p.Color = state.haloColor
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.Anchored = true
        p.CastShadow = false
        p.Parent = character
        haloParts[#haloParts+1] = {
            part = p,
            baseAngle = (i / segments) * math.pi * 2,
            radius = radius
        }
    end
end

local function createSpiral(character)
    destroySpiral()
    local root = character:FindFirstChild("HumanoidRootPart"); if not root then return end
    local segments = 10
    for ring = 1, 3 do
        local radius = 2.0 + ring * 0.3
        local yOffset = -0.5 + (ring - 2) * 1.2
        for i = 1, segments do
            local p = Instance.new("Part")
            p.Name = "UtilitySpiral"; p.Size = Vector3.new(0.25, 0.25, 0.25)
            p.Shape = Enum.PartType.Ball; p.Material = Enum.Material.Neon
            p.Color = state.spiralColor; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
            p.Anchored = true; p.Parent = character
            spiralParts[#spiralParts+1] = { part = p, baseAngle = (i / segments) * math.pi * 2, radius = radius, yOffset = yOffset, ringSpeed = (ring % 2 == 0) and 1.5 or -1.5 }
        end
    end
end

local function createSticks(character)
    destroySticks()
    local root = character:FindFirstChild("HumanoidRootPart"); if not root then return end
    local count = 6
    for i = 1, count do
        local p = Instance.new("Part")
        p.Name = "UtilityStick"; p.Size = Vector3.new(0.15, 0.15, 2.2)
        p.Material = Enum.Material.Neon; p.Color = state.sticksColor
        p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
        p.Anchored = true; p.Parent = character
        stickParts[#stickParts+1] = { part = p, baseAngle = (i / count) * math.pi * 2, radius = 2.6, yOffset = 0, tilt = (i % 2 == 0) and 1 or -1, speed = 2.0 }
    end
end

local function createHSticks(character)
    destroyHSticks()
    local root = character:FindFirstChild("HumanoidRootPart"); if not root then return end

    local count = 4
    local baseRadius = 2.2
    local R15_padding = 1.0

    for i = 1, count do
        local p = Instance.new("Part")
        p.Name = "UtilityHStick"
        p.Size = Vector3.new(0.15, 0.15, 2.2)
        p.Material = Enum.Material.Neon; p.Color = state.hSticksColor
        p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
        p.Anchored = true; p.CastShadow = false; p.Parent = character

        hStickParts[#hStickParts+1] = {
            part = p,
            baseAngle = (i / count) * math.pi * 2,
            radius = baseRadius + R15_padding + math.random() * 0.4,
            yOffset = (math.random() - 0.5) * 1.4,
            speed = 1.6 * (i % 2 == 0 and 1 or -1),
            wobbleSpeed = math.random() * 2 + 1,
            wobbleAmp = math.random() * 0.25
        }
    end
end

-- ================== ANIMATION ==================
local auraTime = 0
RunService.RenderStepped:Connect(function(dt)
    if not (state.haloEnabled or state.spiralEnabled or state.sticksEnabled or state.hSticksEnabled) then return end
    auraTime += dt

    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")

    if state.haloEnabled and head then
        local offsetY = 1.4 + math.sin(auraTime * 3) * 0.12
        local haloRotation = auraTime * 0.8
        local tilt = math.sin(auraTime * 1.5) * 0.15

        for _, data in ipairs(haloParts) do
            if data.part and data.part.Parent then
                local currentAngle = data.baseAngle + haloRotation

                local pos = head.Position + Vector3.new(
                    math.cos(currentAngle) * data.radius,
                    offsetY + math.sin(currentAngle) * tilt,
                    math.sin(currentAngle) * data.radius
                )

                local tangent = Vector3.new(-math.sin(currentAngle), 0, math.cos(currentAngle))
                local up = Vector3.new(0, 1, 0) + Vector3.new(
                    math.cos(currentAngle) * tilt * 0.5, 0, math.sin(currentAngle) * tilt * 0.5
                )
                data.part.CFrame = CFrame.lookAt(pos, pos + tangent, up)
            end
        end
    end

    if root then
        if state.spiralEnabled then
            for _, data in ipairs(spiralParts) do
                if data.part and data.part.Parent then
                    local currentAngle = data.baseAngle + (auraTime * data.ringSpeed)
                    local wobble = math.sin(auraTime * 2 + data.baseAngle) * 0.2
                    data.part.CFrame = CFrame.new(root.Position + Vector3.new(math.cos(currentAngle) * data.radius, data.yOffset + wobble, math.sin(currentAngle) * data.radius))
                end
            end
        end
        if state.sticksEnabled then
            for _, data in ipairs(stickParts) do
                if data.part and data.part.Parent then
                    local currentAngle = data.baseAngle + (auraTime * data.speed)
                    local bob = math.sin(auraTime * 2 + data.baseAngle) * 0.25
                    local pos = root.Position + Vector3.new(math.cos(currentAngle) * data.radius, data.yOffset + bob, math.sin(currentAngle) * data.radius)
                    local tangent = Vector3.new(-math.sin(currentAngle), 0, math.cos(currentAngle))
                    local up = Vector3.new(0, 1, 0) * data.tilt
                    data.part.CFrame = CFrame.lookAt(pos, pos + (tangent + up).Unit)
                end
            end
        end
        if state.hSticksEnabled then
            for _, data in ipairs(hStickParts) do
                if data.part and data.part.Parent then
                    local currentAngle = data.baseAngle + (auraTime * data.speed)
                    local wobbleY = math.sin(auraTime * data.wobbleSpeed + data.baseAngle) * data.wobbleAmp

                    local safeRadius = math.max(data.radius, 2.2)

                    local pos = root.Position + Vector3.new(
                        math.cos(currentAngle) * safeRadius,
                        data.yOffset + wobbleY,
                        math.sin(currentAngle) * safeRadius
                    )
                    local tangent = Vector3.new(-math.sin(currentAngle), 0, math.cos(currentAngle))
                    data.part.CFrame = CFrame.lookAt(pos, pos + tangent)
                end
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if state.haloEnabled then safe(createHalo, char) end
    if state.spiralEnabled then safe(createSpiral, char) end
    if state.sticksEnabled then safe(createSticks, char) end
    if state.hSticksEnabled then safe(createHSticks, char) end
    if state.espEnabled then safe(refreshESP) end
    if state.noclip then safe(setNoclip, true) end
end)

-- ================== NOCLIP ==================
local noclipConn
function setNoclip(on)
    state.noclip = on
    if on then
        if not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character; if not char then return end
                for _, p in ipairs(char:GetChildren()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end)
        end
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end

-- ================== ANTI-AFK ==================
local antiAfkConnection
local function setAntiAfk(on)
    state.antiAfk = on
    if on then
        if not antiAfkConnection then
            antiAfkConnection = task.spawn(function()
                while state.antiAfk do
                    task.wait(60)
                    if state.antiAfk and LocalPlayer then
                        pcall(function()
                            VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("Humanoid") then char.Humanoid.Jump = true end
                        end)
                    end
                end
            end)
        end
    else
        if antiAfkConnection then task.cancel(antiAfkConnection); antiAfkConnection = nil end
    end
end

-- ================== TELEPORT ==================
local function teleportTo(player)
    if not player or not player.Character then return end
    local char = LocalPlayer.Character; if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    local theirRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and theirRoot then myRoot.CFrame = theirRoot.CFrame * CFrame.new(0, 0, 3) end
end

-- ================== ORBIT PLAYER ==================
local orbitConn = nil
local orbitAngle = 0
local orbitTargetPlayer = nil
local orbitRunning = false

local function findPlayerByName(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == name:lower() then return p end
    end
    return nil
end

local function stopOrbit()
    if orbitConn then orbitConn:Disconnect(); orbitConn = nil end
    orbitTargetPlayer = nil
    state.orbitEnabled = false
end

local function startOrbit(targetName)
    stopOrbit()
    orbitTargetPlayer = (targetName ~= "") and findPlayerByName(targetName) or nil

    if targetName ~= "" and not orbitTargetPlayer then
        warn("[Utility] Orbit target not found: " .. targetName)
        return
    end

    state.orbitEnabled = true
    orbitAngle = 0

    orbitConn = RunService.Heartbeat:Connect(function(dt)
        if not state.orbitEnabled then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        if orbitTargetPlayer then
            if not orbitTargetPlayer.Character then stopOrbit(); return end
            local tRoot = orbitTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not tRoot then stopOrbit(); return end

            orbitAngle += dt * state.orbitSpeed
            local center = tRoot.Position
            local newPos = center + Vector3.new(
                math.cos(orbitAngle) * state.orbitRadius,
                3,
                math.sin(orbitAngle) * state.orbitRadius
            )
            myRoot.CFrame = CFrame.lookAt(newPos, center)
        else
            orbitAngle += dt * state.orbitSpeed
            local center = myRoot.Position
            local newPos = center + Vector3.new(
                math.cos(orbitAngle) * state.orbitRadius,
                0,
                math.sin(orbitAngle) * state.orbitRadius
            )
            myRoot.CFrame = CFrame.lookAt(newPos, center)
        end
    end)
end

-- ================== REJOIN ==================
local function rejoinServer()
    local placeId = game.PlaceId; local jobId = game.JobId
    if jobId and jobId ~= "" then
        local success, err = pcall(function() TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer) end)
        if not success then pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end) end
    else
        pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
    end
end

-- ================== SKY & FOG (Space lighter + Gray Fog) ==================
local function applySky(mode)
    state.skyMode = mode
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj.Name == "UtilityAtmosphere" or obj.Name == "UtilityColorCorrection"
        or obj.Name == "UtilitySky" or obj.Name == "UtilityBloom" or obj.Name == "UtilityGrayFog" then obj:Destroy() end
    end
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if sky and sky.Name == "UtilitySky" then sky:Destroy() end

    if mode == "Default" then
        Lighting.ClockTime = 14; Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
    elseif mode == "Day" then
        Lighting.ClockTime = 12; Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        Lighting.Ambient = Color3.fromRGB(90, 90, 90)
    elseif mode == "Night" then
        Lighting.ClockTime = 0; Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 50)
        Lighting.Ambient = Color3.fromRGB(20, 20, 35)
    elseif mode == "Sunset" then
        Lighting.ClockTime = 18; Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 100, 80)
        Lighting.Ambient = Color3.fromRGB(90, 60, 50)
    elseif mode == "Space" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 1.2
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 80, 130)
        Lighting.Ambient = Color3.fromRGB(40, 45, 80)
        Lighting.EnvironmentDiffuseScale = 0.4
        Lighting.EnvironmentSpecularScale = 0.4

        local atm = Instance.new("Atmosphere")
        atm.Name = "UtilityAtmosphere"
        atm.Density = 0.25
        atm.Offset = 0.1
        atm.Color = Color3.fromRGB(80, 90, 140)
        atm.Decay = Color3.fromRGB(120, 130, 180)
        atm.Glare = 0.2
        atm.Haze = 1.5
        atm.Parent = Lighting

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "UtilityColorCorrection"
        cc.TintColor = state.skyColor
        cc.Brightness = 0.15
        cc.Contrast = 0.05
        cc.Saturation = 0.1
        cc.Parent = Lighting

        local bloom = Instance.new("BloomEffect")
        bloom.Name = "UtilityBloom"
        bloom.Intensity = 0.4
        bloom.Size = 24
        bloom.Threshold = 1.2
        bloom.Parent = Lighting

        local starSky = Instance.new("Sky")
        starSky.Name = "UtilitySky"
        starSky.SkyboxBk = "rbxassetid://159454299"
        starSky.SkyboxDn = "rbxassetid://159454296"
        starSky.SkyboxFt = "rbxassetid://159454293"
        starSky.SkyboxLf = "rbxassetid://159454286"
        starSky.SkyboxRt = "rbxassetid://159454300"
        starSky.SkyboxUp = "rbxassetid://159454288"
        starSky.StarCount = 5000
        starSky.CelestialBodiesShown = true
        starSky.MoonAngularSize = 11
        starSky.SunAngularSize = 11
        starSky.Parent = Lighting
    end
    
    -- Восстанавливаем туман, если он был включен
    if state.grayFogEnabled then setGrayFog(true) end
    
    saveSettings()
end

-- === ДОБАВЛЕНО: ФУНКЦИЯ СЕРОГО ТУМАНА ===
function setGrayFog(on)
    state.grayFogEnabled = on
    local existing = Lighting:FindFirstChild("UtilityGrayFog")
    if existing then existing:Destroy() end

    if on then
        local fog = Instance.new("Atmosphere")
        fog.Name = "UtilityGrayFog"
        fog.Density = 0.35          -- Плотность тумана (от 0 до 1)
        fog.Offset = 0.2
        fog.Color = Color3.fromRGB(120, 120, 120) -- Серый цвет
        fog.Decay = Color3.fromRGB(80, 80, 80)
        fog.Glare = 0.1
        fog.Haze = 2.5
        fog.Parent = Lighting
    end
    saveSettings()
end

local function applySkyColor(c)
    state.skyColor = c
    if state.skyMode == "Space" then applySky("Space") else Lighting.OutdoorAmbient = c; saveSettings() end
end

-- ================== RADAR (minimap) ==================
local RADAR_SIZE = 180
local RADAR_RANGE = 120

local radarFrame = Instance.new("Frame")
radarFrame.Name = "UtilityRadar"
radarFrame.Size = UDim2.new(0, RADAR_SIZE, 0, RADAR_SIZE)
radarFrame.Position = UDim2.new(0, 20, 1, -RADAR_SIZE - 20)
radarFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
radarFrame.BackgroundTransparency = 0.15
radarFrame.BorderSizePixel = 0
radarFrame.Visible = state.radarVisible
radarFrame.Active = true
radarFrame.Parent = gui
corner(radarFrame, 14)

local radarStroke = Instance.new("UIStroke")
radarStroke.Color = state.uiAccentColor
radarStroke.Thickness = 1.5
radarStroke.Transparency = 0.2
radarStroke.Parent = radarFrame

-- Заголовок
local radarTitle = Instance.new("TextLabel")
radarTitle.Size = UDim2.new(1, 0, 0, 22)
radarTitle.Position = UDim2.new(0, 0, 0, 4)
radarTitle.BackgroundTransparency = 1
radarTitle.Text = "RADAR"
radarTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
radarTitle.Font = Enum.Font.GothamBold
radarTitle.TextSize = 12
radarTitle.Parent = radarFrame

-- Контейнер для точек (обрезаем по кругу)
local radarClip = Instance.new("Frame")
radarClip.Size = UDim2.new(1, -20, 1, -40)
radarClip.Position = UDim2.new(0, 10, 0, 28)
radarClip.BackgroundTransparency = 1
radarClip.ClipsDescendants = true
radarClip.Parent = radarFrame

-- Внешний круг (граница)
local outerCircle = Instance.new("Frame")
outerCircle.Size = UDim2.new(1, 0, 1, 0)
outerCircle.Position = UDim2.new(0, 0, 0, 0)
outerCircle.BackgroundTransparency = 1
outerCircle.Parent = radarClip
corner(outerCircle, 9999)
local outerCircleStroke = Instance.new("UIStroke")
outerCircleStroke.Color = Color3.fromRGB(60, 60, 80)
outerCircleStroke.Thickness = 1
outerCircleStroke.Transparency = 0.3
outerCircleStroke.Parent = outerCircle

-- Внутренний круг (половина радиуса)
local innerCircle = Instance.new("Frame")
innerCircle.Size = UDim2.new(0.5, 0, 0.5, 0)
innerCircle.Position = UDim2.new(0.25, 0, 0.25, 0)
innerCircle.BackgroundTransparency = 1
innerCircle.Parent = radarClip
corner(innerCircle, 9999)
local innerCircleStroke = Instance.new("UIStroke")
innerCircleStroke.Color = Color3.fromRGB(60, 60, 80)
innerCircleStroke.Thickness = 1
innerCircleStroke.Transparency = 0.5
innerCircleStroke.Parent = innerCircle

-- Точка игрока (центр)
local playerDot = Instance.new("Frame")
playerDot.Size = UDim2.new(0, 8, 0, 8)
playerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
playerDot.BackgroundColor3 = Color3.fromRGB(60, 255, 100)
playerDot.BorderSizePixel = 0
playerDot.Parent = radarClip
corner(playerDot, 4)

-- Контейнер для точек игроков
local enemyContainer = Instance.new("Frame")
enemyContainer.Size = UDim2.new(1, 0, 1, 0)
enemyContainer.BackgroundTransparency = 1
enemyContainer.Parent = radarClip

local radarDots = {}

-- Кнопка скрыть/показать радар
local radarToggle = Instance.new("TextButton")
radarToggle.Size = UDim2.new(0, 26, 0, 26)
radarToggle.Position = UDim2.new(1, -32, 0, 6)
radarToggle.BackgroundColor3 = state.uiButtonColor
radarToggle.BorderSizePixel = 0
radarToggle.Text = "×"
radarToggle.TextColor3 = state.uiTextColor
radarToggle.Font = Enum.Font.GothamBold
radarToggle.TextSize = 16
radarToggle.ZIndex = 5
radarToggle.Parent = radarFrame
corner(radarToggle, 6)

radarToggle.MouseButton1Click:Connect(function()
    state.radarVisible = not state.radarVisible
    radarFrame.Visible = state.radarVisible
    saveSettings()
end)

-- Кнопка "показать радар" (если скрыт)
local radarShowBtn = Instance.new("TextButton")
radarShowBtn.Size = UDim2.new(0, 40, 0, 40)
radarShowBtn.Position = UDim2.new(0, 20, 1, -60)
radarShowBtn.BackgroundColor3 = state.uiBgColor
radarShowBtn.BackgroundTransparency = 0.2
radarShowBtn.BorderSizePixel = 0
radarShowBtn.Text = "R"
radarShowBtn.TextColor3 = state.uiAccentColor
radarShowBtn.Font = Enum.Font.GothamBold
radarShowBtn.TextSize = 16
radarShowBtn.Visible = not state.radarVisible
radarShowBtn.Parent = gui
corner(radarShowBtn, 20)
local showStroke = Instance.new("UIStroke")
showStroke.Color = state.uiAccentColor
showStroke.Thickness = 1.5
showStroke.Transparency = 0.2
showStroke.Parent = radarShowBtn

radarShowBtn.MouseButton1Click:Connect(function()
    state.radarVisible = true
    radarFrame.Visible = true
    radarShowBtn.Visible = false
    saveSettings()
end)

-- Функция обновления радара
local function updateRadar()
    if not state.radarVisible then
        radarShowBtn.Visible = true
        return
    end
    radarShowBtn.Visible = false
    radarStroke.Color = state.uiAccentColor

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- Направление взгляда (в плоскости XZ)
    local look = myRoot.CFrame.LookVector
    local lookFlat = Vector3.new(look.X, 0, look.Z)
    if lookFlat.Magnitude < 0.01 then return end
    lookFlat = lookFlat.Unit

    -- Перпендикуляр (вправо)
    local rightFlat = Vector3.new(lookFlat.Z, 0, -lookFlat.X) -- или -lookFlat.Z?

    -- Удаляем мёртвые точки
    for _, dot in pairs(radarDots) do
        if not dot.frame or not dot.frame.Parent then
            dot.frame = nil
        end
    end

    local activePlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            activePlayers[p] = true
            local tRoot = p.Character.HumanoidRootPart
            local rel = tRoot.Position - myRoot.Position
            local relFlat = Vector3.new(rel.X, 0, rel.Z)

            -- Проекция на направление взгляда (вперёд) и вправо
            local forward = relFlat:Dot(lookFlat)
            local right = relFlat:Dot(rightFlat)

            -- Масштабируем в радиус радара
            local scale = (RADAR_SIZE - 40) / 2 / RADAR_RANGE
            local px = right * scale
            local py = -forward * scale -- вперёд = вверх на радаре

            -- Скрываем если вне круга
            local dist = math.sqrt(px*px + py*py)
            local maxDist = (RADAR_SIZE - 40) / 2
            if dist > maxDist then
                if radarDots[p] and radarDots[p].frame then
                    radarDots[p].frame.Visible = false
                end
            else
                local dot = radarDots[p]
                if not dot then
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(0, 7, 0, 7)
                    frame.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
                    frame.BorderSizePixel = 0
                    frame.AnchorPoint = Vector2.new(0.5, 0.5)
                    frame.Parent = enemyContainer
                    corner(frame, 4)
                    local dotStroke = Instance.new("UIStroke")
                    dotStroke.Color = Color3.fromRGB(0, 0, 0)
                    dotStroke.Thickness = 1
                    dotStroke.Transparency = 0.5
                    dotStroke.Parent = frame
                    radarDots[p] = { frame = frame, stroke = dotStroke }
                end
                local f = radarDots[p].frame
                f.Visible = true
                f.Position = UDim2.new(0.5, px, 0.5, py)
            end
        end
    end

    -- Удаляем точки для вышедших игроков
    for p, dot in pairs(radarDots) do
        if not activePlayers[p] then
            if dot.frame then dot.frame:Destroy() end
            radarDots[p] = nil
        end
    end
end

-- Запуск обновления радара каждый кадр
RunService.RenderStepped:Connect(updateRadar)

-- ================== UI COLORS ==================
local function updateUIColors()
    main.BackgroundColor3 = state.uiBgColor
    stroke.Color = state.uiAccentColor
    header.BackgroundColor3 = state.uiHeaderColor
    headerLabel.TextColor3 = state.uiAccentColor
    leftBtn.BackgroundColor3 = state.uiButtonColor
    rightBtn.BackgroundColor3 = state.uiButtonColor
    tabTitle.TextColor3 = state.uiTextColor
    
    for _, dot in ipairs(dots) do
        if dot.BackgroundColor3 ~= state.uiAccentColor then
            dot.BackgroundColor3 = state.uiButtonColor
        end
    end

    radarStroke.Color = state.uiAccentColor
    radarToggle.BackgroundColor3 = state.uiButtonColor
    radarToggle.TextColor3 = state.uiTextColor
    radarShowBtn.BackgroundColor3 = state.uiBgColor
    radarShowBtn.TextColor3 = state.uiAccentColor
    showStroke.Color = state.uiAccentColor

    for _, page in ipairs(pages) do
        page.ScrollBarImageColor3 = state.uiAccentColor
        for _, child in ipairs(page:GetChildren()) do
            if child:IsA("TextLabel") and child.Text ~= "" then 
                child.TextColor3 = state.uiAccentColor
            elseif child:IsA("TextButton") then
                if child.Text:find("ON") then 
                    child.TextColor3 = state.uiAccentColor 
                else 
                    child.TextColor3 = state.uiTextColor 
                end
                child.BackgroundColor3 = state.uiButtonColor
            end
        end
    end
end

-- ================== BUILD PAGES ==================
-- PAGE 1: ESP & Auras
sectionLabel("ESP", page1)
toggleButton("ESP", state.espEnabled, function(on) state.espEnabled = on; refreshESP() end, page1)
sectionLabel("ESP Outline Color", page1)
colorRow(function(c) state.espOutline = c; updateESPColors() end, page1)
sectionLabel("ESP Fill Color", page1)
colorRow(function(c) state.espFill = c; updateESPColors() end, page1)

sectionLabel("3D Auras", page1)
toggleButton("Halo", state.haloEnabled, function(on)
    state.haloEnabled = on
    if on then if LocalPlayer.Character then safe(createHalo, LocalPlayer.Character) end else destroyHalo() end
end, page1)
colorRow(function(c) setHaloColor(c) end, page1)

toggleButton("Spirals", state.spiralEnabled, function(on)
    state.spiralEnabled = on
    if on then if LocalPlayer.Character then safe(createSpiral, LocalPlayer.Character) end else destroySpiral() end
end, page1)
colorRow(function(c) setSpiralColor(c) end, page1)

toggleButton("Sticks", state.sticksEnabled, function(on)
    state.sticksEnabled = on
    if on then if LocalPlayer.Character then safe(createSticks, LocalPlayer.Character) end else destroySticks() end
end, page1)
colorRow(function(c) setSticksColor(c) end, page1)

toggleButton("Horizontal Sticks", state.hSticksEnabled, function(on)
    state.hSticksEnabled = on
    if on then if LocalPlayer.Character then safe(createHSticks, LocalPlayer.Character) end else destroyHSticks() end
end, page1)
colorRow(function(c) setHSticksColor(c) end, page1)

-- ================== QUICK ACTIONS (PAGE 1) ==================
sectionLabel("Quick Actions", page1)
local orbitQuickBtn = makeButton("", page1)
local function refreshOrbitQuickBtn()
    orbitQuickBtn.Text = "Orbit Player: " .. (orbitRunning and "ON" or "OFF") .. "  [O]"
    orbitQuickBtn.TextColor3 = orbitRunning and state.uiAccentColor or state.uiTextColor
    orbitQuickBtn.BackgroundColor3 = orbitRunning and Color3.fromRGB(30, 55, 35) or state.uiButtonColor
end
refreshOrbitQuickBtn()

orbitQuickBtn.MouseButton1Click:Connect(function()
    orbitRunning = not orbitRunning
    if orbitRunning then
        startOrbit(state.orbitTarget or "")
    else
        stopOrbit()
    end
    refreshOrbitQuickBtn()
    if _G.UtilityRefreshOrbitBtn then _G.UtilityRefreshOrbitBtn() end
    saveSettings()
end)
_G.UtilityRefreshOrbitQuickBtn = refreshOrbitQuickBtn

-- PAGE 2: Utilities & Sky
sectionLabel("Movement", page2)
toggleButton("Noclip", state.noclip, function(on) setNoclip(on) end, page2)

sectionLabel("Utilities", page2)
toggleButton("Anti-AFK", state.antiAfk, function(on) setAntiAfk(on) end, page2)
toggleButton("Gray Fog", state.grayFogEnabled, function(on) setGrayFog(on) end, page2) -- ДОБАВЛЕНО: Кнопка тумана

sectionLabel("Sky & Time", page2)
local skyButtons = {
    {"Day", "Day"}, {"Night", "Night"}, {"Sunset", "Sunset"},
    {"Space", "Space"}, {"Default", "Default"}
}
for _, data in ipairs(skyButtons) do
    local b = makeButton(data[1], page2)
    b.MouseButton1Click:Connect(function() applySky(data[2]) end)
end
sectionLabel("Sky / Atmosphere Color", page2)
colorRow(function(c) applySkyColor(c) end, page2)

-- PAGE 3: Players & UI
-- ===== Сворачиваемый список игроков (TP) =====
local _, tpContainer = collapsibleSection("Players (TP)", page3, state.uiPlayersOpen, function(open)
    state.uiPlayersOpen = open
end)

local refreshBtn = makeButton("Refresh List", tpContainer)
local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(1, 0, 0, 0)
playerListFrame.AutomaticSize = Enum.AutomaticSize.Y
playerListFrame.BackgroundTransparency = 1
playerListFrame.LayoutOrder = nextOrder()
playerListFrame.Parent = tpContainer
local plLayout = Instance.new("UIListLayout")
plLayout.Padding = UDim.new(0, 4); plLayout.SortOrder = Enum.SortOrder.LayoutOrder
plLayout.Parent = playerListFrame

local function refreshPlayerList()
    for _, child in ipairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for i, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 28); b.BackgroundColor3 = state.uiButtonColor
            b.BorderSizePixel = 0; b.Text = "TP → " .. p.Name
            b.TextColor3 = state.uiTextColor; b.Font = Enum.Font.Gotham; b.TextSize = 12
            b.AutoButtonColor = true; b.LayoutOrder = i; b.Parent = playerListFrame
            corner(b, 6)
            b.MouseButton1Click:Connect(function() safe(teleportTo, p) end)
        end
    end
end

refreshBtn.MouseButton1Click:Connect(refreshPlayerList)
safe(refreshPlayerList)
Players.PlayerAdded:Connect(function() task.wait(0.2) safe(refreshPlayerList) end)
Players.PlayerRemoving:Connect(function() task.wait(0.2) safe(refreshPlayerList) end)

sectionLabel("Server", page3)
local rejoinBtn = makeButton("Rejoin Server", page3)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 40)
rejoinBtn.MouseButton1Click:Connect(rejoinServer)

sectionLabel("UI Customization", page3)
sectionLabel("Menu Background", page3)
colorRow(function(c) state.uiBgColor = c; updateUIColors() end, page3)
sectionLabel("Accent Color", page3)
colorRow(function(c) state.uiAccentColor = c; updateUIColors() end, page3)

-- ===== Сворачиваемая секция Orbit Player =====
local _, orbitContainer = collapsibleSection("Orbit Player", page3, state.uiOrbitOpen, function(open)
    state.uiOrbitOpen = open
end)

local targetBox = Instance.new("TextBox")
targetBox.Size = UDim2.new(1, 0, 0, 30)
targetBox.BackgroundColor3 = state.uiButtonColor
targetBox.BorderSizePixel = 0
targetBox.PlaceholderText = "Target player name (пусто = вокруг себя)"
targetBox.Text = state.orbitTarget or ""
targetBox.TextColor3 = state.uiTextColor
targetBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
targetBox.Font = Enum.Font.Gotham
targetBox.TextSize = 12
targetBox.ClearTextOnFocus = false
targetBox.LayoutOrder = nextOrder()
targetBox.Parent = orbitContainer
corner(targetBox, 6)

targetBox.FocusLost:Connect(function()
    state.orbitTarget = targetBox.Text
    saveSettings()
end)

local orbitTargetsFrame = Instance.new("Frame")
orbitTargetsFrame.Size = UDim2.new(1, 0, 0, 0)
orbitTargetsFrame.AutomaticSize = Enum.AutomaticSize.Y
orbitTargetsFrame.BackgroundTransparency = 1
orbitTargetsFrame.LayoutOrder = nextOrder()
orbitTargetsFrame.Parent = orbitContainer
local otLayout = Instance.new("UIListLayout")
otLayout.Padding = UDim.new(0, 4); otLayout.SortOrder = Enum.SortOrder.LayoutOrder
otLayout.Parent = orbitTargetsFrame

local function refreshOrbitTargets()
    for _, child in ipairs(orbitTargetsFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local sel = (state.orbitTarget or ""):lower()
    for i, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local isSel = (p.Name:lower() == sel)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 26)
            b.BackgroundColor3 = isSel and Color3.fromRGB(30, 60, 40) or state.uiButtonColor
            b.BorderSizePixel = 0
            b.Text = (isSel and "★ " or "○ ") .. p.Name
            b.TextColor3 = isSel and state.uiAccentColor or state.uiTextColor
            b.Font = Enum.Font.Gotham; b.TextSize = 12
            b.AutoButtonColor = true; b.LayoutOrder = i; b.Parent = orbitTargetsFrame
            corner(b, 6)
            b.MouseButton1Click:Connect(function()
                state.orbitTarget = p.Name
                targetBox.Text = p.Name
                saveSettings()
                refreshOrbitTargets()
                if orbitRunning then startOrbit(p.Name) end
            end)
        end
    end
end

local orbitBtn = makeButton("", orbitContainer)
local function refreshOrbitBtn()
    orbitBtn.Text = "Orbit: " .. (orbitRunning and "ON" or "OFF")
    orbitBtn.TextColor3 = orbitRunning and state.uiAccentColor or state.uiTextColor
end
refreshOrbitBtn()
_G.UtilityRefreshOrbitBtn = refreshOrbitBtn

orbitBtn.MouseButton1Click:Connect(function()
    orbitRunning = not orbitRunning
    if orbitRunning then
        startOrbit(state.orbitTarget or "")
    else
        stopOrbit()
    end
    refreshOrbitBtn()
    if _G.UtilityRefreshOrbitQuickBtn then _G.UtilityRefreshOrbitQuickBtn() end
    saveSettings()
end)

local quickOrbitBtn = makeButton("Quick Orbit → Nearest", orbitContainer)
quickOrbitBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
quickOrbitBtn.MouseButton1Click:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position
    local nearest, nearestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
            if d < nearestDist then nearest, nearestDist = p, d end
        end
    end
    if nearest then
        targetBox.Text = nearest.Name
        state.orbitTarget = nearest.Name
        if not orbitRunning then
            orbitRunning = true
            startOrbit(nearest.Name)
            refreshOrbitBtn()
            if _G.UtilityRefreshOrbitQuickBtn then _G.UtilityRefreshOrbitQuickBtn() end
        else
            startOrbit(nearest.Name)
        end
        refreshOrbitTargets()
        saveSettings()
    end
end)

local speedLbl = Instance.new("TextLabel")
speedLbl.Size = UDim2.new(1, 0, 0, 16)
speedLbl.BackgroundTransparency = 1
speedLbl.Text = "Speed (0.5-20)"
speedLbl.TextColor3 = state.uiAccentColor
speedLbl.Font = Enum.Font.Gotham
speedLbl.TextSize = 11
speedLbl.TextXAlignment = Enum.TextXAlignment.Left
speedLbl.LayoutOrder = nextOrder()
speedLbl.Parent = orbitContainer

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, 0, 0, 28)
speedBox.BackgroundColor3 = state.uiButtonColor
speedBox.BorderSizePixel = 0
speedBox.Text = tostring(state.orbitSpeed)
speedBox.TextColor3 = state.uiTextColor
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 13
speedBox.LayoutOrder = nextOrder()
speedBox.Parent = orbitContainer
corner(speedBox, 6)
speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text)
    if n and n >= 0.5 and n <= 20 then
        state.orbitSpeed = n
    else
        speedBox.Text = tostring(state.orbitSpeed)
    end
    saveSettings()
end)

local radiusLbl = Instance.new("TextLabel")
radiusLbl.Size = UDim2.new(1, 0, 0, 16)
radiusLbl.BackgroundTransparency = 1
radiusLbl.Text = "Radius (2-20)"
radiusLbl.TextColor3 = state.uiAccentColor
radiusLbl.Font = Enum.Font.Gotham
radiusLbl.TextSize = 11
radiusLbl.TextXAlignment = Enum.TextXAlignment.Left
radiusLbl.LayoutOrder = nextOrder()
radiusLbl.Parent = orbitContainer

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(1, 0, 0, 28)
radiusBox.BackgroundColor3 = state.uiButtonColor
radiusBox.BorderSizePixel = 0
radiusBox.Text = tostring(state.orbitRadius)
radiusBox.TextColor3 = state.uiTextColor
radiusBox.Font = Enum.Font.Gotham
radiusBox.TextSize = 13
radiusBox.LayoutOrder = nextOrder()
radiusBox.Parent = orbitContainer
corner(radiusBox, 6)
radiusBox.FocusLost:Connect(function()
    local n = tonumber(radiusBox.Text)
    if n and n >= 2 and n <= 20 then
        state.orbitRadius = n
    else
        radiusBox.Text = tostring(state.orbitRadius)
    end
    saveSettings()
end)

safe(refreshOrbitTargets)
Players.PlayerAdded:Connect(function() task.wait(0.2) safe(refreshOrbitTargets) end)
Players.PlayerRemoving:Connect(function() task.wait(0.2) safe(refreshOrbitTargets) end)

sectionLabel("Settings", page3)
local resetBtn = makeButton("Reset Settings", page3)
resetBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
resetBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
resetBtn.MouseButton1Click:Connect(function()
    state = {}
    for k, v in pairs(defaultState) do state[k] = v end
    stopOrbit()
    saveSettings(); gui:Destroy()
end)

-- ================== INIT ==================
updateTabs()

task.spawn(function()
    task.wait(1)
    if state.espEnabled then refreshESP() end
    if state.haloEnabled and LocalPlayer.Character then safe(createHalo, LocalPlayer.Character) end
    if state.spiralEnabled and LocalPlayer.Character then safe(createSpiral, LocalPlayer.Character) end
    if state.sticksEnabled and LocalPlayer.Character then safe(createSticks, LocalPlayer.Character) end
    if state.hSticksEnabled and LocalPlayer.Character then safe(createHSticks, LocalPlayer.Character) end
    if state.noclip then setNoclip(true) end
    if state.antiAfk then setAntiAfk(true) end
    if state.skyMode then applySky(state.skyMode) end
    if state.grayFogEnabled then setGrayFog(true) end -- ДОБАВЛЕНО: Применяем туман при загрузке
    updateUIColors()
end)

-- ================== K + O + Drag ==================
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.K then main.Visible = not main.Visible end
    if input.KeyCode == Enum.KeyCode.O then
        orbitRunning = not orbitRunning
        if orbitRunning then
            startOrbit(state.orbitTarget or "")
        else
            stopOrbit()
        end
        if _G.UtilityRefreshOrbitBtn then _G.UtilityRefreshOrbitBtn() end
        if _G.UtilityRefreshOrbitQuickBtn then _G.UtilityRefreshOrbitQuickBtn() end
        saveSettings()
    end
end)

local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
