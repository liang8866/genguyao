
local MyApp = class("MyApp")

function MyApp:onCreate()
    math.randomseed(os.time())
end

function MyApp:ctor(configs)
    self.configs_ = {
        defaultSceneName = "app/views/Login/LoginLayer.lua",
    }

    for k, v in pairs(configs or {}) do
        self.configs_[k] = v
    end

    if type(self.configs_.viewsRoot) ~= "table" then
        self.configs_.viewsRoot = {self.configs_.viewsRoot}
    end
    if type(self.configs_.modelsRoot) ~= "table" then
        self.configs_.modelsRoot = {self.configs_.modelsRoot}
    end

    if DEBUG > 1 then
        dump(self.configs_, "MyApp configs")
    end

    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(false)
    end
    math.randomseed(os.time())  --随机种子
    -- event
    self:onCreate()
    
    --监听游戏退出事件
    if cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() then
        local isWaiting = false
        local function sceneEventReleased()  
            if isWaiting == false then
                local function onEventEixtGame()
                    cc.Director:getInstance():endToLua()
                end
                local function onEventCancel()
                    isWaiting = false
                end
                local YesCancelLayer = require("app/views/public/YesCancelLayer")
                YesCancelLayer:create("您确定退出游戏？",onEventEixtGame,onEventCancel)
                isWaiting = true 
            end

        end
        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(sceneEventReleased,cc.Handler.EVENT_KEYBOARD_RELEASED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener,-99)
    elseif cc.PLATFORM_OS_MAC == cc.Application:getInstance():getTargetPlatform() or 
        cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
        local function OnKeyPressed(keyCode,event)
            if cc.KeyCode["KEY_B"] == keyCode then
                cclog("KEY_B is Pressed")
--                local curScene = cc.Director:getInstance():getRunningScene()
--                local testNode = curScene:getChildByName("AllLayerShowForTest")
--                if testNode ~= nil then
--                    testNode:removeFromParent()
--                else
--                    local node  = require("app.views.public.AllLayerShowForTest"):create()
--                    curScene:addChild(node,999)
--                end
                
                
            end
        end
        local function OnKeyReleased(keyCode,event)
            if cc.KeyCode["KEY_B"] == keyCode then
                cclog("KEY_B is Released")
            end
        end
        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(OnKeyPressed,cc.Handler.EVENT_KEYBOARD_PRESSED)
        listener:registerScriptHandler(OnKeyReleased,cc.Handler.EVENT_KEYBOARD_RELEASED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener,-99)
    end
    
end

function MyApp:run(initSceneName)
    initSceneName = initSceneName or self.configs_.defaultSceneName
    self:enterScene(initSceneName)
end

function MyApp:enterScene(sceneName)
    local scene = cc.Scene:create()
    local view = self:createView(sceneName)
    scene:addChild(view)
    cc.Director:getInstance():replaceScene(scene)
end

function MyApp:createView(name)
    local view = require(name).new()
    return view
end

function MyApp:onCreate()
end

return MyApp
