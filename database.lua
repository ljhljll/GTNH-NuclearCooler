local component = require("component")
local config = require("config")
local globalRedstoneSide = nil
local reactorChambers = {}

local function getGlobalRedstoneSide()
    return globalRedstoneSide
end

local function getGlobalRedstone()
    local global = component.proxy(config.globalRedstone)
    if getGlobalRedstoneSide() ~= nil then
        return global.getInput(getGlobalRedstoneSide()) > 0
    end
    local signal = global.getInput()
    for side, num in pairs(signal) do
        if num > 0 then
            globalRedstoneSide = side
            return true
        end
    end
    return false
end

local function scanDrawer(rc)
    local drawer = component.proxy(rc.drawerAddress)
    local drawerSlotSize = drawer.getDrawerCount()
    local scheme = config.scheme[rc.scheme]
    local result = {}
    for i = 1, #scheme.resource, 1 do
        local slots = {}
        for j = 1, drawerSlotSize, 1 do
            if drawer.getItemName(j) == scheme.resource[i].name then
                table.insert(slots, j)
            end
        end
        result[scheme.resource[i].name] = slots
    end

    -- 针对散热组件做的兼容(现在的代码已经严格控制红石信号，可以说用不上散热,但以防万一呢)
    for i = 1, drawerSlotSize, 1 do
        if drawer.getItemName(i) == scheme.insurance.name then
            result[scheme.insurance.name] = { i }
            break
        end
    end
    return result
end


local function scanAdator()
    local reactorChamberList = config.reactorChamberList
    print("读取到" .. #reactorChamberList .. "个核电配置")
    for i = 1, #reactorChamberList, 1 do
        reactorChambers[i] = reactorChamberList[i]
        reactorChambers[i].running = false
        reactorChambers[i].drawer = scanDrawer(reactorChamberList[i])
        print("配置" .. i .. "使用模式:" .. reactorChambers[i].scheme .. "预热堆温:" .. reactorChambers[i].thresholdHeat)
    end
end

return {
    scanAdator = scanAdator,
    reactorChambers = reactorChambers,
    getGlobalRedstone = getGlobalRedstone
}
