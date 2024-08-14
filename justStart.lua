local database = require("database")
local action = require("action")
local thread = require("thread")
local detection = require("coolantcellThread")
local config = require("config")

-- 清理控制台打印信息，防止内存溢出
local function clearCommandInterval()
    while (true) do
        for i = 1, config.cleatLogInterval, 1 do
            if not database.getGlobalRedstone() then
                goto stopClear
            end
            os.sleep(1)
        end
        os.execute("cls")
    end
    ::stopClear::
end

local function shutdownThread(threads)
    while true do
        if not database.getGlobalRedstone() then
            break;
        end
        os.sleep(0.1)
    end
    for i = 1, #threads, 1 do
        threads[i]:kill()
        if i <= #threads - 1 then
            action.stopReactorChamberByRc(database.reactorChambers[i], true)
        end
    end
end

local function reactorChamberStart(rcTable)
    os.execute("cls")
    local threads = {}

    for i = 1, #rcTable do
        threads[i] = thread.create(detection.runningReactorChamber, database.reactorChambers[rcTable[i]])
    end
    threads[#threads + 1] = thread.create(clearCommandInterval)
    threads[#threads + 1] = thread.create(shutdownThread, threads)
    thread.waitForAll(threads)
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

    if model == "1" then
        action.insertItemsIntoReactorChamber(runningTable)
    end
    reactorChamberStart(runningTable)
end

local function init()
    if not database.getGlobalRedstone then
        print("未开启全局开关")
        action.stopAllReactorChamber(false)
        os.exit(0)
    end
    database.scanAdator()
end

init()
action.stopAllReactorChamber(false)
justStart()
