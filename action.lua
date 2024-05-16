local component = require("component")
local database = require("database")
local config = require("config")

local function checkItemCount(runningTable)
    for i = 1, #runningTable, 1 do
        local rc = database.reactorChambers[runningTable[i]]
        local drComponent = component.proxy(rc.drawerAddress)
        local resource = config.scheme[rc.scheme].resource

        for j = 1, #resource, 1 do
            for k = 1, #rc.drawer[resource[j].name], 1 do
                print("检查抽屉第" .. rc.drawer[resource[j].name][k] .. "格")
                print("数量为" .. drComponent.getItemCount(rc.drawer[resource[j].name][k]))
                if drComponent.getItemCount(rc.drawer[resource[j].name][k]) >= resource[j].count then
                    goto continue
                end
            end
            print(rc.reactorChamberAddr .. "所需的材料:" .. resource[j].name .. "小于" .. resource[j].count)
            os.exit(0)
            ::continue::
        end
    end
end

local function stopReactorChamberByRc(rc)
    local redstone = component.proxy(rc.switchRedstone)
    rc.running = false
    -- 红石端口的set方法并不是直接调用,所以最多需要1tick(100ms)才能真正输出信号，你可以自行修改sleep的时间
    redstone.setOutput(rc.reactorChamberSide, 0)
    -- 确保反应堆先停机再继续运行
    os.sleep(1)
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

-- 我知道这函数太多参数了而且rc对象里其实都包含,但如果物品要操作的方向并不在rc中呢?
local function insert(transforAddr, sourceSide, targetSlot, outputSide, name, rc, dmg)
    local transposer = component.proxy(transforAddr)
    local drComponent = component.proxy(rc.drawerAddress)
    local drawer = rc.drawer
    while true do
        for i = 1, #drawer[name], 1 do
            if drComponent.getItemName(drawer[name][i]) == name and drComponent.getItemCount(drawer[name][i]) > 0
                and (dmg == -1 or drComponent.getItemDamage(drawer[name][i]) < dmg)
            then
                local insertCount = transposer.transferItem(sourceSide, outputSide, 1, drawer[name][i], targetSlot)
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
        local drComponent = component.proxy(rc.drawerAddress)
        local resource = config.scheme[rc.scheme].resource

        for i = 1, #resource do
            for j = 1, #resource[i].slot, 1 do
                for k = 1, #rc.drawer[resource[i].name], 1 do
                    local slot = rc.drawer[resource[i].name][k]
                    print("输入:" ..
                        rc.inputSide .. "输出:" .. rc.reactorChamberSide .. "slot:" .. slot .. "插入到:" ..
                        resource[i].slot[j])
                    if drComponent.getItemCount(slot) > 0 then
                        transposer.transferItem(rc.inputSide, rc.reactorChamberSide, 1, slot, resource[i].slot[j])
                    end
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
local function removeAndInsert(transforAddr, rcSide, sourceSide, targetSlot, outputSide, itemName, rc, dmg)
    remove(transforAddr, rcSide, targetSlot, outputSide)
    insert(transforAddr, sourceSide, targetSlot, rcSide, itemName, rc, dmg)
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
                cfgResource.name, rc, -1)
            goto continue
        end
        -- 是否为空位
        if rcBox[boxSlot - 1].name == nil then
            stopReactorChamberByRc(rc)
            insert(rc.transforAddr, rc.inputSide, boxSlot, rc.reactorChamberSide, cfgResource.name, rc, -1)
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
                    cfgResource.name, rc, cfgResource.dmg)
                goto continue
            end
        end
        -- 是否为空位
        if rcBox[boxSlot - 1].damage == nil then
            stopReactorChamberByRc(rc)
            insert(rc.transforAddr, rc.inputSide, boxSlot, rc.reactorChamberSide, cfgResource.name, rc, -1)
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
--该方法即将被废弃
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
            scheme.insurance.changeName, rc, -1)
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
