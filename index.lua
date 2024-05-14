local computer = require('computer')
local component = require('component')
local JSON = (loadfile "JSON.lua")()
local itemConfig = io.open("config.json", "r")
local redstone1 = component.proxy("97d5e1c1-a895-42db-8ac2-08cd26c246d0") -- 1号红石io为控制反应堆
local redstone2 = component.proxy("292c254c-d4c6-4372-81c8-0c4b86d6a989") -- 2号红石io为控制全局开关
local transposer = component.transposer
local reactor_chamber = component.reactor_chamber
-- 北:2
-- x东:5
-- 西:4
-- z南:3
local sourceBoxSide = 2      -- 输入箱子
local reactorChamberSide = 3 -- 核电仓
local outPutBoxSide = 4      -- 输出箱子e
local outPutDrawerSide = 0   -- 输出抽屉
local runTime = 0            -- 正常运行时间
local controlside = 2        --控制红石接收器方向

-- 检查原材料箱中原材料数量
local function checkSourceBoxItems(itemName, itemCount)
    local itemSum = 0
    local sourceBoxitemList = transposer.getAllStacks(sourceBoxSide).getAll()

    for index, item in pairs(sourceBoxitemList) do
        if item.name then
            if item.name == itemName then
                itemSum = itemSum + item.size
            end
        end
    end

    if itemSum >= itemCount then
        return true
    else
        return false
    end
end

-- 选择配置文件中的项目
local function configSelect()
    print("Please enter config project:")
    local project = io.read()

    if itemConfig then
        local ItemConfig_table = JSON:decode(itemConfig:read("*a"))

        if (ItemConfig_table[project]) then
            itemConfig:close()
            return ItemConfig_table[project]
        else
            print("The project name you entered could not be found.")
            itemConfig:close()
            os.exit(0)
        end
    else
        print("config.json not found.")
        os.exit(0)
    end
end

-- 停止核电仓
local function stop()
    redstone1.setOutput(reactorChamberSide, 0)
end

--启动核电仓
local function start()
    redstone1.setOutput(reactorChamberSide, 1)
end


-- 向核电仓中转移原材料
local function insertItemsIntoReactorChamber(project)
    local sourceBoxitemList = transposer.getAllStacks(sourceBoxSide).getAll()
    local reactorChamber = transposer.getAllStacks(reactorChamberSide)
    local reactorChamberLenth = reactorChamber.count()
    local projectLenth = #project.resource

    for i = 1, projectLenth do
        for indexJ, j in pairs(project.resource[i].slot) do
            for index, item in pairs(sourceBoxitemList) do
                if item.name == project.resource.name then
                    transposer.transferItem(sourceBoxSide, reactorChamberSide, 1, index + 1, j)
                end
            end
        end
    end
end

-- 核电仓物品移入输入箱
local function removeToSourceSide(removeSlot)
    while true do
        if transposer.transferItem(reactorChamberSide, sourceBoxSide, 1, removeSlot) == 0 then
            print("输入箱子已满!")
            for i = 10, 1, -1 do
                print("在" .. i .. " 秒后再次检测输入箱")
                os.sleep(1)
            end
            os.execute("cls")
        else
            break
        end
    end
end

-- 物品移入核电仓
local function insert(sinkSlot, insertItemName)
    while true do
        local sourceBoxitemList = transposer.getAllStacks(sourceBoxSide).getAll()
        if checkSourceBoxItems(insertItemName, 1) then
            for index, item in pairs(sourceBoxitemList) do
                if item.name == insertItemName then
                    transposer.transferItem(sourceBoxSide, reactorChamberSide, 1, index + 1, sinkSlot)
                    break
                end
            end
            break
        else
            print(insertItemName .. "-------没有找到该物品")
            for i = 10, 1, -1 do
                print("在 " .. i .. " 秒后再次检测输入仓")
                os.sleep(1)
            end
            os.execute("cls")
        end
    end
end

-- 反应堆降温
local function heatDissipation(project)
    local reactorChamber = transposer.getAllStacks(reactorChamberSide)
    local reactorChambeerList = reactorChamber.getAll();
    -- 获取核电仓中是否有空位或替换一个冷却单元下来
    local targetIndex = -1
    for index, item in pairs(reactorChambeerList) do
        if item.name == nil then
            targetIndex = index + 1
            break;
        elseif item.name == project.insurance.changeName then
            removeToSourceSide(index + 1)
            targetIndex = index + 1
            break;
        end
    end

    if targetIndex == -1 then
        print("未在核电仓中找到空位或可替换的冷却单元")
    end

    insert(targetIndex, project.insurance.name)
    while reactor_chamber.getHeat() ~= 0 do
        print("反应堆冷却中, 温度:" .. reactor_chamber.getHeat())
        os.sleep(5)
    end
end

-- 核电仓热量检测
local function checkReactorChamberHeat(project)
    x = redstone2.getInput(controlside);
    if x > 0 then
        if (reactor_chamber.getHeat() >= 100) then
            os.execute("cls")
            print("反应堆温度为:" .. reactor_chamber.getHeat() .. " >= 100")
            stop()
            local status, retval = pcall(heatDissipation, project)
            if not status then
                print(retval)
            end
        elseif (reactor_chamber.getHeat() < 100) then
            print("反应堆温度正常")
            start()
            os.execute("cls")
        end
    else
        print("主机控制端被关闭，2秒后退出")
        os.sleep(2)
        stop()
        os.exit()
    end
end

-- 物品移除核电仓
local function remove(removeSlot, removeSide)
    while true do
        if transposer.transferItem(reactorChamberSide, removeSide, 1, removeSlot) == 0 then
            print("输出箱子已满!")
            for i = 10, 1, -1 do
                print("在" .. i .. " 秒后再次检测输出箱")
                os.sleep(1)
            end
            os.execute("cls")
        else
            break
        end
    end
end

-- 物品移除和移入核电仓
local function removeAndInsert(removeSlot, removeSide, insertItemName)
    stop()
    remove(removeSlot, removeSide)
    insert(removeSlot, insertItemName)
end

-- 物品监测（需要监测DMG和不需要监测DMG）
local function checkItemDMG(project)
    local reactorChamber = transposer.getAllStacks(reactorChamberSide)
    local reactorChamberLenth = reactorChamber.count()
    local reactorChamberList = reactorChamber.getAll()

    for i = 1, #project.resource do
        for index, slot in pairs(project.resource[i].slot) do
            if project.resource[i].dmg ~= -1 then
                if reactorChamberList[slot - 1].damage ~= nil then
                    if reactorChamberList[slot - 1].damage >= project.resource[i].dmg then
                        removeAndInsert(slot, outPutBoxSide, project.resource[i].name)
                    end
                else
                    stop()
                    insert(slot, project.resource[i].name)
                end
            elseif project.resource[i].dmg == -1 then
                if reactorChamberList[slot - 1].name ~= nil then
                    if reactorChamberList[slot - 1].name ~= project.resource[i].name and
                        reactorChamberList[slot - 1].name == project.resource[i].changeName then
                        removeAndInsert(slot, outPutDrawerSide, project.resource[i].name)
                    end
                else
                    stop()
                    insert(slot, project.resource[i].name)
                end
            end
        end
    end
end

-- 核电仓运行时
local function reactorChamberRunTime(project)
    os.execute("cls")
    x = redstone2.getInput(controlside);
    print("反应堆正常运行!")
    while true do
        if x > 0 then
            checkItemDMG(project)
            checkReactorChamberHeat(project)
        else
            print("主机控制端未启动! 2秒后退出")
            os.sleep(2)
            os.exit()
        end
    end
end

-- 从配置文件启动
local function startWithConfig()
    local project = configSelect()
    local projectLenth = #project.resource
    local whileFlag = true
    local isOK = 0

    while whileFlag do
        x = redstone2.getInput(controlside);
        if x > 0 then
            isOK = 0
            -- 判断并输出原材料箱中原材料是否满足
            for i = 1, projectLenth do
                if checkSourceBoxItems(project.resource[i].name, project.resource[i].count) then
                    print(project.resource[i].name .. "-------is ok")
                    isOK = isOK + 1
                else
                    print(project.resource[i].name .. "-------没有这样的项目")
                end
            end

            if isOK == projectLenth then
                whileFlag = false
                -- 向核电仓中转移原材料
                local status, retval = pcall(insertItemsIntoReactorChamber, project)
                -- 启动强冷核电
                if status then
                    reactorChamberRunTime(project)
                else
                    print(retval)
                end
            else
                for i = 10, 1, -1 do
                    print("在 " .. i .. " 秒后再次检测核电仓原材料是否填充")
                    os.sleep(1)
                end
                os.execute("cls")
            end
        else
            print("主机控制端未启动，5秒后退出")
            os.sleep(5)
            os.exit()
        end
    end
end

-- 直接启动
local function justStart()
    local project = configSelect()
    reactorChamberRunTime(project)
end

local function startSelect()
    stop()
    print("请输入(0)选择配置文件启动 (1)直接启动:")
    while true do
        local select = io.read()
        if select == "0" then
            startWithConfig()
            break
        elseif select == "1" then
            justStart()
            break
        elseif select == "-1" then
            os.exit(0)
        else
            print("Please enter [0]:start with config or [1]:just start:")
        end
    end
end

startSelect()
