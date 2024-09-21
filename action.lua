local component = require("component")
local database = require("database")
local config = require("config")
local coroutine = require("coroutine")

local function checkItemCount(runningTable)
    for i = 1, #runningTable, 1 do
        local rc = database.reactorChambers[runningTable[i]]
        local inputBox = component.proxy(rc.transforAddr).getAllStacks(rc.inputSide).getAll()
        local resource = config.scheme[rc.scheme].resource
        for j = 1, #resource, 1 do
            local num = 0
            for index, item in pairs(inputBox) do
                if item.name and item.name == resource[j].name then
                    num = num + item.size
                end
                if num >= resource[j].count then break end
            end
            if num < resource[j].count then
                print(rc.name .. "所需的材料:" .. resource[j].name .. "小于" .. resource[j].count)
                os.exit(0)
            end
        end
    end
end

local function stopReactorChamberByRc(rc, isBlock)
    local redstone = component.proxy(rc.switchRedstone)
    if redstone.getOutput(rc.reactorChamberSideToRS) == 0 then
        return
    end
    rc.running = false
    -- setOutput为非直接调用，其正确输出对应的红石信号需要至少1tick时间
    redstone.setOutput(rc.reactorChamberSideToRS, 0)
    if isBlock then
        -- 确保反应堆先停机再继续运行
        repeat
            coroutine.yield()
            local singal = redstone.getOutput(rc.reactorChamberSideToRS)
        until (singal == 0)
    end
    print(rc.name .. " is shutdown")
end

local function stopAllReactorChamber(isBlock)
    for i = 1, #database.reactorChambers, 1 do
        stopReactorChamberByRc(database.reactorChambers[i], isBlock)
    end
end

local function remove(transforAddr, sourceSide, slot, outpuSide)
    local transposer = component.proxy(transforAddr)
    repeat
        local removeCount = transposer.transferItem(sourceSide, outpuSide, 1, slot)
        if removeCount == 0 then
            print("箱子已满,无法输出物品")
        end
        coroutine.yield()
    until (removeCount > 0)
end

local function insert(transforAddr, sourceSide, targetSlot, outputSide, name, dmg)
    local transposer = component.proxy(transforAddr)
    while true do
        local sourceBox = transposer.getAllStacks(sourceSide).getAll()
        for index, item in pairs(sourceBox) do
            if item.name == name and (dmg == -1 or item.damage < dmg) then
                local insertCount = transposer.transferItem(sourceSide, outputSide, 1, index + 1, targetSlot)
                if insertCount > 0 then
                    return
                end
            end
        end
        sourceBox = nil
        print("材料箱未找到物品:" .. name)
        coroutine.yield()
    end
end

local function startReactorChamber(rc)
    local rcRedstone = component.proxy(rc.switchRedstone)
    if rcRedstone.getOutput(rc.reactorChamberSideToRS) > 0 then
        return
    end
    if rc.aborted then
        print(string.format("%s was over-heated, it cannot start. You can manually cooldown it and then restart the program.", rc.name))
        return
        -- local heat = rcComponent.getHeat()
        -- if heat > rc.thresholdHeat then
        --     print(string.format("%s is over-heated, it cannot start. You can cooldown it ant it could restart later.", rc.name))
        --     return
        -- else 
        --     rc.aborted = false
        --     print(string.format("%s is recovering from over-heated, it is restarting.", rc.name))
        -- end
    end
    rc.running = true
    rcRedstone.setOutput(rc.reactorChamberSideToRS, 15)

    repeat
        coroutine.yield()
        local singal = rcRedstone.getOutput(rc.reactorChamberSideToRS)
    until (singal > 0)

    print(rc.reactorChamberAddr .. " is running")
end

local function preheatRc(rc)
    local rcComponent = component.proxy(rc.reactorChamberAddr)
    if rcComponent.getHeat() >= rc.thresholdHeat then return true end
    insert(rc.transforAddr, rc.tempSide, 1, rc.reactorChamberSide, rc.preheatItem, -1)
    startReactorChamber(rc)
    repeat
        local heat = rcComponent.getHeat()
        if not database.getGlobalRedstone() then
            break
        end
    until (heat >= rc.thresholdHeat)
    stopReactorChamberByRc(rc, true)
    remove(rc.transforAddr, rc.reactorChamberSide, 1, rc.tempSide)
end

-- 向核电仓中转移原材料
local function insertItemsIntoReactorChamber(runningTable)
    checkItemCount(runningTable)
    for k = 1, #runningTable, 1 do -- 原先这里是for i = 1, #runningTable, 1 do，内促内循环还有一个循环变量i，容易出问题
        local rc = database.reactorChambers[runningTable[k]]
        local transposer = component.proxy(rc.transforAddr)
        local sourceBoxitemList = transposer.getAllStacks(rc.inputSide).getAll()
        local resource = config.scheme[rc.scheme].resource

        if rc.thresholdHeat ~= -1 then
            preheatRc(rc)
            print(rc.name .. " 预热完成")
        end

        for i = 1, #resource do
            local nowIndex = 0
            -- pairs性能比#table性能差，由于此处需要多层循环遍历,故使用numeric for
            for j = 1, #resource[i].slot, 1 do
                while nowIndex < #sourceBoxitemList do
                    local item = sourceBoxitemList[nowIndex]
                    if item.name == resource[i].name then
                        transposer.transferItem(rc.inputSide, rc.reactorChamberSide, 1, nowIndex + 1, resource[i].slot
                            [j])
                        if transposer.getSlotStackSize(rc.inputSide, nowIndex + 1) == 0 then
                            nowIndex = nowIndex + 1
                        end
                        break
                    end
                    nowIndex = nowIndex + 1
                end
            end
        end
        print(string.format("完成了对核反应堆 %s 的初次材料转移", rc.name))
    end
end

---移出{transforAddr}在{rcSide}方向上的第{targetSlot}的物品到{outputSide}容器中,并将耐久阈值小于{dmg}的{itemName}放入{targetSlot}
---@param transforAddr string
---@param sourceSide integer
---@param targetSlot integer
---@param outputSide integer
---@param itemName string
---@param dmg integer
local function removeAndInsert(transforAddr, rcSide, sourceSide, targetSlot, outputSide, itemName, dmg)
    remove(transforAddr, rcSide, targetSlot, outputSide)
    insert(transforAddr, sourceSide, targetSlot, rcSide, itemName, dmg)
end

local function checkItemChangeName(cfgResource, rc)
    local transposer = component.proxy(rc.transforAddr)
    local rcBox = transposer.getAllStacks(rc.reactorChamberSide).getAll()
    for i = 1, #cfgResource.slot, 1 do
        local boxSlot = cfgResource.slot[i]
        -- 名称已变化
        if rcBox[boxSlot - 1].name ~= cfgResource.name
            and rcBox[boxSlot - 1].name == cfgResource.changeName then
            stopReactorChamberByRc(rc, true)
            removeAndInsert(rc.transforAddr,
                rc.reactorChamberSide,
                rc.inputSide,
                boxSlot,
                rc.changeItemOutputSide,
                cfgResource.name, -1)
            goto continue
        end
        -- 是否为空位
        if rcBox[boxSlot - 1].name == nil then
            stopReactorChamberByRc(rc, true)
            insert(rc.transforAddr, rc.inputSide, boxSlot, rc.reactorChamberSide, cfgResource.name, -1)
        end
        ::continue::

        -- if i % 9 == 0 then
        --     coroutine.yield()
        -- end
    end
end

local function checkItemDmg(cfgResource, rc)
    local transposer = component.proxy(rc.transforAddr)
    local rcBox = transposer.getAllStacks(rc.reactorChamberSide).getAll()
    for i = 1, #cfgResource.slot, 1 do
        local boxSlot = cfgResource.slot[i]
        -- 耐久是否达到阈值
        if rcBox[boxSlot - 1].damage ~= nil then
            if rcBox[boxSlot - 1].damage >= cfgResource.dmg then
                stopReactorChamberByRc(rc, true)
                removeAndInsert(rc.transforAddr, rc.reactorChamberSide, rc.inputSide, boxSlot, rc.outputSide,
                    cfgResource.name, cfgResource.dmg)
                goto continue
            end
        end
        -- 是否为空位
        if rcBox[boxSlot - 1].damage == nil then
            stopReactorChamberByRc(rc, true)
            insert(rc.transforAddr, rc.inputSide, boxSlot, rc.reactorChamberSide, cfgResource.name, -1)
        end
        ::continue::

        -- if i % 9 == 0 then
        --     coroutine.yield()
        -- end
    end
end

local function checkReactorChamberDMG(rc, scheme)
    for i = 1, #scheme.resource do
        -- 检测耐久
        if scheme.resource[i].dmg ~= -1 then
            checkItemDmg(scheme.resource[i], rc)
            goto continue
        end
        -- 检测替换物
        if scheme.resource[i].changeName ~= -1 then
            checkItemChangeName(scheme.resource[i], rc)
        end

        ::continue::
    end
end

return {
    checkItemCount = checkItemCount,
    insertItemsIntoReactorChamber = insertItemsIntoReactorChamber,
    stopAllReactorChamber = stopAllReactorChamber,
    checkReactorChamberDMG = checkReactorChamberDMG,
    startReactorChamber = startReactorChamber,
    stopReactorChamberByRc = stopReactorChamberByRc,
    preheatRc = preheatRc
}
