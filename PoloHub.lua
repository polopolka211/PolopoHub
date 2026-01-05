-- ============================================
-- POLOHUB MINIMAL GUI
-- Чистый Roblox UI, только основа
-- ============================================

-- Получаем необходимые сервисы
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- Создаём главный контейнер
local MainFrame = Instance.new("Frame")
MainFrame.Name = "PoloHubMain"
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)  -- Тёмно-серый
MainFrame.BackgroundTransparency = 0.15  -- 15% прозрачности
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)  -- Ближе к углу
MainFrame.Size = UDim2.new(0, 250, 0, 300)  -- Компактный размер
MainFrame.AnchorPoint = Vector2.new(0, 0)
MainFrame.Parent = PlayerGui

-- Сглаженные углы
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Тонкая обводка
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(70, 70, 70)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- ============================================
-- ЗАГОЛОВОК "polohub" в левом верхнем углу
-- ============================================
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "PolohubTitle"
TitleLabel.Text = "polohub"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)  -- Светло-серый
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamSemibold
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 12, 0, 8)
TitleLabel.Size = UDim2.new(0, 100, 0, 24)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- ============================================
-- БАЗОВАЯ КНОПКА (пример)
-- ============================================
local ButtonFrame = Instance.new("Frame")
ButtonFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ButtonFrame.BackgroundTransparency = 0.3
ButtonFrame.BorderSizePixel = 0
ButtonFrame.Position = UDim2.new(0.1, 0, 0.15, 0)
ButtonFrame.Size = UDim2.new(0.8, 0, 0, 40)
ButtonFrame.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ButtonFrame

local ButtonLabel = Instance.new("TextLabel")
ButtonLabel.Text = "Кнопка"
ButtonLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
ButtonLabel.TextSize = 14
ButtonLabel.Font = Enum.Font.Gotham
ButtonLabel.BackgroundTransparency = 1
ButtonLabel.Size = UDim2.new(1, 0, 1, 0)
ButtonLabel.Parent = ButtonFrame

local ButtonButton = Instance.new("TextButton")
ButtonButton.Text = ""
ButtonButton.BackgroundTransparency = 1
ButtonButton.Size = UDim2.new(1, 0, 1, 0)
ButtonButton.Parent = ButtonFrame

ButtonButton.MouseButton1Click:Connect(function()
    print("polohub: Кнопка нажата")
end)

-- Эффект при наведении
ButtonButton.MouseEnter:Connect(function()
    ButtonFrame.BackgroundTransparency = 0.1
end)

ButtonButton.MouseLeave:Connect(function()
    ButtonFrame.BackgroundTransparency = 0.3
end)

-- ============================================
-- СИСТЕМА ПЕРЕТАСКИВАНИЯ (работает на телефоне)
-- ============================================
local dragging = false
local dragStart, startPos

local function Update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X,
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or 
       input.UserInputType == Enum.UserInputType.MouseButton1 then
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

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or 
                    input.UserInputType == Enum.UserInputType.MouseMovement) then
        Update(input)
    end
end)

-- ============================================
-- ГОТОВО
-- ============================================
print("polohub: GUI загружено")
print("• Перетаскивайте за любое место окна")
print("• Надпись 'polohub' в левом верхнем углу")
