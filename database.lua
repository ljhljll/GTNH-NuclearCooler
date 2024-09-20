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


local function scanAdaptor()
    local reactorChamberList = config.reactorChamberList
    print("读取到" .. #reactorChamberList .. "个核电配置")
    for i = 1, #reactorChamberList, 1 do
        reactorChambers[i] = reactorChamberList[i]
        reactorChambers[i].running = false
        if (reactorChambers[i].energy == nil) then
            reactorChambers[i].energy = true
        end
        if reactorChambers[i].reactorChamberSideToRS == nil then -- 如果没有配置这个，使用和转运器一样的方向设置，这是为了兼容ljhljll/GTNH-NuclearCooler的行为
            reactorChambers[i].reactorChamberSideToRS = reactorChambers[i].reactorChamberSide
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
    scanAdaptor = scanAdaptor,
    reactorChambers = reactorChambers,
    getGlobalRedstone = getGlobalRedstone
}
