local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")

local goodsNode = require("app.views.public.goodsNode")

local MyBagLayer = class("MyBagLayer", function()
    return cc.Layer:create()
end)

local listViewChildNode = {node_1 = {}, node_2 = {}, node_3 = {}}
local pageNode = {curNode_1 = 0, curNode_2 = 0, curNode_3 = 0}

function MyBagLayer:create()
    local view = MyBagLayer:new()
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

function MyBagLayer:ctor()

end

function MyBagLayer:onEnter()
    EventMgr:registListener(EventType.OnBagItemList, self, self.onBagItemList)
    EventMgr:registListener(EventType.OnBagItemChange, self, self.onBagItemChange)
end

function MyBagLayer:onExit()
    EventMgr:unregistListener(EventType.OnBagItemList, self, self.onBagItemList)
    EventMgr:unregistListener(EventType.OnBagItemChange, self, self.onBagItemChange)
    listViewChildNode = {node_1 = {}, node_2 = {}, node_3 = {}}
end

function MyBagLayer:init()
	local csb = cc.CSLoader:createNode("csb/Package_Layer.csb")
	self:addChild(csb)
	self:initListViewNode()
	self:initPageNumNode()
	
	local function onTouchEvent(sender, eventType) 
        if eventType == cc.EventCode.ENDED then
            if sender == self.propBtn then
                self:setButtonNormal(self.materialBtn)
                self:setButtonNormal(self.otherBtn)
                self.propTitle:setTexture("ui/bag/prop_2.png")
                self.materialTitle:setTexture("ui/bag/material_1.png")
                self.otherTitle:setTexture("ui/bag/other_1.png")
                self:setButtonGray(sender)
            elseif sender == self.materialBtn then
                self:setButtonNormal(self.propBtn)
                self:setButtonNormal(self.otherBtn)
                self.propTitle:setTexture("ui/bag/prop_1.png")
                self.materialTitle:setTexture("ui/bag/material_2.png")
                self.otherTitle:setTexture("ui/bag/other_1.png")
                self:setButtonGray(sender)
            elseif sender == self.otherBtn then
                self:setButtonNormal(self.propBtn)
                self:setButtonNormal(self.materialBtn)
                self.propTitle:setTexture("ui/bag/prop_1.png")
                self.materialTitle:setTexture("ui/bag/material_1.png")
                self.otherTitle:setTexture("ui/bag/other_2.png")
                self:setButtonGray(sender)
		    elseif sender == self.closeBtn then
                self:removeFromParent()
		    end
		end
	end
	
	local root = csb:getChildByName("root")
    local leftpanel = root:getChildByName("leftpanel")
    local rightpanel = root:getChildByName("rightpanel")
    
    self.closeBtn = root:getChildByName("closeBtn")                                     --获取关闭按钮
    self.closeBtn:addTouchEventListener(onTouchEvent)
    self.closeBtn:setPressedActionEnabled(true)
    
    self.showGoodsSprite = rightpanel:getChildByName("showGoodsSprite")                  --ico精灵
    self.showGoodsFrame = rightpanel:getChildByName("showGoodsFrame")                    --物品框
    self.nameText = rightpanel:getChildByName("nameText")                                --物品名称
    self.detailText = rightpanel:getChildByName("detailText")                            --物品介绍
    self.sellBtn = rightpanel:getChildByName("sellBtn")                                  --出售按钮
    self.useBtn = rightpanel:getChildByName("useBtn")                                    --使用按钮
    
    self.listView_1 = leftpanel:getChildByName("listView_1")                           --获取列表
    self.listView_2 = leftpanel:getChildByName("listView_2")
    self.listView_3 = leftpanel:getChildByName("listView_3")
    self.listViewPosition = {x = self.listView_1:getPositionX(), y = self.listView_1:getPositionY()}
    
    self.propBtn = rightpanel:getChildByName("propBtn")                                 --获取道具按钮
    self.propTitle = rightpanel:getChildByName("propTitle")
    self.materialBtn = rightpanel:getChildByName("materialBtn")                         --获取材料按钮
    self.materialTitle = rightpanel:getChildByName("materialTitle")
    self.otherBtn = rightpanel:getChildByName("otherBtn")                               --获取其它按钮
    self.otherTitle = rightpanel:getChildByName("otherTitle")
    
    self.propBtn:addTouchEventListener(onTouchEvent)
    self:setButtonGray(self.propBtn)
    self.propTitle:setTexture("ui/bag/prop_2.png")
    self.materialBtn:addTouchEventListener(onTouchEvent)
    self.otherBtn:addTouchEventListener(onTouchEvent)
    
    self:setListViewAttr(1)
    self:setListViewAttr(2)
    self:setListViewAttr(3)
    
    self:initlistView(1)
    self:initlistView(2)
    self:initlistView(3)

    -- 对字体进行描边
--    local Text_sell = self.sellBtn:getChildByName("Text_1")    
--    local Text_use = self.useBtn:getChildByName("Text_1")    
    
    local Text_sell = ccui.Helper:seekWidgetByName(rightpanel ,"sellText")
    local Text_use  = ccui.Helper:seekWidgetByName(rightpanel ,"useText")
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_sell)  
    outLineLable:setTexOutLine(Text_use)  
    
end

function MyBagLayer:setButtonGray(btn)
    btn:setTouchEnabled(false)
    btn:setBright(false)
    self:setListViewPosition(btn)
end
--设置还原
function MyBagLayer:setButtonNormal(btn)
    btn:setTouchEnabled(true)
    btn:setBright(true)
end

function MyBagLayer:initlistView(listViewNum)

    local function onTouchEvent(sender, eventType)
        if eventType == cc.EventCode.BEGAN then
            local itemId = sender:getTag()
            print(string.format("itemId is %d", itemId))
            self:initGoodsDetail(itemId)
            pageNode[string.format("curNode_%d", listViewNum)] = itemId
        end
    end
    
    local goodsCount = #listViewChildNode[string.format("node_%d", listViewNum)]
    local page = math.ceil(goodsCount / 25)
    if page > 5 then
        page = 5
    end
    
    for i = 1, page * 5 do
        local layoutNode = ccui.Layout:create()
        local childNode = listViewChildNode[string.format("node_%d", listViewNum)] 
        for j = 1, 4 do
            local bagGoodsNode = nil
            if childNode[(i - 1)*4 + j] ~= nil then
                local itemId = childNode[(i - 1)*4 + j]
                if UserData.Bag.items[itemId] > 0 then
                    bagGoodsNode = goodsNode:create(itemId, tostring(UserData.Bag.items[itemId]))
                    bagGoodsNode:btnEvent(onTouchEvent)
                end
--                self:setGoodsSpriteTexture(bagGoodsNode,childNode[(i - 1) + j], listViewNum)
            else
                bagGoodsNode = goodsNode:create()
            end
            if i == 1 and j == 1 and listViewNum == 1 then
                self:initGoodsDetail(pageNode.curNode_1)
            end
            bagGoodsNode:setPosition(cc.p((j-1) * 95, 0))
            layoutNode:addChild(bagGoodsNode)
        end
        layoutNode:setContentSize(cc.size(380,100))
        layoutNode:setTouchEnabled(false) 
        layoutNode:setAnchorPoint(0, 0)
        self[string.format("listView_%d", listViewNum)]:addChild(layoutNode)
    end
end

function MyBagLayer:setListViewAttr(listViewNum)
    self[string.format("listView_%d", listViewNum)]:setTouchEnabled(true)
    self[string.format("listView_%d", listViewNum)]:setBounceEnabled(true)
    self[string.format("listView_%d", listViewNum)]:setSwallowTouches(true)
    self[string.format("listView_%d", listViewNum)]:refreshView()
end

function MyBagLayer:setListViewPosition(btn)

    if btn == self.propBtn then
        self.listView_1:setPosition(self.listViewPosition.x, self.listViewPosition.y)
        self.listView_2:setPosition(1000, 1000)
        self.listView_3:setPosition(1000, 1000)
        self:initGoodsDetail(pageNode.curNode_1)
    elseif btn == self.materialBtn then
        self.listView_1:setPosition(1000, 1000)
        self.listView_2:setPosition(self.listViewPosition.x, self.listViewPosition.y)
        self.listView_3:setPosition(1000, 1000)
        self:initGoodsDetail(pageNode.curNode_2)
    elseif btn == self.otherBtn then
        self.listView_1:setPosition(1000, 1000)
        self.listView_2:setPosition(1000, 1000)
        self.listView_3:setPosition(self.listViewPosition.x, self.listViewPosition.y)
        self:initGoodsDetail(pageNode.curNode_3)
    end

end

function MyBagLayer:initListViewNode()
    for k, v in pairs(UserData.Bag.items) do
        if StaticData.Item[k].PageNum == 1 then
            table.insert(listViewChildNode.node_1, 1, k)
        elseif StaticData.Item[k].PageNum == 2 then
            table.insert(listViewChildNode.node_2, 1, k)
        elseif StaticData.Item[k].PageNum == 3 then
            table.insert(listViewChildNode.node_3, 1, k)
        end
        print(string.format("itemId is %d, nNum is %d", k, v))
    end
end
function MyBagLayer:initPageNumNode()
    if pageNode.curNode_1 == 0 then
        pageNode.curNode_1 = listViewChildNode.node_1[1]
    end
    if pageNode.curNode_2 == 0 then
        pageNode.curNode_2 = listViewChildNode.node_2[1]
    end
    if pageNode.curNode_3 == 0 then
        pageNode.curNode_3 = listViewChildNode.node_3[1]
    end
end

function MyBagLayer:setGoodsSpriteTexture(bagGoodsNode, itemId, listViewNum)
    local panel = bagGoodsNode:getChildByName("Panel")

    local goodsBtn = panel:getChildByName("goodsBtn")
    goodsBtn:loadTextures(StaticData.Item[itemId].ItemIcon, StaticData.Item[itemId].ItemIcon, StaticData.Item[itemId].ItemIcon)
    goodsBtn:setVisible(true)

    local goodsCountSprite = panel:getChildByName("goodsCountSprite")
    goodsCountSprite:setVisible(true)

    local goodsCountText = panel:getChildByName("goodsCountText")
    goodsCountText:setString(tostring(UserData.Bag.items[itemId]))

    local function onTouchEvent(sender, eventType)
        if eventType == cc.EventCode.BEGAN then
            print(string.format("itemId is %d", itemId))
            self:initGoodsDetail(itemId)
            pageNode[string.format("curNode_%d", listViewNum)] = itemId
        end
    end
    goodsBtn:addTouchEventListener(onTouchEvent)
end

function MyBagLayer:initGoodsDetail(goodsId)
    if StaticData.Item[goodsId] ~= nil then
        self.showGoodsSprite:setTexture(StaticData.Item[goodsId].ItemIcon)
        self.showGoodsSprite:setVisible(true)
        self.showGoodsFrame:setTexture(string.format("items/goods/GoodsFrame_%d.png", StaticData.Item[goodsId].Frame))
        self.nameText:setString(StaticData.Item[goodsId].ItemName)
        self.detailText:setString(StaticData.Item[goodsId].Comment)
    else
        print("StaticData.Item[goodsId] is nil")
        self.showGoodsSprite:setVisible(false)
        self.showGoodsFrame:setTexture("items/goods/GoodsFrame_0.png")
        self.nameText:setString("")
        self.detailText:setString("")
    end
end

function MyBagLayer:onBagItemChange(event)

end

function MyBagLayer:onBagItemList(event)
    print("onBagItemList")
end

return MyBagLayer