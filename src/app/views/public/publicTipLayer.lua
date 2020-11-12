local publicTipLayer = class("publicTipLayer", function()
    return ccui.Layout:create()
end)

publicTipTable = {}

function publicTipLayer:create()
    local view = publicTipLayer.new()
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

function publicTipLayer:ctor()
   
end

function publicTipLayer:onEnter()

end

function publicTipLayer:onExit()

end

function publicTipLayer:init()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
--    publicTipTable = {}
end

function publicTipLayer:mSetTipTextPos(pos)
    self.tipNode:setPosition(pos)
end

function publicTipLayer:mSetColor(color)
    self.ui_tipText:setTextColor(color)
end

function publicTipLayer:setTextAction(str)

    local image = ccui.ImageView:create()
    image:loadTexture("ui/public/tips.png") 
    table.insert(publicTipTable, 1, image)
    image:setScale9Enabled(true)
    
    local ttfConfig = {}
    ttfConfig.fontFilePath = "TTF/FZY3JW.TTF"
    ttfConfig.fontSize = 28
    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    ttfConfig.outlineSize = 0
   
    local alert = cc.Label:createWithTTF(ttfConfig,"Outline",cc.TEXT_ALIGNMENT_CENTER)
    alert:setString(str)
    alert:enableOutline(cc.c4b(255,0,0,255))
    alert.outlineSize = 8

--    alert:setFontSize(32)        
    alert:setColor(cc.c3b(255, 255, 255))
    local sizeAlert = alert:getContentSize()
    image:addChild(alert)

    local sizeImage = image:getContentSize()
--    local sizeImage = cc.size(sizeAlert.width + 50, sizeAlert.height + 5)
    local curScene = cc.Director:getInstance():getRunningScene()
--    image:setContentSize(sizeImage)
    alert:setPosition(sizeImage.width / 2, sizeImage.height / 2 - 2)
    curScene:addChild(image,100)
    for i = 1, #publicTipTable do
        publicTipTable[i]:setPosition(display.center.x,display.center.y/2 *3 + (i - 1) * (sizeImage.height + 5) + 3)
    end
    
    local function CallFucnCallback1() --回调，让字体隐藏不可见
        curScene:removeChild(image)
        table.remove(publicTipTable, #publicTipTable)
    end

    local t = 2.0
    local delay1 = cc.DelayTime:create(0.5)
    local delay2 = cc.DelayTime:create(0.5)
    
    local fadeTo1 = cc.FadeTo:create(t,0)
    local fadeTo2 = cc.FadeTo:create(t,0)
    
    local action1 = cc.Sequence:create(
        delay1,
        fadeTo1,
        cc.CallFunc:create(CallFucnCallback1) )
    local action2 = cc.Sequence:create(delay2, fadeTo2)
    alert:runAction(action2)
    image:runAction(action1)

    if str == "体力不足" then
        local function onYes()
            UserData.BaseInfo:sendBuyAction()
        end
        local YesCancelLayer = require("app.views.public.YesCancelLayer")
        YesCancelLayer:create(string.format("体力不足，是否花费 %d 元宝购买 20 点体力?", (UserData.BaseInfo.nBuyActionNum + 1) * 10), onYes)
    end
	
end


return publicTipLayer