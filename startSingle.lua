local database = require("database")
local scanner = require("scanner")
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
        print(#database.reactorChambers)
        print("当前方向" .. rc.side)
        print(rc.running)
        if not rc.running then
            goto continue
        end
        threads[index] = thread.create(detection.runningReactorChamber, rc, scheme)
        ::continue::
    end
    thread.waitForAll(threads)
    action.stopAllReactorChamber()
    print("核反应堆已关闭")
end
local function startWithConfig()
    local scheme = configSelect()
    print("请输入启动几连核电:")
    local chamberNumber = tonumber(io.read())
    local flag = database.setOpenNum(chamberNumber)

    if not flag then
        print("启动核电个数错误")
        os.exit(0)
    end

    local isEnough = scanner.scanSchame(scheme)
    if not isEnough then
        os.exit(0)
    end

    local runningNumber = 0
    for index, rc in pairs(database.reactorChambers) do
        if runningNumber == chamberNumber then
            break
        end
        action.insertItemsIntoReactorChamber(scheme, rc)
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

local function startSelect()
    init()
    action.stopAllReactorChamber()
    print("请输入(0)选择配置文件启动 (1)直接启动:")
    while true do
        local select = io.read()
        if select == "0" then
            startWithConfig()
            break
        elseif select == "1" then
            break
        elseif select == "-1" then
            os.exit(0)
        else
            print("Please enter [0]:start with config or [1]:just start:")
        end
    end
end


startSelect()
