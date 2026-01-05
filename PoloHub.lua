-- Загружаем библиотеку Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Кастомная тема: серо-черная с красным заголовком
local PolohubTheme = {
    SchemeColor = Color3.fromRGB(170, 0, 0),      -- Темно-красный (только для акцентов)
    Background = Color3.fromRGB(20, 20, 20),      -- Чёрный фон окна
    Header = Color3.fromRGB(30, 30, 30),          -- Тёмно-серый заголовок
    TextColor = Color3.fromRGB(220, 220, 220),    -- Светло-серый текст
    ElementColor = Color3.fromRGB(40, 40, 40),    -- Серый фон элементов
    
    BorderColor = Color3.fromRGB(80, 80, 80),     -- Серая обводка
    BorderSize = 1,                               -- Тонкая обводка
    CornerRadius = 8,                             -- Сглаженные углы
    Font = Enum.Font.GothamSemibold,
    TextSize = 14
}

-- Создаем окно без названия
local Window = Library.CreateLib("", PolohubTheme)

-- Получаем главный фрейм
local MainFrame = Window.MainFrame
if MainFrame then
    -- Делаем маленькое окно
    MainFrame.Size = UDim2.new(0, 220, 0, 180)
    
    -- Создаем кастомный заголовок "polohub"
    local PolohubLabel = Instance.new("TextLabel")
    PolohubLabel.Name = "PolohubHeader"
    PolohubLabel.Text = "polohub"
    PolohubLabel.TextColor3 = Color3.fromRGB(170, 0, 0)
    PolohubLabel.TextSize = 18
    PolohubLabel.Font = Enum.Font.GothamBold
    PolohubLabel.BackgroundTransparency = 1
    PolohubLabel.Position = UDim2.new(0, 12, 0, 8)
    PolohubLabel.Size = UDim2.new(0, 100, 0, 24)
    PolohubLabel.Parent = MainFrame
    
    -- Прячем стандартный заголовок
    local OriginalTitle = MainFrame:FindFirstChild("WindowTitle")
    if OriginalTitle then OriginalTitle.Visible = false end
    
    -- Делаем окно перетаскиваемым за любую область
    Library:SetDraggable(true, MainFrame)
end

-- Создаем пустую вкладку (основу для будущих кнопок)
local LeftTab = Window:NewTab("")
local LeftSection = LeftTab:NewSection("")

-- Убираем кнопку закрытия
local CloseButton = Window.MainFrame:FindFirstChild("CloseButton")
if CloseButton then CloseButton.Visible = false end

print("Polohub GUI основа загружена")
print("Меню перетаскивается за любую область")
