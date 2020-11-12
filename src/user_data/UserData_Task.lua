
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local stringEx = require("common.stringEx")
-- 以下是网线接收处理函数区 
local netMsgId = require "net.NetMsgId"
local netMsgFunc = require "net.NetMsgFuncs"
local lNet = require "net.Net"
local SceneManager = require("app.views.SceneManager")

--[[
local TaskProcessState = {
    notbegin = 0, -- 任务还未接
    begin = 1, -- 任务刚接还未开始做
    enterTalkBeforeFight = 2, -- 开始对话(战斗前)
    enterFight = 3, --进入战斗
    enterTalkAfterFight = 4, -- 开始对话(战斗后)
    canfinish = 5, 任务完成可提交
}
]]

local Task = {
    firstMainTaskID             = 510001,
    recentlyTaskId              = 0,                                                    -- 最近完成的任务ID，如果是0，那就是没做过主线任务
    acceptedTaskList            = {},                                                   -- 已接任务列表
    nDayTaskNum                 = 0 ,                                                   -- 当日完成的日常任务次数
    finishBranchTaskList        = {},                                                   -- 已经完成的支线任务列表
    finishExploreTaskList       = {},                                                   -- 已经完成的探索任务列表
    acceptedTaskProcessState    = {},                                                   -- 保存当前已结任务的任务进度
    sExploreTaskTime            = "",                                                   -- 探索任务接取时间
    finishMainTasklist          = {},                                                   -- 已完成的主线任务列表
}

--请求任务信息列表
function Task:sendGetTaskInfo() 
    -- 请求参数说明 验证码，角色ID
    print(" 请求任务")
    cclog("UserData.BaseInfo.userVeriCode=%d,UserData.BaseInfo.userID=%d",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_TASK_INFO,"ui",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
end

-- 服务端返回任务信息
netMsgFunc.OnGetTaskInfo = function()
--   nParam1 含义
--    1:杀怪任务,怪物ID
--    2:对白任务,为0
--
--nParam2 含义
--    1:杀怪任务,所要杀的怪物总数量
--    2:对白任务,为0   
--    
--nParam3 含义         
--    1:杀怪任务,已经杀了怪物的数量
--    2:对白任务,为0
    local wsLuaFunc             = lNet.cppFunc
    Task.recentlyTaskId         = wsLuaFunc:readRecvInt()                               -- 最近完成的任务ID，如果是0，那就是没做过主线任务
    local sMainTask             = wsLuaFunc:readRecvString()                            -- 如果是空"nil",主线任务ID(任务ID-目标类型-参数1-参数2-参数3)
    local sBranchTask           = wsLuaFunc:readRecvString()                            -- 如果是空"nil",支线任务(任务ID-目标类型-参数1-参数2-参数3)
    local sDayTask              = wsLuaFunc:readRecvString()                            -- 如果是空"nil",日常任务(任务ID-目标类型-参数1-参数2-参数3)
    Task.nDayTaskNum            = wsLuaFunc:readRecvInt()                               -- 当日完成的日常任务次数
    local sRandTask             = wsLuaFunc:readRecvString()                            -- 如果是空"nil",随机任务 (任务ID-目标类型-参数1-参数2-参数3)
    Task.acceptedTaskList[1]    = stringEx:split(sMainTask,"-")                         -- 没有任务的话解析出来是个 "nil"字符,有任务的话解析出来是个table = {1=任务ID,2=目标类型,3=参数1,4=参数2,5=参数3}
    Task.acceptedTaskList[2]    = stringEx:split(sBranchTask,"-")                       -- 没有任务的话解析出来是个 "nil"字符,有任务的话解析出来是个table = {1=任务ID,2=目标类型,3=参数1,4=参数2,5=参数3}
    Task.acceptedTaskList[3]    = stringEx:split(sDayTask,"-")                          -- 没有任务的话解析出来是个 "nil"字符,有任务的话解析出来是个table = {1=任务ID,2=目标类型,3=参数1,4=参数2,5=参数3}
    Task.acceptedTaskList[4]    = stringEx:split(sRandTask,"-")                         -- 没有任务的话解析出来是个 "nil"字符,有任务的话解析出来是个table = {1=任务ID,2=目标类型,3=参数1,4=参数2,5=参数3}   
    local nLength               = wsLuaFunc:readRecvInt()                               -- 已经完成支线任务种类数,循环读取以下值  
    for i = 1, nLength do
        local nType             = wsLuaFunc:readRecvInt()                               -- 支线任务类型
        local nTaskId           = wsLuaFunc:readRecvInt()                               -- 支线任务ID
        Task.finishBranchTaskList[nTaskId] = nType
    end
    
    --探索任务
    local sExploreTask          = wsLuaFunc:readRecvString()
    Task.acceptedTaskList[5]    = stringEx:split(sExploreTask,"-")
    local length                = wsLuaFunc:readRecvInt()                               -- 已经完成探索任务种类数,循环读取以下值  
    for i = 1, length do
        local nType             = wsLuaFunc:readRecvInt()                               -- 探索任务类型
        local nTaskId           = wsLuaFunc:readRecvInt()                               -- 探索任务ID
        Task.finishExploreTaskList[nTaskId] = nType
    end
    Task.sExploreTaskTime       = wsLuaFunc:readRecvString()  -- 探索任务时间(接任务时间)
    
    for i=1,5 do
        if Task.acceptedTaskList[i][1] == "nil" then
            Task.acceptedTaskProcessState[i] = 0
        else
            Task.acceptedTaskProcessState[i] = 2  --准备进入战斗前对话的阶段
            if tonumber(Task.acceptedTaskList[i][2]) == 2 then --对话任务类型
                if tonumber(Task.acceptedTaskList[i][5]) > 0 then
                    Task.acceptedTaskProcessState[i] = 5 --任务完成可提交
                end
            else  -- 打怪任务类型
                if tonumber(Task.acceptedTaskList[i][5]) > 0 then
                    if tonumber(Task.acceptedTaskList[i][5]) == tonumber(Task.acceptedTaskList[i][4]) then
                        Task.acceptedTaskProcessState[i] = 4  --进入战斗后对话的阶段
                    else 
                        Task.acceptedTaskProcessState[i] = 3  --进入战斗的阶段
                    end
                end
            end
        end
    end

    UserData.BaseInfo.EnterGameMsgList[6].result = true
    --登陆的所有数据，发送和接收完毕，此处之后可以进行数据整合。
    

end

function Task:enterGame()
    --初始化城镇及地图开启数据
    UserData.Map:initAllStageOverInfo()
    
    UserData.Godwill:RefreshGodwillData()

    -- 首次进入游戏但没有接任务
    if Task.acceptedTaskList[1][1] == "nil" and  SceneManager.isFirstLoginInApp == false then
        local ManagerTask = require("app.views.Task.ManagerTask")
        local nextTaskId =  ManagerTask:getNextCanAcceptedMainTask()
        if nextTaskId > 0 then
            Task:sendAcceptTask(nextTaskId,1)
        end
    end

    --进入地图
    if SceneManager.isFirstLoginInApp then
        SceneManager:switch(SceneManager.SceneName.SCENE_STARTSCENE)
    else

        local mapID = UserData.Map:getRoleStayWorldMapID()
        local curRoleStayPointID = tonumber(UserData.Map:getRoleStayPointID())

        local needDirectToMap = true
        if curRoleStayPointID ~= nil and curRoleStayPointID > 1000 then --在大地图或城镇，1000以内为探索地图

            local worldID = StaticData.TownMap[tostring(curRoleStayPointID)].WorldMapId
            local isMainTown = StaticData.TownMap[tostring(curRoleStayPointID)].TownType == 0 -- 0:城镇 1:支点
            if isMainTown then
                needDirectToMap = false
                local TownInterfaceLayer =  require("app.views.StageMap.TownInterfaceLayer")
                local layer = TownInterfaceLayer:create()
                local SceneManager = require("app.views.SceneManager")
                SceneManager:addToGameScene(layer)
                local data = {needShowPlot = false,currentTownID = tostring(curRoleStayPointID)}
                layer:initUI(data)
                cc.Director:getInstance():replaceScene(cc.TransitionFade:create(0.5, SceneManager:getGameSceneRoot(), cc.c3b(255,255,255)))
                local curTaskID = tonumber(Task.acceptedTaskList[1][1])
                if curTaskID ~= nil and curTaskID == UserData.NewHandLead.GuideList.TownToMap.TaskID then
                    local guideState = UserData.NewHandLead:getGuideState("TownToMap")
                    if guideState == 0 then
                        local data = {name = "TownToMap"}
                        UserData.NewHandLead:startNewGuide(data)
                    end
                end
            end
        end
        if needDirectToMap then  
            local StageMapLayer =  require("app.views.StageMap.StageMapLayer")
            local layer = StageMapLayer:create(mapID)
            local SceneManager = require("app.views.SceneManager")
            SceneManager:addToGameScene(layer)
            cc.Director:getInstance():replaceScene(cc.TransitionFade:create(0.5, SceneManager:getGameSceneRoot(), cc.c3b(255,255,255)))

            local curTaskID = tonumber(Task.acceptedTaskList[1][1])
            if curTaskID ~= nil and curTaskID == UserData.NewHandLead.GuideList.ClickMapEnventPoint.TaskID then
                local guideState = UserData.NewHandLead:getGuideState("ClickMapEnventPoint")
                if guideState == 0 then
                    local data = {name = "ClickMapEnventPoint"}
                    UserData.NewHandLead:startNewGuide(data)
                    local curTownID = StaticData.Task[curTaskID].TownID
                    local townPos = string.split(StaticData.TownMap[tostring(curTownID)].TownPos,"*")
                    layer:ShowNewHand(cc.p(townPos[1]+50,townPos[2]))
                    
                end
            end
        end
    end
end


-- 客户端请求接任务
function Task:sendAcceptTask(nTaskId,byType)
    -- 请求参数说明 验证码，角色ID,任务ID,任务类型(1:主线，2:支线,3:日常任务,4:随机任务,5:探索任务) 
    --print("接任务"..nTaskId,byType)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_GET_TASK,"uiib",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nTaskId,byType)
end


-- 服务端通知任务增加
netMsgFunc.OnNoticeAddTask = function()
    local wsLuaFunc             = lNet.cppFunc
    local result                = wsLuaFunc:readRecvByte()                              -- 0:成功,1:类型错误,2:有任务未完成,3:任务ID不存在,4:不符合该任务要求,5：通知增加一个任务，6：日常任务数量达到今日上限
    print("添加任务服务器返回 result= ",result)
    
    if result ~= 0 and result ~= 5 then
        return
    end 
    
    local taskType          = wsLuaFunc:readRecvByte()                                 -- 任务类型(0：没有增添任务1:主线，2:支线,3:日常任务,4:随机任务,5:探索任务)
    local sTask             = wsLuaFunc:readRecvString()                               -- 任务信息  
    if taskType ~= 0 then
        Task.acceptedTaskList[taskType] = stringEx:split(sTask,"-")

        Task.acceptedTaskProcessState[taskType] = 2  --准备进入战斗前对话的阶段
    end
    cclog("添加任务服务器返回 sTask = %s ",sTask)
    if taskType == 5 then --探索任务
        Task.sExploreTaskTime       = wsLuaFunc:readRecvString()  -- 探索任务时间(接任务时间)
    end

    local currentTaskID = tonumber(Task.acceptedTaskList[taskType][1])
    EventMgr:dispatch(EventType.EventOnNoticeAddTask,currentTaskID)                            -- 其他页面需要的话 函数事件通知

    if currentTaskID > 0 and StaticData.Task[currentTaskID].ImmediateStart == 1 then
        ManagerTask:StartTaskImmediately(currentTaskID)
    end

    if currentTaskID == UserData.NewHandLead.GuideList.EnterToJiangDou.TaskID then
        local guideState = UserData.NewHandLead:getGuideState("EnterToJiangDou")
        if guideState == 0 then
            local data = {name = "EnterToJiangDou"}
            UserData.NewHandLead:startNewGuide(data)
        end
    end
        
     
end    

-- 客户端请求更新任务状态
function Task:sendUpdateTask(nTaskId,byType)
    -- 请求参数说明 验证码，角色ID,任务ID,任务类型(1:主线，2:支线,3:日常任务,4:随机任务,5:探索任务) 
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_UPDATE_TASK,"uiib",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nTaskId,byType)
end

-- 服务端通知任务状态发生改变
netMsgFunc.OnUpDateTask = function()
    local wsLuaFunc             = lNet.cppFunc
    local result                = wsLuaFunc:readRecvByte()                              -- 0:成功,1:类型错误,2:任务ID不存在，3：条件不符
    print("更新任务服务端返回 result= ",result)
    if result ~= 0 then
        return
    end 
    
    local taskType              = wsLuaFunc:readRecvByte()                              -- 任务类型
    local nPram3                = wsLuaFunc:readRecvInt()                               -- 参数三说明
    local temp                  = Task.acceptedTaskList[taskType]
    
    if temp ~= "nil" and temp[1] ~= "nil" then
        temp[5] = nPram3
        Task.acceptedTaskList[taskType] = temp
        
        if tonumber(Task.acceptedTaskList[taskType][2]) == 2 then --对话任务类型
            Task.acceptedTaskProcessState[taskType] = 5 --任务完成可提交
        else
            if tonumber(Task.acceptedTaskList[taskType][5]) > 0 then
                if tonumber(Task.acceptedTaskList[taskType][5]) == tonumber(Task.acceptedTaskList[taskType][4]) then
                    Task.acceptedTaskProcessState[taskType] = 4  --进入战斗后对话的阶段
                else 
                    Task.acceptedTaskProcessState[taskType] = 3  --进入战斗的阶段
                end
            end
        end
        

    end
    local taskId = tonumber(temp[1])
    EventMgr:dispatch(EventType.EventOnUpDateTask,taskId)                               -- 其他页面需要的话 函数事件通知
    
--    if (tonumber(temp[4]) > 0 and tonumber(temp[5]) == tonumber(temp[4])) then --  or tonumber(temp[2]) == 2
--        Task:sendFinishTask(taskId,taskType)                                                -- 请求任务完成
--    end
end    

-- 客户端请求完成任务
function Task:sendFinishTask(nTaskId,byType)
    -- 请求参数说明 验证码，角色ID,任务ID,任务类型(1:主线，2:支线,3:日常任务,4:随机任务,5:探索任务)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_FINISH_TASK,"uiib",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nTaskId,byType)
end

-- 服务端返回完成任务请求
netMsgFunc.OnFinishTask = function()
    local wsLuaFunc             = lNet.cppFunc
    local result                = wsLuaFunc:readRecvByte()                              -- 0:成功,1:类型错误,2:任务ID不存在，3：条件不符
    Task.nDayTaskNum            = wsLuaFunc:readRecvInt()                               -- 日常任务完成的次数
    local taskType              = wsLuaFunc:readRecvByte()                              -- 任务类型(1:主线，2:支线,3:日常任务,4:随机任务,5:探索任务) 
    
    local currentTaskID = tonumber(Task.acceptedTaskList[taskType][1])
    
    cclog("完成任务服务端返回 currentTaskID = %d,result=%d ",currentTaskID,result)
    
    if ManagerTask.startImmediatelyTaskID > 0 and ManagerTask.startImmediatelyTaskID == currentTaskID then
        ManagerTask.startImmediatelyTaskID = 0
    end
    if result ~= 0 then
        return
    end 
    
    if taskType == 1 then
        Task.finishMainTasklist[currentTaskID] = currentTaskID
    elseif taskType == 2 then   -- 当前完成的是支线任务
        Task.finishBranchTaskList[currentTaskID] = taskType
    elseif taskType == 5 then   -- 当前完成的是探索任务
        Task.finishExploreTaskList[currentTaskID] = taskType
    end
    
    
    Task.acceptedTaskList[taskType] = stringEx:split("nil","-")
    EventMgr:dispatch(EventType.EventOnFinishTask,currentTaskID)                                  -- 其他页面需要的话 函数事件通知
    Task.acceptedTaskProcessState[taskType] = 0  --未接任务状态

    if taskType == 1 then  -- 当前完成的是主线任务，自动接下一个任务
        Task.recentlyTaskId = currentTaskID
        local StageMapLayer = require("app.views.StageMap.StageMapLayer")
        StageMapLayer:updateTownOverState(currentTaskID)
        
        local ManagerTask = require("app.views.Task.ManagerTask")
        local nextMainTaskId = ManagerTask:getNextCanAcceptedMainTask()
        if nextMainTaskId > 0 and nextMainTaskId ~= currentTaskID then
            Task:sendAcceptTask(nextMainTaskId,1)  
            return
        end

        local nextTask = ManagerTask:getNextMainTaskId(currentTaskID)
        if nextTask > 0 then
            --local TaskTrackerUI = require("app.views.Task.TaskTrackerUI")
            --TaskTrackerUI:reCreateListItem(nextTask)
            EventMgr:dispatch(EventType.EventOnNoticeAddTask,nextTask) 
        end
    end
    
end    

-- 客户端请求放弃任务

function Task:sendAbandonTask(nTaskId,byType)
    -- 请求参数说明 验证码，角色ID,任务ID,任务类型(1:主线，2:支线,3:日常任务,4:随机任务,5:探索任务)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_ABANDON_TASK,"uiib",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nTaskId,byType)
end

-- 服务端返回放弃任务请求
netMsgFunc.OnAbandonTask = function()
    local wsLuaFunc             = lNet.cppFunc
    local result                = wsLuaFunc:readRecvByte()                              -- 0:成功,1:类型错误,2:任务ID不存在，3:通知放弃一个任务
    local taskType              = wsLuaFunc:readRecvByte()                              -- 任务类型(1:主线，2:支线,3:日常任务,4:随机任务,5:探索任务)
    print("任务放弃服务端返回 result= ",result)
    if result ~= 0 and result ~= 3 then
        return
    end 
    local currentTaskID = tonumber(Task.acceptedTaskList[taskType][1])
    Task.acceptedTaskList[taskType] = stringEx:split("nil","-")
    Task.acceptedTaskProcessState[taskType] = 0  --未接任务状态
    EventMgr:dispatch(EventType.EventOnAbandonTask,currentTaskID)                                 -- 其他页面需要的话 函数事件通知
end   

function Task:getCanAcceptTaskIDListInTown(currentTownID)
    local taskIDList = {}
    taskIDList[1] = {}
    taskIDList[2] = {}
    taskIDList[3] = {}
    taskIDList[4] = {}
    if StaticData.TownMap[currentTownID] == nil then 
        return taskIDList
    end
    local questIdListStr = StaticData.TownMap[currentTownID].QuestId
    local questIdList = string.split(questIdListStr,"-")
    for i = 1, #questIdList do
        local questID = tonumber(questIdList[i])
        if questID ~= nil then
            local taskType = StaticData.Task[questID].TaskType
            if taskIDList[taskType] == nil then
                taskIDList[taskType] = {}
            end
            
            if taskType == 3 or taskType == 4 then  --日常和循环在此处判断前置
                local preTaskID = StaticData.Task[questID].PreTaskID
                local isPreTaskFinish = ManagerTask:isTaskHaveComplete(preTaskID)
                local isCanAccept =  ManagerTask:isTaskCanAccept(questID,isPreTaskFinish)
                if isCanAccept then
                    taskIDList[taskType][table.nums(taskIDList[taskType])+1] = tonumber(questIdList[i])
                end
            else
                taskIDList[taskType][table.nums(taskIDList[taskType])+1] = tonumber(questIdList[i])
            end
        end
    end
    
    --主线
    local mainTaskId = 0
    if taskIDList[1] ~= nil then
        local curTaskID = tonumber(Task.acceptedTaskList[1][1])
        if curTaskID == nil then
            curTaskID = ManagerTask:getNextMainTaskId(Task.recentlyTaskId)
        end
        for i=1,table.nums(taskIDList[1]) do
            if taskIDList[1][i] ==  curTaskID then
                mainTaskId = taskIDList[1][i]
                break
            end
        end
    end
    
    --支线
    local canAcceptBranchTaskList = {}
    if table.nums(taskIDList[2]) > 0 then
        for i=1,table.nums(taskIDList[2]) do
            local questID = taskIDList[2][i]
            
            if Task.finishBranchTaskList[questID] == nil then --未完成过

                local preTaskID = tonumber(StaticData.Task[questID].PreTaskID)
                local isTaskFinish = ManagerTask:isTaskHaveComplete(questID)
                if isTaskFinish == false then
                    local isPreTaskFinish = ManagerTask:isTaskHaveComplete(preTaskID)
                    local isCanAccept =  ManagerTask:isTaskCanAccept(questID,isPreTaskFinish)
                    if isCanAccept then
                        canAcceptBranchTaskList[table.nums(canAcceptBranchTaskList) + 1] = questID
                    end
                end
            end
        end
    end
    
    --日常
    if UserData.Task.nDayTaskNum >= StaticData.SystemParam["DayTaskNum"].IntValue then
        taskIDList[3] = {}
    end
    
    local function sortByLevel(a,b)
        local taskInfoA = StaticData.Task[a]
        local taskInfoB = StaticData.Task[b]
        return  taskInfoA.Level < taskInfoB.Level 
    end
    if table.nums(canAcceptBranchTaskList) > 1 then
        table.sort(canAcceptBranchTaskList,sortByLevel)
    end
    if table.nums(taskIDList[3]) > 1 then
        table.sort(taskIDList[3],sortByLevel)
    end
    if table.nums(taskIDList[4]) > 1 then
        table.sort(taskIDList[4],sortByLevel)
    end
    return mainTaskId,canAcceptBranchTaskList,taskIDList[3],taskIDList[4]
end

return Task