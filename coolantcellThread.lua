local database = require("database")
local action = require("action")
local config = require("config")
local component = require("component")

local function runningReactorChamber(rc, scheme)
    print(rc.side .. " is running")
    while true do
        if not database.getGlobalRedstone() then
            rc.running = false
            break;
        end

        local canRunning = false
        if config.energyLatch then
            local latchRedstone = component.proxy(config.energyLatchRedstone)
            local singalTable = latchRedstone.getInput()
            for side, num in pairs(singalTable) do
                print(side .. " " .. num)
                if num > 0 then
                    canRunning = true
                    break
                else
                    canRunning = false
                end
            end
            if not canRunning then
                action.stopReactorChamberByRc(rc)
            end
        end
        if (config.energyLatch and canRunning) or not config.energyLatch then
            action.checkReactorChamberDMG(rc, scheme)
            action.checkReactorChamberHeat(rc, scheme)
            action.startReactorChamber(rc)
        end
        os.sleep(1)
    end
    print(rc.side .. " is shutdown")
end

return {
    runningReactorChamber = runningReactorChamber
}
