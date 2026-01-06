-- ============================================
-- POLOHUB - COMPLETE VERSION
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
local UndergroundTeleport = {
    Enabled = false,
    Connection = nil,
    Depth = -15,
    Delay = 0.3,
    MaxDistance = 8
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
-- СЕКЦИЯ ТЕЛЕПОРТАЦИИ (В ТОЙ ЖЕ ВКЛАДКЕ)
-- ============================================
local TeleportSection = ItemsTab:CreateSection("Underground Teleport")

-- Кнопка телепортации
local TeleportButton = ItemsTab:CreateButton({
    Name = "📍 Start Underground Teleport",
    Callback = function()
        if UndergroundTeleport.Enabled then
            -- Останавливаем телепорт
            UndergroundTeleport.Stop()
            TeleportButton:Set("📍 Start Underground Teleport")
            
            Rayfield:Notify({
                Title = "Teleport Stopped",
                Content = "Underground teleportation disabled",
                Duration = 2,
            })
        else
            -- Запускаем телепорт
            UndergroundTeleport.Start()
            TeleportButton:Set("⏹️ Stop Teleport")
            
            Rayfield:Notify({
                Title = "Teleport Active",
                Content = "Moving under all objects",
                Duration = 2,
            })
        end
        updateTeleportStatus()
    end,
})

-- Слайдер глубины
local DepthSlider = ItemsTab:CreateSlider({
    Name = "Teleport Depth",
    Range = {5, 30},
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
local DelaySlider = ItemsTab:CreateSlider({
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

-- ============================================
-- ИНФОРМАЦИОННАЯ СЕКЦИЯ
-- ============================================
local InfoSection = ItemsTab:CreateSection("Information")

local StatusLabel = ItemsTab:CreateLabel("Status: Ready")
local SelectedCountLabel = ItemsTab:CreateLabel("Selected: 0 items")
local TeleportStatusLabel = ItemsTab:CreateLabel("Teleport: 🔴 OFF")

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

local function updateTeleportStatus()
    if UndergroundTeleport.Enabled then
        TeleportStatusLabel:Set("Teleport: 🟢 ACTIVE")
        TeleportStatusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
    else
        TeleportStatusLabel:Set("Teleport: 🔴 OFF")
        TeleportStatusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
    end
end

-- ============================================
-- МОДУЛЬ ПОДЗЕМНОЙ ТЕЛЕПОРТАЦИИ
-- ============================================

-- Функция поиска всех точек телепортации
local function findAllTeleportPoints()
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
                local prompt = child:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    table.insert(teleportPoints, {
                        Model = child,
                        Position = child:GetPivot().Position
                    })
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
    local character = game.Players.LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local undergroundPos = Vector3.new(
        pointPosition.X,
        pointPosition.Y + UndergroundTeleport.Depth,
        pointPosition.Z
    )
    
    humanoidRootPart.CFrame = CFrame.lookAt(undergroundPos, pointPosition)
    return true
end

-- Проверка дистанции
local function checkPickupDistance(objectPosition)
    local character = game.Players.LocalPlayer.Character
    if not character then return 0 end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    
    return (hrp.Position - objectPosition).Magnitude
end

-- Основной цикл телепортации
local function teleportationLoop()
    if not UndergroundTeleport.Enabled then return end
    
    local points = findAllTeleportPoints()
    if #points == 0 then
        task.wait(2)
        return
    end
    
    print("[Teleport] Points found: " .. #points)
    
    for i, point in pairs(points) do
        if not UndergroundTeleport.Enabled then break end
        
        print(string.format("[Teleport] %d/%d", i, #points))
        
        if teleportToPoint(point.Position) then
            task.wait(0.2)
            
            local distance = checkPickupDistance(point.Position)
            print(string.format("[Teleport] Distance: %.1f studs", distance))
            
            if distance <= UndergroundTeleport.MaxDistance then
                print("[Teleport] ✓ In pickup range")
            end
            
            task.wait(UndergroundTeleport.Delay)
        end
    end
    
    print("[Teleport] Cycle complete")
end

-- Запуск телепортации
function UndergroundTeleport.Start()
    if UndergroundTeleport.Enabled then
        print("[Teleport] Already running")
        return false
    end
    
    UndergroundTeleport.Enabled = true
    
    print("=" .. string.rep("=", 40))
    print("🚀 UNDERGROUND TELEPORT STARTED")
    print("Depth: " .. math.abs(UndergroundTeleport.Depth) .. " studs")
    print("Target distance: " .. UndergroundTeleport.MaxDistance .. " studs")
    print("=" .. string.rep("=", 40))
    
    UndergroundTeleport.Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if UndergroundTeleport.Enabled then
            teleportationLoop()
            task.wait(0.5)
        else
            if UndergroundTeleport.Connection then
                UndergroundTeleport.Connection:Disconnect()
                UndergroundTeleport.Connection = nil
            end
        end
    end)
    
    return true
end

-- Остановка телепортации
function UndergroundTeleport.Stop()
    if not UndergroundTeleport.Enabled then return end
    
    UndergroundTeleport.Enabled = false
    
    if UndergroundTeleport.Connection then
        UndergroundTeleport.Connection:Disconnect()
        UndergroundTeleport.Connection = nil
    end
    
    print("=" .. string.rep("=", 40))
    print("🛑 TELEPORT STOPPED")
    print("=" .. string.rep("=", 40))
end

-- ============================================
-- ИНИЦИАЛИЗАЦИЯ И НАСТРОЙКА
-- ============================================

-- Настройка Rayfield
Rayfield:SetHotkey("RightShift")
Rayfield:SetWatermark("POLOHUB Items Manager")

-- Инициализация
updateStatus()
updateTeleportStatus()

print("======================================")
print("POLOHUB MANAGER LOADED")
print("• " .. #AllYBAItems .. " items available")
print("• Select items from dropdown")
print("• Use RightShift to toggle UI")
print("======================================")
