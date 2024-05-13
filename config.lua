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
                changeName = "gregtech:gt.360k_Helium_Coolantcell"
            }
        }
    },
    globalRedstone = "292c254c-d4c6-4372-81c8-0c4b86d6a989"
}