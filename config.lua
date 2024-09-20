return {
    -- 核电模式
    scheme = {
        -- 模式名(slyb)
        slyb = {
            -- 所使用到的资源
            resource = {
                {
                    name = "gregtech:gt.360k_Helium_Coolantcell",
                    changeName = -1,
                    dmg = 90,
                    count = 14,
                    slot = { 3, 6, 9, 10, 15, 22, 26, 29, 33, 40, 45, 46, 49, 52 }
                },
                {
                    name = "gregtech:gt.reactorUraniumQuad",
                    changeName = "IC2:reactorUraniumQuaddepleted",
                    dmg = -1,
                    count = 40,
                    slot = {
                        1, 2, 4, 5, 7, 8, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 23, 24, 25, 27, 28, 30, 31, 32, 34, 35, 36, 37,
                        38, 39, 41, 42, 43, 44, 47, 48, 50, 51, 53, 54 }
                }
            }
        },
        mox = {
            resource = {
                {
                    name = "gregtech:gt.360k_Helium_Coolantcell",
                    changeName = -1,
                    dmg = 90,
                    count = 14,
                    slot = { 3, 6, 9, 10, 15, 22, 26, 29, 33, 40, 45, 46, 49, 52 }
                },
                {
                    name = "gregtech:gt.reactorMOXQuad",
                    changeName = "IC2:reactorMOXQuaddepleted",
                    dmg = -1,
                    count = 40,
                    slot = {
                        1, 2, 4, 5, 7, 8, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 23, 24, 25, 27, 28, 30, 31, 32, 34, 35, 36, 37,
                        38, 39, 41, 42, 43, 44, 47, 48, 50, 51, 53, 54 }
                }
            }
        },
        yghhw = {
            resource = {
                {
                    name = "gregtech:gt.360k_Helium_Coolantcell",
                    changeName = -1,
                    dmg = 90,
                    count = 9,
                    slot = { 5, 9, 11, 25, 31, 37, 45, 47, 51 }
                },
                {
                    name = "gregtech:gt.Quad_Thoriumcell",
                    changeName = "gregtech:gt.Quad_ThoriumcellDep",
                    dmg = -1,
                    count = 26,
                    slot = { 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54 }
                },
                {
                    name = "gregtech:gt.glowstoneCell",
                    changeName = "gregtech:gt.sunnariumCell",
                    dmg = -1,
                    count = 18,
                    slot = { 1, 3, 7, 13, 15, 17, 19, 21, 23, 27, 29, 33, 35, 39, 41, 43, 49, 53 }
                }
            }
        }

    },
    -- 是否开启控制台日志清理
    clearLog = true,
    -- 每n秒清理一次控制台日志
    cleatLogInterval = 30,
    --[[
     是否开启电量控制(提供一个红石端口,向该端口开启红石信号后开启核电)
     填入电量控制红石端口的地址,默认不启用（-1)
    --]]
    energyLatchRedstone = "1b9f4226-97df-4dc7-9d2b-29e49aba384b",
    -- 全局红石开关地址(必填)
    globalRedstone = "9c775443-fa8b-47be-a5d9-5e3a869a4c9c",
    --[[
    核电堆配置,可同时配置多台核电并在启动时自己选择开启哪几台,例如下边有2个核电配置，输入1 2即可开两台,只输入2则只启动第二个配置的核电
    方向取值可开启f3来看当前的朝向:
    底面: 0 对应方向:down、negy
    顶面: 1 对应方向:up、posy
    背面: 2 对应方向:north、negz
    前面: 3 对应方向:south、posz、forward
    右面: 4 对应方向:west、negx
    左面: 5 对应方向:east、posx
    --]]
    reactorChamberList = {
        {
            scheme = "mox",--模式
            thresholdHeat = 9500,-- 预热堆温
            preheatItem = "gregtech:gt.reactorUraniumQuad", -- 预热燃料
            reactorChamberAddr = "1a21c432-5331-4d22-8f2f-6d94d8473708", -- 核电仓地址
            reactorChamberSide = 4, -- 核电仓方向
            switchRedstone = "c072f967-8505-417b-836a-989820d3e029",  -- 开关核电的红石端口地址
            reactorChamberSideToRS = 1, -- 核电仓相对于红石信号器的方向
            transforAddr = "5a86daa2-52ad-4da4-8d77-7cd5ef5c44ad",  -- 转运器地址
            inputSide = 0, -- 输入原材料的箱子位置
            outputSide = 3,  -- 输出低耐久冷却单元的箱子位置
            changeItemOutputSide = 1,  -- 输出枯竭燃料棒
            tempSide = 2,   -- 堆加热的东西的箱子位置
            energy = nil -- 是否参与电量控制,默认不填写或者为nil代表参与电量控制,只有在缺电时才会开启,设置为false则无视电量持续监测运行
        },
        {
            scheme = "mox",--模式
            thresholdHeat = 9500,-- 预热堆温
            preheatItem = "gregtech:gt.reactorUraniumQuad", -- 预热燃料
            reactorChamberAddr = "5718cf3c-1789-41e2-9da3-f2d300e68749", -- 核电仓地址
            reactorChamberSide = 4, -- 核电仓方向
            switchRedstone = "e0ce46c1-ca8d-4fbc-ab44-b9518d498044",  -- 开关核电的红石端口地址
            reactorChamberSideToRS = 0, -- 核电仓相对于红石信号器的方向
            transforAddr = "3f34866d-9748-425b-a919-f8c893760954",  -- 转运器地址
            inputSide = 0, -- 输入原材料的箱子位置
            outputSide = 3,  -- 输出低耐久冷却单元的箱子位置
            changeItemOutputSide = 1,  -- 输出枯竭燃料棒
            tempSide = 2,   -- 堆加热的东西的箱子位置
            energy = nil -- 是否参与电量控制,默认不填写或者为nil代表参与电量控制,只有在缺电时才会开启,设置为false则无视电量持续监测运行
        },
        {
            scheme = "mox",--模式
            thresholdHeat = 9500,-- 预热堆温
            preheatItem = "gregtech:gt.reactorUraniumQuad", -- 预热燃料
            reactorChamberAddr = "79a482bf-4627-454c-b119-595f7944b97b", -- 核电仓地址
            reactorChamberSide = 4, -- 核电仓方向
            switchRedstone = "f7e2f68f-fb13-407d-8f0b-b75edfcfd588",  -- 开关核电的红石端口地址
            reactorChamberSideToRS = 1, -- 核电仓相对于红石信号器的方向
            transforAddr = "d435507f-7973-4fbb-a107-4ebf448cf314",  -- 转运器地址
            inputSide = 0, -- 输入原材料的箱子位置
            outputSide = 3,  -- 输出低耐久冷却单元的箱子位置
            changeItemOutputSide = 1,  -- 输出枯竭燃料棒
            tempSide = 2,   -- 堆加热的东西的箱子位置
            energy = nil -- 是否参与电量控制,默认不填写或者为nil代表参与电量控制,只有在缺电时才会开启,设置为false则无视电量持续监测运行
        },
        {
            scheme = "mox",--模式
            thresholdHeat = 9500,-- 预热堆温
            preheatItem = "gregtech:gt.reactorUraniumQuad", -- 预热燃料
            reactorChamberAddr = "1eb88227-0c91-440d-bc27-ef2918f832e0", -- 核电仓地址
            reactorChamberSide = 4, -- 核电仓方向
            switchRedstone = "0d904402-9be5-49d9-8b90-62bc8f31ddf5",  -- 开关核电的红石端口地址
            reactorChamberSideToRS = 0, -- 核电仓相对于红石信号器的方向
            transforAddr = "930f1cce-8088-4cdd-8a10-25fa2df0fb7a",  -- 转运器地址
            inputSide = 0, -- 输入原材料的箱子位置
            outputSide = 3,  -- 输出低耐久冷却单元的箱子位置
            changeItemOutputSide = 1,  -- 输出枯竭燃料棒
            tempSide = 2,   -- 堆加热的东西的箱子位置
            energy = nil -- 是否参与电量控制,默认不填写或者为nil代表参与电量控制,只有在缺电时才会开启,设置为false则无视电量持续监测运行
        },
        {
            scheme = "mox",--模式
            thresholdHeat = 9500,-- 预热堆温
            preheatItem = "gregtech:gt.reactorUraniumQuad", -- 预热燃料
            reactorChamberAddr = "3dd59913-8c21-4dc4-8395-805d5a40ef6b", -- 核电仓地址
            reactorChamberSide = 4, -- 核电仓方向
            switchRedstone = "6b6b213b-1d63-4c2f-8c84-0386f212b782",  -- 开关核电的红石端口地址
            reactorChamberSideToRS = 1, -- 核电仓相对于红石信号器的方向
            transforAddr = "704597b2-573a-4ac3-900e-f695ef214963",  -- 转运器地址
            inputSide = 0, -- 输入原材料的箱子位置
            outputSide = 3,  -- 输出低耐久冷却单元的箱子位置
            changeItemOutputSide = 1,  -- 输出枯竭燃料棒
            tempSide = 2,   -- 堆加热的东西的箱子位置
            energy = nil -- 是否参与电量控制,默认不填写或者为nil代表参与电量控制,只有在缺电时才会开启,设置为false则无视电量持续监测运行
        },
    }
}