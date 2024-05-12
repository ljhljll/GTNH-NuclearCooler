local component = require("component")
local database = require("database")
local sides = require("sides")
local config = require("config")
local action = require("action")

local function scanSchame(scheme)
    while true do
        local enoughOk = 0
        for i = 1, #scheme.resource, 1 do
            local isEnough =
                action.checkItemCount(scheme.resource[i].name, scheme.resource[i].count * database.getOpenNum())
            if isEnough then
                enoughOk = enoughOk + 1
            else
                print("项目所需的材料: " .. scheme.resource[i].name .. "数量不足")
            end
        end
        return enoughOk == #scheme.resource
    end
end

return {
    scanSchame = scanSchame
}
