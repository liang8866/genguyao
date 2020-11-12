
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local ManagerTask = require("app.views.Task.ManagerTask")
local publicTipLayer = require("app/views/public/publicTipLayer")
local stringEx =  require("common.stringEx")
local TimeFormat = require("common.TimeFormat")
local goodsNode = require("app.views.public.goodsNode")

local scheduleUpdate = nil
local taskListItemInfo = {}
local currentSelectedTaskID = 0
local TaskDetailInfoLayer = class("TaskDetailInfoLayer", function()
    return ccui.Layout:create()
end)

function TaskDetailInfoLayer:create()
    local layer = TaskDetailInfoLayer.new()
    layer:init()
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            layer:onEnter() 
        elseif eventType == "exit" then
            layer:onExit() 
        end  
    end  
    layer:registerScriptHandler(onEventHandler)
    return layer
end

function TaskDetailInfoLayer:ctor()
    taskListItemInfo = {}
    currentSelectedTaskID = 0
end

function TaskDetailInfoLayer:onEnter()
    EventMgr:registListener(EventType.EventOnNoticeAddTask, self, self.OnTaskAdded)
    EventMgr:registListener(EventType.EventOnFinishTask, self, self.OnTaskFinished)
    EventMgr:registListener(EventType.EventOnUpDateTask, self, self.OnTaskParameterChanged)
    EventMgr:registListener(EventType.EventOnAbandonTask, self, self.OnTaskAbandoned)
end

function TaskDetailInfoLayer:onExit()
    EventMgr:unregistListener(EventType.EventOnNoticeAddTask, self, self.OnTaskAdded)
    EventMgr:unregistListener(EventType.EventOnFinishTask, self, self.OnTaskFinished)
    EventMgr:unregistListener(EventType.EventOnUpDateTask, self, self.OnTaskParameterChanged)
    EventMgr:unregistListener(EventType.EventOnAbandonTask, self, self.OnTaskAbandoned)
    
    if scheduleUpdate then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
        scheduleUpdate = nil
    end
    
end

function TaskDetailInfoLayer:init()
    local layer =  cc.CSLoader:createNode("csb/TaskDetailInfoLayer.csb")
    self:addChild(layer)
    
    local Button_close = layer:getChildByName("Button_close")
    Button_close:setPressedActionEnabled(true)
    Button_close:setTouchEnabled(true)
    Button_close:addTouchEventListener(function(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("Button_close clicked = " .. sender:getName())
            if self:getParent() ~= nil then
                self:getParent():removeChild(self)
            end
        end
    end)
    
    local Panel_root = layer:getChildByName("Panel_root")
    self.Panel_root = Panel_root
    Panel_root:setTouchEnabled(true)
    
    local Text_taskType = Panel_root:getChildByName("Text_taskType")
    self.Text_taskType = Text_taskType
    
    local Text_taskName = Panel_root:getChildByName("Text_taskName")
    self.Text_taskName = Text_taskName
    
    local Text_taskDescription = Panel_root:getChildByName("Text_taskDescription")
    self.Text_taskDescription = Text_taskDescription

    self.Panel_reward = Panel_root:getChildByName("Panel_reward")
   
    
    local Button_abandon = Panel_root:getChildByName("Button_abandon")
    self.Button_abandon = Button_abandon
    local Button_flyTo = Panel_root:getChildByName("Button_flyTo")
    self.Button_flyTo = Button_flyTo
    local Button_achievement = Panel_root:getChildByName("Button_achievement")
    Button_achievement:setVisible(false)
    --self.Button_achievement = Button_achievement
    
    local function onButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("onButtonClicked ended = " .. sender:getName())
            if currentSelectedTaskID <= 0 then
                return
            end
            local taskType = ManagerTask:getTaskType(currentSelectedTaskID)
            if taskType == 1 and UserData.Task.acceptedTaskList[1][1] == "nil" then
                return
            end
            local buttonName = sender:getName()
            if "Button_abandon" == buttonName then
                local taskType = ManagerTask:getTaskType(currentSelectedTaskID)
                if taskType == 1 then
                    publicTipLayer:setTextAction("主线任务无法放弃")
                else
                    -- 发送请求放弃任务消息
                    UserData.Task:sendAbandonTask(currentSelectedTaskID,taskType)
                end
                
            elseif "Button_flyTo" == buttonName then 
                --立即前往
                if self:getParent() ~= nil then
                    self:getParent():removeChild(self)
                end
                
                local type = StaticData.Task[currentSelectedTaskID].TaskTargetType
                if type == 2 then -- 对话
                    ManagerTask:StartTaskImmediately(currentSelectedTaskID)
                elseif type == 1 then  -- 打怪
                    local townID = StaticData.Task[currentSelectedTaskID].TownID
                    local worldMapID = StaticData.TownMap[tostring(townID)].WorldMapId

                    local StageMapLayer =  require("app.views.StageMap.StageMapLayer")
                    local layer = StageMapLayer:create(worldMapID)
                    local SceneManager = require("app.views.SceneManager")
                    SceneManager:addToGameScene(layer)

                    ManagerTask.currentMoveToNpcTaskID = currentSelectedTaskID
                    StageMapLayer:moveToTaskDestination(currentSelectedTaskID)
                end
                
            end
        end
    end
    self.Button_abandon:setTouchEnabled(true)
    self.Button_abandon:setPressedActionEnabled(true)
    self.Button_abandon:addTouchEventListener(onButtonClicked)
    self.Button_flyTo:setTouchEnabled(true)
    self.Button_flyTo:setPressedActionEnabled(true)
    self.Button_flyTo:addTouchEventListener(onButtonClicked)
    --self.Button_achievement:setPressedActionEnabled(true)
    --self.Button_achievement:addTouchEventListener(onButtonClicked)
    
    local ListView_task = Panel_root:getChildByName("ListView_task")
    ListView_task:jumpToTop()
    ListView_task:setAnchorPoint(cc.p(0,1))
    self.ListView_task = ListView_task

    self.Text_left_time = Panel_root:getChildByName("Text_left_time")
    self.Text_left_time:setVisible(false)
    self.Text_day_times = Panel_root:getChildByName("Text_day_times")
    self.Text_day_times:setVisible(false)

    self.publicTipLayer = publicTipLayer:create()
   
    local TaskList = {}
    local taskList = ManagerTask:getAcceptedTaskList()
    for i=1,#taskList do
        taskListItemInfo[i] = {}
        if tonumber(taskList[i][1]) ~= nil then
            taskListItemInfo[i].taskID = tonumber(taskList[i][1])
        else
            if i==1 then --  主线
                local nextMainID = ManagerTask:getNextMainTaskId(UserData.Task.recentlyTaskId)
                if nextMainID > 0 then
                    taskListItemInfo[i].taskID = nextMainID
                end
            end
        end
        if taskListItemInfo[i].taskID ~= nil and tonumber(taskListItemInfo[i].taskID) ~= nil then
            TaskList[tonumber(taskListItemInfo[i].taskID)] = tonumber(taskListItemInfo[i].taskID)
        end
    end
    
    if table.nums(TaskList) > 0 then
        for i=1,#taskListItemInfo do
            if taskListItemInfo[i].taskID ~= nil then
                self:createListItem(i)
                self:updateItemText(i)
            end
        end
    
        if #taskListItemInfo > 1 then 
            self:showTaskItemSelected(taskListItemInfo[1].taskID)
        end
    else
        self.Text_taskDescription:setString("")
        self.Text_taskName:setString("")
        self.Text_taskType:setString("")
        self.Text_left_time:setString("")
        self.Text_day_times:setString("")
    end
    
    -- 对字体进行描边
    local Text_abandon = Button_abandon:getChildByName("Text_1")
    local Text_flyto = Button_flyTo:getChildByName("Text_1_0")
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_abandon) 
    outLineLable:setTexOutLine(Text_flyto) 
    
end

function TaskDetailInfoLayer:updateItemText(index)
    local taskID = taskListItemInfo[index].taskID

    --local taskType = ManagerTask:getTaskType(taskID)
    local taskName = ManagerTask:getTaskName(taskID)
    if taskListItemInfo[index].Text_task_Name ~= nil then
        taskListItemInfo[index].Text_task_Name:setString(taskName)
    end
end

function TaskDetailInfoLayer:createListItem(index,isInsert)
    local taskID = taskListItemInfo[index].taskID
    local taskType = ManagerTask:getTaskType(taskID)
    local taskName = ManagerTask:getTaskName(taskID)
    
    local function onListItemClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("onListItemClicked ended = " .. sender:getName())
            local taskID = sender:getTag()
            cclog("onListItemClicked taskID = " .. tostring(taskID))
            
            self:showTaskItemSelected(taskID)
        end
    end

    local Panel_item = ccui.Layout:create()
    Panel_item:setContentSize(cc.size(265, 75))
--    Panel_item:setBackGroundColorType(1) -- ccui.LayoutBackGroundColorType.NONE)
--    Panel_item:setBackGroundColor(cc.c3b(128, 0+index*50, 128))
--    Panel_item:setBackGroundColorOpacity(64)
    Panel_item:setAnchorPoint(cc.p(1,0.5))
    --Panel_item:setPositionX(100)
    Panel_item:setTouchEnabled(true)
    Panel_item:setName("Panel_item_task_" .. tostring(taskID))
    Panel_item:setTag(tonumber(taskID))
    Panel_item:addTouchEventListener(onListItemClicked)
    taskListItemInfo[index].Panel_item = Panel_item
    
    local fileName = (1 == index) and "ui/townAssignment/taskFrame_2.png" or "ui/townAssignment/taskFrame_1.png"
    local Image_item_bg = ccui.ImageView:create()
    Image_item_bg:setAnchorPoint(cc.p(0,0))
    Image_item_bg:setPosition(cc.p(0, 0))
    Image_item_bg:loadTexture(fileName,0)
    Panel_item:addChild(Image_item_bg)
    taskListItemInfo[index].Image_item_bg = Image_item_bg
    
    local Image_task_type = ccui.ImageView:create()
    --Image_task_type:setAnchorPoint(cc.p(0,0))
    --Image_task_type:setPositionPercent(cc.p(0.5,0.5))
    Image_task_type:setPosition(cc.p(40,35))
    Image_task_type:loadTexture("ui/townAssignment/taskType_" .. tostring(taskType) .. ".png",0)
    Image_item_bg:addChild(Image_task_type)
    taskListItemInfo[index].Image_task_type = Image_task_type

    local Text_task_Name = ccui.Text:create()
    --Text_task_Name:setFontName("fonts/Marker Felt.ttf")
    Text_task_Name:setFontSize(22)
    --Text_task_Name:setContentSize(cc.size(168,25))
    Text_task_Name:setColor(cc.c3b(255, 255, 255))    
    Text_task_Name:setAnchorPoint(cc.p(0,0.5))
    Text_task_Name:setPosition(cc.p(75,37))
    Text_task_Name:setString(taskName)
    Image_item_bg:addChild(Text_task_Name)
    taskListItemInfo[index].Text_task_Name = Text_task_Name

    if isInsert == nil then
        self.ListView_task:pushBackCustomItem(Panel_item)
    else
        self.ListView_task:insertCustomItem(Panel_item,index-1)
    end
    
end

function TaskDetailInfoLayer:updateListSelectItemBg(taskID)
    for i=1,#taskListItemInfo do
        if taskListItemInfo[i] ~= nil and taskListItemInfo[i].Image_item_bg ~= nil then
            local fileName = (taskListItemInfo[i].taskID == taskID) and "ui/townAssignment/taskFrame_2.png" or "ui/townAssignment/taskFrame_1.png"
            taskListItemInfo[i].Image_item_bg:loadTexture(fileName,0)
--            local pos = (taskListItemInfo[i].taskID == taskID) and cc.p(0.6,0.5) or cc.p(0.5,0.5)
--            taskListItemInfo[i].Image_item_bg:setAnchorPoint(cc.p(0,0))
--            taskListItemInfo[i].Image_item_bg:setPositionPercent(pos)
              --local x = (taskListItemInfo[i].taskID == taskID) and 0.0 or 0.08
            --taskListItemInfo[i].Image_item_bg:setAnchorPoint(x, 0.0)
            local color = (taskListItemInfo[i].taskID == taskID) and cc.c3b(255,255,255) or cc.c3b(192,192,192) 
            taskListItemInfo[i].Text_task_Name:setColor(color)
        end
    end
end

function TaskDetailInfoLayer:showTaskDetailInfo(taskID)
    --local taskID = taskListItemInfo[index].taskID
    local taskInfo = ManagerTask:getTaskInfo(taskID)
    local taskType = ManagerTask:getTaskType(taskID)
    local taskName = ManagerTask:getTaskName(taskID)
    local taskDescription = ManagerTask:getTaskDescription(taskID)
    self.Text_taskDescription:setTextColor(cc.c4b(255, 255, 255, 255))
    if taskType == 1 and UserData.Task.acceptedTaskList[1][1] == "nil" then
        local level = ManagerTask:getTaskInfo(taskID).Level
        taskDescription = "需要等级" .. tostring(level)
        self.Text_taskDescription:setTextColor(cc.c4b(255, 0, 0, 255))
    end
    
    self.Text_taskType:setString(ManagerTask.TASK_TYPE[taskType])
    self.Text_taskName:setString(taskName)
    self.Text_taskDescription:setString(taskDescription)
    
    local prizeId = taskInfo.PrizeID
    self:showTaskRewards(prizeId)
    
    if scheduleUpdate ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
        scheduleUpdate = nil
    end
    if taskType == 5 then -- 探索任务
        
        self.Text_left_time:setVisible(true)
        local taskTotalTime = taskInfo.LimitTime/1000  -- 需要多少秒内完成
        local duration = TimeFormat:getSecondsInter(UserData.Task.sExploreTaskTime)
        if duration < taskTotalTime then --还未到时间
            self.remainTime = taskTotalTime - duration
            
            if self.remainTime > 0 then
                scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) 
                    self:updateTimer(dt)
                end, 1 ,false)
                local nh, nm, ns = TimeFormat:getHMS(math.floor(self.remainTime))
                self.Text_left_time:setString(string.format("剩余时间:(%02d:%02d:%02d)",nh, nm,ns))
                
            end
        else
            self.Text_left_time:setString("任务超时,已失败")
        end
    
    else
        self.Text_left_time:setVisible(false)
    end
    if taskType == 3 then -- 日常任务
        self.Text_day_times:setString(tostring(UserData.Task.nDayTaskNum) .. "/" .. tostring(StaticData.SystemParam["DayTaskNum"].IntValue))
    else
        self.Text_day_times:setVisible(false)
    end
end


function  TaskDetailInfoLayer:updateTimer(dt)

    self.remainTime = self.remainTime - dt

    if self.remainTime <= 0 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
        scheduleUpdate = nil
        
        self.Text_left_time:setVisible(false)
        self.remainTime = 0
        return
    end
    
    local nh, nm, ns = TimeFormat:getHMS(math.floor(self.remainTime))
    self.Text_left_time:setString(string.format("剩余时间:(%02d:%02d:%02d)",nh, nm,ns))
end

function  TaskDetailInfoLayer:showTaskRewards(prizeId)
    local prize = StaticData.Prize[prizeId]
    if prize then
        local itemstr = prize.Items
        local items = {}
        if itemstr then
            stringEx:itemResolveFromString(itemstr,items)
        end
        if #items > 0 then
            for i=1,4 do
                if items[i] ~= nil then
                    self:createTaskItemSprite(self.Panel_reward,items[i])
                end
            end

        end

    end
end


function TaskDetailInfoLayer:createTaskItemSprite(parent,itemInfo)
    local itemStaticInfo = StaticData.Item[itemInfo.id]
    if itemStaticInfo ~= nil then
        --[[
        local itemCount = itemInfo.count
        local sp1 = cc.Sprite:create(itemStaticInfo.ItemIcon)
        sp1:setAnchorPoint(cc.p(0,0))
        sp1:setPosition(cc.p(0,0))
        parent:addChild(sp1)
        local labal = cc.Label:createWithSystemFont(tostring(itemCount), "Helvetica.ttf", 30.0)
        labal:setColor(cc.c3b(255,255,255))
        --labal:setString(tostring(itemCount))
        parent:addChild(labal,1)
        labal:setPosition(65,20)
        ]]
        local function touchEvent(sender, eventType)
            if eventType == cc.EventCode.ENDED then
                local FlyMakeMatLayer = require("app.views.public.FlyMakeMatLayer")
                local goodsNum = UserData.Bag.items[sender:getTag()]
                local flyMakeMatLayer = FlyMakeMatLayer:create(sender:getTag())
                local SceneManager = require("app.views.SceneManager")  
                local layer = SceneManager:getGameLayer("TaskDetailInfoLayer")
                layer:addChild(flyMakeMatLayer)
            end
        end
        
        local layout = ccui.Layout:create()
        layout:setEnabled(true)

        local id = tonumber(itemInfo.id)
        local num = tonumber(itemInfo.count)
        local prizeNode = goodsNode:create(id,num)
        prizeNode:btnEvent(touchEvent)

        layout:addChild(prizeNode)  
        parent:addChild(layout,1)    
    end
end


--添加任务,添加任务时，此界面必定未打开，故可以不处理此事件
function TaskDetailInfoLayer:OnTaskAdded(event)
    local taskID = event._usedata
    self:reCreateListItem()
    
    publicTipLayer:setTextAction("接任务成功")
end

--完成后删除任务
function TaskDetailInfoLayer:OnTaskFinished(event)
    local taskID = event._usedata
    self:reCreateListItem()
    publicTipLayer:setTextAction("任务已完成")
end

--更新任务
function TaskDetailInfoLayer:OnTaskParameterChanged(event)
    local taskID = event._usedata
    for i=1,#taskListItemInfo do
        if taskID == taskListItemInfo[i].taskID then
            self:updateItemText(i)
        end
    end
     publicTipLayer:setTextAction("任务已更新")
end


--放弃任务
function TaskDetailInfoLayer:OnTaskAbandoned(event)
    local taskID = event._usedata
    self:reCreateListItem()
    publicTipLayer:setTextAction("成功放弃任务")
end



function TaskDetailInfoLayer:reCreateListItem()

    local taskList = ManagerTask:getAcceptedTaskList()  --新任务列表

    local needRemoveTaskID = {}
    local needAddTaskID = {}
    for i=1,#taskList do
        if taskList[i][1] == "nil" then
            if i ~= 1 then
                table.insert(needRemoveTaskID,i)
            end
        else
            if taskListItemInfo[i].taskID == nil then
                taskListItemInfo[i].taskID = tonumber(taskList[i][1])
                table.insert(needAddTaskID,tonumber(taskList[i][1]))
            else
                if taskListItemInfo[i].taskID ~= tonumber(taskList[i][1]) then
                    self:updateItemText(i)
                end
            end
        end
    end

    --需要删除的
    local removeCount = #needRemoveTaskID
    if removeCount > 0 then
        for i=#needRemoveTaskID,1,-1 do
            local index = needRemoveTaskID[i]
            cclog("needRemoveTaskID index = " .. tostring(index))
            if taskListItemInfo[index]~= nil and  taskListItemInfo[index].Panel_item ~= nil then
                self.ListView_task:removeChild(taskListItemInfo[index].Panel_item, true)
                self.ListView_task:requestRefreshView()
                taskListItemInfo[index] = {}
            end
        end
    end

    --需要添加的
    for i=1,#taskListItemInfo do
        for j=1,#needAddTaskID do
            if taskListItemInfo[i].taskID  == needAddTaskID[j] then
                self:createListItem(i,true)
                break
            end
        end
    end
    
    local taskID = 0
    for i=1,#taskListItemInfo do
        if taskListItemInfo[i] ~= nil and taskListItemInfo[i].taskID > 0 then
            taskID = taskListItemInfo[i].taskID
            break
        end
    end
    self:showTaskItemSelected(taskID)
end

function TaskDetailInfoLayer:showTaskItemSelected(taskID)
    if taskID > 0 then
        currentSelectedTaskID = taskID
        self:showTaskDetailInfo(taskID)
        self:updateListSelectItemBg(taskID)
    end
end

return TaskDetailInfoLayer