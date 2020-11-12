local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local AnimationManager = require("app.views.public.AnimationManager")

local TimeFormat = require("common.TimeFormat")

local TransportLayer = class("TransportLayer", function()
    return ccui.Layout:create()
end)

function TransportLayer:create()
    local view = TransportLayer.new()
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

function TransportLayer:ctor()
    self.CurModeIdx = 1                                                                                  --当前选定的是那个镖车
    self.isSelectAuto = true                                                                             --是否是选择的 道具不足的时候使用元宝
end

function TransportLayer:onEnter()
    EventMgr:registListener(EventType.OnTransportList, self, self.OnTransportList)                       -- 服务端向客户端返回押镖列表(包含玩家自身的信息）
    EventMgr:registListener(EventType.OnRefreshType, self, self.OnRefreshType)                           -- 服务返回镖车刷新请求
    EventMgr:registListener(EventType.OnStartTransport, self, self.OnStartTransport)                     -- 服务返回开始押镖
    EventMgr:registListener(EventType.OnEndTransport, self, self.OnEndTransport)                         -- 服务返回结束押镖请求
   

end

function TransportLayer:onExit()
    EventMgr:unregistListener(EventType.OnTransportList, self, self.OnTransportList)                     -- 服务端向客户端返回押镖列表(包含玩家自身的信息）
    EventMgr:unregistListener(EventType.OnRefreshType, self, self.OnRefreshType)                         -- 服务返回镖车刷新请求
    EventMgr:unregistListener(EventType.OnStartTransport, self, self.OnStartTransport)                   -- 服务返回开始押镖
    EventMgr:unregistListener(EventType.OnEndTransport, self, self.OnEndTransport)                       -- 服务返回结束押镖请求
    if self.myScheduleUpdateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.myScheduleUpdateId)
    end
end

--- 事件分发通知区域

-- 服务端向客户端返回押镖列表(包含玩家自身的信息)
function TransportLayer:OnTransportList(event) 
    if  self.whichPanel == 2 then
        --创建押镖车运行
        for key, itemTable in pairs(UserData.Transport.transportList) do
            if self:getIsExist(itemTable.nPlayerId) == false then
                self:createOneCarAction(itemTable,key)
            end
        end
    end
end

-- 服务返回镖车刷新请求
function TransportLayer:OnRefreshType(event) 
    local iTable = event._usedata   
    if iTable.byRes == 0 then                                                                            --0:成功,1:没有该道具,2:元宝不足，3：参数错误,4:镖车已经是最高级别
         
    elseif iTable.byRes == 1 then
        PublicTipLayer:setTextAction("没有押镖令")
    elseif iTable.byRes == 2 then
        PublicTipLayer:setTextAction("元宝不足")
    elseif iTable.byRes == 3 then
        PublicTipLayer:setTextAction("参数错误")
    elseif iTable.byRes == 4 then
        PublicTipLayer:setTextAction("镖车已经是最高级别")
    end
    self:changePosForSelectEffect()
    if UserData.Transport.mySelectCarIdx >= 5 then      -- 说明已经是最高级了
        local trNode = self.panel1:getChildByTag(3000+UserData.Transport.mySelectCarIdx)
        if trNode and self.selectSpriteEf then
            local Button_call = trNode:getChildByName("Button_call") 
            self:setButtonGray(Button_call)
        end
        local Button_refresh = ccui.Helper:seekWidgetByName(self.panel_ui ,string.format("Button_refresh"))
        self:setButtonGray(Button_refresh)
    end
    
end

-- 服务返回开始押镖
function TransportLayer:OnStartTransport(event) 

    self:showPanel2()

end
-- 服务返回结束押镖请求
function TransportLayer:OnEndTransport(event) 

  local flg = UserData.Transport:checkMyIsInTransport()
    
    if flg == true then --说明在押镖
        self:showPanel2()
    else--不在押镖
        if UserData.Transport.myTransportResNum > 0 then

            self:showPanel1()
            self:setUiButtonAndText()
        else
            self:showPanel2()
        end
    end
   
 

end



--- UI系统区域

--初始化
function TransportLayer:init()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    local rootNode = cc.CSLoader:createNode("csb/transport_Layer.csb")
    self:addChild(rootNode)
    self.panel1 = rootNode:getChildByName("Panel_1")--获取panel1
    self.panel2 = rootNode:getChildByName("Panel_2")--获取panel2
    self.panel_ui = rootNode:getChildByName("Panel_ui")--获取panelui
    self.panel_smallbg = self.panel2:getChildByName("Panel_di")--获取有小地图的UI
    self.panel_smallbg:setPosition(display.center)
    local panel0 = rootNode:getChildByName("Panel_0")--Panel_0
    panel0:setPosition(display.center)
    self.nameTableBiaoche = {"白色货车","绿色货车","蓝色货车","紫色货车","橙色货车"}
    self.nameTableColor   = {cc.c3b(255,255,255),cc.c3b(125,255,125),cc.c3b(118,236,241),cc.c3b(147,105,242),cc.c3b(235,117,51)}
    
    self:showLayerUi()
   
    self.CarList = {} -- 一个记录有哪些在押镖的车的表
    self.myScheduleUpdateId = nil
    self.whichPanel = 1 -- panel1 = 1 panel2 =2
   
    local flg = UserData.Transport:checkMyIsInTransport()
    
    if flg == true then --说明在押镖
        self:showPanel2()
    else--不在押镖
        if UserData.Transport.myTransportResNum > 0 then
            self:showPanel1()
        else
            self:showPanel2()
        end
    end
   

    for key, var in pairs(UserData.Transport.transportList) do
        if var.nPlayerId == UserData.BaseInfo.userID then
            local distEndTime = TimeFormat:getSecondsInter(var.sStartTime)   --相差的时间
            if  distEndTime > UserData.Transport.myTransportTime then        -- 押镖时间已经过了
                UserData.Transport:sendServerEndTransport()
            end
            break
        end
    end

end
--设置灰色
function TransportLayer:setButtonGray(btn)
    btn:setTouchEnabled(false)
    btn:setColor(cc.c3b(130,130,130))

end
--设置还原
function TransportLayer:setButtonNormal(btn)
    btn:setTouchEnabled(true)
    btn:setColor(cc.c3b(255,255,255))

end


--显示UI层
function TransportLayer:showLayerUi()
    self.panel_ui:setPosition(display.center)
    local Panel_down_bg = ccui.Helper:seekWidgetByName(self.panel_ui ,"Panel_down_bg")
  
    local Button_back = ccui.Helper:seekWidgetByName(self.panel_ui ,string.format("Button_back"))
   -- Button_back:setPositionY(Panel_down_bg:getPositionY() + display.height/2 - 576/2)
    --刷新按钮
    local Button_refresh = ccui.Helper:seekWidgetByName(self.panel_ui ,string.format("Button_refresh"))
    --开始按钮
    local Button_start = ccui.Helper:seekWidgetByName(self.panel_ui ,string.format("Button_start"))
    --按钮回调事件
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            if sender == Button_back then  --返回
                self:removeFromParent()
            elseif sender == Button_refresh then --刷新
                if self.isSelectAuto then --不够押镖令的时候自动使用元宝
                    if UserData.Bag:searchObjectOnBag(UserData.Transport.myTransportIconId) > 0 then -- 押镖领拥有
                        UserData.Transport:sendServerRefreshType(0) --刷新类型0:使用道具刷新,1:使用10元宝,2:直接刷新为高级镖车
                    else -- 没有押镖令，直接使用元宝
                        if UserData.BaseInfo.userIngot >= UserData.Transport.myNeedIngot then
                            UserData.Transport:sendServerRefreshType(1) --刷新类型0:使用道具刷新,1:使用10元宝,2:直接刷新为高级镖车
                        else
                            PublicTipLayer:setTextAction("元宝不足")
                     	end
                    end
                else -- 不够押镖令的时候不使用元宝
                	if UserData.Bag:searchObjectOnBag(UserData.Transport.myTransportIconId) > 0 then -- 押镖领拥有
                        UserData.Transport:sendServerRefreshType(0) --刷新类型0:使用道具刷新,1:使用10元宝,2:直接刷新为高级镖车
                    else
                        PublicTipLayer:setTextAction("你的押镖令不足")
                    end
                end
            elseif sender == Button_start then --开始
                UserData.Transport:sendServerStartTransport()--发送请求
            end
        end
    end
    
    --绑定事件
    Button_back:addTouchEventListener(onEventTouchButton)
    Button_back:setPressedActionEnabled(true)
    Button_refresh:addTouchEventListener(onEventTouchButton)
    Button_refresh:setPressedActionEnabled(true)
    Button_start:addTouchEventListener(onEventTouchButton)
    Button_start:setPressedActionEnabled(true) 
    --品质最高级的时候了
    if UserData.Transport.mySelectCarIdx >= 5 then 
        self:setButtonGray(Button_refresh)
    end
    -- 自动选择的checkBox
    local checkBox = ccui.Helper:seekWidgetByName(self.panel_ui ,string.format("CheckBox_1"))
    local function selectedEvent(sender,eventType)
       
        if eventType == 0 then     -- 选中
            self.isSelectAuto = true
        elseif eventType == 1 then  -- 未选中
            self.isSelectAuto = false
        end
    end  
    checkBox:addEventListener(selectedEvent)  
    
    -- 设置剩余的押镖次数
    local Text_rest_num = ccui.Helper:seekWidgetByName(self.panel_ui ,"Text_rest_num")
    Text_rest_num:setString(UserData.Transport.myTransportResNum)
    
    --设置当前押镖的镖车名字
    self.Text_cur_fag = ccui.Helper:seekWidgetByName(self.panel_ui ,"Text_cur_fag")
    self.Text_cur_fag:setString(self.nameTableBiaoche[UserData.Transport.mySelectCarIdx])
    self.Text_cur_fag:setColor(self.nameTableColor[UserData.Transport.mySelectCarIdx])
    if UserData.Transport.myTransportResNum == 0 then
        self.Text_cur_fag:setString("无")
    end
    
end

--深圳UI层上的按钮等状态的
function TransportLayer:setUiButtonAndText()
    local Button_refresh = ccui.Helper:seekWidgetByName(self.panel_ui ,string.format("Button_refresh"))
    local Button_start = ccui.Helper:seekWidgetByName(self.panel_ui ,string.format("Button_start"))
    
    
    local Text_rest_num = ccui.Helper:seekWidgetByName(self.panel_ui ,"Text_rest_num")
    Text_rest_num:setString(UserData.Transport.myTransportResNum)
    
    if self.whichPanel == 1 then
        if UserData.Transport.myTransportResNum > 0 then
            self:setButtonNormal(Button_refresh)
            self:setButtonNormal(Button_start)
            self:changePosForSelectEffect()
    	end
    else
        self:setButtonGray(Button_refresh)
        self:setButtonGray(Button_start)
       
    end
end

--这个是选择押镖的马的
function TransportLayer:showPanel1()
    self.whichPanel = 1 -- panel1 = 1 panel2 =2
    if self.panel1 then
        self.panel1:setPosition(display.center)
    end
    if self.panel2 then
        self.panel2:setPositionX(-10000)
    end
    
    local len = 165
    local firstPosX = display.center.x - len * 3
	for i=1, 5 do
        self:createCarNodeForPanel1(cc.p(firstPosX +  len * i ,576/2 + 60),i)
	end
	
	-- 选择的背后的特效
    if self.selectSpriteEf then
		self.selectSpriteEf:removeFromParent()
	end
    self.selectSpriteEf = cc.Sprite:create()
    self.selectSpriteEf:setPosition(cc.p(firstPosX +  len  ,display.center.y - 40))
    local effect = AnimationManager:createEffect("effect/zhuangji_%d.png",5)
    local pea = cc.RepeatForever:create(effect)
    self.selectSpriteEf:runAction(pea)
    self.panel1:addChild(self.selectSpriteEf,-1)
    self:changePosForSelectEffect()
	
end

function TransportLayer:changePosForSelectEffect()
    --设置当前押镖的镖车名字
    self.Text_cur_fag:setString(self.nameTableBiaoche[UserData.Transport.mySelectCarIdx])
    self.Text_cur_fag:setColor(self.nameTableColor[UserData.Transport.mySelectCarIdx])
    if UserData.Transport.myTransportResNum == 0 then
    	self.Text_cur_fag:setString("无")
    end
    local trNode = self.panel1:getChildByTag(3000+UserData.Transport.mySelectCarIdx)
    if trNode and self.selectSpriteEf then
		self.selectSpriteEf:setPosition(trNode:getPosition())
	end
end


--查询是否存在了的
function TransportLayer:getIsExist(nId)
    local flag = false
    for key, var in pairs(self.CarList) do
        if var.nPlayerId == nId then
            flag = true
            break
        end
    end
    return flag
end


--这个是显示正在押镖的页面的
function TransportLayer:showPanel2()
    if self.myScheduleUpdateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.myScheduleUpdateId)
    end
    
    self.panel1:setPositionX(-10000)
    self.panel2:setPosition(display.center)
    self.whichPanel = 2 -- panel1 = 1 panel2 =2
    
    self:setUiButtonAndText()
        
    --创建押镖车运行
    for key, itemTable in pairs(UserData.Transport.transportList) do
        if self:getIsExist(itemTable.nPlayerId) == false then
            self:createOneCarAction(itemTable,key)
        end
    end
    
    -- 定义一个定时器
    local function myupdate(dt)
        if  self.whichPanel == 2 then
            UserData.Transport:sendServerTransportList()
        end
       
    end   
    self.myScheduleUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(myupdate, 1 ,false)
  
    
end




--创建选择镖车的节点
function TransportLayer:createCarNodeForPanel1(vPos,nIdx)

    local temp = self.panel1:getChildByTag(3000 +nIdx)
    if temp then
    	return
    end
   
    local transportNode = cc.CSLoader:createNode("csb/transport_Node.csb")
    transportNode:setPosition(vPos)
    self.panel1:addChild(transportNode)
    transportNode:setTag(3000+nIdx)
	
	
    -- 召唤最后一辆车的
   local function onEventTouchCallCar(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            if UserData.Transport.mySelectCarIdx < 5 then
                UserData.Transport:sendServerRefreshType(2)--直接成为最高级
            else
                PublicTipLayer:setTextAction("镖车已经是最高级别")
            end
        end
    end

    local Image_bg =  transportNode:getChildByName("Image_bg") 
    local Image_zi =  transportNode:getChildByName("Image_zi") 
    Image_bg:loadTexture(string.format("ui/transport/yabiao_diban_%02d.png",nIdx))
    Image_zi:loadTexture( string.format("ui/transport/yabiao_zi_%02d.png",nIdx))
  

    local Text_money_num = transportNode:getChildByName("Text_money_num") 
    local Text_exp_num = transportNode:getChildByName("Text_exp_num")  
    Text_money_num:setString(1000+nIdx *200)
    Text_exp_num:setString(2000+nIdx *321)
    if nIdx == 5 then --第五个显示召唤
        local Button_call = transportNode:getChildByName("Button_call") 
        Button_call:setVisible(true)
        Button_call:setTouchEnabled(true)
        Button_call:addTouchEventListener(onEventTouchCallCar)
        Button_call:setPressedActionEnabled(true) 
        if UserData.Transport.mySelectCarIdx >= 5  then
        	 Button_call:setColor(cc.c3b(130,130,130))
            Button_call:setTouchEnabled(false)
        end
    end 
    
	
end


--创建一个移动的押镖车
function TransportLayer:createOneCarAction(itemTable,idx)
 
    local distEndTime = TimeFormat:getSecondsInter(itemTable.sStartTime) --相差的时间
   
    if distEndTime < UserData.Transport.myTransportTime and distEndTime >= 0 and itemTable.sStartTime ~= "0000-00-00 00:00:00" then --如果返回不等于0,而且小于规定的时间的话
    
        -- 获取整个屏幕的长度
        local wholeLen = 880
        local nPID =  distEndTime / UserData.Transport.myTransportTime
        local actionCar = cc.CSLoader:createNode("csb/transport_actionCar_Node.csb")
        self.panel_smallbg:addChild(actionCar,1)

        local nameText =  actionCar:getChildByName("Text_name")
        nameText:setString(itemTable.nPlayerName)
         
        
        actionCar.nPlayerId = itemTable.nPlayerId
        table.insert(self.CarList,actionCar)
        --删除
        local function  callbackDel(sender)
            -- 如果是自己
            if sender.nPlayerId == UserData.BaseInfo.userID then
            	UserData.Transport:sendServerEndTransport() --请求结束
            end
            for key, var in pairs(self.CarList) do
                if sender == var then
                    table.remove(self.CarList,key)
        		end
        	end
            self.panel_smallbg:removeChild(sender)
        end
        
        
        local posX = nPID * wholeLen
        local posY = (idx % 3) *112 + 56
        local nNeedTime = UserData.Transport.myTransportTime *( 1- nPID)
        local nNeedLen = wholeLen *( 1- nPID)
        actionCar:setPosition(cc.p(posX - 40,posY))
        
        local biaoche = cc.Sprite:create()
        biaoche:setPosition(cc.p(0,0))
        local effect = AnimationManager:createEffect("animation/ma/biaoche_%d.png",20)
        local pea = cc.RepeatForever:create(effect)
        biaoche:runAction(pea)
        actionCar:addChild(biaoche)
        
        local moveby = cc.MoveBy:create(nNeedTime,cc.p(nNeedLen,0))
        local callback = cc.CallFunc:create(callbackDel)
        local seq = cc.Sequence:create(moveby,callback)
        actionCar:runAction(seq)
        
    end



end









return TransportLayer