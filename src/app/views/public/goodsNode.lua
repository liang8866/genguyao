local goodsNode = class("goodsNode", function()
    return cc.Node:create()
end)

function goodsNode:create(goodsId, goodsNum, isShowName)
    local view = goodsNode:new()
    view:init(goodsId, goodsNum, isShowName)
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

function goodsNode:ctor()

end

function goodsNode:onEnter()

end

function goodsNode:onExit()

end

function goodsNode:init(goodsId, goodsNum, isShowName)
    local csb = cc.CSLoader:createNode("csb/bagGoodsNode.csb")
    self:addChild(csb)
    if goodsId == nil then
        return
    end
    
    local panel = csb:getChildByName("Panel")
    self.goodsFrame = panel:getChildByName("goodsFrame")
    self.goodsBtn = panel:getChildByName("goodsBtn")
    self.goodsBtn:setTag(goodsId)
    self.goodsCountText = panel:getChildByName("goodsCountText")
    print(goodsId)
    self.goodsBtn:loadTextures(StaticData.Item[goodsId].ItemIcon, StaticData.Item[goodsId].ItemIcon, StaticData.Item[goodsId].ItemIcon)     -- 设置物品图标
    self.goodsBtn:setVisible(true)
    self.goodsFrame:setTexture(string.format("items/goods/GoodsFrame_%d.png", StaticData.Item[goodsId].Frame))                              -- 设置框图标
    if goodsNum ~= nil then
        self.goodsCountText:setString(goodsNum)
    end

    if (goodsId >= 750001 and goodsId <= 750034) or (goodsId >= 760001 and goodsId <= 760027) then
        self.fragmentIcon = panel:getChildByName("fragmentIcon")
        self.fragmentIcon:setVisible(true)
    end
    
    if isShowName == true then
        self.nameText = panel:getChildByName("nameText")
        self.nameText:setString(StaticData.Item[goodsId].ItemName)
    end
end

function goodsNode:btnEvent(touchEvent, press)
    self.goodsBtn:addTouchEventListener(touchEvent)
    self.goodsBtn:setTouchEnabled(true)
    if press == true then
        self.goodsBtn:setPressedActionEnabled(true)
    end
end

return goodsNode