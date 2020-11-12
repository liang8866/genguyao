local NetMsgId = require("net.NetMsgId")
local Net = require("net.Net")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local UserData = require("user_data.UserData")
local StaticData = require("static_data.StaticData")
local publicTipLayer = require("app.views.public.publicTipLayer")


local ShopLayer = class("ShopLayer", function ()
    return cc.Layer:create()
end)


--state:SHOP,PAY
function ShopLayer:create(state)
    local view = ShopLayer.new()
    view:init(state)
    local function onNodeEvent(eventType)
        if eventType == "enter" then
            view:onEnter()
        elseif eventType == "exit" then
            view:onExit()
        end
    end
    view:registerScriptHandler(onNodeEvent)
    return view
end


function ShopLayer:ctor()
    self.preItemID = nil       --当前选择的物品ID
    
    self.TipObj = publicTipLayer:create() 
    self:addChild(self.TipObj, 99) 
end


function ShopLayer:onEnter()
    EventMgr:registListener(EventType.ReqBuyItem, self, self.ReqBuyItem)
    EventMgr:registListener(EventType.OnPropertyChange, self, self.OnPropertyChange)
    
end


function ShopLayer:onExit()
    EventMgr:unregistListener(EventType.ReqBuyItem, self, self.ReqBuyItem)
    EventMgr:unregistListener(EventType.OnPropertyChange, self, self.OnPropertyChange)
    
end


function ShopLayer:init(state)
    local shopLayer = cc.CSLoader:createNode("csb/shop_layer.csb")
    shopLayer:setAnchorPoint(cc.p(0.5,0.5))
    shopLayer:setPosition(display.center.x,display.center.y)
    self:addChild(shopLayer)
    self.rootPanel = shopLayer:getChildByName('Panel_root')
    
    self.widgetTable = {
        Button_back = ccui.Helper:seekWidgetByName(self.rootPanel ,"Button_back"),
        Image_tipIcon = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_tipIcon"),
        Panel_shoplayer = ccui.Helper:seekWidgetByName(self.rootPanel ,"Panel_shoplayer"),
        ListView_1 = ccui.Helper:seekWidgetByName(self.rootPanel ,"ListView_1"),
        Image_shopBtn = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_shopBtn"),
        Image_payBtn = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_payBtn"),
        Text_goldNum = ccui.Helper:seekWidgetByName(self.rootPanel ,"Text_goldNum"),
        Text_moneyNum = ccui.Helper:seekWidgetByName(self.rootPanel ,"Text_moneyNum"),
        ScrollView_1 = ccui.Helper:seekWidgetByName(self.rootPanel ,"ScrollView_1"),
        Text_itemName = ccui.Helper:seekWidgetByName(self.rootPanel ,"Text_itemName"),
        Text_itemPay = ccui.Helper:seekWidgetByName(self.rootPanel ,"Text_itemPay"),
        Image_goldOrMoney = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_goldOrMoney"),
        Text_itemDes = ccui.Helper:seekWidgetByName(self.rootPanel ,"Text_itemDes"),
        Button_pay = ccui.Helper:seekWidgetByName(self.rootPanel ,"Button_pay"),
        }
        
    self:initUIState(state)
    self:registerBtnFun()
end


--初始化UI
function ShopLayer:initUIState(state)
    self:switchState(state)
    self:loadShopItem()
    self:loadPayItem() 
    self.widgetTable.Text_goldNum:setString(UserData.BaseInfo.userIngot)
    self.widgetTable.Text_moneyNum:setString(UserData.BaseInfo.userGold)
end


--状态切换：商店，支付
function ShopLayer:switchState(state)
	if state == 'SHOP' then
        self.widgetTable.Image_tipIcon:loadTexture('ui/shop/shop_11.png')
        self.widgetTable.Panel_shoplayer:setVisible(true)
        self.widgetTable.ListView_1:setVisible(false)
        self.widgetTable.Image_shopBtn:loadTexture('ui/public/public_btn_08.png')
        self.widgetTable.Image_payBtn:loadTexture('ui/public/public_btn_07.png')
        self.widgetTable.ScrollView_1:jumpToTop() 
	elseif state == 'PAY' then
        self.widgetTable.Image_tipIcon:loadTexture('ui/shop/shop_10.png')
        self.widgetTable.Panel_shoplayer:setVisible(false)
        self.widgetTable.ListView_1:setVisible(true)
        self.widgetTable.Image_shopBtn:loadTexture('ui/public/public_btn_07.png')
        self.widgetTable.Image_payBtn:loadTexture('ui/public/public_btn_08.png')
        self.widgetTable.ListView_1:jumpToTop() 
	end
end


--注册按钮事件
function ShopLayer:registerBtnFun()
    self.widgetTable.Button_back:setPressedActionEnabled(true)
    self.widgetTable.Button_back:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self:removeFromParent()
            self = nil
        end
    end)
    
    self.widgetTable.Image_shopBtn:setTouchEnabled(true)
    self.widgetTable.Image_shopBtn:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self:switchState('SHOP')
        end
    end)
    
    self.widgetTable.Image_payBtn:setTouchEnabled(true)
    self.widgetTable.Image_payBtn:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then
            self:switchState('PAY')
        end 
    end)
end


--表排序
function ShopLayer:sortTable(tableMall, state)
    local temp = {}
    for key, var in pairs(tableMall) do
        table.insert(temp,var)	 
    end
    table.sort(temp, function (a,b)
        if state == 'SHOP' then
            return a.ItemId < b.ItemId
        end
        return a.RechargeRMB < b.RechargeRMB 
    end)   
    
    return temp
end


--加载商品
function ShopLayer:loadShopItem()
	self.widgetTable.ScrollView_1:removeAllChildren() 
    local mallTable = self:sortTable(StaticData.Mall, 'SHOP') 
    local inSizeHeight = 100 * math.ceil(#mallTable / 2)
    self.widgetTable.ScrollView_1:setInnerContainerSize(cc.size(435,inSizeHeight))
    self.preItemID = mallTable[1].ItemId
    for count, var in ipairs(mallTable) do
        local key =  var.ItemId
        local layout = ccui.Layout:create()
        local itemNode = cc.CSLoader:createNode("csb/shop_item_node.csb")
        local Image_root = itemNode:getChildByName('Image_root')
        layout:setContentSize(Image_root:getContentSize())
        layout:addChild(itemNode)
        self.widgetTable.ScrollView_1:addChild(layout)
        local row = math.ceil(count / 2)
        local col = (count % 2 == 0 and 2) or 1 
        layout:setPosition(5 + (col - 1) * 209, inSizeHeight - 95 - (row - 1) * 100)
        
        local Image_dazhe = ccui.Helper:seekWidgetByName(Image_root ,"Image_dazhe")
        local Text_itemName = ccui.Helper:seekWidgetByName(Image_root ,"Text_itemName")
        local Panel_dazheLayer = ccui.Helper:seekWidgetByName(Image_root ,"Panel_dazheLayer")
        local Image_IconDZ = ccui.Helper:seekWidgetByName(Image_root ,"Image_IconDZ")
        local Text_goldDZ = ccui.Helper:seekWidgetByName(Image_root ,"Text_goldDZ")
        local Image_IconYJ = ccui.Helper:seekWidgetByName(Image_root ,"Image_IconYJ")
        local Text_goldYJ = ccui.Helper:seekWidgetByName(Image_root ,"Text_goldYJ")
        local Text_dazheNum = ccui.Helper:seekWidgetByName(Image_root ,"Text_dazheNum")
        
        if StaticData.Mall[key].Discount == 0 then
            Panel_dazheLayer:setVisible(false)
            Image_dazhe:setVisible(false)
            Text_goldYJ:setString(StaticData.Mall[key].RealPrice)
        else
            Panel_dazheLayer:setVisible(true)
            Image_dazhe:setVisible(true)
            Text_goldDZ:setString(StaticData.Mall[key].ViewPrice)
            Text_goldYJ:setString(StaticData.Mall[key].RealPrice)
            Text_dazheNum:setString(StaticData.Mall[key].Discount .. '折')  
        end
        if StaticData.Mall[key].PriceType == 1 then
            Image_IconDZ:loadTexture('ui/public/public_other_27.png')
            Image_IconYJ:loadTexture('ui/public/public_other_27.png')
        else
            Image_IconDZ:loadTexture('ui/public/public_other_26.png')
            Image_IconYJ:loadTexture('ui/public/public_other_26.png')
        end
        local itemName = StaticData.Item[key].ItemName
        Text_itemName:setString(itemName)
        local itemDes = StaticData.Item[key].Comment
        if count == 1 then
            self.widgetTable.Text_itemName:setString(itemName)
            self.widgetTable.Text_itemDes:setString(itemDes)
            self.widgetTable.Text_itemPay:setString(StaticData.Mall[key].RealPrice)
            if StaticData.Mall[key].PriceType == 1 then
                self.widgetTable.Image_goldOrMoney:loadTexture('ui/public/public_other_27.png')
            else
                self.widgetTable.Image_goldOrMoney:loadTexture('ui/public/public_other_26.png')
            end
        end
        
        self:sangleItemClick(layout,key)
    end
    
    self.widgetTable.Button_pay:setPressedActionEnabled(true)
    self.widgetTable.Button_pay:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self:buyItemFunc()
        end
    end)
end


--物品单项点击
function ShopLayer:sangleItemClick(layout, key) 
    layout:setTouchEnabled(true)
    layout:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self.widgetTable.Text_itemName:setString(StaticData.Item[key].ItemName)
            self.widgetTable.Text_itemDes:setString(StaticData.Item[key].Comment)
            self.widgetTable.Text_itemPay:setString(StaticData.Mall[key].RealPrice)
            if StaticData.Mall[key].PriceType == 1 then
                self.widgetTable.Image_goldOrMoney:loadTexture('ui/public/public_other_27.png')
            else
                self.widgetTable.Image_goldOrMoney:loadTexture('ui/public/public_other_26.png')
            end
            
            self.preItemID = key
        end
    end)
end


--购买物品
function ShopLayer:buyItemFunc()
    self.buyItemNode = cc.CSLoader:createNode("csb/shop_buyItem_node.csb")
    self:addChild(self.buyItemNode)
    self.buyItemNode:setAnchorPoint(cc.p(0.5,0.5))
    self.buyItemNode:setPosition(display.center.x,display.center.y)
    local Panel_root = self.buyItemNode:getChildByName('Panel_root')
    local Button_back = ccui.Helper:seekWidgetByName(Panel_root ,"Button_back")
    local Text_itemName = ccui.Helper:seekWidgetByName(Panel_root ,"Text_itemName")
    local Text_singlePay = ccui.Helper:seekWidgetByName(Panel_root ,"Text_singlePay")
    local Text_allPay = ccui.Helper:seekWidgetByName(Panel_root ,"Text_allPay")
    local Image_payType1 = ccui.Helper:seekWidgetByName(Panel_root ,"Image_payType1")
    local Image_payType2 = ccui.Helper:seekWidgetByName(Panel_root ,"Image_payType2") 
    local Button_sub = ccui.Helper:seekWidgetByName(Panel_root ,"Button_sub") 
    local Text_buyNum = ccui.Helper:seekWidgetByName(Panel_root ,"Text_buyNum") 
    local Button_add = ccui.Helper:seekWidgetByName(Panel_root ,"Button_add") 
    local Button_yes = ccui.Helper:seekWidgetByName(Panel_root ,"Button_yes") 
    local Button_pay = ccui.Helper:seekWidgetByName(Panel_root ,"Button_pay") 
    local count = 1
    Text_buyNum:setString(count)
    Text_itemName:setString(StaticData.Item[self.preItemID].ItemName)
    Text_singlePay:setString(StaticData.Mall[self.preItemID].RealPrice)
    Text_allPay:setString(StaticData.Mall[self.preItemID].RealPrice * count) 
    if StaticData.Mall[self.preItemID].PriceType == 1 then
        Image_payType1:loadTexture('ui/public/public_other_27.png')
        Image_payType2:loadTexture('ui/public/public_other_27.png')
    else
        Image_payType1:loadTexture('ui/public/public_other_26.png')
        Image_payType2:loadTexture('ui/public/public_other_26.png')
    end
    
    Button_back:setPressedActionEnabled(true)
    Button_back:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self.buyItemNode:removeFromParent()
            self.buyItemNode = nil
        end
    end)
    
    Button_sub:setPressedActionEnabled(true)
    Button_sub:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            if count > 1 then
                count = count - 1
                Text_buyNum:setString(count)
                Text_allPay:setString(StaticData.Mall[self.preItemID].RealPrice * count) 
            end
        end
    end)
    
    Button_add:setPressedActionEnabled(true)
    Button_add:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            if count < 99 then
                count = count + 1
                Text_buyNum:setString(count)
                Text_allPay:setString(StaticData.Mall[self.preItemID].RealPrice * count)  
            end
        end
    end)
    
    Button_yes:setPressedActionEnabled(true)
    Button_yes:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            if UserData.BaseInfo.userVip < StaticData.Mall[self.preItemID].VipLevel then
                self.TipObj:setTextAction('VIP等级不够！')  
            elseif StaticData.Mall[self.preItemID].PriceType == 2 and UserData.BaseInfo.userGold < StaticData.Mall[self.preItemID].RealPrice * count then
                self.TipObj:setTextAction('金币不足！')  
            elseif StaticData.Mall[self.preItemID].PriceType == 1 and UserData.BaseInfo.userIngot < StaticData.Mall[self.preItemID].RealPrice * count then
                self.TipObj:setTextAction('元宝不足！')  
            else
                Net:sendMsgToSvr(NetMsgId.CL_SERVER_BUY_ITEM, "uiii", UserData.BaseInfo.userVeriCode, UserData.BaseInfo.userID, self.preItemID, count)
            end
        end
    end)
    
    Button_pay:setPressedActionEnabled(true)
    Button_pay:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self.buyItemNode:removeFromParent()
            self.buyItemNode = nil
            self:switchState('PAY')
        end
    end)
    
end


--加载支付UI
function ShopLayer:loadPayItem()
    self.widgetTable.ListView_1:removeAllChildren()   
    local rechargeTable = self:sortTable(StaticData.Recharge, 'PAY') 
    for key, var in ipairs(rechargeTable) do
        local layout = ccui.Layout:create()
        local shopPayNode = cc.CSLoader:createNode("csb/shop_pay_node.csb")
        local Panel_root = shopPayNode:getChildByName('Panel_root') 
        layout:setContentSize(Panel_root:getContentSize())
        layout:addChild(shopPayNode)
        self.widgetTable.ListView_1:pushBackCustomItem(layout)
        
        local Text_goldNum = ccui.Helper:seekWidgetByName(Panel_root ,"Text_goldNum") 
        local Text_payDes = ccui.Helper:seekWidgetByName(Panel_root ,"Text_payDes") 
        local Text_moneyNum = ccui.Helper:seekWidgetByName(Panel_root ,"Text_moneyNum") 
        local Button_pay = ccui.Helper:seekWidgetByName(Panel_root ,"Button_pay") 
        Text_goldNum:setString(var.Ingots .. '元宝')
        Text_payDes:setString(var.Comment)
        Text_moneyNum:setString('￥' .. var.RechargeRMB .. '元')
        
        Button_pay:setPressedActionEnabled(true)
        Button_pay:addTouchEventListener(function(sender,event)
            if event == cc.EventCode.ENDED then 
                self:postRechargeRequest(UserData.BaseInfo.userID,var.RechargeRMB)
            end
        end)
        
    end
end


--支付消息发送
function ShopLayer:postRechargeRequest(playID, payNum)
    --Post
    local ip = UserData.BaseInfo.userServAddrTable.NetAddr
    local port = UserData.BaseInfo.userServAddrTable.NetPort

    local xhr = cc.XMLHttpRequest:new()     
    xhr.responseType = 0   --返回字符串类型
    xhr:open("POST", 'http://192.168.0.78/payAction.php?userid=' .. playID .. '&rmb=' .. payNum .. '&serverhost=' .. ip .. '&serverport=' .. port)  

    local function onReadyStateChange()   
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            if tonumber(xhr.response) == 0 then
                self.TipObj:setTextAction('成功充值' .. payNum .. '元' )  
            else
                self.TipObj:setTextAction('充值失败')  
            end
            print(xhr.response)
        else
            self.TipObj:setTextAction('充值失败')
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)  
    xhr:send()  

end


-------------------------------------------------
--服务端返回
function ShopLayer:ReqBuyItem(event) 
    if event._usedata == 0 then
        self.buyItemNode:removeFromParent()
        self.buyItemNode = nil
        self.TipObj:setTextAction('购买物品成功！') 
    else
        self.TipObj:setTextAction('购买物品失败！')  
    end
	
end


function ShopLayer:OnPropertyChange(event)
    self.widgetTable.Text_goldNum:setString(UserData.BaseInfo.userIngot)
    self.widgetTable.Text_moneyNum:setString(UserData.BaseInfo.userGold)
end


return ShopLayer