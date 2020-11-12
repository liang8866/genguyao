local stringEx = require("common.stringEx")

local ExploreManager = {}

--获取探索类型Icon图标列表
function ExploreManager:getItemsIconTable(iExploreMapID)
    local mapStaticInfo = StaticData.Map[iExploreMapID]
    return stringEx:splitPrizeItemsStr(mapStaticInfo.iconID)
end

--获取探索类型的图标
function ExploreManager:getExploreItemIconPath(iconTable,itemType)
    local iconID = 0
    for i=1,#iconTable do
        if tonumber(iconTable[i][1]) == itemType then
            iconID = tonumber(iconTable[i][2])
            break
        end
    end
    return StaticData.Icon[iconID] ~= nil and StaticData.Icon[iconID].path or ""

end

--获取探索普通类型列表
function ExploreManager:getExploreMapNormalItems(iExploreMapID)
    local items = {}
    local mapStaticInfo = StaticData.Map[iExploreMapID]
    if mapStaticInfo ~= nil then
        -- Type="1-2|2-1|3-1|4-1|5-1|6-1", 
        -- Type="类型数量,1箱子,2事件,3塔,4传送,5交易npc,6商店npc",Type2="7大宝1,8大宝2,9大宝3（类型-数量-概率-必出次数）
        items = stringEx:splitPrizeItemsStr(mapStaticInfo.Type)
    end
    return items
end

--获取特殊大宝配置信息
function ExploreManager:getExploreMapSpecialItems(mapID)
    local items = {}
    local mapStaticInfo = StaticData.Map[mapID]
    if mapStaticInfo ~= nil then
        -- Type2="7-2-1000-2|8-3-2000-5|9-1-5000-10"
        -- Type="类型数量,1箱子,2事件,3塔,4传送,5交易npc,6商店npc",Type2="7大宝1,8大宝2,9大宝3（类型-数量-概率-必出次数）
        items = stringEx:splitPrizeItemsStr(mapStaticInfo.Type2)
    end
    return items
end


function ExploreManager:isFreeRefresh(mapID)
    local exploreMapData = UserData.Explore.map[mapID]
    local exploreStaticData = StaticData.Map[mapID]
    local TimeFormat = require("common.TimeFormat")
    local duration = TimeFormat:getSecondsInter(exploreMapData[ExploreEnum.Time])
    local isTimeFull = duration > exploreStaticData.time/1000
    local freshNum = exploreMapData[ExploreEnum.Refresh] -- 当前的刷新次数

    -- 未刷新过，或当前有一次免费机会
    return (duration == 0 or isTimeFull ) and 1 or 0
end

--获取当前探索进度，只计算类型1,3,8,9,10,11
function ExploreManager:getCurrentProgress(iExploreMapID)
    local exploreMapData = UserData.Explore.map[iExploreMapID]
    if exploreMapData == nil then
        return 0
    end

    local limitNumList = self:getLimitNumList(iExploreMapID)
    
    local num = exploreMapData[ExploreEnum.Box] + exploreMapData[ExploreEnum.Tower] 
    local total = limitNumList[ExploreEnum.Box] + limitNumList[ExploreEnum.Tower] 
    if exploreMapData[ExploreEnum.BigBox] < 111 then --已经刷出来了
        num = num + (limitNumList[ExploreEnum.BigBox] - exploreMapData[ExploreEnum.BigBox])
        total = total + limitNumList[ExploreEnum.BigBox]
    end

    if exploreMapData[ExploreEnum.Crystal] < 111 then --已经刷出来了
        num = num + (limitNumList[ExploreEnum.Crystal] - exploreMapData[ExploreEnum.Crystal])
        total = total + limitNumList[ExploreEnum.Crystal]
    end

    if exploreMapData[ExploreEnum.Jewel] < 111 then --已经刷出来了
        num = num + (limitNumList[ExploreEnum.Jewel] - exploreMapData[ExploreEnum.Jewel])
        total = total + limitNumList[ExploreEnum.Jewel]
    end
    return num,total
end


--获得各种探索类型的上限数量
function ExploreManager:getLimitNumList(iExploreMapID)
    local stringEx = require("common.stringEx")
    local exploreStaticData = StaticData.Map[iExploreMapID]
    local items2 = stringEx:splitPrizeItemsStr(exploreStaticData.Type2)  --稀有宝物
    local items1 = stringEx:splitPrizeItemsStr(exploreStaticData.Type)   -- 普通宝物
    local ShowNumList = stringEx:splitPrizeItemsStr(exploreStaticData.ShowNum)  -- ShowNum="1-5|2-2|8-1|9-1|10-1"
    local ShowNum = {}
    for i=1,table.nums(ShowNumList) do
        ShowNum[tonumber(ShowNumList[i][1])] = tonumber(ShowNumList[i][2])
    end
    
    local limitNumList = {}
    
    for i=1,table.nums(items1) do
        local type = tonumber(items1[i][1])
        local num = tonumber(items1[i][2])
        limitNumList[type] = ShowNum[type] ~= nil and ShowNum[type] or num
    end

    for i=1,table.nums(items2) do
        local type = tonumber(items2[i][1])
        local num = tonumber(items2[i][2])
        limitNumList[type] = ShowNum[type] ~= nil and ShowNum[type] or num
    end
    return limitNumList
    
end

return ExploreManager