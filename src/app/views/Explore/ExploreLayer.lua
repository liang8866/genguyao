local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local ExploreProgressNode = require("app.views.Explore.ExploreProgressNode")
local PlotLayer = require("app.views.Plot.PlotLayer")
local newHandLead = require("app.views.NewHandLead.NewHandLeadLayer")

-- 探索
local ExploreLayer = class("ExploreLayer", function()
    return cc.Layer:create()
end)

function ExploreLayer:create(mapId)
    local view = ExploreLayer.new()
    view:init(mapId)
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

function ExploreLayer:ctor()

end

function ExploreLayer:onEnter()

--    EventMgr:registListener(EventType.OnGetExploreInfo, self, self.onGetExploreInfo)
    EventMgr:registListener(EventType.OnGetCell, self, self.onGetCell)
    EventMgr:registListener(EventType.OnGetNoticePrize, self, self.onGetNoticePrize)
    EventMgr:registListener(EventType.OnExploreThrouth, self, self.onExploreThrouth)

end

function ExploreLayer:onExit()
--    EventMgr:unregistListener(EventType.OnGetExploreInfo, self, self.onGetExploreInfo)
    EventMgr:unregistListener(EventType.OnGetCell, self, self.onGetCell)
    EventMgr:unregistListener(EventType.OnGetNoticePrize, self, self.onGetNoticePrize)
    EventMgr:unregistListener(EventType.OnExploreThrouth, self, self.onExploreThrouth)
    if self.schedule ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
        self.schedule = nil
    end
    
    local SceneManager = require("app.views.SceneManager")
    local layer = SceneManager:getGameLayer("ExploreStartLayer")
    if layer ~= nil then
        layer:updateProgressInfo()
    end
end

function ExploreLayer:init(mapId)
    self.visibleSize = cc.Director:getInstance():getVisibleSize()

    self.publicTipLayer = PublicTipLayer:create()
    self:addChild(self.publicTipLayer)
    
    self.mapId = mapId
    
    local exploreCsb = cc.CSLoader:createNode("csb/ExploreLayer.csb")
	self:addChild(exploreCsb)
	self.panel = exploreCsb:getChildByName("Panel")
	
    self.Button_center = exploreCsb:getChildByName("Button_center")
    self.Button_back = exploreCsb:getChildByName("Button_back")
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local senderName = sender:getName()
            cclog("ExploreLayer onEventTouchButton,name = "  .. senderName)
            if senderName == "Button_back" then
                local iExploreMapID = self.mapId
                self:removeFromParent()
                local ExploreStartLayer = require("app.views.Explore.ExploreStartLayer")
                local layer = ExploreStartLayer:create(iExploreMapID)
                local SceneManager = require("app.views.SceneManager")
                SceneManager:addToGameScene(layer,10)
                layer:updateProgressInfo()
            elseif senderName == "Button_center" then
            end
        end
    end
    self.Button_center:setVisible(false)

    self.Button_back:setTouchEnabled(true)
    self.Button_back:addTouchEventListener(onEventTouchButton)
    self.Button_back:setPressedActionEnabled(true)
    
    local path = StaticData.Map[mapId].MapPath
    self.exploreMap = cc.TMXTiledMap:create(path)
	self.panel:addChild(self.exploreMap)
	
    self.blockLayer = self.exploreMap:getLayer("blockLayer")            -- 障碍层
    self.boxLayer = self.exploreMap:getLayer("boxLayer")                -- 宝箱层
    self.prisonLayer = self.exploreMap:getLayer("prisonLayer")          -- 牢笼
    self.monsterLayer = self.exploreMap:getLayer("monsterLayer")
    self.eventLayer = self.exploreMap:getLayer("eventLayer")
    self.shadeLayer = self.exploreMap:getLayer("shadeLayer")            -- 遮罩层
    self.shadeLayer:setLocalZOrder(100)
    
    local csbChildArray = self.exploreMap:getChildren()
    local child = nil
    local pObject = nil
    for i = 1, #csbChildArray do
        if csbChildArray[i] ~= self.shadeLayer then
            csbChildArray[i]:getTexture():setAntiAliasTexParameters()
        end
    end
    
    if UserData.Explore.map[mapId][ExploreEnum.Through] == 1 then
        local tilePos = self:seriesIDTotilePos(StaticData.Map[mapId].BossCell)
        self.shadeLayer:removeFromParent()
        self.shadeLayer = nil
        cc.UserDefault:getInstance():setStringForKey("explore" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, "through")
    else
        if cc.UserDefault:getInstance():getStringForKey("explore" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID) == "through" then
            cc.UserDefault:getInstance():setStringForKey("explore" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, "")
        end
    end
    print(string.format("UserData.Explore.map[mapId][ExploreEnum.Through] is %d", UserData.Explore.map[self.mapId][ExploreEnum.Through]))

	self.mapSize = self.exploreMap:getMapSize()                         -- 地图大小
    self.mapSize.width = self.mapSize.width * 80
    self.mapSize.height = self.mapSize.height * 80
    self.exploreMap:setPosition(self.visibleSize.width - self.mapSize.width, self.visibleSize.height - self.mapSize.height)
    print("width:" .. self.mapSize.width .. ", " .. "height:" .. self.mapSize.height)
    
    self.role = cc.CSLoader:createNode("csb/ExploreRoleNode.csb")
    local panel = self.role:getChildByName("Panel")
    local roleSprite = panel:getChildByName("roleSprite")
    if UserData.BaseInfo.userSex == 2 then
        roleSprite:setTexture("items/role/women1.png")
    end
    local tilePos = string.split(StaticData.Map[mapId].BeginDot, "_")
    local pos = self:tileposToPos(cc.p(tonumber(tilePos[1]), tonumber(tilePos[2])))
    self.role:setPosition(pos) 
    self.exploreMap:addChild(self.role, 101)
    
    local mapX, mapY = self.exploreMap:getPosition()
    self.mapWorldPos = cc.p(mapX, mapY)                                                                 -- 地图的世界坐标
    self.roleNodePos = pos                                                                              -- 人物的节点坐标
    self.roleWindPos = self:nodePosToTouchPos(self.roleNodePos)                                         -- 人物的世界坐标
    self.roleTilePos = self:posToTilepos(self.roleNodePos)                                              -- 人物瓦片地图坐标

    self.mapGID = nil                                                                                   -- 当前地图块的GID
    self.moveSpeed = 8                                                                                  -- 人物移动速度
    self.moveTime = 0
    self.isMove = false                                                                                 -- 判断是否在运动
    self.isPlot = false
    self.stepNum = 0                                                                                    -- 所走的步数

    print("x:" .. self.mapWorldPos.x .. ", " .. "y:" .. self.mapWorldPos.y)
    print("x:" .. self.roleWindPos.x .. ", " .. "y:" .. self.roleWindPos.y)
    print("x:" .. self.roleNodePos.x .. ", " .. "y:" .. self.roleNodePos.y)

    -- 记录所有箱子和事件的点
    self.allEventDot = {}
    self.allEventStr = cc.UserDefault:getInstance():getStringForKey("exploreAllEvent" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID)
    if self.allEventStr == nil or self.allEventStr == "" then
        local width = self.mapSize.width / 80 - 1
        local height = self.mapSize.height / 80 - 1
        for i = 1, width - 1 do
            for j = 1, height - 1 do
                local seriesId = self:tilePosToSeriesID(cc.p(i, j))
                if StaticData.ExploreMap[seriesId] ~= nil then
--                    if self.mapId == 1 and seriesId == 111403 then
--                    else
                        local posStr = self:posToString(cc.p(i, j))
                        if self.allEventStr == nil or self.allEventStr == "" then
                            self.allEventStr = posStr
                        else
                            self.allEventStr = self.allEventStr .. "|" .. posStr
                        end
                        cc.UserDefault:getInstance():setStringForKey("exploreAllEvent" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, self.allEventStr)
                end
            end
        end
    end
    self.allEventDot = self:getRoleMoveDot(self.allEventStr, "_")

    -- 记录已经打开的格子
    local str = cc.UserDefault:getInstance():getStringForKey("exploreOpen" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID)
    self.openStr = str
    self.openDot = {}
    if self.openStr ~= nil and self.openStr ~= "" then
        local openDot = self:getRoleMoveDot(self.openStr, "_")
        for i = 1, #openDot do
            local seriesId = self:tilePosToSeriesID(cc.p(openDot[i].x, openDot[i].y))
            self.openDot[seriesId] = true
        end
    end
    -- 记录后箱子和事件的点
    local showBoxAndEventStr = cc.UserDefault:getInstance():getStringForKey("exploreShowBoxAndEvent" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID)
    if showBoxAndEventStr == nil or showBoxAndEventStr == "" then
        local boxNum = 0
        local eventNum = 0
        for i = 1, #self.allEventDot do       -- 所有箱子和时间都设为隐藏
            local seriesId = self:tilePosToSeriesID(cc.p(self.allEventDot[i].x, self.allEventDot[i].y))
            if StaticData.ExploreMap[seriesId] == nil then
                print(seriesId)
            end
            local type = StaticData.ExploreMap[seriesId].Type
            if type == 1 then
                self:setOpenGid(cc.p(self.allEventDot[i].x, self.allEventDot[i].y), true)
                boxNum = boxNum + 1
            elseif type == 2 then
                self.blockLayer:setTileGID(0, cc.p(self.allEventDot[i].x, self.allEventDot[i].y))
                eventNum = eventNum + 1
            elseif type == 8 or type == 9 or type == 10 then
                self:setOpenGid(cc.p(self.allEventDot[i].x, self.allEventDot[i].y), true)
            end
        end
        self:showNum(self.mapId,boxNum,eventNum)
    else
        for i = 1, #self.allEventDot do       -- 所有箱子和时间都设为隐藏
            local seriesId = self:tilePosToSeriesID(cc.p(self.allEventDot[i].x, self.allEventDot[i].y))
            local type = StaticData.ExploreMap[seriesId].Type
            if type == 1 or type == 8 or type == 9 or type == 10 then
                self:setOpenGid(cc.p(self.allEventDot[i].x, self.allEventDot[i].y), true)
            elseif type == 2 then
                self.blockLayer:setTileGID(0, cc.p(self.allEventDot[i].x, self.allEventDot[i].y))
            end
        end
        local showAllPos = self:getRoleMoveDot(showBoxAndEventStr, "_")
        for i = 1, #showAllPos do            -- 显示已经记录的箱子
            local pos = cc.p(showAllPos[i].x, showAllPos[i].y)
            local seriesId = self:tilePosToSeriesID(pos)
            if self.openDot[seriesId] == true then
                local type = StaticData.ExploreMap[seriesId].Type
                local icon = StaticData.ExploreMap[seriesId].Icon
                if type == 8 or type == 9 or type == 10 then
                    self:setOpenGid(pos, false)
                elseif type == 1 then
                    if icon == 142 then
                        self:setOpenGid(pos, false)
                    else
                        self:setOpenGid(pos, true)
                    end
                elseif type == 2 then
                    self.blockLayer:setTileGID(0, pos)
                end
            else
                self:setRecordGid(pos)
            end
        end
    end
    
    self:openShade(self.roleTilePos)
    self:touchEvent()
    
    self.taskNPC = UserData.Explore.map[self.mapId][ExploreEnum.TaskNPC]
    
    if self.shadeLayer ~= nil then
        self.posString = cc.UserDefault:getInstance():getStringForKey("explore" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID)
        if self.posString == nil or self.posString == "" then
            self.posString = self:posToString(self.roleTilePos)
            cc.UserDefault:getInstance():setStringForKey("explore" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, self.posString)
        end
        local allPos = self:getRoleMoveDot(self.posString, "_")
        for i = 1, #allPos do
            self:openShade(allPos[i])
        end
    end

    local childNode = ExploreProgressNode:create(self.mapId)
    self:addChild(childNode,10)
    local x = self.visibleSize.width - 260
    childNode:setPosition(cc.p(x,0))
    self.rightBar = childNode
    
    self.bottomBar = require("app.views.Main.OperateUI"):create()
    self:addChild(self.bottomBar,10)
    --self.bottomBar:setAnchorPoint(cc.p(0.5,0.0))
    self.bottomBar:setPosition(cc.p(display.width/2,0))  
    
    if self.mapId == 1 and UserData.NewHandLead:getGuideState("Explore_1") ~= 1 then

        local userExplore = UserData.NewHandLead.GuideList["Explore_1"]
        userExplore.parent = self
        
        self.newLeadLayer_1 = UserData.NewHandLead:startNewGuide(userExplore)
        self.exploreMap:addChild(self.newLeadLayer_1, 30)
        
        ManagerTask.SectionId = UserData.NewHandLead.GuideList.Explore_1.step[1].PlotSectionID
        local plot = PlotLayer:create()
        plot:initPlotEnterAntExit(0)
        self:addChild(plot, 50)
    
    end
    
end

-- 地图坐标转成普通
function ExploreLayer:posToTilepos(pos)
    local tileX = math.floor(pos.x / 80)
    local tileY = self.mapSize.height / 80 - 1 - math.floor(pos.y / 80)
    return cc.p(tileX, tileY)
end

-- 普通坐标转成地图坐标
function ExploreLayer:tileposToPos(tilepos)
	local posX = tilepos.x * 80 + 40
    local posY = (self.mapSize.height / 80 - 1 - tilepos.y) * 80 + 40
	return (cc.p(posX, posY))
end

-- 世界坐标转成节点坐标
function ExploreLayer:touchPosToNodePos(touchPos)
    local mapPosX, mapPosY = self.exploreMap:getPosition()
    return cc.p(touchPos.x - mapPosX, touchPos.y - mapPosY)
end

-- 节点坐标转成世界坐标
function ExploreLayer:nodePosToTouchPos(nodePos)
    local mapPosX, mapPosY = self.exploreMap:getPosition()
    return cc.p(nodePos.x + mapPosX, nodePos.y + mapPosY)
end

function ExploreLayer:setLabel(str, tilePos)
    local labelImage = ccui.ImageView:create()
    labelImage:setScale9Enabled(true)
    labelImage:loadTexture("ui/public/bgLabel.png")
    local label = cc.LabelTTF:create("", "Arial", 14)
    label:setFontSize(14)
    label:setColor(cc.c3b(0,0,0))
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setHorizontalAlignment(0)--左中友
    label:setVerticalAlignment(1)--上中下

    labelImage:addChild(label)
    label:setTag(1)
    
    label:setString(str)
    local size = label:getContentSize()
    if size.width < 160 then
        size = cc.size(size.width + 30, size.height + 20)
        labelImage:setContentSize(size)
    else
        label:setDimensions(cc.size(160,00))
        size = label:getContentSize()
        size = cc.size(size.width + 10, size.height + 20)
        labelImage:setContentSize(size)
    end

    label:setPosition(size.width / 2, size.height / 2)
    labelImage:setVisible(true)
    self.exploreMap:addChild(labelImage, 1000)
    local pos = self:tileposToPos(tilePos)
    labelImage:setPosition(pos.x, pos.y + 80)
    
    local delay1 = cc.DelayTime:create(0.2)
    local delay2 = cc.DelayTime:create(0.2)
    
    local fadeOut1 = cc.FadeOut:create(0.5)
    local fadeOut2 = cc.FadeOut:create(0.5)
    
    local remove = cc.RemoveSelf:create()
    local seq1 = cc.Sequence:create(delay1, fadeOut1, remove)
    local seq2 = cc.Sequence:create(delay2, fadeOut2)
    
    label:runAction(seq2)
    labelImage:runAction(seq1)
end

-- 人物移动
function ExploreLayer:move(touchTilePos)
    local roleTilePos = self:posToTilepos(self.roleNodePos)
    local gid = self.blockLayer:getTileGIDAt(touchTilePos)
    if gid ~= 1000 then
            if touchTilePos.x == roleTilePos.x  and touchTilePos.y ~= roleTilePos.y then     -- 上下移动
                local dirction = -(touchTilePos.y - roleTilePos.y) / math.abs(touchTilePos.y - roleTilePos.y)
                self.schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
                    function(dt) 
                        self:roleOrMapMove(touchTilePos, 2, dirction * self.moveSpeed)
                    end, 0 ,false)
            else
                self.isMove = false
            end
            if touchTilePos.y == roleTilePos.y and touchTilePos.x ~= roleTilePos.x then     -- 左右移动
                local dirction = (touchTilePos.x - roleTilePos.x) / math.abs(touchTilePos.x - roleTilePos.x)
                self.schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
                    function(dt) 
                        self:roleOrMapMove(touchTilePos, 1, dirction * self.moveSpeed)
                    end, 0 ,false)
            else
                self.isMove = false
            end
    else
        print(string.format("gid is %d", gid))
    end
end

-- 1为左右移动，2为上下移动, moveSpeed为移动速度
function ExploreLayer:roleOrMapMove(touchTilePos, dirStr, moveSpeed)
    if  self.moveTime == 0 then
        if self:blockStop(touchTilePos, dirStr, moveSpeed) == true then
            return
        end
    end
    self.isMove = true
    self.moveTime = self.moveTime + 1
    
    local mapX, mapY = self.exploreMap:getPosition()
    self.mapWorldPos = cc.p(mapX, mapY)
    
    if dirStr == 1 then
        local leftLen = self.visibleSize.width / 2
        local rightLen = self.mapSize.width - self.visibleSize.width / 2
        if self.roleNodePos.x <= leftLen or self.roleNodePos.x >= rightLen then
            self.role:setPositionX(self.roleNodePos.x + moveSpeed)
            self.roleNodePos.x = self.roleNodePos.x + moveSpeed
        elseif self.roleNodePos.x > leftLen and self.roleNodePos.x < rightLen then
            self.exploreMap:setPositionX(self.mapWorldPos.x - moveSpeed)
            self.role:setPositionX(self.roleNodePos.x + moveSpeed)
            self.mapWorldPos.x = self.mapWorldPos.x - moveSpeed
            self.roleNodePos.x = self.roleNodePos.x + moveSpeed
        end
    elseif dirStr == 2 then 
        local downLen = self.visibleSize.height / 2
        local upLen = self.mapSize.height - self.visibleSize.height / 2
        if self.roleNodePos.y <= downLen or self.roleNodePos.y >= upLen then
            self.role:setPositionY(self.roleNodePos.y + moveSpeed)
            self.roleNodePos.y = self.roleNodePos.y + moveSpeed
        elseif self.roleNodePos.y > downLen and self.roleNodePos.y < upLen then
            self.exploreMap:setPositionY(self.mapWorldPos.y - moveSpeed)
            self.role:setPositionY(self.roleNodePos.y + moveSpeed)
            self.mapWorldPos.y = self.mapWorldPos.y - moveSpeed
            self.roleNodePos.y = self.roleNodePos.y + moveSpeed
        end
    end
    if self.moveTime == 10 then
        self.roleTilePos = self:posToTilepos(self.roleNodePos)
        self:blockStop(touchTilePos, dirStr, moveSpeed)
        self:openShade(self.roleTilePos)                            -- 打开迷雾
        self:recordMoveDot(self.roleTilePos)                        -- 记录走过的点
        self.moveTime = 0
--        self:darkMine(self.mapId)                                   -- 遇到暗雷
    end
end

-- 遇到障碍物停止移动
function ExploreLayer:blockStop(touchTilePos, dirStr, moveSpeed)
    if self:touchPosStop(touchTilePos) == true then
        return false
    end
    
    if dirStr == 1 then
        local direction = moveSpeed / math.abs(moveSpeed)
        local nextPos = cc.p(self.roleNodePos.x + direction * 41, self.roleNodePos.y)
        local nextTilePos = self:posToTilepos(nextPos)
        local mapGID = self.blockLayer:getTileGIDAt(nextTilePos)
        if mapGID ~= 0 and mapGID ~= 79 then
            self:moveEvent(nextTilePos, mapGID)
            return true
        end
    elseif dirStr == 2 then
        local direction = moveSpeed / math.abs(moveSpeed)
        local nextPos = cc.p(self.roleNodePos.x, self.roleNodePos.y + direction * 41)
        local nextTilePos = self:posToTilepos(nextPos)
        local mapGID = self.blockLayer:getTileGIDAt(nextTilePos)
        if mapGID ~= 0 and mapGID ~= 79 then
            self:moveEvent(nextTilePos, mapGID)
            return true
        end 
    end
    return false
end

-- 移动到点击坐标停止
function ExploreLayer:touchPosStop(touchTilePos)
    local roleTilePos = self:posToTilepos(self.roleNodePos)
    local stop = false 
    if self.blockLayer:getTileGIDAt(roleTilePos) == 79 and self.isMove == true and self.moveTime ~= 0 then             -- 走到传送阵
        stop = true
        local seriesId = self:tilePosToSeriesID(roleTilePos)
        local strProb = StaticData.ExploreMap[seriesId].Attribute
        self:tranFront(strProb, "_")
    elseif roleTilePos.x == touchTilePos.x and roleTilePos.y == touchTilePos.y then             -- 是否在点击的坐标
        stop = true
    end
    if stop == true then
        if self.schedule ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
            self.schedule = nil
        end
        self.isMove = false
        return true
    else
        return false
    end
end

function ExploreLayer:moveEvent(tilePos, mapGID)

    if self.schedule ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedule)
        self.schedule = nil
    end
    self.isMove = false
    local seriesId = self:tilePosToSeriesID(tilePos)
    
    local function eventBtn(seriesId)
        local type = StaticData.ExploreMap[seriesId].Type
    
        local csb = cc.CSLoader:createNode("csb/ExploreSelectBtnLayer.csb")
        local panel = csb:getChildByName("Panel")
        
        local btnPanel = panel:getChildByName("btnPanel")
        local btnTable = {}
        btnTable.btn1 = btnPanel:getChildByName("Button_1")  
        btnTable.btn2 = btnPanel:getChildByName("Button_2")   
        btnTable.btn3 = btnPanel:getChildByName("Button_3")   
        local prob = 0

        local function touchEvent(sender, eventType)
            if eventType == cc.EventCode.ENDED  then 
                if sender == btnTable.btn1 then
                    if UserData.Task.acceptedTaskList[5][1] ~= "nil" and UserData.Task.acceptedTaskList[5][1] == StaticData.ExploreMap[seriesId].Attribute then
                        ManagerTask:StartTaskImmediately(StaticData.ExploreMap[seriesId].Attribute)
                    else
                        ManagerTask.SectionId = StaticData.ExploreMap[seriesId].TalkID
                        UserData.Explore:sendGetCell(self.mapId, seriesId, prob, 0)
                    end
                    self.isMove = false
                    self:removeChildByTag(seriesId)
                elseif sender == btnTable.btn2 then
                    self:removeChildByTag(seriesId)
                elseif sender == btnTable.btn3 then
                    self:removeChildByTag(seriesId)
                end
                self.isPlot = false
            end
        end
        if type == 2 then
            prob = self:eventProb(StaticData.ExploreMap[seriesId].Prob)
        end

        local str = StaticData.ExploreMap[seriesId].SelectTitle
        local table = string.split(str, "|")
        for i = 1, 3 do
            if table[i] ~= nil and StaticData.taskMonsterDialog[tonumber(table[i])].content ~= "" then
                local text = btnTable[string.format("btn%d", i)]:getChildByName("text")
                text:setString(StaticData.taskMonsterDialog[tonumber(table[i])].content)
                local size = text:getContentSize()
                btnTable[string.format("btn%d", i)]:setContentSize(cc.size(size.width + 34, 64))
                btnTable[string.format("btn%d", i)]:setPressedActionEnabled(true)
                btnTable[string.format("btn%d", i)]:addTouchEventListener(touchEvent)
            else
                btnTable[string.format("btn%d", i)]:setVisible(false)
            end
        end
        return csb
    end

    local function onEnterPrePlot(serId)
        if StaticData.ExploreMap[serId].PassTaskID ~= 0 then
            ManagerTask.SectionId = StaticData.ExploreMap[seriesId].PassTaskID
            local layer = PlotLayer:create()
            layer:initPlotEnterAntExit(0)
            local SceneManager = require("app.views.SceneManager")
            SceneManager:addToGameScene(layer, 50)
        end
    end

    local type = 0
    
    if StaticData.ExploreMap[seriesId] ~= nil then
        type = StaticData.ExploreMap[seriesId].Type
    end
    local openGrid = nil 
    if type == 0 then                   -- 障碍
        local tackTable = string.split(StaticData.Map[self.mapId].TackForBuild, "|")
        local num = math.random(1, #tackTable)
        local str = StaticData.taskMonsterDialog[tonumber(tackTable[num])].content
        self:setLabel(str, tilePos)
    elseif type == 2 then                --事件
        openGrid = true
    elseif type == 1 or type == 8 or type == 9 or type == 10 then
        openGrid = true
    elseif type == 7 then
        local str = cc.UserDefault:getInstance():getStringForKey("taskNPC" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID)
        local posStr = self:posToString(tilePos)
        local find = string.find(str, posStr, 1)
        if UserData.Task.acceptedTaskList[5][1] == StaticData.ExploreMap[seriesId].Attribute then
            openGrid = true
        elseif find ~= nil then
            onEnterPrePlot(seriesId)
        elseif UserData.Task.acceptedTaskList[5][1] ~= "nil" then
            onEnterPrePlot(seriesId)
        else
            local exploreTaskId = tonumber(StaticData.ExploreMap[seriesId].Attribute)
            local preTaskID = StaticData.Task[exploreTaskId].PreTaskID
            if preTaskID ~= 0 and UserData.Task.finishExploreTaskList[preTaskID] == nil then
                onEnterPrePlot(seriesId)
            else
                openGrid = true
            end
        end
    elseif mapGID == 183 or mapGID == 145 or mapGID == 107 or mapGID == 69 then
        if StaticData.ExploreMap[seriesId].PassTaskID ~= 0 then
            self:setLabel(StaticData.taskMonsterDialog[StaticData.ExploreMap[seriesId].PassTaskID].content, tilePos)
        end
    elseif type == 11 then
        if seriesId == 110204 then
            if self.newLeadLayer_2 ~= nil then
                self.newLeadLayer_2:removeFromParent()
                self.newLeadLayer_2 = nil
                UserData.NewHandLead:CompleteGuide("Explore_2")
            end
        end
        openGrid = true
    end
    
    if openGrid == true and self.isPlot == false then
        self.openStr = cc.UserDefault:getInstance():getStringForKey("exploreOpen" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID)
        local posStr = self:posToString(tilePos)
        local find = string.find(self.openStr, posStr, 1)
        if find == nil then
            if StaticData.ExploreMap[seriesId].TalkID ~= 0 then
                self.isPlot = true
                ManagerTask.SectionId = StaticData.ExploreMap[seriesId].TalkID
                local plot = PlotLayer:create(eventBtn, seriesId)
                self:addChild(plot)
                plot:setTag(seriesId)
                print(seriesId)
            else
                local prob = 0
                if StaticData.ExploreMap[seriesId].Type == 2 then
                    prob = self:eventProb(StaticData.ExploreMap[seriesId].Prob)
                end
                UserData.Explore:sendGetCell(self.mapId, seriesId, prob, 0)
                self.isPlot = false
            end
        elseif type == 11 then
            onEnterPrePlot(seriesId)
        end
    end
end

-- 打开遮罩层
function ExploreLayer:openShade(roleTilePos)
    if self.shadeLayer == nil then
        return
    end
    local borderX = self.mapSize.width / 80 - 1
    local borderY = self.mapSize.height / 80 - 1
    
    local rangeX = roleTilePos.x + 1
    local rangeY = roleTilePos.y + 1
    if self.mapId == 1 and UserData.NewHandLead:getGuideState("Explore_1") ~= 1 and roleTilePos.x == 8 and roleTilePos.y == 2 then
        rangeY = rangeY + 1
    end
    for i = roleTilePos.x - 1, rangeX do
        if i >= 0 and i <= borderX then
            for j = roleTilePos.y - 1, rangeY do
                if j >= 0 and j <= borderY then
                    self.shadeLayer:setTileGID(0, cc.p(i, j))
                end
            end
        end
    end
    if self.newLeadLayer_1 ~= nil and roleTilePos.x == 8 and roleTilePos.y == 3 and UserData.NewHandLead:getGuideState("Explore_1") ~= 1 then
        if self.newLeadLayer_1 ~= nil then
            self.newLeadLayer_1:removeFromParent()
            self.newLeadLayer_1 = nil
            UserData.NewHandLead:CompleteGuide("Explore_1")
        end
    end
    if self.roleTilePos.x == 2 and self.roleTilePos.y == 5 and UserData.NewHandLead:getGuideState("Explore_2") ~= 1 then
        local userExplore = UserData.NewHandLead.GuideList["Explore_2"]
        userExplore.parent = self

        self.newLeadLayer_2 = UserData.NewHandLead:startNewGuide(userExplore)
        self.exploreMap:addChild(self.newLeadLayer_2, 30)
    
        ManagerTask.SectionId = UserData.NewHandLead.GuideList.Explore_2.step[1].PlotSectionID
        local plot = PlotLayer:create()
        plot:initPlotEnterAntExit(0)
        self:addChild(plot, 50)
    end
end

-- 坐标转成字符串
function ExploreLayer:posToString(tilePos)
    tilePos.x = tonumber(tilePos.x)
    tilePos.y = tonumber(tilePos.y) 
    if tilePos.x < 10 then
        tilePos.x = "0" .. tilePos.x
    end
    if tilePos.y < 10 then
        tilePos.y = "0" .. tilePos.y
    end
    local string = tilePos.x .. "_" .. tilePos.y
    return string
end

-- 记录走过的坐标
function ExploreLayer:recordMoveDot(tilePos)
    if self.shadeLayer ~= nil then
        local pos = self:posToString(tilePos)
        local find1, find2 = string.find(self.posString, pos)
        print(find1)
        if find1 == nil then
            self.posString = self.posString .. "|" .. pos
            print(self.posString)
            cc.UserDefault:getInstance():setStringForKey("explore" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, self.posString)
        end
    end
end

-- 获取记录的所有坐标
function ExploreLayer:getRoleMoveDot(posStr, char)
    local posTable = string.split(posStr, "|")
    local allPos = {}
    
    local function setAllPos(dot)
        local pos = cc.p(tonumber(dot[1]), tonumber(dot[2]))
        table.insert(allPos, pos)
    end
    for i = 1, #posTable do
        local dot = string.split(posTable[i], char)
        setAllPos(dot)
    end
    return allPos
end

-- 解析字符串
function ExploreLayer:stringAnalyze(str, char)

    local allStrTable = {}
    local stringTable = string.split(str, "|")
    
    local function getAllTable(dotAndProb)                      
        local dot = string.split(dotAndProb[1], char)
        local t = {}
        table.insert(t, tonumber(dot[1]))                     -- x坐标
        table.insert(t, tonumber(dot[2]))                     -- y坐标
        table.insert(t, tonumber(dotAndProb[2]))              -- 概率
        table.insert(allStrTable, t)
    end
    for i = 1, #stringTable do
        local dotAndProb = {}
        dotAndProb = string.split(stringTable[i], "-")
        getAllTable(dotAndProb)
    end
    
    return allStrTable

end

-- 计算传送概率
function ExploreLayer:tranFront(strProb, char)
 
    local posX = 0
    local posY = 0
    local dotProb = self:stringAnalyze(strProb, char)

    local num = math.random(1, 100) / 100
    local prob = 0
    local index = 0
    for i = 1, #dotProb do                            -- 计算概率
        index = index + 1
        if num > prob / 10000 and num <= dotProb[i][3] / 10000 + prob / 10000 then
            break
        end
        prob = prob + dotProb[i][3]
    end
    local tranPos = self:tileposToPos(cc.p(dotProb[index][1], dotProb[index][2]))
    
    if tranPos.x < self.visibleSize.width / 2 then
        posX = 0
    elseif tranPos.x > self.mapSize.width - self.visibleSize.width / 2 then
        posX = self.visibleSize.width - self.mapSize.width
    else
        local posGap = self.visibleSize.width/2 - (tranPos.x + self.mapWorldPos.x)
        posX = posGap + self.mapWorldPos.x
    end
    if tranPos.y < self.visibleSize.height / 2 then
        posY = 0
    elseif tranPos.y > self.mapSize.height - self.visibleSize.height / 2 then
        posY = self.visibleSize.height - self.mapSize.height 
    else
        local posGap = self.visibleSize.height/2 - (tranPos.y + self.mapWorldPos.y)
        posY = posGap + self.mapWorldPos.y
    end
    local pos = cc.p(posX, posY)
    local callBack_1 = cc.CallFunc:create(function()
        self.role:setVisible(false)
    end)
    local moveTime = math.sqrt(math.pow((self.mapWorldPos.x - pos.x),2) + math.pow((self.mapWorldPos.y - pos.y), 2)) / 500
    local moveTo = cc.MoveTo:create(moveTime, pos)
    local callBack_2 = cc.CallFunc:create(function()
        self.role:setPosition(tranPos.x, tranPos.y)
        self.role:setVisible(true)
        self:openShade(cc.p(dotProb[index][1], dotProb[index][2]))
        self.roleNodePos = tranPos
        self:recordMoveDot(cc.p(dotProb[index][1], dotProb[index][2]))
    end)
    local seq = cc.Sequence:create(callBack_1, moveTo, callBack_2)
    self.exploreMap:runAction(seq)
end

-- 数字转成坐标
function ExploreLayer:numToPos(x, y)
    if x < 10 then
        x = "0" .. x
    end
    if y < 10 then
        y = "0" .. y
    end
    local string = x .. "_" .. y
    return string
end

-- 格子坐标转成地图序列号
function ExploreLayer:tilePosToSeriesID(tilePos)
    local map = 10 + self.mapId
    local posX = tilePos.x
    local posY = tilePos.y
    if posX < 10 then
        posX = "0" .. posX
    end
    if posY < 10 then
        posY = "0" .. posY
    end
    local seriesId = map .. posX .. posY
    seriesId = tonumber(seriesId)
    
    return seriesId
end

-- 地图序列号转成格子坐标
function ExploreLayer:seriesIDTotilePos(serStr)
    local map = string.sub(serStr, 1, 2)
    local posX = string.sub(serStr, 3, 4)
    local posY = string.sub(serStr, 5, 6)
    
    return cc.p(tonumber(posX), tonumber(posY))
end

-- 计算事件概率
function ExploreLayer:eventProb(probStr)
    -- 为了方便使用getRoleMoveDot解析字符串
    local probTable = self:getRoleMoveDot(probStr, "_")
    local num = math.random(1, 100)
    local num = num / 100
    if num <= probTable[1].y / 10000 then
        return 1
    elseif num > probTable[1].y / 10000 and num <= probTable[1].y / 10000 + probTable[2].y / 10000 then
        return 2
    end
end

-- 随机刷箱子和事件
function ExploreLayer:showNum(mapId, boxNum, eventNum)
    local showStr = StaticData.Map[1].ShowNum
    local showNum = self:getRoleMoveDot(showStr, "-")
    local exploreMapInfo =  UserData.Explore.map
    showNum[1].y = showNum[1].y - exploreMapInfo[self.mapId][ExploreEnum.Box]
    showNum[2].y = showNum[2].y - exploreMapInfo[self.mapId][ExploreEnum.Event]
    showNum[3].y = exploreMapInfo[self.mapId][ExploreEnum.BigBox] 
    showNum[4].y = exploreMapInfo[self.mapId][ExploreEnum.Crystal] 
    showNum[5].y = exploreMapInfo[self.mapId][ExploreEnum.Jewel] 
    
    local bigBoxStr = StaticData.Map[mapId].Type2
    local bigBoxTable = self:getRoleMoveDot(bigBoxStr, "-")
    local bigBoxNum = bigBoxTable[1].y
    local crystalNum = bigBoxTable[2].y
    local jewelNum = bigBoxTable[3].y
    
    local showBoxAndEventPosStr = nil
    
    local function recordEventDot(allNum, sNum, tilePos)
        local seriesId = self:tilePosToSeriesID(tilePos)
        local pos = nil
        if allNum > sNum and sNum ~= 0 then
            local num = math.random(1, 10)
            if num > 5 and num <= 10 and sNum ~= 0 then
                self:setRecordGid(tilePos)
                pos = tilePos
                sNum = sNum - 1
                allNum = allNum - 1
            else
                allNum = allNum - 1
            end
        elseif allNum == sNum and sNum ~= 0 then
            self:setRecordGid(tilePos)
            pos = tilePos
            sNum = sNum - 1
            allNum = allNum - 1
        end
        return allNum, sNum, pos
    end
    
    for i = 1, #self.allEventDot do
        local seriesId = self:tilePosToSeriesID(cc.p(self.allEventDot[i].x, self.allEventDot[i].y))
        local pos = nil
        local type = StaticData.ExploreMap[seriesId].Type
        if type == 1 then
            boxNum, showNum[1].y, pos = recordEventDot(boxNum, showNum[1].y, cc.p(self.allEventDot[i].x, self.allEventDot[i].y))
        elseif type == 2 then
            eventNum, showNum[2].y, pos = recordEventDot(eventNum, showNum[2].y, cc.p(self.allEventDot[i].x, self.allEventDot[i].y))
        elseif type == 8 then 
            bigBoxNum, showNum[3].y, pos = recordEventDot(bigBoxNum, showNum[3].y, cc.p(self.allEventDot[i].x, self.allEventDot[i].y))
        elseif type == 9 then
            crystalNum, showNum[4].y, pos = recordEventDot(crystalNum, showNum[4].y, cc.p(self.allEventDot[i].x, self.allEventDot[i].y))
        elseif type == 10 then
            jewelNum, showNum[5].y, pos = recordEventDot(jewelNum, showNum[5].y, cc.p(self.allEventDot[i].x, self.allEventDot[i].y))
        end
        
        if pos ~= nil then
            if showBoxAndEventPosStr == nil then
                showBoxAndEventPosStr = self:posToString(pos)
            else
                local str = self:posToString(pos)
                showBoxAndEventPosStr = showBoxAndEventPosStr .. "|" .. str
            end
            cc.UserDefault:getInstance():setStringForKey("exploreShowBoxAndEvent" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, showBoxAndEventPosStr)
        end
    end
end

-- 设置打开的格子
function ExploreLayer:setOpenGid(tilePos, isZero)
    local seriesId = self:tilePosToSeriesID(tilePos)
    local mapGid = 0
    local type = StaticData.ExploreMap[seriesId].Type
    if isZero ~= 0 then
        mapGid = StaticData.ExploreMap[seriesId].Icon
    end

    local layer = nil
    if type == 1 then
        if mapGid == 220 then
            layer = self.prisonLayer
        elseif mapGid == 142 then
            layer = self.boxLayer
            mapGid = mapGid + 3
        else
            layer = self.monsterLayer
        end
    elseif type == 8 or type == 9 or type == 10 then
        layer = self.boxLayer
        mapGid = mapGid + 3
    end

    for i = tilePos.x - 1, tilePos.x + 1 do
        for j = tilePos.y - 1, tilePos.y do
            if layer ~= nil then
                local newGid = 0
                if layer == self.boxLayer and i == tilePos.x - 1 and j == tilePos.y - 1 then
                elseif isZero == true then
                    layer:setTileGID(newGid, cc.p(i, j))
                else
                    local newGid = mapGid +(j - tilePos.y) * 19 + i - tilePos.x
                    layer:setTileGID(newGid, cc.p(i, j))
                end
                if i == tilePos.x and j == tilePos.y and isZero ~= true then
                    self.blockLayer:setTileGID(mapGid, cc.p(i, j))
                elseif i == tilePos.x and j == tilePos.y and isZero == true then
                    self.blockLayer:setTileGID(0, cc.p(i, j))
                end
            end
        end
    end
end

-- 设置记录的格子
function ExploreLayer:setRecordGid(tilePos)
    local seriesId = self:tilePosToSeriesID(tilePos)
    local type = StaticData.ExploreMap[seriesId].Type
    local icon = StaticData.ExploreMap[seriesId].Icon
    local layer = nil
    if type == 1 then
        if icon == 220 then
            layer = self.prisonLayer
        elseif icon == 142 then
            layer = self.boxLayer
        else
            layer = self.monsterLayer
        end
    elseif type == 8 or type == 9 or type == 10 then
        layer = self.boxLayer
    elseif type == 2 then
        self.blockLayer:setTileGID(icon, tilePos)
        return
    end
    for i = tilePos.x - 1, tilePos.x + 1 do
        for j = tilePos.y - 1, tilePos.y do
            if layer ~= nil then
                local newGid = 0
                newGid = icon +(j - tilePos.y) * 19 + i - tilePos.x
                layer:setTileGID(newGid, cc.p(i, j))
            end
            if i == tilePos.x and j == tilePos.y then
                self.blockLayer:setTileGID(icon, cc.p(i, j))
            end
        end
    end
end

-- 暗雷怪
function ExploreLayer:darkMine(mapId)

    local function openDarkMine()
        local NPCTable = string.split(StaticData.Map[mapId].MonsterID, "|")
        local index = math.random(1, #NPCTable)
        local NPCId = tonumber(NPCTable[index])

        local needCostAction = StaticData.Npc[NPCId].TiLi -- 需要的体力
        if needCostAction > UserData.BaseInfo.nAction then
            local publicTipLayer = require("app/views/public/publicTipLayer")
            publicTipLayer:setTextAction("体力不足")
        else
            UserData.BaseInfo:setCostAction(needCostAction) --请求体力消耗  
              
            local MyFightingCtrl = require("app.views.MyFighting.MyFightingCtrl")
            MyFightingCtrl:getFightingFibbleGodData(NPCId)
            UserData.BaseInfo.myFightTaskId = 0

            local SceneManager = require("app.views.SceneManager")
            local myFightingLayer = require("app.views.MyFighting.MyFightingLayer"):create()
            SceneManager:addToGameScene(myFightingLayer, 100)

        end

     
    end
    
    self.stepNum = self.stepNum + 1

    if self.stepNum == 10 then
        self.stepNum = 0
        openDarkMine()
    else
        local num = math.random(1, 100)
        if num > 0 and num < 8 then
            self.stepNum = 0
            openDarkMine()
        end
    end
end

function ExploreLayer:onExploreThrouth(event)
    local userdata = event._usedata
    if userdata ~= 0 then
        if self.shadeLayer ~= nil then
            self.publicTipLayer:setTextAction("你 已 通 关")
            local tilePos = self:seriesIDTotilePos(StaticData.Map[self.mapId].BossCell)
            self.shadeLayer:removeFromParent()
            self.shadeLayer = nil
            cc.UserDefault:getInstance():setStringForKey("explore" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, "through")
            
            local index = StaticData.Map[self.mapId].BossCell
            local str = StaticData.ExploreMap[index].Pos
            if self.openStr ~= nil and self.openStr ~= "" then
                self.openStr = self.openStr .. "|" .. str
            else
                self.openStr = str
            end
            cc.UserDefault:getInstance():setStringForKey("exploreOpen" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, self.openStr)
        end
    end
end

function ExploreLayer:onGetCell(event)
    local userdata = event._usedata
    print(string.format("userdata.res is %d", userdata.res))
    self.isMove = false
    local function recordOpendDot(str)
        local find = string.find(self.openStr, str, 1)
        if find == nil then
            if self.openStr ~= nil and self.openStr ~= "" then
                self.openStr = self.openStr .. "|" .. str
            else
                self.openStr = str
            end
            cc.UserDefault:getInstance():setStringForKey("exploreOpen" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, self.openStr)
        end
    end

    if userdata.res == 0 then
        local tilePos = self:seriesIDTotilePos(userdata.seriesID)
        local tileGID = self.blockLayer:getTileGIDAt(tilePos)
        local type = StaticData.ExploreMap[userdata.seriesID].Type
        local isOpen = false
        if type == 1 then
            local tileGID = self.blockLayer:getTileGIDAt(tilePos)
            if tileGID == 142 then
                self:setOpenGid(tilePos, false)
            else
                self:setOpenGid(tilePos, true)
            end
            isOpen = true
        elseif type == 2 then
            self.blockLayer:setTileGID(0, tilePos)
            isOpen = true
        elseif type == 8 or type == 9 or type == 10 then
            self:setOpenGid(tilePos, false)
            isOpen = true
        elseif type == 7 then 
            if self.taskNPC ~= userdata.value then
                local posStr = self:posToString(tilePos)
                local str = cc.UserDefault:getInstance():getStringForKey("taskNPC" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID)
                local find = string.find(str,posStr,1)
                if find == nil or find == "" then
                    if str == nil or str == "" then
                        cc.UserDefault:getInstance():setStringForKey("taskNPC" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, posStr)
                    else
                        str = str .. "|" .. posStr
                        cc.UserDefault:getInstance():setStringForKey("taskNPC" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[self.mapId].ID, str)
                    end
                end
            end
        end
        if userdata.type == 2 then
            local seriesId = self:tilePosToSeriesID(tilePos)
            local npcId = StaticData.ExploreMap[seriesId].MonsterID
            
            local needCostAction = StaticData.Npc[npcId].TiLi -- 需要的体力
            if needCostAction > UserData.BaseInfo.nAction then
                local publicTipLayer = require("app/views/public/publicTipLayer")
                publicTipLayer:setTextAction("体力不足")
            else
                UserData.BaseInfo:setCostAction(needCostAction) --请求体力消耗  
                
                local MyFightingCtrl = require("app.views.MyFighting.MyFightingCtrl")
                MyFightingCtrl:getFightingFibbleGodData(npcId)
                UserData.BaseInfo.myFightTaskId = 0
                local SceneManager = require("app.views.SceneManager")
                local myFightingLayer = require("app.views.MyFighting.MyFightingLayer"):create()
                SceneManager:addToGameScene(myFightingLayer, 100)

            end

          
        end
        if isOpen == true then
            local str = self:posToString(tilePos)
            recordOpendDot(str)
        end
        self.rightBar:onGetCell(userdata)
    elseif userdata.res == 1 then
        self.publicTipLayer:setTextAction("你上层地图还没通过哦")
    elseif userdata.res == 2 then
        self.publicTipLayer:setTextAction("格子ID错误")
    elseif userdata.res == 3 then
        self.publicTipLayer:setTextAction("没有钥匙打开")
    elseif userdata.res == 4 then
        self.publicTipLayer:setTextAction("缺少钥匙")
    elseif userdata.res == 5 then
        self.publicTipLayer:setTextAction("缺少交易物品")
    elseif userdata.res == 6 then
        self.publicTipLayer:setTextAction("无法购买")
    elseif userdata.res == 7 then
        self.publicTipLayer:setTextAction("物品购买游戏币或者元宝不足")
    end
end

function ExploreLayer:onGetNoticePrize(event)
    local userdata = event._usedata
    local function judgeAwardAndPunish(num)
        if num > 0 then
            return "你获得了 "
        elseif num < 0 then
            return "你失去了 "
        else
            return nil
        end
    end
    if StaticData.Prize[1] ~= nil then
        if StaticData.Prize[1].Gold ~= 0 then
            self.publicTipLayer:setTextAction(judgeAwardAndPunish(userdata.gold) .. userdata.gold .. " 金币")
        end
        if StaticData.Prize[1].Exp ~= 0 then
            self.publicTipLayer:setTextAction(judgeAwardAndPunish(userdata.Exp) .. userdata.Exp .. " 经验")
        end
        if StaticData.Prize[1].Ingot ~= 0 then
            self.publicTipLayer:setTextAction(judgeAwardAndPunish(userdata.ingot) .. userdata.ingot .. " 元宝")
        end
        if StaticData.Prize[1].Action ~= 0 then
            self.publicTipLayer:setTextAction(judgeAwardAndPunish(userdata.action) .. userdata.action .. " 体力")
        end
    end
    for i = 1, #userdata.goods do
        local goodName = StaticData.Item[userdata.goods[i].Id].ItemName
        self.publicTipLayer:setTextAction("你获得了 " .. goodName)
    end
end

-- 触摸事件
function ExploreLayer:touchEvent()

    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)

    listener:registerScriptHandler(function(touch, event)
        local OperateUI = self.bottomBar
        if OperateUI:getUpDownState() then
            OperateUI:setUpDownStateToDown()
        end
        
        self.rightBar:changeToHide()
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    
    listener:registerScriptHandler(function(touch, event)

    end, cc.Handler.EVENT_TOUCH_MOVED)
    
    listener:registerScriptHandler(function(touch, event)
        local touchPos = touch:getLocation()
        local touchNodePos = self:touchPosToNodePos(touchPos)
        local touchTilePos = self:posToTilepos(touchNodePos)
        if touchTilePos.x > 0 and touchTilePos.x < self.mapSize.width / 80 - 1 and touchTilePos.y > 0 and touchTilePos.y < self.mapSize.height / 80 - 1 then
            local shadeGID = nil
            if self.shadeLayer ~= nil then
                local shadeGID = self.shadeLayer:getTileGIDAt(touchTilePos)
                if shadeGID == 0 then
                    if self.isMove == false and self.schedule == nil then
                        self.isMove = true
                        self.move(self, touchTilePos)
                    end
                end
            else
                if self.isMove == false then
                    self.isMove = true
                    self.move(self, touchTilePos)
                end
            end
        end

    end, cc.Handler.EVENT_TOUCH_ENDED)
    
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

return ExploreLayer