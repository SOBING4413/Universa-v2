-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- STATE
local State = {
    GuiVisible = true,
    ActivePanel = "features",
    FlyEnabled = false,
    InfiniteJumpEnabled = false,
    GodModeEnabled = false,
    ESPEnabled = false,
    InvisibleEnabled = false,
    NoclipEnabled = false,
    PlayerSpeed = 16,
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    CurrentTheme = 1,
}

-- Track themed elements for LIVE theme switching
local ThemedElements = {}

-- THEMES
local Themes = {
    {
        Name = "Cyberpunk Neon",
        Primary = Color3.fromHex("#00f0ff"),
        Secondary = Color3.fromHex("#ff00aa"),
        Accent = Color3.fromHex("#7b2dff"),
        Background = Color3.fromHex("#0a0a0f"),
        Surface = Color3.fromHex("#111118"),
        SurfaceHover = Color3.fromHex("#1a1a25"),
        Border = Color3.fromHex("#1e1e30"),
        Text = Color3.fromHex("#e0e0ff"),
        TextSecondary = Color3.fromHex("#8888aa"),
        Success = Color3.fromHex("#00ff88"),
    },
    {
        Name = "Matrix Green",
        Primary = Color3.fromHex("#00ff41"),
        Secondary = Color3.fromHex("#00cc33"),
        Accent = Color3.fromHex("#33ff77"),
        Background = Color3.fromHex("#0a0f0a"),
        Surface = Color3.fromHex("#0d150d"),
        SurfaceHover = Color3.fromHex("#142014"),
        Border = Color3.fromHex("#1a2e1a"),
        Text = Color3.fromHex("#c0ffc0"),
        TextSecondary = Color3.fromHex("#66aa66"),
        Success = Color3.fromHex("#00ff88"),
    },
    {
        Name = "Synthwave Purple",
        Primary = Color3.fromHex("#b347ea"),
        Secondary = Color3.fromHex("#ff6b35"),
        Accent = Color3.fromHex("#ff2975"),
        Background = Color3.fromHex("#0f0a14"),
        Surface = Color3.fromHex("#15101c"),
        SurfaceHover = Color3.fromHex("#201828"),
        Border = Color3.fromHex("#2a1e3a"),
        Text = Color3.fromHex("#e0d0ff"),
        TextSecondary = Color3.fromHex("#9977bb"),
        Success = Color3.fromHex("#00ff88"),
    },
    {
        Name = "Ice Blue",
        Primary = Color3.fromHex("#4dc9f6"),
        Secondary = Color3.fromHex("#a0e4ff"),
        Accent = Color3.fromHex("#0099cc"),
        Background = Color3.fromHex("#080c10"),
        Surface = Color3.fromHex("#0c1218"),
        SurfaceHover = Color3.fromHex("#141e28"),
        Border = Color3.fromHex("#1a2a3a"),
        Text = Color3.fromHex("#d0e8ff"),
        TextSecondary = Color3.fromHex("#7799bb"),
        Success = Color3.fromHex("#00ff88"),
    },
    {
        Name = "Blood Red",
        Primary = Color3.fromHex("#ff3355"),
        Secondary = Color3.fromHex("#ff0044"),
        Accent = Color3.fromHex("#cc0033"),
        Background = Color3.fromHex("#0f0a0a"),
        Surface = Color3.fromHex("#180d0d"),
        SurfaceHover = Color3.fromHex("#251515"),
        Border = Color3.fromHex("#3a1a1a"),
        Text = Color3.fromHex("#ffd0d0"),
        TextSecondary = Color3.fromHex("#aa6666"),
        Success = Color3.fromHex("#00ff88"),
    },
}

local function GetTheme()
    return Themes[State.CurrentTheme]
end

-- UTILITIES
local function Tween(obj, props, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

-- [FIX] CreateStroke: reuse existing UIStroke to prevent duplicates
local function CreateStroke(parent, color, thickness, transparency)
    local existing = parent:FindFirstChildOfClass("UIStroke")
    if existing then
        existing.Color = color or GetTheme().Border
        existing.Thickness = thickness or 1
        existing.Transparency = transparency or 0
        return existing
    end
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or GetTheme().Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, top, right, bottom, left)
    local existing = parent:FindFirstChildOfClass("UIPadding")
    if existing then
        existing.PaddingTop = UDim.new(0, top or 8)
        existing.PaddingRight = UDim.new(0, right or 8)
        existing.PaddingBottom = UDim.new(0, bottom or 8)
        existing.PaddingLeft = UDim.new(0, left or 8)
        return existing
    end
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 8)
    padding.PaddingRight = UDim.new(0, right or 8)
    padding.PaddingBottom = UDim.new(0, bottom or 8)
    padding.PaddingLeft = UDim.new(0, left or 8)
    padding.Parent = parent
    return padding
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "UNIVERSAL v2",
            Text = text or "",
            Duration = duration or 3,
        })
    end)
end

-- Register element for live theme switching
local function RegisterThemed(obj, propMap)
    table.insert(ThemedElements, {Object = obj, Properties = propMap})
end

-- [FIX] Apply theme to ALL registered elements (live switching)
local function ApplyThemeToAll()
    local theme = GetTheme()
    for _, entry in ipairs(ThemedElements) do
        if entry.Object and entry.Object.Parent then
            for prop, themeKey in pairs(entry.Properties) do
                pcall(function()
                    local targetColor = theme[themeKey]
                    if targetColor then
                        Tween(entry.Object, {[prop] = targetColor}, 0.4)
                    end
                end)
            end
        end
    end
end

-- DESTROY EXISTING GUI
pcall(function()
    if game:GetService("CoreGui"):FindFirstChild("UniversalV2") then
        game:GetService("CoreGui"):FindFirstChild("UniversalV2"):Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("ExterESP") then
        game:GetService("CoreGui"):FindFirstChild("ExterESP"):Destroy()
    end
end)

-- CREATE MAIN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 780, 0, 500)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = GetTheme().Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
CreateCorner(MainFrame, 14)
local mainStroke = CreateStroke(MainFrame, GetTheme().Primary, 1, 0.5)
RegisterThemed(MainFrame, {BackgroundColor3 = "Background"})
RegisterThemed(mainStroke, {Color = "Primary"})

-- Draggable
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Scan line
local ScanLine = Instance.new("Frame")
ScanLine.Name = "ScanLine"
ScanLine.Size = UDim2.new(1, 0, 0, 2)
ScanLine.Position = UDim2.new(0, 0, 0, 0)
ScanLine.BackgroundColor3 = GetTheme().Primary
ScanLine.BackgroundTransparency = 0.85
ScanLine.BorderSizePixel = 0
ScanLine.ZIndex = 100
ScanLine.Parent = MainFrame
RegisterThemed(ScanLine, {BackgroundColor3 = "Primary"})

spawn(function()
    while MainFrame and MainFrame.Parent do
        Tween(ScanLine, {Position = UDim2.new(0, 0, 1, 0)}, 3, Enum.EasingStyle.Linear)
        wait(3)
        ScanLine.Position = UDim2.new(0, 0, 0, 0)
    end
end)

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 190, 1, 0)
Sidebar.BackgroundColor3 = GetTheme().Surface
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
RegisterThemed(Sidebar, {BackgroundColor3 = "Surface"})

local SidebarBorder = Instance.new("Frame")
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Position = UDim2.new(1, 0, 0, 0)
SidebarBorder.BackgroundColor3 = GetTheme().Border
SidebarBorder.BorderSizePixel = 0
SidebarBorder.Parent = Sidebar
RegisterThemed(SidebarBorder, {BackgroundColor3 = "Border"})

-- Logo
local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.new(1, 0, 0, 60)
LogoFrame.BackgroundTransparency = 1
LogoFrame.Parent = Sidebar

local LogoBadge = Instance.new("Frame")
LogoBadge.Size = UDim2.new(0, 34, 0, 34)
LogoBadge.Position = UDim2.new(0, 14, 0.5, 0)
LogoBadge.AnchorPoint = Vector2.new(0, 0.5)
LogoBadge.BackgroundColor3 = GetTheme().Primary
LogoBadge.BorderSizePixel = 0
LogoBadge.Parent = LogoFrame
CreateCorner(LogoBadge, 8)
RegisterThemed(LogoBadge, {BackgroundColor3 = "Primary"})

local LogoBadgeText = Instance.new("TextLabel")
LogoBadgeText.Size = UDim2.new(1, 0, 1, 0)
LogoBadgeText.BackgroundTransparency = 1
LogoBadgeText.Text = "U2"
LogoBadgeText.TextColor3 = GetTheme().Background
LogoBadgeText.TextSize = 12
LogoBadgeText.Font = Enum.Font.GothamBold
LogoBadgeText.Parent = LogoBadge
RegisterThemed(LogoBadgeText, {TextColor3 = "Background"})

local LogoTitle = Instance.new("TextLabel")
LogoTitle.Size = UDim2.new(1, -60, 0, 20)
LogoTitle.Position = UDim2.new(0, 56, 0, 14)
LogoTitle.BackgroundTransparency = 1
LogoTitle.Text = "UNIVERSAL v2"
LogoTitle.TextColor3 = GetTheme().Primary
LogoTitle.TextSize = 15
LogoTitle.Font = Enum.Font.GothamBold
LogoTitle.TextXAlignment = Enum.TextXAlignment.Left
LogoTitle.Parent = LogoFrame
RegisterThemed(LogoTitle, {TextColor3 = "Primary"})

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(1, -60, 0, 14)
LogoSub.Position = UDim2.new(0, 56, 0, 34)
LogoSub.BackgroundTransparency = 1
LogoSub.Text = "v2.6.0 — Fixed Edition"
LogoSub.TextColor3 = GetTheme().TextSecondary
LogoSub.TextSize = 9
LogoSub.Font = Enum.Font.Gotham
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent = LogoFrame
RegisterThemed(LogoSub, {TextColor3 = "TextSecondary"})

local LogoDivider = Instance.new("Frame")
LogoDivider.Size = UDim2.new(1, -24, 0, 1)
LogoDivider.Position = UDim2.new(0, 12, 1, -1)
LogoDivider.BackgroundColor3 = GetTheme().Border
LogoDivider.BorderSizePixel = 0
LogoDivider.Parent = LogoFrame
RegisterThemed(LogoDivider, {BackgroundColor3 = "Border"})

-- Navigation
local NavItems = {
    {id = "features", label = "⚡ Features"},
    {id = "server", label = "🖥️ Server"},
    {id = "utilities", label = "🔧 Utilities"},
    {id = "analyzer", label = "📜 Analyzer"},
    {id = "credits", label = "❤️ Credits"},
    {id = "themes", label = "🎨 Themes"},
    {id = "settings", label = "⚙️ Settings"},
}

local NavButtons = {}
local ContentPanels = {}

local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(1, 0, 1, -65)
NavContainer.Position = UDim2.new(0, 0, 0, 65)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 3)
NavLayout.Parent = NavContainer
CreatePadding(NavContainer, 4, 10, 4, 10)

for i, item in ipairs(NavItems) do
    local btn = Instance.new("TextButton")
    btn.Name = "Nav_" .. item.id
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = GetTheme().SurfaceHover
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = item.label
    btn.TextColor3 = GetTheme().TextSecondary
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = i
    btn.Parent = NavContainer
    CreateCorner(btn, 10)
    CreatePadding(btn, 0, 12, 0, 12)

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 0.5, 0)
    indicator.Position = UDim2.new(0, -1, 0.25, 0)
    indicator.BackgroundColor3 = GetTheme().Primary
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    CreateCorner(indicator, 2)

    NavButtons[item.id] = {Button = btn, Indicator = indicator}

    btn.MouseButton1Click:Connect(function()
        State.ActivePanel = item.id
        for id, nav in pairs(NavButtons) do
            if id == item.id then
                Tween(nav.Button, {BackgroundTransparency = 0.8, TextColor3 = GetTheme().Primary}, 0.25)
                Tween(nav.Indicator, {BackgroundTransparency = 0}, 0.25)
            else
                Tween(nav.Button, {BackgroundTransparency = 1, TextColor3 = GetTheme().TextSecondary}, 0.25)
                Tween(nav.Indicator, {BackgroundTransparency = 1}, 0.25)
            end
        end
        for id, panel in pairs(ContentPanels) do
            panel.Visible = (id == item.id)
        end
    end)

    btn.MouseEnter:Connect(function()
        if State.ActivePanel ~= item.id then
            Tween(btn, {BackgroundTransparency = 0.9}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if State.ActivePanel ~= item.id then
            Tween(btn, {BackgroundTransparency = 1}, 0.15)
        end
    end)
end

-- CONTENT AREA
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -192, 1, -44)
ContentArea.Position = UDim2.new(0, 192, 0, 44)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 4
ContentArea.ScrollBarImageColor3 = GetTheme().Primary
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.Parent = MainFrame
RegisterThemed(ContentArea, {ScrollBarImageColor3 = "Primary"})

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -192, 0, 44)
TopBar.Position = UDim2.new(0, 192, 0, 0)
TopBar.BackgroundColor3 = GetTheme().Surface
TopBar.BackgroundTransparency = 0.1
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 10
TopBar.Parent = MainFrame
RegisterThemed(TopBar, {BackgroundColor3 = "Surface"})

local TopBarDivider = Instance.new("Frame")
TopBarDivider.Size = UDim2.new(1, 0, 0, 1)
TopBarDivider.Position = UDim2.new(0, 0, 1, 0)
TopBarDivider.BackgroundColor3 = GetTheme().Border
TopBarDivider.BorderSizePixel = 0
TopBarDivider.Parent = TopBar
RegisterThemed(TopBarDivider, {BackgroundColor3 = "Border"})

local TopBarTitle = Instance.new("TextLabel")
TopBarTitle.Size = UDim2.new(0.5, 0, 1, 0)
TopBarTitle.Position = UDim2.new(0, 18, 0, 0)
TopBarTitle.BackgroundTransparency = 1
TopBarTitle.Text = "⚡ FEATURES"
TopBarTitle.TextColor3 = GetTheme().Text
TopBarTitle.TextSize = 13
TopBarTitle.Font = Enum.Font.GothamBold
TopBarTitle.TextXAlignment = Enum.TextXAlignment.Left
TopBarTitle.Parent = TopBar
RegisterThemed(TopBarTitle, {TextColor3 = "Text"})

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -90, 0.5, 0)
StatusDot.AnchorPoint = Vector2.new(0, 0.5)
StatusDot.BackgroundColor3 = Color3.fromHex("#00ff88")
StatusDot.BorderSizePixel = 0
StatusDot.Parent = TopBar
CreateCorner(StatusDot, 4)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 70, 1, 0)
StatusText.Position = UDim2.new(1, -78, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Connected"
StatusText.TextColor3 = Color3.fromHex("#00ff88")
StatusText.TextSize = 10
StatusText.Font = Enum.Font.GothamBold
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = TopBar

-- PANEL HELPERS
local function CreatePanel(name, visible)
    local panel = Instance.new("Frame")
    panel.Name = name
    panel.Size = UDim2.new(1, 0, 0, 0)
    panel.AutomaticSize = Enum.AutomaticSize.Y
    panel.BackgroundTransparency = 1
    panel.Visible = visible or false
    panel.Parent = ContentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = panel
    CreatePadding(panel, 14, 18, 14, 18)

    ContentPanels[name] = panel
    return panel
end

local function CreateSectionHeader(parent, text, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order or 0
    container.Parent = parent

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 0, 16)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.BackgroundColor3 = GetTheme().Primary
    line.BorderSizePixel = 0
    line.Parent = container
    CreateCorner(line, 2)
    RegisterThemed(line, {BackgroundColor3 = "Primary"})

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -12, 1, 0)
    header.Position = UDim2.new(0, 12, 0, 0)
    header.BackgroundTransparency = 1
    header.Text = text
    header.TextColor3 = GetTheme().Primary
    header.TextSize = 13
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = container
    RegisterThemed(header, {TextColor3 = "Primary"})
    return container
end

local function CreateToggle(parent, label, description, order, callback)
    local row = Instance.new("Frame")
    row.Name = "Toggle_" .. label
    row.Size = UDim2.new(1, 0, 0, 54)
    row.BackgroundColor3 = GetTheme().SurfaceHover
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 0
    row.Parent = parent
    CreateCorner(row, 10)
    local rowStroke = CreateStroke(row, GetTheme().Border, 1)
    RegisterThemed(row, {BackgroundColor3 = "SurfaceHover"})

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.65, -10, 0, 18)
    labelText.Position = UDim2.new(0, 16, 0, 10)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = GetTheme().Text
    labelText.TextSize = 13
    labelText.Font = Enum.Font.GothamBold
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = row

    local descText = Instance.new("TextLabel")
    descText.Size = UDim2.new(0.65, -10, 0, 14)
    descText.Position = UDim2.new(0, 16, 0, 30)
    descText.BackgroundTransparency = 1
    descText.Text = description
    descText.TextColor3 = GetTheme().TextSecondary
    descText.TextSize = 10
    descText.Font = Enum.Font.Gotham
    descText.TextXAlignment = Enum.TextXAlignment.Left
    descText.Parent = row
    RegisterThemed(descText, {TextColor3 = "TextSecondary"})

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 48, 0, 24)
    toggleBg.Position = UDim2.new(1, -64, 0.5, 0)
    toggleBg.AnchorPoint = Vector2.new(0, 0.5)
    toggleBg.BackgroundColor3 = GetTheme().Border
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row
    CreateCorner(toggleBg, 12)

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, 0)
    toggleKnob.AnchorPoint = Vector2.new(0, 0.5)
    toggleKnob.BackgroundColor3 = GetTheme().TextSecondary
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg
    CreateCorner(toggleKnob, 10)

    local enabled = false
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = row

    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            Tween(toggleBg, {BackgroundColor3 = GetTheme().Primary}, 0.25)
            Tween(toggleKnob, {Position = UDim2.new(0, 26, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1)}, 0.25)
            Tween(labelText, {TextColor3 = GetTheme().Primary}, 0.25)
            -- [FIX] Update existing stroke
            rowStroke.Color = GetTheme().Primary
            rowStroke.Transparency = 0.5
        else
            Tween(toggleBg, {BackgroundColor3 = GetTheme().Border}, 0.25)
            Tween(toggleKnob, {Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = GetTheme().TextSecondary}, 0.25)
            Tween(labelText, {TextColor3 = GetTheme().Text}, 0.25)
            rowStroke.Color = GetTheme().Border
            rowStroke.Transparency = 0
        end
        if callback then callback(enabled) end
    end)

    return row, toggleBtn, enabled
end

local function CreateSlider(parent, label, min, max, default, order, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 64)
    container.BackgroundColor3 = GetTheme().SurfaceHover
    container.BorderSizePixel = 0
    container.LayoutOrder = order or 0
    container.Parent = parent
    CreateCorner(container, 10)
    CreateStroke(container, GetTheme().Border, 1)
    RegisterThemed(container, {BackgroundColor3 = "SurfaceHover"})

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.5, 0, 0, 20)
    labelText.Position = UDim2.new(0, 16, 0, 8)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = GetTheme().Text
    labelText.TextSize = 12
    labelText.Font = Enum.Font.GothamBold
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    RegisterThemed(labelText, {TextColor3 = "Text"})

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.7, -16, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = GetTheme().Primary
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    RegisterThemed(valueLabel, {TextColor3 = "Primary"})

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -32, 0, 6)
    track.Position = UDim2.new(0, 16, 0, 38)
    track.BackgroundColor3 = GetTheme().Border
    track.BorderSizePixel = 0
    track.Parent = container
    CreateCorner(track, 3)
    RegisterThemed(track, {BackgroundColor3 = "Border"})

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = GetTheme().Primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    CreateCorner(fill, 3)
    RegisterThemed(fill, {BackgroundColor3 = "Primary"})

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.BackgroundColor3 = GetTheme().Primary
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track
    CreateCorner(knob, 7)
    RegisterThemed(knob, {BackgroundColor3 = "Primary"})

    local minL = Instance.new("TextLabel")
    minL.Size = UDim2.new(0.2, 0, 0, 14)
    minL.Position = UDim2.new(0, 16, 0, 48)
    minL.BackgroundTransparency = 1
    minL.Text = tostring(min)
    minL.TextColor3 = GetTheme().TextSecondary
    minL.TextSize = 9
    minL.Font = Enum.Font.Gotham
    minL.TextXAlignment = Enum.TextXAlignment.Left
    minL.Parent = container
    RegisterThemed(minL, {TextColor3 = "TextSecondary"})

    local maxL = Instance.new("TextLabel")
    maxL.Size = UDim2.new(0.2, 0, 0, 14)
    maxL.Position = UDim2.new(0.8, -16, 0, 48)
    maxL.BackgroundTransparency = 1
    maxL.Text = tostring(max)
    maxL.TextColor3 = GetTheme().TextSecondary
    maxL.TextSize = 9
    maxL.Font = Enum.Font.Gotham
    maxL.TextXAlignment = Enum.TextXAlignment.Right
    maxL.Parent = container
    RegisterThemed(maxL, {TextColor3 = "TextSecondary"})

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, -32, 0, 24)
    sliderBtn.Position = UDim2.new(0, 16, 0, 30)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = container

    local sliding = false

    local function UpdateSlider(inputX)
        local tPos = track.AbsolutePosition.X
        local tSize = track.AbsoluteSize.X
        local pct = math.clamp((inputX - tPos) / tSize, 0, 1)
        local value = math.floor(min + (max - min) * pct)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -7, 0.5, 0)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    sliderBtn.MouseButton1Down:Connect(function() sliding = true end)
    -- [FIX] Touch support for sliders
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position.X)
        end
    end)

    return container
end

local function CreateActionButton(parent, label, color, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.48, 0, 0, 42)
    btn.BackgroundColor3 = color or GetTheme().SurfaceHover
    btn.BackgroundTransparency = 0.85
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = color or GetTheme().Primary
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order or 0
    btn.Parent = parent
    CreateCorner(btn, 10)
    CreateStroke(btn, color or GetTheme().Primary, 1, 0.6)

    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.65}, 0.15) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0.85}, 0.15) end)
    btn.MouseButton1Click:Connect(function()
        Tween(btn, {BackgroundTransparency = 0.4}, 0.1)
        wait(0.1)
        Tween(btn, {BackgroundTransparency = 0.85}, 0.15)
        if callback then callback() end
    end)
    return btn
end

-- ═══════════════════════════════════════════════════════════════
-- PANEL 1: FEATURES
-- ═══════════════════════════════════════════════════════════════
local featuresPanel = CreatePanel("features", true)
CreateSectionHeader(featuresPanel, "GAME MODIFICATIONS", 1)
CreateToggle(featuresPanel, "FLY", "Fly freely (Press F to toggle)", 2, function(e) State.FlyEnabled = e end)
CreateToggle(featuresPanel, "INFINITE JUMP", "Jump unlimited times in air", 3, function(e) State.InfiniteJumpEnabled = e end)
CreateToggle(featuresPanel, "GOD MODE", "Become invincible to damage", 4, function(e) State.GodModeEnabled = e end)
CreateToggle(featuresPanel, "ESP / WALLHACK", "See players through walls", 5, function(e) State.ESPEnabled = e end)
CreateToggle(featuresPanel, "INVISIBLE", "Become invisible to others", 6, function(e) State.InvisibleEnabled = e end)
CreateSectionHeader(featuresPanel, "PARAMETERS", 7)
CreateSlider(featuresPanel, "PLAYER SPEED", 1, 500, 16, 8, function(v)
    State.PlayerSpeed = v
    local h = GetHumanoid(); if h then h.WalkSpeed = v end
end)
CreateSlider(featuresPanel, "FLY SPEED", 1, 500, 50, 9, function(v) State.FlySpeed = v end)

-- ═══════════════════════════════════════════════════════════════
-- PANEL 2: SERVER INFO
-- ═══════════════════════════════════════════════════════════════
local serverPanel = CreatePanel("server", false)
CreateSectionHeader(serverPanel, "SERVER DETAILS", 1)

local serverInfoFrame = Instance.new("Frame")
serverInfoFrame.Size = UDim2.new(1, 0, 0, 0)
serverInfoFrame.AutomaticSize = Enum.AutomaticSize.Y
serverInfoFrame.BackgroundTransparency = 1
serverInfoFrame.LayoutOrder = 2
serverInfoFrame.Parent = serverPanel

local siLayout = Instance.new("UIGridLayout")
siLayout.CellSize = UDim2.new(0.32, 0, 0, 58)
siLayout.CellPadding = UDim2.new(0.02, 0, 0, 6)
siLayout.SortOrder = Enum.SortOrder.LayoutOrder
siLayout.Parent = serverInfoFrame

local serverStats = {
    {"Server", game.Name ~= "" and game.Name or "Unknown", 1},
    {"Ping", "...", 2},
    {"PlaceId", tostring(game.PlaceId), 3},
    {"Players", tostring(#Players:GetPlayers()) .. "/" .. tostring(Players.MaxPlayers), 4},
    {"JobId", string.sub(game.JobId, 1, 8) .. "...", 5},
    {"FPS", "...", 6},
}

local serverInfoCards = {}
for _, stat in ipairs(serverStats) do
    local card = Instance.new("Frame")
    card.Name = "Card_" .. stat[1]
    card.BackgroundColor3 = GetTheme().SurfaceHover
    card.BorderSizePixel = 0
    card.LayoutOrder = stat[3]
    card.Parent = serverInfoFrame
    CreateCorner(card, 10)
    CreateStroke(card, GetTheme().Border, 1)
    RegisterThemed(card, {BackgroundColor3 = "SurfaceHover"})

    local sLabel = Instance.new("TextLabel")
    sLabel.Size = UDim2.new(1, -10, 0, 16)
    sLabel.Position = UDim2.new(0, 5, 0, 8)
    sLabel.BackgroundTransparency = 1
    sLabel.Text = stat[1]
    sLabel.TextColor3 = GetTheme().TextSecondary
    sLabel.TextSize = 9
    sLabel.Font = Enum.Font.Gotham
    sLabel.TextXAlignment = Enum.TextXAlignment.Center
    sLabel.Parent = card
    RegisterThemed(sLabel, {TextColor3 = "TextSecondary"})

    local sValue = Instance.new("TextLabel")
    sValue.Name = "Value"
    sValue.Size = UDim2.new(1, -10, 0, 20)
    sValue.Position = UDim2.new(0, 5, 0, 28)
    sValue.BackgroundTransparency = 1
    sValue.Text = stat[2]
    sValue.TextColor3 = GetTheme().Text
    sValue.TextSize = 11
    sValue.Font = Enum.Font.GothamBold
    sValue.TextXAlignment = Enum.TextXAlignment.Center
    sValue.TextTruncate = Enum.TextTruncate.AtEnd
    sValue.Parent = card
    RegisterThemed(sValue, {TextColor3 = "Text"})

    serverInfoCards[stat[1]] = sValue
end

-- ═══════════════════════════════════════════════════════════════
-- [FIX] CHECKPOINT TELEPORT with dynamic scanning & selection
-- ═══════════════════════════════════════════════════════════════
CreateSectionHeader(serverPanel, "TELEPORT ACTIONS", 3)

local tpFrame = Instance.new("Frame")
tpFrame.Size = UDim2.new(1, 0, 0, 0)
tpFrame.AutomaticSize = Enum.AutomaticSize.Y
tpFrame.BackgroundTransparency = 1
tpFrame.LayoutOrder = 4
tpFrame.Parent = serverPanel

local tpLayout = Instance.new("UIListLayout")
tpLayout.SortOrder = Enum.SortOrder.LayoutOrder
tpLayout.Padding = UDim.new(0, 6)
tpLayout.Parent = tpFrame

-- Spawn teleport button
local spawnBtnRow = Instance.new("Frame")
spawnBtnRow.Size = UDim2.new(1, 0, 0, 42)
spawnBtnRow.BackgroundTransparency = 1
spawnBtnRow.LayoutOrder = 1
spawnBtnRow.Parent = tpFrame

local spawnBtnLayout = Instance.new("UIGridLayout")
spawnBtnLayout.CellSize = UDim2.new(0.48, 0, 0, 42)
spawnBtnLayout.CellPadding = UDim2.new(0.04, 0, 0, 6)
spawnBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
spawnBtnLayout.Parent = spawnBtnRow

CreateActionButton(spawnBtnRow, "🏠 TP to Spawn", GetTheme().Primary, 1, function()
    local root = GetRootPart()
    if not root then return end
    local spawn = nil
    for _, n in ipairs({"SpawnLocation", "Spawn", "spawn", "SpawnPoint"}) do
        spawn = Workspace:FindFirstChild(n, true)
        if spawn then break end
    end
    if not spawn then spawn = Workspace:FindFirstChildOfClass("SpawnLocation") end
    if spawn and spawn:IsA("BasePart") then
        root.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
        Notify("Teleport", "Teleported to Spawn!")
    else
        Notify("Teleport", "No spawn found!")
    end
end)

-- [FIX] Checkpoint scanner
local function ScanCheckpoints()
    local cps = {}
    local patterns = {"checkpoint", "cp", "stage", "check", "point"}
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local name = obj.Name:lower()
                local isCP = false
                local cpNum = nil
                for _, p in ipairs(patterns) do
                    if name:find(p) then
                        isCP = true
                        cpNum = tonumber(name:match("%d+"))
                        break
                    end
                end
                if not isCP and obj.Parent then
                    local pName = obj.Parent.Name:lower()
                    for _, p in ipairs(patterns) do
                        if pName:find(p) then
                            isCP = true
                            cpNum = tonumber(obj.Name:match("%d+"))
                            break
                        end
                    end
                end
                if isCP then
                    local cf = nil
                    if obj:IsA("BasePart") then
                        cf = obj.CFrame
                    elseif obj:IsA("Model") then
                        pcall(function()
                            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            if part then cf = part.CFrame end
                        end)
                    end
                    if cf then
                        table.insert(cps, {Name = obj.Name, Number = cpNum or #cps + 1, CFrame = cf})
                    end
                end
            end
        end
    end)
    table.sort(cps, function(a, b) return a.Number < b.Number end)
    return cps
end

-- CP Selector UI
local cpFrame = Instance.new("Frame")
cpFrame.Size = UDim2.new(1, 0, 0, 200)
cpFrame.BackgroundColor3 = GetTheme().SurfaceHover
cpFrame.BorderSizePixel = 0
cpFrame.LayoutOrder = 2
cpFrame.Parent = tpFrame
CreateCorner(cpFrame, 10)
CreateStroke(cpFrame, GetTheme().Border, 1)
RegisterThemed(cpFrame, {BackgroundColor3 = "SurfaceHover"})

local cpTitle = Instance.new("Frame")
cpTitle.Size = UDim2.new(1, 0, 0, 36)
cpTitle.BackgroundColor3 = GetTheme().Surface
cpTitle.BorderSizePixel = 0
cpTitle.Parent = cpFrame
CreateCorner(cpTitle, 10)
RegisterThemed(cpTitle, {BackgroundColor3 = "Surface"})

local cpTitleLabel = Instance.new("TextLabel")
cpTitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
cpTitleLabel.Position = UDim2.new(0, 14, 0, 0)
cpTitleLabel.BackgroundTransparency = 1
cpTitleLabel.Text = "🚩 CHECKPOINT TELEPORT"
cpTitleLabel.TextColor3 = GetTheme().Primary
cpTitleLabel.TextSize = 11
cpTitleLabel.Font = Enum.Font.GothamBold
cpTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
cpTitleLabel.Parent = cpTitle
RegisterThemed(cpTitleLabel, {TextColor3 = "Primary"})

local cpRefreshBtn = Instance.new("TextButton")
cpRefreshBtn.Size = UDim2.new(0, 70, 0, 26)
cpRefreshBtn.Position = UDim2.new(1, -80, 0.5, 0)
cpRefreshBtn.AnchorPoint = Vector2.new(0, 0.5)
cpRefreshBtn.BackgroundColor3 = GetTheme().Primary
cpRefreshBtn.BackgroundTransparency = 0.85
cpRefreshBtn.Text = "🔄 Scan"
cpRefreshBtn.TextColor3 = GetTheme().Primary
cpRefreshBtn.TextSize = 10
cpRefreshBtn.Font = Enum.Font.GothamBold
cpRefreshBtn.BorderSizePixel = 0
cpRefreshBtn.Parent = cpTitle
CreateCorner(cpRefreshBtn, 6)

local cpCountLabel = Instance.new("TextLabel")
cpCountLabel.Size = UDim2.new(1, -20, 0, 18)
cpCountLabel.Position = UDim2.new(0, 10, 0, 40)
cpCountLabel.BackgroundTransparency = 1
cpCountLabel.Text = "Scanning..."
cpCountLabel.TextColor3 = GetTheme().TextSecondary
cpCountLabel.TextSize = 10
cpCountLabel.Font = Enum.Font.Gotham
cpCountLabel.TextXAlignment = Enum.TextXAlignment.Left
cpCountLabel.Parent = cpFrame
RegisterThemed(cpCountLabel, {TextColor3 = "TextSecondary"})

local cpScroll = Instance.new("ScrollingFrame")
cpScroll.Size = UDim2.new(1, -16, 0, 130)
cpScroll.Position = UDim2.new(0, 8, 0, 62)
cpScroll.BackgroundTransparency = 1
cpScroll.ScrollBarThickness = 3
cpScroll.ScrollBarImageColor3 = GetTheme().Primary
cpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
cpScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
cpScroll.BorderSizePixel = 0
cpScroll.Parent = cpFrame
RegisterThemed(cpScroll, {ScrollBarImageColor3 = "Primary"})

local cpGridLayout = Instance.new("UIGridLayout")
cpGridLayout.CellSize = UDim2.new(0.48, 0, 0, 34)
cpGridLayout.CellPadding = UDim2.new(0.04, 0, 0, 4)
cpGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
cpGridLayout.Parent = cpScroll

local function RefreshCheckpoints()
    for _, c in ipairs(cpScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local cps = ScanCheckpoints()
    if #cps == 0 then
        cpCountLabel.Text = "No checkpoints found (0 CP)"
    else
        cpCountLabel.Text = "Found " .. #cps .. " checkpoint(s) — Click to teleport"
        for i, cp in ipairs(cps) do
            local cpBtn = Instance.new("TextButton")
            cpBtn.Size = UDim2.new(0.48, 0, 0, 34)
            cpBtn.BackgroundColor3 = GetTheme().Surface
            cpBtn.BackgroundTransparency = 0.3
            cpBtn.Text = "🚩 " .. cp.Name
            cpBtn.TextColor3 = GetTheme().Text
            cpBtn.TextSize = 10
            cpBtn.Font = Enum.Font.GothamMedium
            cpBtn.TextTruncate = Enum.TextTruncate.AtEnd
            cpBtn.LayoutOrder = i
            cpBtn.BorderSizePixel = 0
            cpBtn.Parent = cpScroll
            CreateCorner(cpBtn, 8)
            CreateStroke(cpBtn, GetTheme().Border, 1, 0.5)

            cpBtn.MouseEnter:Connect(function()
                Tween(cpBtn, {BackgroundTransparency = 0.1}, 0.15)
            end)
            cpBtn.MouseLeave:Connect(function()
                Tween(cpBtn, {BackgroundTransparency = 0.3}, 0.15)
            end)
            cpBtn.MouseButton1Click:Connect(function()
                local root = GetRootPart()
                if root and cp.CFrame then
                    root.CFrame = cp.CFrame + Vector3.new(0, 5, 0)
                    Notify("Teleport", "TP to " .. cp.Name .. "!")
                    Tween(cpBtn, {BackgroundColor3 = GetTheme().Success}, 0.15)
                    wait(0.3)
                    Tween(cpBtn, {BackgroundColor3 = GetTheme().Surface}, 0.15)
                end
            end)
        end
    end
end

cpRefreshBtn.MouseButton1Click:Connect(function()
    cpCountLabel.Text = "Scanning..."
    wait(0.1)
    RefreshCheckpoints()
end)

spawn(function() wait(1); RefreshCheckpoints() end)

-- ═══════════════════════════════════════════════════════════════
-- [FIX] AUTO SUBMIT — improved detection & feedback
-- ═══════════════════════════════════════════════════════════════
local asFrame = Instance.new("Frame")
asFrame.Size = UDim2.new(1, 0, 0, 140)
asFrame.BackgroundColor3 = GetTheme().SurfaceHover
asFrame.BorderSizePixel = 0
asFrame.LayoutOrder = 3
asFrame.Parent = tpFrame
CreateCorner(asFrame, 10)
CreateStroke(asFrame, GetTheme().Border, 1)
RegisterThemed(asFrame, {BackgroundColor3 = "SurfaceHover"})

local asTitle = Instance.new("TextLabel")
asTitle.Size = UDim2.new(1, -20, 0, 28)
asTitle.Position = UDim2.new(0, 14, 0, 6)
asTitle.BackgroundTransparency = 1
asTitle.Text = "▶️ AUTO SUBMIT / FINISH"
asTitle.TextColor3 = GetTheme().Success
asTitle.TextSize = 11
asTitle.Font = Enum.Font.GothamBold
asTitle.TextXAlignment = Enum.TextXAlignment.Left
asTitle.Parent = asFrame

local asDesc = Instance.new("TextLabel")
asDesc.Size = UDim2.new(1, -20, 0, 14)
asDesc.Position = UDim2.new(0, 14, 0, 32)
asDesc.BackgroundTransparency = 1
asDesc.Text = "Fires submit/finish/complete remotes + TP to finish zone"
asDesc.TextColor3 = GetTheme().TextSecondary
asDesc.TextSize = 9
asDesc.Font = Enum.Font.Gotham
asDesc.TextXAlignment = Enum.TextXAlignment.Left
asDesc.Parent = asFrame
RegisterThemed(asDesc, {TextColor3 = "TextSecondary"})

local asBtnRow = Instance.new("Frame")
asBtnRow.Size = UDim2.new(1, -16, 0, 36)
asBtnRow.Position = UDim2.new(0, 8, 0, 50)
asBtnRow.BackgroundTransparency = 1
asBtnRow.Parent = asFrame

local asBtnLayout = Instance.new("UIGridLayout")
asBtnLayout.CellSize = UDim2.new(0.48, 0, 0, 36)
asBtnLayout.CellPadding = UDim2.new(0.04, 0, 0, 4)
asBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
asBtnLayout.Parent = asBtnRow

local asLog = Instance.new("TextLabel")
asLog.Size = UDim2.new(1, -20, 0, 40)
asLog.Position = UDim2.new(0, 14, 0, 92)
asLog.BackgroundTransparency = 1
asLog.Text = ""
asLog.TextColor3 = GetTheme().TextSecondary
asLog.TextSize = 9
asLog.Font = Enum.Font.Code
asLog.TextXAlignment = Enum.TextXAlignment.Left
asLog.TextWrapped = true
asLog.Parent = asFrame
RegisterThemed(asLog, {TextColor3 = "TextSecondary"})

CreateActionButton(asBtnRow, "▶️ Auto Submit", GetTheme().Success, 1, function()
    local fired = 0
    local log = ""
    pcall(function()
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local n = v.Name:lower()
                if n:find("submit") or n:find("finish") or n:find("complete") or n:find("win") or n:find("done") then
                    pcall(function() v:FireServer(); fired = fired + 1; log = log .. "✅ " .. v.Name .. " " end)
                end
            elseif v:IsA("RemoteFunction") then
                local n = v.Name:lower()
                if n:find("submit") or n:find("finish") or n:find("complete") then
                    pcall(function() v:InvokeServer(); fired = fired + 1; log = log .. "✅ " .. v.Name .. " " end)
                end
            end
        end
        -- TP to finish zone
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local n = v.Name:lower()
                if n:find("finish") or n:find("end") or n:find("win") or n:find("complete") then
                    local root = GetRootPart()
                    if root then
                        root.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                        log = log .. "📍 TP:" .. v.Name
                        fired = fired + 1
                    end
                    break
                end
            end
        end
    end)
    if fired > 0 then
        asLog.Text = log .. " | Total: " .. fired
        Notify("Auto Submit", fired .. " action(s) fired!")
    else
        asLog.Text = "❌ No submit/finish remotes found"
        Notify("Auto Submit", "No remotes found!")
    end
end)

CreateActionButton(asBtnRow, "🔍 Scan Remotes", GetTheme().Primary, 2, function()
    local found = 0
    local log = ""
    pcall(function()
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local n = v.Name:lower()
                if n:find("submit") or n:find("finish") or n:find("complete") or n:find("win") or n:find("done") then
                    found = found + 1
                    log = log .. v.Name .. " "
                end
            end
        end
    end)
    asLog.Text = found > 0 and ("📡 " .. found .. " found: " .. log) or "❌ None found"
end)

-- Player List
CreateSectionHeader(serverPanel, "PLAYER LIST", 5)

local plFrame = Instance.new("Frame")
plFrame.Size = UDim2.new(1, 0, 0, 200)
plFrame.BackgroundColor3 = GetTheme().SurfaceHover
plFrame.BorderSizePixel = 0
plFrame.LayoutOrder = 6
plFrame.ClipsDescendants = true
plFrame.Parent = serverPanel
CreateCorner(plFrame, 10)
CreateStroke(plFrame, GetTheme().Border, 1)
RegisterThemed(plFrame, {BackgroundColor3 = "SurfaceHover"})

local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, 0, 0, 34)
searchFrame.BackgroundColor3 = GetTheme().Surface
searchFrame.BorderSizePixel = 0
searchFrame.Parent = plFrame
RegisterThemed(searchFrame, {BackgroundColor3 = "Surface"})

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 1, -8)
searchBox.Position = UDim2.new(0, 10, 0, 4)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "🔍 Search players..."
searchBox.PlaceholderColor3 = GetTheme().TextSecondary
searchBox.TextColor3 = GetTheme().Text
searchBox.TextSize = 11
searchBox.Font = Enum.Font.Gotham
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame
RegisterThemed(searchBox, {TextColor3 = "Text"})

local plScroll = Instance.new("ScrollingFrame")
plScroll.Size = UDim2.new(1, 0, 1, -36)
plScroll.Position = UDim2.new(0, 0, 0, 36)
plScroll.BackgroundTransparency = 1
plScroll.ScrollBarThickness = 3
plScroll.ScrollBarImageColor3 = GetTheme().Primary
plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
plScroll.Parent = plFrame
RegisterThemed(plScroll, {ScrollBarImageColor3 = "Primary"})

local plListLayout = Instance.new("UIListLayout")
plListLayout.SortOrder = Enum.SortOrder.LayoutOrder
plListLayout.Padding = UDim.new(0, 1)
plListLayout.Parent = plScroll

local function RefreshPlayerList(q)
    for _, c in ipairs(plScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i, p in ipairs(Players:GetPlayers()) do
        local nm = p.Name:lower()
        local dn = p.DisplayName:lower()
        local query = (q or ""):lower()
        if query == "" or nm:find(query) or dn:find(query) then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 36)
            row.BackgroundColor3 = GetTheme().Surface
            row.BackgroundTransparency = i % 2 == 0 and 0.4 or 0.8
            row.BorderSizePixel = 0
            row.LayoutOrder = i
            row.Parent = plScroll

            local nl = Instance.new("TextLabel")
            nl.Size = UDim2.new(0.55, -10, 1, 0)
            nl.Position = UDim2.new(0, 12, 0, 0)
            nl.BackgroundTransparency = 1
            nl.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            nl.TextColor3 = GetTheme().Text
            nl.TextSize = 10
            nl.Font = Enum.Font.GothamMedium
            nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.TextTruncate = Enum.TextTruncate.AtEnd
            nl.Parent = row

            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0, 74, 0, 26)
            tpBtn.Position = UDim2.new(1, -84, 0.5, 0)
            tpBtn.AnchorPoint = Vector2.new(0, 0.5)
            tpBtn.BackgroundColor3 = GetTheme().Primary
            tpBtn.BackgroundTransparency = 0.8
            tpBtn.Text = "TELEPORT"
            tpBtn.TextColor3 = GetTheme().Primary
            tpBtn.TextSize = 9
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.Parent = row
            CreateCorner(tpBtn, 6)
            CreateStroke(tpBtn, GetTheme().Primary, 1, 0.5)

            tpBtn.MouseButton1Click:Connect(function()
                local root = GetRootPart()
                local tc = p.Character
                if root and tc and tc:FindFirstChild("HumanoidRootPart") then
                    root.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    Notify("Teleport", "TP to " .. p.DisplayName)
                end
            end)
        end
    end
end

RefreshPlayerList("")
searchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshPlayerList(searchBox.Text) end)
Players.PlayerAdded:Connect(function() RefreshPlayerList(searchBox.Text) end)
Players.PlayerRemoving:Connect(function() wait(0.1) RefreshPlayerList(searchBox.Text) end)

-- ═══════════════════════════════════════════════════════════════
-- PANEL 3: UTILITIES
-- ═══════════════════════════════════════════════════════════════
local utilPanel = CreatePanel("utilities", false)
CreateSectionHeader(utilPanel, "CHARACTER CONTROLS", 1)
CreateSlider(utilPanel, "WALKSPEED", 0, 500, 16, 2, function(v)
    State.WalkSpeed = v; local h = GetHumanoid(); if h then h.WalkSpeed = v end
end)
CreateSlider(utilPanel, "JUMP POWER", 0, 500, 50, 3, function(v)
    State.JumpPower = v; local h = GetHumanoid(); if h then h.JumpPower = v end
end)
CreateToggle(utilPanel, "NOCLIP", "Walk through walls (Press N to toggle)", 4, function(e) State.NoclipEnabled = e end)

CreateSectionHeader(utilPanel, "SERVER UTILITIES", 5)
local ubFrame = Instance.new("Frame")
ubFrame.Size = UDim2.new(1, 0, 0, 0)
ubFrame.AutomaticSize = Enum.AutomaticSize.Y
ubFrame.BackgroundTransparency = 1
ubFrame.LayoutOrder = 6
ubFrame.Parent = utilPanel

local ubLayout = Instance.new("UIGridLayout")
ubLayout.CellSize = UDim2.new(0.48, 0, 0, 42)
ubLayout.CellPadding = UDim2.new(0.04, 0, 0, 6)
ubLayout.SortOrder = Enum.SortOrder.LayoutOrder
ubLayout.Parent = ubFrame

CreateActionButton(ubFrame, "🔄 Reset Character", Color3.fromHex("#ff3355"), 1, function()
    local h = GetHumanoid(); if h then h.Health = 0 end
end)
CreateActionButton(ubFrame, "🔁 Rejoin Server", Color3.fromHex("#ffaa00"), 2, function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
CreateActionButton(ubFrame, "📋 Copy JobId", GetTheme().Primary, 3, function()
    pcall(function() setclipboard(game.JobId); Notify("Copied", "JobId copied!") end)
end)
CreateActionButton(ubFrame, "🔀 Server Hop", Color3.fromHex("#7b2dff"), 4, function()
    Notify("Server Hop", "Finding server...")
    pcall(function()
        local s = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if s and s.data then
            for _, sv in ipairs(s.data) do
                if sv.id ~= game.JobId and sv.playing < sv.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, LocalPlayer)
                    return
                end
            end
            Notify("Server Hop", "No servers found!")
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- PANEL 4: SCRIPT ANALYZER
-- ═══════════════════════════════════════════════════════════════
local analyzerPanel = CreatePanel("analyzer", false)
CreateSectionHeader(analyzerPanel, "DETECTED SCRIPTS", 1)

local stFrame = Instance.new("Frame")
stFrame.Size = UDim2.new(1, 0, 0, 0)
stFrame.AutomaticSize = Enum.AutomaticSize.Y
stFrame.BackgroundTransparency = 1
stFrame.LayoutOrder = 2
stFrame.Parent = analyzerPanel

local stLayout = Instance.new("UIGridLayout")
stLayout.CellSize = UDim2.new(0.24, 0, 0, 48)
stLayout.CellPadding = UDim2.new(0.01, 0, 0, 4)
stLayout.SortOrder = Enum.SortOrder.LayoutOrder
stLayout.Parent = stFrame

local function CountScripts()
    local t, l, s, m = 0, 0, 0, 0
    pcall(function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("LocalScript") then l = l + 1; t = t + 1
            elseif v:IsA("Script") and not v:IsA("LocalScript") then s = s + 1; t = t + 1
            elseif v:IsA("ModuleScript") then m = m + 1; t = t + 1 end
        end
    end)
    return t, l, s, m
end

local tS, lS, sS, mS = CountScripts()
for _, st in ipairs({
    {"Total", tostring(tS), GetTheme().Primary, 1},
    {"Local", tostring(lS), Color3.fromHex("#00f0ff"), 2},
    {"Script", tostring(sS), Color3.fromHex("#ff00aa"), 3},
    {"Module", tostring(mS), Color3.fromHex("#7b2dff"), 4},
}) do
    local card = Instance.new("Frame")
    card.BackgroundColor3 = GetTheme().SurfaceHover
    card.BorderSizePixel = 0
    card.LayoutOrder = st[4]
    card.Parent = stFrame
    CreateCorner(card, 8)
    CreateStroke(card, GetTheme().Border, 1)
    RegisterThemed(card, {BackgroundColor3 = "SurfaceHover"})

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(1, 0, 0, 22)
    v.Position = UDim2.new(0, 0, 0, 6)
    v.BackgroundTransparency = 1
    v.Text = st[2]
    v.TextColor3 = st[3]
    v.TextSize = 16
    v.Font = Enum.Font.GothamBold
    v.Parent = card

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, 0, 0, 14)
    lb.Position = UDim2.new(0, 0, 0, 28)
    lb.BackgroundTransparency = 1
    lb.Text = st[1]
    lb.TextColor3 = GetTheme().TextSecondary
    lb.TextSize = 9
    lb.Font = Enum.Font.Gotham
    lb.Parent = card
    RegisterThemed(lb, {TextColor3 = "TextSecondary"})
end

-- ═══════════════════════════════════════════════════════════════
-- PANEL 5: CREDITS
-- ═══════════════════════════════════════════════════════════════
local creditsPanel = CreatePanel("credits", false)
CreateSectionHeader(creditsPanel, "PLAYER INFO", 1)

local piFrame = Instance.new("Frame")
piFrame.Size = UDim2.new(1, 0, 0, 0)
piFrame.AutomaticSize = Enum.AutomaticSize.Y
piFrame.BackgroundColor3 = GetTheme().SurfaceHover
piFrame.BorderSizePixel = 0
piFrame.LayoutOrder = 2
piFrame.Parent = creditsPanel
CreateCorner(piFrame, 10)
CreateStroke(piFrame, GetTheme().Primary, 1, 0.6)
RegisterThemed(piFrame, {BackgroundColor3 = "SurfaceHover"})

local piGridLayout = Instance.new("UIGridLayout")
piGridLayout.CellSize = UDim2.new(0.48, 0, 0, 48)
piGridLayout.CellPadding = UDim2.new(0.04, 0, 0, 6)
piGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
piGridLayout.Parent = piFrame
CreatePadding(piFrame, 10, 10, 10, 10)

for _, d in ipairs({
    {"Username", LocalPlayer.Name, 1},
    {"Display", LocalPlayer.DisplayName, 2},
    {"UserId", tostring(LocalPlayer.UserId), 3},
    {"Status", "Online ✅", 4},
    {"Age", tostring(LocalPlayer.AccountAge) .. " days", 5},
    {"Member", tostring(LocalPlayer.MembershipType), 6},
}) do
    local card = Instance.new("Frame")
    card.BackgroundColor3 = GetTheme().Surface
    card.BorderSizePixel = 0
    card.LayoutOrder = d[3]
    card.Parent = piFrame
    CreateCorner(card, 8)
    RegisterThemed(card, {BackgroundColor3 = "Surface"})

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -10, 0, 14)
    lb.Position = UDim2.new(0, 5, 0, 6)
    lb.BackgroundTransparency = 1
    lb.Text = d[1]
    lb.TextColor3 = GetTheme().TextSecondary
    lb.TextSize = 9
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = card
    RegisterThemed(lb, {TextColor3 = "TextSecondary"})

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(1, -10, 0, 18)
    vl.Position = UDim2.new(0, 5, 0, 22)
    vl.BackgroundTransparency = 1
    vl.Text = d[2]
    vl.TextColor3 = GetTheme().Text
    vl.TextSize = 11
    vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Left
    vl.TextTruncate = Enum.TextTruncate.AtEnd
    vl.Parent = card
    RegisterThemed(vl, {TextColor3 = "Text"})
end

CreateSectionHeader(creditsPanel, "DEVELOPMENT TEAM", 3)

local creditCard = Instance.new("Frame")
creditCard.Size = UDim2.new(1, 0, 0, 54)
creditCard.BackgroundColor3 = GetTheme().SurfaceHover
creditCard.BorderSizePixel = 0
creditCard.LayoutOrder = 4
creditCard.Parent = creditsPanel
CreateCorner(creditCard, 10)
CreateStroke(creditCard, GetTheme().Border, 1)
RegisterThemed(creditCard, {BackgroundColor3 = "SurfaceHover"})

local ccBadge = Instance.new("Frame")
ccBadge.Size = UDim2.new(0, 38, 0, 38)
ccBadge.Position = UDim2.new(0, 10, 0.5, 0)
ccBadge.AnchorPoint = Vector2.new(0, 0.5)
ccBadge.BackgroundColor3 = GetTheme().Primary
ccBadge.BackgroundTransparency = 0.8
ccBadge.BorderSizePixel = 0
ccBadge.Parent = creditCard
CreateCorner(ccBadge, 10)
RegisterThemed(ccBadge, {BackgroundColor3 = "Primary"})

local ccBT = Instance.new("TextLabel")
ccBT.Size = UDim2.new(1, 0, 1, 0)
ccBT.BackgroundTransparency = 1
ccBT.Text = "S"
ccBT.TextColor3 = GetTheme().Primary
ccBT.TextSize = 16
ccBT.Font = Enum.Font.GothamBold
ccBT.Parent = ccBadge
RegisterThemed(ccBT, {TextColor3 = "Primary"})

local ccName = Instance.new("TextLabel")
ccName.Size = UDim2.new(0.6, -60, 0, 16)
ccName.Position = UDim2.new(0, 58, 0, 10)
ccName.BackgroundTransparency = 1
ccName.Text = "Sobing4413"
ccName.TextColor3 = GetTheme().Text
ccName.TextSize = 13
ccName.Font = Enum.Font.GothamBold
ccName.TextXAlignment = Enum.TextXAlignment.Left
ccName.Parent = creditCard
RegisterThemed(ccName, {TextColor3 = "Text"})

local ccRole = Instance.new("TextLabel")
ccRole.Size = UDim2.new(0.7, -60, 0, 14)
ccRole.Position = UDim2.new(0, 58, 0, 28)
ccRole.BackgroundTransparency = 1
ccRole.Text = "Lead Developer — Core Framework & Features"
ccRole.TextColor3 = GetTheme().TextSecondary
ccRole.TextSize = 9
ccRole.Font = Enum.Font.Gotham
ccRole.TextXAlignment = Enum.TextXAlignment.Left
ccRole.Parent = creditCard
RegisterThemed(ccRole, {TextColor3 = "TextSecondary"})

local verFrame = Instance.new("Frame")
verFrame.Size = UDim2.new(1, 0, 0, 40)
verFrame.BackgroundColor3 = GetTheme().SurfaceHover
verFrame.BackgroundTransparency = 0.5
verFrame.BorderSizePixel = 0
verFrame.LayoutOrder = 10
verFrame.Parent = creditsPanel
CreateCorner(verFrame, 10)
RegisterThemed(verFrame, {BackgroundColor3 = "SurfaceHover"})

local verText = Instance.new("TextLabel")
verText.Size = UDim2.new(1, 0, 1, 0)
verText.BackgroundTransparency = 1
verText.Text = "UNIVERSAL v2 v2.6.0 • Fixed Edition • Built with ❤️"
verText.TextColor3 = GetTheme().TextSecondary
verText.TextSize = 10
verText.Font = Enum.Font.Gotham
verText.Parent = verFrame
RegisterThemed(verText, {TextColor3 = "TextSecondary"})

-- ═══════════════════════════════════════════════════════════════
-- PANEL 6: THEMES — [FIX] Live theme switching
-- ═══════════════════════════════════════════════════════════════
local themesPanel = CreatePanel("themes", false)
CreateSectionHeader(themesPanel, "SELECT THEME (Live Switch ✨)", 1)

local themeLabels = {}

for i, theme in ipairs(Themes) do
    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(1, 0, 0, 50)
    tBtn.BackgroundColor3 = theme.SurfaceHover
    tBtn.BorderSizePixel = 0
    tBtn.Text = ""
    tBtn.LayoutOrder = i + 1
    tBtn.Parent = themesPanel
    CreateCorner(tBtn, 10)
    local tStroke = CreateStroke(tBtn, i == State.CurrentTheme and theme.Primary or theme.Border, 1)

    for j, col in ipairs({theme.Primary, theme.Secondary, theme.Accent}) do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 18, 0, 18)
        dot.Position = UDim2.new(0, 14 + (j-1)*22, 0.5, 0)
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.BackgroundColor3 = col
        dot.BorderSizePixel = 0
        dot.Parent = tBtn
        CreateCorner(dot, 9)
    end

    local tName = Instance.new("TextLabel")
    tName.Size = UDim2.new(0.5, -80, 1, 0)
    tName.Position = UDim2.new(0, 84, 0, 0)
    tName.BackgroundTransparency = 1
    tName.Text = theme.Name
    tName.TextColor3 = theme.Text
    tName.TextSize = 12
    tName.Font = Enum.Font.GothamBold
    tName.TextXAlignment = Enum.TextXAlignment.Left
    tName.Parent = tBtn

    local aLabel = Instance.new("TextLabel")
    aLabel.Size = UDim2.new(0, 56, 0, 22)
    aLabel.Position = UDim2.new(1, -70, 0.5, 0)
    aLabel.AnchorPoint = Vector2.new(0, 0.5)
    aLabel.BackgroundColor3 = theme.Primary
    aLabel.BackgroundTransparency = i == State.CurrentTheme and 0.8 or 1
    aLabel.Text = i == State.CurrentTheme and "✓ Active" or "Apply"
    aLabel.TextColor3 = theme.Primary
    aLabel.TextSize = 9
    aLabel.Font = Enum.Font.GothamBold
    aLabel.Parent = tBtn
    CreateCorner(aLabel, 6)

    themeLabels[i] = {Label = aLabel, Stroke = tStroke}

    tBtn.MouseButton1Click:Connect(function()
        State.CurrentTheme = i
        for idx, data in pairs(themeLabels) do
            if idx == i then
                data.Label.Text = "✓ Active"
                data.Label.BackgroundTransparency = 0.8
                data.Stroke.Color = Themes[idx].Primary
            else
                data.Label.Text = "Apply"
                data.Label.BackgroundTransparency = 1
                data.Stroke.Color = Themes[idx].Border
            end
        end
        -- [FIX] Live apply theme to all elements
        ApplyThemeToAll()
        Notify("🎨 Theme", "Switched to " .. theme.Name)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- PANEL 7: SETTINGS
-- ═══════════════════════════════════════════════════════════════
local settingsPanel = CreatePanel("settings", false)
CreateSectionHeader(settingsPanel, "GUI SETTINGS", 1)
CreateToggle(settingsPanel, "Notifications", "Show in-game notifications", 2, function() end)
CreateToggle(settingsPanel, "Anti-Detection", "Anti-cheat bypass measures", 3, function() end)
CreateToggle(settingsPanel, "Streamer Mode", "Hide sensitive info", 4, function() end)

CreateSectionHeader(settingsPanel, "KEYBINDS", 5)
for i, kb in ipairs({{"Toggle GUI", "Right Shift"}, {"Toggle Fly", "F"}, {"Toggle Noclip", "N"}}) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = GetTheme().SurfaceHover
    row.BorderSizePixel = 0
    row.LayoutOrder = 5 + i
    row.Parent = settingsPanel
    CreateCorner(row, 8)
    CreateStroke(row, GetTheme().Border, 1)
    RegisterThemed(row, {BackgroundColor3 = "SurfaceHover"})

    local al = Instance.new("TextLabel")
    al.Size = UDim2.new(0.6, -10, 1, 0)
    al.Position = UDim2.new(0, 16, 0, 0)
    al.BackgroundTransparency = 1
    al.Text = kb[1]
    al.TextColor3 = GetTheme().Text
    al.TextSize = 11
    al.Font = Enum.Font.GothamMedium
    al.TextXAlignment = Enum.TextXAlignment.Left
    al.Parent = row
    RegisterThemed(al, {TextColor3 = "Text"})

    local kl = Instance.new("TextLabel")
    kl.Size = UDim2.new(0, 85, 0, 26)
    kl.Position = UDim2.new(1, -100, 0.5, 0)
    kl.AnchorPoint = Vector2.new(0, 0.5)
    kl.BackgroundColor3 = GetTheme().Primary
    kl.BackgroundTransparency = 0.88
    kl.Text = kb[2]
    kl.TextColor3 = GetTheme().Primary
    kl.TextSize = 10
    kl.Font = Enum.Font.Code
    kl.Parent = row
    CreateCorner(kl, 6)
    CreateStroke(kl, GetTheme().Primary, 1, 0.6)
    RegisterThemed(kl, {TextColor3 = "Primary"})
end

-- SET DEFAULT ACTIVE
if NavButtons["features"] then
    Tween(NavButtons["features"].Button, {BackgroundTransparency = 0.8, TextColor3 = GetTheme().Primary}, 0.01)
    Tween(NavButtons["features"].Indicator, {BackgroundTransparency = 0}, 0.01)
end

-- Update top bar title
spawn(function()
    local titles = {
        features = "⚡ FEATURES", server = "🖥️ SERVER INFO",
        utilities = "🔧 UTILITIES", analyzer = "📜 SCRIPT ANALYZER",
        credits = "❤️ CREDITS", themes = "🎨 THEMES", settings = "⚙️ SETTINGS",
    }
    while MainFrame and MainFrame.Parent do
        TopBarTitle.Text = titles[State.ActivePanel] or "UNIVERSAL v2"
        wait(0.1)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- FEATURE IMPLEMENTATIONS
-- ═══════════════════════════════════════════════════════════════

-- FLY
local flyBV, flyBG
local function StartFly()
    local root = GetRootPart()
    local hum = GetHumanoid()
    if not root or not hum then return end
    -- [FIX] Clean existing first
    if flyBV then pcall(function() flyBV:Destroy() end) end
    if flyBG then pcall(function() flyBG:Destroy() end) end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = root
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 9e4
    flyBG.Parent = root
    hum.PlatformStand = true
    Notify("Fly", "Fly enabled!")
end

local function StopFly()
    local hum = GetHumanoid()
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
    if hum then hum.PlatformStand = false end
end

RunService.RenderStepped:Connect(function()
    if State.FlyEnabled and flyBV and flyBG then
        local root = GetRootPart()
        if root then
            local spd = State.FlySpeed
            local dir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            flyBV.Velocity = dir * spd
            flyBG.CFrame = Camera.CFrame
        end
    end
end)

spawn(function()
    local was = false
    while MainFrame and MainFrame.Parent do
        if State.FlyEnabled and not was then StartFly(); was = true
        elseif not State.FlyEnabled and was then StopFly(); was = false end
        wait(0.1)
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJumpEnabled then
        local h = GetHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if State.NoclipEnabled then
        local char = GetCharacter()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- GOD MODE
spawn(function()
    while MainFrame and MainFrame.Parent do
        if State.GodModeEnabled then
            local h = GetHumanoid()
            if h then h.MaxHealth = math.huge; h.Health = math.huge end
        end
        wait(0.5)
    end
end)

-- ESP (with proper cleanup)
local espFolder = Instance.new("Folder")
espFolder.Name = "ExterESP"
espFolder.Parent = game:GetService("CoreGui")

local espConns = {}
local espAddConn = nil

local function CreateESP(player)
    if player == LocalPlayer then return end
    local existing = espFolder:FindFirstChild("ESP_" .. player.Name)
    if existing then existing:Destroy() end
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_" .. player.Name
    hl.FillColor = GetTheme().Primary
    hl.FillTransparency = 0.7
    hl.OutlineColor = GetTheme().Primary
    hl.OutlineTransparency = 0
    hl.Parent = espFolder
    local function upd() if player.Character then hl.Adornee = player.Character end end
    upd()
    espConns[player.Name] = player.CharacterAdded:Connect(upd)
end

local function ClearESP()
    for _, v in ipairs(espFolder:GetChildren()) do v:Destroy() end
    for _, c in pairs(espConns) do pcall(function() c:Disconnect() end) end
    espConns = {}
end

spawn(function()
    local was = false
    while MainFrame and MainFrame.Parent do
        if State.ESPEnabled and not was then
            for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
            espAddConn = Players.PlayerAdded:Connect(function(p) if State.ESPEnabled then CreateESP(p) end end)
            Players.PlayerRemoving:Connect(function(p)
                local e = espFolder:FindFirstChild("ESP_" .. p.Name)
                if e then e:Destroy() end
                if espConns[p.Name] then pcall(function() espConns[p.Name]:Disconnect() end); espConns[p.Name] = nil end
            end)
            was = true
        elseif not State.ESPEnabled and was then
            ClearESP()
            if espAddConn then pcall(function() espAddConn:Disconnect() end) end
            was = false
        end
        wait(0.5)
    end
end)

-- INVISIBLE
spawn(function()
    local was = false
    while MainFrame and MainFrame.Parent do
        if State.InvisibleEnabled and not was then
            local char = GetCharacter()
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.Transparency = 1
                    elseif p:IsA("Decal") then p.Transparency = 1 end
                end
            end
            was = true
        elseif not State.InvisibleEnabled and was then
            local char = GetCharacter()
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0
                    elseif p:IsA("Decal") then p.Transparency = 0 end
                end
            end
            was = false
        end
        wait(0.5)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- KEYBINDS
-- ═══════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        State.GuiVisible = not State.GuiVisible
        if State.GuiVisible then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 780, 0, 500)}, 0.3, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            wait(0.2)
            MainFrame.Visible = false
        end
    -- [FIX] F key toggles fly
    elseif input.KeyCode == Enum.KeyCode.F then
        State.FlyEnabled = not State.FlyEnabled
    -- [FIX] N key toggles noclip
    elseif input.KeyCode == Enum.KeyCode.N then
        State.NoclipEnabled = not State.NoclipEnabled
    end
end)

-- OPEN ANIMATION
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Visible = true
wait(0.1)
Tween(MainFrame, {Size = UDim2.new(0, 780, 0, 500)}, 0.5, Enum.EasingStyle.Back)

-- [FIX] PING & FPS UPDATER — actually updates the display
spawn(function()
    while MainFrame and MainFrame.Parent do
        pcall(function()
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            if serverInfoCards["Ping"] then
                serverInfoCards["Ping"].Text = tostring(ping) .. "ms"
            end
        end)
        pcall(function()
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            if serverInfoCards["FPS"] then
                serverInfoCards["FPS"].Text = tostring(fps)
            end
        end)
        pcall(function()
            if serverInfoCards["Players"] then
                serverInfoCards["Players"].Text = tostring(#Players:GetPlayers()) .. "/" .. tostring(Players.MaxPlayers)
            end
        end)
        wait(2)
    end
end)

-- NOTIFICATION
Notify("🎮 UNIVERSAL v2 v2.6.0", "Script loaded! Press Right Shift to toggle GUI.")
