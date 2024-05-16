local component = require("component")
local database = require("database")
local config = require("config")

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
                print(rc.reactorChamberAddr .. "所需的材料:" .. resource[j].name .. "小于" .. resource[j].count)
                os.exit(0)
            end
        end
    end
end

local function stopReactorChamberByRc(rc)
    local redstone = component.proxy(rc.switchRedstone)
    rc.running = false
    redstone.setOutput(rc.reactorChamberSide, 0)
    -- 确保反应堆先停机再继续运行
    repeat
        local singal = redstone.getOutput(rc.reactorChamberSide)
    until (singal == 0)
end

local function stopAllReactorChamber()
    for i = 1, #database.reactorChambers, 1 do
        stopReactorChamberByRc(database.reactorChambers[i])
    end
end

local function remove(transforAddr, sourceSide, slot, outpuSide)
    local transposer = component.proxy(transforAddr)
    repeat
        local removeCount = transposer.transferItem(sourceSide, outpuSide, 1, slot)
        if removeCount == 0 then
            print("箱子已满,无法输出物品")
            os.sleep(1)
        end
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
        print("材料箱未找到物品:" .. name)
        os.sleep(1)
    end
end

-- 向核电仓中转移原材料
local function insertItemsIntoReactorChamber(runningTable)
    checkItemCount(runningTable)
    for i = 1, #runningTable, 1 do
        local rc = database.reactorChambers[runningTable[i]]
        local transposer = component.proxy(rc.transforAddr)
        local sourceBoxitemList = transposer.getAllStacks(rc.inputSide).getAll()
        local resource = config.scheme[rc.scheme].resource

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
            stopReactorChamberByRc(rc)
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
            stopReactorChamberByRc(rc)
            insert(rc.transforAddr, rc.inputSide, boxSlot, rc.reactorChamberSide, cfgResource.name, -1)
        end
        ::continue::
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
                stopReactorChamberByRc(rc)
                removeAndInsert(rc.transforAddr, rc.reactorChamberSide, rc.inputSide, boxSlot, rc.outputSide,
                    cfgResource.name, cfgResource.dmg)
                goto continue
            end
        end
        -- 是否为空位
        if rcBox[boxSlot - 1].damage == nil then
            stopReactorChamberByRc(rc)
            insert(rc.transforAddr, rc.inputSide, boxSlot, rc.reactorChamberSide, cfgResource.name, -1)
        end
        ::continue::
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

local function doHeatDissipation(rc, scheme)
    local transposer = component.proxy(rc.transforAddr)
    local rcComponent = component.proxy(rc.reactorChamberAddr)
    while true do
        local rcBox = transposer.getAllStacks(rc.reactorChamberSide).getAll()
        local targetInex = -1
        for index, item in pairs(rcBox) do
            if item.name == nil then
                targetInex = index + 1
                break;
            end

            if item.name == scheme.insurance.changeName and item.damage <= scheme.insurance.dmg then
                targetInex = index + 1
                -- 将可用于替换的组件放入临时箱,为散热组件空出位置
                remove(rc.transforAddr, rc.reactorChamberSide, targetInex, rc.tempSide)
                break;
            end
        end

        if targetInex == -1 then
            goto continue
        end
        -- 放入符合指定耐久的散热组件
        insert(rc.transforAddr, rc.tempSide, targetInex, rc.reactorChamberSide, scheme.insurance.name,
            scheme.insurance.dmg)
        repeat
            local heat = rcComponent.getHeat()
            print("堆散热中:" .. rc.reactorChamberAddr .. ",方向:" .. rc.reactorChamberSide .. "Heat =" .. heat)
            os.sleep(1)
        until (heat == 0)
        -- 将临时箱中的替换组件放回去
        removeAndInsert(rc.transforAddr, rc.reactorChamberSide, rc.tempSide, targetInex, rc.tempSide,
            scheme.insurance.changeName, -1)
        do return end
        ::continue::
        print("[散热]未找到空位或可替换的组件:" .. scheme.insurance.changeName)
        os.sleep(1)
    end
end

local function checkReactorChamberHeat(rc, scheme)
    local heat = component.proxy(rc.reactorChamberAddr).getHeat()
    if heat >= config.dangerHeat then
        stopReactorChamberByRc(rc)
        print("堆:" .. rc.reactorChamberAddr .. ",方向:" .. rc.reactorChamberSide .. "Heat >=" .. config.dangerHeat)
        doHeatDissipation(rc, scheme)
    end
end

local function startReactorChamber(rc)
    rc.running = true
    local rcRedstone = component.proxy(rc.switchRedstone)
    rcRedstone.setOutput(rc.reactorChamberSide, 15)
end

return {
    checkItemCount = checkItemCount,
    insertItemsIntoReactorChamber = insertItemsIntoReactorChamber,
    stopAllReactorChamber = stopAllReactorChamber,
    checkReactorChamberDMG = checkReactorChamberDMG,
    checkReactorChamberHeat = checkReactorChamberHeat,
    startReactorChamber = startReactorChamber,
    stopReactorChamberByRc = stopReactorChamberByRc
}
