
local EventMgr                   = require("common.EventMgr")
local EventType                  = require("common.EventType")
-- 以下是网线接收处理函数区 
local netMsgId                   = require "net.NetMsgId"
local netMsgFunc                 = require "net.NetMsgFuncs"
local lNet                       = require "net.Net"

local Friend = {
    myFriendList                 = {},                                  -- 我的好友列表
    applyFriendList              = {},                                  -- 申请的好友列表
    commendFriendList            = {},                                  -- 推荐的好友
    blackFriendList              = {},                                  -- 黑名单列表
}

-- 客户端向服务端请求好友列表以及好友申请列表
function Friend:sendServerFriendList()
   -- lNet:sendMsgToSvr(netMsgId.CL_SERVER_FRIEND_LIST,"ui",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
end


-- 服务端向客户端返回好友列表以及好友申请列表
netMsgFunc.OnFriendList = function()
    local wsLuaFunc = lNet.cppFunc
    local nFriendNum = wsLuaFunc:readRecvInt()                          -- 好友列表的数量
    Friend.myFriendList = {}                                            -- 清空数据表
    cclog("nFriendNum =%d",nFriendNum)
    for i = 1, nFriendNum do
        local  itemTable = {}
        itemTable.nFriendId = wsLuaFunc:readRecvInt()                   -- 好友ID
        itemTable.sName = wsLuaFunc:readRecvString()                    -- 角色名
        itemTable.byJobId = wsLuaFunc:readRecvByte()                    -- 职业
        itemTable.bySex = wsLuaFunc:readRecvByte()                      -- 性别
        itemTable.nImageId = wsLuaFunc:readRecvInt()                    -- 头像ID
        itemTable.nLevel = wsLuaFunc:readRecvInt()                      -- 等级
        itemTable.nFight = wsLuaFunc:readRecvInt()                      -- 战斗力
        itemTable.sLastOffLineTime =  wsLuaFunc:readRecvString()        -- 0000-00-00 00:00:00 表示在线，其它值为离线时间
        itemTable.gave = wsLuaFunc:readRecvByte()                       -- 0可赠送体力 ， 1不可赠送体力
        itemTable.accept =  wsLuaFunc:readRecvByte()                    -- 0不可接收体力，1表示可以接收体力
        table.insert(Friend.myFriendList,itemTable)
    end
    local nApplyNum = wsLuaFunc:readRecvInt()                           -- 好友申请列表的数量
    Friend.applyFriendList = {}                                         -- 清空数据表
    cclog("nApplyNum = %d",nApplyNum)
    for i = 1, nApplyNum do
        local  itemTable = {}
        itemTable.nFriendId = wsLuaFunc:readRecvInt()                   -- 好友ID
        itemTable.sName = wsLuaFunc:readRecvString()                    -- 角色名
        itemTable.byJobId = wsLuaFunc:readRecvByte()                    -- 职业
        itemTable.bySex = wsLuaFunc:readRecvByte()                      -- 性别
        itemTable.nImageId = wsLuaFunc:readRecvInt()                    -- 头像ID
        itemTable.nLevel = wsLuaFunc:readRecvInt()                      -- 等级
        itemTable.nFight = wsLuaFunc:readRecvInt()                      -- 战斗力     
       
        table.insert(Friend.applyFriendList,itemTable)
    end 
     
end



-- 客户端向服务端请求推荐好友列表
function Friend:sendServerCommendList()
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_COMMEND_LIST,"ui",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
end

-- 服务端向客户端返回推荐好友列表
netMsgFunc.OnCommendList = function()
    local wsLuaFunc = lNet.cppFunc
    local nCommendNum = wsLuaFunc:readRecvInt()                         -- 推荐好友的数量
    cclog("nApplyNum = %d",nCommendNum)
    Friend.commendFriendList = {}
    for i = 1, nCommendNum do
        local  itemTable = {}
        itemTable.nFriendId = wsLuaFunc:readRecvInt()                   -- 好友ID
        itemTable.sName = wsLuaFunc:readRecvString()                    -- 角色名
        itemTable.byJobId = wsLuaFunc:readRecvByte()                    -- 职业
        itemTable.bySex = wsLuaFunc:readRecvByte()                      -- 性别
        itemTable.nImageId = wsLuaFunc:readRecvInt()                    -- 头像ID
        itemTable.nLevel = wsLuaFunc:readRecvInt()                      -- 等级
        itemTable.nFight = wsLuaFunc:readRecvInt()                      -- 战斗力     
        table.insert(Friend.commendFriendList,itemTable)
    end 
    EventMgr:dispatch(EventType.OnCommendList,0)                        -- 事件分发通知推荐好友列表
end

--客户端向服务端请求查询玩家信息
function Friend:sendServerInquiryPlayerInfo(sId)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_INQUIRY_PLAYER_INFO,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,tonumber(sId))
end


-- 服务端向客户端返回查询的玩家信息
netMsgFunc.OnInquiryPlayerInfo = function()
    local wsLuaFunc = lNet.cppFunc
    local byRes = wsLuaFunc:readRecvByte()                              -- 0成功,1:该ID不存在(不读取以下信息)
    local inquiryList = {}                                              -- 设置一个外部的table，方便以后修改，说不定呢
    if byRes == 0 then
        local itemTable = {}                                            -- 单个tabel
        itemTable.nFriendId = wsLuaFunc:readRecvInt()                   -- 好友ID
        itemTable.sName = wsLuaFunc:readRecvString()                    -- 角色名
        itemTable.byJobId = wsLuaFunc:readRecvByte()                    -- 职业
        itemTable.bySex = wsLuaFunc:readRecvByte()                      -- 性别
        itemTable.nImageId = wsLuaFunc:readRecvInt()                    -- 头像ID
        itemTable.nLevel = wsLuaFunc:readRecvInt()                      -- 等级
        itemTable.nFight = wsLuaFunc:readRecvInt()                      -- 战斗力    
        table.insert(inquiryList,itemTable)
    end
    local myData = {}
    myData.byRes = byRes
    myData.inquiryList = inquiryList
    EventMgr:dispatch(EventType.OnInquiryPlayerInfo,myData)             -- 事件分发
    
end

-- 客户端向服务端添加好友
function Friend:sendServerAddFriend(nTargetId)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_ADD_FRIEND,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,tonumber(nTargetId))
end

-- 服务器返回添加好友结果
netMsgFunc.OnAddFriend = function()
    local wsLuaFunc = lNet.cppFunc
    -- 0 成功，1对方已经在好友列表里,2目标ID错误,3自己已达好友数量上限，4对方已经达到好友上限 4添加自己为好友
    -- 5 对方已经在自己的好友申请列表中 6 已经提交过一次好友申请
    local byResult = wsLuaFunc:readRecvByte()                         
    EventMgr:dispatch(EventType.OnAddFriend,byResult)                  -- 事件分发
    print(byResult)
end

-- 服务器通知玩家，某玩家的申请好友的消息
netMsgFunc.OnNoticeAddFriend = function()
    local wsLuaFunc = lNet.cppFunc
    local itemTable = {}
    itemTable.nFriendId = wsLuaFunc:readRecvInt()                       -- 好友ID
    itemTable.sName = wsLuaFunc:readRecvString()                        -- 角色名
    itemTable.byJobId = wsLuaFunc:readRecvByte()                        -- 职业
    itemTable.bySex = wsLuaFunc:readRecvByte()                          -- 性别
    itemTable.nImageId = wsLuaFunc:readRecvInt()                        -- 头像ID
    itemTable.nLevel = wsLuaFunc:readRecvInt()                          -- 等级
    itemTable.nFight = wsLuaFunc:readRecvInt()                          -- 战斗力  
    table.insert(Friend.applyFriendList,itemTable)
    EventMgr:dispatch(EventType.OnNoticeAddFriend,itemTable)            -- 事件分发通知有好友申请       
    cclog("通知有好友申请 ")      
    dump(itemTable)      
    
end


-- 玩家回复好友申请
function Friend:sendServerReplyAddFriend(nTargetId,byResult)
    --  nTargetId 目标ID  byResult:byte  0拒绝，其他值为同意(默认为1)
    cclog("nTargetId=%d,byResult=%d",nTargetId,byResult)
    
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_REPLY_ADD_FRIEND,"uiib",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,tonumber(nTargetId),byResult)
end

-- 玩家好友申请拒绝回复   
netMsgFunc.OnRefuseAddFriend = function()
    local wsLuaFunc = lNet.cppFunc
    local nApplyId =  wsLuaFunc:readRecvInt()                           -- 申请者ID
    local nTargetId =  wsLuaFunc:readRecvInt()                          -- 目标ID
    local byResult = wsLuaFunc:readRecvByte()                           -- 0玩家拒绝  1玩家数据不符
    local myData = {}
    myData.byResult = byResult
--    cclog(" myData.byResult = %d", myData.byResult)
    --下面判断是把好友申请列表删除
    if byResult == 0 then
    	 for key, var in pairs(Friend.applyFriendList) do
--            print(nTargetId.."    "..var.nFriendId)
            if var.nFriendId == nApplyId then
                table.remove(Friend.applyFriendList,key)
--                dump(Friend.applyFriendListg)
             end
         end
    end
    EventMgr:dispatch(EventType.OnRefuseAddFriend,myData)            -- 事件分发通知有好友申请拒绝回复
    
end 

-- 把玩家添加到好友列表，
netMsgFunc.OnAgreeAddFriend = function()
    local wsLuaFunc = lNet.cppFunc
    local  itemTable = {}
    itemTable.nFriendId = wsLuaFunc:readRecvInt()                       -- 好友ID
    itemTable.sName = wsLuaFunc:readRecvString()                        -- 角色名
    itemTable.byJobId = wsLuaFunc:readRecvByte()                        -- 职业
    itemTable.bySex = wsLuaFunc:readRecvByte()                          -- 性别
    itemTable.nImageId = wsLuaFunc:readRecvInt()                        -- 头像ID
    itemTable.nLevel = wsLuaFunc:readRecvInt()                          -- 等级
    itemTable.nFight = wsLuaFunc:readRecvInt()                          -- 战斗力
    itemTable.sLastOffLineTime =  wsLuaFunc:readRecvString()            -- 0000-00-00 00:00:00 表示在线，其它值为离线时间
    itemTable.gave = wsLuaFunc:readRecvByte()                           -- 0可赠送体力 ， 1不可赠送体力
    itemTable.accept =  wsLuaFunc:readRecvByte()                        -- 0不可接收体力，1表示可以接收体力
    table.insert(Friend.myFriendList,itemTable)                         -- 插入好友列表中
    
    for key, var in pairs(Friend.applyFriendList) do
        if var.nFriendId == itemTable.nFriendId then
            table.remove(Friend.applyFriendList,key)
            dump(Friend.applyFriendList)
            break
        end
    end
    EventMgr:dispatch(EventType.OnAgreeAddFriend,itemTable)            -- 服务器通知玩家，把玩家添加到好友列表
end
 
-- 客户端向服务端请删除好友
function Friend:sendServerDeleteFriend(nTargetId)

    lNet:sendMsgToSvr(netMsgId.CL_SERVER_DEL_FRIEND,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,tonumber(nTargetId))
end
-- 服务器向客户端发送删除好友信息(发2次，发给对方)   
netMsgFunc.OnDeleteFriend = function()
    local wsLuaFunc = lNet.cppFunc
    local nApplyId =  wsLuaFunc:readRecvInt()                           -- 申请者ID
    local nTargetId =  wsLuaFunc:readRecvInt()                          -- 目标ID
    
end 
 
--玩家登陆或者离线，服务器主动发给自己的好友列表
netMsgFunc.OnUpdateFriendOnline = function()
    local wsLuaFunc = lNet.cppFunc
    local nApplyId =  wsLuaFunc:readRecvInt()                           -- 申请者ID
    local sLastOffLineTime =  wsLuaFunc:readRecvString()                -- 0000-00-00 00:00:00 表示在线，其它值为离线时间
    local myTable = {}
    for key, var in pairs(Friend.myFriendList) do
        local itemTable = var
        if itemTable.nFriendId == nApplyId then                         -- 说明是本身的好友
            itemTable.sLastOffLineTime = sLastOffLineTime
            Friend.myFriendList[key] = itemTable
            myTable = itemTable
   	    end
    end
    EventMgr:dispatch(EventType.OnUpdateFriendOnline,myTable)           -- 服务器通知玩家登陆或者离线
end  
 
-- 客户端向服务端请求给好友体力 
function Friend:sendServerGiveFriendAction(nTargetId)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_GIVE_FRIEND_ACTION,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,tonumber(nTargetId))
end

-- 服务端返回体力赠送结果
netMsgFunc.OnGiveFriendAction = function()
    local wsLuaFunc = lNet.cppFunc
    local nTargetId =  wsLuaFunc:readRecvInt()                           -- 需要给的好友ID
    local byResult = wsLuaFunc:readRecvByte()                            -- 0成功，其它失败(1表示今天已经给过该好友体力了)
    local myData = {}
    myData.byResult = byResult
    cclog("服务端返回体力赠送结果 byResult=%d  nTargetId=%d",byResult,nTargetId)
    if byResult == 0 then
        for key, var in pairs(Friend.myFriendList) do
            print(var.nFriendId)
            local itemTable = var
            if itemTable.nFriendId == nTargetId then                     -- 说明是本身的好友
                itemTable.gave = 1                                       -- 0可赠送体力 ， 1不可赠送体力
                Friend.myFriendList[key] = itemTable
                myData.itemTable = itemTable
                break
            end
        end
    end
    EventMgr:dispatch(EventType.OnGiveFriendAction,myData)               -- 服务端返回体力赠送结果   
end 


-- 收到好友赠送体力通知的消息
netMsgFunc.OnNoticeGetFriendAcion = function()
    local wsLuaFunc = lNet.cppFunc
    local nPlayerId =  wsLuaFunc:readRecvInt()                           -- 那个好友赠送体力给你的ID
    local myData = {}
    for key, var in pairs(Friend.myFriendList) do
        local itemTable = var
        if itemTable.nFriendId == nPlayerId then                         -- 说明是本身的好友
            itemTable.accept =  1                                        -- 0不可接收体力，1表示可以接收体力
            Friend.myFriendList[key] = itemTable
            myData = itemTable
            break
        end
    end
    
    EventMgr:dispatch(EventType.OnNoticeGetFriendAcion,myData)           -- 服务端返回体力赠送结果   
    
    
end 

-- 客户端向服务端接收好友赠送的体力 
function Friend:sendServerGetFriendAction(nFriendId)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_FRIEND_ACTION,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,tonumber(nFriendId))
end

-- 服务端向客户端发送接收好友赠送的体力结果
netMsgFunc.OnGetFriendAcion = function()
    local wsLuaFunc = lNet.cppFunc
    local myData = {}
    local nFriendId =  wsLuaFunc:readRecvInt()                           -- 好友ID
    local byResult = wsLuaFunc:readRecvByte()                            -- 0成功，其它失败（1表示今天收取的体力值已经达到上限,2好友没有赠送体力或者已经领取过）
    local nActionDay = wsLuaFunc:readRecvInt()                           -- 当天已经收取好友体力值
    myData.byResult = byResult
    
    if byResult == 0 then
        for key, var in pairs(Friend.myFriendList) do
            local itemTable = var
            if itemTable.nFriendId == nFriendId then                     -- 说明是本身的好友
                itemTable.accept =  0                                    -- 0不可接收体力，1表示可以接收体力
                Friend.myFriendList[key] = itemTable
                myData.itemTable = itemTable
                break 
            end
        end
    end
    
    EventMgr:dispatch(EventType.OnGetFriendAcion,myData)               -- 服务端向客户端发送接收好友赠送的体力结果
end 

-- 黑名单 
-- 客户端向服务端请求黑名单列表
function Friend:sendServerBlackList()
    --lNet:sendMsgToSvr(netMsgId.CL_SERVER_BLACKLIST,"ui",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
    
end

-- 服务端向客户端返回黑名单列表
netMsgFunc.OnBlackList = function()
    local wsLuaFunc             = lNet.cppFunc
    local nNum1                 = wsLuaFunc:readRecvInt()                -- 被自己拉黑的玩家数量(循环读取)
    Friend.blackFriendList      = {}                                     -- 清空数据表
    cclog("nNum1 =%d",nNum1)
    for i = 1, nNum1 do
        local  itemTable        = {}
        itemTable.nFriendId     = wsLuaFunc:readRecvInt()                -- 好友ID
        itemTable.sName         = wsLuaFunc:readRecvString()             -- 角色名
        itemTable.byJobId       = wsLuaFunc:readRecvByte()               -- 职业
        itemTable.bySex         = wsLuaFunc:readRecvByte()               -- 性别
        itemTable.nImageId      = wsLuaFunc:readRecvInt()                -- 头像ID
        itemTable.nLevel        = wsLuaFunc:readRecvInt()                -- 等级
        itemTable.nFight        = wsLuaFunc:readRecvInt()                -- 战斗力
       
        dump(itemTable)
        table.insert(Friend.blackFriendList,itemTable)
    end
    local nNum2                 = wsLuaFunc:readRecvInt()                -- 将自己拉黑的玩家数量(循环读取)
    cclog("nNum2 = %d",nNum2)
    for i = 1, nNum2 do
        local  itemTable        = {}
        itemTable.nFriendId     = wsLuaFunc:readRecvInt()                -- 好友ID
        itemTable.sName         = wsLuaFunc:readRecvString()             -- 角色名
        itemTable.byJobId       = wsLuaFunc:readRecvByte()               -- 职业
        itemTable.bySex         = wsLuaFunc:readRecvByte()               -- 性别
        itemTable.nImageId      = wsLuaFunc:readRecvInt()                -- 头像ID
        itemTable.nLevel        = wsLuaFunc:readRecvInt()                -- 等级
        itemTable.nFight        = wsLuaFunc:readRecvInt()                -- 战斗力
        table.insert(Friend.blackFriendList,itemTable)
    end 

end

-- 客户端向服务端请求将玩家拉入黑名单
function Friend:sendServerPullBlack(nBlackerId)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_PULL_BLACK,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nBlackerId)
end

-- 服务端向客户端返回玩家拉黑请求
netMsgFunc.OnPullBlack = function()
    local wsLuaFunc             = lNet.cppFunc
    local byRes                 = wsLuaFunc:readRecvByte()                -- 0:表示成功，1：失败,拉黑玩家ID不存在
    EventMgr:dispatch(EventType.OnPullBlack,byRes)                        -- 服务端向客户端返回黑名单列表
end    

--客户端向服务端请求与玩家解除黑名单关系
function Friend:sendServerNotPullBlack(nBlackerId)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_NOT_PULL_BLACK,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nBlackerId)
end

-- 服务端向客户端返回与玩家解除黑名单关系请求
netMsgFunc.OnNotPullBlack = function()
    local wsLuaFunc             = lNet.cppFunc
    local byRes                 = wsLuaFunc:readRecvByte()                -- 0:表示成功，其他值：失败
    EventMgr:dispatch(EventType.OnNotPullBlack,byRes)                     -- 服务端向客户端返回与玩家解除黑名单关系请求
end    

-- 服务端向客户端通知黑名单列表变化
netMsgFunc.OnNoticeBlackListChange = function()
    local wsLuaFunc             = lNet.cppFunc
    local byRes                 =  wsLuaFunc:readRecvByte()               -- 1: 增加一个自己拉黑的玩家ID,2:增加一个将自己拉黑的玩家ID，3:减少一个自己拉黑的玩家ID,4:减少一个将自己拉黑的玩家ID
    local itemTable             = {}
    itemTable.nFriendId         = wsLuaFunc:readRecvInt()                -- 好友ID
    itemTable.sName             = wsLuaFunc:readRecvString()             -- 角色名
    if byRes == 1 or byRes == 2 then
        itemTable.byJobId       = wsLuaFunc:readRecvByte()               -- 职业
        itemTable.bySex         = wsLuaFunc:readRecvByte()               -- 性别
        itemTable.nImageId      = wsLuaFunc:readRecvInt()                -- 头像ID
        itemTable.nLevel        = wsLuaFunc:readRecvInt()                -- 等级
        itemTable.nFight        = wsLuaFunc:readRecvInt()                -- 战斗力
        table.insert(Friend.blackFriendList,itemTable)
    end
    if byRes == 3 or byRes == 4 then
        for key, var in pairs(Friend.blackFriendList) do
            if var.nFriendId == itemTable.nFriendId then
                table.remove(Friend.blackFriendList,key)
    		end
    	end
    end
    EventMgr:dispatch(EventType.OnNoticeBlackListChange,byRes)           -- 服务端向客户端通知黑名单列表变化
    
    
end    

-- 功能性函数 

--传入ID检查是否是黑名单的
function Friend:searchIsBlackName(sId)
    for key, var in pairs(Friend.blackFriendList) do
        if var.nFriendId == sId then
            return true
        end
    end
    return false
end

-- 出入一个时间字符串，判断是否是在线
function Friend:judgeTimeIsOnLine(timeStr)
    if timeStr == "0000-00-00 00:00:00" then
		return true
	else
	    return false	
	end	
    
end


return Friend
