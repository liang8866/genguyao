
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local publicTipLayer = require("app.views.public.publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")

local ShaderEffect = require("src.app.views.public.ShaderEffect")
local MyBagLayer = require("app.views.Bag.MyBagLayer")
local FlyMainUILayer = require("app.views.FlyTechTree.FlyMainUILayer")

local MainUILayer = class("MainUILayer", function()
    return cc.Node:create()
end)

function MainUILayer:ctor()
end

function MainUILayer:create()
    local node = MainUILayer.new()
    node:init()
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            node:onEnter() 
        elseif eventType == "exit" then
            node:onExit() 
        end  
    end  
    node:registerScriptHandler(onEventHandler)
    return node
end


function MainUILayer:onEnter()

    EventMgr:registListener(EventType.OnBuyAction, self, self.onBuyAction)                          -- 购买体力
    EventMgr:registListener(EventType.OnGetActionBag, self, self.onGetActionBag)                    -- 领取体力包
    EventMgr:registListener(EventType.OnPropertyChange, self, self.refreshTopUI)                    -- 刷新ui
    EventMgr:registListener(EventType.OnTransportList, self, self.OnTransportList)                  -- 服务端向客户端返回押镖列表(包含玩家自身的信息）

end

function MainUILayer:onExit()

    EventMgr:unregistListener(EventType.OnBuyAction, self, self.onBuyAction)
    EventMgr:unregistListener(EventType.OnGetActionBag, self, self.onGetActionBag)
    EventMgr:unregistListener(EventType.OnPropertyChange, self, self.refreshTopUI)
    EventMgr:unregistListener(EventType.OnTransportList, self, self.OnTransportList)                 -- 服务端向客户端返回押镖列表(包含玩家自身的信息）

end

function MainUILayer:init()

    self.uiLayer_RootNode    = cc.CSLoader:createNode("csb/main_ui_Layer.csb")
    self.uiLayer_RootNode:setAnchorPoint(cc.p(0.5,0.5))
    self.uiLayer_RootNode:setPosition(display.center)
    self:addChild(self.uiLayer_RootNode)
    
    local ProjectNode_topBar = self.uiLayer_RootNode:getChildByName("ProjectNode_topBar")
    self.topBar = require("app.views.public.topBar"):create()
    ProjectNode_topBar:addChild(self.topBar)
    self.topBar:refreshTopUI()

    self.actionState = 0        -- 0 今天未领取 1 午餐已领取 2 晚餐已领取
    
    local ProjectNode_bottomBar = self.uiLayer_RootNode:getChildByName("ProjectNode_bottomBar")
    self.bottomBar = require("app.views.Main.OperateUI"):create()
    ProjectNode_bottomBar:addChild(self.bottomBar)
    self.bottomBar:setPosition(cc.p(0,0))  
    
    ProjectNode_topBar:setPositionY(ProjectNode_topBar:getPositionY() + (display.height - 576)/2)
    ProjectNode_bottomBar:setPositionY(ProjectNode_bottomBar:getPositionY() - (display.height - 576)/2)
    
    
    self.tipsIsVisible = false
    self.publicTipLayer = publicTipLayer:create()
    self:addChild(self.publicTipLayer)
end


function MainUILayer:updateLogic()

    local baseInfo = UserData.BaseInfo
    local function update(dt)
        if baseInfo.h>=12 and baseInfo.h<14 and self.actionState==0 then
            self.getActionBtn:setVisible(true)
            self.getActionBtn:setTitleText("午餐时间到了")
        elseif baseInfo.h>=18 and baseInfo.h<20 and self.actionState<2 then 
            self.getActionBtn:setVisible(true)
            self.getActionBtn:setTitleText("晚餐时间到了")
        else
            self.getActionBtn:setVisible(false)
        end

    end
    self.scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0 ,false)

end

-- 判断体力包领取状态
function MainUILayer:checkActionState()

    local baseInfo = UserData.BaseInfo
    local byear, bmonth, bday, bhour, bmin, bsec = require("common.TimeFormat"):getYMDHMS(baseInfo.sGetActionBag)
    local serverTime = baseInfo:getSeverTime()
    if byear==serverTime.year and bmonth==serverTime.month and bday==serverTime.day then
        if bhour>=12 and bhour<14 then
            self.actionState = 1
        elseif bhour>=18 and bhour<20 then
            self.actionState = 2
        else
            self.actionState = 0
        end
    end

end

-- 刷新顶部ui， 体力数量 金币数量等
function MainUILayer:refreshTopUI(event)
    self.topBar:refreshTopUI()

end

-- 购买体力结果
function MainUILayer:onBuyAction(event)

    local userdata = event._usedata
    if userdata == 0 then
        self.publicTipLayer:setTextAction("体力购买成功")
    elseif userdata == 1 then
        self.publicTipLayer:setTextAction("购买次数已达上限")
    elseif userdata == 2 then
        YesCancelLayer:create("元宝不足，是否充值")
    end

end

-- 获取体力包结果
function MainUILayer:onGetActionBag(event)

    local userdata = event._usedata
    if userdata == 0 then
        self.publicTipLayer:setTextAction("体力包领取成功")
    elseif userdata == 1 then
        self.publicTipLayer:setTextAction("未到领取时间")
    elseif userdata == 2 then
        self.publicTipLayer:setTextAction("体力包已领取过")
    end

end


-- 服务端向客户端返回押镖列表(包含玩家自身的信息)
function MainUILayer:OnTransportList(event) 
    --跳转界面
    local SceneManager = require("app.views.SceneManager")
    SceneManager:switch(SceneManager.SceneName.SCENE_TRANSPORT)

end



return MainUILayer