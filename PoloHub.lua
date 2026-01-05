-- PoloHub Mobile GUI
-- Чистый Roblox UI с серой полупрозрачной темой

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. СОЗДАЕМ ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Name = "PoloHub"
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  -- Темно-серый
MainFrame.BackgroundTransparency = 0.2  -- 20% прозрачности
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)  -- 10% от краев
MainFrame.Size = UDim2.new(0, 300, 0, 400)  -- Компактный размер
MainFrame.AnchorPoint = Vector2.new(0, 0)

-- Сглаженные углы
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Тонкая обводка
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 80)  -- Серая обводка
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- 2. ЗАГОЛОВОК С ВОЗМОЖНОСТЬЮ ПЕРЕТАСКИВАНИЯ
local TitleFrame = Instance.new("Frame")
TitleFrame.Name = "TitleBar"
TitleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleFrame.BackgroundTransparency = 0.3
TitleFrame.BorderSizePixel = 0
TitleFrame.Size = UDim2.new(1, 0, 0, 40)
TitleFrame.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Text = "POLOHUB"
TitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)  -- Светло-серый
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleFrame

-- Кнопка закрытия (опционально)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseButton.TextSize = 24
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BackgroundTransparency = 1
CloseButton.Size = UDim2.new(0, 40, 1, 0)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.Parent = TitleFrame

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible  -- Скрываем/показываем по клику
end)

-- 3. ОБЛАСТЬ ДЛЯ КНОПОК
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)  -- Отступ между кнопками
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ContentFrame

-- 4. ФУНКЦИЯ ДЛЯ СОЗДАНИЯ КНОПКИ
local function CreateButton(text, description, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ButtonFrame.BackgroundTransparency = 0.4
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Size = UDim2.new(1, 0, 0, 50)
    ButtonFrame.LayoutOrder = #ContentFrame:GetChildren()
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ButtonFrame
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(90, 90, 90)
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = ButtonFrame
    
    local ButtonLabel = Instance.new("TextLabel")
    ButtonLabel.Text = text
    ButtonLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ButtonLabel.TextSize = 16
    ButtonLabel.Font = Enum.Font.GothamSemibold
    ButtonLabel.BackgroundTransparency = 1
    ButtonLabel.Size = UDim2.new(1, -20, 0.6, 0)
    ButtonLabel.Position = UDim2.new(0, 10, 0, 5)
    ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
    ButtonLabel.Parent = ButtonFrame
    
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Text = description
    DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    DescLabel.TextSize = 12
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.BackgroundTransparency = 1
    DescLabel.Size = UDim2.new(1, -20, 0.4, 0)
    DescLabel.Position = UDim2.new(0, 10, 0.6, 0)
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = ButtonFrame
    
    local ButtonButton = Instance.new("TextButton")
    ButtonButton.Text = ""
    ButtonButton.BackgroundTransparency = 1
    ButtonButton.Size = UDim2.new(1, 0, 1, 0)
    ButtonButton.Parent = ButtonFrame
    
    -- Эффект при нажатии
    ButtonButton.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    ButtonButton.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(
            ButtonFrame,
            TweenInfo.new(0.2),
            {BackgroundTransparency = 0.2}
        ):Play()
    end)
    
    ButtonButton.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(
            ButtonFrame,
            TweenInfo.new(0.2),
            {BackgroundTransparency = 0.4}
        ):Play()
    end)
    
    ButtonFrame.Parent = ContentFrame
    return ButtonFrame
end

-- 5. ДОБАВЛЯЕМ ПРИМЕРНЫЕ КНОПКИ
CreateButton("АВТО-ФАРМ", "Автоматический сбор ресурсов", function()
    print("Авто-фарм активирован")
    -- Ваш код здесь
end)

CreateButton("ТЕЛЕПОРТ", "Быстрая телепортация", function()
    print("Телепорт активирован")
    -- Ваш код здесь
end)

CreateButton("ESP / ВИДИМОСТЬ", "Отображение предметов и NPC", function()
    print("ESP переключен")
    -- Ваш код здесь
end)

CreateButton("НАСТРОЙКИ", "Настройки интерфейса", function()
    print("Открыты настройки")
    -- Ваш код здесь
end)

-- 6. СИСТЕМА ПЕРЕТАСКИВАНИЯ (работает на телефоне!)
local dragging = false
local dragInput, dragStart, startPos

local function Update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X,
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

TitleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
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

TitleFrame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragging then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        Update(input)
    end
end)

-- 7. ФИНАЛЬНАЯ НАСТРОЙКА
MainFrame.Parent = PlayerGui

-- Горячая клавиша для скрытия/показа
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("═" .. string.rep("═", 30))
print("  POLOHUB GUI УСПЕШНО ЗАГРУЖЕН")
print("  • Перетаскивайте за серую панель")
print("  • RightControl - скрыть/показать")
print("═" .. string.rep("═", 30))
