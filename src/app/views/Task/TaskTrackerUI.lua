require("cocos/cocos2d/bitExtend.lua")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local ManagerTask = require("app.views.Task.ManagerTask")

local FIXED_ITEM_WIDTH = 200 --任务列表显示的宽度
local taskListItemInfo = {}
local TaskTrackerUI = class("TaskTrackerUI", function()
    return cc.Node:create()
end)

function TaskTrackerUI:create()
    local node = TaskTrackerUI.new()
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

function TaskTrackerUI:ctor()
    taskListItemInfo = {}
end

function TaskTrackerUI:onEnter()
    EventMgr:registListener(EventType.EventOnNoticeAddTask, self, self.OnTaskAdded)
    EventMgr:registListener(EventType.EventOnFinishTask, self, self.OnTaskFinished)
    EventMgr:registListener(EventType.EventOnUpDateTask, self, self.OnTaskParameterChanged)
    EventMgr:registListener(EventType.EventOnAbandonTask, self, self.OnTaskAbandoned)
end

function TaskTrackerUI:onExit()
    EventMgr:unregistListener(EventType.EventOnNoticeAddTask, self, self.OnTaskAdded)
    EventMgr:unregistListener(EventType.EventOnFinishTask, self, self.OnTaskFinished)
    EventMgr:unregistListener(EventType.EventOnUpDateTask, self, self.OnTaskParameterChanged)
    EventMgr:unregistListener(EventType.EventOnAbandonTask, self, self.OnTaskAbandoned)
end

function TaskTrackerUI:init()
    local node =  cc.CSLoader:createNode("csb/TaskTracker.csb")
    self:addChild(node)
    
    local Panel_root = node:getChildByName("Panel_root")
    self.Panel_root = Panel_root
    self.PanelRootHide = true
    self.Panel_root:setPosition(310,500)
    
    
    local Button_hide = Panel_root:getChildByName("Button_hide")
    self.Button_hide = Button_hide
    self.Button_hide:setPressedActionEnabled(true)
    self.Button_hide:setRotation(180)
    self.Button_hide:setContentSize(cc.size(52,56))
    
    local function onHideButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("onHideButtonClicked ended = " .. sender:getName())
            local hide = self.PanelRootHide
            self.PanelRootHide = not hide
            local rootPos = cc.p(310,500)
            local texturePath = "ui/task/task_4.png"
            self.Button_hide:setRotation(180)
            if false == self.PanelRootHide then
                rootPos = cc.p(100,500)
                texturePath = "ui/task/task_3.png"
                self.Button_hide:setRotation(0)
            end
            local move = cc.MoveTo:create(0.2,rootPos)
            self.Panel_root:runAction(move)
            self.Button_hide:loadTextures(texturePath,texturePath,texturePath,0)
        end
    end
    self.Button_hide:addTouchEventListener(onHideButtonClicked)
    
    
    local function onTitleBarClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("onTitleBarClicked = " .. sender:getName())
            --打开已接任务描述界面

            local StageMapLayer = require("app.views.StageMap.StageMapLayer")
            StageMapLayer:StopRoleMoveUpdate()
            local SceneManager = require("app.views.SceneManager")
            SceneManager:switch(SceneManager.SceneName.SCENE_TASKLIST)
        end
    end
    local Panel_titleBar = Panel_root:getChildByName("Panel_titleBar")
    Panel_titleBar:setTouchEnabled(true)
    Panel_titleBar:addTouchEventListener(onTitleBarClicked)
    
    --local Image_titlebar =  Panel_root:getChildByName("Image_titlebar") 奖励
    
    local Text_title =  Panel_root:getChildByName("Text_title")
    --Text_title:setString("任务追踪")
    
    local ListView_1 = Panel_root:getChildByName("ListView_1")
    ListView_1:setContentSize(cc.size(FIXED_ITEM_WIDTH,240))
    self.ListView_1 = ListView_1
    self.ListView_width = ListView_1:getContentSize().width
    self.ListView_height = ListView_1:getContentSize().height
    ListView_1:jumpToTop()
    
    local Panel_item = Panel_root:getChildByName("Panel_item")
    self.Panel_item = Panel_item
    self.Panel_item:setVisible(false)
    
    
    local taskList = ManagerTask:getAcceptedTaskList()
    for i=1,#taskList do
        taskListItemInfo[i] = {}
        if taskList[i][1] == "nil" then 
            if i==1 then --  主线
                local nextMainID = ManagerTask:getNextMainTaskId(UserData.Task.recentlyTaskId)
                taskListItemInfo[i].taskID = nextMainID
            end
        else
            taskListItemInfo[i].taskID = tonumber(taskList[i][1])
        end
    end
    
    for i=1,#taskListItemInfo do
        self:createTaskItem(i)
        self:updateItemText(i)
    end
    
end

-- taskInfo = {title = "任务标题"，descriptions = {}}
function TaskTrackerUI:createTaskItem(index,isInsert)
    if taskListItemInfo[index].taskID == nil then
        return
    end
    
    local function onListItemClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("onListItemClicked ended = " .. sender:getName())
            local taskID = sender:getTag()
            local taskType = ManagerTask:getTaskType(taskID)
            if UserData.Task.acceptedTaskList[taskType][1] ~= "nil" and tonumber(UserData.Task.acceptedTaskList[taskType][1]) >0 then
                cclog("onListItemClicked taskID = " .. tostring(taskID))
                self:moveToTaskDestination(taskID)
            end
        end
    end
    
    local taskID = taskListItemInfo[index].taskID
    local Panel_item = ccui.Layout:create()
    Panel_item:setContentSize(cc.size(self.ListView_width-5, 70))
    --Panel_item:setBackGroundColorType(1) -- ccui.LayoutBackGroundColorType.solid)
    --Panel_item:setBackGroundColor(cc.c3b(128, 0+index*50, 128))
    --Panel_item:setBackGroundColorOpacity(128)
    Panel_item:setAnchorPoint(cc.p(0,1))
    Panel_item:setTouchEnabled(true)
    Panel_item:setName("Panel_item_task_" .. tostring(taskID))
    Panel_item:setTag(tonumber(taskID))
    Panel_item:addTouchEventListener(onListItemClicked)
    taskListItemInfo[index].Panel_item = Panel_item
    
    local parentHeight = Panel_item:getContentSize().height
    
    local titleLabel = ccui.Text:create()
    --titleLabel:setFontName("fonts/Marker Felt.ttf")
    titleLabel:setFontSize(20)
    titleLabel:setContentSize(cc.size(self.ListView_width-5,22))
    titleLabel:setColor(cc.c3b(255, 168, 255))    
    titleLabel:setAnchorPoint(cc.p(0,1))
    titleLabel:setPosition(cc.p(5,parentHeight))
    Panel_item:addChild(titleLabel)
    taskListItemInfo[index].titleLabel = titleLabel
    
    local richTextHight = 0
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(cc.size(self.ListView_width-35, 45))
    richText:setAnchorPoint(cc.p(0.2,0.75))
    richText:setPosition(cc.p(5,parentHeight-25))
    Panel_item:addChild(richText)
    taskListItemInfo[index].richText = richText
    
    if isInsert == nil then
        self.ListView_1:pushBackCustomItem(Panel_item)
    else
        self.ListView_1:insertCustomItem(Panel_item,index-1)
    end

end

function TaskTrackerUI:updateItemText(index)
    if taskListItemInfo[index].taskID == nil then
        return
    end
    local taskID = taskListItemInfo[index].taskID
    local taskType = ManagerTask:getTaskType(taskID)
    --任务追踪描述
    local taskParams = ManagerTask:getTaskParameter(taskID) -- {taskID，taskDesType，killNpcID,maxNum，curNum}
    
    local taskTitleStr = ManagerTask:getTaskName(taskID)
    local taskContent = ManagerTask:getTaskTraceTextContent(taskID)
    
    taskListItemInfo[index].titleLabel:setString( ManagerTask.TASK_TYPE[taskType] .. taskTitleStr)
    local isFirstTask = UserData.Task.recentlyTaskId == nil or UserData.Task.recentlyTaskId == 0
    if taskParams == nil and (not isFirstTask) then
        local level = ManagerTask:getTaskInfo(taskID).Level
        local re1 = ccui.RichElementText:create(1, cc.c3b(255, 0, 0), 255, "需要等级" .. tostring(level), "Helvetica", 16) -- "Default/FZLBJW.TTF"
        taskListItemInfo[index].richText:pushBackElement(re1)
    else
        local stringEx = require("common.stringEx")
        local strTab = stringEx:splitClumpText(taskContent)
        for i=1,#strTab do
            local textStr = strTab[i].text
            local imageStr = strTab[i].image
            if textStr ~= nil then  --文字
                local textSize = strTab[i].fontSize ~= nil and strTab[i].fontSize or 16
                local textFont = strTab[i].fontName ~= nil and strTab[i].fontName or "Helvetica"
                local fontColor = strTab[i].fontColor ~= nil and  tonumber(strTab[i].fontColor,16) or 0xffffff
                local colorB = bit._and(fontColor, 0xff)
                local colorG = bit._and(bit._rshift(fontColor,8), 0xff)
                local colorR = bit._and(bit._rshift(fontColor,16), 0xff)
      
                local re1 = ccui.RichElementText:create(i, cc.c3b(colorR, colorG, colorB), 255, textStr, textFont, textSize) -- "Default/FZLBJW.TTF"
                taskListItemInfo[index].richText:pushBackElement(re1)
                --local re2 = ccui.RichElementText:create(i+1, cc.c3b(255, 0, 0), 255, "(完成)", "Helvetica", 12) -- "Default/FZLBJW.TTF"
                --taskInfo.richText:pushBackElement(re2)
                --local reimg = ccui.RichElementImage:create(i+3, cc.c3b(255, 255, 255), 255, "ui/public/public_other_26.png")
                --taskInfo.richText:pushBackElement(reimg)
            else    --图片
                if imageStr ~= nil then -- 目前不支持缩放
                    local reimg = ccui.RichElementImage:create(i, cc.c3b(255, 255, 255), 255, imageStr)
                    taskListItemInfo[index].richText:pushBackElement(reimg)
                end
            end
    
        end
    end

end

function TaskTrackerUI:moveToTaskDestination(taskID)
    cclog("moveToTaskDestination taskID = " .. tostring(taskID))
    local StageMapLayer = require("app.views.StageMap.StageMapLayer")
    StageMapLayer:moveToTaskDestination(taskID)
end

--添加任务
function TaskTrackerUI:OnTaskAdded(event)
    local taskID = event._usedata
    self:reCreateList()
end

--完成后删除任务
function TaskTrackerUI:OnTaskFinished(event)
    local taskID = event._usedata
    self:reCreateList()
end


--放弃任务
function TaskTrackerUI:OnTaskAbandoned(event)
    local taskID = event._usedata
    self:reCreateList()
end



--更新任务
function TaskTrackerUI:OnTaskParameterChanged(event)
    local taskID = event._usedata

    self:UpdateTaskParameter(taskID)
end


function TaskTrackerUI:UpdateTaskParameter(taskID)
    
    for i=1,#taskListItemInfo do
        if taskID == taskListItemInfo[i].taskID then
            self:updateItemText(i)
            break
        end
    end
end


function TaskTrackerUI:reCreateListItem(nextTaskID)
    local taskType = ManagerTask:getTaskType(nextTaskID)
    local index = taskType -1
    self.ListView_1:removeItem(index)
    taskListItemInfo[taskType].taskID = nextTaskID
    self:createTaskItem(taskType,true)
    self:updateItemText(taskType)
end

function TaskTrackerUI:reCreateList()

    self.ListView_1:removeAllChildren()
    
    local taskList = ManagerTask:getAcceptedTaskList()
    for i=1,#taskList do
        taskListItemInfo[i] = {}
        if taskList[i][1] == "nil" then 
            if i==1 then --  主线
                local nextMainID = ManagerTask:getNextMainTaskId(UserData.Task.recentlyTaskId)
                taskListItemInfo[i].taskID = nextMainID
            end
        else
            taskListItemInfo[i].taskID = tonumber(taskList[i][1])
        end
    end
    
    for i=1,#taskListItemInfo do
        self:createTaskItem(i)
        self:updateItemText(i)
    end
    
end

function TaskTrackerUI:updateItemInfo(taskID)
    
end

return TaskTrackerUI



--[[

// RichText
        self._richText = ccui.RichText:create()
    self._richText:ignoreContentAdaptWithSize(false)
    self._richText:setContentSize(cc.size(100, 100))

    local re1 = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, "This color is white. ", "Helvetica", 10)
    local re2 = ccui.RichElementText:create(2, cc.c3b(255, 255,   0), 255, "And this is yellow. ", "Helvetica", 10)
    local re3 = ccui.RichElementText:create(3, cc.c3b(0,   0, 255), 255, "This one is blue. ", "Helvetica", 10)
    local re4 = ccui.RichElementText:create(4, cc.c3b(0, 255,   0), 255, "And green. ", "Helvetica", 10)
    local re5 = ccui.RichElementText:create(5, cc.c3b(255,  0,   0), 255, "Last one is red ", "Helvetica", 10)

    local reimg = ccui.RichElementImage:create(6, cc.c3b(255, 255, 255), 255, "cocosui/sliderballnormal.png")

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("cocosui/100/100.ExportJson")
    local arr = ccs.Armature:create("100")
    arr:getAnimation():play("Animation1")

    local recustom = ccui.RichElementCustomNode:create(1, cc.c3b(255, 255, 255), 255, arr)
    local re6 = ccui.RichElementText:create(7, cc.c3b(255, 127,   0), 255, "Have fun!! ", "Helvetica", 10)
    self._richText:pushBackElement(re1)
    self._richText:insertElement(re2, 1)
    self._richText:pushBackElement(re3)
    self._richText:pushBackElement(re4)
    self._richText:pushBackElement(re5)
    self._richText:insertElement(reimg, 2)
    self._richText:pushBackElement(recustom)
    self._richText:pushBackElement(re6)
    
    self._richText:setPosition(cc.p(widgetSize.width / 2, widgetSize.height / 2))
    self._richText:setLocalZOrder(10)
    
    
    self._widget:addChild(self._richText)
]]