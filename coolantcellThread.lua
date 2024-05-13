local database = require("database")
local action = require("action")

local nowRc

local function runningReactorChamber(rc, scheme)
    nowRc = rc
    print(database.getGlobalRedstone())
    database.getControlRedstone().setOutput(rc.side, 15)
    while nowRc.running do
        if not database.getGlobalRedstone() then
            nowRc.running = false
            break;
        end
        print("检测一次")
        --action.checkReactorChamberDMG(rc, scheme)
        os.sleep(5)
        print("休眠结束")
    end
end

return {
    runningReactorChamber = runningReactorChamber
}
