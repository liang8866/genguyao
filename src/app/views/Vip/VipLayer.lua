local NetMsgId = require("net.NetMsgId")
local Net = require("net.Net")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local UserData = require("user_data.UserData")
local StaticData = require("static_data.StaticData")
local publicTipLayer = require("app.views.public.publicTipLayer")
local ShaderEffect = require("app.views.public.ShaderEffect")

local VipLayer = class("VipLayer", function ()
    return cc.Layer:create()
end)

function VipLayer:create()
    local view = VipLayer.new()
    view:init()
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

function VipLayer:ctor()
    self.preSelectVipLev = UserData.BaseInfo.userVip
   
    self.TipObj = publicTipLayer:create() 
    self:addChild(self.TipObj, 99) 
end

function VipLayer:onEnter()
    EventMgr:registListener(EventType.OnPropertyChange, self, self.OnPropertyChange)
    EventMgr:registListener(EventType.ReqNoticeVipExpChange, self, self.ReqNoticeVipExpChange)
    EventMgr:registListener(EventType.ReqGetVipBag, self, self.ReqGetVipBag)
end

function VipLayer:onExit()
    EventMgr:unregistListener(EventType.OnPropertyChange, self, self.OnPropertyChange) 
    EventMgr:unregistListener(EventType.ReqNoticeVipExpChange, self, self.ReqNoticeVipExpChange)
    EventMgr:unregistListener(EventType.ReqGetVipBag, self, self.ReqGetVipBag)

end

function VipLayer:init()
    local vipLayer = cc.CSLoader:createNode("csb/vip_layer.csb")
    vipLayer:setAnchorPoint(cc.p(0.5,0.5))
    vipLayer:setPosition(display.center.x,display.center.y)
    self:addChild(vipLayer)
    self.rootPanel = vipLayer:getChildByName('Panel_root')

    self.widgetTable = {
        Button_back = ccui.Helper:seekWidgetByName(self.rootPanel ,"Button_back"),
        Button_pay = ccui.Helper:seekWidgetByName(self.rootPanel ,"Button_pay"),
        Panel_richText = ccui.Helper:seekWidgetByName(self.rootPanel ,"Panel_richText"),
        Text_preVIpLev = ccui.Helper:seekWidgetByName(self.rootPanel ,"Text_preVIpLev"),
        ListView_1 = ccui.Helper:seekWidgetByName(self.rootPanel ,"ListView_1"),
        Image_good1 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_good1"),
        Image_good2 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_good2"),
        Image_good3 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_good3"),
        Image_good4 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_good4"),
        Image_vipLight1 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vipLight1"),
        Image_vipLight2 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vipLight2"),
        Image_vipLight3 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vipLight3"),
        Image_vipLight4 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vipLight4"),
        Image_vipLight5 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vipLight5"),
        Image_vipLight6 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vipLight6"),
        Image_vipLight7 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vipLight7"),
        Image_vipLight8 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vipLight8"),
        Image_vipLight9 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vipLight9"),
        Image_vipLight10 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vipLight10"),
        Image_vip1 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vip1"),
        Image_vip2 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vip2"),
        Image_vip3 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vip3"),
        Image_vip4 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vip4"),
        Image_vip5 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vip5"),
        Image_vip6 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vip6"),
        Image_vip7 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vip7"),
        Image_vip8 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vip8"),
        Image_vip9 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vip9"),
        Image_vip10 = ccui.Helper:seekWidgetByName(self.rootPanel ,"Image_vip10"),
        PageView_1 = ccui.Helper:seekWidgetByName(self.rootPanel ,"PageView_1"),
        Button_linqu = ccui.Helper:seekWidgetByName(self.rootPanel ,"Button_linqu"),
        
    }

    self:initVipShowDes(UserData.BaseInfo.userVip)
    self:registerBtn()
end

--注册按钮响应事件
function VipLayer:registerBtn()
    self.widgetTable.Button_back:setPressedActionEnabled(true)
    self.widgetTable.Button_back:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            self:removeFromParent()
            self = nil
        end
    end)
    
    self.widgetTable.Button_pay:setPressedActionEnabled(true)
    self.widgetTable.Button_pay:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            local shoplayer = require("app.views.Shop.ShopLayer"):create('PAY')
            self:addChild(shoplayer)
        end
    end)
    
    for var=1, 10 do
        local vipBtn = 'Image_vip' .. var 
        self.widgetTable[vipBtn]:setTouchEnabled(true)
        self.widgetTable[vipBtn]:addTouchEventListener(function(sender,event)
            if event == cc.EventCode.ENDED then 
                self.preSelectVipLev = var
                self:switchVipShowDes(var) 
            end
        end)
    end
    
    self.widgetTable.Button_linqu:setPressedActionEnabled(true)
    self.widgetTable.Button_linqu:addTouchEventListener(function(sender,event)
        if event == cc.EventCode.ENDED then 
            Net:sendMsgToSvr(NetMsgId.CL_SERVER_GET_VIP_BAG, "uib", UserData.BaseInfo.userVeriCode, UserData.BaseInfo.userID, self.preSelectVipLev)
        end
    end)
    
end

--初始化VIP描述
function VipLayer:initVipShowDes(lev) 
    self:preVipTextDes(lev)
    self:switchVipShowDes(lev)
    
    self.widgetTable.PageView_1:setCustomScrollThreshold(0.3)
    if lev > 6 then
        self.widgetTable.PageView_1:scrollToPage(1)
    else
        self.widgetTable.PageView_1:scrollToPage(0)
    end
end

--切换VIP等级显示
function VipLayer:switchVipShowDes(lev)  
    self:switchLightLev(lev)
    self.widgetTable.Text_preVIpLev:setString('VIP' .. lev .. '特权')

    self.widgetTable.ListView_1:removeAllChildren()
    local label = cc.Label:create()
    label:setString(StaticData.vip[lev].PrivilegeComment)
    self.widgetTable.ListView_1:addChild(label)
    label:setColor(cc.c3b(165, 42, 42))
    label:setSystemFontSize(28)
    label:setPosition(160,160)

    local awardTable = self:splitString(StaticData.vip[lev].ViewItem)
    if #awardTable < 1 then
        self.widgetTable.Image_good1:setVisible(false)
        self.widgetTable.Image_good2:setVisible(false)
        self.widgetTable.Image_good3:setVisible(false)
        self.widgetTable.Image_good4:setVisible(false)
    else
        self.widgetTable.Image_good1:setVisible(true)
        self.widgetTable.Image_good2:setVisible(true)
        self.widgetTable.Image_good3:setVisible(true)
        self.widgetTable.Image_good4:setVisible(true)
        for key, var in ipairs(awardTable) do
            local path = StaticData.Item[var].ItemIcon
            local goods = 'Image_good' .. key
            self.widgetTable[goods]:loadTexture(path)
        end
    end

end

--VIP等级图标高亮
function VipLayer:switchLightLev(lev)
    local light = 'Image_vipLight' .. lev
	for var=1, 10 do
        light = 'Image_vipLight' .. var
        self.widgetTable[light]:setVisible(false)
		if lev == var then
            self.widgetTable[light]:setVisible(true)
		end
	end
	
    local isBool = self:isBagLinQu(self.preSelectVipLev)
    if self.preSelectVipLev > UserData.BaseInfo.userVip or isBool >= 1 then
        self.widgetTable.Button_linqu:setTouchEnabled(false)
        --self.widgetTable.Button_linqu:setColor(cc.c3b(192,192,192))
        ShaderEffect:setGrayAndChild(self.widgetTable.Button_linqu)
    else
        self.widgetTable.Button_linqu:setTouchEnabled(true)
        --self.widgetTable.Button_linqu:setColor(cc.c3b(255,255,255))
        ShaderEffect:setRemoveGrayAndChild(self.widgetTable.Button_linqu)
    end       
end

--礼包是否领取
function VipLayer:isBagLinQu(lev)
    local vipbag = UserData.BaseInfo.nVipBag
    local res = 0
    for i = 1,lev do
        res = vipbag % 10
        vipbag = vipbag / 10
    end
    return res  --0:没有领取 1：已经领取
end

--当前VIP描述
function VipLayer:preVipTextDes(vipLev)
    self.widgetTable.Panel_richText:removeAllChildren()
    local vipTable = StaticData.vip
    if vipLev < 10 then
        local vipDesTable1 = {
            '您当前为',
            'VIP' .. vipLev,
            '累积充值',
            UserData.BaseInfo.nVipExp / 10,
            '元，再充值',
            (vipTable[vipLev + 1].Ingots - UserData.BaseInfo.nVipExp) / 10,
            '元，'       
        }
        local vipDesTable2  = {
            '即可领取',
            'VIP' .. vipLev + 1 .. '大礼包'
        }
        local richText = ccui.RichText:create()
        richText:ignoreContentAdaptWithSize(false)  
        richText:setContentSize(cc.size(500,0))
        for key, var in ipairs(vipDesTable1) do
            local res = nil
            if key == 1 or key == 3 or key == 5 or key == 7 then
                res = ccui.RichElementText:create(key, cc.c3b(0, 255, 0), 255, var, '', 24) 
            elseif key == 2 or key == 4 then
                res = ccui.RichElementText:create(key, cc.c3b(219, 197, 34), 255, var, '', 24) 
            else
                res = ccui.RichElementText:create(key, cc.c3b(197, 13, 184), 255, var, '', 24) 
            end
            richText:pushBackElement(res)
        end
        self.widgetTable.Panel_richText:addChild(richText)
        richText:setPosition(280,65)

        local richText = ccui.RichText:create()
        richText:ignoreContentAdaptWithSize(false) 
        richText:setContentSize(cc.size(500,0)) 
        for key, var in ipairs(vipDesTable2) do
            local res = nil
            if key == 1 then
                res = ccui.RichElementText:create(key, cc.c3b(0, 255, 0), 255, var, '', 24)
            else
                res = ccui.RichElementText:create(key, cc.c3b(255, 0, 0), 255, var, '', 24)
            end
            richText:pushBackElement(res)
        end
        self.widgetTable.Panel_richText:addChild(richText)
        richText:setPosition(280,35)
    else
        local vipDesTable = {
            '您当前为',
            'VIP' .. vipLev,
            '累积充值',
            UserData.BaseInfo.nVipExp / 10,
            '元，已经满级'         
        }
        local richText = ccui.RichText:create()
        richText:ignoreContentAdaptWithSize(false) 
        richText:setContentSize(cc.size(500,0)) 
        for key, var in ipairs(vipDesTable) do
            local res = nil
            if key == 1 or key == 3 or key == 5 then
                res = ccui.RichElementText:create(key, cc.c3b(0, 255, 0), 255, var, '', 24)
            else
                res = ccui.RichElementText:create(key, cc.c3b(219, 197, 34), 255, var, '', 24) 
            end
            richText:pushBackElement(res)
        end
        self.widgetTable.Panel_richText:addChild(richText)
        richText:setPosition(280,45)
    end
end

--11001|11002|11003|11004
function VipLayer:splitString(str) 
    local srcLen = string.len(str)
    local temp = {}  
  
    local function splitFunc()
        local tag = nil
        local Id = nil
        if str ~= "" and str ~= nil then 
            tag =  string.find(str ,'|')
            if tag == nil then
                Id = tonumber(string.sub(str, 1, srcLen))
                str = nil
            else    
                Id = tonumber(string.sub(str, 1, tag - 1))
                str = string.sub(str, tag + 1, srcLen)
            end

            table.insert(temp,Id)

            splitFunc()
        end
    end
    splitFunc()

    return temp
end


------------------------------------------------
--服务端返回
function VipLayer:OnPropertyChange(event)
    if event._usedata == 6 then
        self.preSelectVipLev = UserData.BaseInfo.userVip
        self:initVipShowDes(UserData.BaseInfo.userVip)
    end
end


function VipLayer:ReqNoticeVipExpChange(event) 
    self.preSelectVipLev = UserData.BaseInfo.userVip
    self:initVipShowDes(UserData.BaseInfo.userVip)
end

function VipLayer:ReqGetVipBag(event)
    if event._usedata == 0 then
        self.widgetTable.Button_linqu:setTouchEnabled(false)
        --self.widgetTable.Button_linqu:setColor(cc.c3b(192,192,192))
        ShaderEffect:setGrayAndChild(self.widgetTable.Button_linqu)
        self.TipObj:setTextAction('VIP礼包领取成功！') 
    else
        self.TipObj:setTextAction('VIP礼包领取失败！') 
    end
end


return VipLayer