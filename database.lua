local sides = require("sides")
local component = require("component")
local config = require("config")
local controlRedstone
local globalRedstoneSide = nil
local scanSide = { sides.top, sides.right, sides.bottom, sides.left }
local openNum = 1
local reactorChambers = {}

local function getControlRedstone()
    return controlRedstone
end

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

local function setOpenNum(num)
    print(#reactorChambers .. "扫描了核电数量")
    if num <= 0 or num > #reactorChambers then
        return false
    end
    openNum = num
    return true
end

local function getOpenNum()
    return openNum
end


local function scanReactorRedstone()
    for address, name in pairs(component.list("redstone")) do
        if address ~= config.globalRedstone and address ~= config.energyLatchRedstone then
            controlRedstone = component.proxy(address)
            break;
        end
    end
end

local function scanAdator()
    local reactorChamberList = component.list("reactor")
    local index = 1
    for i = 1, #scanSide, 1 do
        repeat
            local startSingal = controlRedstone.setOutput(scanSide[i], 15)
        until (startSingal == 15)
        for address, name in pairs(reactorChamberList) do
            local reactor = component.proxy(address)
            if reactor.producesEnergy() then
                reactorChambers[index] = {
                    reactor = reactor,
                    address = address,
                    side = scanSide[i],
                    running = false
                }
                index = index + 1
            end
        end
        repeat
            local closeSingal = controlRedstone.setOutput(scanSide[i], 0)
        until (closeSingal == 0)
    end
end

return {
    setOpenNum = setOpenNum,
    getOpenNum = getOpenNum,
    scanAdator = scanAdator,
    scanReactorRedstone = scanReactorRedstone,
    reactorChambers = reactorChambers,
    getGlobalRedstone = getGlobalRedstone,
    getControlRedstone = getControlRedstone,
    scanSide = scanSide
}
