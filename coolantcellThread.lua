local database = require("database")
local action = require("action")
local config = require("config")
local component = require("component")

local function runningReactorChamber(rc, scheme)
    while rc.running do
        if not database.getGlobalRedstone() then
            rc.running = false
            break;
        end

        if config.energyLatch then
            local latchRedstone = component.proxy(config.energyLatchRedstone)
            local singalTable = latchRedstone.getInput()
            for i = 1, #singalTable, 1 do
                if singalTable[i] > 0 then
                    goto startCheck
                end
            end
            action.stopReactorChamberBySides(rc)
            goto nextCheck
        end
        ::startCheck::
        action.checkReactorChamberDMG(rc, scheme)
        action.checkReactorChamberHeat(rc, scheme)
        action.startReactorChamber(rc)
        ::nextCheck::
        os.sleep(1)
    end
end

return {
    runningReactorChamber = runningReactorChamber
}
