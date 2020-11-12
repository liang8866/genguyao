--邮件UI刷新需要重新切换到邮件列表才刷新

local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local Net         = require("net.Net")


local Mail = 
    {
        mailList = {}          --邮件列表
    }


--服务端向客户端返回邮件列表
NetMsgFuncs.OnMailList = function()
    local wsLuaFunc = Net.cppFunc
    local nEmailNum = wsLuaFunc:readRecvInt()
    for var=1, nEmailNum do
        local temp = {}
        temp.nEmailId = wsLuaFunc:readRecvInt()
        temp.nImageId = wsLuaFunc:readRecvInt()
        temp.sSubject = wsLuaFunc:readRecvString()
        temp.sContent = wsLuaFunc:readRecvString()
        temp.nAttachItemId1 = wsLuaFunc:readRecvInt()
        temp.nAttachItemNum1 = wsLuaFunc:readRecvInt()
        temp.nAttachItemId2 = wsLuaFunc:readRecvInt()
        temp.nAttachItemNum2 = wsLuaFunc:readRecvInt()
        temp.nAttachItemId3 = wsLuaFunc:readRecvInt()
        temp.nAttachItemNum3 = wsLuaFunc:readRecvInt()
        temp.nAttachItemId4 = wsLuaFunc:readRecvInt()
        temp.nAttachItemNum4 = wsLuaFunc:readRecvInt()
        temp.sSendTime = wsLuaFunc:readRecvString()
        temp.byIsRead = wsLuaFunc:readRecvByte()
        temp.byAttachIsPick = wsLuaFunc:readRecvByte()
        table.insert(Mail.mailList,temp) 
    end
end


-- 服务端向客户端返回邮件读取请求
NetMsgFuncs.OnReadMail = function()
    local wsLuaFunc = Net.cppFunc
    local bResult = wsLuaFunc:readRecvByte()  
    if bResult == 0 then
        for key, var in ipairs(Mail.mailList) do
            var.byIsRead = 1
        end
    end
    EventMgr:dispatch(EventType.ReqReadMail , bResult) 
end


-- 服务端向客户端返回提取邮件附件
NetMsgFuncs.OnPickAttack = function()
    local wsLuaFunc = Net.cppFunc
    local nEmailId = wsLuaFunc:readRecvInt()  
    local bySuccess = wsLuaFunc:readRecvByte()  
    if bySuccess == 0 then
        for key, var in ipairs(Mail.mailList) do
            if var.nEmailId == nEmailId then
                var.nAttachItemId1 = 0
                var.nAttachItemNum1 = 0
                var.nAttachItemId2 = 0
                var.nAttachItemNum2 = 0
                var.nAttachItemId3 = 0
                var.nAttachItemNum3 = 0
                var.nAttachItemId4 = 0
                var.nAttachItemNum4 = 0
                var.byAttachIsPick = 1
                break
            end
        end
    end
    EventMgr:dispatch(EventType.ReqPickMail , bySuccess)  
end


-- 服务端向客户端返回删除邮件
NetMsgFuncs.OnDelMail = function()
    local wsLuaFunc = Net.cppFunc
    local nEmailId = wsLuaFunc:readRecvInt()  
    local bySuccess = wsLuaFunc:readRecvByte()  
    if bySuccess == 0 then
        for key, var in ipairs(Mail.mailList) do
            if var.nEmailId == nEmailId then
                table.remove(Mail.mailList,key) 
                break
            end
        end
    end
    EventMgr:dispatch(EventType.ReqDelMail, bySuccess)  
end


-- 服务端通知客户端多了一封邮件
NetMsgFuncs.OnNoticeAddMail = function()
    local wsLuaFunc = Net.cppFunc
    local temp = {}
    temp.nEmailId = wsLuaFunc:readRecvInt()
    temp.nImageId = wsLuaFunc:readRecvInt()
    temp.sSubject = wsLuaFunc:readRecvString()
    temp.sContent = wsLuaFunc:readRecvString()
    temp.nAttachItemId1 = wsLuaFunc:readRecvInt()
    temp.nAttachItemNum1 = wsLuaFunc:readRecvInt()
    temp.nAttachItemId2 = wsLuaFunc:readRecvInt()
    temp.nAttachItemNum2 = wsLuaFunc:readRecvInt()
    temp.nAttachItemId3 = wsLuaFunc:readRecvInt()
    temp.nAttachItemNum3 = wsLuaFunc:readRecvInt()
    temp.nAttachItemId4 = wsLuaFunc:readRecvInt()
    temp.nAttachItemNum4 = wsLuaFunc:readRecvInt()
    temp.sSendTime = wsLuaFunc:readRecvString()
    temp.byIsRead = wsLuaFunc:readRecvByte()
    temp.byAttachIsPick = wsLuaFunc:readRecvByte()
    table.insert(Mail.mailList,temp)    
    
    EventMgr:dispatch(EventType.ReqNoticeAddMail)
end


-- 服务端通知客户端删除了一封邮件
NetMsgFuncs.OnNoticeDelMail = function()
    local wsLuaFunc = Net.cppFunc
    local nEmailId = wsLuaFunc:readRecvInt()
    for key, var in ipairs(Mail.mailList) do
        if var.nEmailId == nEmailId then
            table.remove(Mail.mailList,key) 
            break
        end
    end
end


return Mail