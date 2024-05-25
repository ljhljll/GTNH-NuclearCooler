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
                    name = "gregtech:gt.1080k_Space_Coolantcell",
                    changeName = -1,
                    dmg = 90,
                    count = 14,
                    slot = { 3, 6, 9, 10, 15, 22, 26, 29, 33, 40, 45, 46, 49, 52 }
                },
                {
                    name = "GoodGenerator:rodCompressedPlutonium4",
                    changeName = "GoodGenerator:rodCompressedPlutoniumDepleted4",
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
                    name = "gregtech:gt.60k_NaK_Coolantcell",
                    changeName = -1,
                    dmg = 90,
                    count = 9,
                    slot = { 5, 9, 11, 26, 32, 37, 45, 47, 52 }
                },
                {
                    name = "gregtech:gt.Quad_Thoriumcell",
                    changeName = "greatech:gt.Quad_ThoriumcellDep",
                    dmg = -1,
                    count = 26,
                    slot = { 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 48, 50, 52, 54 }
                },
                {
                    name = "greatech:gt.glowstoneCell",
                    changeName = "greatech:gt.sunnariumCell",
                    dmg = -1,
                    count = 18,
                    slot = { 1, 3, 7, 13, 15, 17, 19, 21, 23, 27, 29, 33, 35, 39, 41, 43, 49, 53 }
                },
                {
                    name = "IC2:reactorPlating",
                    changeName = -1,
                    dmg = -1,
                    count = 1,
                    slot = { 46 }
                }
            }
        }

    },
    --[[
     是否开启电量控制(提供一个红石端口,向该端口开启红石信号后开启核电)
     填入电量控制红石端口的地址,默认不启用（-1)
    --]]
    energyLatchRedstone = "8d772225-df71-41b9-ade8-df51764c96ad",
    -- 全局红石开关地址(必填)
    globalRedstone = "ed89abd2-df21-4a4d-a9f3-9c76214faf1b",
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
            -- 对应上面scheme里面的发电模式
            scheme = "slyb",
            -- 预热堆温,默认-1不开启,用于99%堆核电(填9900)
            thresholdHeat = -1,
            -- 用于预热反应堆的燃料名
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            -- 核电仓地址
            reactorChamberAddr = "06b5c62b-17fb-4909-99ae-0d745aeca04b",
            -- 核电仓方向
            reactorChamberSide = 1,
            -- 开关核电的红石端口地址
            switchRedstone = "91336ae5-edb7-4913-9474-224d0aae693f",
            -- 转运器地址
            transforAddr = "39b51a7e-06ea-4723-a99e-f9e3cc399e88",
            -- 输入原材料的箱子位置(对转运器来说,例如填5则箱子需要在转运器的左边(east方向))
            inputSide = 2,
            -- 输出低耐久冷却单元的箱子位置(对转运器来说,例如填4则箱子需要在转运器的右边(west方向))
            outputSide = 2,
            -- 输出枯竭燃料棒的箱子位置(对转运器来说,例如填0则箱子需要在转运器的下边
            changeItemOutputSide = 2,
            -- 可自由扩展的箱子(目前用来存放用于99%堆加热的东西，可自由修改)
            tempSide = 2
        },
        {
            -- 对应上面scheme里面的发电模式
            scheme = "slyb",
            -- 预热堆温,默认-1不开启,用于99%堆核电(填9900)
            thresholdHeat = -1,
            -- 用于预热反应堆的燃料名
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            -- 核电仓地址
            reactorChamberAddr = "d67da54f-5235-41be-98ab-ff9054d05812",
            -- 核电仓方向
            reactorChamberSide = 5,
            -- 开关核电的红石端口地址
            switchRedstone = "91336ae5-edb7-4913-9474-224d0aae693f",
            -- 转运器地址
            transforAddr = "39b51a7e-06ea-4723-a99e-f9e3cc399e88",
            -- 输入原材料的箱子位置(对转运器来说,例如填5则箱子需要在转运器的左边(east方向))
            inputSide = 2,
            -- 输出低耐久冷却单元的箱子位置(对转运器来说,例如填4则箱子需要在转运器的右边(west方向))
            outputSide = 2,
            -- 输出枯竭燃料棒的箱子位置(对转运器来说,例如填0则箱子需要在转运器的下边
            changeItemOutputSide = 2,
            -- 可自由扩展的箱子(目前用来存放用于99%堆加热的东西，可自由修改)
            tempSide = 2
        },
        {
            -- 对应上面scheme里面的发电模式
            scheme = "slyb",
            -- 预热堆温,默认-1不开启,用于99%堆核电(填9900)
            thresholdHeat = -1,
            -- 用于预热反应堆的燃料名
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            -- 核电仓地址
            reactorChamberAddr = "1af24d78-72e0-40b6-814e-760e05cedd1c",
            -- 核电仓方向
            reactorChamberSide = 0,
            -- 开关核电的红石端口地址
            switchRedstone = "91336ae5-edb7-4913-9474-224d0aae693f",
            -- 转运器地址
            transforAddr = "39b51a7e-06ea-4723-a99e-f9e3cc399e88",
            -- 输入原材料的箱子位置(对转运器来说,例如填5则箱子需要在转运器的左边(east方向))
            inputSide = 2,
            -- 输出低耐久冷却单元的箱子位置(对转运器来说,例如填4则箱子需要在转运器的右边(west方向))
            outputSide = 2,
            -- 输出枯竭燃料棒的箱子位置(对转运器来说,例如填0则箱子需要在转运器的下边
            changeItemOutputSide = 2,
            -- 可自由扩展的箱子(目前用来存放用于99%堆加热的东西，可自由修改)
            tempSide = 2
        },
        {
            -- 对应上面scheme里面的发电模式
            scheme = "slyb",
            -- 预热堆温,默认-1不开启,用于99%堆核电(填9900)
            thresholdHeat = -1,
            -- 用于预热反应堆的燃料名
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            -- 核电仓地址
            reactorChamberAddr = "b38823c3-4e1e-4900-b6f8-09fd375154e9",
            -- 核电仓方向
            reactorChamberSide = 4,
            -- 开关核电的红石端口地址
            switchRedstone = "91336ae5-edb7-4913-9474-224d0aae693f",
            -- 转运器地址
            transforAddr = "39b51a7e-06ea-4723-a99e-f9e3cc399e88",
            -- 输入原材料的箱子位置(对转运器来说,例如填5则箱子需要在转运器的左边(east方向))
            inputSide = 2,
            -- 输出低耐久冷却单元的箱子位置(对转运器来说,例如填4则箱子需要在转运器的右边(west方向))
            outputSide = 2,
            -- 输出枯竭燃料棒的箱子位置(对转运器来说,例如填0则箱子需要在转运器的下边
            changeItemOutputSide = 2,
            -- 可自由扩展的箱子(目前用来存放用于99%堆加热的东西，可自由修改)
            tempSide = 2
        },
        {
            -- 对应上面scheme里面的发电模式
            scheme = "mox",
            -- 预热堆温,默认-1不开启,用于99%堆核电(填9900)
            thresholdHeat = 9900,
            -- 用于预热反应堆的燃料名
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            -- 核电仓地址
            reactorChamberAddr = "eb857b6c-7625-4668-a2e2-d65ff5d869f9",
            -- 核电仓方向
            reactorChamberSide = 4,
            -- 开关核电的红石端口地址
            switchRedstone = "caf1cd78-05e3-4675-aaea-427d265c2849",
            -- 转运器地址
            transforAddr = "f5290190-3a45-45e7-926c-788c9454054a",
            -- 输入原材料的箱子位置(对转运器来说,例如填5则箱子需要在转运器的左边(east方向))
            inputSide = 3,
            -- 输出低耐久冷却单元的箱子位置(对转运器来说,例如填4则箱子需要在转运器的右边(west方向))
            outputSide = 2,
            -- 输出枯竭燃料棒的箱子位置(对转运器来说,例如填0则箱子需要在转运器的下边
            changeItemOutputSide = 0,
            -- 可自由扩展的箱子(目前用来存放用于99%堆加热的东西，可自由修改)
            tempSide = 2
        }
    }
}
