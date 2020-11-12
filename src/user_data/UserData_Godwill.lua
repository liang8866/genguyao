

-- 神将系统
require "fight_static_data.FightStaticData"
local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local Net         = require("net.Net")
local GodwillManager = require("app.views.Godwill.GodwillManager")
local Godwill = {
    godList = {},       -- 神将列表总表(此表格不排序)
}

function Godwill:initAllGodList()
    UserData.Godwill.godList = {}
    
    for key,value in pairs(FightStaticData.godwill) do
        if value.activeNeedItem ~= nil and value.activeNeedItem ~= "" then
            UserData.Godwill.godList[key] = {
                id = key,      --神将id
                level = 0,     --神将等级
                star = 0,      --神将星级
                unlocked = 0,  --是否解锁
                fight = 0,     --神将战力值(战力=hp+atk*3+品质*100（暂定）)
                grade = value.grade,     --神将品质(静态数据)
                createNeedItems = GodwillManager:getGodCreateNeedItems(key),
                itemHaveNum = nil,  -- 当前拥有的神将合成物品的数量
                pos = 0, --神将被使用的位置
                fight = 0,
            }
            
             
        end
    end
end

function Godwill:RefreshGodwillData()

    Godwill:initCreateGodwillNeedItemsNum()
    --重新排序
    GodwillManager:updateGodwillListOrder()
end

--重新设置背包中已有的合成神将需要的材料的个数(需要在背包消息返回后处理)
function Godwill:initCreateGodwillNeedItemsNum()
    
    local ItemManager = require("app.views.ItemManager")
    for key ,value in pairs(UserData.Godwill.godList) do
        UserData.Godwill.godList[key].pos = 0
        local data = FightStaticData.godwill[key]
        --local goddetail = PlayerDetails:getGodDetatils(key)
        UserData.Godwill.godList[key].fight = data.hp + data.atk*3 + data.grade*100
        if value.unlocked == 0 then
            if UserData.Godwill.godList[key].createNeedItems.id ~= nil then  --还未解锁的才需要设置合成物品数据
                local itemID = UserData.Godwill.godList[key].createNeedItems.id
                UserData.Godwill.godList[key].itemHaveNum = ItemManager:getItemNum(itemID)
            end
        else
            local fibbleID = UserData.BaseInfo.nFibbleId
            local fibbleInfo = UserData.Fibble.fibbleTable[fibbleID][1]
            if key == fibbleInfo.nGodId1 then
                UserData.Godwill.godList[key].pos = 5
            end
            if key == fibbleInfo.nGodId2 then
                UserData.Godwill.godList[key].pos = 4
            end
            if key == fibbleInfo.nGodId3 then
                UserData.Godwill.godList[key].pos = 3
            end
            if key == fibbleInfo.nGodId4 then
                UserData.Godwill.godList[key].pos = 2
            end
            if key == fibbleInfo.nGodId5 then
                UserData.Godwill.godList[key].pos = 1
            end
        end
    end
    
end

-- 客户端请求神将列表信息
function Godwill:sendGetGodwillList()
    --先将所有神将列表置为未解锁状态
    Godwill:initAllGodList()
    
    local baseInfo = UserData.BaseInfo
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_GOD_INFO,"ui", baseInfo.userVeriCode, baseInfo.userID)
end

-- 服务端向客户端返回神将列表
NetMsgFuncs.OnGetGodInfo = function()

    local wsLuaFunc = Net.cppFunc
    local nLength = wsLuaFunc:readRecvInt()

    for i=1, nLength do
        local nGodID = wsLuaFunc:readRecvInt()     -- 神将ID
        local byStar = wsLuaFunc:readRecvByte()    -- 神将星级
        local nLevel = wsLuaFunc:readRecvInt()     -- 神将等级
        if UserData.Godwill.godList[nGodID] == nil then
            cclog("error , new godID that not in staticdata. nGodID = " .. tostring(nGodID))
            
            UserData.Godwill.godList[nGodID] = {nGodID = nGodID,}
        end
        UserData.Godwill.godList[nGodID].level = nLevel
        UserData.Godwill.godList[nGodID].star = byStar
        UserData.Godwill.godList[nGodID].unlocked = 1  -- 解锁标志更改
        local godwillStaticdata = FightStaticData.godwill[nGodID]
        UserData.Godwill.godList[nGodID].fight = (godwillStaticdata ~= nil) and (godwillStaticdata.hp + godwillStaticdata.atk*3 + godwillStaticdata.grade*100) or 0
    end
    
--    dump(UserData.Godwill.godList)

    UserData.BaseInfo.EnterGameMsgList[3].result = true 
end

-- 客户端请求合成神将;[[poi\oiuh
function Godwill:sendCreateGod(nGodID)
    -- 请求参数说明 验证码，角色ID,神将ID
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_CREATE_GOD,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nGodID)
end

--  服务端返回神将合成请求
NetMsgFuncs.OnCreateGod = function()
    local wsLuaFunc = Net.cppFunc
    local nGodID = wsLuaFunc:readRecvInt()    -- 神将ID
    local byRes = wsLuaFunc:readRecvByte()    -- 0:成功,1:神将ID错误 2:已经打造过,3:材料不足(成功客户端默认增加一个飞宝对象)
    if byRes == 0 then
        if UserData.Godwill.godList[nGodID] ~= nil then
            UserData.Godwill.godList[nGodID].level = 1
            UserData.Godwill.godList[nGodID].star = 0
            UserData.Godwill.godList[nGodID].unlocked = 1  -- 解锁标志更改
            local godwillStaticdata = FightStaticData.godwill[nGodID]
            UserData.Godwill.godList[nGodID].fight = godwillStaticdata.hp + godwillStaticdata.atk*3 + godwillStaticdata.grade*100
            
            --更新数据
            Godwill:RefreshGodwillData()
        end
    else
    
    end
    local returnData = {byRes = byRes,nGodID = nGodID}
    EventMgr:dispatch(EventType.OnCreateGod,returnData)     
end

-- 客户端请求提升神将等级请求
function Godwill:sendGodLevelUp(nGodID)
    -- 请求参数说明 验证码，角色ID,神将ID
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_GOD_UP,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nGodID)
end

-- 服务端返回神将升级请求
NetMsgFuncs.OnGodLevelUp = function()
    local wsLuaFunc = Net.cppFunc
    local nGodID = wsLuaFunc:readRecvInt()    -- 神将ID
    local nLevel = wsLuaFunc:readRecvInt()    -- 神将等级
    local byRes = wsLuaFunc:readRecvByte()    -- 0:成功,1:神将不存在,2:材料不足,3:神将等级上限，4:神将星级上限 5:金币不足
    
    if byRes == 0 then
        if UserData.Godwill.godList[nGodID] ~= nil then
            UserData.Godwill.godList[nGodID].level = nLevel
            local godwillStaticdata = FightStaticData.godwill[nGodID]
            UserData.Godwill.godList[nGodID].fight = godwillStaticdata.hp + godwillStaticdata.atk*3 + godwillStaticdata.grade*100
            --更新数据
            Godwill:RefreshGodwillData()
        end
    else

    end
    local returnData = {byRes = byRes,nGodID = nGodID,nLevel = nLevel}
    EventMgr:dispatch(EventType.OnGodLevelUp,returnData)  
end

-- 客户端请求提升神将星级请求
function Godwill:sendGodStarUp(nGodID)
    -- 请求参数说明 验证码，角色ID,神将ID
    Net:sendMsgToSvr(NetMsgId.CL_SERVER_GOD_STAR_UP,"uii",UserData.BaseInfo.userVeriCode,UserData.BaseInfo.userID,nGodID)
end

-- 服务端返回提升神将星级请求
NetMsgFuncs.OnGodStarUp = function()
    local wsLuaFunc = Net.cppFunc
    local nGodID = wsLuaFunc:readRecvInt()    -- 神将ID
    local byStar = wsLuaFunc:readRecvByte()   -- 神将星级
    local byRes = wsLuaFunc:readRecvByte()    -- 0:成功,1:神将ID错误,2:材料不足,3:星级上限,4:等级太低
    if byRes == 0 then
        if UserData.Godwill.godList[nGodID] ~= nil then
            UserData.Godwill.godList[nGodID].star = byStar
            local godwillStaticdata = FightStaticData.godwill[nGodID]
            UserData.Godwill.godList[nGodID].fight = godwillStaticdata.hp + godwillStaticdata.atk*3 + godwillStaticdata.grade*100
            --更新数据
            Godwill:RefreshGodwillData()
        end
    else

    end
    local returnData = {byRes = byRes,nGodID = nGodID,byStar = byStar}
    EventMgr:dispatch(EventType.OnGodStarUp,returnData) 
end

return Godwill