local component = require("component")
local transposer = component.transposer
local sides = require("sides")
local database = require("database")
local config = require("config")

local function checkItemCount(itemName, count)
    local num = 0
    local itemList = transposer.getAllStacks(sides.back).getAll()
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
    local sourceBoxitemList = transposer.getAllStacks(sides.back).getAll()

    for i = 1, #scheme.resource do
        local nowIndex = 0
        -- pairs性能比#table性能差，由于此处需要循环遍历,故使用#
        for j = 1, #scheme.resource[i].slot, 1 do
            while nowIndex < #sourceBoxitemList do
                local item = sourceBoxitemList[nowIndex]
                if item.name == scheme.resource[i].name then
                    transposer.transferItem(sides.back, rc.side, 1, nowIndex + 1, scheme.resource[i].slot[j])
                    if transposer.getSlotStackSize(sides.back, nowIndex + 1) == 0 then
                        nowIndex = nowIndex + 1
                    end
                    break
                end
                nowIndex = nowIndex + 1
            end
        end
    end
end

local function stopReactorChamberBySides(rc)
    rc.running = false
    database.getControlRedstone().setOutput(rc.side, 0)
end

local function stopAllReactorChamber()
    for i = 1, #database.reactorChambers, 1 do
        stopReactorChamberBySides(database.reactorChambers[i])
    end
end

local function remove(side, slot)
    repeat
        local removeCount = transposer.transferItem(side, side.back, 1, slot)
        if removeCount == 0 then
            print("箱子已满,无法输出物品")
            os.sleep(1)
        end
    until (removeCount > 0)
end

local function insert(side, slot, name)
    while true do
        local sourceBox = transposer.getAllStacks(sides.back).getAll()
        for i = 1, #sourceBox, 1 do
            local item = sourceBox[i]
            if item.name == name then
                local insertCount = transposer.transferItem(sides.back, side, 1, i, slot)
                if insertCount > 0 then
                    break
                end
            end
        end
        print("材料箱未找到物品:" .. name)
        os.sleep(1)
    end
end

local function removeAndInsert(rcSide, targetSlot, itemName)
    stopReactorChamberBySides(rcSide)
    remove(rcSide, targetSlot)
    insert(rcSide, targetSlot, itemName)
end

local function checkItemChangeName(rcBox, cfgResource, side)
    for i = 1, #cfgResource.slot, 1 do
        local boxSlot = cfgResource.solt[i]
        -- 名称已变化
        if rcBox[boxSlot - 1].name ~= cfgResource.name
            and rcBox[boxSlot - 1].name == cfgResource.changeName then
            removeAndInsert(side, boxSlot, cfgResource.name)
            goto continue
        end
        -- 是否为空位
        if rcBox[boxSlot - 1].name == nil then
            stopReactorChamberBySides(side)
            insert(side, boxSlot, cfgResource.name)
        end
        ::continue::
    end
end

local function checkItemDmg(rcBox, cfgResource, side)
    for i = 1, #cfgResource.slot, 1 do
        local boxSlot = cfgResource.solt[i]
        -- 耐久是否达到阈值
        if rcBox[boxSlot - 1].damage ~= nil then
            if rcBox[boxSlot - 1].damage >= cfgResource.slot[i].dmg then
                removeAndInsert(side, boxSlot, cfgResource.name)
                goto continue
            end
        end
        -- 是否为空位
        if rcBox[boxSlot - 1].damage == nil then
            stopReactorChamberBySides(side)
            insert(side, boxSlot, cfgResource.name)
        end
        ::continue::
    end
end

local function checkReactorChamberDMG(rc, scheme)
    local rcBox = transposer.getAllStacks(rc.side).getAll()
    for i = 1, #scheme.resource do
        -- 检测耐久
        if scheme.resource[i].dmg ~= -1 then
            checkItemDmg(rcBox, scheme.resource[i], rc.side)
            goto continue
        end
        -- 检测替换物
        if scheme.resource[i].changeName ~= -1 then
            checkItemChangeName(rcBox, scheme.resource[i].rc.side)
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

            if item.name == scheme.insurance.changeName then
                targetInex = index + 1
                remove(side, targetInex)
                break;
            end
        end

        if targetInex == -1 then
            goto continue
        end

        insert(targetInex, scheme.insurance.name)
        repeat
            local heat = component.proxy(rcAddress).getHeat()
            print("堆散热中:" .. rcAddress .. ",方向:" .. side .. "Heat =" .. heat)
            os.sleep(1)
        until (heat ~= 0)

        removeAndInsert(side, targetInex, scheme.insurance.changeName)

        ::continue::
    end
end

local function checkReactorChamberHeat(rc, scheme)
    local heat = component.proxy(rc.address).getHeat()
    if heat >= config.dangerHeat then
        stopReactorChamberBySides(rc.side)
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
    startReactorChamber = startReactorChamber
}
