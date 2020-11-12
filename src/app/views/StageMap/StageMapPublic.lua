
local StageMapPublic = class("StageMapPublic")
function StageMapPublic:AddNextPointAnimation(node)
    local offset = 2
    local posx, posy = node:getPosition()
    local moveto1 = cc.MoveTo:create(0.15, cc.p(posx,posy-3))
    local moveto2 = cc.MoveTo:create(0.15, cc.p(posx,posy+3))
    return node:runAction(cc.RepeatForever:create(cc.Sequence:crearte(moveto1,moveto2)))
end


function StageMapPublic:getAllChildByName(childrenVec,namePreString)
    local childrenNode = {}
    if childrenVec ~= nil then
        for i=1,#childrenVec do
            local child = childrenVec[i]
            if child ~= nil then
                local i,j = string.find(child:getName(),namePreString)
                if i ~= nil and j ~= nil then
                    table.insert(childrenNode,child)
                end
            end
        end
    end
    return childrenNode
end 


function StageMapPublic:getStageMapIdListInCurrentWorldMap(worldMapID,smallMapTab)
    local stageMapIdList = {}
    if smallMapTab ~= nil then
        for key, var in pairs(smallMapTab) do
            if tonumber(var.LandId) == tonumber(worldMapID) and nil == isTableHasValue(stageMapIdList,var.StageId) then
                table.insert(stageMapIdList,var.StageId)
            end
        end
    end

    return stageMapIdList
end


function StageMapPublic:getRoadPointInfoByName(roadPointName)

    for i=1,table.maxn(RoadPointNodeList) do
        if roadPointName == RoadPointNodeList[i].name then
            return RoadPointNodeList[i]
        end
    end
    
    return nil
end

function StageMapPublic:getRoadPointInfoByID(id)
    cclog("getRoadPointInfoByID  id="..id)
    for i=1,#RoadPointNodeList do
        cclog("RoadPointNodeList[i].id  i="..i .. ",id=" .. RoadPointNodeList[i].id)
        if tonumber(id) == tonumber(RoadPointNodeList[i].id) then
            cclog("RoadPointNodeList[i].id .... ")
            return RoadPointNodeList[i]
        end
    end
    return nil
end

return StageMapPublic