
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local ManagerTask = require("app.views.Task.ManagerTask")


local taskListItemInfo = {}

local publicTips = nil
local TaskListNode = class("TaskListNode", function()
    return cc.Node:create()
end)

function TaskListNode:create()
    local node = TaskListNode.new()
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

function TaskListNode:ctor()
    taskListItemInfo = {}
end

function TaskListNode:onEnter()
end

function TaskListNode:onExit()
end

function TaskListNode:init()
    local node =  cc.CSLoader:createNode("csb/TaskListNode.csb")
    self:addChild(node)
    --node:setPosition(-200,0)
    node:setPosition(cc.p(1000,130))
    self.ListView_1 = node:getChildByName("ListView_1")
    self.ListView_1:jumpToTop()
    self.ListView_1:setItemsMargin(10)
    local publicTipLayer = require("app.views.public.publicTipLayer")
    publicTips = publicTipLayer:create()
    self:addChild(publicTips,100)
end

function TaskListNode:initUI(currentTownID,parent)
    taskListItemInfo = {}
--    local questIdListStr = StaticData.TownMap[currentTownID].QuestId
--    local questIdList = string.split(questIdListStr,"-")
--    for i = 1, #questIdList do
--        taskListItemInfo[i] = {}
--        taskListItemInfo[i].taskID = tonumber(questIdList[i])
--        
--    end
    
    local mainTaskId,branchTaskList,dayTaskList,roundTaskList = UserData.Task:getCanAcceptTaskIDListInTown(currentTownID)
    if mainTaskId > 0 then
	    taskListItemInfo[1] = {}
	    taskListItemInfo[1].taskID = tonumber(mainTaskId)
   	end
    for i=1,table.nums(branchTaskList) do
        local num = table.nums(taskListItemInfo) + 1
        taskListItemInfo[num] = {}
        taskListItemInfo[num].taskID = tonumber(branchTaskList[i])
    end
    for i=1,table.nums(dayTaskList) do
        local num = table.nums(taskListItemInfo) + 1
        taskListItemInfo[num] = {}
        taskListItemInfo[num].taskID = tonumber(dayTaskList[i])
    end
    for i=1,table.nums(roundTaskList) do
        local num = table.nums(taskListItemInfo) + 1
        taskListItemInfo[num] = {}
        taskListItemInfo[num].taskID = tonumber(roundTaskList[i])
    end

    self:initListView()  

    
--    local guideState = UserData.NewHandLead:getGuideState("ClickTaskNodeList")
--    if guideState == 0 then
--        local curTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
--        if curTaskID ~= nil and curTaskID > 0 and curTaskID == UserData.NewHandLead.GuideList.ClickTaskNodeList.TaskID then
--            local data = {name = "ClickTaskNodeList"}
--            UserData.NewHandLead:startNewGuide(data)
--        end
--    end
end




function TaskListNode:initListView()                                          --初始化列表
    for i = 1, #taskListItemInfo do
        self:createTaskItem(i)
    end
end


function TaskListNode:createTaskItem(index,isInsert)
    if taskListItemInfo[index] == nil then
        return
    end
    local taskID = taskListItemInfo[index].taskID
    local taskStaticInfo = StaticData.Task[taskID]
    if taskStaticInfo == nil then
        return
    end
    --ManagerTask
    local function onListItemClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            local taskID = sender:getTag()
            --            local taskType = ManagerTask:getTaskType(taskID)

            cclog("onListItemClicked taskID = " .. tostring(taskID))
            self:doTaskImmediately(taskID)

--            local guideState = UserData.NewHandLead:getGuideState("ClickTaskNodeList")
--            if guideState == 0 then
--                local curTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
--                if curTaskID ~= nil and curTaskID > 0 and curTaskID == UserData.NewHandLead.GuideList.ClickTaskNodeList.TaskID and curTaskID == taskID then
            --                    local SceneManager = require("app.views.SceneManager")
--                    SceneManager:removeChildLayer("NewHandLeadLayer")
--                end
--            end
            
        end
    end
    
    local ListView_width = self.ListView_1:getContentSize().width
    local Panel_item = ccui.Layout:create()
    Panel_item:setContentSize(cc.size(ListView_width, 102))
    Panel_item:setBackGroundColorType(0) -- ccui.LayoutBackGroundColorType.solid)
    --    Panel_item:setBackGroundColor(cc.c3b(128, 0+index*50, 128))
    --    Panel_item:setBackGroundColorOpacity(128)
    Panel_item:setAnchorPoint(cc.p(0,1))
    Panel_item:setBackGroundImage("ui/townInterface/tasklist_2.png")
    Panel_item:setTouchEnabled(true)
    Panel_item:setName("Panel_item_task_" .. tostring(taskID))
    Panel_item:setTag(tonumber(taskID))
    Panel_item:addTouchEventListener(onListItemClicked)
    taskListItemInfo[index].Panel_item = Panel_item

    local parentHeight = Panel_item:getContentSize().height

--    local titleLabel = ccui.Text:create()
--    titleLabel:setFontName("font/FangZhengJianYuan.ttf")
--    titleLabel:setFontSize(22)
--    titleLabel:setContentSize(cc.size(ListView_width,22))
--    titleLabel:setColor(cc.c3b(255, 255, 255))    
    --    titleLabel:setAnchorPoint(cc.p(0,1))
    --    titleLabel:setPosition(cc.p(100,parentHeight-10))
--    Panel_item:addChild(titleLabel)
--    taskListItemInfo[index].titleLabel = titleLabel

    local taskType = ManagerTask:getTaskType(taskID)
    local taskName = ManagerTask:getTaskName(taskID)
    --titleLabel:setString(taskName)

    local ttfConfig = {}
    ttfConfig.fontFilePath = "font/FangZhengJianYuan.ttf"
    ttfConfig.fontSize = 22
    ttfConfig.glyphs   = cc.GLYPHCOLLECTION_DYNAMIC
    ttfConfig.customGlyphs = nil
    ttfConfig.distanceFieldEnabled = true
    ttfConfig.outlineSize = 0
   
    local lable = cc.Label:createWithTTF(ttfConfig,taskName,cc.TEXT_ALIGNMENT_CENTER)
    --lable:setString(taskName)
    lable:setAnchorPoint(cc.p(0,1)) 
    lable:setPosition(cc.p(96,parentHeight-10))
    lable:enableOutline(cc.c3b(38, 41, 100))
    lable.outlineSize = 8      
    lable:setColor(cc.c3b(255, 255, 255))
    local sizeAlert = lable:getContentSize()
    Panel_item:addChild(lable)
  
    taskListItemInfo[index].titleLabel = lable
    
    local contentLabel = ccui.Text:create()
    contentLabel:setFontName("font/FangZhengJianYuan.ttf")
    contentLabel:ignoreContentAdaptWithSize(false)
    contentLabel:setFontSize(18)
    contentLabel:setString(taskStaticInfo.TaskDesc)
    contentLabel:setLayoutComponentEnabled(true)
--    contentLabel:setCascadeColorEnabled(true)  --子控件颜色传递
--    contentLabel:setCascadeOpacityEnabled(true) --子控件透明度传递
    contentLabel:setAnchorPoint(cc.p(0,1))
    contentLabel:setPosition(cc.p(100,parentHeight-50))
    contentLabel:setColor(cc.c3b(172, 199, 255))
    --contentLabel:setOpacity(255)
    local layout = ccui.LayoutComponent:bindLayoutComponent(contentLabel)
    layout:setSize(cc.size(180, 50))
    
    Panel_item:addChild(contentLabel)
    taskListItemInfo[index].contentLabel = contentLabel
    
    
    local npcHead = "items/Task/" .. tostring(taskType) .. ".png"
    local npcHeadImage = ccui.ImageView:create()
    npcHeadImage:setAnchorPoint(cc.p(0,0))
    npcHeadImage:setPosition(cc.p(10,10))
    npcHeadImage:loadTexture(npcHead)
    Panel_item:addChild(npcHeadImage)
    taskListItemInfo[index].npcHeadImage = npcHeadImage
    
    
--    local prizeID = taskStaticInfo.PrizeID
--    local prizeIconPath =""
--    local prize = StaticData.Prize[prizeID]
--    if prize then
--        local itemstr = prize.Items
--        local items = {}
--        if itemstr then
--            local stringEx = require("common.stringEx")
--            stringEx:itemResolveFromString(itemstr,items)
--        end
--        if #items > 0 then
--            local itemID = items[1].id
--            local itemStaticInfo = StaticData.Item[itemID]
--            if itemStaticInfo ~= nil then
--                prizeIconPath = itemStaticInfo.ItemIcon
--            end
--        end
--    end
--    local itemReward = prizeIconPath
--    if  itemReward ~= nil and itemReward ~= "" then
--        local itemRewardIconBG = ccui.ImageView:create()
--        itemRewardIconBG:setAnchorPoint(cc.p(0,0))
--        itemRewardIconBG:setPosition(cc.p(285,8))
--        itemRewardIconBG:setScale(0.65)
--        itemRewardIconBG:loadTexture("items/goods/GoodsFrame_0.png")
--        Panel_item:addChild(itemRewardIconBG,1)
--
--        local itemRewardIcon = ccui.ImageView:create()
--        itemRewardIcon:setAnchorPoint(cc.p(0,0))
--        itemRewardIcon:setScale(0.6)
--        itemRewardIcon:setPosition(cc.p(288,10))
--        itemRewardIcon:loadTexture(itemReward)
--        Panel_item:addChild(itemRewardIcon,2)
--        taskListItemInfo[index].itemRewardIcon = itemRewardIcon
--    end

    self.ListView_1:pushBackCustomItem(Panel_item)
end


function TaskListNode:doTaskImmediately(taskID)
    local taskType = ManagerTask:getTaskType(taskID)
    if UserData.Task.acceptedTaskList[taskType][1] == "nil" then
        UserData.Task:sendAcceptTask(taskID,taskType)
    else
        if taskID == tonumber(UserData.Task.acceptedTaskList[taskType][1]) then
            ManagerTask:StartTaskImmediately(taskID)
        else
            publicTips:setTextAction("当前还有此类型的任务尚未完成!")
        end
    end

end

return TaskListNode