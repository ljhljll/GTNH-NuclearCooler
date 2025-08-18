local database = require("database")
local action = require("action")
local detection = require("coolantcellThread")
local config = require("config")
local coroutine = require("coroutine")
local computer = require("computer")
local component = require("component")

-- 协程类型定义
local COROUTINE_TYPES = {
    REACTOR = 0,
    LOGGER = 1,
    HEAT_MONITOR = 2
}

-- 温度监控器，过热强制关机避免爆炸
local function heatMonitor(rcTable)
    local checkInterval = 0.1 -- 检查间隔
    local lastCheck = 0

    while true do
        local currentTime = computer.uptime()
        if currentTime - lastCheck >= checkInterval then
            for i = 1, #rcTable do
                local rc = database.reactorChambers[rcTable[i]]
                if not rc or rc.scheme == "mox" or not rc.aborted then
                    goto continue_reactor
                end

                local rcComponent = component.proxy(rc.reactorChamberAddr)
                if not rcComponent then goto continue_reactor end

                local heat = rcComponent.getHeat()
                local threshold = rc.thresholdHeat or 0

                if heat >= threshold + 100 or heat >= 9960 then
                    print(string.format("警告: %s 温度过高 (%d K)，执行紧急停堆！", rc.name, heat))
                    rc.aborted = true
                    action.stopReactorChamberByRc(rc, false)
                end
                ::continue_reactor::
            end
            lastCheck = currentTime
        end
        coroutine.yield()
    end
end

-- 清理控制台打印信息，防止内存溢出
local function clearAndIntervalMessages(rcTable)
    local clearLogInterval = math.max(config.cleatLogInterval or 30, 5)

    while true do
        action.coroutineSleep(clearLogInterval)
        os.execute("cls")

        -- 批量处理输出，减少协程yield
        printResidentMessages()
        printOverHeated(rcTable)
        print(string.format("下一次清屏计划在 %d 秒后", clearLogInterval))

        -- 只在最后yield一次
        coroutine.yield()
    end
end

-- 协程管理器
local CoroutineManager = {
    creators = {
        [COROUTINE_TYPES.REACTOR] = function(rc)
            return function() detection.runningReactorChamber(rc) end
        end,
        [COROUTINE_TYPES.LOGGER] = function(rcTable)
            return function() clearAndIntervalMessages(rcTable) end
        end,
        [COROUTINE_TYPES.HEAT_MONITOR] = function(rcTable)
            return function() heatMonitor(rcTable) end
        end
    }
}

function CoroutineManager.restartCoroutine(coroutineData, rcTable)
    local creator = CoroutineManager.creators[coroutineData.type]
    if not creator then return nil end
    
    local newCoro = coroutine.create(creator(rcTable[coroutineData.index] or rcTable))
    return newCoro
end

local function printResidentMessages()
    local time = computer.uptime()
    local diffSeconds = math.floor(time - database.startTimeStamp)
    local days = math.floor(diffSeconds / 86400)
    local hours = math.floor((diffSeconds % 86400) / 3600)
    local minutes = math.floor((diffSeconds % 3600) / 60)
    print(string.format("本核电站已安全运行 %d 天 %d 时 %d 分。道路千万条，安全第一条；核电不规范，回档两行泪。", days, hours, minutes))
end

local function printOverHeated(rcTable)
    local outputLines = {}
    for i = 1, #rcTable do
        local rc = database.reactorChambers[rcTable[i]]
        if not rc then goto continue end
        
        local rcComponent = component.proxy(rc.reactorChamberAddr)
        if not rcComponent then goto continue end
        
        local heat = rcComponent.getHeat()
        if rc.aborted then 
            table.insert(outputLines, string.format("The heat of %s is %d K, it is aborted due to over-heated", rc.name, heat))
        else
            table.insert(outputLines, string.format("The heat of %s is %d K", rc.name, heat))
        end
        ::continue::
    end
    
    -- 一次性输出所有行，减少I/O操作
    for _, line in ipairs(outputLines) do
        print(line)
    end
    outputLines = nil -- 清理内存
end

-- 处理协程错误并重启
local function handleCoroutineError(coroutineData, rcTable)
    print(string.format("协程 %d (类型: %d) 发生错误，正在重启...", coroutineData.index, coroutineData.type))
    
    -- 关闭旧协程
    if coroutine.status(coroutineData.coroutine) ~= "dead" then
        coroutineData.coroutine = nil
    end
    
    -- 创建新协程
    local newCoro = CoroutineManager.restartCoroutine(coroutineData, rcTable)
    if newCoro then
        coroutineData.coroutine = newCoro
        local success, err = coroutine.resume(newCoro)
        if not success then
            print(string.format("协程重启失败: %s", err))
            return false
        end
        return true
    else
        print(string.format("无法重启协程: 未知的协程类型 %d", coroutineData.type))
        return false
    end
end

-- 主协程调度器
local function runCoroutineScheduler(coroutines, rcTable)
    local running = true
    
    while running do
        -- 检查全局开关
        if not database.getGlobalRedstone() then
            print("检测到全局开关关闭，准备安全停机...")
            running = false
            break
        end
        
        -- 调度所有协程
        for i = 1, #coroutines do
            local coroData = coroutines[i]
            if coroutine.status(coroData.coroutine) ~= "dead" then
                local success, err = coroutine.resume(coroData.coroutine)
                if not success then
                    handleCoroutineError(coroData, rcTable)
                end
            end
        end
        
        os.sleep(0) -- 最高效的调度间隔
    end
    
    return running
end

-- 安全停机流程
local function emergencyShutdown(rcTable)
    print("开始执行紧急停机程序...")
    
    local shutdownCoroutines = {}
    for i = 1, #rcTable do
        shutdownCoroutines[i] = coroutine.create(function()
            local rc = database.reactorChambers[rcTable[i]]
            if rc then
                action.stopReactorChamberByRc(rc, true)
            end
        end)
        coroutine.resume(shutdownCoroutines[i])
    end
    
    -- 等待所有反应堆停机
    local shutdownTimeout = computer.uptime() + 30 -- 30秒超时
    while computer.uptime() < shutdownTimeout do
        local stoppedCount = 0
        for i = 1, #shutdownCoroutines do
            local status = coroutine.status(shutdownCoroutines[i])
            if status == "dead" then
                stoppedCount = stoppedCount + 1
            end
        end
        
        if stoppedCount == #rcTable then
            print("所有反应堆已安全停机")
            return true
        end
        
        os.sleep(0.1)
    end
    
    print("警告：停机超时，部分反应堆可能未完全关闭")
    return false
end

local function reactorChamberStart(rcTable)
    os.execute("cls")
    print(string.format("启动 %d 个核反应堆控制程序...", #rcTable))
    
    local coroutines = {}
    
    -- 创建反应堆监控协程
    for i = 1, #rcTable do
        local rc = database.reactorChambers[rcTable[i]]
        coroutines[i] = {
            coroutine = coroutine.create(function() detection.runningReactorChamber(rc) end),
            type = COROUTINE_TYPES.REACTOR,
            index = i
        }
    end
    
    -- 创建日志协程
    coroutines[#coroutines + 1] = {
        coroutine = coroutine.create(function() clearAndIntervalMessages(rcTable) end),
        type = COROUTINE_TYPES.LOGGER,
        index = #coroutines + 1
    }
    
    -- 创建温度监控协程
    coroutines[#coroutines + 1] = {
        coroutine = coroutine.create(function() heatMonitor(rcTable) end),
        type = COROUTINE_TYPES.HEAT_MONITOR,
        index = #coroutines + 1
    }
    
    -- 运行主调度器
    local running = runCoroutineScheduler(coroutines, rcTable)
    
    -- 清理协程资源
    for _, coroData in ipairs(coroutines) do
        if coroutine.status(coroData.coroutine) ~= "dead" then
            coroData.coroutine= nil
        end
    end
    coroutines = nil
    
    -- 执行停机
    if not running then
        emergencyShutdown(rcTable)
    end
    
    print("核反应堆控制系统已关闭")
end

-- 验证用户输入的反应堆配置
local function validateReactorConfig(choices)
    local validChoices = {}
    local maxConfig = #config.reactorChamberList
    
    for _, choice in ipairs(choices) do
        if choice >= 1 and choice <= maxConfig then
            table.insert(validChoices, choice)
        else
            print(string.format("警告: 配置 %d 无效，跳过 (有效范围: 1-%d)", choice, maxConfig))
        end
    end
    
    if #validChoices == 0 then
        print("错误: 没有有效的反应堆配置")
        return nil
    end
    
    return validChoices
end
-- 主入口
local function justStart()
    print("=== GTNH 核反应堆控制系统 ===")
    print("(0) 直接启动 (1) 配置启动 (-1) 退出")
    
    local model = io.read()
    if model == "-1" then 
        print("退出系统")
        return 
    end
    
    if model ~= "0" and model ~= "1" then
        print("无效选择，退出系统")
        return
    end
    
    print("请输入要启动的反应堆配置编号 (1-" .. #config.reactorChamberList .. ")，用空格分隔:")
    local input = io.read()
    
    -- 解析用户输入
    local choices = {}
    for num in input:gmatch("%d+") do
        table.insert(choices, tonumber(num))
    end
    
    -- 验证配置
    local runningTable = validateReactorConfig(choices)
    if not runningTable then
        return
    end
    
    print(string.format("准备启动以下反应堆: %s", table.concat(runningTable, ", ")))
    
    database.startTimeStamp = computer.uptime()
    
    if model == "1" then
        print("执行初始材料装载...")
        local success, err = pcall(action.insertItemsIntoReactorChamber, runningTable)
        if not success then
            print(string.format("材料装载失败: %s", err))
            return
        end
        print("材料装载完成")
    end
    
    reactorChamberStart(runningTable)
end

-- 系统初始化和安全检查
local function systemInit()
    print("系统初始化中...")
    
    -- 检查全局开关状态
    if not database.getGlobalRedstone() then
        print("错误: 未开启全局安全开关")
        action.stopAllReactorChamber(false)
        os.exit(1)
    end
    
    -- 扫描硬件适配器
    local success, err = pcall(database.scanAdaptor)
    if not success then
        print(string.format("硬件扫描失败: %s", err))
        os.exit(1)
    end
    
    print("系统初始化完成")
    print(string.format("发现 %d 个反应堆配置", #database.reactorChambers))
end

-- 主程序入口
local function main()
    -- 系统初始化
    systemInit()
    
    -- 确保所有反应堆处于关闭状态
    action.stopAllReactorChamber(false)
    
    -- 启动用户界面
    justStart()
end

-- 启动主程序
main()
