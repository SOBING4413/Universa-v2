-- ═══════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURATION & STATE
-- ═══════════════════════════════════════════════════════════════
local State = {
    GuiVisible = true,
    ActivePanel = "features",
    -- Features
    FlyEnabled = false,
    InfiniteJumpEnabled = false,
    GodModeEnabled = false,
    ESPEnabled = false,
    InvisibleEnabled = false,
    NoclipEnabled = false,
    -- Values
    PlayerSpeed = 16,
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    -- Theme
    CurrentTheme = 1,
}

-- ═══════════════════════════════════════════════════════════════
-- THEMES
-- ═══════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════
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

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or GetTheme().Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, top, right, bottom, left)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 8)
    padding.PaddingRight = UDim.new(0, right or 8)
    padding.PaddingBottom = UDim.new(0, bottom or 8)
    padding.PaddingLeft = UDim.new(0, left or 8)
    padding.Parent = parent
    return padding
end

local function CreateGlow(parent, color, size)
    -- Simulated glow using ImageLabel with gradient
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, size or 20, 1, size or 20)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundColor3 = color or GetTheme().Primary
    glow.BackgroundTransparency = 0.85
    glow.BorderSizePixel = 0
    glow.ZIndex = parent.ZIndex - 1
    CreateCorner(glow, 12)
    glow.Parent = parent
    return glow
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

-- ═══════════════════════════════════════════════════════════════
-- DESTROY EXISTING GUI
-- ═══════════════════════════════════════════════════════════════
if game:GetService("CoreGui"):FindFirstChild("ExterFW") then
    game:GetService("CoreGui"):FindFirstChild("ExterFW"):Destroy()
end

-- ═══════════════════════════════════════════════════════════════
-- CREATE MAIN GUI
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExterFW"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN FRAME (Landscape Layout)
-- ═══════════════════════════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 750, 0, 480)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = GetTheme().Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
CreateCorner(MainFrame, 12)
CreateStroke(MainFrame, GetTheme().Border, 1)

-- Make draggable
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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

-- ═══════════════════════════════════════════════════════════════
-- SCAN LINE EFFECT (Overlay)
-- ═══════════════════════════════════════════════════════════════
local ScanLine = Instance.new("Frame")
ScanLine.Name = "ScanLine"
ScanLine.Size = UDim2.new(1, 0, 0, 2)
ScanLine.Position = UDim2.new(0, 0, 0, 0)
ScanLine.BackgroundColor3 = GetTheme().Primary
ScanLine.BackgroundTransparency = 0.9
ScanLine.BorderSizePixel = 0
ScanLine.ZIndex = 100
ScanLine.Parent = MainFrame

-- Animate scan line
spawn(function()
    while MainFrame and MainFrame.Parent do
        Tween(ScanLine, {Position = UDim2.new(0, 0, 1, 0)}, 3, Enum.EasingStyle.Linear)
        wait(3)
        ScanLine.Position = UDim2.new(0, 0, 0, 0)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- SIDEBAR
-- ═══════════════════════════════════════════════════════════════
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = GetTheme().Surface
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarBorder = Instance.new("Frame")
SidebarBorder.Name = "Border"
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Position = UDim2.new(1, 0, 0, 0)
SidebarBorder.BackgroundColor3 = GetTheme().Border
SidebarBorder.BorderSizePixel = 0
SidebarBorder.Parent = Sidebar

-- Logo Section
local LogoFrame = Instance.new("Frame")
LogoFrame.Name = "LogoFrame"
LogoFrame.Size = UDim2.new(1, 0, 0, 50)
LogoFrame.BackgroundTransparency = 1
LogoFrame.Parent = Sidebar

local LogoBadge = Instance.new("Frame")
LogoBadge.Name = "Badge"
LogoBadge.Size = UDim2.new(0, 30, 0, 30)
LogoBadge.Position = UDim2.new(0, 12, 0.5, 0)
LogoBadge.AnchorPoint = Vector2.new(0, 0.5)
LogoBadge.BackgroundColor3 = GetTheme().Primary
LogoBadge.BorderSizePixel = 0
LogoBadge.Parent = LogoFrame
CreateCorner(LogoBadge, 6)

local LogoBadgeText = Instance.new("TextLabel")
LogoBadgeText.Size = UDim2.new(1, 0, 1, 0)
LogoBadgeText.BackgroundTransparency = 1
LogoBadgeText.Text = "NX"
LogoBadgeText.TextColor3 = GetTheme().Background
LogoBadgeText.TextSize = 11
LogoBadgeText.Font = Enum.Font.GothamBold
LogoBadgeText.Parent = LogoBadge

local LogoTitle = Instance.new("TextLabel")
LogoTitle.Name = "Title"
LogoTitle.Size = UDim2.new(1, -55, 1, 0)
LogoTitle.Position = UDim2.new(0, 50, 0, 0)
LogoTitle.BackgroundTransparency = 1
LogoTitle.Text = "UNIVERSAL v2"
LogoTitle.TextColor3 = GetTheme().Primary
LogoTitle.TextSize = 14
LogoTitle.Font = Enum.Font.GothamBold
LogoTitle.TextXAlignment = Enum.TextXAlignment.Left
LogoTitle.Parent = LogoFrame

local LogoDivider = Instance.new("Frame")
LogoDivider.Size = UDim2.new(1, -20, 0, 1)
LogoDivider.Position = UDim2.new(0, 10, 1, 0)
LogoDivider.BackgroundColor3 = GetTheme().Border
LogoDivider.BorderSizePixel = 0
LogoDivider.Parent = LogoFrame

-- Navigation Buttons
local NavItems = {
    {id = "features", label = "⚡ Features"},
    {id = "server", label = "🖥️ Server Info"},
    {id = "utilities", label = "🔧 Utilities"},
    {id = "analyzer", label = "📜 Script Analyzer"},
    {id = "credits", label = "❤️ Credits"},
    {id = "themes", label = "🎨 Themes"},
    {id = "settings", label = "⚙️ Settings"},
}

local NavButtons = {}
local ContentPanels = {}

local NavContainer = Instance.new("Frame")
NavContainer.Name = "NavContainer"
NavContainer.Size = UDim2.new(1, 0, 1, -55)
NavContainer.Position = UDim2.new(0, 0, 0, 55)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 2)
NavLayout.Parent = NavContainer
CreatePadding(NavContainer, 4, 8, 4, 8)

for i, item in ipairs(NavItems) do
    local btn = Instance.new("TextButton")
    btn.Name = "Nav_" .. item.id
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = GetTheme().Surface
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = item.label
    btn.TextColor3 = GetTheme().TextSecondary
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = i
    btn.Parent = NavContainer
    CreateCorner(btn, 8)
    CreatePadding(btn, 0, 10, 0, 10)

    -- Active indicator
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, 0, 0.2, 0)
    indicator.BackgroundColor3 = GetTheme().Primary
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    CreateCorner(indicator, 2)

    NavButtons[item.id] = {Button = btn, Indicator = indicator}

    btn.MouseButton1Click:Connect(function()
        State.ActivePanel = item.id
        -- Update nav visuals
        for id, nav in pairs(NavButtons) do
            if id == item.id then
                Tween(nav.Button, {BackgroundTransparency = 0.85, TextColor3 = GetTheme().Primary}, 0.2)
                Tween(nav.Indicator, {BackgroundTransparency = 0}, 0.2)
            else
                Tween(nav.Button, {BackgroundTransparency = 1, TextColor3 = GetTheme().TextSecondary}, 0.2)
                Tween(nav.Indicator, {BackgroundTransparency = 1}, 0.2)
            end
        end
        -- Show/hide panels
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

-- ═══════════════════════════════════════════════════════════════
-- CONTENT AREA
-- ═══════════════════════════════════════════════════════════════
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -182, 1, -40)
ContentArea.Position = UDim2.new(0, 182, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 4
ContentArea.ScrollBarImageColor3 = GetTheme().Primary
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, -182, 0, 40)
TopBar.Position = UDim2.new(0, 182, 0, 0)
TopBar.BackgroundColor3 = GetTheme().Surface
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 10
TopBar.Parent = MainFrame

local TopBarDivider = Instance.new("Frame")
TopBarDivider.Size = UDim2.new(1, 0, 0, 1)
TopBarDivider.Position = UDim2.new(0, 0, 1, 0)
TopBarDivider.BackgroundColor3 = GetTheme().Border
TopBarDivider.BorderSizePixel = 0
TopBarDivider.Parent = TopBar

local TopBarTitle = Instance.new("TextLabel")
TopBarTitle.Name = "PanelTitle"
TopBarTitle.Size = UDim2.new(0.5, 0, 1, 0)
TopBarTitle.Position = UDim2.new(0, 15, 0, 0)
TopBarTitle.BackgroundTransparency = 1
TopBarTitle.Text = "⚡ FEATURES"
TopBarTitle.TextColor3 = GetTheme().Text
TopBarTitle.TextSize = 12
TopBarTitle.Font = Enum.Font.GothamBold
TopBarTitle.TextXAlignment = Enum.TextXAlignment.Left
TopBarTitle.Parent = TopBar

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -80, 0.5, 0)
StatusDot.AnchorPoint = Vector2.new(0, 0.5)
StatusDot.BackgroundColor3 = Color3.fromHex("#00ff88")
StatusDot.BorderSizePixel = 0
StatusDot.Parent = TopBar
CreateCorner(StatusDot, 4)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 60, 1, 0)
StatusText.Position = UDim2.new(1, -65, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Connected"
StatusText.TextColor3 = GetTheme().TextSecondary
StatusText.TextSize = 10
StatusText.Font = Enum.Font.Gotham
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = TopBar

-- ═══════════════════════════════════════════════════════════════
-- HELPER: Create Panel Container
-- ═══════════════════════════════════════════════════════════════
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
    CreatePadding(panel, 12, 15, 12, 15)
    
    ContentPanels[name] = panel
    return panel
end

-- Helper: Section Header
local function CreateSectionHeader(parent, text, order)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundTransparency = 1
    header.Text = text
    header.TextColor3 = GetTheme().Primary
    header.TextSize = 14
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = order or 0
    header.Parent = parent
    return header
end

-- Helper: Toggle Row
local function CreateToggle(parent, label, description, order, callback)
    local row = Instance.new("Frame")
    row.Name = "Toggle_" .. label
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = GetTheme().SurfaceHover
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 0
    row.Parent = parent
    CreateCorner(row, 10)
    CreateStroke(row, GetTheme().Border, 1)

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, -10, 0, 18)
    labelText.Position = UDim2.new(0, 15, 0, 8)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = GetTheme().Text
    labelText.TextSize = 13
    labelText.Font = Enum.Font.GothamBold
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = row

    local descText = Instance.new("TextLabel")
    descText.Size = UDim2.new(0.6, -10, 0, 14)
    descText.Position = UDim2.new(0, 15, 0, 28)
    descText.BackgroundTransparency = 1
    descText.Text = description
    descText.TextColor3 = GetTheme().TextSecondary
    descText.TextSize = 10
    descText.Font = Enum.Font.Gotham
    descText.TextXAlignment = Enum.TextXAlignment.Left
    descText.Parent = row

    -- Toggle switch
    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 44, 0, 22)
    toggleBg.Position = UDim2.new(1, -60, 0.5, 0)
    toggleBg.AnchorPoint = Vector2.new(0, 0.5)
    toggleBg.BackgroundColor3 = GetTheme().Border
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row
    CreateCorner(toggleBg, 11)

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, 0)
    toggleKnob.AnchorPoint = Vector2.new(0, 0.5)
    toggleKnob.BackgroundColor3 = GetTheme().TextSecondary
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg
    CreateCorner(toggleKnob, 9)

    local enabled = false
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = row

    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            Tween(toggleBg, {BackgroundColor3 = GetTheme().Primary}, 0.2)
            Tween(toggleKnob, {Position = UDim2.new(0, 24, 0.5, 0), BackgroundColor3 = GetTheme().Background}, 0.2)
            Tween(labelText, {TextColor3 = GetTheme().Primary}, 0.2)
            CreateStroke(row, GetTheme().Primary, 1, 0.6)
        else
            Tween(toggleBg, {BackgroundColor3 = GetTheme().Border}, 0.2)
            Tween(toggleKnob, {Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = GetTheme().TextSecondary}, 0.2)
            Tween(labelText, {TextColor3 = GetTheme().Text}, 0.2)
            CreateStroke(row, GetTheme().Border, 1)
        end
        if callback then callback(enabled) end
    end)

    return row, toggleBtn, enabled
end

-- Helper: Slider
local function CreateSlider(parent, label, min, max, default, order, callback)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. label
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundColor3 = GetTheme().SurfaceHover
    container.BorderSizePixel = 0
    container.LayoutOrder = order or 0
    container.Parent = parent
    CreateCorner(container, 10)
    CreateStroke(container, GetTheme().Border, 1)

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.5, 0, 0, 20)
    labelText.Position = UDim2.new(0, 15, 0, 6)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = GetTheme().Text
    labelText.TextSize = 12
    labelText.Font = Enum.Font.GothamBold
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.7, -15, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = GetTheme().Primary
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container

    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -30, 0, 6)
    track.Position = UDim2.new(0, 15, 0, 34)
    track.BackgroundColor3 = GetTheme().Border
    track.BorderSizePixel = 0
    track.Parent = container
    CreateCorner(track, 3)

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = GetTheme().Primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    CreateCorner(fill, 3)

    -- Min/Max labels
    local minLabel = Instance.new("TextLabel")
    minLabel.Size = UDim2.new(0.2, 0, 0, 14)
    minLabel.Position = UDim2.new(0, 15, 0, 44)
    minLabel.BackgroundTransparency = 1
    minLabel.Text = tostring(min)
    minLabel.TextColor3 = GetTheme().TextSecondary
    minLabel.TextSize = 9
    minLabel.Font = Enum.Font.Gotham
    minLabel.TextXAlignment = Enum.TextXAlignment.Left
    minLabel.Parent = container

    local maxLabel = Instance.new("TextLabel")
    maxLabel.Size = UDim2.new(0.2, 0, 0, 14)
    maxLabel.Position = UDim2.new(0.8, -15, 0, 44)
    maxLabel.BackgroundTransparency = 1
    maxLabel.Text = tostring(max)
    maxLabel.TextColor3 = GetTheme().TextSecondary
    maxLabel.TextSize = 9
    maxLabel.Font = Enum.Font.Gotham
    maxLabel.TextXAlignment = Enum.TextXAlignment.Right
    maxLabel.Parent = container

    -- Slider interaction
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, -30, 0, 20)
    sliderBtn.Position = UDim2.new(0, 15, 0, 28)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = container

    local sliding = false
    sliderBtn.MouseButton1Down:Connect(function()
        sliding = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local trackAbsPos = track.AbsolutePosition.X
            local trackAbsSize = track.AbsoluteSize.X
            local mouseX = input.Position.X
            local percent = math.clamp((mouseX - trackAbsPos) / trackAbsSize, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = tostring(value)
            if callback then callback(value) end
        end
    end)

    return container
end

-- Helper: Action Button
local function CreateActionButton(parent, label, color, order, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "Action_" .. label
    btn.Size = UDim2.new(0.48, 0, 0, 40)
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
    CreateStroke(btn, color or GetTheme().Primary, 1, 0.7)

    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundTransparency = 0.7}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundTransparency = 0.85}, 0.15)
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

-- ═══════════════════════════════════════════════════════════════
-- PANEL 1: FEATURES
-- ═══════════════════════════════════════════════════════════════
local featuresPanel = CreatePanel("features", true)

CreateSectionHeader(featuresPanel, "GAME MODIFICATIONS", 1)

CreateToggle(featuresPanel, "FLY", "Fly freely in the game world", 2, function(enabled)
    State.FlyEnabled = enabled
end)

CreateToggle(featuresPanel, "INFINITE JUMP", "Jump unlimited times in air", 3, function(enabled)
    State.InfiniteJumpEnabled = enabled
end)

CreateToggle(featuresPanel, "GOD MODE", "Become invincible to damage", 4, function(enabled)
    State.GodModeEnabled = enabled
end)

CreateToggle(featuresPanel, "ESP / WALLHACK", "See players through walls", 5, function(enabled)
    State.ESPEnabled = enabled
end)

CreateToggle(featuresPanel, "INVISIBLE", "Become invisible to others", 6, function(enabled)
    State.InvisibleEnabled = enabled
end)

CreateSectionHeader(featuresPanel, "PARAMETERS", 7)

CreateSlider(featuresPanel, "PLAYER SPEED", 1, 500, 16, 8, function(value)
    State.PlayerSpeed = value
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = value end
end)

CreateSlider(featuresPanel, "FLY SPEED", 1, 500, 50, 9, function(value)
    State.FlySpeed = value
end)

-- ═══════════════════════════════════════════════════════════════
-- PANEL 2: SERVER INFO
-- ═══════════════════════════════════════════════════════════════
local serverPanel = CreatePanel("server", false)

CreateSectionHeader(serverPanel, "SERVER DETAILS", 1)

-- Server info cards
local serverInfoFrame = Instance.new("Frame")
serverInfoFrame.Name = "ServerInfo"
serverInfoFrame.Size = UDim2.new(1, 0, 0, 0)
serverInfoFrame.AutomaticSize = Enum.AutomaticSize.Y
serverInfoFrame.BackgroundTransparency = 1
serverInfoFrame.LayoutOrder = 2
serverInfoFrame.Parent = serverPanel

local serverInfoLayout = Instance.new("UIGridLayout")
serverInfoLayout.CellSize = UDim2.new(0.32, 0, 0, 55)
serverInfoLayout.CellPadding = UDim2.new(0.02, 0, 0, 6)
serverInfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
serverInfoLayout.Parent = serverInfoFrame

local serverStats = {
    {"Server", game.Name ~= "" and game.Name or "Unknown", 1},
    {"Ping", "Calculating...", 2},
    {"PlaceId", tostring(game.PlaceId), 3},
    {"Admins", "N/A", 4},
    {"Players", tostring(#Players:GetPlayers()) .. "/" .. tostring(Players.MaxPlayers), 5},
    {"JobId", string.sub(game.JobId, 1, 8) .. "...", 6},
}

for _, stat in ipairs(serverStats) do
    local card = Instance.new("Frame")
    card.BackgroundColor3 = GetTheme().SurfaceHover
    card.BorderSizePixel = 0
    card.LayoutOrder = stat[3]
    card.Parent = serverInfoFrame
    CreateCorner(card, 8)
    CreateStroke(card, GetTheme().Border, 1)

    local statLabel = Instance.new("TextLabel")
    statLabel.Size = UDim2.new(1, -10, 0, 16)
    statLabel.Position = UDim2.new(0, 5, 0, 6)
    statLabel.BackgroundTransparency = 1
    statLabel.Text = stat[1]
    statLabel.TextColor3 = GetTheme().TextSecondary
    statLabel.TextSize = 9
    statLabel.Font = Enum.Font.Gotham
    statLabel.TextXAlignment = Enum.TextXAlignment.Center
    statLabel.Parent = card

    local statValue = Instance.new("TextLabel")
    statValue.Name = "Value"
    statValue.Size = UDim2.new(1, -10, 0, 20)
    statValue.Position = UDim2.new(0, 5, 0, 26)
    statValue.BackgroundTransparency = 1
    statValue.Text = stat[2]
    statValue.TextColor3 = GetTheme().Text
    statValue.TextSize = 11
    statValue.Font = Enum.Font.GothamBold
    statValue.TextXAlignment = Enum.TextXAlignment.Center
    statValue.TextTruncate = Enum.TextTruncate.AtEnd
    statValue.Parent = card
end

-- Teleport Actions
CreateSectionHeader(serverPanel, "TELEPORT ACTIONS", 3)

local teleportFrame = Instance.new("Frame")
teleportFrame.Name = "TeleportActions"
teleportFrame.Size = UDim2.new(1, 0, 0, 0)
teleportFrame.AutomaticSize = Enum.AutomaticSize.Y
teleportFrame.BackgroundTransparency = 1
teleportFrame.LayoutOrder = 4
teleportFrame.Parent = serverPanel

local teleportLayout = Instance.new("UIGridLayout")
teleportLayout.CellSize = UDim2.new(0.48, 0, 0, 36)
teleportLayout.CellPadding = UDim2.new(0.04, 0, 0, 6)
teleportLayout.SortOrder = Enum.SortOrder.LayoutOrder
teleportLayout.Parent = teleportFrame

local function TeleportToSpawn()
    local root = GetRootPart()
    if root then
        local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then
            root.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

local function TeleportToCheckpoint()
    local root = GetRootPart()
    if root then
        -- Try common checkpoint names
        for _, name in ipairs({"Checkpoint", "CP", "Stage", "checkpoint", "cp"}) do
            local cp = Workspace:FindFirstChild(name, true)
            if cp and cp:IsA("BasePart") then
                root.CFrame = cp.CFrame + Vector3.new(0, 5, 0)
                return
            end
        end
    end
end

CreateActionButton(teleportFrame, "🏠 TP to Spawn", GetTheme().Primary, 1, TeleportToSpawn)
CreateActionButton(teleportFrame, "🚩 TP to Checkpoint", GetTheme().Primary, 2, TeleportToCheckpoint)
CreateActionButton(teleportFrame, "▶️ Auto Submit", GetTheme().Success, 3, function()
    -- Auto submit logic - fires common remote events
    pcall(function()
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("submit") or v.Name:lower():find("finish") or v.Name:lower():find("complete")) then
                v:FireServer()
            end
        end
    end)
end)

-- Player List
CreateSectionHeader(serverPanel, "PLAYER LIST", 5)

local playerListFrame = Instance.new("Frame")
playerListFrame.Name = "PlayerList"
playerListFrame.Size = UDim2.new(1, 0, 0, 200)
playerListFrame.BackgroundColor3 = GetTheme().SurfaceHover
playerListFrame.BorderSizePixel = 0
playerListFrame.LayoutOrder = 6
playerListFrame.ClipsDescendants = true
playerListFrame.Parent = serverPanel
CreateCorner(playerListFrame, 10)
CreateStroke(playerListFrame, GetTheme().Border, 1)

-- Search bar
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, 0, 0, 32)
searchFrame.BackgroundColor3 = GetTheme().Surface
searchFrame.BorderSizePixel = 0
searchFrame.Parent = playerListFrame

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
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

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Name = "PlayerScroll"
playerScroll.Size = UDim2.new(1, 0, 1, -34)
playerScroll.Position = UDim2.new(0, 0, 0, 34)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 3
playerScroll.ScrollBarImageColor3 = GetTheme().Primary
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.Parent = playerListFrame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Padding = UDim.new(0, 1)
playerListLayout.Parent = playerScroll

local function RefreshPlayerList(query)
    for _, child in ipairs(playerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for i, player in ipairs(Players:GetPlayers()) do
        local name = player.Name:lower()
        local displayName = player.DisplayName:lower()
        local q = (query or ""):lower()
        
        if q == "" or name:find(q) or displayName:find(q) then
            local row = Instance.new("Frame")
            row.Name = "Player_" .. player.Name
            row.Size = UDim2.new(1, 0, 0, 34)
            row.BackgroundColor3 = GetTheme().Surface
            row.BackgroundTransparency = i % 2 == 0 and 0.5 or 1
            row.BorderSizePixel = 0
            row.LayoutOrder = i
            row.Parent = playerScroll

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.55, -10, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
            nameLabel.TextColor3 = GetTheme().Text
            nameLabel.TextSize = 10
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = row

            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0, 70, 0, 24)
            tpBtn.Position = UDim2.new(1, -80, 0.5, 0)
            tpBtn.AnchorPoint = Vector2.new(0, 0.5)
            tpBtn.BackgroundColor3 = GetTheme().Primary
            tpBtn.BackgroundTransparency = 0.8
            tpBtn.Text = "TELEPORT"
            tpBtn.TextColor3 = GetTheme().Primary
            tpBtn.TextSize = 9
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.Parent = row
            CreateCorner(tpBtn, 6)
            CreateStroke(tpBtn, GetTheme().Primary, 1, 0.6)

            tpBtn.MouseButton1Click:Connect(function()
                local root = GetRootPart()
                local targetChar = player.Character
                if root and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                    root.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end)
        end
    end
end

RefreshPlayerList("")
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    RefreshPlayerList(searchBox.Text)
end)
Players.PlayerAdded:Connect(function() RefreshPlayerList(searchBox.Text) end)
Players.PlayerRemoving:Connect(function() wait(0.1) RefreshPlayerList(searchBox.Text) end)

-- ═══════════════════════════════════════════════════════════════
-- PANEL 3: UTILITIES
-- ═══════════════════════════════════════════════════════════════
local utilitiesPanel = CreatePanel("utilities", false)

CreateSectionHeader(utilitiesPanel, "CHARACTER CONTROLS", 1)

CreateSlider(utilitiesPanel, "WALKSPEED", 0, 500, 16, 2, function(value)
    State.WalkSpeed = value
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = value end
end)

CreateSlider(utilitiesPanel, "JUMP POWER", 0, 500, 50, 3, function(value)
    State.JumpPower = value
    local hum = GetHumanoid()
    if hum then hum.JumpPower = value end
end)

CreateToggle(utilitiesPanel, "NOCLIP", "Walk through walls and objects", 4, function(enabled)
    State.NoclipEnabled = enabled
end)

CreateSectionHeader(utilitiesPanel, "SERVER UTILITIES", 5)

local utilBtnFrame = Instance.new("Frame")
utilBtnFrame.Name = "UtilButtons"
utilBtnFrame.Size = UDim2.new(1, 0, 0, 0)
utilBtnFrame.AutomaticSize = Enum.AutomaticSize.Y
utilBtnFrame.BackgroundTransparency = 1
utilBtnFrame.LayoutOrder = 6
utilBtnFrame.Parent = utilitiesPanel

local utilBtnLayout = Instance.new("UIGridLayout")
utilBtnLayout.CellSize = UDim2.new(0.48, 0, 0, 40)
utilBtnLayout.CellPadding = UDim2.new(0.04, 0, 0, 6)
utilBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
utilBtnLayout.Parent = utilBtnFrame

CreateActionButton(utilBtnFrame, "🔄 Reset Character", Color3.fromHex("#ff3355"), 1, function()
    local hum = GetHumanoid()
    if hum then hum.Health = 0 end
end)

CreateActionButton(utilBtnFrame, "🔁 Rejoin Server", Color3.fromHex("#ffaa00"), 2, function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateActionButton(utilBtnFrame, "📋 Copy JobId", GetTheme().Primary, 3, function()
    pcall(function()
        setclipboard(game.JobId)
    end)
end)

CreateActionButton(utilBtnFrame, "🔀 Server Hop", Color3.fromHex("#7b2dff"), 4, function()
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if servers and servers.data then
            for _, server in ipairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- PANEL 4: SCRIPT ANALYZER
-- ═══════════════════════════════════════════════════════════════
local analyzerPanel = CreatePanel("analyzer", false)

CreateSectionHeader(analyzerPanel, "LUA CHECKER — DETECTED SCRIPTS", 1)

-- Stats
local statsFrame = Instance.new("Frame")
statsFrame.Name = "Stats"
statsFrame.Size = UDim2.new(1, 0, 0, 0)
statsFrame.AutomaticSize = Enum.AutomaticSize.Y
statsFrame.BackgroundTransparency = 1
statsFrame.LayoutOrder = 2
statsFrame.Parent = analyzerPanel

local statsLayout = Instance.new("UIGridLayout")
statsLayout.CellSize = UDim2.new(0.24, 0, 0, 45)
statsLayout.CellPadding = UDim2.new(0.01, 0, 0, 4)
statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
statsLayout.Parent = statsFrame

-- Count scripts
local function CountScripts()
    local total, localScripts, serverScripts, moduleScripts = 0, 0, 0, 0
    pcall(function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("LocalScript") then localScripts = localScripts + 1; total = total + 1
            elseif v:IsA("Script") and not v:IsA("LocalScript") then serverScripts = serverScripts + 1; total = total + 1
            elseif v:IsA("ModuleScript") then moduleScripts = moduleScripts + 1; total = total + 1
            end
        end
    end)
    return total, localScripts, serverScripts, moduleScripts
end

local totalS, localS, serverS, moduleS = CountScripts()

local scriptStats = {
    {"Total", tostring(totalS), GetTheme().Primary, 1},
    {"LocalScript", tostring(localS), Color3.fromHex("#00f0ff"), 2},
    {"Script", tostring(serverS), Color3.fromHex("#ff00aa"), 3},
    {"ModuleScript", tostring(moduleS), Color3.fromHex("#7b2dff"), 4},
}

for _, stat in ipairs(scriptStats) do
    local card = Instance.new("Frame")
    card.BackgroundColor3 = GetTheme().SurfaceHover
    card.BorderSizePixel = 0
    card.LayoutOrder = stat[4]
    card.Parent = statsFrame
    CreateCorner(card, 8)
    CreateStroke(card, GetTheme().Border, 1)

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, 0, 0, 22)
    val.Position = UDim2.new(0, 0, 0, 4)
    val.BackgroundTransparency = 1
    val.Text = stat[2]
    val.TextColor3 = stat[3]
    val.TextSize = 16
    val.Font = Enum.Font.GothamBold
    val.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.Position = UDim2.new(0, 0, 0, 26)
    lbl.BackgroundTransparency = 1
    lbl.Text = stat[1]
    lbl.TextColor3 = GetTheme().TextSecondary
    lbl.TextSize = 9
    lbl.Font = Enum.Font.Gotham
    lbl.Parent = card
end

-- Script list (terminal style)
local terminalFrame = Instance.new("ScrollingFrame")
terminalFrame.Name = "Terminal"
terminalFrame.Size = UDim2.new(1, 0, 0, 250)
terminalFrame.BackgroundColor3 = GetTheme().Surface
terminalFrame.BorderSizePixel = 0
terminalFrame.ScrollBarThickness = 3
terminalFrame.ScrollBarImageColor3 = GetTheme().Primary
terminalFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
terminalFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
terminalFrame.LayoutOrder = 3
terminalFrame.Parent = analyzerPanel
CreateCorner(terminalFrame, 10)
CreateStroke(terminalFrame, GetTheme().Border, 1)

-- Terminal header
local termHeader = Instance.new("Frame")
termHeader.Size = UDim2.new(1, 0, 0, 28)
termHeader.BackgroundColor3 = GetTheme().SurfaceHover
termHeader.BorderSizePixel = 0
termHeader.Parent = terminalFrame

local dots = Instance.new("Frame")
dots.Size = UDim2.new(0, 50, 0, 12)
dots.Position = UDim2.new(0, 10, 0.5, 0)
dots.AnchorPoint = Vector2.new(0, 0.5)
dots.BackgroundTransparency = 1
dots.Parent = termHeader

for idx, col in ipairs({Color3.fromHex("#ff3355"), Color3.fromHex("#ffaa00"), Color3.fromHex("#00ff88")}) do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, (idx - 1) * 16, 0.5, 0)
    dot.AnchorPoint = Vector2.new(0, 0.5)
    dot.BackgroundColor3 = col
    dot.BorderSizePixel = 0
    dot.Parent = dots
    CreateCorner(dot, 5)
end

local termTitle = Instance.new("TextLabel")
termTitle.Size = UDim2.new(1, -80, 1, 0)
termTitle.Position = UDim2.new(0, 70, 0, 0)
termTitle.BackgroundTransparency = 1
termTitle.Text = "lua_analyzer.exe"
termTitle.TextColor3 = GetTheme().TextSecondary
termTitle.TextSize = 10
termTitle.Font = Enum.Font.Code
termTitle.TextXAlignment = Enum.TextXAlignment.Left
termTitle.Parent = termHeader

local termContent = Instance.new("Frame")
termContent.Name = "Content"
termContent.Size = UDim2.new(1, 0, 0, 0)
termContent.Position = UDim2.new(0, 0, 0, 30)
termContent.AutomaticSize = Enum.AutomaticSize.Y
termContent.BackgroundTransparency = 1
termContent.Parent = terminalFrame

local termContentLayout = Instance.new("UIListLayout")
termContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
termContentLayout.Padding = UDim.new(0, 1)
termContentLayout.Parent = termContent

-- Populate script list
pcall(function()
    local order = 0
    local locations = {
        game:GetService("StarterPlayer"),
        game:GetService("StarterGui"),
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
    }
    
    -- Also try accessible services
    pcall(function() table.insert(locations, game:GetService("ServerScriptService")) end)
    pcall(function() table.insert(locations, game:GetService("ServerStorage")) end)
    
    for _, location in ipairs(locations) do
        pcall(function()
            for _, v in pairs(location:GetDescendants()) do
                if v:IsA("LocalScript") or v:IsA("ModuleScript") or (v:IsA("Script") and not v:IsA("LocalScript")) then
                    order = order + 1
                    if order > 50 then return end -- Limit display
                    
                    local scriptType = v.ClassName
                    local typeColor = scriptType == "LocalScript" and Color3.fromHex("#00f0ff") 
                        or scriptType == "ModuleScript" and Color3.fromHex("#7b2dff") 
                        or Color3.fromHex("#ff00aa")
                    
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, 0, 0, 28)
                    row.BackgroundColor3 = GetTheme().Surface
                    row.BackgroundTransparency = order % 2 == 0 and 0.3 or 0.6
                    row.BorderSizePixel = 0
                    row.LayoutOrder = order
                    row.Parent = termContent

                    local scriptName = Instance.new("TextLabel")
                    scriptName.Size = UDim2.new(0.4, -5, 1, 0)
                    scriptName.Position = UDim2.new(0, 10, 0, 0)
                    scriptName.BackgroundTransparency = 1
                    scriptName.Text = "📄 " .. v.Name
                    scriptName.TextColor3 = GetTheme().Text
                    scriptName.TextSize = 10
                    scriptName.Font = Enum.Font.Code
                    scriptName.TextXAlignment = Enum.TextXAlignment.Left
                    scriptName.TextTruncate = Enum.TextTruncate.AtEnd
                    scriptName.Parent = row

                    local scriptTypeLabel = Instance.new("TextLabel")
                    scriptTypeLabel.Size = UDim2.new(0.25, 0, 1, 0)
                    scriptTypeLabel.Position = UDim2.new(0.4, 0, 0, 0)
                    scriptTypeLabel.BackgroundTransparency = 1
                    scriptTypeLabel.Text = scriptType
                    scriptTypeLabel.TextColor3 = typeColor
                    scriptTypeLabel.TextSize = 9
                    scriptTypeLabel.Font = Enum.Font.Code
                    scriptTypeLabel.Parent = row

                    local scriptPath = Instance.new("TextLabel")
                    scriptPath.Size = UDim2.new(0.35, -10, 1, 0)
                    scriptPath.Position = UDim2.new(0.65, 0, 0, 0)
                    scriptPath.BackgroundTransparency = 1
                    scriptPath.Text = v.Parent and v.Parent:GetFullName() or "Unknown"
                    scriptPath.TextColor3 = GetTheme().TextSecondary
                    scriptPath.TextSize = 8
                    scriptPath.Font = Enum.Font.Code
                    scriptPath.TextXAlignment = Enum.TextXAlignment.Right
                    scriptPath.TextTruncate = Enum.TextTruncate.AtEnd
                    scriptPath.Parent = row
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- PANEL 5: CREDITS & PLAYER INFO
-- ═══════════════════════════════════════════════════════════════
local creditsPanel = CreatePanel("credits", false)

CreateSectionHeader(creditsPanel, "PLAYER INFORMATION", 1)

local playerInfoFrame = Instance.new("Frame")
playerInfoFrame.Name = "PlayerInfo"
playerInfoFrame.Size = UDim2.new(1, 0, 0, 0)
playerInfoFrame.AutomaticSize = Enum.AutomaticSize.Y
playerInfoFrame.BackgroundColor3 = GetTheme().SurfaceHover
playerInfoFrame.BorderSizePixel = 0
playerInfoFrame.LayoutOrder = 2
playerInfoFrame.Parent = creditsPanel
CreateCorner(playerInfoFrame, 10)
CreateStroke(playerInfoFrame, GetTheme().Primary, 1, 0.7)

local piLayout = Instance.new("UIGridLayout")
piLayout.CellSize = UDim2.new(0.48, 0, 0, 45)
piLayout.CellPadding = UDim2.new(0.04, 0, 0, 6)
piLayout.SortOrder = Enum.SortOrder.LayoutOrder
piLayout.Parent = playerInfoFrame
CreatePadding(playerInfoFrame, 10, 10, 10, 10)

local playerData = {
    {"Username", LocalPlayer.Name, 1},
    {"Display Name", LocalPlayer.DisplayName, 2},
    {"UserId", tostring(LocalPlayer.UserId), 3},
    {"Status", "Online ✅", 4},
    {"Account Age", tostring(LocalPlayer.AccountAge) .. " days", 5},
    {"Membership", tostring(LocalPlayer.MembershipType), 6},
}

for _, data in ipairs(playerData) do
    local card = Instance.new("Frame")
    card.BackgroundColor3 = GetTheme().Surface
    card.BorderSizePixel = 0
    card.LayoutOrder = data[3]
    card.Parent = playerInfoFrame
    CreateCorner(card, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 14)
    lbl.Position = UDim2.new(0, 5, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = data[1]
    lbl.TextColor3 = GetTheme().TextSecondary
    lbl.TextSize = 9
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, -10, 0, 18)
    val.Position = UDim2.new(0, 5, 0, 20)
    val.BackgroundTransparency = 1
    val.Text = data[2]
    val.TextColor3 = GetTheme().Text
    val.TextSize = 11
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.TextTruncate = Enum.TextTruncate.AtEnd
    val.Parent = card
end

-- Credits
CreateSectionHeader(creditsPanel, "DEVELOPMENT TEAM", 3)

local creditsData = {
    {"Lead Developer & Engineer", "Sobing4413", "Core GUI Framework & Features"},
}

for i, credit in ipairs(creditsData) do
    local card = Instance.new("Frame")
    card.Name = "Credit_" .. i
    card.Size = UDim2.new(1, 0, 0, 50)
    card.BackgroundColor3 = GetTheme().SurfaceHover
    card.BorderSizePixel = 0
    card.LayoutOrder = 3 + i
    card.Parent = creditsPanel
    CreateCorner(card, 10)
    CreateStroke(card, GetTheme().Border, 1)

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 36, 0, 36)
    badge.Position = UDim2.new(0, 10, 0.5, 0)
    badge.AnchorPoint = Vector2.new(0, 0.5)
    badge.BackgroundColor3 = GetTheme().Primary
    badge.BackgroundTransparency = 0.85
    badge.BorderSizePixel = 0
    badge.Parent = card
    CreateCorner(badge, 8)

    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = credit[2]:sub(1, 1)
    badgeText.TextColor3 = GetTheme().Primary
    badgeText.TextSize = 14
    badgeText.Font = Enum.Font.GothamBold
    badgeText.Parent = badge

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, -60, 0, 16)
    nameLabel.Position = UDim2.new(0, 55, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = credit[2]
    nameLabel.TextColor3 = GetTheme().Text
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(0.6, -60, 0, 14)
    roleLabel.Position = UDim2.new(0, 55, 0, 26)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = credit[1] .. " — " .. credit[3]
    roleLabel.TextColor3 = GetTheme().TextSecondary
    roleLabel.TextSize = 9
    roleLabel.Font = Enum.Font.Gotham
    roleLabel.TextXAlignment = Enum.TextXAlignment.Left
    roleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    roleLabel.Parent = card
end

-- Version
local versionFrame = Instance.new("Frame")
versionFrame.Name = "Version"
versionFrame.Size = UDim2.new(1, 0, 0, 40)
versionFrame.BackgroundColor3 = GetTheme().SurfaceHover
versionFrame.BackgroundTransparency = 0.5
versionFrame.BorderSizePixel = 0
versionFrame.LayoutOrder = 10
versionFrame.Parent = creditsPanel
CreateCorner(versionFrame, 10)

local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(1, 0, 1, 0)
versionText.BackgroundTransparency = 1
versionText.Text = "UNIVERSAL v2 v2.5.0 • Universal Roblox Script GUI • Built with ❤️"
versionText.TextColor3 = GetTheme().TextSecondary
versionText.TextSize = 10
versionText.Font = Enum.Font.Gotham
versionText.Parent = versionFrame

-- ═══════════════════════════════════════════════════════════════
-- PANEL 6: THEMES
-- ═══════════════════════════════════════════════════════════════
local themesPanel = CreatePanel("themes", false)

CreateSectionHeader(themesPanel, "SELECT THEME", 1)

for i, theme in ipairs(Themes) do
    local themeBtn = Instance.new("TextButton")
    themeBtn.Name = "Theme_" .. theme.Name
    themeBtn.Size = UDim2.new(1, 0, 0, 45)
    themeBtn.BackgroundColor3 = theme.SurfaceHover
    themeBtn.BorderSizePixel = 0
    themeBtn.Text = ""
    themeBtn.LayoutOrder = i + 1
    themeBtn.Parent = themesPanel
    CreateCorner(themeBtn, 10)
    CreateStroke(themeBtn, i == State.CurrentTheme and theme.Primary or theme.Border, 1)

    -- Color dots
    local dot1 = Instance.new("Frame")
    dot1.Size = UDim2.new(0, 16, 0, 16)
    dot1.Position = UDim2.new(0, 15, 0.5, 0)
    dot1.AnchorPoint = Vector2.new(0, 0.5)
    dot1.BackgroundColor3 = theme.Primary
    dot1.BorderSizePixel = 0
    dot1.Parent = themeBtn
    CreateCorner(dot1, 8)

    local dot2 = Instance.new("Frame")
    dot2.Size = UDim2.new(0, 16, 0, 16)
    dot2.Position = UDim2.new(0, 36, 0.5, 0)
    dot2.AnchorPoint = Vector2.new(0, 0.5)
    dot2.BackgroundColor3 = theme.Secondary
    dot2.BorderSizePixel = 0
    dot2.Parent = themeBtn
    CreateCorner(dot2, 8)

    local themeName = Instance.new("TextLabel")
    themeName.Size = UDim2.new(0.6, -60, 1, 0)
    themeName.Position = UDim2.new(0, 60, 0, 0)
    themeName.BackgroundTransparency = 1
    themeName.Text = theme.Name
    themeName.TextColor3 = theme.Text
    themeName.TextSize = 12
    themeName.Font = Enum.Font.GothamBold
    themeName.TextXAlignment = Enum.TextXAlignment.Left
    themeName.Parent = themeBtn

    if i == State.CurrentTheme then
        local activeLabel = Instance.new("TextLabel")
        activeLabel.Name = "ActiveLabel"
        activeLabel.Size = UDim2.new(0, 50, 0, 20)
        activeLabel.Position = UDim2.new(1, -65, 0.5, 0)
        activeLabel.AnchorPoint = Vector2.new(0, 0.5)
        activeLabel.BackgroundColor3 = theme.Primary
        activeLabel.BackgroundTransparency = 0.8
        activeLabel.Text = "Active"
        activeLabel.TextColor3 = theme.Primary
        activeLabel.TextSize = 9
        activeLabel.Font = Enum.Font.GothamBold
        activeLabel.Parent = themeBtn
        CreateCorner(activeLabel, 4)
    end

    themeBtn.MouseButton1Click:Connect(function()
        State.CurrentTheme = i
        -- Note: Full theme switching requires recreating the GUI
        -- For simplicity, we show a notification
        StarterGui:SetCore("SendNotification", {
            Title = "UNIVERSAL v2",
            Text = "Theme changed to " .. theme.Name .. ". Re-execute script to apply.",
            Duration = 3,
        })
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- PANEL 7: SETTINGS
-- ═══════════════════════════════════════════════════════════════
local settingsPanel = CreatePanel("settings", false)

CreateSectionHeader(settingsPanel, "GUI SETTINGS", 1)

CreateToggle(settingsPanel, "Notifications", "Show in-game notifications", 2, function(enabled) end)
CreateToggle(settingsPanel, "Anti-Detection", "Enable anti-cheat bypass measures", 3, function(enabled) end)
CreateToggle(settingsPanel, "Streamer Mode", "Hide sensitive info for streaming", 4, function(enabled) end)
CreateToggle(settingsPanel, "Smooth Animations", "Enable smooth GUI transitions", 5, function(enabled) end)
CreateToggle(settingsPanel, "Always On Top", "Keep GUI above other elements", 6, function(enabled) end)

CreateSectionHeader(settingsPanel, "KEYBINDS", 7)

local keybinds = {
    {"Toggle GUI", "Right Shift"},
    {"Toggle Fly", "F"},
    {"Toggle Noclip", "N"},
}

for i, kb in ipairs(keybinds) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = GetTheme().SurfaceHover
    row.BorderSizePixel = 0
    row.LayoutOrder = 7 + i
    row.Parent = settingsPanel
    CreateCorner(row, 8)
    CreateStroke(row, GetTheme().Border, 1)

    local actionLabel = Instance.new("TextLabel")
    actionLabel.Size = UDim2.new(0.6, -10, 1, 0)
    actionLabel.Position = UDim2.new(0, 15, 0, 0)
    actionLabel.BackgroundTransparency = 1
    actionLabel.Text = kb[1]
    actionLabel.TextColor3 = GetTheme().Text
    actionLabel.TextSize = 11
    actionLabel.Font = Enum.Font.GothamMedium
    actionLabel.TextXAlignment = Enum.TextXAlignment.Left
    actionLabel.Parent = row

    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(0, 80, 0, 24)
    keyLabel.Position = UDim2.new(1, -95, 0.5, 0)
    keyLabel.AnchorPoint = Vector2.new(0, 0.5)
    keyLabel.BackgroundColor3 = GetTheme().Primary
    keyLabel.BackgroundTransparency = 0.9
    keyLabel.Text = kb[2]
    keyLabel.TextColor3 = GetTheme().Primary
    keyLabel.TextSize = 10
    keyLabel.Font = Enum.Font.Code
    keyLabel.Parent = row
    CreateCorner(keyLabel, 6)
    CreateStroke(keyLabel, GetTheme().Primary, 1, 0.7)
end

-- ═══════════════════════════════════════════════════════════════
-- SET DEFAULT ACTIVE PANEL
-- ═══════════════════════════════════════════════════════════════
if NavButtons["features"] then
    Tween(NavButtons["features"].Button, {BackgroundTransparency = 0.85, TextColor3 = GetTheme().Primary}, 0.01)
    Tween(NavButtons["features"].Indicator, {BackgroundTransparency = 0}, 0.01)
end

-- Update top bar title when panel changes
spawn(function()
    local panelTitles = {
        features = "⚡ FEATURES",
        server = "🖥️ SERVER INFO",
        utilities = "🔧 UTILITIES",
        analyzer = "📜 SCRIPT ANALYZER",
        credits = "❤️ CREDITS & PLAYER INFO",
        themes = "🎨 THEMES",
        settings = "⚙️ SETTINGS",
    }
    while MainFrame and MainFrame.Parent do
        TopBarTitle.Text = panelTitles[State.ActivePanel] or "UNIVERSAL v2"
        wait(0.1)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- FEATURE IMPLEMENTATIONS
-- ═══════════════════════════════════════════════════════════════

-- FLY SYSTEM
local flyBodyVelocity, flyBodyGyro
local function StartFly()
    local root = GetRootPart()
    local hum = GetHumanoid()
    if not root or not hum then return end
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = root
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyGyro.P = 9e4
    flyBodyGyro.Parent = root
    
    hum.PlatformStand = true
end

local function StopFly()
    local hum = GetHumanoid()
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if hum then hum.PlatformStand = false end
end

RunService.RenderStepped:Connect(function()
    if State.FlyEnabled then
        local root = GetRootPart()
        if root and flyBodyVelocity and flyBodyGyro then
            local speed = State.FlySpeed
            local direction = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            if direction.Magnitude > 0 then
                direction = direction.Unit
            end
            
            flyBodyVelocity.Velocity = direction * speed
            flyBodyGyro.CFrame = Camera.CFrame
        end
    end
end)

-- Watch fly state
spawn(function()
    local wasFlying = false
    while MainFrame and MainFrame.Parent do
        if State.FlyEnabled and not wasFlying then
            StartFly()
            wasFlying = true
        elseif not State.FlyEnabled and wasFlying then
            StopFly()
            wasFlying = false
        end
        wait(0.1)
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJumpEnabled then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if State.NoclipEnabled then
        local char = GetCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- GOD MODE
spawn(function()
    while MainFrame and MainFrame.Parent do
        if State.GodModeEnabled then
            local hum = GetHumanoid()
            if hum then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
        end
        wait(0.5)
    end
end)

-- ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "ExterESP"
espFolder.Parent = game:GetService("CoreGui")

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_" .. player.Name
    highlight.FillColor = GetTheme().Primary
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = GetTheme().Primary
    highlight.OutlineTransparency = 0
    highlight.Parent = espFolder
    
    local function UpdateESP()
        if player.Character then
            highlight.Adornee = player.Character
        end
    end
    
    UpdateESP()
    player.CharacterAdded:Connect(UpdateESP)
end

local function ClearESP()
    for _, v in ipairs(espFolder:GetChildren()) do
        v:Destroy()
    end
end

spawn(function()
    local wasESP = false
    while MainFrame and MainFrame.Parent do
        if State.ESPEnabled and not wasESP then
            for _, player in ipairs(Players:GetPlayers()) do
                CreateESP(player)
            end
            Players.PlayerAdded:Connect(function(player)
                if State.ESPEnabled then CreateESP(player) end
            end)
            wasESP = true
        elseif not State.ESPEnabled and wasESP then
            ClearESP()
            wasESP = false
        end
        wait(0.5)
    end
end)

-- INVISIBLE
spawn(function()
    local wasInvisible = false
    while MainFrame and MainFrame.Parent do
        if State.InvisibleEnabled and not wasInvisible then
            local char = GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                    elseif part:IsA("Decal") then
                        part.Transparency = 1
                    end
                end
            end
            wasInvisible = true
        elseif not State.InvisibleEnabled and wasInvisible then
            local char = GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 0
                    elseif part:IsA("Decal") then
                        part.Transparency = 0
                    end
                end
            end
            wasInvisible = false
        end
        wait(0.5)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- KEYBIND: Toggle GUI (Right Shift)
-- ═══════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        State.GuiVisible = not State.GuiVisible
        if State.GuiVisible then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 750, 0, 480)}, 0.3, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            wait(0.2)
            MainFrame.Visible = false
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
        -- Toggle fly handled by panel toggle
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- OPEN ANIMATION
-- ═══════════════════════════════════════════════════════════════
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Visible = true
wait(0.1)
Tween(MainFrame, {Size = UDim2.new(0, 750, 0, 480)}, 0.5, Enum.EasingStyle.Back)

-- ═══════════════════════════════════════════════════════════════
-- PING UPDATER
-- ═══════════════════════════════════════════════════════════════
spawn(function()
    while MainFrame and MainFrame.Parent do
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        -- Update ping display in server panel
        pcall(function()
            local pingCard = serverInfoFrame:FindFirstChild("Value", true)
            -- We'll update via the stats
        end)
        wait(2)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATION
-- ═══════════════════════════════════════════════════════════════
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "🎮 UNIVERSAL v2 v2.5.0",
        Text = "Script loaded! Press Right Shift to toggle GUI.",
        Duration = 5,
    })
end)
