

local stringEx = require("common.stringEx")
local MyBullet = class("MyBullet", cc.Node)

function MyBullet:create(skillId, camp,BulletType,god)
    local view = MyBullet.new()
    view:init(skillId, camp,BulletType,god)
    return view
end

--特效创建
function MyBullet:createEffect(name, count)
    local animation = cc.Animation:create()
    for i = 1 , count do
        local path = string.format(name, i)
        animation:addSpriteFrameWithFile(path)
    end
    animation:setDelayPerUnit(0.0833)
    animation:setRestoreOriginalFrame(true)
    return cc.RepeatForever:create(cc.Animate:create(animation))
end

--特效创建
function MyBullet:createEffectOne(name, count)
    local animation = cc.Animation:create()
    for i = 1 , count do
        local path = string.format(name,i)
        animation:addSpriteFrameWithFile(path)
    end
    animation:setDelayPerUnit(0.0833)
    animation:setRestoreOriginalFrame(true)
    return cc.Animate:create(animation)
    
end

function MyBullet:init(skillId, camp,BulletType,god)
    self.camp = camp
    self.deltaTime = 0
    self.skillStaticData = FightStaticData.flyingObjectSkill[skillId]
    self.BulletType = BulletType  -- 类型，是飞宝发射 的还是神将发射的
    if self.skillStaticData == nil then
        print("出错了。。。。")
        return
    end
    self.crashPos = cc.p(0,0)
    self.skillIdx = 1 -- 是属于哪个技能的
    self.thirdCostOtherSkillHp = 30 -- 特定技能对其他技能直接的伤害
    self.objType = 1  --  2是飞宝，3是神将 1是子弹
    self.skillType = self.skillStaticData.skillType --大类型
    self.countKeepTime = 0 -- 护盾或者墙的持续时间
    self.smallSkillType = self.skillStaticData.smallSkillType --小分类
    self.keepTime = self.skillStaticData.keepTime --持续时间
    self.inChangFlag = false -- 是否在场里面
    
    self.isEnableCollision = true  -- 是否可以碰撞,默认是可以的
    self.isUpdateFlag = true      --是否开启定时器,默认是开启
    self.isInBlast = false
    self.bufferIdTable = {}    -- 记录本技能的BuffID
    local allBufferTable =  MyFightingCtrl:getBufferFromStr(self.skillStaticData.buffID)
    self.shootBufferTable = {} -- 发射的时候要检测的BUG
    for key, var in pairs(allBufferTable) do
        local buffData = FightStaticData.buffer[var]
        if buffData.trigger == 1 then -- 碰撞或者造成伤害的时候才判断
            table.insert(self.bufferIdTable,var)
        elseif  buffData.trigger == 1 then --发射的时候检测的BUFF
            table.insert(self.shootBufferTable,var)
        end
    end

   
  
   
    if BulletType == MyFightingConfig.BulletType.FibbleSkill then
        self.hp = 0
        self.atk = 0
 
    elseif BulletType == MyFightingConfig.BulletType.GodSkill then
        self.hp = god.hp --神通本身的血量
        self.atk = god.atk-- 攻击力
        -- 赋值给技能
        self.bufferIdTable = god.bufferIdTable    -- 记录本技能的BuffID
        self.shootBufferTable = god.shootBufferTable
    end
    
    self.maxHp = self.hp
    self.costhp = 0 --每次消耗的量
    self.crashObjTable = {} -- 一开始是空的
    
   
    self.haveBuffTable = {} -- 我现在身上的BUFF有那几种类型
   
    self.isPoisoningFlag = false --  是否中毒
    self.PoisoningValue = 0 -- 中毒的值
    
    self.isSlowDownFlag = false -- 是否在减速，默认false
    self.slowDownValue  = 0

    self.isSpeedUpFlag = false --是否在加速 默认false
    self.SpeedUpValue = 0
    
    self.isWeakFlag = false --是否被虚弱了
    self.beforeWeakAtk = self.atk
    
    self.isNumbFlag    = false  -- 是否麻痹
    self.numbValue = 0.0 --麻痹要的值
    
    
    local SpineJson = self.skillStaticData.shootSpine..".json"
    local SpineAtlas = self.skillStaticData.shootSpine..".atlas"
  
    self.myView = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
  
    --0子弹  0/正常 1/痕迹 2/爆炸 3/分裂  4/重生
    --1直接伤害 0/伤飞宝  1/伤敌方子弹(可选弹道)  2/伤敌方子弹及飞宝(可选弹道) 3/伤所有子弹,包括自己(可选弹道) 
    --2墙  0/起墙    直接在目标点起墙;       1/飞墙    有子弹轨迹,到达目标点后停止; 2/刺墙    墙爆炸后,同一弹道上有刺飞出去造成对方子弹伤害 
    --3盾 0/就一个盾
    --4半场 0、配置效果,进入此范围的目标,都受到效果影响,我方只受到下面BUF,敌方受到负面BUFF 
    
    if self.skillType == 0  then
        self.myView:setAnimation(0, "flight", true)  
    
    elseif self.skillType == 2  then -- 墙的
        self.isEnableCollision = false  -- 是否可以碰撞,默认是可以的
        if self.smallSkillType == 0 then -- 直接在目标点起墙
            self.isUpdateFlag = false      --是否开启定时器，关闭
            self.myView:setAnimation(0, "start", false)
        elseif  self.smallSkillType == 1 then	--有子弹轨迹,到达目标点后停止;
            self.myView:setAnimation(0, "flight", true)    
        elseif  self.smallSkillType == 2 then  	--墙爆炸后,同一弹道上有刺飞出去造成对方子弹伤害 
        	
        end
     
    elseif  self.skillType == 3 then-- 盾的,先播放开始盾，然后盾循环，一段时间后如果没爆掉就自动爆掉
        self.isEnableCollision = false  -- 是否可以碰撞,默认是可以的
        if self.smallSkillType == 0 then -- 直接在目标点起墙
            self.isUpdateFlag = false      --是否开启定时器，关闭
            self.myView:setAnimation(0, "start", false)
        end     
    elseif self.skillType == 4 then
        self.isEnableCollision = false  -- 是否可以碰撞,默认是可以的
        self.isUpdateFlag = false      --是否开启定时器，关闭
        self.myView:setAnimation(0, "start", false)
    end
    
    self.myView:setPosition(0,0)
    self:addChild(self.myView, -1)
    self.myView.isFlippedX = false

    local function onSpineEvent(event)
       
        if event.eventData.name == "callback" and MyFightingCtrl.gameOver == nil then
            if event.animation == "start" then
                self.myView:setAnimation(0, "flight", true)  
                self.isEnableCollision = true  -- 是否可以碰撞,默认是可以的
                self.isUpdateFlag = true      -- 默认是true 
                if self.skillType == 3 then
                    self:creatHudunBar()
                end
            elseif  event.animation == "blast" then
                --删除本身
                self:deleteBulletHpbar()
                MyFightingCtrl:removeBullet(self)
                MyFightingCtrl:removeSpine(self.myView)
                MyFightingCtrl:removeSpine(self)
            end 
        end
    end
    self.myView:registerSpineEventHandler(onSpineEvent, 3)
  
  
    local isParcitle,particlePos = self:getParticle(self.skillStaticData.ParticlePos)
    if isParcitle and self.skillStaticData.shootParticle ~= "0" then
        --cclog("1 粒子效果名称 %s",self.skillStaticData.shootParticle)
        local emitter = cc.ParticleSystemQuad:create(self.skillStaticData.shootParticle..".plist")
        emitter:setPosition(particlePos)
        self.myView:addChild(emitter)
     end
    if isParcitle and self.skillStaticData.shootParticle2 ~= "0" then
        --cclog("2 粒子效果名称 %s",self.skillStaticData.shootParticle2)
        local emitter2 = cc.ParticleSystemQuad:create(self.skillStaticData.shootParticle2..".plist")
        emitter2:setPosition(particlePos)
        self.myView:addChild(emitter2)
    end
  
    self.skillhpBarNode = nil --血条
    self.crashEffectNode = nil --碰撞特效
    self.directDamageBarNode = nil -- 直接伤害的时候出现的血条
      
    self.pause = false 
    self.offsetY = 130         -- y方向偏移量 绝对值
    self.duration =  self.skillStaticData.speed / 10000  
    --添加上去
    MyFightingCtrl.bulletuid = MyFightingCtrl.bulletuid + 1
    self.uid = MyFightingCtrl.bulletuid
    MyFightingCtrl:addBullet(self)
    
    
    
end

--分割获取粒子坐标是否存在
function MyBullet:getParticle(pStr)
	local  p = cc.p(0,0)
	local  isParticle =  true
    if self.skillStaticData.shootParticle == "0" then
        isParticle =  false
        return isParticle,p
	end
    if pStr ~= "0" then
        local t = stringEx:split(pStr,"|")
        p = cc.p(tonumber(t[1]),tonumber(t[2]))
	end
    return isParticle,p
end

-- 震动
--function MyBullet:shake(node, range)
--
--    node:stopActionByTag(10086)    
--    local offset = range or 10
--    local center = cc.p(node.orignPos)
--    local l1 = cc.MoveTo:create(0.05,cc.pAdd(cc.p(math.random(-offset,offset),math.random(-offset,offset)), center))
--    local l2 = cc.MoveTo:create(0.05,cc.pAdd(cc.p(math.random(-offset,offset),math.random(-offset,offset)), center))
--    local l3 = cc.MoveTo:create(0.05,cc.pAdd(cc.p(math.random(-offset,offset),math.random(-offset,offset)), center))
--    local l4 = cc.MoveTo:create(0.05,cc.pAdd(cc.p(math.random(-offset,offset),math.random(-offset,offset)), center))
--    local l5 = cc.MoveTo:create(0.05,cc.pAdd(cc.p(math.random(-offset,offset),math.random(-offset,offset)), center))
--    local l6 = cc.MoveTo:create(0.05,cc.pAdd(cc.p(math.random(-offset,offset),math.random(-offset,offset)), center))
--    local l7 = cc.MoveTo:create(0.05, node.orignPos)
--    local seq = cc.Sequence:create(l1, l2, l3, l4, l5, l6, l7)
--    seq:setTag(10086)
--    node:runAction(seq)
--    
--end

-- 震屏
--function MyBullet:shakeScreen()
--
--    local node = cc.Director:getInstance():getRunningScene()
--    local oldPos = cc.p(node:getPosition())
--    local rightBottom = cc.MoveTo:create(0.05, cc.pAdd(oldPos,cc.p(2.5,-5)))
--    local rightTop = cc.MoveTo:create(0.05, cc.pAdd(oldPos, cc.p(5, 5)))
--    local back = cc.MoveTo:create(0.05,cc.p(0,0))
--    local seq = cc.Sequence:create(rightBottom, rightTop, back)
--    node:runAction(seq)
--    
--end

function MyBullet:dealloc()

    if self.hp>0 then
        local role = MyFightingCtrl:getTargetRole(self.camp)
        local rolePos = cc.p(role:getPosition())
        
        local  reduceHp = -self.atk
        local def = MyFightingCtrl:getCurFightingDef(self.camp)
        reduceHp = math.max(1,math.ceil(self.atk * self.hp /self.maxHp))*(1 - def)*self.skillStaticData.hurtX/100
        role.hurtType = 1 --伤害类型，0表示有误，1表示普通伤害 2表示大招，3表示加血
        role:updateHp(-reduceHp)
        
        -- 设置buff到飞宝上
        MyFightingCtrl:setObjHaveBuff(self.bufferIdTable,role)
       
        local aniSpine = nil
        local aniParticle = nil
        -- 是有骨骼动画的特效
        if self.skillStaticData.bombEffect ~= "0" then
            local SpineJson = self.skillStaticData.bombEffect..".json"
            local SpineAtlas = self.skillStaticData.bombEffect..".atlas"
            aniSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
            aniSpine:setAnimation(0, "blast", false)
            aniSpine:setPosition(0,0)
     
        end
        --是有粒子的特效
        if self.skillStaticData.bombEffectParticle ~= "0" then
             aniParticle = cc.ParticleSystemQuad:create(self.skillStaticData.shootParticle2..".plist")
        end
         
         -- 获取位置
        local bombPos = cc.p(0,0)
        if self.camp == MyFightingConfig.ECamp.Player then
            bombPos = cc.p(rolePos.x - role.myBoombPos.x,rolePos.y + role.myBoombPos.y)
        else
            bombPos = cc.p(rolePos.x + role.myBoombPos.x,rolePos.y + role.myBoombPos.y)
        end
        -- 添加到层
        local parent = self:getParent()
        if aniSpine then
            aniSpine:setPosition(bombPos)
            parent:addChild(aniSpine,20)
        end
        if aniParticle then
            aniParticle:setPosition(bombPos)
            parent:addChild(aniParticle,20)
        end
        if self.camp == MyFightingConfig.ECamp.Enemy then
            if aniSpine then
                aniSpine:setRotation3D(cc.p(0,180,0))
            end
            if aniParticle then
                aniParticle:setRotation3D(cc.p(0,180,0))
            end
        end
        --最后删除
        local  function onSpineComplete(event)
            if  event.animation == "blast" then
                if aniSpine then
                    MyFightingCtrl:removeSpine(aniSpine)
                end
                if aniParticle then
                    aniParticle:removeFromParent()
                end
            end
        end
        -- 结尾
        if aniSpine then
            aniSpine:registerSpineEventHandler(onSpineComplete, 2)
        end
    end
  
    self:deleteBulletHpbar()
    if self.skillType == 2 or self.skillType == 3 or self.skillType == 4 then 
        if  self.isInBlast == false then
            self.myView:setAnimation(0, "blast", false)
            self.isInBlast = true
        end
    else
        --删除本身
        MyFightingCtrl:removeBullet(self)
        self:removeFromParent()
    end
    
end


-- 掉血冒数字
function MyBullet:showReduceHpNum(num)
    local pngPath = "fnt/pu.fnt"

    local str = tostring(math.floor(num))
    local label = cc.Label:createWithBMFont(pngPath, str)
    label:setAnchorPoint(cc.p(0.5,0.5))
    label:setPosition(0,0)
    self:addChild(label)

    local act1 = cc.MoveBy:create(1.0,cc.p(0,80))   
    local act3 = cc.FadeOut:create(0.5)
    local function callback()
        label:removeFromParent()
    end
    label:setString(math.floor(num))
    local seq = cc.Sequence:create(act1,act3,cc.CallFunc:create(callback))
    label:runAction(seq)


end


-- 创建直接伤害的血条
function MyBullet:createDirectDamageBar()
  

    if self.skillhpBarNode == nil and self.skillType ~= 3 and  self.directDamageBarNode == nil then
        self.directDamageBarNode =  cc.CSLoader:createNode("csb/skill_bar.csb")
        self.directDamageBarNode:setPosition(0,0)
        if  self.myView.isFlippedX  then
            self.directDamageBarNode:setPosition(0,0)
        end
       
        self:addChild(self.directDamageBarNode,3) 

        local bar =  self.directDamageBarNode:getChildByName("skill_hp_bar")
        local bar1 =  self.directDamageBarNode:getChildByName("skill_hp_bar_1")
        bar:setVisible(true)
        bar1:setVisible(true)
        if self.camp == MyFightingConfig.ECamp.Player then
            self.hpBar = bar
            bar1:setVisible(false)
        else
            self.hpBar = bar1
            bar:setVisible(false)
        end
         
         --延迟删除
         local function callback()
            if self.directDamageBarNode then
                self.directDamageBarNode:removeFromParent()
                self.directDamageBarNode = nil
                print("删除 self.directDamageBarNode")
            end
         end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(callback))) 
         
    end
    
    
end


function MyBullet:creatHudunBar()
    if self.skillhpBarNode == nil and self.skillType == 3 then
        local myfibble = MyFightingCtrl:getRole(self.camp)
       
        self.skillhpBarNode =  cc.CSLoader:createNode("csb/skill_bar.csb")
        self.skillhpBarNode:setPosition(0,60)
        if  self.myView.isFlippedX  then
            self.skillhpBarNode:setPosition(0,60)
        end
        
        self.myView:addChild(self.skillhpBarNode,3) 
        self.hpBar =  self.skillhpBarNode:getChildByName("skill_hp_bar")
        local bar =  self.skillhpBarNode:getChildByName("skill_hp_bar")
        local bar1 =  self.skillhpBarNode:getChildByName("skill_hp_bar_1")
        bar:setVisible(true)
        bar1:setVisible(true)
        if self.camp == MyFightingConfig.ECamp.Player then
        	self.hpBar = bar
        	bar1:setVisible(false)
        else
            self.hpBar = bar1
            bar:setVisible(false)
        end
        
        self.hpbarImagebg =  self.skillhpBarNode:getChildByName("Image_bg") 

    end
end
--创建血条
function MyBullet:createBulletHpbar()
     
     -- 删除
    if self.directDamageBarNode then
        self.directDamageBarNode:removeFromParent()
        self.directDamageBarNode = nil
    end
    if self.skillhpBarNode == nil and self.skillType ~= 4 then
        self.skillhpBarNode =  cc.CSLoader:createNode("csb/skill_bar.csb")
        self.skillhpBarNode:setPosition(self.crashPos.x  - 1,self.crashPos.y)
        if  self.myView.isFlippedX  then
            self.skillhpBarNode:setPosition(self.crashPos.x  + 1,self.crashPos.y)
        end
        local parent = self:getParent()
        parent:addChild(self.skillhpBarNode,3) 
     
        local bar =  self.skillhpBarNode:getChildByName("skill_hp_bar")
        local bar1 =  self.skillhpBarNode:getChildByName("skill_hp_bar_1")
        bar:setVisible(true)
        bar1:setVisible(true)
        if self.camp == MyFightingConfig.ECamp.Player then
            self.hpBar = bar
            bar1:setVisible(false)
        else
            self.hpBar = bar1
            bar:setVisible(false)
        end
        
        self.hpbarImagebg =  self.skillhpBarNode:getChildByName("Image_bg") 
        
	end
    --显示碰撞动画
    if self.skillType ~= 4 and  self.inChangFlag == false then --场的话不显示
        self:createCrashEffect()
    end
    
end
--删除血条
function MyBullet:deleteBulletHpbar()
    if self.skillhpBarNode and self.skillType ~= 3 then
         self.skillhpBarNode:removeFromParent()
         self.skillhpBarNode = nil
    end
    --删除碰撞动画
    self:deleteCrashEffect()
end

function MyBullet:createCrashEffect()
    if  self.crashEffectNode == nil and self.camp== MyFightingConfig.ECamp.Player then
         
        -- 是有骨骼动画的特效
        local parent = self:getParent()
        local SpineJson = "ui/myFighting/ui_duichongbaozha.json"
        local SpineAtlas = "ui/myFighting/ui_duichongbaozha.atlas"
        self.crashEffectNode = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        self.crashEffectNode:setAnimation(0, "flight", true)
           
        local aniParticle = cc.ParticleSystemQuad:create("ui/myFighting/p_ui_duichongbaozha01.plist")
        parent:addChild(self.crashEffectNode,2)
        self.crashEffectNode:addChild(aniParticle)
        self.crashEffectNode:setPosition(self.crashPos)  
        aniParticle:setPosition(0,0)
       
    end
end

--删除血条
function MyBullet:deleteCrashEffect()
    if self.crashEffectNode then
        self.crashEffectNode:removeFromParent()
        self.crashEffectNode = nil
    end
end

function MyBullet:fly(orign, desition, type)    
    if self.scheduleHandler then
        return
    end
    
    self.orign = orign
    self.desition = desition
    self.type = type
    self.deltaTime = 0
    self.myView:setAnchorPoint(cc.p(1, 0.5))
    if desition.x < orign.x then
        self.myView.isFlippedX = true
        self.myView:setRotation3D(cc.p(0,180,0))
        self.myView:setAnchorPoint(cc.p(0, 0.5))
    end
    self:setPosition(self.orign)
   
    
    if self.skillType == 2 and self.smallSkillType == 0 then --设置位置  0/起墙    直接在目标点起墙;       1/飞墙    有子弹轨迹,到达目标点后停止; 2/刺墙    墙爆炸后,同一弹道上有刺飞出去造成对方子弹伤害 
         local p = 0.3
    	 local distance = self.desition.x - self.orign.x
         local x = self.orign.x + distance * p
         local y = 0
         if self.type==1 then -- 上
             y = self.orign.y + math.sin(p*math.pi) * self.offsetY
         elseif self.type==2 then -- 中
             y = self.orign.y
         elseif self.type==3 then -- 下
             y = self.orign.y - math.sin(p*math.pi) * self.offsetY
         end
         self:setPosition(x, y)
    end
   
    if self.skillType == 3 then -- 盾
         local  myFibble = MyFightingCtrl:getRole(self.camp)
        self:setPosition(cc.p(myFibble:getPosition()))
    end
    if self.skillType == 4 then --场
        local  myFibble = MyFightingCtrl:getRole(self.camp)
        self:setPosition(cc.p(myFibble:getPosition()))
    end
   
   
 
   
end

-- 定时器更新
function MyBullet:update(dt)
    
    if self.isUpdateFlag == false then --是否更新
    	return
    end
    
    if self.directDamageBarNode and self.hpBar then  
     
        self.hpBar:setPercent( (self.hp / self.maxHp) * 100)
    end
    
    -- 检测buff数据
    self:checkBuffer()
    
    --0子弹  0/正常 1/痕迹 2/爆炸 3/分裂  4/重生
    --1直接伤害 0/伤飞宝  1/伤敌方子弹(可选弹道)  2/伤敌方子弹及飞宝(可选弹道) 3/伤所有子弹,包括自己(可选弹道) 
    --2墙  0/起墙    直接在目标点起墙;       1/飞墙    有子弹轨迹,到达目标点后停止; 2/刺墙    墙爆炸后,同一弹道上有刺飞出去造成对方子弹伤害 
    --3盾 0/就一个盾
    --4半场 0、配置效果,进入此范围的目标,都受到效果影响,我方只受到下面BUF,敌方受到负面BUFF 
    if self.hp<=0 then
        self:dealloc()
        return
    end
    
    if  self.isPoisoningFlag ==  true then --中毒的
        self.hp = self.hp - self.PoisoningValue
    end
    
--    if self.skillType == 3 and self.hpBar then -- 护盾的 单独处理
--        self.hpBar:setPercent( (self.hp / self.maxHp) * 100)
--    end
    
    if self.pause  then
        if self.pauseY == nil then
            self.pauseY = self.myView:getPositionY()
        end
        if (self.skillType ~= 2 or self.skillType ~= 3 or self.skillType ~= 4) and  self.inChangFlag  ~= true then -- 这个是墙的那种类型,盾，场
            self.myView:setPositionY(self.pauseY+math.random(-5,5))
        end
        self.hp = self.hp - self.costhp 
        
        self:createBulletHpbar()--创建血条
        if self.hpBar then
            self.hpBar:setPercent( (self.hp / self.maxHp) * 100)
            self.skillhpBarNode:setPosition(self.crashPos.x  - 3.5,self.crashPos.y)
            if  self.myView.isFlippedX  then
                self.skillhpBarNode:setPosition(self.crashPos.x  + 3.5,self.crashPos.y)
            end
        end
        
        if  self.inChangFlag == false  then -- 是否在场里面
            return
        end
        
    else
        self:deleteBulletHpbar()--删除血条
    end
    

    self.deltaTime = self.deltaTime + dt * (1.0 +  self.SpeedUpValue +  self.slowDownValue + self.numbValue)
    local percent = self.deltaTime/self.duration -- 走了多少百分比了
    
    if self.skillType == 2 then --  墙类型的判断
        self.countKeepTime =  self.countKeepTime + dt --计算时间
        if self.countKeepTime >= self.keepTime/10000 then --到了持续时间直接删除
           
            self:deleteBulletHpbar()
            if  self.isInBlast == false then
                self.myView:setAnimation(0, "blast", false)
                self.isInBlast = true
               
            end
            
         end
        if self.smallSkillType == 0 then --直接返回，停住
              return
        elseif self.smallSkillType == 1 then--走一小段停住	
             if percent >= 0.25 then --只走一会儿就暂停下来
                 return
             end
         end
    elseif  self.skillType == 3 then --盾的话不走轨道
        self.countKeepTime =  self.countKeepTime + dt --计算时间
        self:createBulletHpbar()--创建血条
        if self.countKeepTime >= self.keepTime/10000 then --到了持续时间直接删除
            self:deleteBulletHpbar()
            if  self.isInBlast == false then
                self.myView:setAnimation(0, "blast", false)
                self.isInBlast = true
              
            end
        
        end
        return
    elseif  self.skillType == 4 then --场
        self.countKeepTime =  self.countKeepTime + dt --计算时间
        if self.countKeepTime >= self.keepTime/10000 then --到了持续时间直接删除
            self:deleteBulletHpbar()
            if  self.isInBlast == false then
                self.myView:setAnimation(0, "blast", false)
                self.isInBlast = true
            end
           
        end
        return     
    else -- 不是墙的类型的话，到了终点删除
        if percent>=1  then
            self:dealloc()
        end
    end
    
    --按轨道更新位置
    if self.type==1 then     -- 上路
        self:top(percent)    
    elseif self.type==2 then -- 中路
        self:middle(percent)
    elseif self.type==3 then -- 下路
        self:bottom(percent) 
    end
    
   
    
end

function MyBullet:top(dt)
    
    local distance = self.desition.x - self.orign.x
    local x = self.orign.x + distance * dt
    local y = self.orign.y + math.sin(dt*math.pi) * self.offsetY
    self:setPosition(x, y)
    local cosValue = nil
    if distance>0 then
        cosValue = math.cos((1-dt) * math.pi)
    else
        cosValue = math.cos(dt * math.pi)
    end
    local degree = math.deg(math.atan(cosValue))
    degree = degree * self.offsetY/math.abs(distance)*math.pi
    self.myView:setRotation(degree)
    
end

function MyBullet:middle(dt)
    local distance = self.desition.x - self.orign.x
    self:setPosition(self.orign.x + distance * dt, self.orign.y)
end

function MyBullet:bottom(dt)
    local distance = self.desition.x - self.orign.x
    local x = self.orign.x + distance * dt
    local y = self.orign.y - math.sin(dt*math.pi) * self.offsetY
    self:setPosition(x, y)
    local cosValue = nil
    if distance>0 then
        cosValue = math.cos(dt * math.pi)
    else
        cosValue = math.cos((1-dt) * math.pi)
    end
    local degree = math.deg(math.atan(cosValue))
    degree = degree * self.offsetY/math.abs(distance)*math.pi
    self.myView:setRotation(degree)
   
end
	
--设置buff 效果到身上	
function MyBullet:setBufferAnimation(buffId)
	local buffdata =  FightStaticData.buffer[buffId]
    if buffdata ==nil then
 		return
 	end
    if buffdata.targetType == 2  then -- 11 子弹生效 2 飞宝生效 3 子弹与飞宝一起生产
        return
    end
 	
    local aniSpine = nil
    local aniParticle = nil
    local aniParticle2 = nil
    -- 是有骨骼动画的特效
    if buffdata.bulletSpine ~= "" then
        local SpineJson = FightStaticData.Path[tonumber(buffdata.bulletSpine)].path..".json"
        local SpineAtlas =  FightStaticData.Path[tonumber(buffdata.bulletSpine)].path..".atlas"
        aniSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        aniSpine:setAnimation(0, "blast", true)
        aniSpine:setPosition(0,0)

    end
    --是有粒子的特效
    if buffdata.bulletParticle ~= "" then
       local path = FightStaticData.Path[tonumber(buffdata.bulletParticle)].path..".plist"
        aniParticle = cc.ParticleSystemQuad:create(path)

    end
    
    if buffdata.bulletParticle2 ~= "" then
        local path = FightStaticData.Path[tonumber(buffdata.bulletParticle2)].path..".plist"
        aniParticle2 = cc.ParticleSystemQuad:create(path)

    end
 
    -- 获取位置
    local bombPos = cc.p(0,0)
    -- 添加到层

    if aniSpine then
        aniSpine:setPosition(bombPos)
        self.myView:addChild(aniSpine,2)
    end
    if aniParticle then
        
        local pos =  stringEx:split(buffdata.bulletParticlePos1,"|")
        if buffdata.bulletParticlePos1 == "" then
        	pos = {0,0}
        end
        
        aniParticle:setPosition(cc.p(tonumber(pos[1]),tonumber(pos[2])) )
        self.myView:addChild(aniParticle,2)
    end
    if aniParticle2 then
        local pos =  stringEx:split(buffdata.bulletParticlePos2,"|")
        if buffdata.bulletParticlePos2 == "" then
            pos = {0,0}
        end
        aniParticle2:setPosition(cc.p(tonumber(pos[1]),tonumber(pos[2])) )
        self.myView:addChild(aniParticle2,2)
        
    end
    
    if self.camp == MyFightingConfig.ECamp.Enemy then
        if aniSpine then
            aniSpine:setRotation3D(cc.p(0,180,0))
        end
        if aniParticle then
            aniParticle:setRotation3D(cc.p(0,180,0))
        end
        if aniParticle2 then
            aniParticle2:setRotation3D(cc.p(0,180,0))
        end
    end
	
	-- 记录buff ID
    table.insert(self.haveBuffTable,buffdata.id)
   -- print(1,self.skillStaticData.id,buffId)
    local function callback()
        if aniSpine then
            MyFightingCtrl:removeSpine(aniSpine)
        end
        if aniParticle then
            aniParticle:removeFromParent()
        end
        --print(2,self.skillStaticData.id,buffId)
        if aniParticle2 then
            aniParticle2:removeFromParent()
        end
        
        -- 删除记录的BUFFID
        for key, var in pairs(self.haveBuffTable) do
            if var == buffdata.id then
                table.remove(self.haveBuffTable,key)
            end
        end     
        
        if buffdata.buffType == 1 then
             self.isPoisoningFlag = false --  是否中毒
             self.PoisoningValue = 0 -- 中毒的值
        elseif buffdata.buffType == 2 then --减速
            self.isSlowDownFlag = false
             self.slowDownValue = 0
        elseif buffdata.buffType == 3 then --加速
            self.isSpeedUpFlag = false
             self.SpeedUpValue = 0
        elseif buffdata.buffType == 4  then -- 虚弱，飞宝是没虚弱的
            self.isWeakFlag = false
            self.atk =  self.beforeWeakAtk   
        elseif buffdata.buffType == 5  then -- 麻痹
            self.numbValue = 0  
            self.isNumbFlag = false 
        end
    end
    local t = buffdata.buffKeepTime1/10000

    local seq = cc.Sequence:create(cc.DelayTime:create(t),cc.CallFunc:create(callback))
	self:runAction(seq)
	
end	
	
--传入一个buffer ID ，判断是否需要增加这个buffer效果
function MyBullet:setBuffer(buffId)
    local buffData = FightStaticData.buffer[buffId]
    local flag = false
    for key, var in pairs(self.haveBuffTable) do
        local bd = FightStaticData.buffer[var]
        if bd.buffType == buffData.buffType then
            flag = true
            break
        end
    end
    if flag == false then
        self:setBufferAnimation(buffId) -- 设置特效
    else
        return
    end
end

-- 检查BUFF,update里面调用
function MyBullet:checkBuffer()
    for key, buffId in pairs(self.haveBuffTable) do
        local buffData = FightStaticData.buffer[buffId]
        if buffData.buffType == 1 then --中毒
            MyFightingCtrl:setPoisoning(self,buffId)
        elseif buffData.buffType == 2 then--减速
            MyFightingCtrl:setSlowDown(self,buffId)
        elseif buffData.buffType == 3 then--加速
            MyFightingCtrl:setSpeedUp(self,buffId)
        elseif buffData.buffType == 4 then --虚弱
            MyFightingCtrl:setWeak(self,buffId)
        elseif buffData.buffType == 5 then --麻痹，，子弹的话 要减速
            MyFightingCtrl:setNumb(self,buffId)    
        end
    end 

end

	
return MyBullet