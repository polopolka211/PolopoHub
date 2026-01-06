-- ============================================
-- ПРОСТОЙ ТЕЛЕПОРТ ПО ВСЕМ ОБЪЕКТАМ (ПОДЗЕМНЫЙ)
-- ============================================

local TeleportService = {
    IsTeleporting = false,
    TeleportConnection = nil,
    UndergroundDepth = -15, -- Глубина под землей
    TeleportDelay = 0.5, -- Задержка между телепортами
    MaxDistance = 8 -- Максимальная дистанция для подбора
}

-- Получаем путь к объектам
local function getItemsPath()
    -- Пробуем разные варианты написания
    local paths = {
        workspace:FindFirstChild("Item_Spawns"),
        workspace:FindFirstChild("Item_spawns"),
        workspace:FindFirstChild("ItemSpawns")
    }
    
    for _, path in pairs(paths) do
        if path and path:FindFirstChild("Items") then
            return path:FindFirstChild("Items")
        end
    end
    
    warn("[!] Не найден путь Item_Spawns/Items")
    return nil
end

-- Найти ВСЕ модели с промптами
local function findAllItemModels()
    local itemsFolder = getItemsPath()
    if not itemsFolder then return {} end
    
    local allModels = {}
    
    -- Рекурсивно ищем все модели
    local function scanForModels(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Model") then
                -- Проверяем, есть ли в модели ProximityPrompt
                local prompt = child:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    table.insert(allModels, {
                        Model = child,
                        Prompt = prompt,
                        Position = child:GetPivot().Position
                    })
                end
                
                -- Рекурсивно проверяем вложенные модели
                scanForModels(child)
            end
        end
    end
    
    scanForModels(itemsFolder)
    return allModels
end

-- Подземный телепорт к координатам
local function undergroundTeleportTo(position)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    -- Позиция под объектом
    local undergroundPos = Vector3.new(
        position.X,
        position.Y + TeleportService.UndergroundDepth,
        position.Z
    )
    
    -- Поворачиваемся лицом к объекту
    local lookAt = CFrame.lookAt(undergroundPos, position)
    
    -- Телепорт
    humanoidRootPart.CFrame = lookAt
    
    print(string.format("[→] Телепорт: X=%.1f, Y=%.1f, Z=%.1f", 
        undergroundPos.X, undergroundPos.Y, undergroundPos.Z))
    
    return true
end

-- Основной цикл телепортации
local function teleportLoop()
    if not TeleportService.IsTeleporting then return end
    
    -- Находим все модели
    local allModels = findAllItemModels()
    
    if #allModels == 0 then
        print("[!] Модели не найдены")
        task.wait(2)
        return
    end
    
    print("[📊] Найдено объектов: " .. #allModels)
    
    -- Телепортируемся под каждый объект
    for i, modelData in pairs(allModels) do
        if not TeleportService.IsTeleporting then break end
        
        print(string.format("[%d/%d] Телепорт к объекту...", i, #allModels))
        
        -- Телепортируемся
        if undergroundTeleportTo(modelData.Position) then
            -- Ждем нужную дистанцию для подбора (8 studs)
            task.wait(0.3)
            
            -- Проверяем дистанцию
            local character = game.Players.LocalPlayer.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distance = (hrp.Position - modelData.Position).Magnitude
                    print(string.format("   📏 Дистанция: %.1f studs", distance))
                    
                    if distance <= TeleportService.MaxDistance then
                        print("   ✅ В радиусе подбора (8 studs)")
                    else
                        print("   ⚠️  Слишком далеко")
                    end
                end
            end
            
            -- Ждем перед следующим телепортом
            task.wait(TeleportService.TeleportDelay)
        end
    end
    
    print("[✓] Цикл телепортации завершен")
end

-- Запуск телепортации
function TeleportService:StartTeleporting()
    if self.IsTeleporting then
        print("[!] Телепортация уже запущена")
        return false
    end
    
    self.IsTeleporting = true
    
    print("=" .. string.rep("=", 50))
    print("🚀 ЗАПУСК ТЕЛЕПОРТАЦИИ")
    print("Глубина: " .. math.abs(self.UndergroundDepth) .. " studs под землей")
    print("Дистанция подбора: " .. self.MaxDistance .. " studs")
    print("=" .. string.rep("=", 50))
    
    -- Запускаем цикл
    self.TeleportConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if self.IsTeleporting then
            teleportLoop()
            task.wait(1) -- Пауза между полными циклами
        else
            if self.TeleportConnection then
                self.TeleportConnection:Disconnect()
                self.TeleportConnection = nil
            end
        end
    end)
    
    return true
end

-- Остановка телепортации
function TeleportService:StopTeleporting()
    if not self.IsTeleporting then return end
    
    self.IsTeleporting = false
    
    if self.TeleportConnection then
        self.TeleportConnection:Disconnect()
        self.TeleportConnection = nil
    end
    
    print("=" .. string.rep("=", 50))
    print("🛑 ТЕЛЕПОРТАЦИЯ ОСТАНОВЛЕНА")
    print("=" .. string.rep("=", 50))
end

-- ============================================
-- ИНТЕГРАЦИЯ С RAYFIELD UI
-- ============================================

-- ДОБАВЬТЕ В ВАШ КОД RAYFIELD:

-- 1. Создайте новую вкладку для телепортации
local TeleportTab = Window:CreateTab("Teleport", nil)
local TeleportSection = TeleportTab:CreateSection("Подземная телепортация")

-- 2. Кнопка запуска/остановки телепортации
local TeleportButton = TeleportTab:CreateButton({
    Name = "🔄 Начать подземную телепортацию",
    Callback = function()
        if TeleportService.IsTeleporting then
            -- Останавливаем
            TeleportService:StopTeleporting()
            TeleportButton:Set("🔄 Начать подземную телепортацию")
            
            Rayfield:Notify({
                Title = "Телепортация остановлена",
                Content = "Прекращено перемещение по объектам",
                Duration = 2,
            })
        else
            -- Запускаем
            local success = TeleportService:StartTeleporting()
            
            if success then
                TeleportButton:Set("⏹️ Остановить телепортацию")
                
                Rayfield:Notify({
                    Title = "Телепортация запущена",
                    Content = "Перемещение под всеми объектами",
                    Duration = 3,
                })
            end
        end
    end,
})

-- 3. Слайдер для настройки глубины
local DepthSlider = TeleportTab:CreateSlider({
    Name = "Глубина под землей",
    Range = {5, 30},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = math.abs(TeleportService.UndergroundDepth),
    Flag = "UndergroundDepth",
    Callback = function(Value)
        TeleportService.UndergroundDepth = -Value -- Отрицательное значение (под землей)
        print("Глубина установлена: " .. Value .. " studs")
    end,
})

-- 4. Слайдер для дистанции подбора
local DistanceSlider = TeleportTab:CreateSlider({
    Name = "Дистанция подбора",
    Range = {5, 15},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = TeleportService.MaxDistance,
    Flag = "PickupDistance",
    Callback = function(Value)
        TeleportService.MaxDistance = Value
        print("Дистанция подбора: " .. Value .. " studs")
    end,
})

-- 5. Информационная панель
local InfoSection = TeleportTab:CreateSection("Информация")
local StatusLabel = TeleportTab:CreateLabel("Статус: Остановлено")
local ObjectsLabel = TeleportTab:CreateLabel("Объектов: 0")

-- Функция обновления статуса
local function updateTeleportStatus()
    if TeleportService.IsTeleporting then
        StatusLabel:Set("Статус: 📍 Телепортация активна")
        StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
    else
        StatusLabel:Set("Статус: ⏸️ Остановлено")
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- 6. Кнопка быстрой проверки объектов
local CheckObjectsButton = TeleportTab:CreateButton({
    Name = "🔍 Проверить объекты",
    Callback = function()
        local models = findAllItemModels()
        ObjectsLabel:Set("Объектов: " .. #models)
        
        Rayfield:Notify({
            Title = "Проверка объектов",
            Content = "Найдено: " .. #models .. " моделей с промптами",
            Duration = 3,
        })
        
        print("[📊] Статистика объектов:")
        for i, model in pairs(models) do
            print(string.format("  %d. Pos: (%.1f, %.1f, %.1f)", 
                i, model.Position.X, model.Position.Y, model.Position.Z))
        end
    end,
})

-- Инициализация
updateTeleportStatus()
