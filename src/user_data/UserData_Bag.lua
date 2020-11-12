-- 背包系统

local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local Net         = require("net.Net")

local Bag = {
    items = {},
}

-- 客户端请求背包信息
function Bag:sendBagItemList()
    
    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_BAG_INFO,"ui", baseInfo.userVeriCode, baseInfo.userID)
    
end

-- 服务端向客户端返回背包列表
NetMsgFuncs.OnBagItemList = function()
    
    local wsLuaFunc = Net.cppFunc
    local nLength = wsLuaFunc:readRecvInt()
    
    local temp = {}
    for i=1, nLength do
        local nItemID = wsLuaFunc:readRecvInt()
        temp[nItemID] = wsLuaFunc:readRecvInt()
    end
    
    UserData.Bag.items = temp

    EventMgr:dispatch(EventType.OnBagItemList)
    
    if UserData.BaseInfo.EnterGameMsgList ~= nil and UserData.BaseInfo.EnterGameMsgList[2] ~= nil then
        UserData.BaseInfo.EnterGameMsgList[2].result = true  
    end
end

-- 服务端通知玩家物品数量发生改变 
NetMsgFuncs.OnBagItemChange = function()
    
    local wsLuaFunc = Net.cppFunc
    local nItemID = wsLuaFunc:readRecvInt()
    local nNum = wsLuaFunc:readRecvInt()
    if UserData.Bag.items == nil then
        UserData.Bag.items = {}
    end
    Bag.items[nItemID] = nNum
    
    print(nItemID .. " is " .. nNum)
       
    EventMgr:dispatch(EventType.OnBagItemChange)
    EventMgr:dispatch(EventType.OnFlyPrompt)
    
end

-- 查找物品表是否有此物品，返回0表示没有此物品，其他数量表示有多少个
function Bag:searchObjectOnBag(myId)
    local nNum = 0
    if  UserData.Bag.items[myId] ~= nil then
        nNum = Bag.items[myId].nNum
   end
   return nNum
end


return Bag