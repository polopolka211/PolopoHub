-- ============================================
-- POLOHUB - ШАБЛОН ИНТЕРФЕЙСА (Rayfield)
-- Только структура меню, без игровых функций
-- ============================================

-- Загружаем Rayfield Interface Suite
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создаём главное окно
local Window = Rayfield:CreateWindow({
    Name = "POLOHUB INTERFACE",
    LoadingTitle = "Загрузка интерфейса...",
    LoadingSubtitle = "Чистый шаблон для изучения",
    ConfigurationSaving = { Enabled = false }, -- Отключаем сохранение настроек
    Discord = { Enabled = false },
    KeySystem = false, -- Без системы ключей
})

-- ============================================
-- ВКЛАДКА 1: ГЛАВНОЕ МЕНЮ (демонстрация элементов)
-- ============================================
local MainTab = Window:CreateTab("Главное", nil) -- nil = без иконки

-- Секция 1: Кнопки
local ButtonSection = MainTab:CreateSection("Примеры кнопок")

local DemoButton1 = MainTab:CreateButton({
    Name = "Кнопка 1 (простая)",
    Callback = function()
        print("Нажата простая кнопка")
        -- Здесь будет ваша функция
    end,
})

local DemoButton2 = MainTab:CreateButton({
    Name = "Кнопка 2 (с уведомлением)",
    Callback = function()
        Rayfield:Notify({
            Title = "Уведомление",
            Content = "Это пример уведомления Rayfield",
            Duration = 3,
        })
        print("Нажата кнопка с уведомлением")
    end,
})

-- Секция 2: Переключатели
local ToggleSection = MainTab:CreateSection("Примеры переключателей")

local DemoToggle1 = MainTab:CreateToggle({
    Name = "Переключатель 1",
    CurrentValue = false,
    Flag = "Toggle1Demo",
    Callback = function(Value)
        print("Переключатель 1: " .. (Value and "ВКЛ" or "ВЫКЛ"))
        -- Здесь будет ваша функция при включении/выключении
    end,
})

local DemoToggle2 = MainTab:CreateToggle({
    Name = "Переключатель с сохранением",
    CurrentValue = true,
    Flag = "Toggle2Demo", -- Флаг для сохранения состояния
    Callback = function(Value)
        print("Сохранённый переключатель: " .. (Value and "ВКЛ" or "ВЫКЛ"))
    end,
})

-- Секция 3: Слайдеры
local SliderSection = MainTab:CreateSection("Примеры слайдеров")

local DemoSlider = MainTab:CreateSlider({
    Name = "Числовой слайдер",
    Range = {0, 100},
    Increment = 5,
    Suffix = "ед.",
    CurrentValue = 50,
    Flag = "SliderDemo",
    Callback = function(Value)
        print("Значение слайдера: " .. Value)
        -- Здесь будет ваша функция при изменении значения
    end,
})

-- ============================================
-- ВКЛАДКА 2: НАСТРОЙКИ ИНТЕРФЕЙСА
-- ============================================
local SettingsTab = Window:CreateTab("Настройки", nil)

-- Секция: Внешний вид
local ThemeSection = SettingsTab:CreateSection("Внешний вид")

local ThemeToggle = SettingsTab:CreateToggle({
    Name = "Тёмная тема",
    CurrentValue = true,
    Flag = "DarkThemeSetting",
    Callback = function(Value)
        if Value then
            Window:SetTheme("Dark")
        else
            Window:SetTheme("Light")
        end
        print("Тема изменена на: " .. (Value and "Тёмную" or "Светлую"))
    end,
})

local ColorPicker = SettingsTab:CreateColorPicker({
    Name = "Цвет акцентов",
    Color = Color3.fromRGB(40, 40, 40), -- Серый цвет
    Flag = "AccentColorSetting",
    Callback = function(Color)
        Window:ChangeColor(Color)
        print("Цвет акцентов изменён")
    end
})

-- Секция: Элементы управления
local ControlSection = SettingsTab:CreateSection("Управление")

local WatermarkToggle = SettingsTab:CreateToggle({
    Name = "Водяной знак",
    CurrentValue = true,
    Flag = "WatermarkSetting",
    Callback = function(Value)
        Rayfield:SetWatermarkVisibility(Value)
        print("Водяной знак: " .. (Value and "Показан" or "Скрыт"))
    end,
})

local HotkeyButton = SettingsTab:CreateButton({
    Name = "Сменить горячую клавишу",
    Callback = function()
        Rayfield:Notify({
            Title = "Смена клавиши",
            Content = "Нажмите новую клавишу...",
            Duration = 2,
        })
        -- Rayfield сам запросит новую клавишу
    end,
})

-- Секция: Информация
local InfoSection = SettingsTab:CreateSection("Информация")

local VersionLabel = SettingsTab:CreateLabel("PoloHub Template v1.0")
local LibraryLabel = SettingsTab:CreateLabel("Rayfield Interface Suite")
local InfoLabel = SettingsTab:CreateLabel("Этот шаблон - только для изучения")

-- ============================================
-- ВКЛАДКА 3: ТЕСТИРОВАНИЕ (дополнительные элементы)
-- ============================================
local TestTab = Window:CreateTab("Тесты", nil)

local TestSection = TestTab:CreateSection("Другие элементы UI")

-- Выпадающий список
local TestDropdown = TestTab:CreateDropdown({
    Name = "Пример списка",
    Options = {"Вариант 1", "Вариант 2", "Вариант 3"},
    CurrentOption = "Вариант 1",
    Flag = "TestDropdown",
    Callback = function(Option)
        print("Выбран: " .. Option)
    end,
})

-- Текстовое поле ввода
local TestInput = TestTab:CreateInput({
    Name = "Текстовое поле",
    PlaceholderText = "Введите текст...",
    RemoveTextAfterFocusLost = false,
    Flag = "TestInputField",
    Callback = function(Text)
        print("Введён текст: " .. Text)
    end,
})

-- Кнопка закрытия
local CloseSection = TestTab:CreateSection("Управление интерфейсом")
local CloseUIButton = TestTab:CreateButton({
    Name = "Скрыть интерфейс",
    Callback = function()
        Rayfield:Destroy()
        print("Интерфейс закрыт")
    end,
})

local ToggleUIButton = TestTab:CreateButton({
    Name = "Свернуть/развернуть",
    Callback = function()
        -- Rayfield не имеет встроенной функции сворачивания
        Rayfield:Notify({
            Title = "Информация",
            Content = "Используйте горячую клавишу для скрытия",
            Duration = 3,
        })
    end,
})

-- ============================================
-- НАСТРОЙКА ИНТЕРФЕЙСА
-- ============================================

-- Устанавливаем горячую клавишу по умолчанию
Rayfield:SetHotkey("RightShift")

-- Включаем водяной знак
Rayfield:SetWatermark("POLOHUB Template")

-- Финальное сообщение в консоль
print("=" .. string.rep("=", 50))
print("  POLOHUB RAYFIELD TEMPLATE ЗАГРУЖЕН")
print("  • Используйте RightShift для скрытия/показа")
print("  • Это чистый шаблон без игровых функций")
print("=" .. string.rep("=", 50))

-- Возвращаем объект Window, если нужно управлять им извне
return Window
