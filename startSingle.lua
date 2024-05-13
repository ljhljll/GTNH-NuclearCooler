local component = require("component")
local database = require("database")
local scanner = require("scanner")
local config = require("config")
local action = require("action")
local sides = require("sides")

local threads = {}

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

    while true do
        if not database.getGlobalRedstone then
            print("全局开关未开启,反应堆停止")
            action.stopAllReactorChamber()
            os.exit()
        end
        os.sleep(1)
        -- action.checkReactorChamberDMG(scheme)
    end
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
    for _, rc in pairs(database.reactorChambers) do
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
        os.exit(0)
    end
    database.scanAdator()
end

local function startSelect()
    init()
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
