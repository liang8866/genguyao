local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local ManagerTask = require("app.views.Task.ManagerTask")

local Button_back = nil  -- 返回按钮
local Panel_root = nil   
local buttonInterfaceList = nil -- 按钮列表
local mylayer = nil

local currentTownID = nil
local delayCallFunction = nil

local TownInterfaceLayer = class("TownInterfaceLayer", function()
    return cc.Node:create()
end)


function TownInterfaceLayer:create()
    local node = TownInterfaceLayer.new()
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

function TownInterfaceLayer:ctor()
    buttonInterfaceList = {} -- 按钮列表
end

function TownInterfaceLayer:onEnter()
    EventMgr:registListener(EventType.EventOnNoticeAddTask, self, self.OnTaskAdded)
    EventMgr:registListener(EventType.EventOnFinishTask, self, self.OnTaskFinished)
    EventMgr:registListener(EventType.EventOnAbandonTask, self, self.OnTaskAbandoned)
    
end

function TownInterfaceLayer:onExit()
    EventMgr:unregistListener(EventType.EventOnNoticeAddTask, self, self.OnTaskAdded)
    EventMgr:unregistListener(EventType.EventOnFinishTask, self, self.OnTaskFinished)
    EventMgr:unregistListener(EventType.EventOnAbandonTask, self, self.OnTaskAbandoned)
end


function TownInterfaceLayer:checkCreateNpc(canFinishTaskID)
    cclog("currentTownID = " .. tostring(currentTownID))
    if currentTownID ~= nil and tonumber(currentTownID)  > 0 and mylayer ~= nil then

        self:removeAllNpc()
        --创建城镇中的任务Npc
        local taskList = ManagerTask:getAcceptedTaskList()
        for i=1,#taskList do
            if tonumber(taskList[i][1]) ~= nil then
                local taskID = tonumber(taskList[i][1])
                local isFinishTask = canFinishTaskID >0 and canFinishTaskID == taskID
                local  data  = StaticData.Task[taskID]
                if data.TownID == tonumber(currentTownID) and (not isFinishTask) then --说明是城镇中的任务
                    ManagerTask:addNpcToCity(taskID,mylayer)
                end
            end
        end
    end

end

function TownInterfaceLayer:checkFinishTask()
    local canFinishTaskID = ManagerTask:getCanFinishTask()

    if delayCallFunction then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(delayCallFunction)
    end

    if canFinishTaskID > 0 then
        local function myupdate(dt)
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(delayCallFunction)

            --直接弹完成任务界面
            local TaskMessageBox =  require("app.views.Task.TaskMessageBox")
            local layer = TaskMessageBox:create()
            local SceneManager = require("app.views.SceneManager")
            SceneManager:addToGameScene(layer, 40)
            TaskMessageBox:ShowTaskFinishMessageBox(canFinishTaskID)
        end
        delayCallFunction = cc.Director:getInstance():getScheduler():scheduleScriptFunc(myupdate, 0.5 ,false)
    end 
    self:checkCreateNpc(canFinishTaskID)  
end

--初始化(内部调用)
function TownInterfaceLayer:init()
   
    mylayer =  cc.CSLoader:createNode("csb/TownInterfaceLayer.csb")
    mylayer:setName("TownInterfaceLayer_csb_root")
    mylayer:setPositionY(mylayer:getPositionY() + (display.height - 576)/2)
    self:addChild(mylayer)
    self.name = "TownInterfaceLayer"
    self:setName("TownInterfaceLayer")
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    
    Panel_root = mylayer:getChildByName("Panel_root")
   
    Button_back = mylayer:getChildByName("Button_back")
    Button_back:setPositionY(display.height - 60 - (display.height - 576)/2)
    
    self.Image_bg = Panel_root:getChildByName("Image_bg")  -- 设置背景，不同城镇背景不同
    
    self.Text_name = Panel_root:getChildByName("Text_name")
    self.Image_town_name_bg = Panel_root:getChildByName("Image_town_name_bg")
    self.Image_town_name = Panel_root:getChildByName("Image_town_name")
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            cclog("TownInterfaceLayer onEventTouchButton,name = "  .. sender:getName())
            self:removeFromParent()
            
            
            local acceptTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
            if acceptTaskID ~= nil and acceptTaskID == UserData.NewHandLead.GuideList.TownToMap.TaskID then
                local guideState = UserData.NewHandLead:getGuideState("ClickMapEnventPoint")
                if guideState == 0 then
                    
                    UserData.NewHandLead:CompleteGuide("TownToMap")
                    UserData.NewHandLead:closeCurrentGuide()
                end
                
            end
            local SceneManager = require("app.views.SceneManager")
            SceneManager:removeChildLayer("NewHandLeadLayer")
            
            local currentMapID = UserData.Map:getRoleStayWorldMapID()
            local StageMapLayer = require("app.views.StageMap.StageMapLayer"):create(currentMapID)
            
            SceneManager:addToGameScene(StageMapLayer)
            
            
            local curTaskID = UserData.NewHandLead.GuideList.ClickMapEnventPoint.TaskID
            if acceptTaskID == curTaskID then
                local guideState = UserData.NewHandLead:getGuideState("ClickMapEnventPoint")
                if guideState == 0 then
                    local data = {name = "ClickMapEnventPoint"}
                    UserData.NewHandLead:startNewGuide(data)
                    local curTownID = StaticData.Task[curTaskID].TownID
                    local townPos = string.split(StaticData.TownMap[tostring(curTownID)].TownPos,"*")
                    StageMapLayer:ShowNewHand(cc.p(townPos[1]+50,townPos[2])) 
                end
            end
           
        end
    end
    Button_back:addTouchEventListener(onEventTouchButton)
    Button_back:setPressedActionEnabled(true)
    
    local function onTouchBG(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            self.main_ui_layer.bottomBar:setUpDownStateToDown()
        end
    end
    self.Image_bg:addTouchEventListener(onTouchBG)
    self.Image_bg:setTouchEnabled(true)
    
    self:BackToUI()
    
    self.main_ui_layer = require("app.views.Main.MainUILayer"):create()   
    self:addChild(self.main_ui_layer,2)
    self.main_ui_layer.bottomBar:setUpDownStateToUP()
    

end


function TownInterfaceLayer:createInterfaceWnd(parent,index,interfaceInfo)
 
    local pos = buttonInterfaceList[index].pos 
    
    local button = ccui.Button:create()
    button:setTouchEnabled(true)
    --button:loadTextures("items/goods/item_11016.png", "items/goods/item_11016.png", "items/goods/item_11016.png")
    local iconImagePath = StaticData.Icon[tonumber(interfaceInfo.IconPath)].path
    if iconImagePath == nil or iconImagePath == "" then
        iconImagePath = "ui/townInterface/icon_10.png"
    end
    local textImagePath = interfaceInfo.TextIconPath
    if textImagePath == nil or textImagePath == "" then
        textImagePath = "ui/townInterface/icon_10.png"
    end
    
    button:loadTextureNormal(iconImagePath,0)
    button:loadTexturePressed(iconImagePath,0)
    button:loadTextureDisabled(iconImagePath,0)
    button:setName("Button_" .. tostring(index))
    button:setAnchorPoint(0,0)
    button:setPosition(pos.x,pos.y)
    button:setTag(index)
    button:setVisible(true)
    button:setPressedActionEnabled(true)
    --button:setOpacity(150)
    parent:addChild(button)

    --Create Image_bg
--    local Image_bg = ccui.ImageView:create()
--    Image_bg:setLayoutComponentEnabled(true)
--    Image_bg:setName("Image_bg")
--    Image_bg:loadTexture(textImagePath,0)
--    Image_bg:setAnchorPoint(0,0.5)
    --    button:addChild(Image_bg)


    --[[
    --Create Text_Title
    local Text_Title = ccui.Text:create()
    Text_Title:setFontSize(24)
    Text_Title:setTextHorizontalAlignment(1)
    Text_Title:setTextVerticalAlignment(1)
    Text_Title:setLayoutComponentEnabled(true)
    Text_Title:setName("Text_Title")
    Text_Title:setCascadeColorEnabled(true)
    Text_Title:setCascadeOpacityEnabled(true)
    Text_Title:setPosition(50.0000, 63.4924)
    Text_Title:setColor(cc.c3b(0, 153, 255))
    Text_Title:setString("市场")
    button:addChild(Text_Title)
    ]]

    return button
end

--初始化(外调用，传入数据)
function TownInterfaceLayer:initUI(data)
    -- userdata = {currentTownID = id}

    currentTownID = data.currentTownID
    local townStaticDataInfo = StaticData.TownMap[data.currentTownID]
    if townStaticDataInfo == nil then
        cclog("townStaticDataInfo  is nil ,currentTownID = " ..tostring(currentTownID))
        return
    end
    local bg = townStaticDataInfo.TownBG
    self.Image_bg:loadTexture(bg)
    
    cclog("currentTownID = " .. data.currentTownID)
    --self.Text_name:setString(StaticData.TownMap[data.currentTownID].TownName)
    self.Text_name:setVisible(false)
    self.Image_town_name:loadTexture(townStaticDataInfo.TownNameImage,0)
    self.Image_town_name:ignoreContentAdaptWithSize(true)
    local sizeName = self.Image_town_name:getContentSize()
    self.Image_town_name_bg:ignoreContentAdaptWithSize(true)
    self.Image_town_name_bg:setScale9Enabled(true)
    self.Image_town_name_bg:setCapInsets(cc.rect(36,14,43,15))
    self.Image_town_name_bg:loadTexture("ui/worldMap/worldMap_text_bg2.png",0)
    self.Image_town_name_bg:setContentSize(cc.size(sizeName.width+50,sizeName.height+10))

    
    local idStr = StaticData.TownMap[data.currentTownID].InterfaceIdList
    local pointStr = StaticData.TownMap[data.currentTownID].InterfacePointList
    local funcIDStr = StaticData.TownMap[data.currentTownID].FunctionID
    local pointList = string.split(pointStr,"-")
    local funcList = string.split(funcIDStr,"|")
    local interfaceIDList = string.split(idStr,"*")
    local tableEx = require("common.tableEx")
    local n1 = tableEx:getTableRealLength(interfaceIDList)

    local Node_interface = Panel_root:getChildByName("Node_interface")
    Node_interface:removeAllChildren()
    buttonInterfaceList = {}

    for i=1 ,n1 do
        local interfaceID = tonumber(interfaceIDList[i])
        if interfaceID ~= nil then
            local interfaceInfo = StaticData.TownInterface[interfaceID]
            local posTab = string.split(pointList[i],"*")
            local funcTab = string.split(funcList[i],"-")
            buttonInterfaceList[i] = {}

            buttonInterfaceList[i].id =  i
            buttonInterfaceList[i].pos = { x = tonumber(posTab[1]), y = tonumber(posTab[2]) }
            buttonInterfaceList[i].funcNumber = { tonumber(funcTab[1]), tonumber(funcTab[2]) }

            buttonInterfaceList[i].button = self:createInterfaceWnd(Node_interface,i,interfaceInfo)
            buttonInterfaceList[i].Image_bg = buttonInterfaceList[i].button:getChildByName("Image_bg")

            self:addPointButtonEvent(buttonInterfaceList[i])
        end
    end

    self:initTaskListNode()

    self:checkFinishTask()


    --UserData.NewHandLead:CheckStartNewGuide()


    local name = "" 
    if (currentTownID == "612005") then -- 江都
        name = "EnterToJiangDou"
        local taskID = UserData.NewHandLead.GuideList.EnterToJiangDou.TaskID
        local preTaskID = StaticData.Task[taskID].PreTaskID
        if ManagerTask:isTaskHaveComplete(preTaskID) then
            if UserData.NewHandLead:getGuideState(name) == 0 then
                UserData.NewHandLead:CompleteGuide("EnterToJiangDou")
            end
            name = "ClickTaskNodeList"
            local guideState = UserData.NewHandLead:getGuideState(name)
            if guideState == 0 then
                local data = {name = name}
                UserData.NewHandLead:startNewGuide(data)
            end
        end
                
        name = "GodWillLead_levelup"
        if ManagerTask:isTaskHaveComplete(UserData.NewHandLead.GuideList[name].TaskID) then
            if UserData.NewHandLead:getGuideState(name) == 0 and UserData.NewHandLead:isPreGuideCompleted(name)  then
                local data = {name = name}
                UserData.NewHandLead.GuideList[name].curStep = 1
                UserData.NewHandLead:startNewGuide(data)
                self:showNewHand(name)
            end
        end
        
        name = "GodWillLead_starUp"
        if UserData.NewHandLead.GuideList[name] ~= nil and ManagerTask:isTaskHaveComplete(UserData.NewHandLead.GuideList[name].TaskID) then
            if UserData.NewHandLead:getGuideState(name) == 0 and UserData.NewHandLead:isPreGuideCompleted(name) then
                local data = {name = name}
                UserData.NewHandLead.GuideList[name].curStep = 1
                UserData.NewHandLead:startNewGuide(data)
                self:showNewHand(name)
            end
        end
        
        name = "FlySkillLead"
        if ManagerTask:isTaskHaveComplete(UserData.NewHandLead.GuideList[name].TaskID) then
            if UserData.NewHandLead:getGuideState(name) == 0 and UserData.NewHandLead:isPreGuideCompleted(name) then
                local data = {name = name}
                UserData.NewHandLead.GuideList[name].curStep = 1
                UserData.NewHandLead:startNewGuide(data)
                self:showNewHand(name)
            end
        end
    end
   
    
    if ManagerTask:isTaskHaveComplete(UserData.NewHandLead.GuideList.FlyRefining.TaskID) and UserData.NewHandLead:isPreGuideCompleted("FlyRefining") then
        if UserData.NewHandLead:getGuideState("FlyRefining") == 0 or
            UserData.NewHandLead:getGuideState("FlySkillChange") == 0 or
            UserData.NewHandLead:getGuideState("FlyGodChange") == 0 or
            UserData.NewHandLead:getGuideState("FlyFighting") == 0
         then
            self:showNewHand("FlyRefining")
            
--       if UserData.NewHandLead:getGuideState("FlyRefining") == 0 then 
--            local data = {name = "FlyRefining", order = 20}
--            UserData.NewHandLead:startNewGuide(data)
--        elseif UserData.NewHandLead:getGuideState("FlySkillChange") == 0 then
--            local data = {name = "FlySkillChange", order = 20}
--            UserData.NewHandLead:startNewGuide(data)
--        elseif UserData.NewHandLead:getGuideState("FlyGodChange") == 0 then
--            local data = {name = "FlyGodChange", order = 20}
--            UserData.NewHandLead:startNewGuide(data)
--        elseif UserData.NewHandLead:getGuideState("FlyFighting") == 0 then
--            local data = {name = "FlyFighting", order = 20}
--            UserData.NewHandLead:startNewGuide(data)
--        end
          end
    end

    if (currentTownID == "612005" and ManagerTask:isTaskHaveComplete(UserData.NewHandLead.GuideList.ExploreLead.TaskID)) then
        if UserData.NewHandLead:getGuideState("ExploreLead") == 0 and UserData.NewHandLead:isPreGuideCompleted("ExploreLead") then
            local data = {name = "ExploreLead", order = 9}
            UserData.NewHandLead:startNewGuide(data)
        end
    end
end



function TownInterfaceLayer:showNewHand(name)
    if self.main_ui_layer ~= nil and self.main_ui_layer.bottomBar ~= nil then
        self.main_ui_layer.bottomBar:showNewHand(name)
    end
end
               
function TownInterfaceLayer:addPointButtonEvent(buttonInfo)
    local function onEventButtonClicked(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            cclog("onEventButtonClicked,name="  .. sender:getName())
            local id = sender:getTag()
            cclog("onEventButtonClicked,id="  .. id)
            self:callBackFunction(id)
            
        end
    end
    buttonInfo.button:addTouchEventListener(onEventButtonClicked)
    buttonInfo.button:setTouchEnabled(true)
    buttonInfo.button:setPressedActionEnabled(true)
    buttonInfo.button:setTag(buttonInfo.id)
end


function TownInterfaceLayer:callBackFunction(id)

    if buttonInterfaceList[id].funcNumber ~= nil then
        if buttonInterfaceList[id].funcNumber[1] == 1  then --进入探索地图
            if self:isExploreOpened() then
                local exploreMapID = buttonInterfaceList[id].funcNumber[2]
                local ExploreStartLayer = require("app.views.Explore.ExploreStartLayer")
                local layer = ExploreStartLayer:create(exploreMapID)
                local SceneManager = require("app.views.SceneManager")
                SceneManager:addToGameScene(layer,8)
            
            else
                local task = UserData.NewHandLead.GuideList.ExploreLead.TaskID
                local closeStr = "完成任务[" .. StaticData.Task[task].TaskName .. "]之后开启此功能。"
                local publicTipLayer = require("app/views/public/publicTipLayer")
                publicTipLayer:setTextAction(closeStr)
            end
        end
    end
    
end

function TownInterfaceLayer:isExploreOpened()
    return ManagerTask:isTaskHaveComplete(UserData.NewHandLead.GuideList.ExploreLead.TaskID) and UserData.NewHandLead:isPreGuideCompleted("ExploreLead") 

end


function TownInterfaceLayer:BackToUI()
    if currentTownID ~= nil and tonumber(currentTownID)  > 0 then  -- "612001"
        local userdata = {currentTownID = currentTownID}
        self:initUI(userdata)
    end
end

function TownInterfaceLayer:removeAllNpc()
    if mylayer ~= nil then
        local childs = mylayer:getChildren()
        for i=#childs,0,-1 do
            if childs[i] ~= nil and childs[i].__cname == "publicNpc" then
                childs[i]:removeFromParent()
            end
        end
    end
end

function TownInterfaceLayer:OnTaskAdded(event)
    local taskID = event._usedata
    self:initTaskListNode()
    
    if taskID == UserData.NewHandLead.GuideList.TownToMap.TaskID then
        local guideState = UserData.NewHandLead:getGuideState("TownToMap")
        if guideState == 0 then
            local data = {name = "TownToMap"}
            UserData.NewHandLead:startNewGuide(data)
        end
    end
end

--完成后删除任务
function TownInterfaceLayer:OnTaskFinished(event)
    local taskID = event._usedata
    self:initTaskListNode()
    
    if taskID == UserData.NewHandLead.GuideList.ExploreLead.TaskID then
        if UserData.NewHandLead:getGuideState("ExploreLead") == 0 and UserData.NewHandLead:isPreGuideCompleted("ExploreLead") then
            local data = {name = "ExploreLead", order = 9}
            UserData.NewHandLead:startNewGuide(data)
        end
    end
    
    if taskID == UserData.NewHandLead.GuideList.FlyRefining.TaskID then
        if UserData.NewHandLead:getGuideState("FlyRefining") == 0 and UserData.NewHandLead:isPreGuideCompleted("FlyRefining") then
--            local data = {name = "FlyRefining", order = 20}
--            if self.main_ui_layer.bottomBar:getUpDownState() ~= true then
--                data.beginStep = 1
--            end
--            UserData.NewHandLead:startNewGuide(data)

            self:showNewHand("FlyRefining")
        end
    end
    
    
    local name = "FlySkillLead"
    if taskID == UserData.NewHandLead.GuideList[name].TaskID then
        local guideState = UserData.NewHandLead:getGuideState("FlySkillLead")
        if guideState == 0 and UserData.NewHandLead:isPreGuideCompleted("FlySkillLead") then
            local data = {name = name}
            UserData.NewHandLead.GuideList[name].curStep = 1
            UserData.NewHandLead:startNewGuide(data)
            
            self:showNewHand(name)
        end
    end
    
    name = "GodWillLead_starUp"
    if UserData.NewHandLead.GuideList[name] ~= nil and taskID == UserData.NewHandLead.GuideList[name].TaskID then
        local guideState = UserData.NewHandLead:getGuideState(name)
        if guideState == 0 and UserData.NewHandLead:isPreGuideCompleted(name) then
            local data = {name = name}
            UserData.NewHandLead.GuideList[name].curStep = 1
            UserData.NewHandLead:startNewGuide(data)
            self:showNewHand(name)
        end
    end

    
end


--放弃任务
function TownInterfaceLayer:OnTaskAbandoned(event)
    local taskID = event._usedata
    self:initTaskListNode()
end

function TownInterfaceLayer:initTaskListNode()
    if Panel_root ~= nil and currentTownID ~= nil and tonumber(currentTownID)  > 0 then
        
        local Node_quest = Panel_root:getChildByName("Node_quest")
        if Node_quest ~= nil then
            Node_quest:removeAllChildren()
            local TaskListNode = require("app.views.Task.TaskListNode"):create()
            Node_quest:addChild(TaskListNode)
            TaskListNode:initUI(tostring(currentTownID),Node_quest)
        end
        
    end
end

return TownInterfaceLayer