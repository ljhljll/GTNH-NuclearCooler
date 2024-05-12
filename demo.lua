local thread = require("thread")
local event = require("event")


thread.create(function()
    local function demo(i)
        print("子线程" .. i)
    end
    local eventID = event.listen("demo", demo)
    print(eventID .. "已经注册demo事件")
end)
print("Main program end")
for i = 1, 3, 1 do
    print("主线程插入事件")
    event.push("demo", i)
    os.sleep(5)
end
