local component = require("component")
local transposer = component.transposer
local sides = require("sides")
local database = require("database")
local event = require("evet")

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
            while nowIndex <= #sourceBoxitemList do
                local item = sourceBoxitemList[nowIndex]
                if item.name == scheme.resource[i].name then
                    transposer.transferItem(sides.back, rc.side, 1, nowIndex, scheme.resource[i].slot[j])
                    break
                end
                nowIndex = nowIndex + 1
            end
        end
    end
end

local function stopReactorChamberBySides(side)
    database.redstone.setOutput(side, 0)
end

local function stopAllReactorChamber()
    for i = 1, #database.scanSide, 1 do
        stopReactorChamberBySides(database.scanSide[i])
    end
end

local function insert(side, slot, name)
    while true do
        local sourceBox = transposer.getAllStacks(sides.back).getAll()
        for i = 1, #sourceBox, 1 do
            local item = sourceBox[i]
            if item.name == name then
                transposer.transferItem(sides.back, side, 1, i - 1, slot)
                break
            end
        end
        print(rc.address .. "材料箱未找到物品:" .. name)
        os.sleep(1)
    end
end

local function removeAndInsert(rcSide, targetSlot, itemName)
    stopReactorChamberBySides(rcSide)
    remove(rcSide, targetSlot)
    insert()
end

local function checkItemDmg(rcBox, configResource, side)
    for i = 1, #configResource.slot, 1 do
        local boxSlot = configResource.solt[i] - 1
        if rcBox[boxSlot].damage ~= nil then
            if rcBox[boxSlot].damage >= configResource.slot[i].dmg then
                removeAndInsert(side, boxSlot, configResource.name)
                goto continue
            end
        end
        ::continue::
    end
end

local function checkReactorChamberDMG(rc, scheme)
    local rcBox = transposer.getAllStacks(rc.side).getAll()
    for i = 1, #scheme.resource do
        if scheme.resource[i].dmg ~= -1 then
            checkItemDmg(rcBox, scheme.resource[i], rc.side)
        else

        end
    end
end

return {
    checkItemCount = checkItemCount,
    insertItemsIntoReactorChamber = insertItemsIntoReactorChamber,
    stopAllReactorChamber = stopAllReactorChamber,
    stopReactorChamberBySides = stopReactorChamberBySides,
    checkReactorChamberDMG = checkReactorChamberDMG
}
