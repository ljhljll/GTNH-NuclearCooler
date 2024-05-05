# GTNH-NuclearCooler
该脚本基于
https://github.com/L-Temple/OC-NuclearCooler
的脚本进行改造
加入了因为游戏延迟导致的核反应堆温度上升而导致的核电停机处理(原脚本处理时当核电仓温度>1000就会停机,得手动将散热片放入核电仓进行散热后手动重启才行)

基本使用流程:
1. 准备一套OC(高级机箱、内存条、显示器、键盘、磁盘驱动器、红石IO端口2个、一些线缆、BIOS、高级处理器(cpu)、基础显卡、转运器、适配器等等
2. 装机后将JSON.lua、index.lua、config.json放入存档中的opencomputers/{设备id}下
3. 编辑config.json,参数释义如下:
```
{
  "slyb": {
    "resource": [
      {
        "name": "gregtech:gt.360k_Helium_Coolantcell",
        "changeName": -1,
        "dmg": 90,
        "count": 14,
        "slot": [3, 6, 9, 10, 15, 22, 26, 29, 33, 40, 45, 46, 49, 52]
      },
      {
        "name": "gregtech:gt.reactorUraniumQuad",
        "changeName": "IC2:reactorUraniumQuaddepleted",
        "dmg": -1,
        "count": 40,
        "slot": [
          1, 2, 4, 5, 7, 8, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 23, 24, 25, 27, 28, 30, 31, 32, 34, 35, 36, 37, 38,
          39, 41, 42, 43, 44, 47, 48, 50, 51, 53, 54
        ]
      }
    ],
    "insurance": {
      "name": "IC2:reactorVentGold",
      "changeName": "gregtech:gt.360k_Helium_Coolantcell"
    }
  }
}
```
```
slyb:项目名,你启动时需要输入的名称,自行填写

resource: 要加入核反应堆中的原材料(如铀棒、冷却单元)
resource.name: 要加入核电仓的物品名称
resource.changeName: 该物品变化后的名称（如4连铀棒变为枯竭的4连铀棒）
resource.count: 物品数量
resource.slot: 该物品要放入核电仓中的位置(从左上角第一格开始,从左到右从上到下的顺序计数,从1开始)

insurance: 用于冷却反应堆的物品
insurance.name: 用于冷却反应堆的物品名称,例如"IC2:reactorVentGold"(超频散热片)
insurance.changeName: 散热片要替换的核电仓中任意一个组件的名字(默认配置将核电仓中第一个空位或物品名称为"changeName"的物品替换为散热片)
```
4. 配置index.lua,配置第5、6、13、14、15、16行代码，根据你游戏中具体的数据来设定
使用oc中的分析器右键红石端口可以直接复制它的地址id
这里的方位，是以你放下"转运器"的正面来判断的,可以在它旁边随便翻个gt机器，然后根据扳手来调整方位，加上OO的方位显示来填写对应的数字

5. 启动！
