PlayerDetails = {
    flyingObject = {},          -- 飞宝基本数据
    Skill = {},                 -- 技能基本数据
    SkillWithoutFly = {},       -- 技能基本数据
    God = {},                   -- 神将基本数据
}

function PlayerDetails:getFiyingObjectDetatils(fiyingObjectID, star)

    local flyObj = FightStaticData.flyingObject[fiyingObjectID]
--    local star = UserData.Fibble.fibbleTable[fiyingObjectID].byStar
    local lv = UserData.BaseInfo.userLevel
    local t = {}
    
    t.flyingObject_Hp = (10 * flyObj.grade + flyObj.hp) * (lv + 3) + 100 * star             -- 飞宝血量
    t.bonus_MechHurt  = (star + 2) * flyObj.bonusMechDef / 10000                            -- 机系伤害减免
    t.bonus_FairyHurt = (star + 2) * flyObj.bonusFairyDef / 10000                           -- 仙系伤害减免
    t.bonus_DemonHurt = (star + 2) * flyObj.bonusDemonDef / 10000                           -- 神系伤害减免
    
    t.bonus_SkillHp   = (star + 2) * flyObj.bonusHp / 10000                                 -- 技能血量加成
    t.bonus_SkillAtk  = (star + 2) * flyObj.bonusAtk / 10000                                -- 技能攻击加成
    
    PlayerDetails.flyingObject = t
    return t
end

--参与战斗的(有飞宝ID时的)技能属性
function PlayerDetails:getSkillDetatils(fiyingObjectID, skillID)
    local flySkill = FightStaticData.flyingObjectSkill[skillID]
    local flySkillLv = UserData.Fibble.skillTable[skillID].level
    local t = {}
    
    local flyingObjectDetails = self:getFiyingObjectDetatils(fiyingObjectID)
    t.Skill_Hp  = ((10 * flySkill.grade + flySkill.hp) * (flySkillLv + 3) / 2) * (1 + flyingObjectDetails.bonus_SkillHp)        -- 技能血量
    t.Skill_Atk = ((10 * flySkill.grade + flySkill.atk) * (flySkillLv + 3) / 6) * (1 + flyingObjectDetails.bonus_SkillAtk)      -- 技能攻击
    t.Skill_Hp_Next  = ((10 * flySkill.grade + flySkill.hp) * (flySkillLv + 3 + 1) / 2) * (1 + flyingObjectDetails.bonus_SkillHp)
    t.Skill_Atk_Next = ((10 * flySkill.grade + flySkill.atk) * (flySkillLv + 3 + 1) / 6) * (1 + flyingObjectDetails.bonus_SkillAtk)
    
    t.speed  = flySkill.speed
    t.cdTime = flySkill.cdTime
    t.speed_Next  = flySkill.speed   --后期会有公式计算，目前升级后不变化
    t.cdTime_Next = flySkill.cdTime  --后期会有公式计算，目前升级后不变化
    
    PlayerDetails.Skill = t
    
    return t
end

--技能列表的(无飞宝ID时的)技能属性
function PlayerDetails:getSkillDetatilsWithoutFlyObject(skillID)
    local flySkill = FightStaticData.flyingObjectSkill[skillID]
    local flySkillLv = UserData.Fibble.skillTable[skillID].level
    local t = {}
    
    t.Skill_Hp  = math.floor(((10 * flySkill.grade + flySkill.hp) * (flySkillLv + 3) / 2))        -- 技能血量
    t.Skill_Atk = math.floor(((10 * flySkill.grade + flySkill.atk) * (flySkillLv + 3) / 6))       -- 技能攻击
    t.Skill_Hp_Next  = math.floor(((10 * flySkill.grade + flySkill.hp) * (flySkillLv + 3 + 1) / 2)) 
    t.Skill_Atk_Next = math.floor(((10 * flySkill.grade + flySkill.atk) * (flySkillLv + 3 + 1) / 6)) 

    t.speed  = flySkill.speed
    t.cdTime = flySkill.cdTime
    t.speed_Next  = flySkill.speed   --后期会有公式计算，目前升级后不变化
    t.cdTime_Next = flySkill.cdTime  --后期会有公式计算，目前升级后不变化

    PlayerDetails.SkillWithoutFly = t

    return t
end

function PlayerDetails:getGodDetatils(GodId)
    local godWill = FightStaticData.godwill[GodId]
    local UserGodWill = UserData.Godwill.godList[GodId]
    local t = {}
    
    t.God_Hp  = (10 * godWill.grade + godWill.hp) * (UserGodWill.level + 3) / 2 + 50 * UserGodWill.star
    t.God_Atk = (10 * godWill.grade + godWill.atk) * (UserGodWill.level + 3) / 6 + 50 * UserGodWill.star / 3
    t.God_Hp_Next  = (10 * godWill.grade + godWill.hp) * (UserGodWill.level + 3 + 1) / 2 + 50 * UserGodWill.star
    t.God_Atk_Next = (10 * godWill.grade + godWill.atk) * (UserGodWill.level + 3 + 1) / 6 + 50 * UserGodWill.star / 3
    
    PlayerDetails.God = t
    return t
    
end


function PlayerDetails:getSkillBufferList(skillID)
    local bufferIDList = {}
    local skill_staticData = FightStaticData.flyingObjectSkill[skillID]
    if skill_staticData == nil then
        return bufferIDList
    end
    
    if string.len(skill_staticData.buffID) == 0 then
        return bufferIDList
    end
    local buffIDList = string.split(skill_staticData.buffID,"|")
    for i=1, table.nums(buffIDList) do
        local buffID = tonumber(buffIDList[i])
        local buffStaticInfo = FightStaticData.buffer[buffID]
        if buffStaticInfo ~= nil then
            bufferIDList[table.nums(bufferIDList) + 1] = buffID
        end
    end

    return bufferIDList
end

function PlayerDetails:getSkillBufferDes(skillID)	
    local bufferIDList = PlayerDetails:getSkillBufferList(skillID)
    local effectText = ""
    local num = table.nums(bufferIDList)
    for i=1, num do
        local buffID = bufferIDList[i]
        local buffStaticInfo = FightStaticData.buffer[buffID]
        if buffStaticInfo ~= nil then
            effectText = effectText .. buffStaticInfo.name
        end
        if i < num then
            effectText = effectText .. ","
        end
    end	
    return effectText
end

return PlayerDetails