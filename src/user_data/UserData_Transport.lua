
local EventMgr                   = require("common.EventMgr")
local EventType                  = require("common.EventType")
-- 以下是网线接收处理函数区 
local netMsgId                   = require "net.NetMsgId"
local netMsgFunc                 = require "net.NetMsgFuncs"
local lNet                       = require "net.Net"
local TimeFormat                 = require("common.TimeFormat")

local Transport = {
    transportList                = {},
    mySelectCarIdx               = 1,                                        -- 默认选择是的第一个镖车
    myTransportResNum            = 0,                                        -- 当天剩余押镖次数
    myTransportMaxNum            = 2,                                        -- 设置一个最大的押镖次数 
    myNeedIngot                  = 10,                                       -- 需要元宝
    myTransportIconId            = 10001,                                    -- 押镖令的ID
    myTransportTime              = 300,                                       -- 总的运输时间
}

-- 客户端向服务端请求押镖列表
function Transport:sendServerTransportList()
    
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_TRANSPORT_LIST,"ui",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
end

-- 服务端向客户端返回押镖列表(包含玩家自身的信息）
netMsgFunc.OnTransportList = function()
    local wsLuaFunc              = lNet.cppFunc
    local nNum                   = wsLuaFunc:readRecvInt()                   -- 正在押镖的玩家数量     
   
    Transport.transportList      = {}
    for i = 1, nNum do
        local  itemTable         = {}
        itemTable.nPlayerId      = wsLuaFunc:readRecvInt()                   -- 玩家的ID
        itemTable.nPlayerName    = wsLuaFunc:readRecvString()                -- 玩家的名字
        itemTable.byType         = wsLuaFunc:readRecvByte()                  -- 镖车类型
        itemTable.sStartTime     = wsLuaFunc:readRecvString()                -- 玩家开始押镖的时间
        table.insert( Transport.transportList,itemTable)      
        cclog("nPlayerId=%d,nPlayerName=%s,itemTable.sStartTime=%s，itemTable.byType=%d",itemTable.nPlayerId,itemTable.nPlayerName,itemTable.sStartTime,itemTable.byType)
    end    

    local hsNum =  wsLuaFunc:readRecvByte()                                  -- 玩家当日的押镖次数(玩家自己)
    Transport.myTransportResNum  = Transport.myTransportMaxNum - hsNum       -- 剩余押镖次数         
    
    for key, var in pairs(Transport.transportList) do
        if var.nPlayerId == UserData.BaseInfo.userID then
            Transport.mySelectCarIdx = var.byType                            -- 获取当前的最大品质Id

            break
    	end
    end
    
    cclog("netMsgFunc.OnTransportList Transport.myTransportResNum=%d",Transport.myTransportResNum)
    EventMgr:dispatch(EventType.OnTransportList,0)                           -- 服务端向客户端返回押镖列表
   
end


-- 玩家请求刷新镖车类型
function Transport:sendServerRefreshType(nType)
    --刷新类型0:使用道具刷新,1:使用10元宝,2:直接刷新为高级镖车
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_REFRESH_TYPE,"uib",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nType)
end

-- 服务返回镖车刷新请求
netMsgFunc.OnRefreshType = function()
    local wsLuaFunc              = lNet.cppFunc
    local byRes                  = wsLuaFunc:readRecvByte()                  -- 0:成功,1:没有该道具,2:元宝不足，3：参数错误,4:镖车已经是最高级别
    local byType                 = wsLuaFunc:readRecvByte()                  -- 当前玩家的镖车类型
    local resTabel               = {}
    resTabel.byRes               = byRes
    resTabel.byType              = byType
    Transport.mySelectCarIdx     = byType
    cclog("请求刷新，品质是 byType=%d",byType)
    EventMgr:dispatch(EventType.OnRefreshType,resTabel)                      -- 服务返回镖车刷新请求
end


-- 玩家请求开始押镖
function Transport:sendServerStartTransport()
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_START_TRANSPORT,"ui",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
end

-- 服务返回开始押镖
netMsgFunc.OnStartTransport = function()
    local wsLuaFunc              = lNet.cppFunc
    local byRes                  = wsLuaFunc:readRecvByte()                  -- 0:成功,1:上次运镖为结束 2:次数不足
    local byNumber               = wsLuaFunc:readRecvByte()                  -- 玩家当日已用的押镖次数
    Transport.myTransportResNum  = Transport.myTransportMaxNum - byNumber    -- 求出剩余次数
    EventMgr:dispatch(EventType.OnStartTransport,byRes)                      -- 服务返回镖车刷新请求
   
    
    Transport:sendServerTransportList()                                      -- 请求下列表
    
end

-- 玩家请求结束押镖
function Transport:sendServerEndTransport()
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_END_TRANSPORT,"ui",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
end

-- 服务返回结束押镖请求
netMsgFunc.OnEndTransport = function()
    local wsLuaFunc              = lNet.cppFunc
    local byRes                  = wsLuaFunc:readRecvByte()                  -- 0:成功,1:未开始运镖，2：时间不足（成功读取以下值）、】
    
    if byRes == 0 then
        local nMoney                 = wsLuaFunc:readRecvInt()               -- 获取的游戏币数量
        local nExp                   = wsLuaFunc:readRecvInt()               -- 获取的经验
        UserData.BaseInfo.userGold   = UserData.BaseInfo.userGold + nMoney   -- 累计金钱
        UserData.BaseInfo.userExp    = UserData.BaseInfo.userExp + nExp      -- 累计经验
        
    end
   
    --时间结束了就变成0吧 重置品质吧
    for key, var in pairs(Transport.transportList) do
        if var.nPlayerId == UserData.BaseInfo.userID then
            Transport.transportList[key].sStartTime = "0000-00-00 00:00:00"
            Transport.transportList[key].byType     = 1
            Transport.mySelectCarIdx               = 1                      -- 获取当前的最大品质Id
            --重置啦
            break
        end
    end
    cclog("服务返回结束押镖请求 - -byRes=%d",byRes)
    EventMgr:dispatch(EventType.OnEndTransport,byRes) 
    Transport:sendServerTransportList()                                      -- 请求下列表     
end

--功能性函数
--寻找自己是否也在其中
function Transport:checkMyIsInTransport()
	local flg =  false
    
	for key, var in pairs(Transport.transportList) do
        if var.nPlayerId == UserData.BaseInfo.userID then
            local distEndTime = TimeFormat:getSecondsInter(var.sStartTime)   --相差的时间
            if var.sStartTime == "0000-00-00 00:00:00" or distEndTime > Transport.myTransportTime then                  -- 不在押镖
                flg =  false
            else                                                             -- 在押镖
                flg =  true	
            end
            cclog("checkMyIsInTransport() distEndTime=%f",distEndTime)
			break
		end
	end
	return flg
end



return Transport