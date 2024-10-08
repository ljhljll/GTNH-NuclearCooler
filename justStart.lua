local database = require("database")
local action = require("action")
local thread = require("thread")
local detection = require("coolantcellThread")
local config = require("config")
local coroutine = require("coroutine")
local computer = require("computer")
local component = require("component")

local function printResidentMessages()
    local time = computer.uptime()
    local diffSeconds = math.floor(time - database.startTimeStamp)
    local days = math.floor(diffSeconds / 86400)
    local hours = math.floor((diffSeconds % 86400) / 3600)
    local minutes = math.floor((diffSeconds % 3600) / 60)
    print(string.format("本核电站已安全运行 %d 天 %d 时 %d 分。道路千万条，安全第一条；核电不规范，回档两行泪。", days, hours, minutes))
end

local function printOverHeated(rcTable)
    for i = 1, #rcTable do
        local rc = database.reactorChambers[rcTable[i]]
        local rcComponent = component.proxy(rc.reactorChamberAddr)
        local heat = rcComponent.getHeat()
        if rc.aborted then
            print(string.format("The heat of %s is %d K, it is aborted due to over-heated", rc.name, heat))
        else
            print(string.format("The heat of %s is %d K", rc.name, heat))
        end
    end
end

-- 清理控制台打印信息，防止内存溢出
local function clearAndIntervalMessages(rcTable)
    cleatLogInterval = config.cleatLogInterval
    if cleatLogInterval < 5 then
        cleatLogInterval = 5
    end
    while true do
        action.coroutineSleep(cleatLogInterval)
        os.execute("cls")
        coroutine.yield()
        printResidentMessages()
        coroutine.yield()
        printOverHeated(rcTable)
        coroutine.yield()
        print(string.format("下一次清屏计划在 %d 秒后", cleatLogInterval))
    end
end

-- 温度监控器，过热强制关机避免爆炸
local function heatMonitor(rcTable)
    while true do
        for i = 1, #rcTable do
            local rc = database.reactorChambers[rcTable[i]]
            if rc.scheme == "mox" and not rc.aborted then
                local rcComponent = component.proxy(rc.reactorChamberAddr)
                local heat = rcComponent.getHeat()
                if heat >= rc.thresholdHeat + 100 or (heat >= 9960 and rc.thresholdHeat ~= 9900) then
                    rc.aborted = true
                    action.stopReactorChamberByRc(rc, false)
                end
            end
            coroutine.yield()
        end
        coroutine.yield()
        coroutine.yield() -- update: 大幅度提高检测频率
        coroutine.yield()
        -- for i = 1,10 do
        --     coroutine.yield() -- 间隔10tick再做下一轮检查
        -- end
    end
end

local function reactorChamberStart(rcTable)
    os.execute("cls")
    -- local threads = {}
    local coroutines = {}

    for i = 1, #rcTable do
        coroutines[i] = coroutine.create(function()
            detection.runningReactorChamber(database.reactorChambers[rcTable[i]])
        end)
    end
    coroutines[#coroutines + 1] = coroutine.create(function()
        clearAndIntervalMessages(rcTable)
    end)
    coroutines[#coroutines + 1] = coroutine.create(function()
        heatMonitor(rcTable)
    end)
    while true do
        for i = 1, #coroutines do
            if coroutine.status(coroutines[i]) ~= "dead" then
                local status, err = coroutine.resume(coroutines[i])
                if not status then
                    print("Error in coroutine " .. i .. ": " .. err)
                end
            end
        end
        if not database.getGlobalRedstone() then
            break;
        end
        os.sleep(0) -- 能有多快就有多快好吧
    end
    -- 所有关闭反应堆
    local stop_coroutines = {}
    for i = 1, #rcTable do
        stop_coroutines[i] = coroutine.create(function()
            action.stopReactorChamberByRc(database.reactorChambers[rcTable[i]], true)
        end)
    end

    while true do
        local stopped_count = 0
        for i = 1, #rcTable do
            local status, err = coroutine.resume(stop_coroutines[i]);
            if not status then
                stopped_count = stopped_count + 1
            end
        end
        if stopped_count == #rcTable then
            break
        end
    end

    print("核反应堆已关闭")
end

local function justStart()
    print("(0)直接启动 (1)通过配置启动 (-1)退出")
    local model = io.read()

    if model == "-1" then return end

    print("请输入启用的配置(从1开始以空格分割，顺序对应config.lua配置):")
    local choicesNum = io.read()
    local runningTable = {}
    for index in choicesNum:gmatch("%d+") do
        table.insert(runningTable, tonumber(index))
    end

    database.startTimeStamp = computer.uptime()

    if model == "1" then
        action.insertItemsIntoReactorChamber(runningTable)
    end
    reactorChamberStart(runningTable)
end

local function init()
    if not database.getGlobalRedstone() then
        print("未开启全局开关")
        action.stopAllReactorChamber(false)
        os.exit(0)
    end
    database.scanAdaptor()
end

init()
action.stopAllReactorChamber(false)
justStart()
