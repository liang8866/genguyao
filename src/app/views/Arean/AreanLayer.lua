-- 卷选择界面
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local CopySectionLayer = require("app.views.Pve.CopySectionLayer")
local PublicTipLayer = require("app.views.public.publicTipLayer")
local TimeFormat = require("common.TimeFormat")
local YesCancelLayer = require("app.views.public.YesCancelLayer")

local AreanLayer = class("AreanLayer", require("app.views.View"))

function AreanLayer:onCreate()

    self.publicTipLayer = PublicTipLayer:create()
    self:addChild(self.publicTipLayer)

    local csb = self:createResoueceNode("csb/AreanLayer.csb")           --创建CSB
    local root = csb:getChildByName("root")
    root:setPosition(display.center)
    
    local topPanel = root:getChildByName("toppanel")                    -- 顶部面板
    local midPanel = root:getChildByName("midpanel")                    -- 中间面板
    self.bottomPanel = root:getChildByName("bottompanel")               -- 底部面板
    
    self.rankLabel = midPanel:getChildByName("ranklabel")               -- 我的排名
    self.remainLabel = self.bottomPanel:getChildByName("remaintimes")   -- 剩余次数
    self.goldLabel = topPanel:getChildByName("goldlabel")               -- 金币
    self.ingotLabel = topPanel:getChildByName("ingotlabel")             -- 元宝
    self.swLabel = topPanel:getChildByName("swlabel")                   -- 声望
    
    self.regularPanel = root:getChildByName("regularpanel")             -- 规则面板
    self.rankPanel = root:getChildByName("rankpanel")                   -- 排名面板
    
    local closebtn = topPanel:getChildByName("closebtn")                -- 关闭按钮
    local regularBtn = midPanel:getChildByName("regularbtn")            -- 规则按钮
    local rankBtn = midPanel:getChildByName("rankbtn")                  -- 排名按钮
    local recordBtn = midPanel:getChildByName("recordbtn")              -- 记录按钮
    local changeBtn = self.bottomPanel:getChildByName("changebtn")      -- 换一批按钮

    local function onButtonEvent(sender, eventType)
        if eventType==cc.EventCode.ENDED then
            if sender==closebtn then
                self:removeFromParent()
            elseif sender==regularBtn then
                self.regularPanel:setVisible(true)
            elseif sender==rankBtn then
                UserData.Arean:sendRequestAreanRankInfo()
                self.rankPanel:setVisible(true)
            elseif sender==recordBtn then
                UserData.Arean:sendRequestAreanRecord()
                self.rankPanel:setVisible(true)
            elseif sender==changeBtn then
                UserData.Arean:sendRequestAreanOpponent()
            end
        end
    end
    
    closebtn:addTouchEventListener(onButtonEvent)
    regularBtn:addTouchEventListener(onButtonEvent)
    rankBtn:addTouchEventListener(onButtonEvent)
    recordBtn:addTouchEventListener(onButtonEvent)
    changeBtn:addTouchEventListener(onButtonEvent)
    
    changeBtn:setPressedActionEnabled(true)

    self:handleRankPanel()
    self:handleRegularPanel()
    self:handBottomPanel()

    UserData.Arean:sendRequestAreanOpponent()
    self:OnAreanSelfInfoBack()
    self:refreshTopUI()

end

--进入
function AreanLayer:onEnter()

    EventMgr:registListener(EventType.OnAreanOpponentList, self, self.OnAreanOpponentList)
    EventMgr:registListener(EventType.OnAreanRankList, self, self.OnAreanRankList)
    EventMgr:registListener(EventType.OnAreanSelfInfoBack, self, self.OnAreanSelfInfoBack)
    EventMgr:registListener(EventType.OnPropertyChange, self, self.refreshTopUI)    
    EventMgr:registListener(EventType.OnAreanRecord, self, self.OnAreanRecord)  
    EventMgr:registListener(EventType.OnAreanBuyBack, self, self.OnAreanBuyBack)     
    

end

--退出
function AreanLayer:onExit()

    print("ccccccccccccccccc")
    EventMgr:unregistListener(EventType.OnAreanOpponentList, self, self.OnAreanOpponentList)
    EventMgr:unregistListener(EventType.OnAreanRankList, self, self.OnAreanRankList)
    EventMgr:unregistListener(EventType.OnAreanSelfInfoBack, self, self.OnAreanSelfInfoBack)
    EventMgr:unregistListener(EventType.OnPropertyChange, self, self.refreshTopUI)
    EventMgr:unregistListener(EventType.OnAreanRecord, self, self.OnAreanRecord)  
    EventMgr:unregistListener(EventType.OnAreanBuyBack, self, self.OnAreanBuyBack)   
    
end

function AreanLayer:OnAreanSelfInfoBack(event)
    
    local userdata = UserData.Arean.selfInfo
    self.rankLabel:setString("我的排名: " .. tostring(userdata.rank))
    self.remainLabel:setString(tostring(userdata.times) .. "/10")
    
end

-- 竞技场排名
function AreanLayer:OnAreanRankList(event)

    local userdata = event._usedata
    local length = userdata.length
    
    local rankPanel = self.rankPanel
    rankPanel:getChildByName("title"):setString("排行榜")
    local list = rankPanel:getChildByName("list")
    list:removeAllItems()
    local item = self.rankPanel:getChildByName("item")
    list:setItemModel(item)
    
    for i=1, length do
        list:pushBackDefaultItem()
        local value = userdata[i]
        local item = list:getItem(i-1)
        item:setVisible(true)
        item:getChildByName("rank"):setString(tostring(value.rank))
        item:getChildByName("lv"):setString(tostring(value.level))
        item:getChildByName("name"):setString(value.name)
    end

end

function AreanLayer:getTime(time)

    local second = TimeFormat:getSecondsInter(time)
    local minute = 60
    local hour = minute * 60
    local day = hour * 24
    local month = day * 30 
    local year = month * 12
    
    local str = ""
    local tmp = 0
    tmp = math.floor(second/year)
    if tmp>=1 then
        str = tostring(tmp) .. "年前"
        return str
    end
    
    tmp = math.floor(second/month)
    if tmp>=1 then
        str = tostring(tmp) .. "月前"
        return str
    end
    
    tmp = math.floor(second/day)
    if tmp>=1 then
        str = tostring(tmp) .. "天前"
        return str
    end
    
    tmp = math.floor(second/hour)
    if tmp>=1 then
        str = tostring(tmp) .. "小时钟前"
        return str
    end
    
    tmp = math.floor(second/minute)
    if tmp>=1 then
        str = tostring(tmp) .. "分钟前"    
        return str
    end
    
    str = tostring(second) .. "秒前"
    
    return str
    
end

-- 竞技场记录
function AreanLayer:OnAreanRecord(event)

    local userdata = event._usedata
    local length = userdata.length
    
    local rankPanel = self.rankPanel
    rankPanel:getChildByName("title"):setString("记录")
    local list = rankPanel:getChildByName("list")
    list:removeAllItems()
    local item = self.rankPanel:getChildByName("item1")
    list:setItemModel(item)
    
    for i=1, length do
        list:pushBackDefaultItem()
        local value = userdata[i]
        local item = list:getItem(i-1)
        item:setVisible(true)
        item:getChildByName("lv"):setString(tostring(value.level))
        
        
        if value.result==0 or value.result==2 then
            item:getChildByName("result"):setString("战胜")
        else
            item:getChildByName("result"):setString("战败")
        end
        
        if value.result==0 or value.result==1 then
            item:getChildByName("name"):setString("你")
            item:getChildByName("info"):setString(self:getTime(value.time) .. "挑战了" .. value.name)
        else
            item:getChildByName("name"):setString(value.name)
            item:getChildByName("info"):setString(self:getTime(value.time) .. "挑战了你")
        end
        
        
        if value.rank>=0 then
            item:getChildByName("arrow"):loadTexture("ui/arean/rank/arean_rank_up.png")
        else
            item:getChildByName("arrow"):loadTexture("ui/arean/rank/arean_rank_down.png")
        end
        item:getChildByName("ranknum"):setString(value.rank)
        
    end
    
end

-- 竞技场对手列表
function AreanLayer:OnAreanOpponentList(event)
    
    local userdata = event._usedata
    local length = userdata.length
    
    local bottomPanel = self.bottomPanel
    for i=1, 3 do
        local item = bottomPanel:getChildByName("panel" .. tostring(i))
        if i<= length then
            local value = userdata[i]
            item:setVisible(true)
            item:getChildByName("rank"):setString(tostring(value.rank))
            item:getChildByName("info"):setString(value.name)
            item:getChildByName("power"):setString(value.fighting)
            item:getChildByName("icon"):getChildByName("lv"):setString(value.level)
        else
            item:setVisible(false)
        end
    end
    
end

-- 竞技场购买记过
function AreanLayer:OnAreanBuyBack(event)
    
    local userdata = event._usedata
    if userdata.result==0 then
        self.publicTipLayer:setTextAction("购买成功")
    else
        self.publicTipLayer:setTextAction("购买失败")
    end
    
end

-- 规则面板
function AreanLayer:handleRegularPanel()
    
    local regularPanel = self.regularPanel
    local closeBtn = regularPanel:getChildByName("closebtn")
    
    local function onCloseEvent(sender, eventType)
        if eventType==cc.EventCode.ENDED then
            regularPanel:setVisible(false)
        end
    end
    closeBtn:addTouchEventListener(onCloseEvent)
end

-- 排名面板
function AreanLayer:handleRankPanel()
    
    local rankPanel = self.rankPanel
    local closeBtn = rankPanel:getChildByName("closebtn")
    local list = rankPanel:getChildByName("list")
    local item = rankPanel:getChildByName("item")
    list:setItemModel(item)
    
    local function onCloseEvent(sender, eventType)
        if eventType==cc.EventCode.ENDED then
            rankPanel:setVisible(false)
        end
    end 
    closeBtn:addTouchEventListener(onCloseEvent)
    
end

-- 底部面板
function AreanLayer:handBottomPanel()

    local function onChallegeBtnEvent(sender, eventType)
        if eventType==cc.EventCode.ENDED then
            if UserData.Arean.selfInfo.times>0 then
                local index = sender:getTag()
                local playerId = UserData.Arean.opponentList[index].playerId
                local BattleLayer = require("app.views.Battle.BattleLayer")
                local battlelayer = BattleLayer:new()
                self:addChild(battlelayer)
                battlelayer:pvp(playerId)
                UserData.Arean:sendRequestAreanOpponent()
            else
--                self.publicTipLayer:setTextAction("今日剩余次数不足！")
                local function onYes()
                    UserData.Arean:sendRequestAreanBuyCount()
                end
                YesCancelLayer:create("剩余次数不足，您确定购买次数吗?", onYes)
            end
        end
    end
    
    local bottomPanel = self.bottomPanel
    for i=1, 3 do
        local panel = bottomPanel:getChildByName("panel" .. tostring(i))
        local challegeBtn = panel:getChildByName("challegebtn")
        challegeBtn:setTag(i)
        challegeBtn:addTouchEventListener(onChallegeBtnEvent)
    end
    
end

-- 刷新顶部ui， 体力数量 金币数量等
function AreanLayer:refreshTopUI()

    self.goldLabel:setString(tostring(UserData.BaseInfo.userGold))
    self.ingotLabel:setString(tostring(UserData.BaseInfo.userIngot))
    self.swLabel:setString(tostring(UserData.BaseInfo.nReputation))

end

return AreanLayer