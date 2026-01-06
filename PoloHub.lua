-- ============================================
-- POLOHUB - WISTERIA VERSION
-- Полный перенос с Rayfield на Wisteria
-- ============================================

-- Загружаем Wisteria вместо Rayfield
local Wisteria = loadstring(game:HttpGet("https://raw.githubusercontent.com/BatsAndCode/Wisteria/main/source.lua"))()

-- Создаём главное окно Wisteria
local Window = Wisteria:CreateWindow({
    Title = "POLOHUB | ITEMS",
    SubTitle = "by polopolka211",
    Size = UDim2.new(0, 500, 0, 450), -- Размер окна
    Theme = "Dark" -- Тема: Dark, Light, Blue, Red
})

-- ============================================
-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
-- ============================================
local SelectedItems = {}
local UndergroundTeleport = {
    Enabled = false,
    Connection = nil,
    Depth = -8,
    Delay = 0.3,
    MaxDepth = 8
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
-- ГЛАВНАЯ ВКЛАДКА (ITEMS)
-- ============================================
local ItemsTab = Window:AddTab({
    Name = "Items"
})

-- Секция выбора предметов
ItemsTab:AddSection({
    Name = "Items to Farm"
})

-- Выпадающий список выбора предметов (мультивыбор)
local ItemsDropdown = ItemsTab:AddDropdown({
    Name = "Select Items",
    Options = AllYBAItems,
    Multi = true, -- Мультивыбор
    Default = {}, -- Пустой по умолчанию
    Callback = function(SelectedOptions)
        SelectedItems = SelectedOptions
        updateStatus()
        
        if #SelectedOptions > 0 then
            Window:Notify({
                Title = "Items Selected",
                Content = "Selected " .. #SelectedOptions .. " items",
                Duration = 2
            })
            
            print("=== SELECTED ITEMS ===")
            for i, item in ipairs(SelectedOptions) do
                print(i .. ". " .. item)
            end
            print("======================")
        else
            print("No items selected")
        end
    end
})

-- Секция быстрого выбора
ItemsTab:AddSection({
    Name = "Quick Selection"
})

-- Кнопка выбора всех
ItemsTab:AddButton({
    Name = "Select All Items",
    Callback = function()
        ItemsDropdown:Set(AllYBAItems)
        print("All items selected")
    end
})

-- Кнопка очистки выбора
ItemsTab:AddButton({
    Name = "Clear Selection",
    Callback = function()
        ItemsDropdown:Set({})
        print("Selection cleared")
    end
})

-- Счётчик выбранных предметов
local SelectedCountLabel = ItemsTab:AddLabel({
    Name = "Selected: 0 items",
    Center = false
})

-- Статус
local StatusLabel = ItemsTab:AddLabel({
    Name = "Status: Ready",
    Center = false
})

-- ============================================
-- ВКЛАДКА НАСТРОЕК (TELEPORT)
-- ============================================
local SettingsTab = Window:AddTab({
    Name = "Settings"
})

-- Секция настроек телепорта
SettingsTab:AddSection({
    Name = "Teleport Settings"
})

-- Переключатель телепортации
local TeleportToggle = SettingsTab:AddToggle({
    Name = "Underground Teleport",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Включаем телепорт
            local success = UndergroundTeleport.Start()
            if success then
                TeleportStatusLabel:Set("Teleport: 🟢 ACTIVE")
                print("[Teleport] Toggle ON")
            else
                TeleportToggle:Set(false)
            end
        else
            -- Выключаем телепорт
            UndergroundTeleport.Stop()
            TeleportStatusLabel:Set("Teleport: 🔴 OFF")
            print("[Teleport] Toggle OFF")
        end
    end
})

-- Слайдер глубины (1-8 studs)
SettingsTab:AddSlider({
    Name = "Teleport Depth",
    Min = 1,
    Max = 8,
    Default = math.abs(UndergroundTeleport.Depth),
    ValueName = "studs",
    Callback = function(Value)
        UndergroundTeleport.Depth = -Value
        print("[Teleport] Depth set: " .. Value .. " studs")
    end
})

-- Слайдер задержки
SettingsTab:AddSlider({
    Name = "Teleport Delay",
    Min = 0.1,
    Max = 1.0,
    Default = UndergroundTeleport.Delay,
    ValueName = "sec",
    Callback = function(Value)
        UndergroundTeleport.Delay = Value
        print("[Teleport] Delay set: " .. Value .. " sec")
    end
})

-- Кнопка теста пути
SettingsTab:AddButton({
    Name = "Test Item Path",
    Callback = function()
        local points = UndergroundTeleport.FindAllPoints()
        Window:Notify({
            Title = "Path Test",
            Content = "Found " .. #points .. " items",
            Duration = 3
        })
    end
})

-- Статус телепорта
local TeleportStatusLabel = SettingsTab:AddLabel({
    Name = "Teleport: 🔴 OFF",
    Center = false
})

-- ============================================
-- ФУНКЦИЯ ОБНОВЛЕНИЯ СТАТУСА
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
-- МОДУЛЬ ТЕЛЕПОРТАЦИИ (адаптированный для Wisteria)
-- ============================================

-- Функция поиска всех точек
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
                for _, obj in pairs(child:GetChildren()) do
                    if obj:IsA("ProximityPrompt") then
                        table.insert(teleportPoints, {
                            Model = child,
                            Position = child:GetPivot().Position
                        })
                        break
                    end
                end
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
    
    local undergroundPos = Vector3.new(
        pointPosition.X,
        math.min(pointPosition.Y + UndergroundTeleport.Depth, pointPosition.Y - 1),
        pointPosition.Z
    )
    
    local success, err = pcall(function()
        humanoidRootPart.CFrame = CFrame.new(undergroundPos)
    end)
    
    if not success then
        print("[Teleport] Teleport failed: " .. tostring(err))
        return false
    end
    
    return true
end

-- Основной цикл телепортации
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
        
        if teleportToPoint(point.Position) then
            task.wait(0.3)
            
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
            
            task.wait(UndergroundTeleport.Delay)
        else
            print("[Teleport] Failed to teleport to point")
        end
    end
    
    print("[Teleport] Cycle complete, restarting...")
end

-- Запуск телепортации
function UndergroundTeleport.Start()
    if UndergroundTeleport.Enabled then
        print("[Teleport] Already running")
        return false
    end
    
    UndergroundTeleport.Enabled = true
    
    print("=" .. string.rep("=", 40))
    print("🚀 UNDERGROUND TELEPORT STARTED (Wisteria)")
    print("Depth: " .. math.abs(UndergroundTeleport.Depth) .. " studs")
    print("Delay: " .. UndergroundTeleport.Delay .. " sec")
    print("=" .. string.rep("=", 40))
    
    local function safeLoop()
        while UndergroundTeleport.Enabled do
            local success, err = pcall(teleportationLoop)
            if not success then
                warn("[Teleport] Loop error: " .. tostring(err))
            end
            task.wait(0.5)
        end
    end
    
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
-- ИНИЦИАЛИЗАЦИЯ И ЗАВЕРШЕНИЕ
-- ============================================

-- Открываем окно после создания
Window:Open()

-- Обновляем начальный статус
updateStatus()

print("=" .. string.rep("=", 50))
print("POLOHUB WISTERIA EDITION LOADED")
print("• Items: " .. #AllYBAItems .. " available")
print("• Teleport depth: " .. math.abs(UndergroundTeleport.Depth) .. " studs")
print("• Interface: Wisteria Library")
print("=" .. string.rep("=", 50))

-- Возвращаем объект Window для внешнего управления
return Window
