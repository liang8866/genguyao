local goodsNode = require("app.views.public.goodsNode")

local FlyMakeMatLayer = class("FlyMakeMatLayer", function()
    return cc.Layer:create()
end)

function FlyMakeMatLayer:create(goodsId, goodsCount)
    local view = FlyMakeMatLayer.new()
    view:init(goodsId, goodsCount)
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

function FlyMakeMatLayer:ctor()
    
end

function FlyMakeMatLayer:onEnter()
    
end

function FlyMakeMatLayer:onExit()

end

--初始化
function FlyMakeMatLayer:init(goodsId, goodsCount)

    local csb = cc.CSLoader:createNode("csb/Fly_makeMat_Layer.csb")
    self:addChild(csb)
    
    local panel = csb:getChildByName("Panel")
    local goodsFrame = panel:getChildByName("goodsFrame")
    local goods = goodsNode:create(goodsId, goodsCount)
    goodsFrame:addChild(goods)
    goods:setPosition(-47.5, -45)
    
    self.goodsNameText = panel:getChildByName("goodsNameText")               -- 物品名字
    self.introduceText = panel:getChildByName("introduceText")               -- 物品介绍
    self.sourceListView = panel:getChildByName("sourceListView")
    self.sourceListView:setTouchEnabled(true)
    self.sourceListView:setBounceEnabled(true)
    self.sourceListView:setSwallowTouches(true)
    self.sourceListView:refreshView()
    self.sourceListView:jumpToTop()
    
    self:setGoodsData(goodsId, goodsCount)
    self:TouchEvent()
    self:initListView(goodsId)
    
end

function FlyMakeMatLayer:initListView(goodsId)
    local dressStr = StaticData.Item[goodsId].GoodsDress
    local table = string.split(dressStr, "|")
    
    local function btnTouchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            local tag = sender:getTag()

            local dressStr = StaticData.Track[tag].Dress
            local StageMapLayer =  require("app.views.StageMap.StageMapLayer")
            local layer = StageMapLayer:create(tonumber(StaticData.Track[tag].BigMap))
            local SceneManager = require("app.views.SceneManager")
            SceneManager:removeChildLayer("StageMapLayer",true)
            SceneManager:addToGameScene(layer)
            
            local dressStr = StaticData.Track[tag].Dress
            local tableDre = string.split(dressStr, "|")
            local coor = string.split(tableDre[1], "*")
            local pos = cc.p(tonumber(coor[1]), tonumber(coor[2]))
            StageMapLayer:moveRoleToMapPoint(pos,tableDre[2])
        end
    end
    
    for i = 1, #table do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(320, 65))
        layout:setTouchEnabled(true)
        local csb = cc.CSLoader:createNode("csb/GoodsDressNode.csb")
        csb:setPosition(0, 0)
        layout:addChild(csb)
        self.sourceListView:addChild(layout)
        local panel = csb:getChildByName("Panel")
        local goodsDressText = panel:getChildByName("goodsDressText")
        local goBtn = panel:getChildByName("goBtn")
        goodsDressText:setString(StaticData.Track[tonumber(table[i])].Name)
        goBtn:addTouchEventListener(btnTouchEvent)
        goBtn:setPressedActionEnabled(true)
        goBtn:setTag(tonumber(table[i]))
    end
    
end

function FlyMakeMatLayer:setGoodsData(goodsId, goodsCount)

    local item = StaticData.Item

    self.goodsNameText:setString(item[goodsId].ItemName)
    self.introduceText:setString(item[goodsId].Comment)
end

function FlyMakeMatLayer:TouchEvent()

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    
    listener:registerScriptHandler(function(touch, event)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    
    listener:registerScriptHandler(function(touch, event)
        self:removeFromParent()
    end, cc.Handler.EVENT_TOUCH_ENDED)
    
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
    
end

return FlyMakeMatLayer