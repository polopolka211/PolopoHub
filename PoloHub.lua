-- ============================================
-- POLOHUB - COMPLETE VERSION (FIXED)
-- Rayfield UI + Item Selection + Underground Teleport
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

-- ============================================
-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
-- ============================================
local SelectedItems = {}
local IsFarming = false

-- МОДУЛЬ ТЕЛЕПОРТАЦИИ (исправленный)
local UndergroundTeleport = {
    Enabled = false,
    Connection = nil,
    Depth = -8,  -- ФИКС: изначально 8 studs
    Delay = 0.3,
    MaxDepth = 8 -- ФИКС: максимум 8 studs
}

-- ============================================
-- СПИСОК ПРЕДМЕТОВ YBA
-- ============================================
local AllYBAItems = {
    "Mysterious Arrow",
    "Rokakaka Fruit", 
    "Diamond",
    "Gold Coin",
    "Quinton's Glove",
    "Steel Ball",
    "Ancient Scroll",
    "Rib Cage of The Saint Corpse",
    "Dio's Diary",
    "Stone Mask",
    "Lucky Arrow",
    "Christmas Present",
    "Caesar's Headband",
    "Pure Rokakaka",
    "Clackers",
    "Lucky Stone Mask",
    "Zepelli's Hat"
}

-- ============================================
-- ВКЛАДКА ITEMS (ВЫБОР ПРЕДМЕТОВ)
-- ============================================
local ItemsTab = Window:CreateTab("Items", nil)

-- Секция выбора предметов
local FarmSection = ItemsTab:CreateSection("Items to Farm")

-- Выпадающий список выбора предметов
local ItemsDropdown = ItemsTab:CreateDropdown({
    Name = "Items to Farm",
    Options = AllYBAItems,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "YBA_Items_Selection",
    Callback = function(SelectedOptions)
        SelectedItems = SelectedOptions
        updateStatus()
        
        if #SelectedOptions > 0 then
            Rayfield:Notify({
                Title = "Items Selected",
                Content = "Selected " .. #SelectedOptions .. " items",
                Duration = 2,
            })
            
            print("=== SELECTED ITEMS ===")
            for i, item in ipairs(SelectedOptions) do
                print(i .. ". " .. item)
            end
            print("======================")
        else
            print("No items selected")
        end
    end,
})

-- Секция быстрого выбора
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

-- ============================================
-- ВКЛАДКА SETTINGS (НАСТРОЙКИ ТЕЛЕПОРТА)
-- ============================================
local SettingsTab = Window:CreateTab("Settings", nil)

-- Секция настроек телепорта
local TeleportSettings = SettingsTab:CreateSection("Teleport Settings")

-- ПЕРЕКЛЮЧАТЕЛЬ телепортации (вместо кнопки)
local TeleportToggle = SettingsTab:CreateToggle({
    Name = "Underground Teleport",
    CurrentValue = false,
    Flag = "TeleportEnabled",
    Callback = function(Value)
        if Value then
            -- Включаем телепорт
            local success = UndergroundTeleport.Start()
            if success then
                TeleportStatusLabel:Set("Teleport: 🟢 ACTIVE")
                TeleportStatusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
                print("[Teleport] Toggle ON")
            else
                TeleportToggle:Set(false) -- Возвращаем выключенное состояние
            end
        else
            -- Выключаем телепорт
            UndergroundTeleport.Stop()
            TeleportStatusLabel:Set("Teleport: 🔴 OFF")
            TeleportStatusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
            print("[Teleport] Toggle OFF")
        end
    end,
})

-- Слайдер глубины (максимум 8)
local DepthSlider = SettingsTab:CreateSlider({
    Name = "Teleport Depth (MAX: 8)",
    Range = {1, 8}, -- ФИКС: максимум 8 studs
    Increment = 1,
    Suffix = " studs",
    CurrentValue = math.abs(UndergroundTeleport.Depth),
    Flag = "TeleportDepth",
    Callback = function(Value)
        UndergroundTeleport.Depth = -Value
        print("[Teleport] Depth set: " .. Value .. " studs")
    end,
})

-- Слайдер задержки
local DelaySlider = SettingsTab:CreateSlider({
    Name = "Teleport Delay",
    Range = {0.1, 1.0},
    Increment = 0.1,
    Suffix = " sec",
    CurrentValue = UndergroundTeleport.Delay,
    Flag = "TeleportDelay",
    Callback = function(Value)
        UndergroundTeleport.Delay = Value
        print("[Teleport] Delay set: " .. Value .. " sec")
    end,
})

-- Кнопка теста пути
local TestPathButton = SettingsTab:CreateButton({
    Name = "Test Item Path",
    Callback = function()
        local points = UndergroundTeleport.FindAllPoints()
        Rayfield:Notify({
            Title = "Path Test",
            Content = "Found " .. #points .. " items",
            Duration = 3,
        })
    end,
})

-- Информационная секция
local InfoSection = SettingsTab:CreateSection("Status")
local TeleportStatusLabel = SettingsTab:CreateLabel("Teleport: 🔴 OFF")

-- ============================================
-- ИНФОРМАЦИОННАЯ СЕКЦИЯ В ITEMS TAB
-- ============================================
local ItemsInfoSection = ItemsTab:CreateSection("Information")
local StatusLabel = ItemsTab:CreateLabel("Status: Ready")
local SelectedCountLabel = ItemsTab:CreateLabel("Selected: 0 items")

-- ============================================
-- ФУНКЦИИ ОБНОВЛЕНИЯ СТАТУСА
-- ============================================
local function updateStatus()
    local count = #SelectedItems
    SelectedCountLabel:Set("Selected: " .. count .. " item" .. (count == 1 and "" or "s"))
    
    if count > 0 then
        StatusLabel:Set("Status: Ready (" .. count .. " selected)")
    else
        StatusLabel:Set("Status: Ready")
    end
end

-- ============================================
-- ИСПРАВЛЕННЫЙ МОДУЛЬ ТЕЛЕПОРТАЦИИ
-- ============================================

-- Функция поиска всех точек (ИСПРАВЛЕНА)
function UndergroundTeleport.FindAllPoints()
    local spawnsFolder = workspace:FindFirstChild("Item_Spawns") 
                      or workspace:FindFirstChild("Item_spawns")
    
    if not spawnsFolder then
        print("[Teleport] Item_Spawns not found")
        return {}
    end
    
    local itemsFolder = spawnsFolder:FindFirstChild("Items")
    if not itemsFolder then
        print("[Teleport] Items folder not found")
        return {}
    end
    
    local teleportPoints = {}
    
    local function scanForPoints(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Model") then
                -- Ищем промпт в модели
                for _, obj in pairs(child:GetChildren()) do
                    if obj:IsA("ProximityPrompt") then
                        table.insert(teleportPoints, {
                            Model = child,
                            Position = child:GetPivot().Position
                        })
                        break
                    end
                end
                
                -- Рекурсивно проверяем дочерние модели
                scanForPoints(child)
            end
        end
    end
    
    scanForPoints(itemsFolder)
    return teleportPoints
end

-- Подземный телепорт к точке
local function teleportToPoint(pointPosition)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character.Parent then 
        print("[Teleport] Character not found")
        return false 
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        print("[Teleport] HumanoidRootPart not found")
        return false
    end
    
    -- Безопасный расчет позиции
    local undergroundPos = Vector3.new(
        pointPosition.X,
        math.min(pointPosition.Y + UndergroundTeleport.Depth, pointPosition.Y - 1), -- Не выше предмета
        pointPosition.Z
    )
    
    -- Безопасный телепорт
    local success, err = pcall(function()
        humanoidRootPart.CFrame = CFrame.new(undergroundPos)
    end)
    
    if not success then
        print("[Teleport] Teleport failed: " .. tostring(err))
        return false
    end
    
    return true
end

-- Основной цикл телепортации (ИСПРАВЛЕН)
local function teleportationLoop()
    if not UndergroundTeleport.Enabled then 
        return 
    end
    
    local points = UndergroundTeleport.FindAllPoints()
    if #points == 0 then
        print("[Teleport] No points found, waiting...")
        task.wait(2)
        return
    end
    
    print("[Teleport] Scanning " .. #points .. " points...")
    
    for i, point in pairs(points) do
        if not UndergroundTeleport.Enabled then 
            break 
        end
        
        print(string.format("[Teleport] %d/%d - X:%.1f Y:%.1f Z:%.1f", 
            i, #points, point.Position.X, point.Position.Y, point.Position.Z))
        
        -- Телепортируемся
        if teleportToPoint(point.Position) then
            -- Ждем стабилизации
            task.wait(0.3)
            
            -- Проверяем дистанцию
            local character = game.Players.LocalPlayer.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distance = (hrp.Position - point.Position).Magnitude
                    print(string.format("[Teleport] Distance: %.1f studs", distance))
                    
                    if distance <= math.abs(UndergroundTeleport.Depth) + 2 then
                        print("[Teleport] ✓ In range")
                    end
                end
            end
            
            -- Задержка перед следующей точкой
            task.wait(UndergroundTeleport.Delay)
        else
            print("[Teleport] Failed to teleport to point")
        end
    end
    
    print("[Teleport] Cycle complete, restarting...")
end

-- Запуск телепортации (ИСПРАВЛЕН)
function UndergroundTeleport.Start()
    if UndergroundTeleport.Enabled then
        print("[Teleport] Already running")
        return false
    end
    
    UndergroundTeleport.Enabled = true
    
    print("=" .. string.rep("=", 40))
    print("🚀 UNDERGROUND TELEPORT STARTED")
    print("Depth: " .. math.abs(UndergroundTeleport.Depth) .. " studs")
    print("Delay: " .. UndergroundTeleport.Delay .. " sec")
    print("=" .. string.rep("=", 40))
    
    -- Запускаем безопасный цикл
    local function safeLoop()
        while UndergroundTeleport.Enabled do
            local success, err = pcall(teleportationLoop)
            if not success then
                warn("[Teleport] Loop error: " .. tostring(err))
            end
            task.wait(0.5)
        end
    end
    
    -- Запускаем в отдельном потоке
    task.spawn(safeLoop)
    
    return true
end

-- Остановка телепортации
function UndergroundTeleport.Stop()
    if not UndergroundTeleport.Enabled then 
        return 
    end
    
    UndergroundTeleport.Enabled = false
    
    print("=" .. string.rep("=", 40))
    print("🛑 TELEPORT STOPPED")
    print("=" .. string.rep("=", 40))
end

-- ============================================
-- ИНИЦИАЛИЗАЦИЯ И НАСТРОЙКА
-- ============================================

-- Настройка Rayfield
Rayfield:SetHotkey("RightShift")
Rayfield:SetWatermark("POLOHUB v2.0")

-- Инициализация статусов
updateStatus()
TeleportStatusLabel:Set("Teleport: 🔴 OFF")
TeleportStatusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)

print("======================================")
print("POLOHUB MANAGER LOADED")
print("• Items: " .. #AllYBAItems .. " available")
print("• Teleport depth: " .. math.abs(UndergroundTeleport.Depth) .. " studs")
print("• Settings tab for teleport controls")
print("======================================")
