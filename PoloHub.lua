-- ============================================
-- POLOHUB - ITEMS FARM MANAGER
-- Минималистичный интерфейс на Rayfield
-- ============================================

-- Загружаем Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создаём окно
local Window = Rayfield:CreateWindow({
    Name = "POLOHUB | ITEMS",
    LoadingTitle = "Загрузка менеджера предметов...",
    LoadingSubtitle = "by polopolka211",
    ConfigurationSaving = { Enabled = true },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- Создаём вкладку Items
local ItemsTab = Window:CreateTab("Items", nil)

-- Секция для фарма предметов
local FarmSection = ItemsTab:CreateSection("Items to Farm")

-- ФИНАЛЬНЫЙ ОБНОВЛЁННЫЙ список предметов YBA
local AllYBAItems = {
    "Mysterious Arrow",           -- Таинственная стрела
    "Rokakaka Fruit",             -- Плод рокакаки
    "Diamond",                    -- Алмаз
    "Gold Coin",                  -- Золотая монета
    "Quinton's Glove",            -- Перчатка Квинтона
    "Steel Ball",                 -- Стальной шар
    "Ancient Scroll",             -- Древний свиток
    "Rib Cage of The Saint Corpse", -- Ребро святого (с добавлением corpse)
    "Dio's Diary",                -- Дневник Дио
    "Stone Mask",                 -- Каменная маска
    "Lucky Arrow",                -- Счастливая стрела
    "Christmas Present",          -- Рождественский подарок
    "Caesar's Headband",          -- Повязка Цезаря (замена Zepelli's Headband)
    "Pure Rokakaka",              -- Чистая рокакака
    "Clackers",                   -- Кле́керы (добавлено)
    "Lucky Stone Mask",           -- Счастливая каменная маска (добавлено)
    "Zepelli's Hat",              -- Шапка Цеппели (добавлено)
}

-- Выпадающий список для выбора предметов
local SelectedItems = {} -- Здесь будем хранить выбранные предметы

local ItemsDropdown = ItemsTab:CreateDropdown({
    Name = "Items to Farm",
    Options = AllYBAItems,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "YBA_Items_Selection",
    Callback = function(SelectedOptions)
        SelectedItems = SelectedOptions
        
        if #SelectedOptions > 0 then
            Rayfield:Notify({
                Title = "Items Selected",
                Content = "Selected " .. #SelectedOptions .. " items for farming",
                Duration = 2,
            })
            
            print("=== SELECTED ITEMS FOR FARMING ===")
            for i, item in ipairs(SelectedOptions) do
                print(i .. ". " .. item)
            end
            print("==================================")
        else
            print("No items selected for farming")
        end
    end,
})

-- Кнопка для быстрого выбора/сброса
local SelectionSection = ItemsTab:CreateSection("Quick Selection")

local SelectAllButton = ItemsTab:CreateButton({
    Name = "Select All Items",
    Callback = function()
        ItemsDropdown:Set(AllYBAItems)
        print("All items selected")
    end,
})

local ClearAllButton = ItemsTab:CreateButton({
    Name = "Clear Selection",
    Callback = function()
        ItemsDropdown:Set({})
        print("Selection cleared")
    end,
})

-- Информационная секция
local InfoSection = ItemsTab:CreateSection("Information")

local StatusLabel = ItemsTab:CreateLabel("Status: Ready")
local SelectedCountLabel = ItemsTab:CreateLabel("Selected: 0 items")

-- Функция для обновления статуса
local function updateStatus()
    local count = #SelectedItems
    SelectedCountLabel:Set("Selected: " .. count .. " item" .. (count == 1 and "" or "s"))
    
    if count > 0 then
        StatusLabel:Set("Status: Farming " .. count .. " items")
    else
        StatusLabel:Set("Status: Idle")
    end
end

-- Обновляем статус при изменении выбора
local originalCallback = ItemsDropdown.Callback
ItemsDropdown.Callback = function(SelectedOptions)
    SelectedItems = SelectedOptions
    updateStatus()
    originalCallback(SelectedOptions)
end

-- Настройка интерфейса
Rayfield:SetHotkey("RightShift")
Rayfield:SetWatermark("POLOHUB Items Manager")

-- Финальная инициализация
updateStatus()

print("======================================")
print("POLOHUB ITEMS MANAGER LOADED")
print("• " .. #AllYBAItems .. " items available")
print("• Select items from dropdown")
print("• Use RightShift to toggle UI")
print("======================================")
