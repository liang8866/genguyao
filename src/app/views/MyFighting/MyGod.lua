

local MyBullet = require("app.views.MyFighting.MyBullet")
local MyFightingConfig =  require("app.views.MyFighting.MyFightingConfig")
local stringEx = require("common.stringEx")

local MyGod = class("MyGod", function()
    return cc.Node:create()
end)


function MyGod:create(camp,godId,level)

    local view = MyGod.new()
    view:init(camp,godId,level)
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            view:onEnter() 
        elseif eventType == "exit" then
            view:onExit() 
        end  
    end  
    view:registerScriptHandler(onEventHandler)
    return view
    
end

function MyGod:onCreate()

 
end

function MyGod:onEnter()

end


function MyGod:onExit()
 
end


function MyGod:init(camp,godId)

      
    self.camp = camp                                                         -- 属于那个阵营的
    self.godId = godId                                                       -- 自身的ID
    
    self.lineType = 1                                                        -- 记录是那条轨道路线
    self.objType = 3  --  2是飞宝，3是神将 1是子弹
    self.scheduleUpdate = nil -- 定时器

    self.MyGodData_Static = FightStaticData.godwill[tonumber(self.godId)]                               -- 获取神将的数据
    self.MyGodData_Serv = MyFightingCtrl:getGodInfo(godId,camp) -- 从服务器来的数据

   
    self.name = self.MyGodData_Static.name                                          -- 名字   
    self.level = self.MyGodData_Serv.level                                          -- 等级,服务器发送
    self.grade = self.MyGodData_Serv.grade                                          -- 等级,服务器发送
    self.star  = self.MyGodData_Serv.star                                           -- 等级,服务器发送
    self.godtype  =  self.MyGodData_Static.propertyType                             -- 类别，1机械，2仙 ，3妖
    self.needAngry = self.MyGodData_Static.needAngry                                -- 需要的怒气
    self.cdTime = self.MyGodData_Static.cdTime / 10000                              -- 冷却时间

    self.fireType = self.MyGodData_Static.fireType                                  -- 释放方式几弹道的，0表示直接轰对方飞宝上，1表示1弹道，2表示2弹道，3表示三弹道
    self.buffID = self.MyGodData_Static.buffID                                      -- 附带的其他效果buffer（多个的话用分隔符|连接）
    
    local SkillData = FightStaticData.flyingObjectSkill[self.MyGodData_Static.skillID]
  
    self.bufferIdTable = {}    -- 记录本技能的BuffID
    local allBufferTable =  MyFightingCtrl:getBufferFromStr(SkillData.buffID)
    self.shootBufferTable = {} -- 发射的时候要检测的BUG
    for key, var in pairs(allBufferTable) do
        local buffData = FightStaticData.buffer[var]
        if buffData.trigger == 1 then -- 碰撞或者造成伤害的时候才判断
            table.insert(self.bufferIdTable,var)
        elseif  buffData.trigger == 1 then --发射的时候检测的BUFF
            table.insert(self.shootBufferTable,var)
        end
    end
    

    --    神将血量    God_Hp  =(10*grade+hp)*(lv+3)/2 + 50*star       (字段都来自 godwill 表）
    --    神将攻击    God_Atk =((10*grade+atk)*(lv+3)/6 + 50*star/3) * hurtY/100        (字段都来自 godwill 表）
--    ADSLD2136059446
--昨天我收到短信说有个280元的电信业务缴费，然后我在网上联系客服查询，也有说是280的 缴费业务，然后客服发了缴费地址给我，我在上面用支付宝支付了，然后我到个人中心查询到 我只缴费了的是100元的业务，还差180元的费用没交到。请帮我查询下这里面是哪里不对？
    self.hp = (10*self.grade +  self.MyGodData_Static.hp)*(self.level + 3)/ 2 + 50* self.star
    self.atk = (10*self.grade +  self.MyGodData_Static.atk)*(self.level + 3)/ 6 + 50* self.star 
    self.atk =  self.atk *self.MyGodData_Static.hurtY/100
    self.hp = math.floor(self.hp)
    self.atk = math.floor(self.atk)
    self.maxHp = self.hp
     
    
    self.orignPos = cc.p(0,0)
    self.isHaveShow = false
    local SpineJson = self.MyGodData_Static.spineName..".json"
    local SpineAtlas = self.MyGodData_Static.spineName..".atlas"
    self.state = MyFightingConfig.ERoleState.Stand
    self.mySpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    self.mySpine:setAnimation(0, "load", true)
    
    self.mySpine:setPosition(0,0)
    self:addChild(self.mySpine)
    self.mySpine:setMix("load", "sAtk", 0.1) --过渡
    self.mySpine:setMix( "sAtk","load", 0.1) --过渡
    
    local SpineJson1 = "spine/gendouyun/ui_jiaodiyun.json"
    local SpineAtlas1 = "spine/gendouyun/ui_jiaodiyun.atlas"
    local gendouyun = sp.SkeletonAnimation:create(SpineJson1, SpineAtlas1, 1.0)
    gendouyun:setAnimation(0, "load", true)
    gendouyun:setPosition(0,-20)
    gendouyun:setScale(0.5)
    self:addChild(gendouyun,-1)
    
   
end

--设置位置
function MyGod:setGodPos(pos,flyObj)
    local tmpPos = pos
    local width =  300
    if flyObj then
        width = flyObj:getSize().width
    end
    self:setPosition(cc.p(tmpPos.x,tmpPos.y))
end




function MyGod:switchState(state, call)

    self.mySpine:stopAllActions()
    local  function onSpineComplete(event)
        if  event.animation == "matk" then
           
            local flyObj = MyFightingCtrl:getRole(self.camp)
            self:switchState(MyFightingConfig.ERoleState.Stand)
            --第二种
--            local  len = 80
--            local  t = 1.0
--            if self.isHaveShow == false then
--                self.orignPos = cc.p((flyObj.showGodIdx -1)*len,150)
--                flyObj.showGodIdx = flyObj.showGodIdx + 1       
--                if self.camp == MyFightingConfig.ECamp.Enemy then
--                    self.orignPos = cc.p(-(flyObj.showGodIdx -1)*len +len,150)
--                end       
--                self.isHaveShow = true  
--            end
--            local move = cc.MoveTo:create(t, self.orignPos)
--            self:runAction(move)
            
--            local function callback()
--            	self:setVisible(false)
--            end
--            local t = 0.2
--            local sca = cc.ScaleTo:create(t,1.0)
--            self:runAction(cc.Sequence:create(sca,cc.DelayTime:create(2.0),cc.CallFunc:create(callback)))
            
            
            local sca = cc.ScaleTo:create(0.3,1.0)
            local moveBy = cc.MoveBy:create(0.2,cc.p(-400,0))
            if self.camp == MyFightingConfig.ECamp.Enemy then
                moveBy = cc.MoveBy:create(0.2,cc.p(400,0))
            end
           
            self:runAction(cc.Sequence:create(sca,moveBy)) 
            
          
        end
     end
    local function onSpineEvent(event)
        if event.eventData.name == "callback" and MyFightingCtrl.gameOver == nil then

            --0子弹  0/正常 1/痕迹 2/爆炸 3/分裂  4/重生
            --1直接伤害 0/伤飞宝  1/伤敌方子弹(可选弹道)  2/伤敌方子弹及飞宝(可选弹道) 3/伤所有子弹,包括自己(可选弹道) 
            --2墙  0/起墙    直接在目标点起墙;       1/飞墙    有子弹轨迹,到达目标点后停止; 2/刺墙    墙爆炸后,同一弹道上有刺飞出去造成对方子弹伤害 
            --3盾 0/就一个盾
            --4半场 0、配置效果,进入此范围的目标,都受到效果影响,我方只受到下面BUF,敌方受到负面BUFF     
            local skillID = self.MyGodData_Static.skillID                 
            local skillData  = FightStaticData.flyingObjectSkill[skillID]
            self.skillType = skillData.skillType

            if  self.skillType == 0 then -- 子弹
                self:playFor_Bullet()
            elseif  self.skillType == 1 then -- 1直接伤害
                self:playFor_damage()
            elseif  self.skillType == 2 then -- 2墙
                self:playFor_Bullet()
            elseif  self.skillType == 3 then--3盾
                self:playFor_Bullet()
            elseif  self.skillType == 4 then --4半场
                self:playFor_Bullet()
            end
        end
    end
    -- 注册事件
    self.mySpine:registerSpineEventHandler(onSpineComplete, 2)
    self.mySpine:registerSpineEventHandler(onSpineEvent, 3)
    if state == MyFightingConfig.ERoleState.Stand then
        self.state = MyFightingConfig.ERoleState.Stand
        self.mySpine:setAnimation(0, "load", true)
    elseif state == MyFightingConfig.ERoleState.Attack then
        self.state = MyFightingConfig.ERoleState.Attack
        self.mySpine:setAnimation(0, "matk", false)
    end
    
end


function MyGod:update(dt)
 
end

--移动出来释放技能

function MyGod:releaseSkill()
    local fibble = MyFightingCtrl:getRole(self.camp)
    --第一种
--    for key, var in pairs(fibble.myGod) do
--        var:setVisible(false)
--    end
    
   --第二种
   -- self:setVisible(false)--设置不可见
    
   
    
    
    self.releaseNode = nil
    if self.camp == MyFightingConfig.ECamp.Player then
        
        local releaseNode = cc.CSLoader:createNode("res/csb/god_release_layer.csb")
        MyFightingCtrl.battleLayer:addChild(releaseNode,22)
        releaseNode:setPositionY(releaseNode:getPositionY() + (display.height - 576)/2)
        local panel =  releaseNode:getChildByName("Panel")
        panel:setContentSize(cc.size(display.width, display.height))
        local pathName = "spine/releaseSkill/god_releaseSkill"
        local SpineJson = pathName..".json"
        local SpineAtlas = pathName..".atlas"
        local aniSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        aniSpine:setAnimation(0, "load", false)
        aniSpine:setPosition(display.center)
        panel:addChild(aniSpine)
--        panel:setOpacity(50)
        
        local bigGodPath = "items/bigGod/"..tonumber(self.godId)..".png"
        local bigGod = cc.Sprite:create(bigGodPath)
--        bigGod:setPosition(-400,display.center.y)
--        panel:addChild(bigGod)
--        local act1 =cc.DelayTime:create(8/30)
--        local act2 = cc.MoveTo:create(2/30,cc.p(display.width/4*3,display.center.y))
--        local act3 = cc.MoveBy:create(40/30,cc.p(-60,0))
--        local act4 = cc.MoveBy:create(5/30,cc.p(1000,0))
        bigGod:setPosition(display.width + 400,display.center.y)
        panel:addChild(bigGod)
        local act1 =cc.DelayTime:create(8/30)
        local act2 = cc.MoveTo:create(2/30,cc.p(display.width/4*1,display.center.y))
        local act3 = cc.MoveBy:create(40/30,cc.p( 60,0))
        local act4 = cc.MoveBy:create(5/30,cc.p(-1000,0))
        bigGod:runAction(cc.Sequence:create(act1,act2,act3,act4))
        
        local  function onSpineComplete(event) --完成
            if  event.animation == "load"  then
            
                aniSpine:stopAllActions()
                local function callback1()
                    releaseNode:removeFromParent()
                    MyFightingCtrl.battleLayer.isUpDateFlag = true
                end

                local seq = cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(callback1))
                aniSpine:runAction(seq)
                
                local flyObj = MyFightingCtrl:getRole(self.camp)
                local flyObjPos = cc.p(flyObj:getPosition())
               
--                for key, var in pairs(flyObj.myGod) do
--                    var:setVisible(false)
--                end
--                self:setVisible(true)
--                local t = 0.2
--                self:runAction(cc.ScaleTo:create(t,1.5))
                
                
--                self:setVisible(true) 
--                self:setPosition(0,50)
--                self:switchState(MyFightingConfig.ERoleState.Attack)
                
                local function callback2(parameters)
                    self:switchState(MyFightingConfig.ERoleState.Attack)
                end
                local moveBy = cc.MoveBy:create(0.2,cc.p(400,0))
                local sca = cc.ScaleTo:create(0.2,1.5)
                local act = cc.Sequence:create(moveBy,cc.DelayTime:create(0.2),sca,cc.CallFunc:create(callback2))
                self:runAction(act) 
                
            end
        end
         
        -- 注册事件
        aniSpine:registerSpineEventHandler(onSpineComplete, 2)
        
    else
       
        local flyObj = MyFightingCtrl:getRole(self.camp)
        local flyObjPos = cc.p(flyObj:getPosition())

--        for key, var in pairs(flyObj.myGod) do
--            var:setVisible(false)
--        end

--        local t = 0.2
--        self:runAction(cc.ScaleTo:create(t,1.5))

--        self:setVisible(true)
--        self:setPosition(0,50)
--        self:switchState(MyFightingConfig.ERoleState.Attack)
        
        local function callback2(parameters)
            self:switchState(MyFightingConfig.ERoleState.Attack)
        end
        local moveBy = cc.MoveBy:create(0.2,cc.p(-400,0))
        local act = cc.Sequence:create(moveBy,cc.DelayTime:create(0.2),cc.CallFunc:create(callback2))
        self:runAction(act) 
        
    end

end

-- 有弹道的
function  MyGod:playFor_Bullet()
    local skillId = self.MyGodData_Static.skillID
    local Player = MyFightingCtrl:getRole(MyFightingConfig.ECamp.Player)  --获取本方的飞宝
    local Enemy = MyFightingCtrl:getTargetRole(MyFightingConfig.ECamp.Player)  --获取对方的飞宝
    local playerPos = cc.p(MyFightingCtrl.player:getPosition())
    local enemyPos = cc.p(MyFightingCtrl.enemy:getPosition())
    local shootBulletTables = {}
    local function createBullet(type)
       
        local bullet = MyBullet:create(skillId, self.camp,MyFightingConfig.BulletType.GodSkill,self)
        bullet.skillIdx = 0
        MyFightingCtrl.battleLayer:addChild(bullet)
        local orgPos = cc.p(0,0)
        local desPos = cc.p(0,0)
        if self.camp== MyFightingConfig.ECamp.Player then
            orgPos = cc.p(playerPos.x + Player.myShootPos.x,playerPos.y + Player.myShootPos.y)
            desPos = cc.p(enemyPos.x - Enemy.myShootPos.x,enemyPos.y + Enemy.myShootPos.y)
        else
            orgPos = cc.p(enemyPos.x - Enemy.myShootPos.x,enemyPos.y + Enemy.myShootPos.y)
            desPos = cc.p(playerPos.x + Player.myShootPos.x,playerPos.y + Player.myShootPos.y)
        end
        bullet:fly(orgPos,desPos, type)
        table.insert(shootBulletTables,bullet)
      
       
    end
   
    local fireType = FightStaticData.flyingObjectSkill[skillId].fireType
    if fireType == 1 then --只有一弹道
        createBullet(self.lineType) 
    elseif fireType == 2 then
        local t = {1,2,3}
        table.remove(t,self.lineType)
        local i = math.random(1,2)
        createBullet(self.lineType)
        createBullet(t[i])
    elseif fireType == 3 then
        createBullet(1)
        createBullet(2)
        createBullet(3)
    end
    
    -- buffer计算，这里是是计算发射时候的要出现的buffer
    MyFightingCtrl:shootBuffer(self,shootBulletTables)
    
end


--1直接伤害 0/伤飞宝  1/伤敌方子弹(可选弹道)  2/伤敌方子弹及飞宝(可选弹道) 3/伤所有子弹,包括自己(可选弹道) 
function MyGod:playFor_damage()
    --获取对方的飞宝
    local targetRole = MyFightingCtrl:getTargetRole(self.camp) 
    local myRole = MyFightingCtrl:getRole(self.camp) 
    local reduceHp = 0
    local def = MyFightingCtrl:getCurFightingDef(self.camp)
   
    local tempAtk = self.atk*self.MyGodData_Static.hurtX/100
    reduceHp = math.max(1,(1 - def)*tempAtk)
--    print("直接伤害",reduceHp,self.atk,self.hp,self.maxHp,def,self.MyGodData_Static.hurtX)
    
    local skillID = self.MyGodData_Static.skillID                 
    local skillData  = FightStaticData.flyingObjectSkill[skillID]
    local smallAtkType = skillData.smallSkillType
    
    self.skillStaticData = skillData
    local role = targetRole
    local rolePos = cc.p(role:getPosition())
    
    local aniSpine = nil
    local aniParticle = nil
    
    local zord = myRole:getLocalZOrder()
    myRole:setLocalZOrder(zord + 1) 
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

    -- 添加到层
    local parent = self:getParent()
    if aniSpine then
        aniSpine:setPosition(bombPos)
        targetRole:addChild(aniSpine,20)
    end
    if aniParticle then
        aniParticle:setPosition(bombPos)
        targetRole:addChild(aniParticle,20)
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
        myRole:setLocalZOrder(zord ) 
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
    
    -- 0/伤飞宝  1/伤敌方子弹(可选弹道)  2/伤敌方子弹及飞宝(可选弹道) 3/伤所有子弹,包括自己(可选弹道) 
    MyFightingCtrl:setObjHaveBuff(self.bufferIdTable,targetRole)
    if  smallAtkType == 0 then
        targetRole.hurtType = 1 --伤害类型，0表示有误，1表示普通伤害 2表示大招，3表示加血
        targetRole:updateHp(-reduceHp) --扣飞宝的血
    elseif smallAtkType == 1 then   
        MyFightingCtrl:skillDirectHurtBullet(self.bufferIdTable,self.camp,tempAtk,smallAtkType,skillData.fireType,self.lineType)
    elseif smallAtkType == 2 then
        targetRole.hurtType = 1 --伤害类型，0表示有误，1表示普通伤害 2表示大招，3表示加血
        targetRole:updateHp(-reduceHp) --扣飞宝的血
        MyFightingCtrl:skillDirectHurtBullet(self.bufferIdTable,self.camp,tempAtk,smallAtkType,skillData.fireType,self.lineType)
    elseif smallAtkType == 3 then
        MyFightingCtrl:skillDirectHurtBullet(self.bufferIdTable,self.camp,tempAtk,smallAtkType,skillData.fireType,self.lineType)
    end
    
    -- buffer计算，这里是是计算发射时候的要出现的buffer
    MyFightingCtrl:shootBuffer(self,{})
    
    
end



return MyGod