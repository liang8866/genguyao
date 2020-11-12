
local AllLayerShowForTest = class("AllLayerShowForTest", function()
    return cc.Node:create()
end)

function AllLayerShowForTest:create()
    local node = AllLayerShowForTest.new()
    node:init()
--    local function onEventHandler(eventType)  
--        if eventType == "enter" then  
--            node:onEnter() 
--        elseif eventType == "exit" then
--            node:onExit() 
--        end  
--    end  
--    node:registerScriptHandler(onEventHandler)
    return node
end

function AllLayerShowForTest:ctor()

end

function AllLayerShowForTest:init()
    self:setName("AllLayerShowForTest")
    self:setPosition(display.center)
    local panel = ccui.Layout:create()
    panel:setContentSize(cc.size(display.width,display.height))
    panel:setBackGroundColor(cc.c3b(0,0,0))
    panel:setBackGroundColorType(1)
    panel:setBackGroundColorOpacity(192)
    
    panel:setTouchEnabled(false)
    
    panel:setPosition(display.center)
    panel:setAnchorPoint(cc.p(1,1))
    self:addChild(panel)
    
    local label = cc.Label:create()
    label:setColor(cc.c3b(165, 42, 42))
    label:setSystemFontSize(28)
    label:setAnchorPoint(cc.p(0.5,0.5))
    label:setPosition(display.center)
    panel:addChild(label)
    label:setString(self:getcurrentLayerInGameScene())
end

function AllLayerShowForTest:getcurrentLayerInGameScene()
    local SceneManager = require("app.views.SceneManager")
    local root =  SceneManager:getGameSceneRoot()
    local str = ""
    if root ~= nil then
        local children = root:getChildren()
        for i=1,#children do
            local child = children[i]
            local name = (child.__cname ~= nil and child.__cname ~= "") and child.__cname or child:getName()
            str = str .. string.format("%d,name=%s,localZorder=%d,worldZorder=%d\n",i,child.__cname,child:getLocalZOrder(),child:getGlobalZOrder())
        end
    end
    
    return str
end

return AllLayerShowForTest