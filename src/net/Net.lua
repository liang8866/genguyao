--[[
// lua 调用 C++
unsigned char readRecvByte();
short readRecvShort();
int readRecvInt();
unsigned int readRecvUint32();
double readRecvDouble();
std::string readRecvString();
bool writeSendByte(unsigned char byValue);
bool writeSendShort(short shtValue);
bool writeSendInt(int nValue);
bool writeSendUint32(unsigned int unValue);
bool writeSendDouble(double dblValue);
bool writeSendString(std::string strValue);
void beginSendBuf(unsigned int unMsgId);
void endSendBuf();
bool sendSvrBuf(std::string strFarAddr,unsigned int uPort);
]]--

local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")

local Net = {
    cppFunc = nil,
    serverAddr = "",                -- 远程服务器地址
    serverPort = 0,                 -- 远程服务器端口
    
}

function Net:init(strServerAddr,nServerPort)
    if self.cppFunc == nil then
        self.cppFunc = NetLuaFunc.NetLuaFunc:create()
        self.cppFunc:retain()
    end
    
    self.serverAddr = strServerAddr
    self.serverPort = nServerPort
end

--[[
    发送消息到服务端
    参数说明：
    msgId:消息的ID
    strCmd:可变参数列表的控制符：b:unsigned char,i:int,h:short,u:unsigned int,f:float,s:string
   ]]--
   

function Net:sendMsgToSvr(msgId,strCmd,...)
    local arg = {...}
    arg.n = select ("#",...)
        
    local nStrLen = string.len(strCmd)
    local nArgLen = arg.n
    if nStrLen ~= nArgLen then
        error("error:Net:sendMsgToSvr.args error",2)
        return   
    end
    
    -- 在此加上网络连接(转圈的动画)
    local MyMsgId = require("net.MyMsgId")
    
    if false == MyMsgId:getiIsNeedLoadFalsh(msgId) then--随机名字不出现
      
        local curScene = cc.Director:getInstance():getRunningScene()
        local Blayer = curScene:getChildByTag(20151010)
        if Blayer == nil then
            local publicBusyLayer = require("app.views.public.publicBusyLayer")
            local myBusyLayer = publicBusyLayer:create()
            myBusyLayer:setTag(20151010)
            EventMgr:registListener(EventType.deleteBusyLayer,Net, Net.deleteBusyLayer)
        end
        
        
    end
    
    self.cppFunc:beginSendBuf(msgId)
    for i = 1,nStrLen,1 do
        local sTemp = string.sub(strCmd,i,i)
        if sTemp == "b" then
            self.cppFunc:writeSendByte(arg[i])
        elseif sTemp == "i" then
            self.cppFunc:writeSendInt(arg[i])
        elseif sTemp == "h" then
            self.cppFunc:writeSendShort(arg[i])
        elseif sTemp == "u" then
            self.cppFunc:writeSendUint32(arg[i])
        elseif sTemp == "g" then
            self.cppFunc:writeSendDouble(arg[i])
        elseif sTemp == "s" then
            self.cppFunc:writeSendString(arg[i])
        end
    end
    self.cppFunc:endSendBuf()
    self.cppFunc:sendSvrBuf(self.serverAddr,self.serverPort,false)
end

function Net:sendMsgToSvrDirect(msgId,strCmd,...)
    local arg = {...}
    arg.n = select ("#",...)

    local nStrLen = string.len(strCmd)
    local nArgLen = arg.n
    if nStrLen ~= nArgLen then
        error("error:Net:sendMsgToSvr.args error",2)
        return   
    end

    self.cppFunc:beginSendBuf(msgId)
    for i = 1,nStrLen,1 do
        local sTemp = string.sub(strCmd,i,i)
        if sTemp == "b" then
            self.cppFunc:writeSendByte(arg[i])
        elseif sTemp == "i" then
            self.cppFunc:writeSendInt(arg[i])
        elseif sTemp == "h" then
            self.cppFunc:writeSendShort(arg[i])
        elseif sTemp == "u" then
            self.cppFunc:writeSendUint32(arg[i])
        elseif sTemp == "g" then
            self.cppFunc:writeSendDouble(arg[i])
        elseif sTemp == "s" then
            self.cppFunc:writeSendString(arg[i])
        end
    end
    self.cppFunc:endSendBuf()
    self.cppFunc:sendSvrBuf(self.serverAddr,self.serverPort,true)
end

function Net:deleteBusyLayer(event)

    local curScene = cc.Director:getInstance():getRunningScene()
    local Blayer = curScene:getChildByTag(20151010)
    local delay = cc.DelayTime:create(0.5)
    local function callback()
        if Blayer then
            curScene:removeChild(Blayer)
        end
    end
    if Blayer then
        Blayer:runAction(cc.Sequence:create(delay,cc.CallFunc:create(callback)))
    end
   
    
    
end

return Net
