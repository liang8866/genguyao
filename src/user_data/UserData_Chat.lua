
local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local Net         = require("net.Net")


local Chat = 
    {
        worldChatTable = {},            --世界聊天数据保存
        privateChatTable = {},          --私聊数据保存
        chatMaxNum = 20,              --聊天保存最大条数
    }


--世界聊天
NetMsgFuncs.OnWorldChat = function()
    local wsLuaFunc = Net.cppFunc
    local byRet = wsLuaFunc:readRecvByte()
    EventMgr:dispatch(EventType.ReqWorldChatRet , byRet)
end


NetMsgFuncs.OnNoticeWorldChat = function()
    local wsLuaFunc = Net.cppFunc
    local worldtable = {}
    worldtable.nPlayerId = wsLuaFunc:readRecvInt()   
    
    local isPushBlack = UserData.Friend:searchIsBlackName(worldtable.nPlayerId)
    if isPushBlack == true then
        return
    end
    
    worldtable.sActorName = wsLuaFunc:readRecvString()
    worldtable.nLevel = wsLuaFunc:readRecvInt()   
    worldtable.nImage = wsLuaFunc:readRecvInt()
    worldtable.sChat = wsLuaFunc:readRecvString()
    worldtable.strTime = wsLuaFunc:readRecvString()
    worldtable.tipRedPoint = 0     --标记，0：这条消息未读，1：这条消息已读

    table.insert(Chat.worldChatTable ,worldtable) 
    if #Chat.worldChatTable > Chat.chatMaxNum then
        table.remove(Chat.worldChatTable,1) 
    end
    
    EventMgr:dispatch(EventType.ReqNoticeWorldChat)
end


--私聊
NetMsgFuncs.OnPrivateChat = function()
    local wsLuaFunc = Net.cppFunc
    local ret = wsLuaFunc:readRecvByte()
    if ret == 0 then
        local oneChatTable = {}
        oneChatTable.nPlayerId = wsLuaFunc:readRecvInt() 
        oneChatTable.sActorName = wsLuaFunc:readRecvString()
        oneChatTable.nLevel = wsLuaFunc:readRecvInt() 
        oneChatTable.nImage = wsLuaFunc:readRecvInt()   
        oneChatTable.sChat = wsLuaFunc:readRecvString()
        oneChatTable.strTime = wsLuaFunc:readRecvString()
        oneChatTable.tipRedPoint = 0

        table.insert(Chat.privateChatTable ,oneChatTable) 
        if #Chat.privateChatTable > Chat.chatMaxNum then
            table.remove(Chat.privateChatTable,1) 
        end
    end
    EventMgr:dispatch(EventType.ReqPrivateChatRet , ret)
end


return Chat

