local sides = require("sides")
local component = require("component")
local config = require("config")
local redstone
local globalRedstoneSide
local scanSide = { sides.top, sides.right, sides.bottom, sides.left }
local openNum = 1
local adaptors = {}
local runningrReactorChamber
local waitCoolingReactorChamber


local function getGlobalRedstone()
    local global = component.proxy(config.globalRedstone)
    if globalRedstoneSide ~= nil then
        return global.getInput(globalRedstoneSide) > 0
    end
    local signal = global.getInput()
    for _ = 1, #signal, 1 do
        if signal[_] > 0 then
            globalRedstoneSide = _
            return true
        end
    end
    return false
end

local function setOpenNum(num)
    if num <= 0 or num > #adaptors then
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
        if address ~= config.globalRedstone then
            redstone = component.proxy(address)
            break;
        end
    end
end

local function scanAdator()
    local reactorChamberList = component.list("reactor")
    for i = 1, #scanSide, 1 do
        redstone.setOutput(scanSide[i], 15)
        for address, name in pairs(reactorChamberList) do
            local reactor = component.proxy(address)
            if reactor.producesEnergy() then
                adaptors[scanSide[i]] = {
                    reactor = reactor,
                    address = address,
                    side = scanSide[i]
                }
            end
        end
    end
end

return {
    setOpenNum = setOpenNum,
    getOpenNum = getOpenNum,
    scanAdator = scanAdator,
    scanReactorRedstone = scanReactorRedstone,
    adaptors = adaptors,
    getGlobalRedstone = getGlobalRedstone,
    redstone = redstone,
    scanSide = scanSide,
    runningrReactorChamber = runningrReactorChamber
}
