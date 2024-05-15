local database = require("database")
local action = require("action")
local config = require("config")
local component = require("component")

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
    print(rc.reactorChamberAddr .. " is running")
    if rc.thresholdHeat ~= -1 then
        action.preheatRc(rc)
    end
    while true do
        if not database.getGlobalRedstone() then
            rc.running = false
            break;
        end

        local canCheck = true
        if config.energyLatchRedstone ~= -1 then
            if not getLatchRedstoneSingal() then
                action.stopReactorChamberByRc(rc)
                canCheck = false
            end
        end
        if canCheck then
            local scheme = config.scheme[rc.scheme]
            action.checkReactorChamberDMG(rc, scheme)
            action.checkReactorChamberHeat(rc, scheme)
            if rc.thresholdHeat == -1 then
                action.startReactorChamber(rc)
            end
        end
        os.sleep(0.5)
    end
    print(rc.reactorChamberAddr .. " is shutdown")
end

return {
    runningReactorChamber = runningReactorChamber
}
