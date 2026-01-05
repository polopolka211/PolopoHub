-- ============================================
-- ПОЛНАЯ ДИАГНОСТИКА СКРИПТА POLOHUB
-- ============================================

print("🔍 Начинаю диагностику POLOHUB GUI...")
print("═" .. string.rep("═", 50))

-- 1. ПРОВЕРКА ССЫЛКИ И ЗАГРУЗКИ
local test_url = "https://raw.githubusercontent.com/polopolka211/PolopoHub/refs/heads/main/PoloHub.lua"
print("[1/5] Проверяю доступ к файлу GitHub...")
print("📎 URL:", test_url)

local content, http_error
local http_success, http_result = pcall(function()
    return game:HttpGet(test_url, true) -- true = асинхронный запрос
end)

if http_success then
    content = http_result
    print("✅ Файл успешно загружен")
    print("   📏 Размер:", #content, "символов")
    print("   🔠 Первые 100 символов:", string.sub(content, 1, 100) .. "...")
else
    http_error = http_result
    print("❌ ОШИБКА ЗАГРУЗКИ ФАЙЛА!")
    print("   🚫 Тип ошибки:", type(http_error))
    print("   📄 Сообщение:", tostring(http_error))
    
    -- Попробуем альтернативную ссылку
    print("   🔄 Пробую альтернативный формат ссылки...")
    local alt_url = "https://raw.githubusercontent.com/polopolka211/PolopoHub/main/PoloHub.lua"
    local alt_success, alt_content = pcall(game.HttpGet, game, alt_url)
    if alt_success then
        print("   ✅ Альтернативная ссылка сработала!")
        content = alt_content
        test_url = alt_url
    else
        print("   ❌ Альтернативная ссылка тоже не работает")
        print("   💡 Рекомендация: проверьте, публичный ли репозиторий PolopoHub")
        print("      Откройте в браузере: https://github.com/polopolka211/PolopoHub")
        print("      Если не видите кода, в Settings → General сделайте репозиторий Public")
        return
    end
end

print("═" .. string.rep("═", 50))

-- 2. ПРОВЕРКА СИНТАКСИСА LUA
print("[2/5] Анализирую синтаксис Lua...")

local chunk, parse_error = loadstring(content, "PoloHubGUI")

if chunk then
    print("✅ Синтаксис корректный")
    
    -- Проверяем, какие глобальные переменные создаст скрипт
    local env = {
        print = function(...)
            local args = {...}
            local result = ""
            for i = 1, select('#', ...) do
                result = result .. tostring(args[i]) .. "\t"
            end
            print("   [СКРИПТ]:", result)
        end,
        wait = task.wait,
        game = game,
        Color3 = Color3,
        UDim2 = UDim2,
        Vector2 = Vector2,
        Enum = Enum,
        Instance = Instance,
        task = task
    }
    
    setfenv(chunk, env)
    
else
    print("❌ ОШИБКА СИНТАКСИСА!")
    print("   📍 Позиция ошибки:", parse_error)
    
    -- Пытаемся найти строку с ошибкой
    if type(parse_error) == "string" then
        local line_num = parse_error:match(":(%d+):")
        if line_num then
            line_num = tonumber(line_num)
            local lines = {}
            for line in content:gmatch("[^\n]+") do
                table.insert(lines, line)
            end
            if lines[line_num] then
                print("   📝 Строка " .. line_num .. ":", lines[line_num])
            end
        end
    end
    return
end

print("═" .. string.rep("═", 50))

-- 3. ВЫПОЛНЕНИЕ СКРИПТА В ЗАЩИЩЕННОМ РЕЖИМЕ
print("[3/5] Выполняю скрипт в защищенном режиме...")

local exec_success, exec_error = pcall(function()
    -- Создаем песочницу для безопасного выполнения
    local sandbox = {
        print = print,
        warn = warn,
        error = error,
        pcall = pcall,
        xpcall = xpcall,
        select = select,
        type = type,
        tostring = tostring,
        tonumber = tonumber,
        pairs = pairs,
        ipairs = ipairs,
        next = next,
        unpack = unpack,
        table = table,
        string = string,
        math = math,
        coroutine = coroutine,
        _VERSION = _VERSION,
        
        -- Roblox API (ограниченный набор)
        game = game,
        workspace = workspace,
        Players = game:GetService("Players"),
        CoreGui = game:GetService("CoreGui"),
        UserInputService = game:GetService("UserInputService"),
        TweenService = game:GetService("TweenService"),
        
        -- Roblox типы
        Color3 = Color3,
        UDim2 = UDim2,
        Vector2 = Vector2,
        Vector3 = Vector3,
        CFrame = CFrame,
        Enum = Enum,
        Instance = Instance,
        BrickColor = BrickColor,
        
        -- Безопасные аналоги
        spawn = task.spawn,
        delay = task.delay,
        wait = task.wait,
        
        -- Ограничения
        getfenv = function() return sandbox end,
        setfenv = function(f, env) return f end,
        loadstring = function() error("loadstring disabled in sandbox") end,
        require = function() error("require disabled in sandbox") end,
        _G = sandbox
    }
    
    setfenv(chunk, sandbox)
    return chunk()
end)

if exec_success then
    print("✅ Скрипт выполнен без критических ошибок")
    print("   💡 Возможно, GUI создано, но невидимо или находится вне экрана")
else
    print("❌ ОШИБКА ВЫПОЛНЕНИЯ СКРИПТА!")
    print("   📄 Сообщение:", tostring(exec_error))
    
    -- Анализируем распространенные ошибки
    local err_msg = tostring(exec_error):lower()
    
    if err_msg:find("attempt to index") then
        print("   🔍 Возможно, не хватает Roblox-сервиса")
    elseif err_msg:find("invalid argument") then
        print("   🔍 Проблема с аргументами функции")
    elseif err_msg:find("expected") then
        print("   🔍 Ожидался другой тип данных")
    elseif err_msg:find("cannot create instance") then
        print("   🔍 Проблема с созданием Roblox-объектов")
    end
    
    -- Выводим стек вызовов
    print("   📊 Трассировка стека:")
    local trace = debug.traceback(exec_error, 2)
    for line in trace:gmatch("[^\n]+") do
        print("      " .. line)
    end
end

print("═" .. string.rep("═", 50))

-- 4. ПРОВЕРКА ДОСТУПА К ИГРОВЫМ СЕРВИСАМ
print("[4/5] Проверяю доступ к необходимым сервисам...")

local required_services = {
    "Players",
    "CoreGui", 
    "UserInputService",
    "TweenService",
    "Workspace"
}

local all_services_ok = true
for _, service_name in ipairs(required_services) do
    local success, service = pcall(game.GetService, game, service_name)
    if success and service then
        print("   ✅ " .. service_name .. " — доступен")
    else
        print("   ❌ " .. service_name .. " — НЕ доступен")
        all_services_ok = false
    end
end

if not all_services_ok then
    print("   ⚠️  Отсутствуют некоторые сервисы. Это может быть причиной.")
end

print("═" .. string.rep("═", 50))

-- 5. ЗАПУСК ПОЛНОЙ ВЕРСИИ СКРИПТА (если все проверки пройдены)
print("[5/5] Пробую запустить оригинальный скрипт...")

if content and chunk and all_services_ok then
    print("🚀 Запускаю POLOHUB GUI...")
    
    -- Запускаем оригинальный код
    local final_success, final_error = pcall(function()
        local func = loadstring(content, "PoloHubFinal")
        if func then
            func()
        end
    end)
    
    if final_success then
        print("========================================")
        print("🎉 POLOHUB GUI УСПЕШНО ЗАПУЩЕН!")
        print("========================================")
        print("💡 Если окно не видно, попробуйте:")
        print("   1. Нажать RightControl для показа/скрытия")
        print("   2. Проверить, что скрипт выполняется в правильном контексте")
    else
        print("❌ ФИНАЛЬНАЯ ОШИБКА ПРИ ЗАПУСКЕ:")
        print("   " .. tostring(final_error))
    end
else
    print("⚠️  Пропускаю финальный запуск из-за предыдущих ошибок")
end

print("═" .. string.rep("═", 50))
print("🔚 Диагностика завершена")
