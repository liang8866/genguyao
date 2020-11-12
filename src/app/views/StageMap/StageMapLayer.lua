

local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local tableEx = require("common.tableEx")
local StageMapConfig = require("app.views.StageMap.StageMapConfig")
local PlotLayer = require("app.views.Plot.PlotLayer")
local ManegerTask = require("app.views.Task.ManagerTask")
local DataManager = require("app.views.public.DataManager")

local ROLE_MOVE_SPEED = 200  -- 移动速度
local MIN_DISTANCE = 100

local bgList = {}  -- 背景图片列表
local bgOriginalScale = 1.0 -- 背景缩放比例
local bgCurrentAnchorPoint = cc.p(0,0)  -- 保存Panel_root的锚点位置

local multiTouchInfo = {
    scaleMax = 2,     --最大缩放比例
    scaleMin = 0.65,     --最小缩放比例
    lastScale = 1.0,    --保存上次缩放比例

    isAltKeyPressed = false, -- 是否按住左ALT键
    touchPointes = {},  -- 当前触摸的点的坐标
    } -- 触摸信息
    
local mylayer = nil  
local Panel_root = nil
local Image_next = nil
local Node_other = nil
local Button_back = nil
local Node_roadPoint = nil
local Panel_bg = nil
local Button_to_role = nil
local Node_role = nil
local Node_newHand = nil

local visibleSize = nil
local roadPointInfo = {}  --路径点信息列表
local eventPointInfo = {} -- 事件点列表

local role = nil
local delayCallFunction = nil
local roleMoveActionInfo = { panel_root = nil,desPos = nil,currentPos = nil,callBack = nil}
local scheduleUpdate = nil
local worldMapID = nil
local main_ui_layer = nil
local createRoadPointDynamic = false
local currentCell = {x=1,y=1}
    
local StageMapLayer = class("StageMapLayer", function()
    return ccui.Layout:create()
end)

function StageMapLayer:create(worldMapID)
    local view = StageMapLayer.new()
    view:init(worldMapID)
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

function StageMapLayer:ctor()
    
    --重置数据
    roadPointInfo = {} 
    eventPointInfo = {} 
    currentCell = {x=1,y=1}
    createRoadPointDynamic = false
    bgList = {}
end

function StageMapLayer:onEnter()
    cclog("StageMapLayer:onEnter()")
    EventMgr:registListener(EventType.EventOnNoticeAddTask, self, self.OnTaskAdded)
    EventMgr:registListener(EventType.EventOnFinishTask, self, self.OnTaskFinished)
    EventMgr:registListener(EventType.EventOnUpDateTask, self, self.OnTaskParameterChanged)
    EventMgr:registListener(EventType.EventOnAbandonTask, self, self.OnTaskAbandoned)
    
    
    --创建任务Npc
    self:createMapTaskNpc()
    
--    --检测是否需要自动移动到npc
--    if ManagerTask.currentMoveToNpcTaskID > 0 then
--        self:moveToTaskDestination(ManagerTask.currentMoveToNpcTaskID)
--        ManagerTask.currentMoveToNpcTaskID = 0
--    end
    
    --判断是否有可完成任务
    self:checkFinishTask()
    
 
    local SceneManager =  require("app.views.SceneManager")
    if SceneManager.isFirstLoginInApp then
        --local ManagerTask = require("app.views.Task.ManagerTask")
        local nextTaskId =  ManegerTask:getNextCanAcceptedMainTask()
        if nextTaskId > 0 then
            UserData.Task:sendAcceptTask(nextTaskId,1)
        end
    end  
    
    local name = "EnterToJiangDou" 
    local curAcceptedTask = tonumber(UserData.Task.acceptedTaskList[1][1])
    local curTaskID = UserData.NewHandLead.GuideList[name].TaskID
    if curAcceptedTask == curTaskID then
        if UserData.NewHandLead:getGuideState(name) == 0 then
            local data = {name = name}
            UserData.NewHandLead:startNewGuide(data)
            local curTownID = StaticData.Task[curTaskID].TownID
            local townPos = string.split(StaticData.TownMap[tostring(curTownID)].TownPos,"*")
            self:ShowNewHand(cc.p(townPos[1]+50,townPos[2])) 
        end  
    end

    name = "ClickMapEnventPoint"
    curTaskID = UserData.NewHandLead.GuideList.ClickMapEnventPoint.TaskID
    if curAcceptedTask == curTaskID then
        if UserData.NewHandLead:getGuideState(name) == 0 then
            local data = {name = name}
            UserData.NewHandLead:startNewGuide(data)
            local curTownID = StaticData.Task[curTaskID].TownID
            local townPos = string.split(StaticData.TownMap[tostring(curTownID)].TownPos,"*")
            self:ShowNewHand(cc.p(townPos[1]+50,townPos[2])) 
        end
    end
            
    
--    name = "GodWillLead_levelup"
--    curTaskID = UserData.NewHandLead.GuideList[name].TaskID
--    if UserData.NewHandLead:getGuideState(name) == 0 then
--        if ManagerTask:isTaskHaveComplete(curTaskID) then
--            local data = {name = name, order = 2000, beginStep = 1}
--            UserData.NewHandLead.GuideList[name].curStep = 1
--            UserData.NewHandLead:startNewGuide(data)
--            if self.main_ui_layer ~= nil and self.main_ui_layer.bottomBar ~= nil then
--                self.main_ui_layer.bottomBar:showNewHand(name)
--            end
--        end
--    end
--
--    name = "GodWillLead_starUp"
--    curTaskID = UserData.NewHandLead.GuideList[name].TaskID
--    if UserData.NewHandLead:getGuideState(name) == 0 then
--        if ManagerTask:isTaskHaveComplete(curTaskID) then
--            local data = {name = name, order = 2000, beginStep = 1}
--            UserData.NewHandLead.GuideList[name].curStep = 1
--            UserData.NewHandLead:startNewGuide(data)
--            if self.main_ui_layer ~= nil and self.main_ui_layer.bottomBar ~= nil then
--                self.main_ui_layer.bottomBar:showNewHand(name)
--            end
--        end
--    end
--
--    name = "FlySkillLead"
--    curTaskID = UserData.NewHandLead.GuideList[name].TaskID
--    if UserData.NewHandLead:getGuideState(name) == 0 then
--        if ManagerTask:isTaskHaveComplete(curTaskID) then
--            local data = {name = name, order = 2000, beginStep = 1}
--            UserData.NewHandLead.GuideList[name].curStep = 1
--            UserData.NewHandLead:startNewGuide(data)
--            if self.main_ui_layer ~= nil and self.main_ui_layer.bottomBar ~= nil then
--                self.main_ui_layer.bottomBar:showNewHand(name)
--            end
--        end
--    end
        
end

function StageMapLayer:onExit()
    cclog("StageMapLayer:onExit()")
    EventMgr:unregistListener(EventType.EventOnNoticeAddTask, self, self.OnTaskAdded)
    EventMgr:unregistListener(EventType.EventOnFinishTask, self, self.OnTaskFinished)
    EventMgr:unregistListener(EventType.EventOnUpDateTask, self, self.OnTaskParameterChanged)
    EventMgr:unregistListener(EventType.EventOnAbandonTask, self, self.OnTaskAbandoned)
    
    if scheduleUpdate ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
    end
    audio.stopMusic(false)
end

--初始化
function StageMapLayer:init(mapID)
    visibleSize = cc.Director:getInstance():getVisibleSize()
    self.name = "StageMapLayer"
    self:setName("StageMapLayer")
    worldMapID = mapID
    
    local worldMapStaticData = StaticData.WorldMap[worldMapID]
    if worldMapStaticData == nil then
        cclog("world map id is not find in StaticData.WorldMap.")
        return 
    end
    mylayer =  cc.CSLoader:createNode("csb/stageMapLayer.csb")
    mylayer:setName("stageMapLayer_csb_root")
    self:addChild(mylayer)
    
    local root = mylayer:getChildByName("Panel_root")
    Panel_root = root
    Panel_root:setContentSize(cc.size(worldMapStaticData.MapWidth,worldMapStaticData.MapHeight))  
    Panel_root:setPosition(cc.p(worldMapStaticData.ScreenCenterX,worldMapStaticData.ScreenCenterY))
    Panel_root:setAnchorPoint(cc.p(0,0))


    --初始化Button_back并设置事件
    Button_back = mylayer:getChildByName("Button_back")
    Button_back:setPositionY(display.height - 60 )
    --回到角色位置
    Button_to_role = mylayer:getChildByName("Button_to_role")
    Button_to_role:setPosition(974,200)
    Button_to_role:setVisible(false)
    
    Panel_bg = Panel_root:getChildByName("Panel_bg")
    Panel_bg:setPosition(cc.p(0,0))
    Panel_bg:setTouchEnabled(false)

    --Create Node_roadPoint
    Node_roadPoint = Panel_root:getChildByName("Node_roadPoint")
    

    --Create Node_eventPoint
    local Node_eventPoint = Panel_root:getChildByName("Node_eventPoint")

    --Create Node_other
    Node_other = Panel_root:getChildByName("Node_other") --指向下一个
    Node_other:setLocalZOrder(9)
    Image_next = Node_other:getChildByName("Image_next")
    Image_next:setVisible(false)

    Node_newHand = Panel_root:getChildByName("Node_newHand")
    
    Node_newHand:setVisible(false)
    Node_role = Panel_root:getChildByName("Node_role")
    Node_role:setLocalZOrder(10)

    local Image_ship = Node_role:getChildByName("Image_ship")
    local Image_role = Node_role:getChildByName("Image_role")
    Image_ship:ignoreContentAdaptWithSize(true)
    Image_role:ignoreContentAdaptWithSize(true)
    
    self:attachEvent()

    bgCurrentAnchorPoint = Panel_root:getAnchorPoint()
    local scale = math.min(bgOriginalScale,multiTouchInfo.scaleMax)
    bgOriginalScale = 1  --进入默认缩放比例
    scale = math.max(scale, multiTouchInfo.scaleMin)
    Panel_root:setScale(scale)
    bgOriginalScale = scale
    --Node_role:setScale(1/scale)
    role = Node_role
    
    cclog("worldMapID = " .. tostring(worldMapID))
    
    
    createRoadPointDynamic = false
    if worldMapStaticData.BlockNumX > 3 or worldMapStaticData.BlockNumY > 3 then
        createRoadPointDynamic = true
    end
    
    self:initAllRoadPointInfo(worldMapID,createRoadPointDynamic)  --初始化城镇点
        
    local cx, cy = Panel_root:getPosition()
    cx = cx - visibleSize.width/2
    cy = cy - visibleSize.height/2
    local i,j = self:getIndexByPos(math.abs(cx),math.abs(cy))


    self:initUserInfo()
    self:updateStageContent()

    
    
    self:setNextTownPoint()

    audio.playMusic("audioMusic/mapBg.mp3",true)
    audio.setMusicVolume(0.1)

--    local FileNode_TaskTracker = mylayer:getChildByName("FileNode_TaskTracker")
--    local TaskTrackerUI  =  require("app.views.Task.TaskTrackerUI")
--    local taskTracer = TaskTrackerUI:create()
    --    taskTracer:setName("taskTracer")
    --    FileNode_TaskTracker:removeAllChildren()
--    FileNode_TaskTracker:addChild(taskTracer)
    --    taskTracer:setPosition(cc.p(-90,-250))
    --    taskTracer:reCreateList()


    main_ui_layer = require("app.views.Main.MainUILayer"):create()   
    self:addChild(main_ui_layer,10)
    
--    local townTaskTypeList = ManagerTask:getCanAcceptedTaskTownList(worldMapID,roadPointInfo)
--    dump(townTaskTypeList)
    
end    

function StageMapLayer:resetMapUserData()
end

function StageMapLayer:checkFinishTask()
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
end


function StageMapLayer:createMapTaskNpc()
    local taskList = ManagerTask:getAcceptedTaskList()
    for i=1,#taskList do
        if tonumber(taskList[i][1]) ~= nil then
            local taskID = tonumber(taskList[i][1])
            local  data  = StaticData.Task[taskID]
            local needCreateNpc = tonumber(taskList[i][2]) > 0 and tonumber(taskList[i][4]) > tonumber(taskList[i][5])
            local taskMapID = StaticData.TownMap[tostring(data.TownID)].WorldMapId
            if data.CityType == 0  and needCreateNpc and taskMapID == worldMapID then --说明是地图上的任务  --worldMapID
                self:addNpcToMapLayer(taskID)
            end
        end
    end
end


function StageMapLayer:getNextPointID()
    
    local townId = nil
    local eventPointID = nil
    local pointList = {}
    for key,value in pairs(roadPointInfo) do
        if roadPointInfo[key].over == false then
            table.insert(pointList,tonumber(key))
        end
    end
    table.sort(pointList)
    townId = pointList[1] ~= nil and tostring(pointList[1]) or nil -- 最大的已解锁的城镇节点
    cclog("getNextPointID townId = " .. tostring(townId))
    
    local function comps(a,b)
        local pointIdStr1 = string.split(a,"_")
        local pointIdStr2 = string.split(b,"_")
        if tonumber(pointIdStr1[1]) < tonumber(pointIdStr2[1]) then
            return true
        elseif tonumber(pointIdStr1[1]) > tonumber(pointIdStr2[1]) then
            return false
        else
            if pointIdStr1[2] ~= nil then
                if tonumber(pointIdStr1[2]) < tonumber(pointIdStr2[2]) then
                    return true
                elseif tonumber(pointIdStr1[2]) > tonumber(pointIdStr2[2]) then
                    return false
                else
                    if pointIdStr1[3] ~= nil then 
                        return tonumber(pointIdStr1[3]) < tonumber(pointIdStr2[3])
                    else
                        return false
                    end
                    
                end
            else
                return false
            end
        end 
        return false
    end
    
    local eventPointIdList = {}
    for key,value in pairs(eventPointInfo) do
        if eventPointInfo[key].over == false then
            table.insert(eventPointIdList,key)
        end
    end
    table.sort(eventPointIdList,comps)
    if #eventPointIdList > 0 then
        eventPointID = tostring(eventPointIdList[1])  -- 最大的已解锁的事件节点
    end
    cclog("getNextPointID eventPointID = " .. tostring(eventPointID))
    
    return townId,eventPointID

end

function StageMapLayer:removeNextTownPointFlag(taskID)
    local nextID = ""
    if StaticData.Task[nextMainTaskID] ~= nil then
        nextID = tostring(StaticData.Task[nextMainTaskID].TownID)
    end
    local SceneManager = require("app.views.SceneManager")
    local layer = SceneManager:getGameLayer("StageMapLayer")
    if nextID ~= "" and nextID ~= nil and layer ~= nil then
        local townPointInfo = roadPointInfo[nextID]
        if townPointInfo ~= nil and Node_other ~= nil then
            if Node_other.getChildByName ~= nil then
                local child = Node_other:getChildByName("skeletonNode")
                if child ~= nil then
                    Node_other:removeChildByName("skeletonNode")
                    child = nil
                end
            end
        end
     end
end

function StageMapLayer:setNextTownPoint()
    --设置nextOpenedTownID
    --local nextID = UserData.Map.nextOpenedTownID
    local nextID = ""
    local nextMainTaskID = 0
    if UserData.Task.acceptedTaskList[1][1] ~= "nil" then
        nextMainTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
    else
        nextMainTaskID = ManagerTask:getNextMainTaskId(UserData.Task.recentlyTaskId)
    end
    if StaticData.Task[nextMainTaskID] ~= nil then
        nextID = tostring(StaticData.Task[nextMainTaskID].TownID)
    end
    local SceneManager = require("app.views.SceneManager")
    local layer = SceneManager:getGameLayer("StageMapLayer")
    if nextID ~= "" and nextID ~= nil  then
        local townPointInfo = roadPointInfo[nextID]
        --local isTown = self:isMainTown(nextID)

        if townPointInfo ~= nil and Node_other ~= nil then    
            --            Image_next:stopAllActions()
            --            --Image_next:loadTexture("ui/stageMap/icon_next.png",0)
            --            Image_next:setPosition(cc.p(townPointInfo.pos.x,townPointInfo.pos.y+70))
            --            local posX,posY = Image_next:getPosition()
            --            local moveto1 = cc.MoveTo:create(0.3, cc.p(posX,posY-5))
            --            local moveto2 = cc.MoveTo:create(0.3, cc.p(posX,posY+5))
            --            Image_next:runAction(cc.RepeatForever:create(cc.Sequence:create(moveto1,moveto2)))
            local isTown = townPointInfo.isMainTown
            if Node_other.getChildByName ~= nil then
                local child = Node_other:getChildByName("skeletonNode")
                if child ~= nil then
                    Node_other:removeChildByName("skeletonNode")
                    child = nil
                end
                if child == nil then
                    child = self:createNextAnimation()
                    Node_other:addChild(child)
                    child:setName("skeletonNode")
                end
                local animName = isTown and "load" or "load_2"
                child:setAnimation(0, animName, true)
                cclog("setNextTownPoint() setAnimation animName = " .. animName)
                child:setPosition(cc.p(townPointInfo.pos.x,townPointInfo.pos.y))
            end
        end
    end

end

function StageMapLayer:createNextAnimation()
    local SpineJson = "spine/ui/ui_zhiyingjuanzhou.json"
    local SpineAtlas = "spine/ui/ui_zhiyingjuanzhou.atlas"

    local skeletonNode = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    --skeletonNode:setAnimation(0, "load", true)
    skeletonNode:setPosition(0,0)
    return skeletonNode
end

function StageMapLayer:initUserInfo()

    local curPointInfo = {}
    local lastPointStr = DataManager:getStringForKey("roleStayPoint")
    local pointTab = string.split(lastPointStr,"-")
    local lastPoint = cc.p(0,0)
    local lastPointID = ""
    if pointTab ~= nil and #pointTab == 2 then
        lastPoint.x = tonumber(pointTab[1])
        lastPoint.y = tonumber(pointTab[2])
    else
         
        lastPointID = "612001"
        local curTask = tonumber(UserData.Task.acceptedTaskList[1][1])
        if curTask ~= nil and curTask > 0 then
            local curTownID = StaticData.Task[curTask].TownID
            
            if curTownID > 1000 then
                lastPointID = tostring(curTownID)
                local curWorldMapID = StaticData.TownMap[tostring(curTownID)].WorldMapId
                UserData.Map.currentWorldMapID = curWorldMapID
            end
        end
        local pointInfo = self:getPointInfo(lastPointID)
        if pointInfo ~= nil then
            lastPoint = pointInfo.pos
        else
            local TownPos = StaticData.TownMap[tostring(lastPointID)].TownPos
            local posTab = string.split(TownPos,"*")
            lastPoint = cc.p(tonumber(posTab[1]),tonumber(posTab[2]))
        end
        
        DataManager:setStringForKey("roleStayPoint",lastPoint.x .. "-" .. lastPoint.y)
    end
    UserData.Map.roleStayPoint = lastPoint

    self:createRole(lastPoint)
end

function StageMapLayer:createRole(pos)
    if pos == nil then
        return
    end

    local scale = Panel_root:getScale()
    Panel_root:setPosition(cc.p(-pos.x*scale + visibleSize.width/2,(-pos.y+160)*scale + visibleSize.height/2))
    local posX,posY = Panel_root:getPosition()
    cclog("Panel_root pos = (" ..tostring(posX) .. ",".. tostring(posY) .. ")")
    posY = posY - visibleSize.height/2
    self:correctPosition(posX,posY)
    --[[
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Armature/td_boss_02.ExportJson")
    role = ccs.Armature:create("td_boss_02")
    role:getAnimation():play("load")
    role:setPosition(cc.p(pos.x,pos.y))
    role:setAnchorPoint(cc.p(0.5,0.5)) 
    Panel_root:addChild(role)
    ]]

    if role == nil then
        Node_role = Panel_root:getChildByName("Node_role")
        role = Node_role
        --role:setScale(1/scale)
    end
    role:setPosition(cc.p(pos.x,pos.y+50))
    role:setAnchorPoint(cc.p(0.5,0.5)) 
 
    
    UserData.Map.roleIsMoving = false

    local Image_ship = role:getChildByName("Image_ship")
    local Image_role = role:getChildByName("Image_role")
    local fibbleId = UserData.BaseInfo.nFibbleId
    if fibbleId > 0 then
        local sFibbleIconID = tonumber(FightStaticData.flyingObject[fibbleId].sImg)
        local sFibbleIcon = StaticData.Icon[sFibbleIconID].path
        Image_ship:loadTexture(sFibbleIcon)
        --Image_ship:setScale(0.66)
    end
    local userImageID = UserData.BaseInfo.userImageID
    if userImageID > 0 then
        local userImage = StaticData.Icon[userImageID].path
        Image_role:loadTexture(userImage)
        --Image_role:setContentSize(cc.size(80,80))
    end
    --self:updateLineState()

end


function StageMapLayer:checkRoleInScreen()
    local needMoveToscreen = false
    if UserData.Map.roleStayPoint ~= nil then
        local pos = UserData.Map.roleStayPoint
        local posInWorld = Panel_root:convertToWorldSpace(cc.p(pos.x,pos.y))
        local posInScreen = mylayer:convertToNodeSpace(posInWorld)
        local bShowRoleReturnButton = false
        if posInScreen.x < 0 or posInScreen.x > visibleSize.width or posInScreen.y < 0 or posInScreen.y > visibleSize.height then
            bShowRoleReturnButton = true
            needMoveToscreen = true
        end
        if Button_to_role ~= nil then
            Button_to_role:setVisible(bShowRoleReturnButton)
        end
    end
    return needMoveToscreen
end

-- 触摸事件处理
function StageMapLayer:attachEvent()
    --[[    
    -- 单点触摸
    local listener = cc.EventListenerTouchOneByOne:create()
    local halfWidth = visibleSize.width/2

    -- 开始
    listener:registerScriptHandler(function(touch, event)
            return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )

    -- 移动
    listener:registerScriptHandler(function(touch, event)
    self:handleMove(touch)
    end,cc.Handler.EVENT_TOUCH_MOVED )

    -- 结束
    listener:registerScriptHandler(function(touch, event)
    print("StageMapLayer touch end")
    self:handeEnded(touch)
    end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    ]]
    -- 多点触摸
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(function(touches, event)
        multiTouchInfo.touchPointes = {}
        for i=1,#touches do
            multiTouchInfo.touchPointes[i] = touches[i]:getLocation()
        end
        
        return true
    end,cc.Handler.EVENT_TOUCHES_BEGAN )

    -- 移动
    listener:registerScriptHandler(function(touches, event)
        --dump(touches)
        if #touches == 2 or multiTouchInfo.isAltKeyPressed == true then -- 多点触摸，缩放操作
            self:handlePinchZoom(touches)
        else    
            local touch = touches[1]
            self:handleMove(touch)
            
        end
        
    end,cc.Handler.EVENT_TOUCHES_MOVED )

    -- 结束
    listener:registerScriptHandler(function(touches, event)
        --print("StageMapLayer touches end")
        --dump(touches)
        if #touches == 1 and multiTouchInfo.isAltKeyPressed == false then  -- 单点触摸的情况
            local touch = touches[1]
            local point = touches[1]:getLocation()
            self:handeEnded(point)
        else
            --双指触摸不需处理
        end
        self:checkRoleInScreen()
    end,cc.Handler.EVENT_TOUCHES_ENDED )
    
    -- 取消
    listener:registerScriptHandler(function(touch, event)
        print("StageMapLayer touches canceled")

    end,cc.Handler.EVENT_TOUCHES_CANCELLED )
    
    --    local eventDispatcher = Panel_root:getEventDispatcher()
    --    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, Panel_root)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    
    --键盘事件
    local function keyboardPressed(keyCode, event)
        --local id = Math.random(100,1000)
        -- cc.Director:getInstance():getOpenGLView():handleTouchesBegin(1, id, 100,100);
        cclog("keyboardPressed keyCode = " .. cc.KeyCodeKey[keyCode + 1])
        if keyCode == 16 then --KEY_ALT  left
            multiTouchInfo.isAltKeyPressed = true
        end
    end

    local function keyboardReleased(keyCode, event)
        cclog("keyboardReleased 111 ")
        multiTouchInfo.isAltKeyPressed = false
        multiTouchInfo.touchPointes = {}
    end
    local listenerKeyBoard = cc.EventListenerKeyboard:create()
    listenerKeyBoard:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listenerKeyBoard:registerScriptHandler(keyboardReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)

    eventDispatcher:addEventListenerWithSceneGraphPriority(listenerKeyBoard, self)

    -- 添加返回按钮事件
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            cclog("StageMapLayer onEventTouchButton,name = "  .. sender:getName())
            audio.stopMusic(false)
            self:removeFromParent()
            local SceneManager = require("app.views.SceneManager")
            SceneManager:switch(SceneManager.SceneName.SCENE_WORLDMAPLAYER)

        end
    end
    Button_back:addTouchEventListener(onEventTouchButton)
    Button_back:setPressedActionEnabled(true)
    --Button_back:ignoreContentAdaptWithSize(true)

    local function onBackToRolePosButtonClicked(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            --cclog("StageMapLayer onBackToRolePosButtonClicked,name = "  .. sender:getName())
            self:backToRolePos()
        end
    end
    Button_to_role:addTouchEventListener(onBackToRolePosButtonClicked)
    Button_to_role:setPressedActionEnabled(true)
end

function StageMapLayer:backToRolePos()
   
    local pos = UserData.Map.roleStayPoint
    local scale = Panel_root:getScale()
    Panel_root:setPosition(cc.p(-pos.x*scale + visibleSize.width/2,(-pos.y+160)*scale + visibleSize.height/2))
    local posX,posY = Panel_root:getPosition()
    --cclog("Panel_root pos = (" ..tostring(posX) .. ",".. tostring(posY) .. ")")
    self:correctPosition(posX,posY)
end


--双指缩放
function StageMapLayer:handlePinchZoom(touches)
    
    local addedTempTouchPos = { previousLocation = cc.p(100,100),location = cc.p(100,100) }
    if #touches == 2 then  -- 真机上双指操作
       addedTempTouchPos.previousLocation = touches[2]:getPreviousLocation()
       addedTempTouchPos.location = touches[2]:getLocation()
       
    end
    
    local previousDistance = cc.pGetDistance(touches[1]:getPreviousLocation(),addedTempTouchPos.previousLocation)
    local currentDistance = cc.pGetDistance(touches[1]:getLocation(),addedTempTouchPos.location)
    
    local posMid = Panel_root:getAnchorPoint()
    
    local needChangeValue = false
    local touchPosInNodeSpace2 = nil -- 第二个点在背景中的坐标
    if multiTouchInfo.isAltKeyPressed == false then
        needChangeValue = multiTouchInfo.touchPointes[1] ~= touches[1]:getLocation() or multiTouchInfo.touchPointes[2]  ~= touches[2]:getLocation()
        touchPosInNodeSpace2 = Panel_root:convertToNodeSpace(touches[2]:getLocation())
    else
        needChangeValue = multiTouchInfo.touchPointes[1] ~= touches[1]:getLocation()
        touchPosInNodeSpace2 = Panel_root:convertToNodeSpace(addedTempTouchPos.location)
    end
    if needChangeValue then
        posMid = cc.pMidpoint(Panel_root:convertToNodeSpace(touches[1]:getLocation()) , touchPosInNodeSpace2);
        posMid.x = posMid.x/(Panel_root:getContentSize().width * bgOriginalScale);
        posMid.y = posMid.y/(Panel_root:getContentSize().height * bgOriginalScale);

        for i=1,#touches do
            multiTouchInfo.touchPointes[i] = touches[i]:getLocation()
        end
        --cclog("handlePinchZoom bgCurrentAnchorPoint = " .. tostring(bgCurrentAnchorPoint))
        --cclog("handlePinchZoom posMid = " .. tostring(posMid))
        bgCurrentAnchorPoint = posMid
    else
        posMid = bgCurrentAnchorPoint
    end

    local anchorPointOld = Panel_root:getAnchorPoint()
    local sz = Panel_root:getContentSize()
    local scaleOld = Panel_root:getScale()
    local posOldX, posOldY = Panel_root:getPosition()
     
    local scale = math.min(scaleOld + (currentDistance-previousDistance)/100,multiTouchInfo.scaleMax)
    scale = math.max(scale, multiTouchInfo.scaleMin)
    
    
    --local x = (posMid.x- anchorPointOld.x)*sz.width*scaleOld + posOldX
    --local y = (posMid.y- anchorPointOld.y)*sz.height*scaleOld + posOldY
    --cclog("handlePinchZoom oldPos(x,y) = (" .. tostring(Panel_root:getPositionX()) .. "," .. tostring(Panel_root:getPositionY()) .. ")")
    --cclog("handlePinchZoom pos(x,y) = (" .. tostring(x) .. "," .. tostring(y) .. ")")
    --Panel_root:setPosition(x,y)
    --Panel_root:setAnchorPoint(posMid)
    
    --local sz_new = Panel_root:getContentSize()
    --cclog("handlePinchZoom scale = " .. tostring(scale) )    
    --cclog("handlePinchZoom scaleOld = " .. tostring(scaleOld) )
    --cclog("handlePinchZoom sz(w,h) = (" .. tostring(sz.width) .. "," .. tostring(sz.height) .. ")") 
    --cclog("handlePinchZoom sz_new(w,h) = (" .. tostring(sz_new.width) .. "," .. tostring(sz_new.height) .. ")") 
    --cclog("handlePinchZoom anchorPoint,old(x,y) = (" .. tostring(anchorPoint.x) .. "," .. tostring(anchorPoint.y) .. ")")   
    --cclog("handlePinchZoom anchorPoint,posMid(x,y) = (" .. tostring(posMid.x) .. "," .. tostring(posMid.y) .. ")")
    
    --恢复锚点位置为(0,0)，方便边界判断
    --local xx = (0- posMid.x)*sz.width*scale + x
    --local yy = (0- posMid.y)*sz.height*scale + y
    
    local aaa = (scaleOld - scale)*posMid.x*sz.width - anchorPointOld.x*sz.width*scaleOld + posOldX
    local bbb = (scaleOld - scale)*posMid.y*sz.height - anchorPointOld.y*sz.height*scaleOld +posOldY
    local correctPosX,correctPosY = self:CheckBorder(aaa,bbb)

    Panel_root:setPosition(correctPosX,correctPosY)
    Panel_root:setScale(scale)
    --role:setScale(1/scale)

    --Panel_root:setAnchorPoint(0,0)
    --cclog("handlePinchZoom new pos(x,y) = (" .. tostring(xx) .. "," .. tostring(yy) .. ")")

    --self:correctPosition(curPosX,curPosY)
end

--检测边界
function StageMapLayer:CheckBorder(curPosX,curPosY)

    local anchorPoint = Panel_root:getAnchorPoint()
    local anchorPointInPoints = Panel_root:getAnchorPointInPoints()
    local sz = Panel_root:getContentSize()
    local scale = Panel_root:getScale()
    --cclog("CheckBorder scale = " .. tostring(scale))
    
    if curPosX < 0 - sz.width*scale + visibleSize.width then  -- 最右边沿
        curPosX = 0 - sz.width*scale + visibleSize.width
    end
    if curPosX > 0  then  -- 最左边沿
        curPosX = 0
    end

    if curPosY < 0 - sz.height*scale + visibleSize.height then  -- 最上边沿
        curPosY = 0 - sz.height*scale + visibleSize.height
    end
    if curPosY > 0  then  -- 最下边沿
        curPosY = 0
    end
    
    
    return curPosX,curPosY
end

function StageMapLayer:correctPosition(curPosX,curPosY)
    local correctPosX,correctPosY = self:CheckBorder(curPosX,curPosY)

    --cclog("correctPosX = " .. tostring(correctPosX) .. ",correctPosY = " .. tostring(correctPosY))

    --判断边界
    Panel_root:setPosition(cc.p(correctPosX,correctPosY))

end

--单指操作时的背景移动处理
function StageMapLayer:handleMove(touch)
    local deltaY =  touch:getDelta().y
    local deltaX =  touch:getDelta().x
    local scale = Panel_root:getScale()
    --cclog("handleMove scale= " .. tostring(scale))
    local curPosY = Panel_root:getPositionY()+deltaY
    local curPosX = Panel_root:getPositionX()+deltaX

    --cclog("deltaX = " .. tostring(deltaX) .. ",deltaY = " .. tostring(deltaY) .. ",curPosX = " .. tostring(curPosX) .. ",curPosY = " .. tostring(curPosY))
    self:correctPosition(curPosX,curPosY)

end

--单指操作时的触摸结束
function StageMapLayer:handeEnded(touchPoint)

    cclog("handeEnded:pos x=%0.2f, y=%0.2f", touchPoint.x, touchPoint.y)

    local OperateUI = main_ui_layer.bottomBar
    if OperateUI:getUpDownState() then
        OperateUI:setUpDownStateToDown()
        return
    end

    local isClicked = false -- 是否是单击屏幕地图
    if multiTouchInfo.touchPointes ~= nil and #multiTouchInfo.touchPointes == 1 then
        if self:isSamePoint(multiTouchInfo.touchPointes[1],touchPoint) == true then -- 释放时的点与点击按下的点位于同一位置，说明不是点击拖动操作

            local posInBg = Panel_root:convertToNodeSpace(touchPoint)
            local townID = self:checkPointInTownRect(posInBg)
            
            self:moveRoleToMapPoint(posInBg,townID)
            
        else
            if createRoadPointDynamic == true then
                self:updateStageContent()
            end
        end
    end
end


function StageMapLayer:checkPointInTownRect(pos)
    for key,value in pairs(roadPointInfo) do
        if value.pos ~= nil and cc.pGetDistance(value.pos,pos) < MIN_DISTANCE then
            return key
        end
    end
    return ""
end

function StageMapLayer:isSamePoint(pos1,pos2)

    return cc.pGetDistance(pos1,pos2) < 5
end




function StageMapLayer:moveRoleToMapPoint(pos,pointID)
    local notneedChange = false
    if roleMoveActionInfo.desPos ~= nil then
        notneedChange = cc.pGetDistance(roleMoveActionInfo.desPos,pos) < MIN_DISTANCE/2
    end
    cclog("moveRoleToMapPoint notneedChange=" .. tostring(notneedChange))
    if UserData.Map.roleIsMoving and notneedChange then
        
        return
    end
    roleMoveActionInfo.desPos = cc.p(pos.x,pos.y)
    if role == nil then
        cclog("role is moving now,role is nil.")
        Node_role = Panel_root:getChildByName("Node_role")
        role = Node_role
    end
    local x,y = role:getPosition()
    roleMoveActionInfo.currentPos = cc.p(x,y)
    roleMoveActionInfo.currentPointID = pointID
    local function update(dt)
        if self.roleMoveUpdate ~= nil then
            self:roleMoveUpdate(dt)
        end
    end
    
    if scheduleUpdate ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
    end
    scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0 ,false)
    UserData.Map.roleIsMoving = true  

    --判断role是否在屏幕内，不在则移动到屏幕内
    if self:checkRoleInScreen() then
        self:backToRolePos()
    end
end

--更新场景中内容
function StageMapLayer:updateStageContent()
    if createRoadPointDynamic then
        local cx, cy = Panel_root:getPosition()
        
        cx = cx - visibleSize.width/2
        cy = cy - visibleSize.height/2
        
        --cclog("updateStageContent: Panel_root pos x=%0.2f, y=%0.2f", cx,cy)
        local i,j = self:getIndexByPos(math.abs(cx),math.abs(cy))
        --cclog("updateStageContent: i=%0.2f, j=%0.2f", i,j)
    
        
        if currentCell.x ~= i or currentCell.y ~= j then

            currentCell.x = i
            currentCell.y = j
            self:updateBgSprite()
        end
    else
        -- 一次加载 所有分块
        self:updateBgAllSprite()
    end
    
end


function StageMapLayer:getPointInfo(pointID)
    for key ,value in pairs(roadPointInfo) do
        if value.id == pointID then
            return value
        end
    end
    for key ,value in pairs(eventPointInfo) do
        if value.id == pointID then
            return value
        end
    end
    return nil
end

function StageMapLayer:updateLineState()
--[[ -- local lineInfo = {}
print("1111111111111 updateLineState ")
    for key,value in pairs(lineInfo) do
        local fromRoadPointID = value.from
        local toRoadPointID = value.to
        local color = cc.c3b(48,48,48)
        if roadPointInfo[fromRoadPointID] ~= nil and roadPointInfo[toRoadPointID] ~= nil then
            if roadPointInfo[fromRoadPointID].over == true and  roadPointInfo[toRoadPointID].over == true then
                color = cc.c3b(255,255,255)
            end
        end
        value.image:setColor(color)
    end
]]
    
--[[   
for key,value in pairs(eventPointInfo) do

self:updateEventPoint( value.id)
end
]]
end

-- 当前事件点是否需要显示
function StageMapLayer:updateEventPoint(eventPointID)
    if eventPointInfo[eventPointID] ~= nil then
        local fromTownID = eventPointInfo[eventPointID].from
        local toTownID = eventPointInfo[eventPointID].to

        local aa = roadPointInfo[fromTownID]
        local bb = roadPointInfo[toTownID]
        local cc = eventPointInfo[eventPointID]


        if (roadPointInfo[fromTownID].over == true and roadPointInfo[toTownID].over ~= true) then
            eventPointInfo[eventPointID].node:setVisible(true)
            eventPointInfo[eventPointID].Image_quest_mark:setVisible(eventPointInfo[eventPointID].over ~= true)
            eventPointInfo[eventPointID].Image_line_bg:setVisible(eventPointInfo[eventPointID].over == true)
            
            if self:isAllEventPointOverInThisLine(eventPointID) == true then
                eventPointInfo[eventPointID].node:setVisible(false)
            end
	    else
            eventPointInfo[eventPointID].node:setVisible(false)
	    end
	end
end

function StageMapLayer:isAllEventPointOverInThisLine(eventPointID)
    local allOver = true
    local eventPointIDList = self:getAllEventPointID(eventPointID)
    for i=1,#eventPointIDList do
        if eventPointIDList[i].over ~= true then
            allOver = false
            return allOver 
        end
    end
    return allOver 
end

function StageMapLayer:getAllEventPointID(eventPointID)
    local eventPointIDTemp = {}
    local indexTab = string.split(eventPointID,"_")

    for key,value in pairs(eventPointInfo) do
        local i,j = string.find(key,indexTab[1] .. "_" .. indexTab[2])
        if i ~= nil and j ~= nil then
            table.insert(eventPointIDTemp,key)
        end
    end
    return eventPointIDTemp
end


function StageMapLayer:getOverStateById(townID)
    local isOver = false
    local mapID = StaticData.TownMap[tostring(townID)].WorldMapId
    if UserData.Map.openedTownIDlist[mapID] ~= nil then
        if UserData.Map.openedTownIDlist[mapID][tonumber(townID)] ~= nil then
            isOver = true
        end
    end
    return isOver
    
--    local curMainTaskID = UserData.Task.recentlyTaskId
--    if UserData.Task.acceptedTaskList[1][1] ~= "nil" then
--        curMainTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
--    else
--        curMainTaskID = ManagerTask:getNextMainTaskId(UserData.Task.recentlyTaskId)
--    end
--    
--    local townStaticDataInfo = StaticData.TownMap[tostring(townID)]
--    if curMainTaskID > 0 then
--        if StaticData.Task[curMainTaskID].TownID == tonumber(townID) then
--            return false
--        else
--            return curMainTaskID > tonumber(townStaticDataInfo.OpenCondition2) 
--        end
--    else
--        if UserData.Task.recentlyTaskId > 0  then
--            if StaticData.Task[UserData.Task.recentlyTaskId].TownID == tonumber(townID) then
--                return true
--            else
--                return UserData.Task.recentlyTaskId >= tonumber(townStaticDataInfo.OpenCondition2) 
--            end
--        end
--    end
end

--是否是城镇
function StageMapLayer:isMainTown(pointID)
    --    local i,j = string.find(pointID,"_")
    --    if i~= nil and j ~= nil then
    --    	return false
    --    end
    --    return true
    local staticTownInfo = StaticData.TownMap[pointID]
    if staticTownInfo ~= nil and staticTownInfo.TownType == 0 then -- 0:城镇，1:事件点
        return true
    end
    return false
end

--function StageMapLayer:getNextTownID(pointID)
--    if StaticData.TownMap[pointID] ~= nil then
--        local curTownPreTaskID = tonumber(StaticData.TownMap[pointID].OpenCondition2)
--        local curMainTaskID = tonumber(UserData.Task.recentlyTaskId)
--        if UserData.Task.acceptedTaskList[1][1] ~= "nil" then
--            curMainTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
--        end 
--        if curMainTaskID > curTownPreTaskID then
--            return StaticData.TownMap[pointID].NextTownID
--        else
--            return UserData.Map.nextOpenedTownID
--        end
--    end
--    return UserData.Map.FIRST_TOWN_ID
--end

--function StageMapLayer:getNextEventPointID(pointID)
--    if StaticData.TownMap[pointID] ~= nil then
--        return StaticData.TownMap[pointID].NextTownID
--    end
--    return ""
--end

--function StageMapLayer:checkCanBeMove(pointInfo)
--    if pointInfo == nil then
--        return false
--    end
--    if pointInfo.over == true then --已经开启，则可以直接走
--        return true
--    end
--    local staticInfo = self:getPointInfoByNextPointID(pointInfo.id)
--    local pointInfoPrev = self:getPointInfo(staticInfo.TownId)
--    if pointInfoPrev ~= nil then  
--        if pointInfoPrev.over == false then
--            return false
--        end
--    end
--    return true
--end
--
--function StageMapLayer:getPointInfoByNextPointID(nextPointID)
--    for key,value in pairs(StaticData.TownMap) do
--        if value.NextTownID == nextPointID or value.NextTownID == nextPointID then
--            return value
--        end
--    end
--    return nil
--end


--====================== 加载地图所有区块背景 =====================
function StageMapLayer:updateBgAllSprite()
    local worldMapId = self.worldMapID
    
    local maxX = StaticData.WorldMap[worldMapID].BlockNumX
    local maxY = StaticData.WorldMap[worldMapID].BlockNumY
    
    local beginX ,endX = 1,maxX
    local beginY , endY = 1,maxY
    
    local mapImagePath = StaticData.WorldMap[worldMapID].MapImagePath
    
    for j=beginY,endY do
        for i=beginX,endX do
            local index = (j-1)*maxX + (i-1) + 1
            --cclog("index=".. tostring(index))
            local bgImageName = string.format("%d_%d_%d",worldMapID,(maxX*maxY),index)
            if bgList == nil then
                bgList = {}
            end

            if bgList[bgImageName] == nil then
                bgList[bgImageName] = {}
            end

            bgList[bgImageName].index = index
            bgList[bgImageName].bgImageName = bgImageName
            bgList[bgImageName].i = i
            bgList[bgImageName].j = j
            bgList[bgImageName].used = true
            bgList[bgImageName].pos = cc.p( (i-1)*1024,(j-1)*576 )
            
            local bg = cc.Sprite:create( mapImagePath .. bgImageName .. ".png")
            bg:setAnchorPoint(cc.p(0.0,0.0))
            bg:setPosition( bgList[bgImageName].pos)
            bg:setName(bgImageName)
            Panel_bg:addChild(bg)

            bgList[bgImageName].bg = bg
            bgList[bgImageName].parent = Panel_bg
        end
    end
end

--====================== 分区块加载地图背景 =====================
function StageMapLayer:updateBgSprite()
    local worldMapId = self.worldMapID
    local cellX,cellY = currentCell.x,currentCell.y
    cclog("StageMapLayer:updateBgSprite() : worldMapID = " .. tostring(worldMapID))
    if worldMapID == nil then
        cclog("StageMapLayer:updateBgSprite() : worldMapID = nil nil nil")
    end
    local maxX = StaticData.WorldMap[worldMapID].BlockNumX
    local maxY = StaticData.WorldMap[worldMapID].BlockNumY
    cclog("cellX=" .. tostring(cellX) .. ",cellY=".. tostring(cellY))

    local beginX ,endX = 1,3
    local beginY , endY = 1,3

    --边界处理
    if cellX < 2 or cellX > maxX-1 then
        if cellX == 1 then
            beginX = 1
            endX = 2
        end
        if cellX == maxX then
            beginX = maxX-1
            endX = maxX
        end
    else
        beginX = cellX - 1
        endX = beginX + 2
    end

    if cellY < 2 or cellY > maxY-1 then
        if cellY == 1 then
            beginY = 1
            endY = 2
        end
        if cellY == maxY then
            beginY = maxY - 1
            endY = maxY
        end
    else
        beginY = cellY - 1
        endY = beginY + 2
    end

    --cclog("beginX=%d,endX=%d,beginY=%d,endY=%d",beginX,endX,beginY,endY)
    
    local needCreate = {}
    for key,value in pairs(bgList) do
        value.used = false
    end

    for j=beginY,endY do
        for i=beginX,endX do
            local index = (j-1)*maxX + (i-1) + 1
            --cclog("index=".. tostring(index))
            local bgImageName = string.format("%d_%d_%d",worldMapID,(maxX*maxY),index)
            if bgList == nil then
                bgList = {}
            end

            if bgList[bgImageName] == nil then
                table.insert(needCreate,bgImageName)
            end

            bgList[bgImageName] = {}
            bgList[bgImageName].index = index
            bgList[bgImageName].bgImageName = bgImageName
            bgList[bgImageName].i = i
            bgList[bgImageName].j = j
            bgList[bgImageName].used = true
            bgList[bgImageName].pos = { (i-1)*1024,(j-1)*576}

            -- 创建区域内的城镇点
            if createRoadPointDynamic == true then
                self:createPoint(index)
                --self:createLine(index)
            end
        end
    end

    for key,value in pairs(bgList) do
        if value.used == false then
            --cclog("removeFromParent key = " .. key)
            --cclog("removeFromParent bgList[key] = " .. tostring(bgList[key]))
            --cclog("removeFromParent value.bg = " .. tostring(value.bg))
            value.bg = nil
            --if value.bg ~= nil and value.bg:getParent() ~= nil then
            --    value.bg:getParent():removeChild(value.bg, true)
            --end
            bgList[key] = nil
        end
    end

    local mapImagePath = StaticData.WorldMap[worldMapID].MapImagePath
    for i = 1,#needCreate do
        local name = needCreate[i]
        if bgList[name] ~= nil then
            local bg = cc.Sprite:create( mapImagePath .. bgList[name].bgImageName .. ".png")
            --cclog("needCreate bg=".. name)
            bg:setAnchorPoint(cc.p(0.0,0.0))
            bg:setPosition( bgList[name].pos[1], bgList[name].pos[2] )
            bg:setName(name)
            Panel_bg:addChild(bg)

            bgList[name].bg = bg
            bgList[name].parent = Panel_bg
            
        end
    end
end

function StageMapLayer:getIndexByPos(cx,cy)
    local scale = Panel_root:getScale()
    local i = math.floor(cx/(1024 * scale)) + 1
    local j = math.floor(cy/(576 * scale)) + 1
    --cclog("getIndexByPos i=%f,j=%f,scale = %f",i,j,scale)
    return i,j
end

-- 读取静态数据初始化城镇点及事件点
function StageMapLayer:initAllRoadPointInfo(mapID,showRoadPointDynamic)
    local curMainTaskID = 0
    if UserData.Task.acceptedTaskList[1][1] ~= "nil" then
        curMainTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
    else
        curMainTaskID = ManagerTask:getNextMainTaskId(UserData.Task.recentlyTaskId)
    end
    local curTaskTownID = 0
    if curMainTaskID > 0 then
        curTaskTownID = tonumber(StaticData.Task[curMainTaskID].TownID)
    end
    local townIDList = StageMapConfig:getAllTownIDInWorldMap(mapID)
    for i=1,#townIDList do
        local townID = townIDList[i]  -- string类型
        local townStaticDataInfo = StaticData.TownMap[townID]
        local townPos = string.split(townStaticDataInfo.TownPos,"*")
        local isMainTown = self:isMainTown(townID)
        local isOver = self:getOverStateById(townIDList[i])
        if roadPointInfo[townID] == nil then
            roadPointInfo[townID] = {}
        end
        roadPointInfo[townIDList[i]].id =  townIDList[i]
        roadPointInfo[townIDList[i]].isMainTown =  isMainTown
        roadPointInfo[townIDList[i]].pos = cc.p( tonumber(townPos[1]),  tonumber(townPos[2]) )
        roadPointInfo[townIDList[i]].over = isOver
        
        if showRoadPointDynamic == false then  -- 一次加载全部城镇点，不动态加载 ,已经经过的事件点不再显示出来
            if roadPointInfo[townIDList[i]].node == nil then
                if isMainTown or isOver == false then
                    local buildImage,imageNameBG = self:createTownPointButton(townStaticDataInfo)
                    roadPointInfo[townIDList[i]].node = buildImage
                    if imageNameBG ~= nil then
                        roadPointInfo[townIDList[i]].imageNameBG = imageNameBG
                    end
                end
            end
            
            if roadPointInfo[townIDList[i]].node ~= nil then
                roadPointInfo[townIDList[i]].node:setVisible(true)
                roadPointInfo[townIDList[i]].node:setPosition(roadPointInfo[townIDList[i]].pos)
                if isOver then
                    roadPointInfo[townIDList[i]].node:setColor(cc.c3b(255,255,255))
                    roadPointInfo[townIDList[i]].node:setTouchEnabled(true)
                    if roadPointInfo[townIDList[i]].imageNameBG ~= nil then
                        roadPointInfo[townIDList[i]].imageNameBG:setVisible(true)
                    end
                else
                    if curTaskTownID > 0 and  curTaskTownID ~= tonumber(townIDList[i])  then
                        roadPointInfo[townIDList[i]].node:setColor(cc.c3b(130,130,130))
                        roadPointInfo[townIDList[i]].node:setTouchEnabled(false)
                        if roadPointInfo[townIDList[i]].imageNameBG ~= nil then
                            roadPointInfo[townIDList[i]].imageNameBG:setVisible(false)
                        end
                    end
                end
            end
        end
    end
end


--创建城镇点的信息
function StageMapLayer:createPoint(areaIndex)
    local townIDList = StageMapConfig:getAllPointIDInScreenArea(areaIndex)
    for i=1,table.nums(townIDList) do

        local townStaticDataInfo = StaticData.TownMap[townIDList[i]]
        local townPos = string.split(townStaticDataInfo.TownPos,"*")
        local isMainTown = self:isMainTown(townStaticDataInfo.TownId)
        local isOver = self:getOverStateById(townIDList[i])
        if roadPointInfo[townIDList[i]] == nil then
            roadPointInfo[townIDList[i]] = {}
            roadPointInfo[townIDList[i]].id =  townIDList[i]
            roadPointInfo[townIDList[i]].isMainTown =  isMainTown
            roadPointInfo[townIDList[i]].pos = cc.p( tonumber(townPos[1]),  tonumber(townPos[2]) )
            roadPointInfo[townIDList[i]].over = isOver

        end
        if roadPointInfo[townIDList[i]].node == nil then
            if isMainTown or isOver == false then
                local buildImage,imageNameBG = self:createTownPointButton(townStaticDataInfo)
                roadPointInfo[townIDList[i]].node = buildImage
                if imageNameBG ~= nil then
                    roadPointInfo[townIDList[i]].imageNameBG = imageNameBG
                end
            end
        end

        if roadPointInfo[townIDList[i]].node ~= nil then
            roadPointInfo[townIDList[i]].node:setVisible(true)
            roadPointInfo[townIDList[i]].node:setPosition(roadPointInfo[townIDList[i]].pos)
            if isOver then
                roadPointInfo[townIDList[i]].node:setColor(cc.c3b(255,255,255))
                roadPointInfo[townIDList[i]].node:setTouchEnabled(true)
                if roadPointInfo[townIDList[i]].imageNameBG ~= nil then
                    roadPointInfo[townIDList[i]].imageNameBG:setVisible(true)
                end
            else
                roadPointInfo[townIDList[i]].node:setColor(cc.c3b(130,130,130))
                roadPointInfo[townIDList[i]].node:setTouchEnabled(false)
                if roadPointInfo[townIDList[i]].imageNameBG ~= nil then
                    roadPointInfo[townIDList[i]].imageNameBG:setVisible(false)
                end
            end
        end
    end
end


--创建城镇点按钮
function StageMapLayer:createTownPointButton(townStaticDataInfo)
    
    local function onEventTouchButton(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("onEventTouchButton ended = " .. sender:getName())

            local pointID = ""
            local pointPos = nil
            local isTown = false
            local i,j = string.find(sender:getName(),"Button_point_")
            if i ~= nil and j ~= nil then  -- 城镇
                pointID = string.sub(sender:getName(),string.len("Button_point_")+1)
                pointPos = roadPointInfo[pointID].pos
                isTown = roadPointInfo[pointID].isMainTown

            end
            
            if cc.pGetDistance(pointPos,UserData.Map.roleStayPoint) > MIN_DISTANCE/2 then
                self:moveRoleToMapPoint(pointPos,pointID)
            else 
                if isTown and self:getOverStateById(pointID) == true then
                    --进入城镇UI
                    local TownInterfaceLayer = require("app.views.StageMap.TownInterfaceLayer"):create()
                    local SceneManager = require("app.views.SceneManager")
                    SceneManager:addToGameScene(TownInterfaceLayer)
                    local userdata = { currentTownID = pointID}
                    TownInterfaceLayer:initUI(userdata)
                end
            end
        end
    end    

    local currentTownID = townStaticDataInfo.TownId
    local button = ccui.Button:create()
    button:setTouchEnabled(true)

    local imagePath = townStaticDataInfo.TownImage
    if imagePath == nil or imagePath == "" then
        imagePath = "maps/612_TownIcon/612001.png"
    end
    button:loadTextureNormal(imagePath,0)
    button:loadTexturePressed(imagePath,0)
    button:loadTextureDisabled(imagePath,0)
    button:setName("Button_point_" .. tostring(currentTownID))
    local size = button:getContentSize()
    button:setScale(1.00)
    button:addTouchEventListener(onEventTouchButton)
    button:setPressedActionEnabled(true)

    Node_roadPoint:addChild(button)

    local imageNameBG = nil
    if townStaticDataInfo.TownNameImage ~= "" and townStaticDataInfo.TownNamePos ~= "" then -- 城镇
        local imageName = ccui.ImageView:create()
        imageName:loadTexture(townStaticDataInfo.TownNameImage,0)
        local sizeName = imageName:getContentSize()

        imageNameBG = ccui.ImageView:create()
        imageNameBG:ignoreContentAdaptWithSize(false)
        imageNameBG:setScale9Enabled(true)
        imageNameBG:setCapInsets(cc.rect(36,14,43,15))
        imageNameBG:loadTexture("ui/worldMap/worldMap_text_bg2.png",0)
        imageNameBG:setContentSize(cc.size(sizeName.width+50,sizeName.height+10))
        imageNameBG:addChild(imageName,1)
        local sizeNameBG = imageNameBG:getContentSize()
        imageName:setPosition(cc.p(sizeNameBG.width/2,sizeNameBG.height/2))

        local size = button:getContentSize()
        imageNameBG:setPosition(cc.p(size.width/2,size.height/5))
        button:addChild(imageNameBG,1)
    end
    return button , imageNameBG
end

function StageMapLayer:createLine(areaIndex)
    
end



--function StageMapLayer:isCanMove(pointID)
--    
--    if roadPointInfo[pointID].over == true then
--        return true
--    end
--  
--    if UserData.Map.lastPointID ~= nil and UserData.Map.lastPointID ~= "" then
--        if UserData.Map.lastPointID == pointID or UserData.Map.lastPointID == pointID then
--            return true
--        end
--    end
--    
--    local nextPointID = UserData.Map.nextOpenedTownID
--
--    if nextPointID ~= nil and nextPointID ~= "" then
--        if nextPointID == pointID or nextPointID == pointID then
--            return true
--        end
--    end
--
--    return false
--end


function StageMapLayer:openTaskDetailInfoLayer()
    local TaskDetailInfoLayer = require("app.views.Task.TaskDetailInfoLayer")
    local layer = TaskDetailInfoLayer:create()

    local SceneManager = require("app.views.SceneManager")
    SceneManager:addToGameScene(layer,1)
end


function StageMapLayer:addNpcToMapLayer(taskID)
    if mylayer ~= nil then
        local root = mylayer:getChildByName("Panel_root")
        ManagerTask:addNpcToMap(taskID,root)
    end
end

function StageMapLayer:moveToTaskDestination(taskID)

    local posToMove = nil
    local townPointID = nil
    local  data  = StaticData.Task[taskID]
    if data.CityType == 0  then --说明是地图上的任务
        --local npcTable = self:splitStrForTaskId(data.NpcId)
        local posTable = ManagerTask:splitStrForPos(data.NpcPos)
        posToMove = posTable[1]
        local townID = StaticData.Task[taskID].TownID
        townPointID = townID > 0 and townID or nil
    else  -- 在城镇
        local townID = tostring(data.CityType)
        if StaticData.TownMap[townID] ~= nil and StaticData.TownMap[townID].TownPos ~= "" then
            local townPos = string.split(StaticData.TownMap[townID].TownPos,"*")
            posToMove = cc.p(tonumber(townPos[1]),tonumber(townPos[2]))
            local pos = UserData.Map.roleStayPoint
            if pos ~= nil and cc.pGetDistance(pos,posToMove) < 1 then
                ManagerTask.currentMoveToNpcTaskID = 0
                --进入城镇UI
                local TownInterfaceLayer = require("app.views.StageMap.TownInterfaceLayer"):create()
                local SceneManager = require("app.views.SceneManager")
                SceneManager:addToGameScene(TownInterfaceLayer)
                local userdata = {  currentTownID = townID}
                TownInterfaceLayer:initUI(userdata)
            end
        end
        townPointID = townID
    end
    if posToMove ~= nil then
        self:moveRoleToMapPoint(posToMove,tostring(townPointID))
    end
end

function StageMapLayer:onClickedTaskNpc(taskID,node)
    if taskID <= 0 or node == nil then
        return
    end
    
    local parent = nil
    local name1 = node:getName()
    local name = node:getParent():getName()
    parent = node:getParent()
--    local name1 = parent:getName()
    local preTalk = StaticData.Task[taskID].PreTalk
    local lastTalk = StaticData.Task[taskID].LastTalk
    local taskType = ManagerTask:getTaskType(taskID)
    local taskInfo = UserData.Task.acceptedTaskList[taskType]
    local needShowPlot = false
    if taskInfo[1] ~= "nil" then
        if tonumber(taskInfo[2]) == 2 then
            needShowPlot = true
        else
            if tonumber(taskInfo[5]) == 0 and preTalk > 0 then
                needShowPlot = true
            end
        end
    
    end
    if preTalk > 0 or lastTalk > 0 then
        PlotLayer:initPlotEnterAntExit(taskID)
    end
    if preTalk > 0 and needShowPlot then
        ManagerTask.SectionId = preTalk

        local SceneManager = require("app.views.SceneManager")
        SceneManager:switch(SceneManager.SceneName.SCENE_PLOT)
    
    else
        --直接弹进入战斗界面
        ManagerTask:EnterBeforeFightScene(taskID)
    end

end

function StageMapLayer:OnTaskPlotFinished(currentTaskId)
    local ManagerTask = require("app.views.Task.ManagerTask")
    local taskType = ManagerTask:getTaskType(currentTaskId)
    UserData.Task:sendUpdateTask(currentTaskId,taskType)

end


function StageMapLayer:RemoveTaskNpc(taskID)
    local  data  = StaticData.Task[taskID]
    if data.CityType == 0 then
        
        for i=#ManagerTask.npcList.map,0,-1 do
            local publicNpc = ManagerTask.npcList.map[i]
            if publicNpc ~= nil and publicNpc.taskID == taskID then
                table.remove(ManagerTask.npcList.map,i)
                publicNpc:removeFromParent()
                   
            end
        end

    end
end

function StageMapLayer:OnTaskAdded(event)
    --创建任务NPC
    local taskID = event._usedata
    local taskType = ManagerTask:getTaskType(taskID)
    if UserData.Task.acceptedTaskList[taskType][1] ~= "nil" then
        local  data  = StaticData.Task[taskID]
        if data.CityType == 0  then --说明是地图上的任务
            self:addNpcToMapLayer(taskID)
        end
    end
    
    if taskID == UserData.NewHandLead.GuideList.EnterToJiangDou.TaskID then
        local guideState = UserData.NewHandLead:getGuideState("EnterToJiangDou")
        if guideState == 0 then
            local data = {name = "EnterToJiangDou"}
            UserData.NewHandLead:startNewGuide(data)
            
            local curTownID = StaticData.Task[taskID].TownID
            local townPos = string.split(StaticData.TownMap[tostring(curTownID)].TownPos,"*")
            self:ShowNewHand(cc.p(townPos[1]+50,townPos[2])) 
        end
    end
    
end

function StageMapLayer:OnTaskFinished(event)
    --删除任务NPC
    local taskID = event._usedata
    self:RemoveTaskNpc(taskID)
    
    local name = "FlySkillLead"
    if taskID == UserData.NewHandLead.GuideList[name].TaskID then
        local guideState = UserData.NewHandLead:getGuideState("FlySkillLead")
        if guideState == 0 then
            local data = {name = name}
            UserData.NewHandLead.GuideList[name].curStep = 1
            UserData.NewHandLead:startNewGuide(data)
            if self.main_ui_layer ~= nil and self.main_ui_layer.bottomBar ~= nil then
                self.main_ui_layer.bottomBar:showNewHand(name)
            end
        end
    end
    name = "GodWillLead_levelup"
    if taskID == UserData.NewHandLead.GuideList[name].TaskID then
        local guideState = UserData.NewHandLead:getGuideState("GodWillLead_levelup")
        if guideState == 0 then
            local data = {name = name}
            UserData.NewHandLead.GuideList[name].curStep = 1
            UserData.NewHandLead:startNewGuide(data)
            if self.main_ui_layer ~= nil and self.main_ui_layer.bottomBar ~= nil then
                self.main_ui_layer.bottomBar:showNewHand(name)
            end
        end
    end
    name = "GodWillLead_starUp"
    if UserData.NewHandLead.GuideList[name] ~= nil and taskID == UserData.NewHandLead.GuideList[name].TaskID then
        local guideState = UserData.NewHandLead:getGuideState(name)
        if guideState == 0 then
            local data = {name = name}
            UserData.NewHandLead.GuideList[name].curStep = 1
            UserData.NewHandLead:startNewGuide(data)
            if self.main_ui_layer ~= nil and self.main_ui_layer.bottomBar ~= nil then
                self.main_ui_layer.bottomBar:showNewHand(name)
            end
        end
    end

    if taskID == UserData.NewHandLead.GuideList.ClickMapEnventPoint.TaskID then
        UserData.NewHandLead:CompleteGuide("ClickMapEnventPoint")
        UserData.NewHandLead:closeCurrentGuide()
        local SceneManager = require("app.views.SceneManager")
        SceneManager:removeChildLayer("NewHandLeadLayer")
        if Node_newHand ~= nil then
            Node_newHand:setVisible(false)
            Node_newHand:removeAllChildren()
        end
    end   
    if taskID == UserData.NewHandLead.GuideList.EnterToJiangDou.TaskID then
        --UserData.NewHandLead:CompleteGuide("EnterToJiangDou")  -- 此处不完成，待进入点击任务列表后一起完成
        local SceneManager = require("app.views.SceneManager")
        SceneManager:removeChildLayer("NewHandLeadLayer")
        if Node_newHand ~= nil then
            Node_newHand:setVisible(false)
            Node_newHand:removeAllChildren()
        end
    end   
  
    local nextMainTaskId = ManagerTask:getNextMainTaskId(taskID)
    if nextMainTaskId == 0 then
        --删除当前节点的任务标记
        self:removeNextTownPointFlag(taskID)
    end
end

function StageMapLayer:OnTaskAbandoned(event)
    --删除任务NPC
    local taskID = event._usedata
    self:RemoveTaskNpc(taskID)
end


function StageMapLayer:OnTaskParameterChanged(event)
    local taskID = event._usedata
    --local taskType = ManagerTask:getTaskType(taskID)
    local taskStaticInfo = StaticData.Task[taskID]
    if taskStaticInfo.TaskTargetType == 2 then -- 对话任务
        self:checkFinishTask()
    end
end

function StageMapLayer:StopRoleMoveUpdate()
    if roleMoveActionInfo.currentPos ~= nil then
        UserData.Map.roleStayPoint = roleMoveActionInfo.currentPos
    else
        local posX,posY = role:getPosition()
        UserData.Map.roleStayPoint = cc.p(posX,posY)
    end
    --UserData.Map.roleStayPointID = ""
    UserData.Map.roleIsMoving = false
    DataManager:setStringForKey("roleStayPoint",UserData.Map.roleStayPoint.x .. "-" .. UserData.Map.roleStayPoint.y)
    
    if scheduleUpdate ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
    end
end

function StageMapLayer:roleMoveUpdate(dt)
    
    local distance = cc.pGetDistance(roleMoveActionInfo.currentPos,roleMoveActionInfo.desPos)
    if distance > MIN_DISTANCE/4 then  -- 距离小于MIN_DISTANCE表示达到目的地
        --cclog("roleMoveUpdate = " .. tostring(distance))
        local newFaceDir = {x = roleMoveActionInfo.desPos.x - roleMoveActionInfo.currentPos.x , y = roleMoveActionInfo.desPos.y - roleMoveActionInfo.currentPos.y }
        newFaceDir = cc.pNormalize(newFaceDir)
        local offset = { x = newFaceDir.x * ROLE_MOVE_SPEED * dt, y = newFaceDir.y * ROLE_MOVE_SPEED * dt  }

        roleMoveActionInfo.currentPos = cc.p(roleMoveActionInfo.currentPos.x + offset.x,roleMoveActionInfo.currentPos.y + offset.y)

        role:setPosition(roleMoveActionInfo.currentPos)
        UserData.Map.roleStayPoint = roleMoveActionInfo.currentPos
        --cclog("roleMoveActionInfo.currentPos = (%.2f,%.2f)",roleMoveActionInfo.currentPos.x,roleMoveActionInfo.currentPos.y)
        if Panel_root == nil then
            cclog("Panel_root is nil")
        end

        local posInWorld = Panel_root:convertToWorldSpace(cc.p(roleMoveActionInfo.currentPos.x,roleMoveActionInfo.currentPos.y))
        local posInScreen = mylayer:convertToNodeSpace(posInWorld)
        local needScrollMap = false
        if newFaceDir.x < 0 and posInScreen.x < visibleSize.width/2 then
            needScrollMap = true
        end
        if newFaceDir.x > 0 and posInScreen.x > visibleSize.width/2 then
            needScrollMap = true
        end
        if newFaceDir.y < 0 and posInScreen.y < visibleSize.height/2 then
            needScrollMap = true
        end
        if newFaceDir.y > 0 and posInScreen.y > visibleSize.height/2 then
            needScrollMap = true
        end
        if needScrollMap then
            local scale = Panel_root:getScale()
            Panel_root:setPosition(cc.p(-roleMoveActionInfo.currentPos.x*scale + visibleSize.width/2,(-roleMoveActionInfo.currentPos.y)*scale + visibleSize.height/2))
            local posX,posY = Panel_root:getPosition()
            --cclog("roleMoveUpdate Panel_root pos = (" ..tostring(posX) .. ",".. tostring(posY) .. ")")
            self:correctPosition(posX,posY)
            if createRoadPointDynamic == true then
                self:updateStageContent()
            end
        end
    else

        if scheduleUpdate ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleUpdate)
        end
        UserData.Map.roleStayPointID = ""
        UserData.Map.roleStayPoint = roleMoveActionInfo.currentPos
        UserData.Map.roleIsMoving = false

        DataManager:setStringForKey("roleStayPoint",UserData.Map.roleStayPoint.x .. "-" .. UserData.Map.roleStayPoint.y)
        if roleMoveActionInfo.currentPointID ~= nil and tonumber(roleMoveActionInfo.currentPointID) ~= nil then
            --UserData.Map.lastPointID = UserData.Map.roleStayPointID
            UserData.Map.roleStayPointID = roleMoveActionInfo.currentPointID

            local isMain = self:isMainTown(roleMoveActionInfo.currentPointID)
            UserData.Map.currentWorldMapID = StaticData.TownMap[tostring(roleMoveActionInfo.currentPointID)].WorldMapId

            
            
            --改为由任务控制是否开启下个城镇
            --            local oldOverState = roadPointInfo[roleMoveActionInfo.currentPointID].over
            --            if oldOverState == false then
--                roadPointInfo[roleMoveActionInfo.currentPointID].over = true
            --                UserData.Map:stageInfoToUserData(roadPointInfo,eventPointInfo)
--            end
            --            UserData.Map.nextOpenedTownID = self:getNextTownID(roleMoveActionInfo.currentPointID)
            --            self:setNextTownPoint()

            if isMain then
                if self:getOverStateById(roleMoveActionInfo.currentPointID) then
                    local TownInterfaceLayer = require("app.views.StageMap.TownInterfaceLayer"):create()
                    local SceneManager = require("app.views.SceneManager")
                    SceneManager:addToGameScene(TownInterfaceLayer)
                    local userdata = {currentTownID = roleMoveActionInfo.currentPointID}
                    TownInterfaceLayer:initUI(userdata)
                end
           else
                local curMainTaskID = 0
                if UserData.Task.acceptedTaskList[1][1] ~= "nil" then
                    curMainTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
                    if StaticData.Task[curMainTaskID] ~= nil and StaticData.Task[curMainTaskID].TownID == tonumber(roleMoveActionInfo.currentPointID) then
                        ManagerTask:StartTaskImmediatelyWithoutMove(curMainTaskID)
                    end
                end
           end
            
        end
        UserData.Map:SaveUserData()
        
        roleMoveActionInfo.currentPos = nil
        roleMoveActionInfo.desPos = nil
        roleMoveActionInfo.currentPointID = nil
    end

end

function StageMapLayer:MoveToNpc(npcPos)
	if cc.pGetDistance(npcPos,UserData.Map.roleStayPoint) > MIN_DISTANCE/2 then
	   local townID = self:checkPointInTownRect(npcPos)
            
        self:moveRoleToMapPoint(npcPos,townID)
        return true
    end
    return false
end

function StageMapLayer:removeAllNpc()
    if mylayer ~= nil then
        local root = mylayer:getChildByName("Panel_root")
        if root ~= nil then
            local childs = root:getChildren()
            for i=#childs,0,-1 do
                if childs[i] ~= nil and childs[i].__cname == "publicNpc" then
                    childs[i]:removeFromParent()
                end
            end
        end
    end
end

--更新城镇点完成(开启)的状态
function StageMapLayer:updateTownOverState(currentTaskID)
    local SceneManager = require("app.views.SceneManager")
    local layer = SceneManager:getGameLayer("StageMapLayer")
    --改变当前点状态
    local curTownID = 0
    local taskInfo = StaticData.Task[currentTaskID]
    if taskInfo ~= nil then
        curTownID = tonumber(taskInfo.TownID)
    end
    if curTownID > 1000 and roadPointInfo[tostring(curTownID)] ~= nil then
        UserData.Map:openNewTown(tonumber(curTownID))
        
        local nextTaskID = ManagerTask:getNextMainTaskId(currentTaskID)
        local nextTaskInfo = StaticData.Task[nextTaskID]
        if nextTaskInfo ~= nil then
            local nextTownID = tonumber(nextTaskInfo.TownID)
            if nextTownID ~= nil and nextTownID > 1000 and nextTownID ~= curTownID then
                
                UserData.Map:openNewTown(tonumber(nextTownID))
            end
        end
        
        local oldOverState = roadPointInfo[tostring(curTownID)].over
        if oldOverState == false then
            roadPointInfo[tostring(curTownID)].over = true
            
            if roadPointInfo[tostring(curTownID)].node ~= nil and layer ~= nil then -- 当前已经创建了StageMapLayer
                if roadPointInfo[tostring(curTownID)].isMainTown then
                    if roadPointInfo[tostring(curTownID)].node.setColor ~= nil then
                        roadPointInfo[tostring(curTownID)].node:setColor(cc.c3b(255,255,255))
                    end
                    roadPointInfo[tostring(curTownID)].node:setTouchEnabled(true)
                    roadPointInfo[tostring(curTownID)].node:setVisible(true)
                else
                    roadPointInfo[tostring(curTownID)].node:setVisible(false)
                end
            end
        end
    
    end
    
    --设置下一个点
    self:setNextTownPoint()
    
--    local townTaskTypeList = ManagerTask:getCanAcceptedTaskTownList(worldMapID,roadPointInfo)
--    dump(townTaskTypeList)
    
    local townID = UserData.Map:getTownIDByPreTaskID(currentTaskID)
    if townID == nil or townID == "" then
        return
    end
    UserData.Map.nextOpenedTownID = tostring(townID)
    DataManager:setStringForKey("nextOpenedTownID",UserData.Map.nextOpenedTownID)
    self:checkOpenNextWorldMap(townID) 
    UserData.Map:openNewTown(tonumber(townID))
    
    if roadPointInfo[tostring(townID)] ~= nil and layer ~= nil then -- 当前已经创建了StageMapLayer
        if roadPointInfo[tostring(townID)].node ~= nil then
            --if roadPointInfo[tostring(townID)].isMainTown then
                roadPointInfo[tostring(townID)].node:setColor(cc.c3b(255,255,255))
                roadPointInfo[tostring(townID)].node:setTouchEnabled(true)
                roadPointInfo[tostring(townID)].node:setVisible(true)
                
            --end
        end
        if roadPointInfo[tostring(townID)].imageNameBG ~= nil then
            roadPointInfo[tostring(townID)].imageNameBG:setVisible(true)
        end
    end
    
   
end


--检测是否需要开启下一个地图
function StageMapLayer:checkOpenNextWorldMap(townID) 
    if StaticData.TownMap[tostring(townID)] ~= nil then
        local curWorldMapID = StaticData.TownMap[tostring(townID)].WorldMapId
        local curStayMapID = UserData.Map:getRoleStayWorldMapID()
        if curStayMapID ~= curWorldMapID then
            UserData.Map:SaveRoleStayWorldMapID(curWorldMapID)
            UserData.Map:SaveOpenedWolrdMap(curWorldMapID)
        end
    end
end

--检测已经开启的城镇是否有支线日常循环任务可接
function StageMapLayer:checkCanAcceptTaskInMap() 
--    local townTaskTypeList = ManagerTask:getCanAcceptedTaskTownList(worldMapID)
end

function StageMapLayer:ShowNewHand(pos,rotate) 
    Node_newHand:setVisible(true)
    Node_newHand:removeAllChildren()
    local SpineJson = "spine/ui/ui_shouzhi.json"
    local SpineAtlas = "spine/ui/ui_shouzhi.atlas"
    local skeletonNode = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    skeletonNode:setAnimation(0, "click", true)
    skeletonNode:setPosition(0,0)
    
    Node_newHand:addChild(skeletonNode)
    Node_newHand:setPosition(pos)
    if rotate ~= nil then
        Node_newHand:setRotation(rotate)
    end
    Node_newHand:setLocalZOrder(100)
end

return StageMapLayer
