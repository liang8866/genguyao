 local YesCancelLayer = class("YesCancelLayer", function()
	return ccui.Layout:create()
end)

function YesCancelLayer:create(title,yescallback,cancelcallback)
    local view = YesCancelLayer.new()
    view:init(title,yescallback,cancelcallback)
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

function YesCancelLayer:ctor()
    self.root = nil
	self.title = nil
	self.content = nil
    self.yescallback = nil
    self.cancelcallback = nil
end

function YesCancelLayer:onEnter()

end

function YesCancelLayer:onExit()

end

function YesCancelLayer:init(title,yescallback,cancelcallback)
	local csbYesCancel = cc.CSLoader:createNode("csb/public_yescancel_layer.csb")
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    csbYesCancel:setAnchorPoint(cc.p(0.5,0.5))
    csbYesCancel:setPosition(visibleSize.width/2,visibleSize.height/2)
    self:addChild(csbYesCancel)
    self.root = csbYesCancel:getChildByName("Panel_root")
    self.title = ccui.Helper:seekWidgetByName(self.root,"Text_title")
   
    self.content = ccui.Helper:seekWidgetByName(self.root,"Text_content")
    self.content:setString(title)
    self.yescallback = yescallback
    self.cancelcallback = cancelcallback
    local btnYes = ccui.Helper:seekWidgetByName(self.root,"Button_yes")
    btnYes:setPressedActionEnabled(true)
    btnYes:addTouchEventListener(function(sender,eventType) self:onEventYes(sender,eventType) end)
    local btnCancel = ccui.Helper:seekWidgetByName(self.root,"Button_cancel")
    btnCancel:setPressedActionEnabled(true)
    btnCancel:addTouchEventListener(function(sender,eventType) self:onEventCancel(sender,eventType) end)
    local function onTouchBegan(touch , event)
        return true
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    local curScene = cc.Director:getInstance():getRunningScene()
    curScene:addChild(self, 3000)
    
    -- 对字体进行描边
    local Text_yes = btnYes:getChildByName("Text_1")    
    local Text_cancel = btnCancel:getChildByName("Text_2")    
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    self.lable1 =  outLineLable:setTexOutLine(Text_yes)  
    self.lable2 =outLineLable:setTexOutLine(Text_cancel)  
end

function YesCancelLayer:onEventYes(sender,eventType)
    if eventType == cc.EventCode.ENDED then
        if self.yescallback then
            self.yescallback()
        end
        self:removeFromParent()
    end
end

function YesCancelLayer:onEventCancel(sender,eventType)
    if eventType == cc.EventCode.ENDED then
        if self.cancelcallback then
            self.cancelcallback()
        end
        self:removeFromParent()
    end
end


function YesCancelLayer:setButtonTitle(leftStr,rightStr) 
    local btnYes = ccui.Helper:seekWidgetByName(self.root,"Button_yes")
    local btnCancel = ccui.Helper:seekWidgetByName(self.root,"Button_cancel")

    local text1 = btnYes:getChildByName("Text_1")
    local text2 = btnCancel:getChildByName("Text_2")
    text1:setString(leftStr)
    text2:setString(rightStr)
    self.lable1:removeFromParent()
    self.lable2:removeFromParent()
    
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(text1)
    outLineLable:setTexOutLine(text2)

    
end


return YesCancelLayer