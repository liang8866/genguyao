local myStartScene = class("myStartScene", function()
    return cc.Layer:create()
end)

function myStartScene:create(mapId)
    local view = myStartScene.new()
    view:init(mapId)
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

function myStartScene:onEnter()

end

function myStartScene:onExit()

end

function myStartScene:init()

    self.startOpLayer = {}
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    
    self.startOpLayer.startOpLayer_3 = cc.NodeGrid:create()
    self.startOpLayer.startOpLayer_3:setTag(3)
    self:addChild(self.startOpLayer.startOpLayer_3)
    self.startOpLayer.startOpLayer_3:setPosition(visibleSize.width / 2, visibleSize.height / 2)
    local node_3 = cc.CSLoader:createNode("csb/startOpLayer_3.csb")
    node_3:setAnchorPoint(cc.p(0.5, 0.5))
    self.startOpLayer.startOpLayer_3:addChild(node_3)
    self.startOpLayer.startOpLayer_3:setTag(3)
    
    self.startOpLayer.startOpLayer_2 = cc.NodeGrid:create()
    self:addChild(self.startOpLayer.startOpLayer_2)
    self.startOpLayer.startOpLayer_2:setPosition(visibleSize.width / 2, visibleSize.height / 2)
    local node_2 = cc.CSLoader:createNode("csb/startOpLayer_2.csb")
    node_2:setAnchorPoint(cc.p(0.5, 0.5))
    self.startOpLayer.startOpLayer_2:addChild(node_2)
    self.startOpLayer.startOpLayer_2:setTag(2)
    
    self.startOpLayer.startOpLayer_1 = cc.NodeGrid:create()
    self:addChild(self.startOpLayer.startOpLayer_1)
    self.startOpLayer.startOpLayer_1:setPosition(visibleSize.width / 2, visibleSize.height / 2)
    local node_1 = cc.CSLoader:createNode("csb/startOpLayer_1.csb")
    node_1:setAnchorPoint(cc.p(0.5, 0.5))
    self.startOpLayer.startOpLayer_1:addChild(node_1)
    self.startOpLayer.startOpLayer_1:setTag(1)
    
    self.curOp = 1
    self.isTouch = false
    
    self:touchEvent()
    
    cc.UserDefault:getInstance():setStringForKey("explore" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[1].ID, "")
    
    
end

function myStartScene:touchEvent()

    local function callback1()
        audio.stopMusic(false)
        local DataManager = require("app.views.public.DataManager")
        ManagerTask.SectionId = 1

        DataManager:setStringForKey("roleStayPointID","612001")
        DataManager:setIntegerForKey("roleStayWorldMapID",(611001))
        DataManager:setStringForKey("openedWorldMap","611001")
        
        
        local TownInterfaceLayer = require("app.views.StageMap.TownInterfaceLayer"):create()
        local SceneManager = require("app.views.SceneManager")
        SceneManager:addToGameScene(TownInterfaceLayer)
        local userdata = { currentTownID = "612001"}
        TownInterfaceLayer:initUI(userdata)

        cc.Director:getInstance():replaceScene(cc.TransitionFade:create(0.5, SceneManager:getGameSceneRoot(), cc.c3b(255,255,255)))

        local ManagerTask = require("app.views.Task.ManagerTask")
        local nextTaskId =  ManagerTask:getNextCanAcceptedMainTask()
        if nextTaskId > 0 then
            UserData.Task:sendAcceptTask(nextTaskId,1)
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    
    listener:registerScriptHandler(function(touch, event)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        end, cc.Handler.EVENT_TOUCH_MOVED)

    listener:registerScriptHandler(function(touch, event)
        if self.isTouch == false then
            self.isTouch = true
            local pageTurn = cc.PageTurn3D:create(1, cc.size(100, 100))
            local seq = nil
            local callBack = cc.CallFunc:create(function()
                self:removeChildByTag(self.curOp)
                if self.curOp == 3 then
                    self:removeFromParent()
                else
                    self.curOp = self.curOp + 1
                    self.isTouch = false
                end
            end)
            if self.curOp ~= 3 then
                seq = cc.Sequence:create(pageTurn, callBack)
            else
                seq = cc.Sequence:create(pageTurn, cc.CallFunc:create(callback1))
            end
            self.startOpLayer[string.format("startOpLayer_%d", self.curOp)]:runAction(seq)
        end
    end, cc.Handler.EVENT_TOUCH_ENDED)

    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

return myStartScene