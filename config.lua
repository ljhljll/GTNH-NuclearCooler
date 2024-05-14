return {
    scheme = {
        slyb = {
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
            },
            --- 用于散热的组件 name:散热物品名  changeName: 临时用于替换的元件
            insurance = {
                name = "IC2:reactorVentGold",
                changeName = "gregtech:gt.360k_Helium_Coolantcell",
                -- 散热组件的耐久要求(根据散热组件可承受的热熔来，例如超频散热片的热熔为10000)，只有小于该值的散热片会被使用
                dmg = 3000
            }
        }
    },
    -- 是否开启电量锁存器(提供一个红石端口,向该端口开启红石信号后开启核电)
    energyLatch = false,
    -- 电量锁存器红石端口的地址
    energyLatchRedstone = "",
    globalRedstone = "03e7f8b7-2048-437f-80f1-d5dbd5b5787a",
    -- 当核反应堆达到该热度时,需使用散热组件进行散热,反应堆默认热容为10000
    dangerHeat = 100
}
