

local Macros = {}


Macros.visibleSize = function()
    return cc.Director:getInstance():getVisibleSize()
end     
Macros.origin = function()
    return cc.Director:getInstance():getVisibleOrigin()
end
    
-- 游戏原始设计分辨率
Macros.gameWidth = 1024
Macros.gameHeight = 576

--弹出窗口的分类
Macros.masklayer_LOADING = 1
Macros.masklayer_DIALOG = 2


-- 触摸事件分发优先级
Macros.touchEvents = {
   TOUCH_EVENT_PRIORITY1 = 1,
   TOUCH_EVENT_PRIORITY0 = 0,
   TOUCH_EVENT_PRIORITY_MASK =  -99,

} 
--显示优先级
Macros.zOrder = {               
    PUBLIC_TITLE = 10000,       --广播字幕
}

--商城
Macros.store = {  --0:服装店,1:神秘商店,2:珍宝阁,3:限时抢购       
    clothStore = 1,
    mysticStore = 2,
    treasureStore = 3, 
    rushbuyStore = 4, 
    MaxStore = 4
}

--res path
Macros.resPath = {}
Macros.resPath.mall = "res/ui/mall/"


return Macros



