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


local function scanAdator()
    local reactorChamberList = config.reactorChamberList
    print("读取到" .. #reactorChamberList .. "个核电配置")
    for i = 1, #reactorChamberList, 1 do
        reactorChambers[i] = reactorChamberList[i]
        reactorChambers[i].running = false
        if (reactorChambers[i].energy == nil) then
            reactorChambers[i].energy = true
        end
        print("配置" ..
            i ..
            "使用模式:" ..
            reactorChambers[i].scheme ..
            "预热堆温:" .. reactorChambers[i].thresholdHeat .. "电量控制:" .. tostring(reactorChambers[i]
                .energy))
    end
end

return {
    scanAdator = scanAdator,
    reactorChambers = reactorChambers,
    getGlobalRedstone = getGlobalRedstone
}
