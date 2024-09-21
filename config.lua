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
    energyLatchRedstone = "535435c8-1019-440a-8b22-b8bc1b6cf9a5",
    -- 全局红石开关地址(必填)
    globalRedstone = "00b0cb29-bc9a-488a-8605-22a31028ed95",
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
            scheme = "slyb",                                             --模式
            thresholdHeat = -1,                                          -- 预热堆温
            preheatItem = "gregtech:gt.reactorUraniumQuad",              -- 预热燃料
            reactorChamberAddr = "e044a135-4d27-4403-902e-b0d8d66b1c53", -- 核电仓地址
            reactorChamberSide = 1,                                      -- 核电仓方向
            switchRedstone = "49b24209-57c8-445d-8e9e-473fec29f3de",     -- 开关核电的红石端口地址
            reactorChamberSideToRS = 1,                                  -- 核电仓相对于红石信号器的方向 旧版本更新的话默认填写nil即可会取{reactorChamberSide}的方向
            transforAddr = "4a9956c3-7f70-4b30-a0c8-dd6e25affabd",       -- 转运器地址
            inputSide = 3,                                               -- 输入原材料的箱子位置
            outputSide = 3,                                              -- 输出低耐久冷却单元的箱子位置
            changeItemOutputSide = 3,                                    -- 输出枯竭燃料棒
            tempSide = 3,                                                -- 堆加热的东西的箱子位置
            energy = nil                                                 -- 是否参与电量控制,默认不填写或者为nil代表参与电量控制,只有在缺电时才会开启,设置为false则无视电量持续监测运行
        },
        {
            scheme = "slyb",                                             --模式
            thresholdHeat = -1,                                          -- 预热堆温
            preheatItem = "gregtech:gt.reactorUraniumQuad",              -- 预热燃料
            reactorChamberAddr = "3ba763f9-5c55-4be9-8ccc-5f321f702b17", -- 核电仓地址
            reactorChamberSide = 4,                                      -- 核电仓方向
            switchRedstone = "49b24209-57c8-445d-8e9e-473fec29f3de",     -- 开关核电的红石端口地址
            reactorChamberSideToRS = 4,                                  -- 核电仓相对于红石信号器的方向 旧版本更新的话默认填写nil即可会取{reactorChamberSide}的方向
            transforAddr = "4a9956c3-7f70-4b30-a0c8-dd6e25affabd",       -- 转运器地址
            inputSide = 3,                                               -- 输入原材料的箱子位置
            outputSide = 3,                                              -- 输出低耐久冷却单元的箱子位置
            changeItemOutputSide = 3,                                    -- 输出枯竭燃料棒
            tempSide = 3,                                                -- 堆加热的东西的箱子位置
            energy = nil                                                 -- 是否参与电量控制,默认不填写或者为nil代表参与电量控制,只有在缺电时才会开启,设置为false则无视电量持续监测运行
        },
        {
            scheme = "slyb",                                             --模式
            thresholdHeat = -1,                                          -- 预热堆温
            preheatItem = "gregtech:gt.reactorUraniumQuad",              -- 预热燃料
            reactorChamberAddr = "3a2fa58e-b862-4df5-ae99-b67e13fea876", -- 核电仓地址
            reactorChamberSide = 0,                                      -- 核电仓方向
            switchRedstone = "49b24209-57c8-445d-8e9e-473fec29f3de",     -- 开关核电的红石端口地址
            reactorChamberSideToRS = 0,                                  -- 核电仓相对于红石信号器的方向 旧版本更新的话默认填写nil即可会取{reactorChamberSide}的方向
            transforAddr = "4a9956c3-7f70-4b30-a0c8-dd6e25affabd",       -- 转运器地址
            inputSide = 3,                                               -- 输入原材料的箱子位置
            outputSide = 3,                                              -- 输出低耐久冷却单元的箱子位置
            changeItemOutputSide = 3,                                    -- 输出枯竭燃料棒
            tempSide = 3,                                                -- 堆加热的东西的箱子位置
            energy = nil                                                 -- 是否参与电量控制,默认不填写或者为nil代表参与电量控制,只有在缺电时才会开启,设置为false则无视电量持续监测运行
        },
        {
            scheme = "slyb",                                             --模式
            thresholdHeat = -1,                                          -- 预热堆温
            preheatItem = "gregtech:gt.reactorUraniumQuad",              -- 预热燃料
            reactorChamberAddr = "9b49cef2-44e8-42b8-8ac8-e8e91223de01", -- 核电仓地址
            reactorChamberSide = 5,                                      -- 核电仓方向
            switchRedstone = "49b24209-57c8-445d-8e9e-473fec29f3de",     -- 开关核电的红石端口地址
            reactorChamberSideToRS = 5,                                  -- 核电仓相对于红石信号器的方向 旧版本更新的话默认填写nil即可会取{reactorChamberSide}的方向
            transforAddr = "4a9956c3-7f70-4b30-a0c8-dd6e25affabd",       -- 转运器地址
            inputSide = 3,                                               -- 输入原材料的箱子位置
            outputSide = 3,                                              -- 输出低耐久冷却单元的箱子位置
            changeItemOutputSide = 3,                                    -- 输出枯竭燃料棒
            tempSide = 3,                                                -- 堆加热的东西的箱子位置
            energy = nil                                                 -- 是否参与电量控制,默认不填写或者为nil代表参与电量控制,只有在缺电时才会开启,设置为false则无视电量持续监测运行
        }
    }
}
