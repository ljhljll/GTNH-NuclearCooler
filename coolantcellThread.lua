local action = require("action")
local config = require("config")
local component = require("component")
local coroutine = require("coroutine")

-- 获取电量锁存器信号
local function getLatchRedstoneSingal()
    local latchRedstone = component.proxy(config.energyLatchRedstone)
    local singalTable = latchRedstone.getInput()
    for side, num in pairs(singalTable) do
        if num > 0 then
            return true
        end
    end
    return false
end

local function runningReactorChamber(rc)
    while true do
        local canCheck = true
        if config.energyLatchRedstone ~= -1 and rc.energy then
            if not getLatchRedstoneSingal() then
                action.stopReactorChamberByRc(rc)
                canCheck = false
            end
        end
        if canCheck then
            local scheme = config.scheme[rc.scheme]
            action.checkReactorChamberDMG(rc, scheme)
            action.startReactorChamber(rc)
        end
        coroutine.yield()
    end
end

return {
    runningReactorChamber = runningReactorChamber
}
