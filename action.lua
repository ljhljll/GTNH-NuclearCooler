local component = require("component")
local transposer = component.transposer
local sides = require("sides")
local database = require("database")
local config = require("config")

local function checkItemCount(itemName, count)
    local num = 0
    local itemList = transposer.getAllStacks(sides.front).getAll()
    for index, item in pairs(itemList) do
        if item.name and item.name == itemName then
            num = num + item.size
        end

        if num >= count then return true end
    end
    return false
end

-- 向核电仓中转移原材料
local function insertItemsIntoReactorChamber(scheme, rc)
    local sourceBoxitemList = transposer.getAllStacks(sides.front).getAll()

    for i = 1, #scheme.resource do
        local nowIndex = 0
        -- pairs性能比#table性能差，由于此处需要循环遍历,故使用#
        for j = 1, #scheme.resource[i].slot, 1 do
            while nowIndex < #sourceBoxitemList do
                local item = sourceBoxitemList[nowIndex]
                if item.name == scheme.resource[i].name then
                    transposer.transferItem(sides.front, rc.side, 1, nowIndex + 1, scheme.resource[i].slot[j])
                    if transposer.getSlotStackSize(sides.front, nowIndex + 1) == 0 then
                        nowIndex = nowIndex + 1
                    end
                    break
                end
                nowIndex = nowIndex + 1
            end
        end
    end
end

local function stopReactorChamberByRc(rc)
    rc.running = false
    database.getControlRedstone().setOutput(rc.side, 0)
end

local function stopReactorChamberBySides(side)
    database.getControlRedstone().setOutput(side, 0)
end

local function stopAllReactorChamber()
    for i = 1, #database.reactorChambers, 1 do
        stopReactorChamberByRc(database.reactorChambers[i])
    end
end

local function remove(side, slot)
    repeat
        local removeCount = transposer.transferItem(side, sides.front, 1, slot)
        if removeCount == 0 then
            print("箱子已满,无法输出物品")
            os.sleep(1)
        end
    until (removeCount > 0)
end

local function insert(side, slot, name, dmg)
    while true do
        local sourceBox = transposer.getAllStacks(sides.front).getAll()
        for index, item in pairs(sourceBox) do
            if item.name == name and (dmg == nil or item.damage < dmg) then
                local insertCount = transposer.transferItem(sides.front, side, 1, index + 1, slot)
                if insertCount > 0 then
                    return
                end
            end
        end
        print("材料箱未找到物品:" .. name)
        os.sleep(1)
    end
end

local function removeAndInsert(rcSide, targetSlot, itemName, dmg)
    remove(rcSide, targetSlot)
    insert(rcSide, targetSlot, itemName, dmg)
end

local function checkItemChangeName(rcBox, cfgResource, rc)
    for i = 1, #cfgResource.slot, 1 do
        local boxSlot = cfgResource.slot[i]
        -- 名称已变化
        if rcBox[boxSlot - 1].name ~= cfgResource.name
            and rcBox[boxSlot - 1].name == cfgResource.changeName then
            stopReactorChamberByRc(rc)
            removeAndInsert(rc.side, boxSlot, cfgResource.name)
            goto continue
        end
        -- 是否为空位
        if rcBox[boxSlot - 1].name == nil then
            stopReactorChamberByRc(rc)
            insert(rc.side, boxSlot, cfgResource.name)
        end
        ::continue::
    end
end

local function checkItemDmg(rcBox, cfgResource, rc)
    for i = 1, #cfgResource.slot, 1 do
        local boxSlot = cfgResource.slot[i]
        -- 耐久是否达到阈值
        if rcBox[boxSlot - 1].damage ~= nil then
            if rcBox[boxSlot - 1].damage >= cfgResource.dmg then
                stopReactorChamberByRc(rc)
                removeAndInsert(rc.side, boxSlot, cfgResource.name, cfgResource.dmg)
                goto continue
            end
        end
        -- 是否为空位
        if rcBox[boxSlot - 1].damage == nil then
            stopReactorChamberByRc(rc)
            insert(rc.side, boxSlot, cfgResource.name)
        end
        ::continue::
    end
end

local function checkReactorChamberDMG(rc, scheme)
    local rcBox = transposer.getAllStacks(rc.side).getAll()
    for i = 1, #scheme.resource do
        -- 检测耐久
        if scheme.resource[i].dmg ~= -1 then
            checkItemDmg(rcBox, scheme.resource[i], rc)
            goto continue
        end
        -- 检测替换物
        if scheme.resource[i].changeName ~= -1 then
            checkItemChangeName(rcBox, scheme.resource[i], rc)
        end

        ::continue::
    end
end

local function doHeatDissipation(side, rcAddress, scheme)
    while true do
        local rcBox = transposer.getAllStacks(side).getAll()
        local targetInex = -1
        for index, item in pairs(rcBox) do
            if item.name == nil then
                targetInex = index + 1
                break;
            end

            if item.name == scheme.insurance.changeName and item.damage <= scheme.insurance.dmg then
                targetInex = index + 1
                remove(side, targetInex)
                break;
            end
        end

        if targetInex == -1 then
            goto continue
        end

        insert(side, targetInex, scheme.insurance.name)
        repeat
            local heat = component.proxy(rcAddress).getHeat()
            print("堆散热中:" .. rcAddress .. ",方向:" .. side .. "Heat =" .. heat)
            os.sleep(1)
        until (heat == 0)

        removeAndInsert(side, targetInex, scheme.insurance.changeName)
        do return end
        ::continue::
        print("[散热]未找到空位或可替换的组件:" .. scheme.insurance.changeName)
        os.sleep(1)
    end
end

local function checkReactorChamberHeat(rc, scheme)
    local heat = component.proxy(rc.address).getHeat()
    if heat >= config.dangerHeat then
        stopReactorChamberByRc(rc)
        print("堆:" .. rc.address .. ",方向:" .. rc.side .. "Heat >=" .. config.dangerHeat)
        doHeatDissipation(rc.side, rc.address, scheme)
    end
end
local function startReactorChamber(rc)
    rc.running = true
    database.getControlRedstone().setOutput(rc.side, 15)
end
return {
    checkItemCount = checkItemCount,
    insertItemsIntoReactorChamber = insertItemsIntoReactorChamber,
    stopAllReactorChamber = stopAllReactorChamber,
    stopReactorChamberBySides = stopReactorChamberBySides,
    checkReactorChamberDMG = checkReactorChamberDMG,
    checkReactorChamberHeat = checkReactorChamberHeat,
    startReactorChamber = startReactorChamber,
    stopReactorChamberByRc = stopReactorChamberByRc
}
