local publicBusyLayer = class("publicBusyLayer", function()
    return ccui.Layout:create()
end)

function publicBusyLayer:create()
    local view = publicBusyLayer.new()
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

function publicBusyLayer:ctor()
   
end

function publicBusyLayer:onEnter()

end

function publicBusyLayer:onExit()

end

function publicBusyLayer:init()
    local busyLayer = cc.CSLoader:createNode("csb/public_busy_Layer.csb")
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    busyLayer:setAnchorPoint(cc.p(0.5,0.5))
    busyLayer:setPosition(display.center)
    self:addChild(busyLayer)
    local panel = busyLayer:getChildByName("Panel_1")
    local size = panel:getContentSize()
   
    local mSpineName = "spine/loading/ui_login"
    local SpineJson = mSpineName..".json"
    local SpineAtlas =mSpineName..".atlas"
   
    self.mySpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    self.mySpine:setAnimation(0, "load", true)
    self.state      = MyFightingConfig.ERoleState.Stand                      -- 一开始是load 状态的
    self.mySpine:setPosition(visibleSize.width/2,visibleSize.height/2)
    self:addChild(self.mySpine,5)
    

    local curScene = cc.Director:getInstance():getRunningScene()
    curScene:addChild(self)

end
function publicBusyLayer:deleteMyFromParent()
    local curScene = cc.Director:getInstance():getRunningScene()
    curScene:removeChild(self)


end

return publicBusyLayer