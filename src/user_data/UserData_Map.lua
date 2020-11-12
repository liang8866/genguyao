--地图数据
-- UserData.Map

local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local Net         = require("net.Net")
local DataManager = require("app.views.public.DataManager")

local Map = {
    FIRST_MAP_ID = "611001",             -- 人界(新手进入的默认地图)
    FIRST_TOWN_ID = "612001",            -- 仙桃村(新手进入的默认城镇点)
    
    currentWorldMapID = 0,               -- 当前选择的世界地图ID
    nextOpenedTownID = "",               -- 下一个即将开启的城镇ID
    
    roleStayPoint = cc.p(0,0),           -- 标记 当前角色停留的位置点
    roleStayPointID = "",                -- 标记 当前角色停留的城镇点或支点(如果不在城镇点或支点上，此处为空字符串)
    roleIsMoving = false,                -- 当前是否在自动移动过程中
        
    openedTownIDlist = {},               -- 已经开启的城镇列表

    stageOverInfoByTaskID = {},          -- 标记已经达到过的城镇id2

    roadPointInfo = {},                  --当前地图的数据
}

function Map:initMapData()
    self.roleStayPointID = self:getRoleStayPointID()
    self.currentWorldMapID = self:getRoleStayWorldMapID()

   
    self.nextOpenedTownID = self:getNextOpenedTownID()

    self:getRoleStayPoint()

    local worldMapStaticData = StaticData.WorldMap[self.currentWorldMapID]
    if worldMapStaticData == nil then
        cclog("world map id is not find in StaticData.WorldMap.")
        return 
    end

    local StageMapLayer = require("app.views.StageMap.StageMapLayer")
    StageMapLayer:initAllRoadPointInfo(self.currentWorldMapID,true)  --初始化城镇点
end


-- 读取静态数据初始化城镇点及事件点
--function Map:initAllRoadPointInfo(mapID,showRoadPointDynamic)
--    local curMainTaskID = 0
--    if UserData.Task.acceptedTaskList[1][1] ~= "nil" then
--        curMainTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
--    else
--        curMainTaskID = ManagerTask:getNextMainTaskId(UserData.Task.recentlyTaskId)
--    end
--    local curTaskTownID = 0
--    if curMainTaskID > 0 then
--        curTaskTownID = tonumber(StaticData.Task[curMainTaskID].TownID)
--    end
--    local townIDList = StageMapConfig:getAllTownIDInWorldMap(mapID)
--    for i=1,#townIDList do
--        local townID = townIDList[i]  -- string类型
--        local townStaticDataInfo = StaticData.TownMap[townID]
--        local townPos = string.split(townStaticDataInfo.TownPos,"*")
--        local isMainTown = self:isMainTown(townID)
--        local isOver = self:getOverStateById(townIDList[i])
--        if roadPointInfo[townID] == nil then
--            roadPointInfo[townID] = {}
--        end
--        roadPointInfo[townIDList[i]].id =  townIDList[i]
--        roadPointInfo[townIDList[i]].isMainTown =  isMainTown
--        roadPointInfo[townIDList[i]].pos = cc.p( tonumber(townPos[1]),  tonumber(townPos[2]) )
--        roadPointInfo[townIDList[i]].over = isOver
--
--        if showRoadPointDynamic == false then  -- 一次加载全部城镇点，不动态加载 ,已经经过的事件点不再显示出来
--            if roadPointInfo[townIDList[i]].node == nil then
--                if isMainTown or isOver == false then
--                    local buildImage,imageNameBG = self:createTownPointButton(townStaticDataInfo)
--                    roadPointInfo[townIDList[i]].node = buildImage
--                    if imageNameBG ~= nil then
--                        roadPointInfo[townIDList[i]].imageNameBG = imageNameBG
--                    end
--                end
--        end
--
--        if roadPointInfo[townIDList[i]].node ~= nil then
--            roadPointInfo[townIDList[i]].node:setVisible(true)
--            roadPointInfo[townIDList[i]].node:setPosition(roadPointInfo[townIDList[i]].pos)
--            if isOver then
--                roadPointInfo[townIDList[i]].node:setColor(cc.c3b(255,255,255))
--                roadPointInfo[townIDList[i]].node:setTouchEnabled(true)
--                if roadPointInfo[townIDList[i]].imageNameBG ~= nil then
--                    roadPointInfo[townIDList[i]].imageNameBG:setVisible(true)
--                end
--            else
--                if curTaskTownID > 0 and  curTaskTownID ~= tonumber(townIDList[i])  then
--                    roadPointInfo[townIDList[i]].node:setColor(cc.c3b(130,130,130))
--                    roadPointInfo[townIDList[i]].node:setTouchEnabled(false)
--                    if roadPointInfo[townIDList[i]].imageNameBG ~= nil then
--                        roadPointInfo[townIDList[i]].imageNameBG:setVisible(false)
--                    end
--                end
--            end
--        end
--        end
--    end
--end


function Map:getRoleStayPointID()
    local roleStayPointID = DataManager:getStringForKey("roleStayPointID")
    if roleStayPointID ~= nil and roleStayPointID ~= "" then
        return roleStayPointID
    end
    return ""
    --return Map.FIRST_TOWN_ID
end

function Map:getRoleStayWorldMapID()
    local worldMapID = DataManager:getIntegerForKey("roleStayWorldMapID",0)
    if worldMapID == 0 or worldMapID == nil then
        worldMapID = tonumber(Map.FIRST_MAP_ID)
        Map:SaveRoleStayWorldMapID(worldMapID)
    end
    return worldMapID
end

function Map:SaveRoleStayWorldMapID(worldMapID)
    DataManager:setIntegerForKey("roleStayWorldMapID",tonumber(worldMapID))
end

function Map:getOpenedWolrdMapID()  -- 611001-611002
    local mapIDTab = {}
    local str = DataManager:getStringForKey("openedWorldMap","")
    if str ~= nil and str ~= "" then
        mapIDTab = string.split(str,"-")
    else
        DataManager:setStringForKey("openedWorldMap", Map.FIRST_MAP_ID)
        mapIDTab[1] = Map.FIRST_MAP_ID
    end
    
    return mapIDTab
end

function Map:SaveOpenedWolrdMap(worldMapID)
    local mapIDTab = Map:getOpenedWolrdMapID()
    local needAdd = true
    for i=1,#mapIDTab do
        if mapIDTab[i] == tostring(worldMapID) then
            needAdd = false
            break
        end
    end
    if needAdd then
        mapIDTab[table.nums(mapIDTab)+1] = tostring(worldMapID)
    end
    local str = ""
    local num = table.nums(mapIDTab)
    for i=1,num do
        str = str .. mapIDTab[i]
        if i ~= num then
            str = str .. "-"
        end
    end
    DataManager:setStringForKey("openedWorldMap",str)
end

function Map:SaveUserData()
    DataManager:setStringForKey("roleStayPointID",UserData.Map.roleStayPointID)
    DataManager:setStringForKey("roleStayPoint", UserData.Map.roleStayPoint.x  .. "-" .. UserData.Map.roleStayPoint.y)
    --DataManager:setStringForKey("nextOpenedTownID",UserData.Map.nextOpenedTownID)
    
    self:SaveOpenedWolrdMap(UserData.Map.currentWorldMapID)
    self:SaveRoleStayWorldMapID(UserData.Map.currentWorldMapID)
end

function Map:getRoleStayPoint()
    local strTemp = DataManager:getStringForKey("roleStayPoint","")
    if strTemp ~= nil and strTemp ~= "" then
        local pos = string.split(strTemp,"-")
        Map.roleStayPoint.x = tonumber(pos[1])
        Map.roleStayPoint.y = tonumber(pos[2])
    end

end


function Map:getNextOpenedTownID()
    return DataManager:getStringForKey("nextOpenedTownID",Map.FIRST_TOWN_ID)
end

function Map:initAllStageOverInfo()
    local curMainTaskID = tonumber(UserData.Task.recentlyTaskId)
    if UserData.Task.acceptedTaskList[1][1] ~= "nil" then
        curMainTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
    end
    if curMainTaskID <= 0 then
        curMainTaskID = UserData.Task.firstMainTaskID
    end
    if curMainTaskID > 0 then
        local taskInfo = StaticData.Task[curMainTaskID]
        if taskInfo ~= nil and taskInfo.TownID > 0 then
            Map.nextOpenedTownID = tostring(taskInfo.TownID)
            DataManager:setStringForKey("nextOpenedTownID",Map.nextOpenedTownID)
        end
    end
    
    --通过当前的主线任务来检测地图及城镇开启状态
    UserData.Task.finishMainTasklist = {}   -- 已经开启的主线任务列表
    Map.openedTownIDlist = {}               -- 已经开启的城镇列表
    local openedMapIDlist = {}                -- 已经开启的地图列表
    local curTaskID = curMainTaskID
    while (curTaskID > 0) do
        local townID =  StaticData.Task[curTaskID].TownID
        if townID > 1000 then  --大于1000为城镇及支点ID,小于1000为探索地图ID
            local mapID = StaticData.TownMap[tostring(townID)].WorldMapId
            if Map.openedTownIDlist[mapID] == nil then
                Map.openedTownIDlist[mapID] = {}
            end
            Map.openedTownIDlist[mapID][townID] = townID
            if openedMapIDlist[mapID] == nil then
                openedMapIDlist[mapID] = mapID
                Map:SaveOpenedWolrdMap(mapID)
            end
        end
        if curTaskID ~= curMainTaskID then
            UserData.Task.finishMainTasklist[curTaskID] = curTaskID
        end
        curTaskID = StaticData.Task[curTaskID].PreTaskID
    end


    Map.stageOverInfoByTaskID = {} -- 标记已经达到过的城镇id2
    for key,value in pairs(StaticData.TownMap) do
        local townID = tonumber(key)  
        local preTaskID = tonumber(value.OpenCondition2)
        local over = false
        if preTaskID > 0 then
            over = UserData.Task.finishMainTasklist[preTaskID] ~= nil
            local data = {townID = townID,taskID = preTaskID, over = over}
            Map.stageOverInfoByTaskID[preTaskID] = data
        end
    end

    self:initMapData()
end

--通过前置任务获取城镇或事件点的ID
function Map:getTownIDByPreTaskID(taskID)
    local data = Map.stageOverInfoByTaskID[taskID] 
    return data ~= nil and tostring(data.townID) or ""
end

function Map:openNewTown(townID)
    
    local mapID = 0
    if StaticData.TownMap[tostring(townID)] ~= nil then
        mapID = StaticData.TownMap[tostring(townID)].WorldMapId
    end
    if Map.openedTownIDlist[mapID] == nil then
        Map.openedTownIDlist[mapID]  = {}
    end
    Map.openedTownIDlist[mapID][townID] = townID
end


--function Map:getStageOverInfo(worldMapID)
--
--    local stageOverInfo = nil
--    
--    local strTemp = DataManager:getStringForKey("stageOverInfo")
--    if strTemp == "" or strTemp == nil then
--        strTemp = tostring(Map.FIRST_TOWN_ID)
--        --
--    end
--
--    stageOverInfo = {}  
--    local infoTab = string.split(strTemp,"-")
--    for i=1,#infoTab do
--        stageOverInfo[infoTab[i]] = tonumber(infoTab[i])
--    end   
--    
--
--    return stageOverInfo
--end
--
--function Map:stageInfoToUserData(roadPointInfo,eventPointInfo)
--    cclog("stageInfoToUserData  begin")
--
--    local stringTemp = ""
--    for key,value in pairs(roadPointInfo) do
--        local over = (value.over ~= nil) and value.over or 0
--        if over == 1 then
--            stringTemp = stringTemp .. tostring(key) .. "-"
--        end
--    end
--
--    for key,value in pairs(eventPointInfo) do
--        local over = (value.over ~= nil) and value.over or 0
--        if over == 1 then
--            stringTemp = stringTemp .. tostring(key) .. "-"
--        end
--    end
--
--    cclog("stringTemp 11221111 = " .. stringTemp)
--    local str11 = string.sub(stringTemp,-1)
--    cclog("stringTemp str11 = " .. str11)
--    if str11 == "-" then
--        cclog("stringTemp 123455 = " .. stringTemp)
--        stringTemp = string.sub(stringTemp,1,-2)
--    end
--    cclog("stringTemp 112222222 = " .. stringTemp)
--
--    DataManager:setStringForKey("stageOverInfo",stringTemp)
--    cclog("stageInfoToUserData  end")
--end



return Map