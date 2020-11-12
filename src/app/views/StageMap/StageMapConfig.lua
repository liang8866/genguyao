
local StageMapConfig = class("StageMapConfig")

function StageMapConfig:ctor()
end

function StageMapConfig:init()
end


--获得当前大地图中的所有城镇及事件点id
function StageMapConfig:getTownIdByNextPointID(nextPointID)
    local townIdList = {}
    for key,value in pairs(StaticData.TownMap) do
        if value.WorldMapId == mapID then
            table.insert(townIdList,key)
        end
    end
    return townIdList
end

--获得当前大地图中的所有城镇及事件点id
function StageMapConfig:getAllTownIDInWorldMap(mapID)
    local townIdList = {}
    for key,value in pairs(StaticData.TownMap) do
        if value.WorldMapId == mapID then
            table.insert(townIdList,key)
        end
    end
    return townIdList
end

--获得当前区域内的所有城镇及事件点的id
function StageMapConfig:getAllPointIDInScreenArea(areaId)
    local townIdList = {}
    for key,value in pairs(StaticData.TownMap) do
        if value.AreaID == areaId then
            table.insert(townIdList,key)
        end
    end
    return townIdList
end

--获得当前区域内的所有城镇id
function StageMapConfig:getAllTownIDInScreenArea(areaId)
    local townIdList = {}
    for key,value in pairs(StaticData.TownMap) do
        local a,b = string.find(value.TownId,"_")
        local isTown = (a == nil and b == nil)
        if value.AreaID == areaId and isTown then
            table.insert(townIdList,key)
        end
    end
    return townIdList
end

--获得当前区域内的所有城镇路径的id
function StageMapConfig:getRoadIdListInScreenArea(areaId)
    local roadIdList = {}
    for key,value in pairs(StaticData.TownRoad) do
        if value.AreaID == areaId then
            table.insert(roadIdList,key)
        end
    end
    return roadIdList
end


--通过起始和结束城镇id获得城镇路径的表格信息
function StageMapConfig:getRoadId(townIdFrom,townIdTo)
    local roadIdList = {}
    for key,value in pairs(StaticData.TownRoad) do
        if value.TownIdFrom == townIdFrom and value.TownIdTo == townIdTo then
            return value
        end
    end
    return nil
end

--通过起始和结束城镇id及指定区域id列表中,获得城镇路径的表格信息
function StageMapConfig:getRoadId(townIdFrom,townIdTo,roadIdList)
    local roadIdList = {}
    for i=1,#roadIdList do
        local roadId = roadIdList[i]
        if StaticData.TownRoad[roadId].TownIdFrom == townIdFrom and StaticData.TownRoad[roadId].TownIdTo == townIdTo then
            return StaticData.TownRoad[roadId]
        end
    end
    return nil
end



return StageMapConfig
