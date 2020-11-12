
local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local netMsgId = require "net.NetMsgId"
local netMsgFunc = require "net.NetMsgFuncs"
local lNet = require "net.Net"

local Fibble = {
    fibbleTable = {},
    skillTable = {}, --技能列表
    skillOrderList = {},--技能排序列表
}

-- 发送请求飞宝信息
function Fibble:sendGetFibbleInfo()  
    print("请求飞宝信息")
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_FIBBLE_INFO,"ui",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
end

-- 服务端返回飞宝信息
netMsgFunc.OnGetFibbleInfo = function()
    local wsLuaFunc          = lNet.cppFunc
    local nNum               = wsLuaFunc:readRecvInt()      -- 飞宝数量
    for i =1, nNum do
        local t =  {}
        local t1 = {}
        local nFibbleId   = wsLuaFunc:readRecvInt()   
        t1.nFibbleId      = nFibbleId 
        t1.byStar         = wsLuaFunc:readRecvByte() 
        t1.nSkillId1      = wsLuaFunc:readRecvInt()
        t1.nSkillId2      = wsLuaFunc:readRecvInt()
        t1.nSkillId3      = wsLuaFunc:readRecvInt()
        t1.nSkillId4      = wsLuaFunc:readRecvInt()
        t1.nGodId1        = wsLuaFunc:readRecvInt()
        t1.nGodId2        = wsLuaFunc:readRecvInt()
        t1.nGodId3        = wsLuaFunc:readRecvInt()
        t1.nGodId4        = wsLuaFunc:readRecvInt()
        t1.nGodId5        = wsLuaFunc:readRecvInt()
        t[1] = t1
        Fibble.fibbleTable[nFibbleId] = t
    end
    
    require("app.views.PromptSystem.FlyRefiningPrompt")
    FlyRefiningPrompt:initFibbleTable()
    
    -- 回调通知
    dump(Fibble.fibbleTable)
    EventMgr:dispatch(EventType.OnGetFibbleInfo) 
    
   
    UserData.BaseInfo.EnterGameMsgList[4].result = true 
end

-- 发送请求创造飞宝
function Fibble:sendCreateFibble(nFibbleId)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_CREATE_FIBBLE,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nFibbleId)
end

-- 服务端返回飞宝打造请求
netMsgFunc.OnCreateFibble = function()
    local wsLuaFunc          = lNet.cppFunc
    local nFibbleId          = wsLuaFunc:readRecvInt()
    local res                = wsLuaFunc:readRecvByte() -- 0:成功,1:飞宝ID错误 2:已经打造过,3:等级不足,4:材料不足(成功客户端默认增加一个飞宝对象)
    if res == 0 then
        local t =  {}
        local t1 = {}
        local fibbleData  = FightStaticData.flyingObject[nFibbleId]
        t1.nFibbleId      = nFibbleId 
        t1.byStar         = 1 
        t1.nSkillId1      = fibbleData.skillID1
        t1.nSkillId2      = fibbleData.skillID2
        t1.nSkillId3      = fibbleData.skillID3
        t1.nSkillId4      = fibbleData.skillID4
        t1.nGodId1        = 0
        t1.nGodId2        = 0
        t1.nGodId3        = 0
        t1.nGodId4        = 0
        t1.nGodId5        = 0
        
        t[1] = t1
        Fibble.fibbleTable[nFibbleId] = t
        Fibble:sendFibbleSkillInfo() --打造飞宝成功后重新获取飞宝技能列表
    end
    dump(Fibble.fibbleTable)
    -- 回调通知
    EventMgr:dispatch(EventType.OnCreateFibble,res)
       
end


-- 发送请求炼造飞宝请求
function Fibble:sendFibbleUp(nFibbleId)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_FIBBLE_UP,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nFibbleId)
end

-- 服务端返回炼造飞宝请求
netMsgFunc.OnFibbleUp = function()
    local wsLuaFunc          = lNet.cppFunc
    local nFibbleId          = wsLuaFunc:readRecvInt()
    local byStar             = wsLuaFunc:readRecvByte() 
    local res                = wsLuaFunc:readRecvByte()    -- 0:成功,1:飞宝不存在,2:材料不足,3:飞宝等级上限
    if res ==  0 then
        local t                          = Fibble.fibbleTable[nFibbleId]
        t[1].byStar                      = byStar
        Fibble.fibbleTable[nFibbleId]    = t 
    end
   
    -- 回调通知
    EventMgr:dispatch(EventType.OnFibbleUp,res)
    
end

-- 发送提升技能等级请求
function Fibble:sendSkillUp(nSkillId)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_SKILL_UP,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nSkillId)
end

-- 服务端返回提升技能等级请求
netMsgFunc.OnSkillUp = function()
    local wsLuaFunc          = lNet.cppFunc
    local nSkillId           = wsLuaFunc:readRecvInt() 
    local nSkillLevel        = wsLuaFunc:readRecvInt()
    local res                = wsLuaFunc:readRecvByte()  -- 0:成功,1:技能ID错误，2：技能等级上限,3:技能点不够 4:金币不足
    if res == 0 then
        Fibble.skillTable[nSkillId].level = nSkillLevel
        --重新排序 
        Fibble:sortSkill()
    end
    -- 回调通知
    local retData = {res = res,nSkillId = nSkillId,nSkillLevel = nSkillLevel}
    EventMgr:dispatch(EventType.OnSkillUp,retData)
end


-- 发送技能坑位请求
function Fibble:sendChangeSkillSite(nFibbleId,nSkillId1,nSkillId2,nSkillId3)
    print(nFibbleId,nSkillId1,nSkillId2,nSkillId3)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_CHANGE_SKILL_SITE,"uiiiii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nFibbleId,nSkillId1,nSkillId2,nSkillId3)
end

-- 服务端返回技能坑位请求
netMsgFunc.OnChangeSkillSite = function()
    local wsLuaFunc           = lNet.cppFunc
    local nFibbleId           = wsLuaFunc:readRecvInt()
    local nSkillId1           = wsLuaFunc:readRecvInt() 
    local nSkillId2           = wsLuaFunc:readRecvInt() 
    local nSkillId3           = wsLuaFunc:readRecvInt() 
    local res                 = wsLuaFunc:readRecvByte()  -- 0:成功,1:飞宝不存在，2.技能ID不存在
    print("-- 0:成功,1:飞宝不存在，2.技能ID不存在"..res)
    if res == 0 then
        local t               = Fibble.fibbleTable[nFibbleId]
        t[1].nSkillId1        = nSkillId1
        t[1].nSkillId2        = nSkillId2
        t[1].nSkillId3        = nSkillId3
        Fibble.fibbleTable[nFibbleId] = t  
      
    end
  
    -- 回调通知
    EventMgr:dispatch(EventType.OnChangeSkillSite,res)
end



-- 发送神将坑位请求
function Fibble:sendChangeGodSite(nFibbleId,nGodID1,nGodID2,nGodID3,nGodID4,nGodID5)
  
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_CHANGE_GOD_SITE,"uiiiiiii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nFibbleId,nGodID1,nGodID2,nGodID3,nGodID4,nGodID5)
end

-- 服务端返回神将坑位请求
netMsgFunc.OnChangeGodSite = function()
    local wsLuaFunc           = lNet.cppFunc
    local nFibbleId           = wsLuaFunc:readRecvInt()
    local nGodId1             = wsLuaFunc:readRecvInt()
    local nGodId2             = wsLuaFunc:readRecvInt()
    local nGodId3             = wsLuaFunc:readRecvInt()
    local nGodId4             = wsLuaFunc:readRecvInt()
    local nGodId5             = wsLuaFunc:readRecvInt()
    local res                 = wsLuaFunc:readRecvByte() -- 0:成功,1:飞宝ID不存在,2.神将ID不存在
   
    if res  ==  0  then
        local t               = Fibble.fibbleTable[nFibbleId]
        t[1].nGodId1        = nGodId1
        t[1].nGodId2        = nGodId2
        t[1].nGodId3        = nGodId3
        t[1].nGodId4        = nGodId4
        t[1].nGodId5        = nGodId5
        Fibble.fibbleTable[nFibbleId] = t  
    end
    -- 回调通知
    EventMgr:dispatch(EventType.OnChangeGodSite,res)
end

-- 客户端请求选择飞宝
function Fibble:sendSelectFibble(nFibbleId)
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_SELECT_FIBBLE,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nFibbleId)
end

-- 服务端返回选择飞宝
netMsgFunc.OnSelectFibble = function()
    local wsLuaFunc           = lNet.cppFunc
    local nFibbleId           = wsLuaFunc:readRecvInt()
    local res                 = wsLuaFunc:readRecvByte() -- 0:成功,1:飞宝ID不存在
    if res == 0 then
        UserData.BaseInfo.nFibbleId = nFibbleId
    end
    -- 回调通知
    EventMgr:dispatch(EventType.OnSelectFibble,res)
end

-- 客户端请求飞宝技能信息 
function Fibble:sendFibbleSkillInfo()
    
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_FIBBLE_SKILL_INFO,"ui",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
    
end

-- 服务端返回飞宝技能信息
netMsgFunc.OnGetFibbleSkillInfo = function()
    local wsLuaFunc           = lNet.cppFunc
    local nNum           = wsLuaFunc:readRecvInt()
    Fibble.skillTable = {}
    for i=1, nNum do
        local nSkillId = wsLuaFunc:readRecvInt()
        local nLevel   = wsLuaFunc:readRecvInt()
        Fibble.skillTable[nSkillId] = {}
        Fibble.skillTable[nSkillId].level = nLevel
        Fibble.skillTable[nSkillId].id = nSkillId
        
        local staticInfo = FightStaticData.flyingObjectSkill[nSkillId]
        Fibble.skillTable[nSkillId].grade = (staticInfo ~= nil) and staticInfo.grade or 0
        Fibble.skillTable[nSkillId].name = (staticInfo ~= nil) and staticInfo.name or ""
        Fibble.skillTable[nSkillId].fight = (staticInfo ~= nil) and (staticInfo.hp + staticInfo.atk*3 + staticInfo.grade*100) or 0
        
    end
    
    Fibble:sortSkill()
    
    UserData.BaseInfo.EnterGameMsgList[5].result = true 
end


function Fibble:sortSkill()
    UserData.Fibble.skillOrderList = {}
    for key,value in pairs(UserData.Fibble.skillTable) do
        local skillInfo = {}
        skillInfo.id = key
        skillInfo.grade = value.grade
        skillInfo.fight = value.fight
        table.insert(UserData.Fibble.skillOrderList,skillInfo)
    end

    local function comp(a,b)
        if a.grade > b.grade then
            return true
        else
            if a.fight > b.fight then
                return true
            end
        end
        return false
    end
    table.sort(UserData.Fibble.skillOrderList,comp)
    
end

function Fibble:getSkillInfo(skillID)
    return UserData.Fibble.skillTable[skillID]
end

-- 客户端请求购买技能点
function Fibble:sendBuyFibbleSkillPoint()
    lNet:sendMsgToSvr(netMsgId.CL_SERVER_BUY_SKILL_POINT,"ui",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID)
end


-- 服务端返回技能点购买请求
netMsgFunc.OnBuyFibbleSkillPoint = function()
    local wsLuaFunc = lNet.cppFunc
    local byRes = wsLuaFunc:readRecvByte() -- byRes:byte 0:成功,1:不符合购买条件 2:元宝不足
    if byRes == 0 then
        print("技能点购买成功")
    elseif byRes == 1 then
        print("不符合购买条件")
    elseif byRes == 2 then
        print("元宝不足")
    end
    EventMgr:dispatch(EventType.OnBuyFibbleSkillPoint, byRes)
    
end


return Fibble