local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")

-- 升级
local LevelUpLayer = class("LevelUpLayer", function()
    return cc.Layer:create()
end)

function LevelUpLayer:create()
    local view = LevelUpLayer.new()
    view:init()
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            view:onEnter() 
        elseif eventType == "exit" then
            view:onExit() 
        end  
    end  
    view:registerScriptHandler(onEventHandler)
    return view
end

function LevelUpLayer:ctor()

end

function LevelUpLayer:onEnter()

end

function LevelUpLayer:onExit()

end

function LevelUpLayer:init()
    local csb = cc.CSLoader:createNode("csb/LevelUpLayer.csb")
    self:addChild(csb)
   
    
    local panel = csb:getChildByName("bgPanel")
    panel:setContentSize(cc.size(display.width, display.height +20))
   -- panel:setPositionY(panel:getPositionY() + (display.height - 576)/2)
    panel:setPositionY(display.height/2)
    local bgImage = panel:getChildByName("bgImage")
    
    self.proLevelText = bgImage:getChildByName("proLevelText")          -- 等级
    self.backLevelText = bgImage:getChildByName("backLevelText")
    self.proCurPhPewor = bgImage:getChildByName("proCurPhPewor")        -- 体力
    self.backCurPhPewor = bgImage:getChildByName("backCurPhPewor")
    self.proBestPhPewor = bgImage:getChildByName("proBestPhPewor")      -- 体力上限
    self.backBestPhPewor = bgImage:getChildByName("backBestPhPewor")
    
    self.proLevelText:setString(tostring(UserData.BaseInfo.userLevel - 1))
    self.backLevelText:setString(tostring(UserData.BaseInfo.userLevel))
    
    self.proCurPhPewor:setString(tostring(UserData.BaseInfo.nAction))
    self.backCurPhPewor:setString(tostring(UserData.BaseInfo.nAction + 6))
    
    self.proBestPhPewor:setString(tostring(acTionUpperBound(UserData.BaseInfo.userLevel - 1)))
    self.backBestPhPewor:setString(tostring(acTionUpperBound(UserData.BaseInfo.userLevel)))
    
    local function touchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            self:removeFromParent()
        end
    end
    self.btn = bgImage:getChildByName("btn")
    self.btn:setPressedActionEnabled(true)
    self.btn:addTouchEventListener(touchEvent)
    self.btn:setTouchEnabled(true)
    
--    -- 对字体进行描边
--    local Text_Sure = self.btn:getChildByName("Text_1")   
--    local outLineLable = require("app.views.public.outLineLable")
--    outLineLable:setTtfConfig(24,2)
--    outLineLable:setTexOutLine(Text_Sure)   
--    
    -- 添加背景触摸事件，方便取消整个layer
--    local listenner = cc.EventListenerTouchOneByOne:create()
--    listenner:setSwallowTouches(true)
--    listenner:registerScriptHandler(function(touch, event)
--            return true
--    end,cc.Handler.EVENT_TOUCH_BEGAN )
--
--    listenner:registerScriptHandler(function(touch, event)
--        --        do some thing here
--        self:removeFromParent()
--
--    end,cc.Handler.EVENT_TOUCH_ENDED )
--
--    local eventDispatcher = self:getEventDispatcher()
--    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, panel)

    local function createSpind()
        local SpineJson = "spine/ui/ui_shengji.json"
        local SpineAtlas = "spine/ui/ui_shengji.atlas"

        local spineNode = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        spineNode:setAnimation(0, "load", false)
        spineNode:setPosition(0,0)

        local function onSpineComplete()
            spineNode:setAnimation(0, "load_2", true)
        end

        spineNode:registerSpineEventHandler(onSpineComplete, 3)
        return spineNode
    end
    self.titleNode = panel:getChildByName("titleNode")
    local spineNode = createSpind()
    self.titleNode:addChild(spineNode)

    
end

function LevelUpLayer:onPropertyChange(event)
end


return LevelUpLayer