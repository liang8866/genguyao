local stringEx = require("common.stringEx")
local publicNpc = require("app.views.Task.publicNpc")

--任务管理器 全局
ManagerTask = {
    SectionId = 0, --当前剧情的章节ID,切换到剧情对话时需先赋值
    currentMoveToNpcTaskID = 0, -- 当前要移动到的npc所属的任务ID，在任务描述界面，点击立即前往按钮后赋值
    currentPlotTaskID = 0, -- 当前剧情对话的任务ID
    
    npcList = {map = {},city = {}}, --保存地图上创建的NPC
    
    TASK_TYPE = {"[主线]","[支线]","[日常]","[循环]","[探索]"},
    startImmediatelyTaskID = 0,
    
    townTaskList = {}
}

function ManagerTask:init()
    --向服务器请求已结任务列表
   self.SectionId = 1
end

--获取已接任务列表
function ManagerTask:getAcceptedTaskList()
    return UserData.Task.acceptedTaskList
end

--获取下个可以接的主线任务
function ManagerTask:getNextCanAcceptedMainTask()
    local nextMainTaskId = ManagerTask:getNextMainTaskId(UserData.Task.recentlyTaskId)
    if nextMainTaskId > 0 and StaticData.Task[nextMainTaskId].Level <= UserData.BaseInfo.userLevel and UserData.Task.acceptedTaskList[1][1] == "nil" then
        return nextMainTaskId
    end
    return 0
end

--获取城镇任务列表(主线任务自动接，此处不做处理)  -- 暂时未使用的接口
function ManagerTask:getTownTaskList(worldMapID)
    ManagerTask.townTaskList = {}
    local StageMapConfig = require("app.views.StageMap.StageMapConfig")
    local townIDList = StageMapConfig:getAllTownIDInWorldMap(worldMapID)
    for i=1,#townIDList do
        local townID = townIDList[i]  -- string类型
        if ManagerTask.townTaskList[tonumber(townID)] == nil then
            ManagerTask.townTaskList[tonumber(townID)] = {}
        end
    end

    for key,value in pairs(StaticData.Task) do
        if value.TaskType ~= 1 and value.TaskType ~= 5 and ManagerTask.townTaskList[tonumber(value.TownID)] ~= nil then 
            if ManagerTask.townTaskList[tonumber(value.TownID)][key] == nil then
                local tbInfo = {}
                tbInfo.taskID = key
                tbInfo.townID = value.TownID
                tbInfo.taskType = value.TaskType
                ManagerTask.townTaskList[tonumber(value.TownID)][key] = tbInfo 
            end
        end
    end
    
    --打印
    --dump(ManagerTask.townTaskList)
end

-- (主线任务自动接，此处不做处理)
function ManagerTask:getCanAcceptedTaskTownList(worldMapID,roadPointInfo)
    local townTaskTypeList = {}
    local StageMapConfig = require("app.views.StageMap.StageMapConfig")
    local townIDList = StageMapConfig:getAllTownIDInWorldMap(worldMapID)
    for i=1,#townIDList do
        local townID = townIDList[i]  -- string类型
        local preTask = tonumber(StaticData.TownMap[tostring(townID)].OpenCondition2)
        local currentTaskID = UserData.Task.recentlyTaskId
        local isTownOpen = currentTaskID > 0 and currentTaskID >= preTask
        if isTownOpen then
            local mainTaskId,branchTaskList,dayTaskList,roundTaskList = UserData.Task:getCanAcceptTaskIDListInTown(tostring(townID))
            if table.nums(branchTaskList) > 0 then
                townTaskTypeList[townID] = 2 -- 有支线任务可接
            elseif table.nums(dayTaskList) > 0 then
                townTaskTypeList[townID] = 3 -- 有日常任务可接
            elseif table.nums(roundTaskList) > 0 then
                townTaskTypeList[townID] = 4 -- 有循环任务可接
            end
        end
    end
    return townTaskTypeList
end

function ManagerTask:getTaskState(taskID)
   local taskType = self:getTaskType(taskID)
   return UserData.Task.acceptedTaskProcessState[taskType] 
end

function ManagerTask:setTaskState(taskID,state)
    local taskType = self:getTaskType(taskID)
    UserData.Task.acceptedTaskProcessState[taskType] = state
end

function ManagerTask:getCanFinishTask()
    for i=1,#UserData.Task.acceptedTaskList do
        -- 任务ID-目标类型-参数1-参数2-参数3
        if UserData.Task.acceptedTaskList[i][1] ~= "nil" then
            local taskID = tonumber(UserData.Task.acceptedTaskList[i][1])
            if tonumber(UserData.Task.acceptedTaskList[i][2]) == 1 then
                if tonumber(UserData.Task.acceptedTaskList[i][3]) > 0 and
                    tonumber(UserData.Task.acceptedTaskList[i][4]) > 0 and
                    tonumber(UserData.Task.acceptedTaskList[i][4]) == tonumber(UserData.Task.acceptedTaskList[i][5]) then
                    return taskID
                 end
            else
                if self:getTaskState(taskID) == 5 then
                    return taskID
                end
            end
        end
    end
    return 0
end

function ManagerTask:getAcceptedTaskIDList()
--    local taskIdList = {510001,510002,520001,520002}
    local taskIdList = {}
    for i=1,#UserData.Task.acceptedTaskList do
        -- 任务ID-目标类型-参数1-参数2-参数3
        if UserData.Task.acceptedTaskList[i][1] ~= "nil" then
            taskIdList[#taskIdList] = UserData.Task.acceptedTaskList[i][1]
        end
    end
    return taskIdList
end

function ManagerTask:getNextMainTaskId(currentFinishedTaskID)
    --第一个主线任务时候，currentFinishedTaskID 为0，且表格里的第一个主线任务的PreTaskID为0
    for key,value in pairs(StaticData.Task) do
        if value.TaskType == 1 and currentFinishedTaskID == value.PreTaskID then 
            return value.TaskID
        end
    end
    return 0
end

function ManagerTask:getNextTaskId(currentTaskID)
    for key,value in pairs(StaticData.Task) do
        if currentTaskID == value.PreTaskID then 
            return value.TaskID
        end
    end
end

--获取任务参数信息 (-- 任务ID-目标类型-参数1-参数2-参数3)
function ManagerTask:getTaskParameter(taskID)
    for i=1,#UserData.Task.acceptedTaskList do
        if UserData.Task.acceptedTaskList[i][1] ~= "nil" and  taskID == tonumber(UserData.Task.acceptedTaskList[i][1]) then
            return UserData.Task.acceptedTaskList[i]
        end
    end
    return nil
end


--获取任务表格信息
function ManagerTask:getTaskInfo(taskID)
    return StaticData.Task[taskID]
end

--获取任务名字
function ManagerTask:getTaskName(taskID)
    return StaticData.Task[taskID].TaskName
end

--获取任务描述
function ManagerTask:getTaskDescription(taskID)
    return StaticData.Task[taskID].TaskContent
end

--获取任务追踪内容描述
-- "[text=测试测试 fontColor=ffbf00 fontSize=14 [/text][text=任务状态 fontColor=afafff fontSize=14 [/text][text=(完成) fontColor=ff007f fontSize=14 [/text][image=ui/public/public_other_27.png [/image]"
function ManagerTask:getTaskTraceTextContent(taskID)
    return StaticData.Task[taskID].TaskDesc
end

function ManagerTask:getTaskType(taskID)
    if StaticData.Task[taskID] == nil then
        print(taskID)
    end
    local taskType = StaticData.Task[taskID].TaskType
    taskType = taskType > 5 and 5 or taskType
    taskType = taskType < 1 and 1 or taskType
    return taskType
end


--获取任务需要的体力或能量
function ManagerTask:getTaskNeedPower(taskID)
    return 0
end

--解析任务的NPCID数据
function ManagerTask:splitStrForTaskId(strId)
	local npcTable = {}
	local tempTable = stringEx:split(strId,"|") --先解析有多少种类型的NPC
    for var=1, #tempTable do
        local t = stringEx:split(tempTable[var],"-")
        local item = {}
        item.npcid = tonumber(t[1]) 
        item.num =tonumber(t[2])
        npcTable[var] = item 
	end

	return npcTable
end

--解析NPC坐标的,有多个坐标的话对应NPC类型
function ManagerTask:splitStrForPos(strPos)
	local posTable = {}
    local tempTable = stringEx:split(strPos,"|") --先解析有多少种类型的NPC
    for var=1, #tempTable do
        local t = stringEx:split(tempTable[var],"-")
        local pos = cc.p(tonumber(t[1]) ,tonumber(t[2]) )
        posTable[var] = pos
      
    end
    return posTable
end



--添加NPC到城镇
function ManagerTask:addNpcToCity(taskID,cityLayer)
    local  data  = StaticData.Task[taskID]
    if data.CityType ~= 0 then --说明城镇任务
        local posTable = self:splitStrForPos(data.NpcPos)
        local npcTable = self:splitStrForTaskId(data.NpcId)
        local npc = publicNpc:create(taskID,npcTable[1].npcid) -- 城镇的只有一个NPC，，获取第一个就好
        npc:setPosition(posTable[1])-- 城镇的只有一个NPC位置，，获取第一个就好
        cityLayer:addChild(npc)
        --npcList = {map = {},city = {}}
        self.npcList.city[#self.npcList.city]=npc
	end
	
end

function ManagerTask:myRandPos(basePos)
	local xRand = {-1,1,2}
    local yRand = {-1,1,2}
    local randPosTable = {}
    local len = 100
    for i =  1, #xRand do
        for j = 1, #yRand do
            local t = cc.p(basePos.x + xRand[i] * len,basePos.y + yRand[j] * len)
--            cclog("i= %d,j=%d, x = %d , y=%d",i,j,t.x,t.y)
            table.insert(randPosTable,t)
        end
    end
	return randPosTable
end

--添加NPC到地图
function ManagerTask:addNpcToMap(taskID,mapLayer)
    local  data  = StaticData.Task[taskID]
    if data.CityType == 0  then --说明是地图上的任务
        local npcTable = self:splitStrForTaskId(data.NpcId)
        local posTable = self:splitStrForPos(data.NpcPos)
        for i = 1, #npcTable do
            local temp = npcTable[i]
            local  randPosTable = {}
            if #npcTable == 1 then
                local t = cc.p(posTable[i].x,posTable[i].y)
                table.insert(randPosTable,t)
            else
                randPosTable = self:myRandPos(posTable[i]) --获取5个坐标
            end
            for j = 1, temp.num do --对应的ID怪物有可能有多个
                local npc = publicNpc:create(taskID,temp.npcid)
                mapLayer:addChild(npc,1)
                --npcList = {map = {},city = {}}
                self.npcList.map[#self.npcList.map+1]=npc
                if j <= #randPosTable then
                    npc:setPosition(randPosTable[j])
                   
        		else
                    local  nPos = cc.p(randPosTable[1].x + math.random(20,40),randPosTable[1].y + math.random(20,40))
                    npc:setPosition(nPos)
                 
                end
        	end 
        	
        end
    end
	
end

function ManagerTask:GetTaskNpcID(taskID)
    local data  = StaticData.Task[taskID]
    local npcTable = self:splitStrForTaskId(data.NpcId)
    return npcTable[1].npcid
end


-- 转移到战斗控制器哪里去了
---- 传人NPC ID 获取需要打斗的是飞宝和等级，和神将，和记录是否战斗是任务的ID
--function ManagerTask:GetFightData(taskID)
--    local npcId = ManagerTask:GetTaskNpcID(taskID)
--    local npcData = StaticData.Npc[npcId] --获取NPC数据
--    UserData.BaseInfo.enemyFlyID = tonumber(npcData.FlyID) -- 获取飞宝ID
--    local level = npcData.NeedLevel --获取神将，飞宝等级
--    local temp = stringEx:split(npcData.GodID,"|") -- 解析字符串
--    UserData.BaseInfo.enemyGodTable = {} --置空
--    for i = 1, #temp do
--    	local itemTabel = {}
--        itemTabel[1] = tonumber(temp[i])
--        itemTabel[2] =  level
--        UserData.BaseInfo.enemyGodTable[i] = itemTabel
--    end
--    
--    UserData.BaseInfo.myFightTaskId = tonumber(taskID) -- 记录战斗是任务的
--    
--end

-- 判断当前是否有任务的战斗
function ManagerTask:setTaskUpdate()
    if  UserData.BaseInfo.myFightTaskId == 0 then
        print("当前战斗不是任务的，ManagerTask:setTaskFinish打印")
	    return
	end
	local isCorrect = false
    for key, var in pairs(UserData.Task.acceptedTaskList) do
        if tonumber(var[1]) == UserData.BaseInfo.myFightTaskId then
			isCorrect = true
			break
		end
	end
	if isCorrect == false then
		print("任务ID没有在当前任务找到")
		return
	end
    local taskData = StaticData.Task[UserData.BaseInfo.myFightTaskId] 	
    UserData.Task:sendUpdateTask(UserData.BaseInfo.myFightTaskId,taskData.TaskType) --请求更新任务状态
    UserData.BaseInfo.myFightTaskId = 0 -- 置空
end

--对话过程中，点击跳过对话按钮，切换任务状态
function ManagerTask:changeTaskStateWhileSkipPlot(taskID)
    local taskType = self:getTaskType(taskID)
    local taskStaticInfo = StaticData.Task[taskID]
    if taskStaticInfo.TaskTargetType == 2 then -- 对话任务
        UserData.Task:sendUpdateTask(taskID,taskType) --请求更新任务状态
    elseif taskStaticInfo.TaskTargetType == 1 then --杀怪任务
        local taskUserInfo = UserData.Task.acceptedTaskList[taskType]
        if tonumber(taskUserInfo[4]) > 0  then
            if tonumber(taskUserInfo[5]) > 0 then
                self:setTaskState(taskID,3)
            else
                self:setTaskState(taskID,2)
            end

        end
    end
end

function ManagerTask:StartTaskImmediately(taskID)
    taskID = tonumber(taskID)
    local taskTownID = StaticData.Task[taskID].TownID -- 当前任务所在的城镇ID
    if taskTownID > 0 then
        if StaticData.TownMap[tostring(taskTownID)] ~= nil then
            local isMainTown = StaticData.TownMap[tostring(taskTownID)].TownType == 0  --当前任务是在主城镇，则表示是城镇里的任务，不是主城镇则表示在地图上
            local worldMapID = StaticData.TownMap[tostring(taskTownID)].WorldMapId
            local curStayMapID = UserData.Map:getRoleStayWorldMapID()   -- and StaticData.Task[taskID].TaskTargetType == 1
            if (curStayMapID ~= worldMapID) or 
                (isMainTown == false  and taskTownID > 1000 and curStayMapID == worldMapID and StaticData.Task[taskID].TaskTargetType == 1)  then  --非城镇任务需先移动过去,对话任务不移动直接执行
            	
                local StageMapLayer =  require("app.views.StageMap.StageMapLayer")
                local layer = StageMapLayer:create(worldMapID)
                local SceneManager = require("app.views.SceneManager")
                SceneManager:addToGameScene(layer)
                ManagerTask.currentMoveToNpcTaskID = taskID
                StageMapLayer:moveToTaskDestination(taskID)
                
            	return
            end
        end
        
        self:StartTaskImmediatelyWithoutMove(taskID)
    end
end


function ManagerTask:StartTaskImmediatelyWithoutMove(taskID)
    local taskTownID = StaticData.Task[taskID].TownID -- 当前任务所在的城镇ID
    if taskTownID > 0 then
     --城镇中的任务立即执行
        ManagerTask.startImmediatelyTaskID = taskID
            
        local preTalk = StaticData.Task[taskID].PreTalk
        local lastTalk = StaticData.Task[taskID].LastTalk
        local taskType = ManagerTask:getTaskType(taskID)
        local taskInfo = UserData.Task.acceptedTaskList[taskType]
            
        local needShowPlot = false
        if taskInfo[1] ~= "nil" then
            if tonumber(taskInfo[2]) == 2 then --对话任务必定显示
                needShowPlot = true
           else
                if tonumber(taskInfo[5]) == 0 and preTalk > 0 then  -- 杀怪任务，有preTalk，且已杀怪数量为0时，也显示
                    needShowPlot = true
                end
            end
    
        end
        local PlotLayer = require("app.views.Plot.PlotLayer")
        if preTalk > 0 or lastTalk > 0 then
            PlotLayer:initPlotEnterAntExit(taskID)
        end
        if preTalk > 0 and needShowPlot then
            ManagerTask.SectionId = preTalk
            local layer = PlotLayer:create()
            local SceneManager = require("app.views.SceneManager")
            SceneManager:addToGameScene(layer, 50)
        else
            --直接弹进入战斗界面
            self:EnterBeforeFightScene(taskID)
        end
    end
end

function ManagerTask:isTaskCanAccept(taskID,isFinishedPreTask)
    if isFinishedPreTask == true then
        local taskInfo = StaticData.Task[taskID]
        local taskType = taskInfo.TaskType
        local needLevel = taskInfo.Level 
        local curRoleLevel = UserData.BaseInfo.userLevel
        
        if needLevel<= curRoleLevel then
            return true
        end
    end
    return false
end

function ManagerTask:EnterBeforeFightScene(currentTaskId)
    local taskInfo = StaticData.Task[currentTaskId]
    if taskInfo == nil then
        return
    end
    local npcId = ManagerTask:GetTaskNpcID(currentTaskId)
    local npcInfo = StaticData.Npc[tonumber(npcId)]
    if npcInfo == nil then
        return
    end
    if npcInfo.Desc == "" or npcInfo.Desc == nil then
        
       
        local needCostAction = StaticData.Npc[npcId].TiLi -- 需要的体力
        if needCostAction > UserData.BaseInfo.nAction then
            local publicTipLayer = require("app/views/public/publicTipLayer")
        	 publicTipLayer:setTextAction("体力不足")
        else
            UserData.BaseInfo:setCostAction(needCostAction) --请求体力消耗	
            
            local MyFightingCtrl = require("app.views.MyFighting.MyFightingCtrl")  
            MyFightingCtrl:getFightingFibbleGodData(npcId)
            UserData.BaseInfo.myFightTaskId = tonumber(currentTaskId) -- 记录战斗是任务的

            local SceneManager = require("app.views.SceneManager")
            SceneManager:switch(SceneManager.SceneName.SCENE_MYFIGHTLAYER, 100)
             	  
        end
        
        return
    end

    local TaskMessageBox = require("app.views.Task.TaskMessageBox")
    local layer = TaskMessageBox:create()
    local SceneManager = require("app.views.SceneManager")
    SceneManager:addToGameScene(layer, 40)
    TaskMessageBox:ShowTaskBeginMessageBox(currentTaskId)

end

function ManagerTask:isTaskHaveComplete(taskID)
    local isTaskFinish = false
    if taskID == 0 then
        isTaskFinish = true
    else
        local taskType = self:getTaskType(taskID) 
        if taskType == 1 then
            local curMainTaskID = tonumber(UserData.Task.acceptedTaskList[1][1])
            if curMainTaskID == nil then
                if tonumber(UserData.Task.recentlyTaskId) > taskID then
                    isTaskFinish = true
                end
            else
                if curMainTaskID > taskID then
                    isTaskFinish = true
                end
            end
        elseif taskType == 2 then
            if self:CheckBranchTaskComplete(taskID) then
                isTaskFinish = true
            end
        elseif taskType == 5 then
            if UserData.Task.finishExploreTaskList[taskID] ~= nil then
                isTaskFinish = true
            end
        end
    end
    return isTaskFinish
end

function ManagerTask:CheckBranchTaskComplete(taskID)
    local taskType = self:getTaskType(taskID)
    if taskType ~= 2 then
        return false  
    end
    local branchType = StaticData.Task[taskID].BranchType
    if branchType == 0 then  --非支线
        return false  
    end

    if UserData.Task.finishBranchTaskList[taskID] ~= nil then
        return true
    end
    
    --不在完成任务列表，则查找以其为前置的任务是否在完成任务列表，仍然不在，继续遍历，直到此支线列表全部遍历
    local isCurTaskFinished = false
    local branchTaskList = self:getBranchTaskList(branchType)
    local curTask = taskID
    local num = table.nums(branchTaskList)
    local i=1
    while i <= num do
        local key = branchTaskList[i]
        if StaticData.Task[key].PreTaskID == curTask then
            if UserData.Task.finishBranchTaskList[key] ~= nil then
                isCurTaskFinished = true
                break
            else
                curTask = key
                i = 1
            end
        else
            i = i+1
        end
    end
    return isCurTaskFinished
end


function ManagerTask:getBranchTaskList(branchType)
    local taskList = {}
    for key,value in pairs(StaticData.Task) do
    	if value.BranchType == branchType then
--    	   local data = {taskID = key,preTask = value.PreTaskID}
--    	   taskList[key] = data
            taskList[#taskList+1] = key
    	end
    end
    return taskList
end

function ManagerTask:getTaskMapAndTown(taskID)
    local curTownID = ""
    local curWorldMap = 0
    if StaticData.Task[taskID] ~= nil then
	   curTownID = tostring(StaticData.Task[taskID].TownID)
	end
	if tonumber(curTownID) ~= nil then
	   curWorldMap = StaticData.TownMap[tostring(curTownID)].WorldMapId
	end
	return curTownID,curWorldMap
end

return ManagerTask