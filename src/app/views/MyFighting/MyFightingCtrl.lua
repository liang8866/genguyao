local stringEx = require("common.stringEx")

MyFightingCtrl = {
    bulletuid = 0,
    playerBullets = {},  -- 我方子弹
    enemyBullets = {},   -- 敌方子弹
    player = nil,        -- 角色
    enemy = nil,         -- 敌方
    battleLayer = nil,   -- 战斗层
    gameOver = nil,      -- 游戏是否结束
    resTime = 99,        -- 剩余时间,单位秒
    isWin = 0 ,   -- 是否赢了或者输了，平了，-1输了，0 打平，1赢了
    mySkillTable = {}, -- 我方的技能等级信息
    enemySkillTable = {},-- 敌方的技能等级信息
    enemyFibbleStar = 1,
    myFibbleLevel = 1,
    enemyFibbleLevel= 1,
    guideGodID = 0,  -- 指引时的神将ID
}


function MyFightingCtrl:init()
    self.resTime = 99        -- 剩余时间,单位秒
    self.bulletuid = 0    
    self.playerBullets = {}  -- 我方子弹
    self.enemyBullets = {}   -- 敌方子弹
    self.myGodIconTable={}   --我方的神将显示的UI图标
    self.myGodIconPosTable= {}--我方的神将显示的UI图标位置
    self.player = nil        -- 角色
    self.enemy = nil         -- 敌方
    self.battleLayer = nil   -- 战斗层
    self.gameOver = nil      -- 游戏是否结束
    self.isWin = 0           -- 是否赢了或者输了，平了，-1输了，0 打平，1赢了
    self.guideGodID = 0      -- 指引时的神将ID
end

-- 添加子弹
function MyFightingCtrl:addBullet(bullet)
    if bullet.camp==MyFightingConfig.ECamp.Player then
        self.playerBullets[bullet.uid] = bullet
        
    else
        self.enemyBullets[bullet.uid] = bullet
    end
end

-- 删除子弹
function MyFightingCtrl:removeBullet(bullet)
    if bullet.camp==MyFightingConfig.ECamp.Player then
        self.playerBullets[bullet.uid] = nil
        
    else
        self.enemyBullets[bullet.uid] = nil
    end
end

-- 根据阵营获取角色
function MyFightingCtrl:getRole(camp)
    if camp==MyFightingConfig.ECamp.Player then
        return self.player
    end
    return self.enemy
end

-- 获取敌方角色
function MyFightingCtrl:getTargetRole(camp)
    if camp==MyFightingConfig.ECamp.Player then
        return self.enemy
    end
    return self.player
end

--特效创建
function MyFightingCtrl:createEffect(name, count, speed)
    local animation = cc.Animation:create()
    for i = 1, count do
        local path = string.format(name, i)
        animation:addSpriteFrameWithFile(path)
    end

    local s = 1
    if speed then
        s = 1 / speed
    end

    animation:setDelayPerUnit(0.083 * s)
    animation:setRestoreOriginalFrame(true)
    return cc.Animate:create(animation)
end

--删除骨骼
function MyFightingCtrl:removeSpine(mySpine)
    mySpine:stopAllActions()
    local function callback1()
        mySpine:removeFromParent()
        mySpine = nil
    end
    local seq = cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(callback1))
    mySpine:runAction(seq)
end

--删除所有的子弹和子弹血条和碰撞特效
function MyFightingCtrl:GameOverRemoveAllBullet()
    for key, b in pairs(self.playerBullets) do
   
        if  b and b.skillhpBarNode then
            b.skillhpBarNode:removeFromParent()
            b.skillhpBarNode = nil
        end 
        if  b and b.crashEffectNode then
            b.crashEffectNode:removeFromParent()
            b.crashEffectNode = nil
        end
        table.remove(self.playerBullets,key)
        b:removeFromParent()
	end
	
    for key, b in pairs( self.enemyBullets) do
        if b and b.skillhpBarNode then
            b.skillhpBarNode:removeFromParent()
            b.skillhpBarNode = nil
        end 
        if b and b.crashEffectNode then
            b.crashEffectNode:removeFromParent()
            b.crashEffectNode = nil
        end
        table.remove(self.enemyBullets,key)
        b:removeFromParent()
    end

end

-- 参数：阵营和造成的伤害,类型
-- 功能：特定技能扣血其他的技能的
function MyFightingCtrl:skillCostOtherSkillHp(camp,hurt)

    if camp == MyFightingConfig.ECamp.Player then
        for key, b in pairs( self.enemyBullets) do
            b.hp = b.hp - hurt
        end
    else
        for key, b in pairs( self.playerBullets) do
            b.hp = b.hp - hurt
        end
    end
    
end


-- 参数：阵营和造成的伤害,类型,弹道 fireType,line
-- 功能：对导弹上自动的扣血 smallAtkType: 1/伤敌方子弹  2/伤敌方子弹及飞宝 3/伤所有子弹,包括自己
function MyFightingCtrl:skillDirectHurtBullet(buffTable,camp,hurt,smallAtkType,fireType,line)
    
   local function hurtBullet(myCamp,myLine)
        if myCamp == MyFightingConfig.ECamp.Player then
            for key, b in pairs(self.enemyBullets) do
                if b.type == myLine then
                    b:showReduceHpNum(hurt)
                    b:createDirectDamageBar()
                    b.hp = b.hp - hurt
                    MyFightingCtrl:setObjHaveBuff(buffTable,b)
                end
            end
        else
            for key, b in pairs( self.playerBullets) do
                if b.type == myLine then
                    b:showReduceHpNum(hurt)
                    b:createDirectDamageBar()
                    b.hp = b.hp - hurt
                    MyFightingCtrl:setObjHaveBuff(buffTable,b)
                end
            end
        end
   end
      
    local function hurtLineChoose(myCamp)
        if fireType == 1 then -- 如果只伤一个弹道的话，
            hurtBullet(myCamp,line)
        elseif  fireType == 2 then --如果伤2个弹道的
            hurtBullet(myCamp,line)
            if line == 1 then
                hurtBullet(myCamp,2)
            elseif line == 2  then  
                local t = {1,3}
                local k = math.random(1,2)
                hurtBullet(myCamp,t[k])
            elseif line == 3  then  
                hurtBullet(myCamp,2)
            end
        elseif  fireType == 3 then --全部弹道的话
            hurtBullet(myCamp,1)
            hurtBullet(myCamp,2)
            hurtBullet(myCamp,3)
        end
    end
    
    if smallAtkType  == 1 or smallAtkType  == 2 then --伤的是对方的子弹
         hurtLineChoose(camp)
    elseif smallAtkType  == 3 then -- 连本方也伤害
        hurtLineChoose(MyFightingConfig.ECamp.Player)
        hurtLineChoose(MyFightingConfig.ECamp.Enemy)
    end

end





-- 参数： npcId 如果没有的话不填或者0
-- 功能：获取战斗前的敌对双方的飞宝ID，神将ID，技能ID
function MyFightingCtrl:getFightingFibbleGodData(npcId)
    UserData.BaseInfo.NPCId = npcId       -- 记录NPCId
     
	-- 我方飞宝ID 一开始有默认，在选择飞宝也要传递
	-- 获取我方的神将列表，同一格式是飞宝ID和等级
    self:getMyGodFromList(UserData.BaseInfo.nFibbleId)
    --  获取技能信息的
    self:getMySkillFromList(UserData.BaseInfo.nFibbleId)
    MyFightingCtrl.myFibbleLevel = UserData.BaseInfo.userLevel
    
	-- 获取敌方的飞宝ID和神将ID列表
    if   npcId~= nil or npcId ~= 0 then -- 如果有任务的情况下
        local npcData = StaticData.Npc[npcId] --获取NPC数据
        local flyTemp =  stringEx:split(npcData.FlyID,"-")
        
        UserData.BaseInfo.enemyFlyID = tonumber(flyTemp[1]) -- 获取飞宝ID
        MyFightingCtrl.enemyFibbleStar = tonumber(flyTemp[2]) -- 记录星级
       
        local level = npcData.NeedLevel --获取神将，飞宝等级
        MyFightingCtrl.enemyFibbleLevel = level -- 记录等级
        local temp = stringEx:split(npcData.GodID,"|") -- 解析字符串 里面包含神将ID ，品阶，星级, 等级
        UserData.BaseInfo.enemyGodTable = {} --置空
        if npcData.GodID == "" then
        	temp = {}
        end
        for i = 1, #temp do
            local itemTabel = {}
            local splitTable = stringEx:split(temp[i],"-")
            local gid  =  tonumber(splitTable[1])
            local grade = tonumber(splitTable[2]) -- 品阶
            local star = tonumber(splitTable[3]) -- 星级
            local gLV = tonumber(splitTable[4]) -- 等级
          
            local godData = FightStaticData.godwill[gid]
            
            itemTabel.id = gid      --神将id
            itemTabel.level = gLV   --神将等级
            itemTabel.star = star   -- 神将星级
            itemTabel.unlocked = 1  -- 是否解锁
            itemTabel.grade = grade   --神将品质 NPC获取来的
            itemTabel.fight = godData.hp + godData.atk*3 + grade*100     --神将战力值(战力=hp+atk*3+品质*100（暂定）)
            UserData.BaseInfo.enemyGodTable[i] = itemTabel
        end
        
        local skillTableTemp = stringEx:split(npcData.SkillID,"|")
        MyFightingCtrl.enemySkillTable = {}
        for i=1, 3 do
            local skillInfo = {}
            skillInfo.level = level
            local skillID_lv = stringEx:split(skillTableTemp[i],"-")
            local sId = tonumber(skillID_lv[1])
            local sLv = tonumber(skillID_lv[2])
            skillInfo.id = sId
            skillInfo.level = sLv
            local staticInfo = FightStaticData.flyingObjectSkill[tonumber(skillTableTemp[i])]
            skillInfo.grade = (staticInfo ~= nil) and staticInfo.grade or 0
            skillInfo.name = (staticInfo ~= nil) and staticInfo.name or ""
            skillInfo.fight = (staticInfo ~= nil) and (staticInfo.hp + staticInfo.atk*3 + staticInfo.grade*100) or 0

            table.insert(MyFightingCtrl.enemySkillTable,skillInfo) 
        end
        
        -- 第四个技能不变
        local fibbleStaticData = FightStaticData.flyingObject[UserData.BaseInfo.enemyFlyID ]
        local skillInfo = {}
        skillInfo.level = level
        skillInfo.id = fibbleStaticData.skillID4
        local staticInfo = FightStaticData.flyingObjectSkill[fibbleStaticData.skillID4]
        skillInfo.grade = (staticInfo ~= nil) and staticInfo.grade or 0
        skillInfo.name = (staticInfo ~= nil) and staticInfo.name or ""
        skillInfo.fight = (staticInfo ~= nil) and (staticInfo.hp + staticInfo.atk*3 + staticInfo.grade*100) or 0
        table.insert(MyFightingCtrl.enemySkillTable,skillInfo) 
       
        


    else -- 没有任务的情况下,判断下NpcID
        
        
        
        
	end
    


    
end



-- 参数：我选择的飞宝ID
-- 功能：根据我选择的飞宝ID返回一个神将ID表

function MyFightingCtrl:getMyGodFromList(nSelectFibblleId)
	UserData.BaseInfo.myGodTable = {}
    local t = UserData.Fibble.fibbleTable[nSelectFibblleId][1]
    local myGod = {t.nGodId1,t.nGodId2,t.nGodId3,t.nGodId4,t.nGodId5}
	for i = 1, 5 do
        local itemTabel = {}
        local godid =  myGod[i]
        local godInfo = {}
        if godid ~= 0 then -- 如果有神将ID
            godInfo =  UserData.Godwill.godList[godid]
            table.insert(UserData.BaseInfo.myGodTable,godInfo)           
        end
	end
  
    return myGod
end




-- 参数：我选择的飞宝ID
-- 功能：返回技能的服务器信息

function MyFightingCtrl:getMySkillFromList(nSelectFibblleId)
	MyFightingCtrl.mySkillTable = {}
    local t = UserData.Fibble.fibbleTable[nSelectFibblleId][1]
    local mySkill = {t.nSkillId1,t.nSkillId2,t.nSkillId3,t.nSkillId4}
    for i = 1, #mySkill do
        local itemTabel = {}
        local skillid =  mySkill[i]
        local skillInfo = {}
        if skillid ~= 0 then -- 如果ID
            skillInfo =  UserData.Fibble.skillTable[skillid]
            table.insert(MyFightingCtrl.mySkillTable,skillInfo)           
        end
    end
end

-- 参数：传入神将ID，阵营
-- 功能：获取对应的数据
function MyFightingCtrl:getGodInfo(godid,camp)
	local d = {}
    local godTable = UserData.BaseInfo.myGodTable
    if camp ~= MyFightingConfig.ECamp.Player then
        godTable = UserData.BaseInfo.enemyGodTable
	end
    for key, var in pairs(godTable) do
        if var.id == godid then
			d = var
		    break	
		end
	end
	
	return d
end

-- 参数：传入技能ID，阵营
-- 功能：获取对应的数据
function MyFightingCtrl:getSkillInfo(skillid,camp)
    local d = {}
    local skillTable = MyFightingCtrl.enemySkillTable
  
    if camp == MyFightingConfig.ECamp.Player then
        skillTable = MyFightingCtrl.mySkillTable
    end
   
    for key, var in pairs(skillTable) do
        if var.id == skillid then
            d = var
            break   
        end
    end
    
    return d
end


-- 参数：传入阵营参数
-- 功能：返回获取的静态飞宝数据
function MyFightingCtrl:getCurFightingFibbleStaticInfo(camp)
    local fibbleId = UserData.BaseInfo.nFibbleId
    
    if camp ~= MyFightingConfig.ECamp.Player then
        fibbleId = UserData.BaseInfo.enemyFlyID
    end
    
    return FightStaticData.flyingObject[fibbleId]
end

-- 参数：传入阵营参数
-- 功能：返回当前战斗的飞宝星级
function MyFightingCtrl:getCurFightingFibbleStar(camp)
    local star  =  1
    if camp == MyFightingConfig.ECamp.Player then
        local fibbleId = UserData.BaseInfo.nFibbleId
        star =  UserData.Fibble.fibbleTable[fibbleId][1].byStar
    else
        star = MyFightingCtrl.enemyFibbleStar
    end

    return star
end

-- 参数：传入阵营
-- 功能：返回当前敌方的阵营的减免伤害
function MyFightingCtrl:getCurFightingDef(camp)
	local def = 0
	local type = 1
	local r = nil
    if camp == MyFightingConfig.ECamp.Player then
       type =  MyFightingCtrl.player.type
        r = MyFightingCtrl.enemy
    else
        type =  MyFightingCtrl.enemy.type
        r = MyFightingCtrl.player
    end
    if type ==1 then -- 机械
        def = r.mechDef
    elseif type == 2 then  -- 仙
        def = r.fairyDef
    elseif type == 3 then  -- 妖
        def = r.demonDef
    end
    
    return def
end

-- 参数：一个表，物体
-- 功能：更改表，并改变消耗血的量

function MyFightingCtrl:changObjInBullte(myBullet,obj)
	
    
    local duifangTables = {} --对方的子弹表
    -- 判断获取对方的子弹表
    if myBullet.camp == MyFightingConfig.ECamp.Enemy then
    	duifangTables = MyFightingCtrl.playerBullets
    else
     	duifangTables = MyFightingCtrl.enemyBullets
    end
    local cashTempTable = {} -- 临时的空表
    
    -- 剔除已经不存在了的删除掉的
    for k1, o in pairs(myBullet.crashObjTable) do
        local f = false
        for k2, v in pairs(duifangTables) do
        	if o == v then
                f = true
                break
        	end
        end
        
        if f == true then
            table.insert(cashTempTable,o) --记录还存在的
        end
    end
    myBullet.crashObjTable = cashTempTable --换个新的
    
    local flag = false
	-- 判断是否已经存在了
    for k, o in pairs(myBullet.crashObjTable) do
		if o == obj then
			flag = true
			break
		end
	end
    if flag == false then --插入进来
        table.insert(myBullet.crashObjTable,obj)
	end
	
	local atkCount = 0 --计算碰撞的所有的攻击力总和
    for key, var in pairs(myBullet.crashObjTable) do
        atkCount = atkCount + var.atk
	end
    
    local num = 0
    if obj.crashObjTable == nil or #obj.crashObjTable == 0 then
    	num = 0
        myBullet.costhp = 0
    else
        num = #obj.crashObjTable
        myBullet.costhp = atkCount/num/60
    end
  
end


-- 参数：传入一个阵营
-- 功能：计算一个击杀点
function MyFightingCtrl:countKillPoint(camp,pt)
	
	local flyRole = self:getRole(camp) -- 获取对应的飞宝
     -- 击杀点类型 1：血少于50%，普通技能释放一次增加一次击杀点 2：飞宝受一次攻击，击杀点增加一点 3攻击对方飞宝一次增加一个击杀点
     -- 释放技能所需要的击杀点
    if flyRole.killPointType ==  pt  then
       if  pt == 1 then
            if flyRole.hp <= flyRole.maxHp / 2 and flyRole.mySkillIndex <= 3 then
                flyRole.killPoint = flyRole.killPoint + 1
            end
       else
            flyRole.killPoint = flyRole.killPoint + 1
       end

	end

    if flyRole.killPoint >=  flyRole.killPointValue  then
    	flyRole.killPoint = flyRole.killPointValue
    end

end

-- 参数：传入一个阵营
-- 功能：清零
function MyFightingCtrl:resetKillPoint(camp)
    local flyRole = self:getRole(camp) -- 获取对应的飞宝
    flyRole.killPoint = 0
end


-- 参数：传入一个字符型的bufferID
-- 功能：返回bufftable
function MyFightingCtrl:getBufferFromStr(str)
	local temp = stringEx:split(str,"|")
	local t = {}
    for key, var in pairs(temp) do
		t[key] = tonumber(var)
	end
	return t
end


-- 参数：buffIdTable,要被中的buff的对象
-- 功能：设置BUFF效果
function MyFightingCtrl:setObjHaveBuff(buffTable,obj)
   
    if buffTable == nil  then
         return
    end
    --1 对方目标子弹生效 trigger == 1
    --2 对方飞宝生效   trigger == 1
    --3 对方目标子弹与飞宝一起生产  trigger == 1
    --4 我方所有子弹生效 trigger == 2
    --5 我方飞宝 trigger == 2
    --6 我方子弹和飞宝 trigger == 2
    --7 自身生效 trigger == 2
--    print("造成伤害类型时候的buff")
--    dump(buffTable)
    
    for key, bid in pairs(buffTable) do
        local  buffData = FightStaticData.buffer[bid] 
        if buffData.targetType == 1 then --对方目标子弹生效
           if obj.objType ~= 1 then--1是子弹，2是飞宝，3是神将
               return
            end
        elseif buffData.targetType == 2 then --对方飞宝生效
            if obj.objType ~= 2 then--1是子弹，2是飞宝，3是神将
                return
             end
        elseif buffData.targetType == 3 then --对方目标子弹与飞宝一起生产
         
        end
        obj:setBuffer(bid)
    end


end

-- 参数：myObj:可以是有这个字段的shootBufferTable，selfBullets 发射时候的子弹，有就有，无就无
-- 功能：设置BUFF效果

function MyFightingCtrl:shootBuffer(myObj,selfBullets)
    --1 对方目标子弹生效 trigger == 1
    --2 对方飞宝生效   trigger == 1
    --3 对方目标子弹与飞宝一起生产  trigger == 1
    --4 我方所有子弹生效 trigger == 2
    --5 我方飞宝 trigger == 2
    --6 我方子弹和飞宝 trigger == 2
    --7 自身生效 trigger == 2
    local bullets = MyFightingCtrl.playerBullets
    local fibble = MyFightingCtrl.player
    if myObj.camp == MyFightingConfig.ECamp.Enemy then
        bullets = MyFightingCtrl.enemyBullets
        fibble = MyFightingCtrl.enemy
    end

    for key, var in pairs(myObj.shootBufferTable) do
        local buffData = FightStaticData.buffer[var]
        if buffData.targetType == 4 then --我方所有子弹生效
            for key, b in pairs(bullets) do
                local f = true
                for k1, b1 in pairs(selfBullets) do
                    if b1 == b then
                        f = false
                    end
                end
                if f == true then
                    b:setBuffer(buffData.id)
                end
        end
        elseif buffData.targetType == 5 then --我方飞宝
            fibble:setBuffer(buffData.id)
        elseif buffData.targetType == 6 then --我方子弹和飞宝
            fibble:setBuffer(buffData.id)
            for key, b in pairs(bullets) do
                local f = true
                for k1, b1 in pairs(selfBullets) do
                    if b1 == b then
                        f = false
                    end
                end
                if f == true then
                    b:setBuffer(buffData.id)
                end
            end
        elseif buffData.targetType == 7 then --自身生效 
            myObj:setBuffer(buffData.id)
            for k1, b1 in pairs(selfBullets) do
                myObj:setBuffer(buffData.id)
            end

        else
            cclog("发射时的类型BUFF错误，targetType=%d",buffData.targetType)
        end

    end


end


-- 参数：buffId,bufferID  myObj 我自己本身要中毒
-- 功能：中毒的效果是扣血
function MyFightingCtrl:setPoisoning(myObj,buffId)
    local  buffData = FightStaticData.buffer[buffId] 
    if buffData.buffType == 1 and myObj.isPoisoningFlag == false then
        local v = 0
        if myObj.objType == 1 then --1是子弹，2是飞宝，3是神将
            v =  buffData.buffValue1/10000
        elseif myObj.objType == 2 then
            v =   buffData.buffValue2/10000
        end
         myObj.isPoisoningFlag = true
         myObj.PoisoningValue = v
    end
end

-- 参数：buffId,bufferID  myObj 我自己本身要减速
-- 功能：速度减下来
function MyFightingCtrl:setSlowDown(myObj,buffId)
    local  buffData = FightStaticData.buffer[buffId] 
    if buffData.buffType == 2  and  myObj.isSlowDownFlag == false then
        local v = 0
        if myObj.objType == 1 then --1是子弹，2是飞宝，3是神将
            v =  buffData.buffValue1 /10000
        elseif myObj.objType == 2 then
            v = buffData.buffValue2 /10000
        end
        myObj.slowDownValue = v
        
        
    end
end

-- 参数：buffId,bufferID  myObj 我自己本身要加速
-- 功能：速度加快
function MyFightingCtrl:setSpeedUp(myObj,buffId)
    local  buffData = FightStaticData.buffer[buffId] 
    if buffData.buffType == 3 and myObj.isSpeedUpFlag == false then
        local v = 0
        if myObj.objType == 1 then --1是子弹，2是飞宝，3是神将
            v =  buffData.buffValue1 /10000
        elseif myObj.objType == 2 then
            v = buffData.buffValue2 /10000
        end
        myObj.SpeedUpValue = v
        myObj.isSpeedUpFlag = true
    end
end


-- 参数：buffid,myObj 要虚弱的对象
-- 功能：虚弱
function MyFightingCtrl:setWeak(myObj,buffId)
    local  buffData = FightStaticData.buffer[buffId]
    if buffData.buffType == 4 and myObj.isWeakFlag == false then
        local v = 0
        if myObj.objType == 1 then --1是子弹，2是飞宝，3是神将
            v =  buffData.buffValue1 /10000
        elseif myObj.objType == 2 then
            v = buffData.buffValue2 /10000
        end
        myObj.isWeakFlag = true
        myObj.atk = myObj.atk *(1-v)

    end
end

-- 参数：buffid,myObj 麻痹的对象
-- 功能：麻痹
function MyFightingCtrl:setNumb(myObj,buffId)
    local  buffData = FightStaticData.buffer[buffId]
    if buffData.buffType == 5 and myObj.isNumbFlag == false then
        local v = 0
        if myObj.objType == 1 then --1是子弹，2是飞宝，3是神将
            v =  buffData.buffValue1 /10000
        elseif myObj.objType == 2 then
            v = buffData.buffValue2 /10000
            for key, var in pairs(myObj.mySkills) do
                var.numbValue = v
            end
        end
        myObj.isNumbFlag = true

    end
    
end




return MyFightingCtrl