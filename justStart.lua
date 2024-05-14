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

local function reactorChamberStart(scheme)
    os.execute("cls")
    local threads = {}

    for index, rc in pairs(database.reactorChambers) do
        if not rc.running then
            goto continue
        end
        threads[index] = thread.create(detection.runningReactorChamber, rc, scheme)
        ::continue::
    end
    event.onError()
    thread.waitForAll(threads)
    action.stopAllReactorChamber()
    print("核反应堆已关闭")
end
local function justStart()
    local scheme = configSelect()
    print("请输入启动几连核电:")
    local chamberNumber = tonumber(io.read())
    local flag = database.setOpenNum(chamberNumber)

    if not flag then
        print("启动核电个数错误")
        os.exit(0)
    end

    local runningNumber = 0
    for index, rc in pairs(database.reactorChambers) do
        if runningNumber == chamberNumber then
            break
        end
        runningNumber = runningNumber + 1
        rc.running = true
    end

    reactorChamberStart(scheme)
end

local function init()
    database.scanReactorRedstone()
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
