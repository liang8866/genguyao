local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local Net         = require("net.Net")


local ShopVip = 
    {
        
    }

--买物品
NetMsgFuncs.OnBuyItem = function()
    local wsLuaFunc = Net.cppFunc
    local byRet = wsLuaFunc:readRecvByte()
    local nItemId = wsLuaFunc:readRecvInt()
    local nNumber = wsLuaFunc:readRecvInt() 
    
    EventMgr:dispatch(EventType.ReqBuyItem , byRet) 
end


--通知VIP经验发送变化
NetMsgFuncs.OnNoticeVipExpChange = function()
    local wsLuaFunc = Net.cppFunc
    UserData.BaseInfo.nVipExp = wsLuaFunc:readRecvInt()
    UserData.BaseInfo.userVip = wsLuaFunc:readRecvByte() 

    EventMgr:dispatch(EventType.ReqNoticeVipExpChange) 
end


--获取VIP礼包
NetMsgFuncs.OnGetVipBag = function()
    local wsLuaFunc = Net.cppFunc
    local byRet = wsLuaFunc:readRecvByte() 
    UserData.BaseInfo.nVipBag = wsLuaFunc:readRecvInt() 

    EventMgr:dispatch(EventType.ReqGetVipBag, byRet) 
end


return ShopVip

