# GTNH-NuclearCooler

基本使用流程:
1. 准备一套OC(高级机箱、内存条、显示器、键盘、磁盘驱动器、红石IO端口2个、一些线缆、BIOS、高级处理器(cpu)、基础显卡、转运器、适配器等等
2. 装机后将lua文件放入存档中的opencomputers/{设备id}下
3. 编辑config.lua,释义已在文件中标注,使用oc中的分析器右键红石端口可以直接复制它的地址id
    文件中的方向是可通过开F3等方式来获取（请以转运器为基准来区分方向)
4. 开机启动！

搭建的结构参考：

![多联核电](assets/多联核电.jpg)

![mox99%核电](assets/mox99堆.jpg)

# 必看常见问题
1. 请不要使用windows记事本编辑器进行config.lua的修改,会导致程序无法使用
2. 默认的config.lua中包含了mox99%强冷堆、4连强冷铀堆的默认配置，请按照自己的组件地址进行修改


- [x] 删去无用的散热代码
- [x] 完成99%核电测试及处理
- [x] 简化结构使其得以更少的组件管理更多的核电
- [x] 自行控制反应堆是否参与电量控制
- [x] 16套4连核电低tps运行30*24小时不停机稳定运行
- [x] 半云使用协程优化核电堆检测逻辑
- [x] 增加温控功能
- [x] 优化核电状态打印
- [x] 优化justStart管理协查的代码,增加协查重启机制

# config.lua配置项

游戏中按F3+H开启显示物品拓展信息即可找到物品代码

| 配置项名                 | 取值      | 默认                           | 说明                                                         |
| ------------------------ | --------- | ------------------------------ | ------------------------------------------------------------ |
| `name`                   | `string`  | 不填写则取核电仓地址值         | 用于日志打印时的核电堆名称标识                               |
| `scheme`                 | `string`  | slyb                           | 可选`slyb`\|`mox`\|`yghhw`                                   |
| `thresholdHeat`          | `number`  | -1                             | 开启预热功能,无需开启则填写-1或nil<br>示例: 99%=9900         |
| `preheatItem`            | `string`  | gregtech:gt.reactorUraniumQuad | 用于预热的材料,对应四连铀棒的物品代码                        |
| `reactorChamberAddr`     | `string`  |                                | 核电仓地址(使用`调试器`shift+右键连接核电仓的`适配器`获取)   |
| `reactorChamberSide`     | `number`  |                                | 以`转运器`为基准,`核电仓`所对应的方向值                      |
| `switchRedstone`         | `string`  |                                | 控制该核电仓的`红石端口`地址                                 |
| `reactorChamberSideToRS` | `number`  | `reactorChamberSide`的取值     | 以`switchRedstone`对应的`红石端口`为基准,`核电仓`所对应的方向值 |
| `transforAddr`           | `string`  |                                | 转运器地址                                                   |
| `inputSide`              | `number`  |                                | 以`转运器`为基准,输入原材料的箱子方向值                      |
| `outputSide`             | `number`  |                                | 以`转运器`为基准,输出低耐久冷却单元的箱子方向值              |
| `changeItemOutputSide`   | `number`  |                                | 以`转运器`为基准,输出枯竭燃料棒方向值                        |
| `tempSide`               | `number`  |                                | 以`转运器`为基准,存放预加热的物品的箱子方向值                |
| `energy`                 | `boolean` | nil                            | 是否参与电量控制<br />`true`:是<br />`nil|false`:否          |
| `aborted`                | `boolean` | nil                            | 是否进行过热检测<br />`true`:是<br />`nil|false`:否          |



方向取值:

底面: 0 对应方向:down、negy

顶面: 1 对应方向:up、posy

背面: 2 对应方向:north、negz

前面: 3 对应方向:south、posz、forward

右面: 4 对应方向:west、negx

左面: 5 对应方向:east、posx















