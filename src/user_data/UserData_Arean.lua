-- 竞技场系统

local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local Net         = require("net.Net")

local Arean = {
    opponentList = {},  -- 竞技场对手列表
    rankList = {},
}

-- 请求竞技场排行
function Arean:sendRequestAreanRankInfo()

    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_REQUEST_ARENA_RANK_INFO,"ui", baseInfo.userVeriCode, baseInfo.userID)
    
end

-- 请求竞技场记录
function Arean:sendRequestAreanRecord()

    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_REQUEST_ARENA_RECORD,"ui", baseInfo.userVeriCode, baseInfo.userID)
    
end

-- 请求竞争对手列表
function Arean:sendRequestAreanOpponent()

    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_REQUEST_ARENA_OPPONENT,"ui", baseInfo.userVeriCode, baseInfo.userID)

end

-- 请求对战
function Arean:sendRequestAreanRival(targetId)
    
    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_REQUEST_ARENA_RIVAL,"uii", baseInfo.userVeriCode, baseInfo.userID, targetId)

end

-- 请求自身竞技场信息
function Arean:sendRequestAreanInfo()

    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_REQUEST_ARENA_INFO,"ui", baseInfo.userVeriCode, baseInfo.userID)
    
end

-- 请求购买竞技场次数
function Arean:sendRequestAreanBuyCount()

    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_REQUEST_ARENA_BUY,"ui", baseInfo.userVeriCode, baseInfo.userID)

end

-- 竞技场排名
NetMsgFuncs.OnAreanRankList = function()
    
    local wsLuaFunc = Net.cppFunc
    local length = wsLuaFunc:readRecvByte()
    
    local rankList = { length = length }
    for i=1, length do
        local rank = wsLuaFunc:readRecvInt()
        local playerId = wsLuaFunc:readRecvInt()
        local name = wsLuaFunc:readRecvString()
        local level = wsLuaFunc:readRecvInt()
        local image = wsLuaFunc:readRecvInt()
        local fighting = wsLuaFunc:readRecvInt()
        rankList[i] = {
            rank = rank,
            playerId = playerId,
            name = name,
            level = level,
            image = image,
            fighting = fighting
        }
    end
    UserData.Arean.rankList = rankList
    
    EventMgr:dispatch(EventType.OnAreanRankList, rankList)
    
end

-- 竞技场对手列表      
NetMsgFuncs.OnAreanOpponentList = function()

    local wsLuaFunc = Net.cppFunc
    local length = wsLuaFunc:readRecvByte()
    
    local opponentList = {length = length}
    for i=1, length do
        local location = wsLuaFunc:readRecvByte()
        local rank = wsLuaFunc:readRecvInt()
        local playerId = wsLuaFunc:readRecvInt()
        local name = wsLuaFunc:readRecvString()
        local level = wsLuaFunc:readRecvInt()
        local image = wsLuaFunc:readRecvInt()
        local fighting = wsLuaFunc:readRecvInt()
        opponentList[i] = {
            location = location,
            rank = rank,
            playerId = playerId,
            name = name,
            level = level,
            image = image,
            fighting = fighting
        }
    end
    UserData.Arean.opponentList = opponentList
    
    EventMgr:dispatch(EventType.OnAreanOpponentList, opponentList) 
   
end   
          
-- 竞技场战斗结果          
NetMsgFuncs.OnAreanRivalBack = function()           

    local wsLuaFunc = Net.cppFunc
    local result = wsLuaFunc:readRecvByte()
    local rank = wsLuaFunc:readRecvInt()
    local playerInfo1 = wsLuaFunc:readRecvString()
    local playerInfo2 = wsLuaFunc:readRecvString()
    local course = wsLuaFunc:readRecvString()
     
    if result==1 then
        print("次数不足")
    elseif result==2 then
        print("对手不存在")
    end 
    
     
    local tmp = {
        result = result,
        rank = rank,
        playerInfo1 = playerInfo1,
        playerInfo2 = playerInfo2,
        course = course
    }
    
    EventMgr:dispatch(EventType.OnAreanRivalBack, tmp)

end
     
-- 竞技场个人信息
NetMsgFuncs.OnAreanSelfInfoBack = function()             

    local wsLuaFunc = Net.cppFunc
    local playerId = wsLuaFunc:readRecvInt()
    local name = wsLuaFunc:readRecvString()
    local rank = wsLuaFunc:readRecvInt()
    local level = wsLuaFunc:readRecvInt()
    local image = wsLuaFunc:readRecvByte()
    local fighting = wsLuaFunc:readRecvInt() 
    local times = wsLuaFunc:readRecvInt()

    local tmp = {
        playerId = playerId,
        name = name,
        rank = rank,
        level = level,
        image = image,
        fighting = fighting,
        times = times
    }
    print("剩余次数: " .. tostring(times))
    UserData.Arean.selfInfo = tmp
    EventMgr:dispatch(EventType.OnAreanSelfInfoBack, tmp)

end

NetMsgFuncs.OnAreanRecord = function()

    local wsLuaFunc = Net.cppFunc
    local length = wsLuaFunc:readRecvByte()
    
    local tmp = { length = length } 
    for i=1, length do
        local playerId = wsLuaFunc:readRecvInt()    -- 角色id
        local name = wsLuaFunc:readRecvString()     -- 对手名字
        local time = wsLuaFunc:readRecvString()     -- 时间
        local level = wsLuaFunc:readRecvInt()       -- 对手等级
        local result = wsLuaFunc:readRecvByte()     -- 结果
        local rank = wsLuaFunc:readRecvInt()        -- 排名
        tmp[i] = {
            playerId = playerId,
            name = name,
            time = time,
            level = level,
            result = result,
            rank = rank
        }
    end

    EventMgr:dispatch(EventType.OnAreanRecord, tmp)

end

NetMsgFuncs.OnAreanBuyBack = function()

    local wsLuaFunc = Net.cppFunc
    local result = wsLuaFunc:readRecvByte()
   
    EventMgr:dispatch(EventType.OnAreanBuyBack, {result=result})
         
end

return Arean