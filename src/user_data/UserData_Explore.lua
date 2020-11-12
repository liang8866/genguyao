local EventMgr    = require("common.EventMgr")
local EventType   = require("common.EventType")
local NetMsgFuncs = require("net.NetMsgFuncs")
local NetMsgId    = require("net.NetMsgId")
local lNet         = require("net.Net")

ExploreEnum = {}
ExploreEnum.Box         = 1
ExploreEnum.Event       = 2
ExploreEnum.Tower       = 3
ExploreEnum.Tp          = 4
ExploreEnum.ChangeNPC   = 5
ExploreEnum.StorNPC     = 6
ExploreEnum.TaskNPC     = 7
ExploreEnum.BigBox      = 8
ExploreEnum.Crystal     = 9
ExploreEnum.Jewel       = 10
ExploreEnum.Refresh     = 11
ExploreEnum.Through     = 12
ExploreEnum.Time        = 13


local Explore = {
    map = {},           -- 探索地图
}

-- 发送请求探索信息
function Explore:sendGetExploreInfo()
    print("请求探索信息")
    lNet:sendMsgToSvr(NetMsgId.CL_SERVER_EXPLORE_INFO, "ui", UserData.BaseInfo.userVeriCode, UserData.BaseInfo.userID)
end

NetMsgFuncs.OnGetExploreInfo = function()
    local wsLuaFunc          = lNet.cppFunc
    local nLenth             = wsLuaFunc:readRecvInt()          -- 地图数量
    for i = 1, nLenth do
        local mapId              = wsLuaFunc:readRecvInt()      -- 地图ID
        id = mapId
        local map = {}
        map[ExploreEnum.Box]                    = wsLuaFunc:readRecvByte()          -- 1、当前关卡开的箱子个数
        map[ExploreEnum.Event]                  = wsLuaFunc:readRecvByte()          -- 2、当前关卡开的事件个数
       
        map[ExploreEnum.Tower]                  = wsLuaFunc:readRecvByte()          -- 3、当前关卡开的塔个数
        map[ExploreEnum.Tp]                     = wsLuaFunc:readRecvByte()          -- 4、当前传送个数
        map[ExploreEnum.ChangeNPC]              = wsLuaFunc:readRecvByte()          -- 5、当前关卡遇到商店NPC个数
        map[ExploreEnum.StorNPC]                = wsLuaFunc:readRecvByte()          -- 6、当前关卡遇交易NPC个数
        map[ExploreEnum.TaskNPC]                = wsLuaFunc:readRecvByte()          -- 7、当前关卡遇到任务NPC个数
        
        map[ExploreEnum.BigBox]                 = wsLuaFunc:readRecvByte()          -- 8、当前关卡剩余大箱子个数
        map[ExploreEnum.Crystal]                = wsLuaFunc:readRecvByte()          -- 9、当前关卡剩余水晶箱子个数
        map[ExploreEnum.Jewel]                  = wsLuaFunc:readRecvByte()          -- 10、当前关卡剩余钻石箱子个数
        
        map[ExploreEnum.Refresh]                = wsLuaFunc:readRecvInt()           -- 11、已经刷新次数
        map[ExploreEnum.Through]                = wsLuaFunc:readRecvByte()          -- 12、是否通关   0：未通关，1：通关 
        map[ExploreEnum.Time]                   = wsLuaFunc:readRecvString()        -- 13、上次免费刷新时间
        
        
        Explore.map[mapId] = map
    end
    dump(Explore)
    
    EventMgr:dispatch(EventType.OnGetExploreInfo, Explore.map)
    
end

function Explore:sendGetCell(mapId, seriesID, choice, buyItemId)
    lNet:sendMsgToSvr(NetMsgId.CL_SERVER_GET_CELL, "uiiibi", UserData.BaseInfo.userVeriCode, UserData.BaseInfo.userID, mapId, seriesID, choice, buyItemId)
end

NetMsgFuncs.OnGetNoticePrize = function()
    local wsLuaFunc          = lNet.cppFunc
    local prize = {}
    prize.gold               = wsLuaFunc:readRecvDouble()       -- 奖励的金钱
    prize.Exp                = wsLuaFunc:readRecvDouble()       -- 奖励的经验
    prize.ingot              = wsLuaFunc:readRecvInt()          -- 奖励的元宝
    prize.action             = wsLuaFunc:readRecvInt()          -- 奖励的体力
    prize.lenght             = wsLuaFunc:readRecvInt()          -- 奖励的物品数量
    prize.goods = {}
    for i = 1, prize.lenght do
        local goods = {}
        goods.Id = wsLuaFunc:readRecvInt()                   -- 奖励的物品ID
        goods.num = wsLuaFunc:readRecvInt()                  -- 奖励的物品数量
        table.insert(prize.goods, goods)
    end
    
    EventMgr:dispatch(EventType.OnGetNoticePrize, prize)

end

NetMsgFuncs.OnGetCell = function()
    local wsLuaFunc          = lNet.cppFunc

    local cellAtu            = {}
    cellAtu.mapId            = wsLuaFunc:readRecvInt()      -- 地图ID
    cellAtu.seriesID         = wsLuaFunc:readRecvInt()      -- 地图序列号ID
    cellAtu.res              = wsLuaFunc:readRecvByte()     -- 0:成功,1:没有开启该地图的权限，2:格子ID错误,3:1-9类型开启上限，4:缺少钥匙，5:缺少交易物品，
                                                            -- 6：购买的物品ID错误，7：物品购买游戏币或者元宝不足
    cellAtu.value            = wsLuaFunc:readRecvByte()     -- 改变后的数量(只有当成功了才有意义)
    cellAtu.type             = wsLuaFunc:readRecvByte()     -- 触发的类型(与箱子有关的类型才有意义)
    
    if cellAtu.res == 0 then
        local type = StaticData.ExploreMap[cellAtu.seriesID].Type
        Explore.map[cellAtu.mapId][type] = cellAtu.value
    end
    
    EventMgr:dispatch(EventType.OnGetCell, cellAtu)
    
end

--CL_SERVER_REFRESH = 2605,                     -- 客户端请求刷新大宝
--byRefreshTtype 是否免费刷新（1表示为免费刷新，其他值为非免费刷新(如0)）
function Explore:sendRefreshExploreMap(mapId,byRefreshTtype)
    lNet:sendMsgToSvr(NetMsgId.CL_SERVER_REFRESH, "uiib", UserData.BaseInfo.userVeriCode, UserData.BaseInfo.userID, mapId , byRefreshTtype)
end

--SERVER_CL_REFRESH = 2606,                     -- 服务端返回刷新大宝请求
NetMsgFuncs.OnRefresh = function()
    local wsLuaFunc      = lNet.cppFunc
    
    local data           = {}
    data.nMapID          = wsLuaFunc:readRecvInt()      -- 地图ID
    data.byBigBox        = wsLuaFunc:readRecvByte()     -- 大箱子剩余个数
    data.byCrystal       = wsLuaFunc:readRecvByte()     -- 水晶宝箱剩余个数         
    data.byJewel         = wsLuaFunc:readRecvByte()     -- 钻石宝箱剩余个数
    data.nRefresh        = wsLuaFunc:readRecvInt()      -- 刷新次数
    data.sTime           = wsLuaFunc:readRecvString()   -- 上次免费刷新时间 
    data.byRes           = wsLuaFunc:readRecvByte()     -- 0:成功,1:该地图未开 2:乾坤符不足，3:当前非免费刷新时间
    
    if data.byRes == 0 then
        Explore.map[data.nMapID][ExploreEnum.Box]                    = 0         -- 1、当前关卡开的箱子个数
        Explore.map[data.nMapID][ExploreEnum.Event]                  = 0         -- 2、当前关卡开的事件个数
        Explore.map[data.nMapID][ExploreEnum.Tower]                  = 0         -- 3、当前关卡开的塔个数
        Explore.map[data.nMapID][ExploreEnum.Tp]                     = 0         -- 4、当前传送个数
        Explore.map[data.nMapID][ExploreEnum.ChangeNPC]              = 0         -- 5、当前关卡遇到商店NPC个数
        Explore.map[data.nMapID][ExploreEnum.StorNPC]                = 0         -- 6、当前关卡遇交易NPC个数
        Explore.map[data.nMapID][ExploreEnum.TaskNPC]                = 0         -- 7、当前关卡遇到任务NPC个数
        Explore.map[data.nMapID][ExploreEnum.BigBox]                 = data.byBigBox   -- 8
        Explore.map[data.nMapID][ExploreEnum.Crystal]                = data.byCrystal  -- 9
        Explore.map[data.nMapID][ExploreEnum.Jewel]                  = data.byJewel    -- 10 
        Explore.map[data.nMapID][ExploreEnum.Refresh]                = data.nRefresh   -- 11
        Explore.map[data.nMapID][ExploreEnum.Time]                   = data.sTime      -- 12
        cc.UserDefault:getInstance():setStringForKey("exploreAllEvent" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[data.nMapID].ID, "")
        cc.UserDefault:getInstance():setStringForKey("exploreShowBoxAndEvent" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[data.nMapID].ID, "")
        cc.UserDefault:getInstance():setStringForKey("exploreOpen" .. UserData.BaseInfo.userID .. "_" .. StaticData.Map[data.nMapID].ID, "")
    end
    
    EventMgr:dispatch(EventType.OnRefresh, data)
end

-- 服务端通知探索地图通过
NetMsgFuncs.OnExploreThrouth = function()
    local wsLuaFunc      = lNet.cppFunc
    
    local mapId = wsLuaFunc:readRecvInt()      -- 通过的地图ID
    Explore.map[mapId][ExploreEnum.Through] = 1
    EventMgr:dispatch(EventType.OnExploreThrouth, mapId)
end

    
return Explore