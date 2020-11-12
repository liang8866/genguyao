local stringEx = require("common.stringEx")

--神将管理器
local GodwillManager = {
    unlockedList = {}, 
    lockedList = {},
}

--获已经解锁的神将列表
function GodwillManager:getGodwillUnlockedList()
    return self.unlockedList
end

--获取未解锁的神将列表
function GodwillManager:getGodwillLockedList()
    return self.lockedList
end

--更新已解锁神将列表及排序
function GodwillManager:updateGodwillListOrder()
    self.unlockedList = {}
    self.lockedList = {} 
    for key,value in pairs(UserData.Godwill.godList) do
        if value.unlocked == 0 then
            table.insert(self.lockedList,value)
        else
            table.insert(self.unlockedList,value)
        end
    end
    dump(self.lockedList)
    local function comp(a,b)
        if a ~= nil and b ~= nil then
            if a.pos ~= b.pos then
                return a.pos > b.pos
            else
                if a.grade ~= b.grade then
                    return a.grade > b.grade
                else
                    if a.fight ~= b.fight then
                        return a.fight > b.fight
                    else
                        return a.id > b.id
                    end
                end
            end
        end
        return false
    end
    table.sort(self.unlockedList,comp)
    
    local function comp2(a,b)
        if a ~= nil and b ~= nil then
            if a.itemHaveNum ~= b.itemHaveNum then
                return a.itemHaveNum > b.itemHaveNum
            else
                if a.grade ~= b.grade then
                    return a.grade > b.grade
                else
                    if a.fight ~= b.fight then
                        return a.fight > b.fight
                    else
                        return a.id > b.id
                    end
                end
            end
        end
        return false
    end
    
    table.sort(self.lockedList,comp2)
    
end


--检测是否有可合成的神将
function GodwillManager:CheckHasGodwillCanCreate()
    local ItemManager = require("app.views.ItemManager")
    for key,value in pairs(self.lockedList) do
        if value.createNeedItems.id ~= nil and value.createNeedItems.count ~= nil then
            local itemID = value.createNeedItems.id
            UserData.Godwill.godList[value.id].itemHaveNum = ItemManager:getItemNum(itemID)
            self.lockedList[key].itemHaveNum = UserData.Godwill.godList[value.id].itemHaveNum
            if  UserData.Godwill.godList[value.id].itemHaveNum >= value.createNeedItems.count then
                return true
            end
        end
    end
    return false
end

--检测是否有可升级的神将
function GodwillManager:CheckHasGodwillCanLevelUp()
    local ItemManager = require("app.views.ItemManager")
    for key,value in pairs(self.unlockedList) do
        local canLevelUp = false
        local levelupItemID = GodwillManager:getGodwillLevelUpNeedItems(value.star)
        local itemStaticData = StaticData.Item[levelupItemID]
        if itemStaticData ~= nil then
            local itemNum = ItemManager:getItemNum(levelupItemID)
            if itemNum >= value.level*10 then
                canLevelUp = true
                return canLevelUp
            end
        end
    end
    return false
end

--检测是否有可升星的神将
function GodwillManager:CheckHasGodwillCanStarUp()
    
    local ItemManager = require("app.views.ItemManager")
    for key,value in pairs(self.unlockedList) do
        local canLevelUp = true
        local items = self:getGodwillStarUpNeedItems(value.id,value.star)
        for i=1,4 do
            local itemID = items[i].id
            local itemCount = items[i].count
            local itemStaticInfo = StaticData.Item[itemID]
            if itemStaticInfo ~= nil then
                local itemNum = ItemManager:getItemNum(itemID)
                if itemNum < itemCount then
                    canLevelUp = false
                    break
                end
            end
        end
        if canLevelUp then
            return canLevelUp
        end
    end
    return false
end


function GodwillManager:getGodwillStaticData(id)
    return FightStaticData.godwill[id]

end

function GodwillManager:getGodwillFibbleUPStaticData(id,starLevel)
    local count = table.nums(FightStaticData.FibbleUP)
    for i=1,count do
        if FightStaticData.FibbleUP[i].id == id and FightStaticData.FibbleUP[i].star == starLevel then
            return FightStaticData.FibbleUP[i]
        end
    end
    return nil
end

--获取神将名字
function GodwillManager:getGodwillName(id,starLevel)
    local fibbleUPStaticData = self:getGodwillFibbleUPStaticData(id,starLevel)
    if fibbleUPStaticData == nil then
        cclog("GodwillManager:getGodwillName id = %d" ,id )
    end
    local godwillName = fibbleUPStaticData.name
    if godwillName == nil then
        godwillName = FightStaticData.godwill[id].name
    end
    return (godwillName ~= nil) and godwillName or ""
end

--获取神将头像icon,及神将的展示图片，
function GodwillManager:getGodwillIcon(id,starLevel)
    if starLevel == nil then
        starLevel = 0
    end
         
    local fibbleUPStaticData = self:getGodwillFibbleUPStaticData(id,starLevel)
    return fibbleUPStaticData.icon
end

--获取神将技能的icon
function GodwillManager:getGodwillSkillIcon(id)
    local godwillStaticData = self:getGodwillStaticData(id)
    local skillIcon = godwillStaticData.icon
    return skillIcon
end

--获取神将升星需要的材料列表
function GodwillManager:getGodwillStarUpNeedItems(id,starLevel)
    local fibbleUPStaticData = self:getGodwillFibbleUPStaticData(id,starLevel)
    local godwillStarUpItems = fibbleUPStaticData.cID
    local items = {}
    if godwillStarUpItems then
        stringEx:itemResolveFromString(godwillStarUpItems,items) 
    end
    return items
end

-- 获取神将等级升级需要的材料列表
-- "0-711001|1-712001|2-723001|3-724001|4-735001"
function GodwillManager:getGodwillLevelUpNeedItems(starLevel)
    starLevel = starLevel > 5 and 5 or starLevel
    starLevel = starLevel < 0 and 0 or starLevel
    local levelUpStr = StaticData.SystemParam['GodUPNeedItem'].StrValue
    local items = {}
    if levelUpStr then
        stringEx:itemResolveFromString(levelUpStr,items) 
    end
    return tonumber(items[starLevel+1].id)
end

--判断神将是否达到升级限制
function GodwillManager:canLevelUp(godwillLevel,starLevel)
    return godwillLevel <= starLevel*10-1
end	

--获取神将合成时需要的材料及数量
function GodwillManager:getGodCreateNeedItems(godwillID)
    local needItems = {}
    local staticData = self:getGodwillStaticData(godwillID)
    if staticData ~= nil then
        local needItemStr = string.split(staticData.activeNeedItem,"-")
        needItems.id = tonumber(needItemStr[1])
        needItems.count = tonumber(needItemStr[2])
    end
    return  needItems
end 

--是否已获得神将
function GodwillManager:hasGodwill(id)
    return UserData.Godwill.godList[id].unlocked == 1
end

--获取神将信息
function GodwillManager:getGodwillInfo(id)
    local godwillInfo = UserData.Godwill.godList[id]
    return godwillInfo
end

--添加动画到UI
function GodwillManager:addGodwillAnimToUI(parent,godwillID)
    local SpineJson = FightStaticData.godwill[godwillID].spineName .. ".json"
    local SpineAtlas = FightStaticData.godwill[godwillID].spineName..".atlas"
    local mySpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    mySpine:setScale(1.2)
    mySpine:setAnimation(0, "load", true)
    parent:removeAllChildren()
    parent:addChild(mySpine)

--    local t = 0.4
--    local h = 5
--    local move1 = cc.MoveBy:create(t,cc.p(0,h))
--    local move2 = cc.MoveBy:create(t,cc.p(0,-h))
--    local move3 = cc.MoveBy:create(t,cc.p(0,-h))
--    local move4 = cc.MoveBy:create(t,cc.p(0,h))
--    local seq = cc.Sequence:create(move1,move2,move3,move4)
    --    parent:runAction(cc.RepeatForever:create(seq))

end



return GodwillManager


--  local num = table.nums(UserData.Godwill.godList)
--    cclog("num = " .. tostring(num))
--    if num > 1 then
--        -- 排序的
--        local function Compare(a,b)
--            cclog("a.id = %d,b.id=%d" ,a.id,b.id)
--            return  a.grade < b.grade
--        end
--        local tb = UserData.Godwill.godList
--        table.sort(tb,function(a,b)
--            cclog("111 a.id = %d,b.id=%d" ,a.id,b.id)
--            return  a.grade < b.grade
--        end)
--        
--        UserData.Godwill.godList = tb
--        
--    end