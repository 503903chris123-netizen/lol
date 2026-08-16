local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

if _G.AutoToolsUI then return end
_G.AutoToolsUI = true

-- ==================== UI 创建 ====================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoToolsUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 110)
mainFrame.Position = UDim2.new(0, 15, 0, 15)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "⚡ 快捷工具"
title.TextColor3 = Color3.fromRGB(220, 220, 230)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0, 10, 0, 4)
title.Parent = mainFrame

-- ==================== Toggle 1: 自动 QTE ====================
local t1Frame = Instance.new("Frame")
t1Frame.Size = UDim2.new(1, -20, 0, 30)
t1Frame.Position = UDim2.new(0, 10, 0, 32)
t1Frame.BackgroundTransparency = 1
t1Frame.Parent = mainFrame

local label1 = Instance.new("TextLabel")
label1.Size = UDim2.new(0, 120, 1, 0)
label1.BackgroundTransparency = 1
label1.Text = "自动 QTE"
label1.TextColor3 = Color3.fromRGB(200, 200, 210)
label1.Font = Enum.Font.Gotham
label1.TextSize = 14
label1.TextXAlignment = Enum.TextXAlignment.Left
label1.Parent = t1Frame

local toggle1Btn = Instance.new("TextButton")
toggle1Btn.Size = UDim2.new(0, 50, 1, -4)
toggle1Btn.Position = UDim2.new(1, -55, 0, 2)
toggle1Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
toggle1Btn.Text = "关"
toggle1Btn.TextColor3 = Color3.fromRGB(200, 80, 80)
toggle1Btn.Font = Enum.Font.GothamBold
toggle1Btn.TextSize = 13
toggle1Btn.BorderSizePixel = 0
toggle1Btn.Parent = t1Frame
Instance.new("UICorner", toggle1Btn).CornerRadius = UDim.new(0, 4)

local qteOn = false

toggle1Btn.MouseButton1Click:Connect(function()
    qteOn = not qteOn
    toggle1Btn.Text = qteOn and "开" or "关"
    toggle1Btn.BackgroundColor3 = qteOn and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(50, 50, 60)
    toggle1Btn.TextColor3 = qteOn and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(200, 80, 80)
    print("[AutoQTE] 状态:", qteOn and "开启" or "关闭")
end)

-- ==================== Toggle 2: 自动领域 ====================
local t2Frame = Instance.new("Frame")
t2Frame.Size = UDim2.new(1, -20, 0, 30)
t2Frame.Position = UDim2.new(0, 10, 0, 66)
t2Frame.BackgroundTransparency = 1
t2Frame.Parent = mainFrame

local label2 = Instance.new("TextLabel")
label2.Size = UDim2.new(0, 120, 1, 0)
label2.BackgroundTransparency = 1
label2.Text = "自动领域"
label2.TextColor3 = Color3.fromRGB(200, 200, 210)
label2.Font = Enum.Font.Gotham
label2.TextSize = 14
label2.TextXAlignment = Enum.TextXAlignment.Left
label2.Parent = t2Frame

local toggle2Btn = Instance.new("TextButton")
toggle2Btn.Size = UDim2.new(0, 50, 1, -4)
toggle2Btn.Position = UDim2.new(1, -55, 0, 2)
toggle2Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
toggle2Btn.Text = "关"
toggle2Btn.TextColor3 = Color3.fromRGB(200, 80, 80)
toggle2Btn.Font = Enum.Font.GothamBold
toggle2Btn.TextSize = 13
toggle2Btn.BorderSizePixel = 0
toggle2Btn.Parent = t2Frame
Instance.new("UICorner", toggle2Btn).CornerRadius = UDim.new(0, 4)

local domainOn = false

toggle2Btn.MouseButton1Click:Connect(function()
    domainOn = not domainOn
    toggle2Btn.Text = domainOn and "开" or "关"
    toggle2Btn.BackgroundColor3 = domainOn and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(50, 50, 60)
    toggle2Btn.TextColor3 = domainOn and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(200, 80, 80)
    print("[AutoDomain] 状态:", domainOn and "开启" or "关闭")
end)

-- ==================== QTE 逻辑 (由 Toggle1 控制) ====================
local QTE = LocalPlayer:FindFirstChild("QTE")
local ZonePos, MarkerPos, Click

if QTE then
    ZonePos = QTE:FindFirstChild("ZonePos")
    MarkerPos = QTE:FindFirstChild("MarkerPos")
    Click = QTE:FindFirstChild("Click")
end

local canClick = true
local clickCooldown = 0.3
local tolerance = 0.05

local function doClick()
    if not canClick then return end
    if not Click then return end
    canClick = false
    pcall(function()
        if Click:IsA("RemoteEvent") then
            Click:FireServer()
        elseif Click:IsA("BindableFunction") then
            Click:Invoke()
        else
            Click()
        end
    end)
    task.spawn(function()
        task.wait(clickCooldown)
        canClick = true
    end)
end

-- QTE 循环 (每5ms检测)
task.spawn(function()
    local lastZone, lastMarker
    local matched = false

    while task.wait(0.005) do
        if not qteOn then
            matched = false
            canClick = true
            continue
        end

        if not ZonePos or not MarkerPos or not Click then
            -- 尝试重新获取
            QTE = LocalPlayer:FindFirstChild("QTE")
            if QTE then
                ZonePos = QTE:FindFirstChild("ZonePos")
                MarkerPos = QTE:FindFirstChild("MarkerPos")
                Click = QTE:FindFirstChild("Click")
            end
            continue
        end

        local z = ZonePos.Value
        local m = MarkerPos.Value

        if z == nil or m == nil then continue end

        if z ~= lastZone or m ~= lastMarker then
            lastZone = z
            lastMarker = m
        end

        local diff = math.abs(z - m)

        if diff <= tolerance and canClick and not matched then
            matched = true
            print(string.format("[QTE] ✅ 点击! diff=%.3f", diff))
            doClick()
            task.wait(0.02)
            matched = false
        elseif diff > tolerance then
            matched = false
        end
    end
end)

-- ==================== 自动领域 (由 Toggle2 控制) ====================
task.spawn(function()
    while task.wait(2) do
        if not domainOn then continue end
        pcall(function()
            local tower = Workspace:FindFirstChild("Towers") and Workspace.Towers:FindFirstChild("JusticeSorcerer")
            if tower then
                local domain = ReplicatedStorage:FindFirstChild("Remotes") 
                                and ReplicatedStorage.Remotes:FindFirstChild("Towers") 
                                and ReplicatedStorage.Remotes.Towers:FindFirstChild("JusticeSorcerer") 
                                and ReplicatedStorage.Remotes.Towers.JusticeSorcerer:FindFirstChild("Domain")
                if domain and domain:IsA("RemoteEvent") then
                    domain:FireServer(tower)
                end
            end
        end)
    end
end)

print(string.format("[AutoTools] 已加载: QTE(误差<=%.2f, 冷却%.1fs) | 领域(2s)", tolerance, clickCooldown))
