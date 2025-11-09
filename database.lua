local component = require("component")
local config = require("config")

-- 缓存全局变量
local globalRedstoneSide = nil
local globalRedstoneProxy = nil
local reactorChambers = {}
-- 缓存组件代理
local componentCache = {}

local function getGlobalRedstoneSide()
    return globalRedstoneSide
end

-- 获取组件代理（带缓存）
local function getComponentProxy(address)
    if not componentCache[address] then
        componentCache[address] = component.proxy(address)
    end
    return componentCache[address]
end

-- 获取全局红石信号
local function getGlobalRedstone()
    if not globalRedstoneProxy then
        globalRedstoneProxy = getComponentProxy(config.globalRedstone)
    end
    
    if getGlobalRedstoneSide() ~= nil then
        return globalRedstoneProxy.getInput(getGlobalRedstoneSide()) > 0
    end
    
    local signal = globalRedstoneProxy.getInput()
    for side, num in pairs(signal) do
        if num > 0 then
            globalRedstoneSide = side
            return true
        end
    end
    return false
end


-- 验证和规范化反应堆配置
local function validateReactorConfig(config, index)
    local validated = {
        running = false,
        energy = config.energy ~= false,
        reactorChamberSideToRS = config.reactorChamberSideToRS or config.reactorChamberSide,
        name = config.name or config.reactorChamberAddr,
        aborted = false
    }
    
    -- 复制原始配置
    for k, v in pairs(config) do
        validated[k] = v
    end
    
    return validated
end

-- 硬件验证
local function validateHardware(reactorConfig)
    local requiredComponents = {
        reactorChamberAddr = "反应堆仓",
        switchRedstone = "红石开关",
        transforAddr = "转运器"
    }
    
    for componentField, componentName in pairs(requiredComponents) do
        local address = reactorConfig[componentField]
        if not address or not getComponentProxy(address) then
            print(string.format("警告: 配置 %s 的 %s 组件无效", reactorConfig.name, componentName))
            return false
        end
    end
    
    return true
end

local function scanAdaptor()
    local reactorChamberList = config.reactorChamberList
    print("读取到" .. #reactorChamberList .. "个核电配置")
    
    -- 清理旧数据
    for k in pairs(reactorChambers) do reactorChambers[k] = nil end
    componentCache = {}
    
    for i = 1, #reactorChamberList do
        local config = reactorChamberList[i]
        
        -- 验证硬件
        if not validateHardware(config) then
            print(string.format("跳过无效配置 %d: %s", i, config.name or "未命名"))
            goto continue
        end
        
        -- 验证和规范化配置
        reactorChambers[i] = validateReactorConfig(config, i)
        
        print(string.format("配置 %d 使用模式: %s 预热堆温: %s 电量控制: %s", 
            i, 
            reactorChambers[i].scheme, 
            reactorChambers[i].thresholdHeat or "无", 
            tostring(reactorChambers[i].energy)))
        
        ::continue::
    end
    
    print(string.format("成功加载 %d 个有效反应堆配置", #reactorChambers))
end

-- 清理缓存
local function clearCache()
    componentCache = {}
    globalRedstoneProxy = nil
    globalRedstoneSide = nil
end

-- 获取反应堆状态统计
local function getReactorStats()
    local stats = {
        total = #reactorChambers,
        running = 0,
        aborted = 0,
        withEnergyControl = 0
    }
    
    for _, reactor in ipairs(reactorChambers) do
        -- 正在运行的数量
        if reactor.running then
            stats.running = stats.running + 1
        end
        -- 因为温度过热而停机的数量
        if reactor.aborted then
            stats.aborted = stats.aborted + 1
        end
        -- 开启了电量控制的数量
        if reactor.energy then
            stats.withEnergyControl = stats.withEnergyControl + 1
        end
    end
    
    return stats
end

return {
    scanAdaptor = scanAdaptor,
    reactorChambers = reactorChambers,
    getGlobalRedstone = getGlobalRedstone,
    getComponentProxy = getComponentProxy,
    clearCache = clearCache,
    getReactorStats = getReactorStats
}
