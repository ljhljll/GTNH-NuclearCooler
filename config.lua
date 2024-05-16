return {
    -- 核电模式
    scheme = {
        -- 模式名(slyb)
        slyb = {
            -- 所使用到的资源
            resource = {
                {
                    name = "gt.360k_Helium_Coolantcell",
                    changeName = -1,
                    dmg = 90,
                    count = 14,
                    slot = { 3, 6, 9, 10, 15, 22, 26, 29, 33, 40, 45, 46, 49, 52 }
                },
                {
                    name = "gt.reactorUraniumQuad",
                    changeName = "ic2.reactorUraniumQuaddepleted",
                    dmg = -1,
                    count = 40,
                    slot = {
                        1, 2, 4, 5, 7, 8, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 23, 24, 25, 27, 28, 30, 31, 32, 34, 35, 36, 37,
                        38, 39, 41, 42, 43, 44, 47, 48, 50, 51, 53, 54 }
                }
            },
            --- 用于散热的组件 name:散热物品名  changeName: 临时用于替换的元件
            insurance = {
                name = "ic2.reactorVentGold",
                changeName = "gt.360k_Helium_Coolantcell",
                -- 散热组件的耐久要求(根据散热组件可承受的热熔来，例如超频散热片的热熔为10000)，只有小于该值的散热片会被使用
                dmg = 3000
            }
        }
    },
    --[[
     是否开启电量控制(提供一个红石端口,向该端口开启红石信号后开启核电)
     填入电量控制红石端口的地址,默认不启用
    --]]
    energyLatchRedstone = -1,
    globalRedstone = "69ffa4d5-1e0d-40dc-b5b6-cd9a288b6ba8",
    -- 当核反应堆达到该热度时,需使用散热组件进行散热,反应堆默认热容为10000
    dangerHeat = 100,
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
            scheme = "slyb",
            -- 预热堆温,默认-1不开启,用于99%堆核电(填9900)
            thresholdHeat = -1,
            -- 核电仓地址
            reactorChamberAddr = "348a414a-d8de-4535-a1c9-6e063e9aca73",
            -- 核电仓方向
            reactorChamberSide = 4,
            -- 开关核电的红石端口地址
            switchRedstone = "82427642-f660-4cca-96ff-70d0a0882f18",
            -- 转运器地址
            transforAddr = "f7c2f6e4-55fd-474d-953d-784e50cb2f91",
            -- 输入原材料的箱子位置(对转运器来说,例如填5则箱子需要在转运器的左边(east方向))
            inputSide = 3,
            -- 输出低耐久冷却单元的箱子位置(对转运器来说,例如填4则箱子需要在转运器的右边(west方向))
            outputSide = 3,
            -- 输出枯竭燃料棒的箱子位置(对转运器来说,例如填0则箱子需要在转运器的下边
            changeItemOutputSide = 3,
            -- 用于存放散热组件的箱子(也用作临时存储)
            tempSide = 3,
            drawerAddress = "57370d67-76a6-4321-9ed6-fba936c1295a"
        },
        {
            scheme = "slyb",
            thresholdHeat = -1,
            reactorChamberAddr = "cf13a2a7-255b-424d-b37d-f2f73ada603a",
            reactorChamberSide = 0,
            switchRedstone = "82427642-f660-4cca-96ff-70d0a0882f18",
            transforAddr = "f7c2f6e4-55fd-474d-953d-784e50cb2f91",
            inputSide = 3,
            outputSide = 3,
            changeItemOutputSide = 3,
            tempSide = 3,
            drawerAddress = "57370d67-76a6-4321-9ed6-fba936c1295a"
        },
        {
            scheme = "slyb",
            thresholdHeat = -1,
            reactorChamberAddr = "7be7eb0d-14f9-4ddb-b30b-abc4bc07a48a",
            reactorChamberSide = 5,
            switchRedstone = "82427642-f660-4cca-96ff-70d0a0882f18",
            transforAddr = "f7c2f6e4-55fd-474d-953d-784e50cb2f91",
            inputSide = 3,
            outputSide = 3,
            changeItemOutputSide = 3,
            tempSide = 3,
            drawerAddress = "57370d67-76a6-4321-9ed6-fba936c1295a"
        },
        {
            scheme = "slyb",
            thresholdHeat = -1,
            reactorChamberAddr = "ff3292b2-93db-4805-8bdd-dd3fc8f423aa",
            reactorChamberSide = 1,
            switchRedstone = "82427642-f660-4cca-96ff-70d0a0882f18",
            transforAddr = "f7c2f6e4-55fd-474d-953d-784e50cb2f91",
            inputSide = 3,
            outputSide = 3,
            changeItemOutputSide = 3,
            tempSide = 3,
            drawerAddress = "57370d67-76a6-4321-9ed6-fba936c1295a"
        }
    }
}
