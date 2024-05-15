local database = require("database")
local event = require("event")
local config = require("config")
local action = require("action")
local thread = require("thread")
local detection = require("coolantcellThread")

local function configSelect()
    print("请输入要启用的模式:")
    local scheme = io.read()
    if config.scheme[scheme] then
        return config.scheme[scheme]
    end
    print("配置文件中未找到该模式")
    os.exit(0)
end

local function reactorChamberStart(rcTable)
    os.execute("cls")
    local threads = {}

    for i = 1, #rcTable do
        threads[i] = thread.create(detection.runningReactorChamber, database.reactorChambers[rcTable[i]])
    end
    thread.waitForAll(threads)
    action.stopAllReactorChamber()
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
        action.stopAllReactorChamber()
        os.exit(0)
    end
    database.scanAdator()
end

init()
action.stopAllReactorChamber()
justStart()
