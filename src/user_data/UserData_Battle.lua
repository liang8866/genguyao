
local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local Net         = require("net.Net")


local Battle = 
{
    
}

-- 请求战斗
function Battle:requestBattle()
    
    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_REQUEST_FIGHT,"ui", baseInfo.userVeriCode, baseInfo.userID)
    
end

-- 请求副本战斗
-- sectionID  副本id
-- monsterLocation 怪物位置
-- course 战报
-- result 战斗结果
function Battle:requestPveBattle(sectionID, monsterLocation, course, result)
    
    local bret = 0
    if result=="lose" then
        bret = 1
    end

    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_REQUEST_COPY_BATTLE,"uiiisb", baseInfo.userVeriCode, baseInfo.userID, sectionID, monsterLocation, course, bret)
    
end

-- 服务端返回战斗信息
NetMsgFuncs.OnBattleInfo = function()

    local wsLuaFunc = Net.cppFunc
    local selfInfo = wsLuaFunc:readRecvString()
    local tarInfo  = wsLuaFunc:readRecvString()
    local course   = wsLuaFunc:readRecvString()
    
    local temp = {
        our = selfInfo,
        other = tarInfo,
        record = course
    }

    EventMgr:dispatch(EventType.OnBattleInfo, temp)

end

-- 副本战斗结果
NetMsgFuncs.OnPveBattleResult = function()
    
    local wsLuaFunc = Net.cppFunc
    local result = wsLuaFunc:readRecvByte()
    local star   = wsLuaFunc:readRecvByte()
    local itemList = wsLuaFunc:readRecvString()
    
    local tmp = {
        result = result,
        star = star,
        itemList = itemList
    }
        
    EventMgr:dispatch(EventType.OnPveBattleResult, tmp)   

end

-- 客户端打怪奖励
function Battle:sendOnFightPrize(enemyId)
    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_FIGHT_PRIZE,"uii", baseInfo.userVeriCode, baseInfo.userID, enemyId)
end

return Battle

