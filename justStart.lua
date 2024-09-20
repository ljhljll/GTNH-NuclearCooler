local database = require("database")
local action = require("action")
local thread = require("thread")
local detection = require("coolantcellThread")
local config = require("config")
local coroutine = require("coroutine")

-- 清理控制台打印信息，防止内存溢出
local function clearCommandInterval()
    while (true) do
        -- for i = 1, config.cleatLogInterval, 1 do
        --     if not database.getGlobalRedstone() then
        --         goto stopClear
        --     end
        --     os.sleep(1)
        --     coroutine.yield()
        -- end
        for i = 1, (config.cleatLogInterval * 10) do 
            coroutine.yield()
        end
        os.execute("cls")
        print(string.format("下一次清屏计划在 %d 秒后", config.cleatLogInterval))
    end
    ::stopClear::
end

-- local function shutdownThread(threads)
--     while true do
--         if not database.getGlobalRedstone() then
--             break;
--         end
--         os.sleep(0.1)
--     end
--     for i = 1, #threads, 1 do
--         threads[i]:kill()
--         if i <= #threads - 1 then
--             action.stopReactorChamberByRc(database.reactorChambers[i], true)
--         end
--     end
-- end

local function reactorChamberStart(rcTable)
    os.execute("cls")
   -- local threads = {}
    local coroutines = {}

    for i = 1, #rcTable do
        coroutines[i] = coroutine.create(function()
            detection.runningReactorChamber(database.reactorChambers[rcTable[i]])
        end)
    end
    coroutines[#coroutines + 1] = coroutine.create(clearCommandInterval)
    -- coroutines[#threads + 1] = thread.create(shutdownThread, threads) 
    -- thread.waitForAll(threads)
    while true do 
        for i = 1, #coroutines do 
            -- coroutine.resume(coroutines[i])
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
        os.sleep(0.1) -- 协程内部不sleep，这里统一Sleep，控制到10tps
    end
    -- 所有关闭反应堆
    stop_coroutines = {}
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
