local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")

local BagLayer = class("BagLayer", require("app.views.View"))

function BagLayer:create()

    local baglayer = BagLayer:new()
    baglayer:init()

    return baglayer

end

function BagLayer:init()
    
    self.csb = self:createResoueceNode("csb/Package_Layer.csb"):getChildByName("root")
    self.csb:setPosition(display.center)
    local closebtn = self.csb:getChildByName("closebtn")
    local leftpanel = self.csb:getChildByName("leftpanel")
    local rightpanel = self.csb:getChildByName("rightpanel")
    
    local icon = leftpanel:getChildByName("icon")
    self.ico = icon:getChildByName("ico")
    self.name = leftpanel:getChildByName("name")
    self.count = icon:getChildByName("innerframe"):getChildByName("count")
    self.detail = leftpanel:getChildByName("detail")
    local sellbtn = leftpanel:getChildByName("sellbtn")
    local usebtn = leftpanel:getChildByName("usebtn")
    
    local daojubtn = rightpanel:getChildByName("daoju")
    local cailiaobtn = rightpanel:getChildByName("cailiao")
    local qitabtn = rightpanel:getChildByName("qita")
    
    self.list = rightpanel:getChildByName("list")
    
    self.ico:setVisible(false)
    
    self.tabbtn = {
        [1] = daojubtn,
        [2] = cailiaobtn,
        [3] = qitabtn
    }
    self.curTab = -1
    self:switchTab(1)
    
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            if sender==daojubtn then
                self:switchTab(1)
            elseif sender==cailiaobtn then
                self:switchTab(2)
            elseif sender==qitabtn then
                self:switchTab(3)
            elseif sender==closebtn then
                self:removeFromParent()
            end
        end
    end
    closebtn:addTouchEventListener(onEventTouchButton)
    daojubtn:addTouchEventListener(onEventTouchButton)
    cailiaobtn:addTouchEventListener(onEventTouchButton)
    qitabtn:addTouchEventListener(onEventTouchButton)
    
    closebtn:setPressedActionEnabled(true)
    sellbtn:setPressedActionEnabled(true)
    usebtn:setPressedActionEnabled(true)
    
end

function BagLayer:onEnter()

    EventMgr:registListener(EventType.OnBagItemList, self, self.onBagItemList)
    EventMgr:registListener(EventType.OnBagItemChange, self, self.onBagItemChange)
    UserData.Bag:sendBagItemList()
    
end

function BagLayer:onExit()

    EventMgr:unregistListener(EventType.OnBagItemList, self, self.onBagItemList)
    EventMgr:unregistListener(EventType.OnBagItemChange, self, self.onBagItemChange)

end

function BagLayer:filterByType(type)
    
    if self.curTab==1 and type==1 then return true
    elseif self.curTab==2 and type==3 then return true
    elseif self.curTab==3 and (type==2 and type==4) then return true end
    
    return false
    
end

function BagLayer:onBagItemChange(event)
    
end

function BagLayer:onBagItemList(event)
    
    local list = self.list
    local size = list:getContentSize()
    local items = UserData.Bag.items
    if items==nil then
        return
    end
    
    list:removeAllItems()
    
    local function cellEvent(sender, eventType)
        if eventType == 2 then
            self:onCellClick(sender)
        end
    end
    
    local index = 0
    local cell = nil
    for key, value in pairs(items) do
        
        local itemdata = StaticData.Item[key]
        if itemdata and self:filterByType(itemdata.ItemType) then
            if cell==nil then
                cell = ccui.Layout:create()
                cell:setContentSize(cc.size(size.width, 100))
                list:pushBackCustomItem(cell)
            end
           
            local temp = ccui.ImageView:create("ui/public/public_other_07.png")
            temp:setTouchEnabled(true)
            temp:setAnchorPoint(cc.p(0,0))
            temp:setPosition(index%4*100, 0)
            cell:addChild(temp)
            temp.id = key
            
            local icon = ccui.ImageView:create(itemdata.ItemIcon)
            local s = temp:getContentSize()
            icon:setPosition(s.width/2,s.height/2)
            temp:addChild(icon)
            
            temp:addTouchEventListener(cellEvent)
            
            local label = cc.Label:createWithSystemFont(tostring(value.nNum),"Arial",20)
            temp:addChild(label)
            label:setPosition(20,0)
            
            index = index + 1
            if index%4==0 then
                cell = nil
            end
            
            if index==1 then
                self:onCellClick(temp)
            end
        end
        
    end
    
end

function BagLayer:switchTab(tab)

    if tab == nil or tab<1 or tab>3 then
        return
    end
    
    if self.curTab>=1 and self.curTab<=3 then
        self.tabbtn[self.curTab]:setHighlighted(false)
        self.tabbtn[self.curTab]:getChildByName("title"):setColor(cc.c3b(255,255,255))
    end
    
    self.tabbtn[tab]:setHighlighted(true)
    self.tabbtn[tab]:getChildByName("title"):setColor(cc.c3b(146,17,27))
    self.curTab = tab

    self:onBagItemList()

end


function BagLayer:onCellClick(sender)
    self.ico:setVisible(true)
    self.ico:setTexture(StaticData.Item[sender.id].ItemIcon)
    self.name:setString(StaticData.Item[sender.id].ItemName)
    self.count:setString(UserData.Bag.items[sender.id].nNum)
    self.detail:setString(StaticData.Item[sender.id].Comment)
end

return BagLayer