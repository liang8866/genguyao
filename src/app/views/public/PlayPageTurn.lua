local PlayPageTurn = class("PlayPageTurn", function()
    return cc.Layer:create()
end)

function PlayPageTurn:create(playString, event)
    local view = PlayPageTurn:new()
    view:init(playString, event)
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

function PlayPageTurn:ctor()

end

function PlayPageTurn:onEnter()

end

function PlayPageTurn:onExit()

end

function PlayPageTurn:init(playString, event)
    self.event = event
    self.timeOver = 0

    local visibleSize = cc.Director:getInstance():getVisibleSize()

    local page = string.split(playString, "|")
    self.pageNode = {}
    for i = #page, 1, -1 do
        local node = cc.CSLoader:createNode("csb/startOpLayer_" .. page[i] .. ".csb")
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setPosition(visibleSize.width / 2, visibleSize.height / 2)
        node:setTag(i)
        self:addChild(node)
        
        self.pageNode[i] = node
    end
    self.schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function(dt) 
            self.timeOver = self.timeOver + 1
            if self.timeOver == 120 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
            end
        end, 0 ,false)
    
    
    self.curOp = 1
    self.isTouch = false
    
    self:touchEvent()
    
end

function PlayPageTurn:touchEvent()
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)

    listener:registerScriptHandler(function(touch, event)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        end, cc.Handler.EVENT_TOUCH_MOVED)

    listener:registerScriptHandler(function(touch, event)
        if self.timeOver == 120 then
            self.timeOver = 0
--            local pageTurn = cc.PageTurn3D:create(1, cc.size(100, 100))
            local callBack = cc.CallFunc:create(function()
                self:removeChildByTag(self.curOp)
                if self.curOp == #self.pageNode then
                    local func = self.event
                    self:removeFromParent()
                    func()
                else
                    self.curOp = self.curOp + 1
                    self.schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
                        function(dt) 
                            self.timeOver = self.timeOver + 1
                            if self.timeOver == 120 then
                                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
                            end
                        end, 0 ,false)
                end
            end)
--            local seq = cc.Sequence:create(pageTurn, callBack)
            self.pageNode[self.curOp]:runAction(callBack)
        end
    end, cc.Handler.EVENT_TOUCH_ENDED)

    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
    
end

return PlayPageTurn