
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local ManegerTask = require("app.views.Task.ManagerTask")
local FlyMakeMatLayer = require("app.views.public.FlyMakeMatLayer")
local goodsNode = require("app.views.public.goodsNode")


local MyFightingOver = class("MyFightingOver", function()
    return ccui.Layout:create()
end)

function MyFightingOver:create(result)
    local view = MyFightingOver.new()
    view:init(result)
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

function MyFightingOver:ctor()

end

function MyFightingOver:onEnter()
    EventMgr:registListener(EventType.OnGetNoticePrize, self, self.onGetNoticePrize)
end

function MyFightingOver:onExit()
    EventMgr:unregistListener(EventType.OnGetNoticePrize, self, self.onGetNoticePrize)
end

function MyFightingOver:init(result)
    local csbGameOver = cc.CSLoader:createNode("csb/MyFightingOver.csb")
    self:addChild(csbGameOver)
--    csbGameOver:setPositionY(csbGameOver:getPositionY() + (display.height - 576)/2)
    self.bgPanel = csbGameOver:getChildByName("bgPanel")
    self.bgPanel:setContentSize(cc.size(display.width, display.height))
   -- self.bgPanel:setPositionY(self.bgPanel:getPositionY() + (display.height - 576)/2)
    self.bgPanel:setPositionY(display.height /2)
    self.bgImage = self.bgPanel:getChildByName("bgImage")
    self.overTitle = self.bgImage:getChildByName("overTitle")
    self.ListView_FailToGo = self.bgImage:getChildByName("ListView_FailToGo")
    self.ListView_FailToGo:setVisible(false)
    self.ListView_FailToGo:setTouchEnabled(false)
    
    if UserData.BaseInfo.myFightTaskId == UserData.NewHandLead.GuideList.Fighting_2.TaskID then
        UserData.NewHandLead:CompleteGuide(UserData.NewHandLead.GuideList.Fighting_2.Name)
    elseif UserData.BaseInfo.myFightTaskId == UserData.NewHandLead.GuideList.Fighting_1.TaskID then
        UserData.NewHandLead:CompleteGuide(UserData.NewHandLead.GuideList.Fighting_1.Name)
    elseif UserData.BaseInfo.myFightTaskId == UserData.NewHandLead.GuideList.FightingWithGodwill.TaskID then 
        UserData.NewHandLead:CompleteGuide(UserData.NewHandLead.GuideList.FightingWithGodwill.Name)
    end
    
    local function createSpind(strName)
        local SpineJson = "spine/ui/ui_" .. strName .. ".json"
        local SpineAtlas = "spine/ui/ui_" .. strName .. ".atlas"

        local skeletonNode = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        skeletonNode:setAnimation(0, "load", false)
        skeletonNode:setPosition(0,0)
        
        local function onSpineComplete()
            skeletonNode:setAnimation(0, "load_2", true)
        end
        
        skeletonNode:registerSpineEventHandler(onSpineComplete, 3)
        return skeletonNode
    end
    
    if result == 1 then --赢了
    	UserData.Battle:sendOnFightPrize(UserData.BaseInfo.NPCId)
        local spindNode = createSpind("fightwin")
        self.overTitle:addChild(spindNode)
    elseif result <= 0 then --输了
        local spindNode = createSpind("fightlose")
        self.overTitle:addChild(spindNode)
    end
    local myFightTaskID = UserData.BaseInfo.myFightTaskId
    --返回到副本选择
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local fightingLayer = self:getParent()
            audio.stopMusic(false)
            self:removeFromParent()
            fightingLayer:removeFromParent()
            local SceneManager = require("app.views.SceneManager")
            if result <= 0 or myFightTaskID <= 0 then -- 失败或非任务的战斗
                --cclog("sssss")
            else  --打赢了
                if myFightTaskID > 0 then
                    cclog("myFightTaskID = " .. tostring(myFightTaskID))
                    local taskType = ManagerTask:getTaskType(myFightTaskID)
                    print(myFightTaskID .. "......................")
                    local taskInfo = UserData.Task.acceptedTaskList[taskType]
                    
                    local firstKill = tonumber(taskInfo[4]) > tonumber(taskInfo[5]) and tonumber(taskInfo[5]) == 1
                    local lastKill = tonumber(taskInfo[4]) == tonumber(taskInfo[5]) and tonumber(taskInfo[5]) > 0
                    local lastTalk = tonumber(StaticData.Task[myFightTaskID].LastTalk) 
                    if lastTalk ~= nil and lastTalk > 0 and lastKill then
                        ManagerTask.SectionId = lastTalk
                        local PlotLayer = require("app.views.Plot.PlotLayer")
                        PlotLayer:initPlotEnterAntExit(myFightTaskID)
                        SceneManager:switch(SceneManager.SceneName.SCENE_PLOT, 100)
                        
                    else
                        if StaticData.Task[myFightTaskID].CityType == 0 then
                            local StageMapLayer = require("app.views.StageMap.StageMapLayer")
                            StageMapLayer:checkFinishTask()
                        elseif StaticData.Task[myFightTaskID].CityType > 0 then  -- 城镇地图
                            local TownInterfaceLayer = require("app.views.StageMap.TownInterfaceLayer")
                            TownInterfaceLayer:checkFinishTask()
                        elseif StaticData.Task[myFightTaskID].CityType < 0 then  -- 探索地图
                            local TaskMessageBox =  require("app.views.Task.TaskMessageBox")
                            local layer = TaskMessageBox:create()
                            local SceneManager = require("app.views.SceneManager")
                            SceneManager:addToGameScene(layer, 40)
                            TaskMessageBox:ShowTaskFinishMessageBox(myFightTaskID)
                        end
                    end
                end
            end
        end
    end   
    
    local confirmButton = self.bgImage:getChildByName("confirmButton")
    confirmButton:addTouchEventListener(onEventTouchButton)
    confirmButton:setPressedActionEnabled(true)

    --如果赢了，调用任务管理器，看看是不是任务的战斗，好请求任务结果
    if result == 1 then
        ManagerTask:setTaskUpdate()
    else
   		self:ShowFailToGo()
    end
    
    -- 对字体进行描边
    local Text_Sure = confirmButton:getChildByName("Text_4")    
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_Sure)   
   
end


function MyFightingOver:ShowFailToGo()
	if self.ListView_FailToGo ~= nil then
        self.ListView_FailToGo:setVisible(true)
        local text = self.bgImage:getChildByName("loseText")
        text:setVisible(true)
        for i=1,3 do
            local btnBg = self.ListView_FailToGo:getChildByName(string.format("BtnBg_%d", i))
            local function onListItemClicked(sender,eventType)
                if eventType == cc.EventCode.ENDED then
                    local index = sender:getTag()
                    cclog("onListItemClicked index = " .. tostring(index))
                    
                    self:GotoStrengthUI(index)
                    local fightingLayer = self:getParent()
                    self:removeFromParent()
                    fightingLayer:removeFromParent()
                end
            end
            local btn = btnBg:getChildByName("btn")
            
            btn:setTouchEnabled(true)
            btn:addTouchEventListener(onListItemClicked)
        end
	end
    self.ListView_FailToGo:setVisible(true)
end

function MyFightingOver:onGetNoticePrize(event)
    local userdata = event._usedata
    
    --local awardListView = self.bgImage:getChildByName("awardListView")
    --local posX, posY = awardListView:getPosition()
    --local size = awardListView:getContentSize()
    
    self.awardListView = self.bgImage:getChildByName("awardListView") --ccui.ListView:create()
    --self.awardListView:setContentSize(size)
    --self.bgImage:addChild(self.awardListView)
    
    self.awardListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.awardListView:setDirection(2)
    --self.awardListView:setPosition(posX, posY)
    self.awardListView:setTouchEnabled(true)
    self.awardListView:setBounceEnabled(true)
    self.awardListView:setSwallowTouches(true)
    self.awardListView:refreshView()
    
    local ExpImage = self.bgImage:getChildByName("ExpImage")
    local goldImage = self.bgImage:getChildByName("goldImage")
    local text_Exp = ExpImage:getChildByName("text")
    local text_gold = goldImage:getChildByName("text")
    if userdata.Exp ~= nil and userdata.Exp ~= 0 then
        text_Exp:setString(tostring(userdata.Exp))
        ExpImage:setVisible(true)
    end
    if userdata.gold ~= nil and userdata.gold ~= 0 then
        text_gold:setString(tostring(userdata.gold))
        goldImage:setVisible(true)
    end
    
    local function touchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            print(sender:getTag())
            local goodsNum = UserData.Bag.items[sender:getTag()]
            local flyMakeMatLayer = FlyMakeMatLayer:create(sender:getTag())
            self:addChild(flyMakeMatLayer)
        end
    end
    
    for i = 1, #userdata.goods do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(105, 90))
        layout:setEnabled(true)
        
        local id = userdata.goods[i].Id
        local num = userdata.goods[i].num
        local prizeNode = goodsNode:create(id, num)
        prizeNode:btnEvent(touchEvent)
        
        layout:addChild(prizeNode)
        self.awardListView:addChild(layout)
    end

end

function MyFightingOver:GotoStrengthUI(index)
    
    local layer = nil
    if index == 1 then  -- 飞宝
        layer = require("app.views.FlyTechTree.FlyTechTreeLayer"):create()
    elseif index == 2 then -- 技能
        layer = require("app.views.FlyTechTree.FlySkillLayer"):create()
    elseif index == 3 then -- 神将
        layer = require("app.views.Godwill.GodwillListLayer"):create()
    elseif index == 4 then -- 背包
        layer = require("app.views.Bag.MyBagLayer"):create()
    end
    if layer ~= nil then
        local SceneManager = require("app.views.SceneManager")
        SceneManager:addToGameScene(layer,100)
    end
end


return MyFightingOver