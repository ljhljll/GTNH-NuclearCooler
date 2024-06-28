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
                    name = "gregtech:gt.60k_NaK_Coolantcell",
                    changeName = -1,
                    dmg = 90,
                    count = 9,
                    slot = { 5, 9, 11, 26, 32, 37, 45, 47, 52 }
                },
                {
                    name = "gregtech:gt.Quad_Thoriumcell",
                    changeName = "gregtech:gt.Quad_ThoriumcellDep",
                    dmg = -1,
                    count = 26,
                    slot = { 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 48, 50, 52, 54 }
                },
                {
                    name = "gregtech:gt.glowstoneCell",
                    changeName = "gregtech:gt.sunnariumCell",
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
    energyLatchRedstone = "8994c958-f714-47e9-9c65-6b7c90fd525d",
    -- 全局红石开关地址(必填)
    globalRedstone = "bc476f9e-04f1-4ef0-bbcc-6d2efb31fe6e",
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
            reactorChamberAddr = "f5e43bdd-40cb-4ad7-ac52-419a3ac97b8b",
            -- 核电仓方向
            reactorChamberSide = 1,
            -- 开关核电的红石端口地址
            switchRedstone = "f2df8c22-9883-4f44-b5dc-817bf9e4dac0",
            -- 转运器地址
            transforAddr = "e60b533f-85f2-46d6-8391-19db61026aae",
            -- 输入原材料的箱子位置(对转运器来说,例如填5则箱子需要在转运器的左边(east方向))
            inputSide = 5,
            -- 输出低耐久冷却单元的箱子位置(对转运器来说,例如填4则箱子需要在转运器的右边(west方向))
            outputSide = 5,
            -- 输出枯竭燃料棒的箱子位置(对转运器来说,例如填0则箱子需要在转运器的下边
            changeItemOutputSide = 5,
            -- 可自由扩展的箱子(目前用来存放用于99%堆加热的东西，可自由修改)
            tempSide = 5
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "bfcd305f-38cd-4c7d-aa6f-1e36eb464240",
            reactorChamberSide = 3,
            switchRedstone = "f2df8c22-9883-4f44-b5dc-817bf9e4dac0",
            transforAddr = "e60b533f-85f2-46d6-8391-19db61026aae",
            inputSide = 5,
            outputSide = 5,
            changeItemOutputSide = 5,
            tempSide = 5
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "0bf7e586-4e77-4136-8224-f35925bbdfc7",
            reactorChamberSide = 0,
            switchRedstone = "f2df8c22-9883-4f44-b5dc-817bf9e4dac0",
            transforAddr = "e60b533f-85f2-46d6-8391-19db61026aae",
            inputSide = 5,
            outputSide = 5,
            changeItemOutputSide = 5,
            tempSide = 5
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "384f9e56-01ca-4f24-9121-eee7f7b0b2f9",
            reactorChamberSide = 2,
            switchRedstone = "f2df8c22-9883-4f44-b5dc-817bf9e4dac0",
            transforAddr = "e60b533f-85f2-46d6-8391-19db61026aae",
            inputSide = 5,
            outputSide = 5,
            changeItemOutputSide = 5,
            tempSide = 5
        },
        {
            -- 对应上面scheme里面的发电模式
            scheme = "mox",
            -- 预热堆温,默认-1不开启,用于99%堆核电(填9900)
            thresholdHeat = 9900,
            -- 用于预热反应堆的燃料名
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            -- 核电仓地址
            reactorChamberAddr = "9e7fa7ca-603c-468f-98bc-8d877ba5e7c2",
            -- 核电仓方向
            reactorChamberSide = 1,
            -- 开关核电的红石端口地址
            switchRedstone = "75669c66-93a6-4242-bdf1-f8e57df070d5",
            -- 转运器地址
            transforAddr = "b7041056-c419-4106-bec8-92e8f63b0496",
            -- 输入原材料的箱子位置(对转运器来说,例如填5则箱子需要在转运器的左边(east方向))
            inputSide = 5,
            -- 输出低耐久冷却单元的箱子位置(对转运器来说,例如填4则箱子需要在转运器的右边(west方向))
            outputSide = 5,
            -- 输出枯竭燃料棒的箱子位置(对转运器来说,例如填0则箱子需要在转运器的下边
            changeItemOutputSide = 5,
            -- 可自由扩展的箱子(目前用来存放用于99%堆加热的东西，可自由修改)
            tempSide = 5
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "abdfdabc-6546-4d12-a585-cf276e52a985",
            reactorChamberSide = 3,
            switchRedstone = "75669c66-93a6-4242-bdf1-f8e57df070d5",
            transforAddr = "b7041056-c419-4106-bec8-92e8f63b0496",
            inputSide = 5,
            outputSide = 5,
            changeItemOutputSide = 5,
            tempSide = 5
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "741489c9-b562-4c94-833c-9d3a5af2f601",
            reactorChamberSide = 0,
            switchRedstone = "75669c66-93a6-4242-bdf1-f8e57df070d5",
            transforAddr = "b7041056-c419-4106-bec8-92e8f63b0496",
            inputSide = 5,
            outputSide = 5,
            changeItemOutputSide = 5,
            tempSide = 5
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "7672565a-35d8-4c90-8ff3-dcfd74f79534",
            reactorChamberSide = 2,
            switchRedstone = "75669c66-93a6-4242-bdf1-f8e57df070d5",
            transforAddr = "b7041056-c419-4106-bec8-92e8f63b0496",
            inputSide = 5,
            outputSide = 5,
            changeItemOutputSide = 5,
            tempSide = 5
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "0a106c16-eacc-4dd7-a9c4-d635316ce0f4",
            reactorChamberSide = 1,
            switchRedstone = "305b1e82-26e4-4dd6-b4bb-ce4aa7d0d844",
            transforAddr = "cf154cb3-86a9-44ba-91ec-f914ce714956",
            inputSide = 4,
            outputSide = 4,
            changeItemOutputSide = 4,
            tempSide = 4
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "6d11ee29-3d46-4e3c-ab29-d4d3c5b9f4f8",
            reactorChamberSide = 2,
            switchRedstone = "305b1e82-26e4-4dd6-b4bb-ce4aa7d0d844",
            transforAddr = "cf154cb3-86a9-44ba-91ec-f914ce714956",
            inputSide = 4,
            outputSide = 4,
            changeItemOutputSide = 4,
            tempSide = 4
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "a9aab1b2-2086-4e6e-b76b-86bd0dab7e32",
            reactorChamberSide = 0,
            switchRedstone = "305b1e82-26e4-4dd6-b4bb-ce4aa7d0d844",
            transforAddr = "cf154cb3-86a9-44ba-91ec-f914ce714956",
            inputSide = 4,
            outputSide = 4,
            changeItemOutputSide = 4,
            tempSide = 4
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "84c18ced-80e1-4956-9d35-a030373270d9",
            reactorChamberSide = 3,
            switchRedstone = "305b1e82-26e4-4dd6-b4bb-ce4aa7d0d844",
            transforAddr = "cf154cb3-86a9-44ba-91ec-f914ce714956",
            inputSide = 4,
            outputSide = 4,
            changeItemOutputSide = 4,
            tempSide = 4
        },

        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "15470de5-fc50-4fb5-8b31-6356d3a3a64d",
            reactorChamberSide = 1,
            switchRedstone = "55718679-eb88-4536-baf7-218ddf32cd4f",
            transforAddr = "b0bbbd6f-5fae-46ac-8c26-aecbeb3f6cde",
            inputSide = 4,
            outputSide = 4,
            changeItemOutputSide = 4,
            tempSide = 4
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "a65fce83-0bae-42b7-ad5b-62f32637d09e",
            reactorChamberSide = 2,
            switchRedstone = "55718679-eb88-4536-baf7-218ddf32cd4f",
            transforAddr = "b0bbbd6f-5fae-46ac-8c26-aecbeb3f6cde",
            inputSide = 4,
            outputSide = 4,
            changeItemOutputSide = 4,
            tempSide = 4
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "bf057a83-9e69-4221-9614-401ff177e274",
            reactorChamberSide = 0,
            switchRedstone = "55718679-eb88-4536-baf7-218ddf32cd4f",
            transforAddr = "b0bbbd6f-5fae-46ac-8c26-aecbeb3f6cde",
            inputSide = 4,
            outputSide = 4,
            changeItemOutputSide = 4,
            tempSide = 4
        },
        {
            scheme = "mox",
            thresholdHeat = 9900,
            preheatItem = "gregtech:gt.reactorUraniumQuad",
            reactorChamberAddr = "bccae71c-96f9-4a35-8cd6-4b69d08f0a54",
            reactorChamberSide = 3,
            switchRedstone = "55718679-eb88-4536-baf7-218ddf32cd4f",
            transforAddr = "b0bbbd6f-5fae-46ac-8c26-aecbeb3f6cde",
            inputSide = 4,
            outputSide = 4,
            changeItemOutputSide = 4,
            tempSide = 4
        }
    }
}
