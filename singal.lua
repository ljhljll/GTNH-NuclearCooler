local component = require("component")
local sides = require("sides")
local os = require("os")


local function getSingal(redston, side)
    return redston.getInput(side)
end

local function pluseDown()

end

local function init(redStone, side)
    if redStone == nil then
        print("全局开关未指定")
        return false
    end

    if side ~= nil then
        globalSingal.side = side
    end

    globalSingal.redston = component.proxy(redStone)
    return true
end

return {
    pluseDown = pluseDown,
    init = init,
    getSingal = getSingal
}
