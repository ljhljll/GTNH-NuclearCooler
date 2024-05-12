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
local function insertItemsIntoReactorChamber(scheme, adaptor)
    local sourceBoxitemList = transposer.getAllStacks(sides.back).getAll()
    -- local reactorChamber = transposer.getAllStacks(adaptor.side)

    for i = 1, #scheme.resource do
        for indexJ, j in pairs(scheme.resource[i].slot) do
            for index, item in pairs(sourceBoxitemList) do
                if item.name == scheme.resource[i].name then
                    transposer.transferItem(sides.back, adaptor.side, 1, index + 1, j)
                end
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

local function replaceChangeNameItem(box, rc, boxSlot, name, changeName)
    if box[boxSlot - 1].name == nil then
        stopReactorChamberBySides(rc.side)
        event.push("insertItem", rc, boxSlot, name)
        return true
    end
    if box[boxSlot - 1].name ~= name and box[boxSlot - 1].name == changeName then
        stopReactorChamberBySides(rc.side)
        event.push("removeAndInsert", rc, boxSlot, name)
        return true
    end
    return false
end

local function replaceLowDamageItem(box, rc, boxSlot, name, dmg)
    if box[boxSlot - 1].damage == nil then
        stopReactorChamberBySides(rc.side)
        event.push("insertItem", rc, boxSlot, name)
        return true
    end

    if box[boxSlot - 1].damage >= dmg then
        event.push("removeAndInsert", rc, boxSlot, name, 100)
        return true
    end
    return false
end

local function checkReactorChamberDMG(scheme)
    for i = 1, #scheme.resource do
        for index, rc in pairs(database.runningrReactorChamber) do
            local isStop = false
            local box = transposer.getAllStacks(rc.side).getAll();
            for _, slot in pairs(scheme.resource[i].slot) do
                -- 无需检测耐久
                if scheme.resource[i].dmg == -1 then
                    isStop = replaceChangeNameItem(box, rc, slot, scheme.resource[i].name, scheme.resource[i]
                        .changeName)

                    if isStop then
                        goto continue
                    end
                end
                -- 需检测耐久
                if scheme.resource[i].dmg ~= -1 then
                    isStop = replaceLowDamageItem(box, rc, slot, scheme.resource[i].name, scheme.resource[i].dmg)
                end
            end
            ::continue::
            database.runningrReactorChamber[rc.side] = nil
            database.waitCoolingReactorChamber[rc.side] = rc
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
