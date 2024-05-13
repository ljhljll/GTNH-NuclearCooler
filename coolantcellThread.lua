local database = require("database")
local action = require("action")

local nowRc

local function runningReactorChamber(rc, scheme)
    nowRc = rc
    while nowRc.running do
        action.checkReactorChamberDMG(rc, scheme)
    end
end

return {

}
