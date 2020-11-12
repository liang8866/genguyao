
local MyBullet = require("app.views.MyFighting.MyBullet")


local MyFlyRoleSkill = class("MyFlyRoleSkill")


function MyFlyRoleSkill:create(id, camp,level)

    local skill = MyFlyRoleSkill.new()
    skill:init(id, camp,level)

    return skill

end

--参数说明 技能ID，类型（你的还是对方的），图标，等级
function MyFlyRoleSkill:init(id, camp, level)

    self.level = level

    self.skillId = id   -- 技能id
    self.camp = camp    -- 阵营
              
    self.skillData = FightStaticData.flyingObjectSkill[id]
    if self.skillData == nil then
        return
    end
    
    local skillServInfo = MyFightingCtrl:getSkillInfo(id,camp)--获取服务器个的技能数据
    local fibbleStaticData = MyFightingCtrl:getCurFightingFibbleStaticInfo(camp) --获取静态数据
    local fibbleStar = MyFightingCtrl:getCurFightingFibbleStar(camp) --获取星级
    
    local bonus_SkillHp = (fibbleStar+  2)*fibbleStaticData.bonusHp/10000
    local bonus_SkillAtk = (fibbleStar+  2)*fibbleStaticData.bonusAtk/10000
    self.hp = (10*fibbleStaticData.grade + self.skillData.hp)*(skillServInfo.level + 3)/2 *(1 + bonus_SkillHp) -- Skill_Hp  =((10*grade+hp)*(lv+3)/2）*(1+技能血量加成)
    self.atk =(10*fibbleStaticData.grade + self.skillData.atk)*(skillServInfo.level + 3)/6 * (self.skillData.hurtY/100) * (1 +bonus_SkillAtk) --Skill_Atk =(10*grade+atk)*(lv+3)/6 * hurtY/100 * (1+技能攻击加成)   (字段全来自 filyingObjectSkill 表)
    self.hp = math.floor(self.hp)
    self.atk = math.floor(self.atk)
    
--    if self.camp == 1 then
--        cclog("我方skillId =%d, bonus_SkillHp =%f,bonus_SkillAtk=%f,fibbleStaticData.grade =%f,skillServInfo.level =%f,self.skillData.hp=%f,self.hp =%f,self.atk=%d",self.skillId,bonus_SkillHp,bonus_SkillAtk,fibbleStaticData.grade,skillServInfo.level,self.skillData.hp,self.hp,self.atk)
--    else
--       cclog("敌方 skillId =%d,bonus_SkillHp =%f,bonus_SkillAtk=%f,fibbleStaticData.grade =%f,skillServInfo.level =%f,self.skillData.hp=%f,self.hp =%f,self.atk=%d",self.skillId,bonus_SkillHp,bonus_SkillAtk,fibbleStaticData.grade,skillServInfo.level,self.skillData.hp,self.hp,self.atk)
--    end
    self.deltaTime = 0
    self.coolTime =  self.skillData.cdTime / 10000   -- 技能冷却时间
    
    self.bufferIdTable = {}    -- 记录本技能的BuffID
    local allBufferTable =  MyFightingCtrl:getBufferFromStr(self.skillData.buffID)
    self.shootBufferTable = {} -- 发射的时候要检测的BUG
    for key, var in pairs(allBufferTable) do
        local buffData = FightStaticData.buffer[var]
        if buffData.trigger == 1 then -- 碰撞或者造成伤害的时候才判断
            table.insert(self.bufferIdTable,var)
        elseif  buffData.trigger == 1 then --发射的时候检测的BUFF
            table.insert(self.shootBufferTable,var)
        end
    end
    
    self.numbValue = 0 --麻痹增加的CD时间
    
    
    
end

-- 技能是否可用
function MyFlyRoleSkill:canUse()
    
    if self.deltaTime < (self.coolTime + self.numbValue) then
        return false
    end

    return true
end

--定时器更新血量啥的
function MyFlyRoleSkill:update(dt)

    self.deltaTime = self.deltaTime + dt
    if self.deltaTime > (self.coolTime + self.numbValue) then
        self.deltaTime = self.coolTime + self.numbValue
    end
  

end

-- 使用技能 传人参数，表示的是第几个技能的的
function MyFlyRoleSkill:use(indx)

    self.deltaTime = 0
   
    --0子弹  0/正常 1/痕迹 2/爆炸 3/分裂  4/重生
    --1直接伤害 0/伤飞宝  1/伤敌方子弹(可选弹道)  2/伤敌方子弹及飞宝(可选弹道) 3/伤所有子弹,包括自己(可选弹道) 
    --2墙  0/起墙    直接在目标点起墙;       1/飞墙    有子弹轨迹,到达目标点后停止; 2/刺墙    墙爆炸后,同一弹道上有刺飞出去造成对方子弹伤害 
    --3盾 0/就一个盾
    --4半场 0、配置效果,进入此范围的目标,都受到效果影响,我方只受到下面BUF,敌方受到负面BUFF 
    self.skillType = self.skillData.skillType
    if  self.skillType == 0 then -- 子弹
        self:shoot(indx)
    elseif  self.skillType == 1 then -- 1直接伤害
        if indx == 4 then --大招的这个直接伤害的
            self:skillForDamageHurt(indx)
        else -- 普通技能
            
        end
       
    elseif  self.skillType == 2 then -- 2墙
        self:shoot(indx)
    elseif  self.skillType == 3 then --3盾
        self:shoot(indx)
    elseif  self.skillType == 4 then --4半场
        self:shoot(indx)
   end
    
    -- 击杀点类型 1：血少于50%，普通技能释放一次增加一次击杀点 2：飞宝受一次攻击，击杀点增加一点 3攻击对方飞宝一次增加一个击杀点
    if indx ~= 4 then --普通技能才计算
       
        local fibble = MyFightingCtrl:getRole(self.camp)
        if fibble.hp < fibble.maxHp/2 then
            MyFightingCtrl:countKillPoint(self.camp,1) --计算击杀点
        end
    end
    
  

    
end

--直接伤害的
function MyFlyRoleSkill:skillForDamageHurt(idx)
    local myRole = MyFightingCtrl:getRole(self.camp) 
  
    if myRole.myFlyRoleData.bigAtkType == 0 then --默认的处理
        myRole:bigAtkAction0()
    elseif myRole.myFlyRoleData.bigAtkType == 1  then -- 风火轮哪种
        myRole:bigAtkAction1()
       -- print("myRole.myFlyRoleData.bigAtkType=",myRole.myFlyRoleData.bigAtkType)
    elseif  myRole.myFlyRoleData.bigAtkType == 2 then --九齿逊金耙哪种  
        myRole:bigAtkAction2()
    end
    -- buffer计算，这里是是计算发射时候的要出现的buffer
    MyFightingCtrl:shootBuffer(self,{})
end


function MyFlyRoleSkill:shoot(indx)
   
    local Player = MyFightingCtrl:getRole(MyFightingConfig.ECamp.Player)  --获取本方的飞宝
    local Enemy = MyFightingCtrl:getTargetRole(MyFightingConfig.ECamp.Player)  --获取对方的飞宝
    local skillIdx = indx  --第几个技能的
    local playerPos = cc.p(MyFightingCtrl.player:getPosition())
    local enemyPos = cc.p(MyFightingCtrl.enemy:getPosition())
    
    local shootBulletTables = {}
    local function shootBullet()
        local function createBullet(type)
            local bullet = MyBullet:create(self.skillId, self.camp,MyFightingConfig.BulletType.FibbleSkill)
            bullet.skillIdx = skillIdx 
            bullet.hp = self.hp --赋值HP
            bullet.atk = self.atk--赋值HP
            bullet.maxHp = self.hp
            MyFightingCtrl.battleLayer:addChild(bullet)
            local orgPos = cc.p(0,0)
            local desPos = cc.p(0,0)
            if self.camp== MyFightingConfig.ECamp.Player then
                orgPos = cc.p(playerPos.x + Player.myShootPos.x,playerPos.y + Player.myShootPos.y)
                desPos = cc.p(enemyPos.x - Enemy.myShootPos.x,enemyPos.y + Enemy.myShootPos.y)
              
            else
               
                desPos = cc.p(playerPos.x + Player.myShootPos.x,playerPos.y + Player.myShootPos.y)
                orgPos = cc.p(enemyPos.x - Enemy.myShootPos.x,enemyPos.y + Enemy.myShootPos.y)
            end
            bullet:fly(orgPos,desPos, type)
            table.insert(shootBulletTables,bullet)
        end
        
        
        if skillIdx <= 3 then -- 普通技能
            if skillIdx == 1 then --上
                if self.skillData.fireType == 1 then --只有一弹道
                    createBullet(1)
                elseif self.skillData.fireType == 2 then
                    createBullet(1)
                    createBullet(2)
                elseif self.skillData.fireType == 3 then
                    createBullet(1)
                    createBullet(2)
                    createBullet(3)
                end
            elseif skillIdx == 2 then --中
           	   if self.skillData.fireType == 1 then --只有一弹道
                    createBullet(2)
                elseif self.skillData.fireType == 2 then
                    
                    createBullet(2)
                    local rand = math.random(1,2)
                    if rand ==1 then
                        createBullet(1)
                    else
                        createBullet(3)
                    end
                elseif self.skillData.fireType == 3 then
                    createBullet(1)
                    createBullet(2)
                    createBullet(3)
                end
            elseif skillIdx == 3 then -- 下
               if self.skillData.fireType == 1 then --只有一弹道
                    createBullet(3)
                elseif self.skillData.fireType == 2 then --2弹道
                    createBullet(3)
                    createBullet(2)
                elseif self.skillData.fireType == 3 then--3弹道
                    createBullet(1)
                    createBullet(2)
                    createBullet(3)
                end
            end

        elseif skillIdx == 4 then --特定技能1，只居中发射
            createBullet(2)
         	
        end
       
        self.deltaTime = 0
        
        -- buffer计算，这里是是计算发射时候的要出现的buffer
        MyFightingCtrl:shootBuffer(self,shootBulletTables)
        
    end

    local flyRole = MyFightingCtrl:getRole(self.camp)        -- 获取飞宝
    local tempFlySprite = flyRole.mySpine
  
    --释放技能的位置，。。。。。。。
    local sfPos = cc.p(0,0)
    if self.camp == MyFightingConfig.ECamp.Player then
        sfPos =  cc.p(playerPos.x + Player.myShootPos.x,playerPos.y + Player.myShootPos.y)

    else
        sfPos = cc.p(enemyPos.x - Enemy.myShootPos.x,enemyPos.y + Enemy.myShootPos.y)
       
    end
    --显示释放技能
    local function shifa()

        -- 是有骨骼动画的特效
        
        local SpineJson = "ui/myFighting/ui_fashe.json"
        local SpineAtlas = "ui/myFighting/ui_fashe.atlas"
        local shootSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        shootSpine:setAnimation(0, "flight", true)
        shootSpine:setPosition(sfPos) 
        MyFightingCtrl.battleLayer:addChild(shootSpine,4)
        if self.camp ~= MyFightingConfig.ECamp.Player then
            shootSpine:setRotation3D(cc.p(0,180,0))
        end
        
        local aniParticle1 = cc.ParticleSystemQuad:create("ui/myFighting/p_ui_fashe01.plist")
        aniParticle1:setPosition(0,0)
        shootSpine:addChild(aniParticle1)
        local aniParticle2 = cc.ParticleSystemQuad:create("ui/myFighting/p_ui_fashe02.plist")
        aniParticle2:setPosition(0,0)
        shootSpine:addChild(aniParticle2)
        
        local function onSpineEvent(event)--事件回调
            if event.eventData.name == "callback" and MyFightingCtrl.gameOver == nil then
                shootBullet()
            end
        end
        
        local  function onSpineComplete(event) --完成
            MyFightingCtrl:removeSpine(shootSpine)
        end

        -- 注册事件
        shootSpine:registerSpineEventHandler(onSpineComplete, 2)
        shootSpine:registerSpineEventHandler(onSpineEvent, 3)
    end

    flyRole:switchState(MyFightingConfig.ERoleState.Attack,shifa)
  
end





return MyFlyRoleSkill