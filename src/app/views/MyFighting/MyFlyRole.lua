
local MyFlyRole = class("MyFlyRole", require("app.views.View"))
local stringEx = require("common.stringEx")

local MyFightingConfig =  require("app.views.MyFighting.MyFightingConfig")

local MyGod = require("app.views.MyFighting.MyGod")
local MyFlyRoleSkill = require("app.views.MyFighting.MyFlyRoleSkill")
local MySkillHand = require("app.views.MyFighting.MySkillHand")

function MyFlyRole:create(camp, id)
    local view = MyFlyRole.new()
    view:init(camp, id)
    return view
end

function MyFlyRole:onCreate()

  
    
end

--进入
function MyFlyRole:onEnter()

end

--退出
function MyFlyRole:onExit()
--    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("Armature/td_boss_02.ExportJson")
  
end

function MyFlyRole:init(camp, id)
    print(camp,id)
    self.countUpHp = 0
    self.camp = MyFightingConfig.ECamp.Player                                -- 角色阵营
    self.id = 1                                                              -- 角色id
    self.countEnemyGodTime = 0
    self.mySkills = {}                                                       -- 技能列表
    self.mySkillIndex = 1                                                    -- 当前技能索引
    self.objType = 2  -- 1是子弹 2是飞宝，3是神将 
    self.isReleaseBigSkill = false   --是否在释放大招
    self.maxTime = math.random(50,100)/80

    self.coutSkillTime = 0
    self.myGod  = {}                                                         -- 现在上场的神将列表
    self.showGodIdx = 0 -- 出现的神将的第几个了   
    self.angryCount = 0                                                      -- 计算有多少怒气了
    self.camp = camp                                                         -- 阵营
    self.id = id       
    self.myFlyRoleData = FightStaticData.flyingObject[id]                    -- 获取对应的数据
    self.name = self.myFlyRoleData.name                                      -- 名字   
    self.level = UserData.BaseInfo.userLevel                                 -- 等级,服务器发送
    if self.camp ~= MyFightingConfig.ECamp.Player then
        self.level = MyFightingCtrl.enemyFibbleLevel
         
    end
    -- buff类型变量
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
  
    self.hurtType = 0 --伤害类型，0表示有误，1表示普通伤害 2表示大招，3表示加血
    
    if self.camp == MyFightingConfig.ECamp.Player then
        self.star  = UserData.Fibble.fibbleTable[id][1].byStar                   -- 星 服务器发送
    else
       self.star =  MyFightingCtrl.enemyFibbleStar	 --飞宝的星级
    end
  
    self.type  = self.myFlyRoleData.type                                     -- 类别，1机械，2仙 ，3妖
    self.grade = self.myFlyRoleData.grade                                    -- 品阶
    local killPointTable = stringEx:split(self.myFlyRoleData.killPoint,"-")  --分割
    self.killPoint = 0 --击杀点
  
    self.killPointType = tonumber(killPointTable[1])  -- 击杀点类型 1：血少于50%，普通技能释放一次增加一次击杀点 2：飞宝受一次攻击，击杀点增加一点 3飞宝攻击一次增加一个击杀点
    self.killPointValue = tonumber(killPointTable[2]) -- 释放技能所需要的击杀点

   
    --flyingObject_Hp =(10*grade+hp)*(lv+3) + 100*star
    self.hp = (10*self.grade+self.myFlyRoleData.hp)*(self.level+3) + 100 *self.star
    self.hp = math.floor(self.hp)
    self.maxHp = self.hp                                                     -- 最大血量，用于计算显示的血条      
    self.mechDef = (self.star + 2)*self.myFlyRoleData.bonusMechDef / 10000 -- 机械防御
    self.fairyDef = (self.star + 2)*self.myFlyRoleData.bonusFairyDef / 10000     -- 仙攻击
    self.demonDef = (self.star + 2)*self.myFlyRoleData.bonusDemonDef / 10000         -- 妖防御
    local getSize =  self:getPosForStr(self.myFlyRoleData.size)
    self.mySize = cc.rect(0,0,getSize.x,getSize.y)
    self.myShootPos = self:getPosForStr(self.myFlyRoleData.shootPos)
    self.myBoombPos = self:getPosForStr(self.myFlyRoleData.boombPos)
    local skillTable = MyFightingCtrl.mySkillTable
    if self.camp ~= MyFightingConfig.ECamp.Player then
        skillTable = MyFightingCtrl.enemySkillTable
--        cclog("敌方的飞宝ID =%d",UserData.BaseInfo.enemyFlyID)
--        cclog(" 对方 self.level=%d * self.grade=%d *self.star=%d *self.myFlyRoleData.hp=%d",self.level,self.grade,self.star,self.myFlyRoleData.hp)
--        print("对方hp=",self.hp)  
--          self.maxTime = 5
    else
--        cclog("我方的飞宝ID =%d",UserData.BaseInfo.nFibbleId)   
--        cclog(" 我方 self.level=%d * self.grade=%d *self.star=%d *self.myFlyRoleData.hp=%d",self.level,self.grade,self.star,self.myFlyRoleData.hp)
--       print("我方hp=",self.hp)
      
    end
    
   
    self.skillsMaxCount = #skillTable    
    
                                            -- 技能的数目
    for k, t in pairs(skillTable) do
       
        self.mySkills[k] = MyFlyRoleSkill:create(t.id, camp, t.level)
        
    end
    self.fourthSkillData = FightStaticData.flyingObjectSkill[skillTable[4].id] --第四个技能的skillData
    
    -- 创建人物本身动画  
    local SpineJson = self.myFlyRoleData.mSpineName..".json"
    local SpineAtlas = self.myFlyRoleData.mSpineName..".atlas"
    
    self.mySpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    self.mySpine:setAnimation(0, "load", true)
    self.state      = MyFightingConfig.ERoleState.Stand                      -- 一开始是load 状态的
    self.mySpine:setPosition(0,0)
    self:addChild(self.mySpine,-1)
    self.mySpine:setMix("load", "atk1", 0.1) -- 过渡
    self.mySpine:setMix("load", "atk2", 0.1) -- 过渡
     if self.camp == MyFightingConfig.ECamp.Player then
        self.mySpine:setScaleY(1.00)
        self.hpBar = MyFightingCtrl.battleLayer.LoadingBar_1
        self.epNum = MyFightingCtrl.battleLayer.leftNum
        --self.hpText = MyFightingCtrl.battleLayer.left_textHp
    else
        self.hpBar = MyFightingCtrl.battleLayer.LoadingBar_2
        --self.epNum = MyFightingCtrl.battleLayer.rightNum
        --self.hpText = MyFightingCtrl.battleLayer.right_textHp
        self.mySpine:setRotation3D(cc.p(0,180,0))
    end
    --self.hpText:setString(string.format("%d/%d", self.hp,self.maxHp))
    --获取坐标
    self.posTable = {}
    for i =1, 5 do
        local keys = string.format("pos%d",i)
        self.posTable[i] = self:getPosForStr(self.myFlyRoleData[keys])
    end
    --创建神将 和UI 上的神将图标
    local godTable = UserData.BaseInfo.myGodTable
    if camp == MyFightingConfig.ECamp.Enemy then
        godTable = UserData.BaseInfo.enemyGodTable
     
    end
    local len = 103
    local startX = display.center.x - 2* len  - len/2
    local numGod = #godTable
    if numGod%2 == 0 then --双数
        startX = display.center.x - math.floor(numGod/2)* len + 30
    else -- 单数
        startX = display.center.x - math.floor(numGod/2)* len - len/2 + 30
    end
    self.skillHandTable = {}
    for i=1, #godTable do
        local godData = godTable[i]
        local gID = godData.id

        local god =  MyGod:create(self.camp,gID) 
        self:addChild(god,2)
        god:setAnchorPoint(cc.p(0.5,0.5))
        --god:setGodPos(self.posTable[i])
        god:setGodPos(cc.p(0,50))
        self.myGod[i] = god    
        god:setVisible(true)
        god:setGodPos(cc.p(-400,50))
        if self.camp ~= MyFightingConfig.ECamp.Player then
            god:setRotation3D(cc.p(0,180,0))
            god:setGodPos(cc.p(400,50))
        end
        local skillHand = MySkillHand:create(gID, MyFightingCtrl.battleLayer.battlePathNode,self.camp)
        skillHand.godIdx = i
        local posX = startX + (i - 1) * len
        skillHand:setPosition(posX,0) 
       
        skillHand.GodId = gID -- 记录神将的ID
        self.skillHandTable[i] = skillHand --记录起来
        MyFightingCtrl.battleLayer:addChild(skillHand,10)
        if  self.camp ~= MyFightingConfig.ECamp.Player then --是本身才创建
            skillHand:setPosition(startX + (i - 1) * len,-400)
        end
    end
    
   --开始出场啦
    local function callback1()
        self:setMoveOut() 
    end
    local seq = cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(callback1))
    self:runAction(seq)

    --飞宝上下浮动
    self:floatingUpDown()
    
end

--返回 坐标
function MyFlyRole:getPosForStr(posStr)
    local t = stringEx:split(posStr,"|")
    local p = cc.p(tonumber(t[1]),tonumber(t[2]))
   
    return p
end

function MyFlyRole:setMoveOut()
    MyFightingCtrl.battleLayer.isCountTimeFlag = false
    MyFightingCtrl.battleLayer.isUpDateFlag = false
     
--    local size = self.mySpine:getBoundingBox()
    local size = self.mySize
    self.mySpine:setPosition(0,0)
    self.mySpine:setAnchorPoint(cc.p(0.5,0.5))
    --设置坐标的
    local tmpPos = cc.p(- size.width/2,display.height / 5*2.6) --打斗时候的坐标
    if self.camp == MyFightingConfig.ECamp.Player then --我方飞宝  
        tmpPos = cc.p(size.width/2,tmpPos.y)
        self:setPosition(cc.p(-size.width,tmpPos.y))
--        cclog(" 我方 tmpPos.x= %d,size.width=%d,display.width=%d",tmpPos.x,size.width,display.width)
    else -- 敌方飞宝
        tmpPos = cc.p(display.width-size.width/2,tmpPos.y )
        self:setPosition(cc.p(display.width + size.width,tmpPos.y))
--        cclog(" 敌方 tmpPos.x= %d",tmpPos.x)
    end
    self.myShootPos = cc.p(self.myShootPos.x,0)
    self.myBoombPos = cc.p(self.myBoombPos.x,0)
    
    local function callback1() --此时出现VS2个字
        if self.camp == MyFightingConfig.ECamp.Player then

              self:vsAnimation()
        end
    end
    
    local function callback2()
        if self.camp == MyFightingConfig.ECamp.Player then
            MyFightingCtrl.battleLayer:removeChildByTag(10086)
        end
    end
    local function callback3()
    
        if self.camp == MyFightingConfig.ECamp.Player then
            MyFightingCtrl.battleLayer.isCountTimeFlag = true
            MyFightingCtrl.battleLayer.isUpDateFlag = true
        end
        
        -----  以下为新手指引1代码
        

        --------以上是新手指引1代码
        local myFightingLayer = self:getParent()
        
        if self.camp == MyFightingConfig.ECamp.Player then
            if UserData.BaseInfo.myFightTaskId == UserData.NewHandLead.GuideList.Fighting_1.TaskID then -- 新手指引1
                self.isLead = false
                MyFightingCtrl.battleLayer.isUpDateFlag = false
                for i = 1, #self.skillHandTable do
                    self.skillHandTable[i]:setVisible(false)
                end
                ManagerTask.SectionId = UserData.NewHandLead.GuideList.Fighting_1.step[1].PlotSectionID
                local PlotLayer = require("app.views.Plot.PlotLayer")
                PlotLayer:initPlotEnterAntExit(0)
                local layer = PlotLayer:create(nil, nil, function() MyFightingCtrl.battleLayer.isUpDateFlag = true end)
                myFightingLayer:addChild(layer, 31)
            end
            
         --去掉唐僧阿三的开始战斗对话
            if UserData.BaseInfo.myFightTaskId == UserData.NewHandLead.GuideList.Fighting_2.TaskID then 
                if UserData.NewHandLead:getGuideState("Fighting_2") == 0 and 
                    UserData.NewHandLead.GuideList.Fighting_2.step[1] ~= nil and 
                    UserData.NewHandLead.GuideList.Fighting_2.step[1].PlotSectionID ~= nil then
                    local function plotCallBack_1()
                         MyFightingCtrl.battleLayer.isUpDateFlag = true
                    end
                    
                    MyFightingCtrl.battleLayer.isUpDateFlag = false
                    ManagerTask.SectionId = UserData.NewHandLead.GuideList.Fighting_2.step[1].PlotSectionID
                    local PlotLayer = require("app.views.Plot.PlotLayer")
                    PlotLayer:initPlotEnterAntExit(0)
                    local layer = PlotLayer:create(nil, nil, plotCallBack_1)
                    myFightingLayer:addChild(layer, 31)
                end
            end
            if UserData.BaseInfo.myFightTaskId == UserData.NewHandLead.GuideList.FightingWithGodwill.TaskID then 
                if UserData.NewHandLead:getGuideState("FightingWithGodwill") == 0 and 
                    UserData.NewHandLead.GuideList.FightingWithGodwill.step[1] ~= nil and 
                    UserData.NewHandLead.GuideList.FightingWithGodwill.step[1].PlotSectionID ~= nil then
                    local function plotCallBack_1()
                        MyFightingCtrl.battleLayer.isUpDateFlag = true
                        MyFightingCtrl.guideGodID = UserData.NewHandLead.GuideList.FightingWithGodwill.GodID
                    end
    
                    MyFightingCtrl.battleLayer.isUpDateFlag = false
                    ManagerTask.SectionId = UserData.NewHandLead.GuideList.FightingWithGodwill.step[1].PlotSectionID
                    local PlotLayer = require("app.views.Plot.PlotLayer")
                    PlotLayer:initPlotEnterAntExit(0)
                    local layer = PlotLayer:create(nil, nil, plotCallBack_1)
                    myFightingLayer:addChild(layer, 31)
                end
            end
        end
        
        self:switchState(MyFightingConfig.ERoleState.Stand)
    end
    
    local action1 = cc.MoveTo:create(1.0,tmpPos)
    local delay = cc.DelayTime:create(1.5)
    local seq = cc.Sequence:create(action1,cc.CallFunc:create(callback1),delay,cc.CallFunc:create(callback2),cc.CallFunc:create(callback3))
    self:runAction(seq)
    self:switchState(MyFightingConfig.ERoleState.Run)
end

--vs开场动画
function MyFlyRole:vsAnimation()
    local rootVsNode = cc.CSLoader:createNode("csb/battle_vs_Layer.csb")
    MyFightingCtrl.battleLayer:addChild(rootVsNode,10)
  
   -- rootVsNode:setPositionY(rootVsNode:getPositionY() + (display.height - 576)/4)
    rootVsNode:setTag(10086)
    local panel =  rootVsNode:getChildByName("Panel_1")  --Panel1
   
    --panel:setContentSize(cc.size(display.width, display.height))
    panel:setPositionY(display.center.y)
    local left_tiao =  panel:getChildByName("left_tiao")
    local right_tiao = panel:getChildByName("right_tiao")
    local zi_v = panel:getChildByName("zi_v")
    local zi_s = panel:getChildByName("zi_s")
    local leftHead = left_tiao:getChildByName("image")
    local rightHead = right_tiao:getChildByName("image")
    

    if UserData.BaseInfo.userSex == 1 then --1 男 2女
        leftHead:loadTexture("items/vsIcon/VS_Boy.png")
    else
       leftHead:loadTexture("items/vsIcon/VS_Girl.png")
    end
 
    if  UserData.BaseInfo.NPCId ~= nil  and  UserData.BaseInfo.NPCId ~= 0 and StaticData.Npc[UserData.BaseInfo.NPCId] ~= nil and StaticData.Npc[UserData.BaseInfo.NPCId].FightHead ~= 0 then
        local img = StaticData.Npc[UserData.BaseInfo.NPCId].FightHead
        
        rightHead:loadTexture("items/vsIcon/"..img)
    
    end

    local vslight = panel:getChildByName("vslight")
    vslight:setOpacity(0)
    local panelSize = panel:getContentSize()
    vslight:setPositionY(panelSize.height/10*6)
   -- vslight:setPositionY(vslight:getPositionY() + 40)
    local t1 = 0.25
    local t2 = 0.4
    local t3 = 0.6
    local t4 = 0.25
    local fadeInTime = t1 + t2
    -- vslight渐变出现
    local fedeIn = cc.FadeIn:create(fadeInTime)
    local fadeOut = cc.FadeOut:create(t2)
    vslight:runAction(cc.Sequence:create(fedeIn,fadeOut))
    -- 移动
    local function myMoveAction(t,pos)
    	return cc.MoveBy:create(t,pos)
    end
    local w = display.width/2 - 60 
    local len = 10
    local len1 = 5
    
    local tiao1Move1 = myMoveAction(t1,cc.p(w,0))
    local tiao1Move2 = myMoveAction(t2,cc.p(len,0))
    local tiao1Move3 = myMoveAction(t3,cc.p(100,0))
    local tiao1Move4 = myMoveAction(t4,cc.p(300,0))
    local tiao1fadeOut = cc.FadeOut:create(t4)
    local tiao1Spaw = cc.Spawn:create(tiao1Move4,tiao1fadeOut)
    
    local tiao2Move1 = myMoveAction(t1,cc.p(-w,0))
    local tiao2Move2 = myMoveAction(t2,cc.p(-len,0))
    local tiao2Move3 = myMoveAction(t3,cc.p(-100,0))
    local tiao2Move4 = myMoveAction(t4,cc.p(-300,0))
    local tiao2fadeOut = cc.FadeOut:create(t4)
    local tiao2Spaw = cc.Spawn:create(tiao2Move4,tiao2fadeOut)
    
    local vMove1 =  myMoveAction(t1,cc.p(w,0))
    local vMove2 = myMoveAction(t2,cc.p(len,0))
    local vMove3 = myMoveAction(t3,cc.p(len1,0))
    local vMove4 = myMoveAction(t4,cc.p(len1,0))
    local vfadeOut = cc.FadeOut:create(t4)
    local vSpaw = cc.Spawn:create(vMove4,vfadeOut)
    
    
    local sMove1 =  myMoveAction(t1,cc.p(-w,0))
    local sMove2 = myMoveAction(t2,cc.p(-len,0))
    local sMove3 = myMoveAction(t3,cc.p(-len1,0))
    local sMove4 = myMoveAction(t4,cc.p(-len1,0))
    local sfadeOut = cc.FadeOut:create(t4)
    local sSpaw = cc.Spawn:create(sMove4,sfadeOut)
    
    left_tiao:runAction(tiao1Move1)
    right_tiao:runAction(tiao2Move1)
    zi_v:runAction(vMove1)
    zi_s:runAction(sMove1)
    
    local function callback1()
        local copyV= cc.Sprite:create("ui/VsAnimation/V.png")
        copyV:setPosition(cc.p(zi_v:getPosition()))
        panel:addChild(copyV,10)
        local  sca = cc.ScaleTo:create(t2,2.0)
        local  fo = cc.FadeTo:create(t2,0)
        copyV:runAction(cc.Spawn:create(sca,fo))
    end 
    local function callback2()
        local copyS= cc.Sprite:create("ui/VsAnimation/S.png")
        copyS:setPosition(cc.p(zi_s:getPosition()))
        panel:addChild(copyS,10)
        local  sca = cc.ScaleTo:create(t2,2.0)
        local  fo = cc.FadeTo:create(t2,0)
        copyS:runAction(cc.Spawn:create(sca,fo))
    end
    
    left_tiao:runAction(cc.Sequence:create(tiao1Move1,tiao1Move2,tiao1Move3,tiao1Spaw))
    right_tiao:runAction(cc.Sequence:create(tiao2Move1,tiao2Move2,tiao2Move3,tiao2Spaw))
    
    zi_v:runAction(cc.Sequence:create(vMove1,cc.CallFunc:create(callback1),vMove2,vMove3,vSpaw))
    zi_s:runAction(cc.Sequence:create(sMove1,cc.CallFunc:create(callback2),sMove2,sMove3,sSpaw))
    

    
end




function MyFlyRole:update(dt)
    if self.hp <= 0 then
    	return
    end
    
    
    
    if self.camp == MyFightingConfig.ECamp.Player and self.angryCount == 3 and self.isLead == false and UserData.BaseInfo.myFightTaskId == 510001 then
        self.isLead = true
        local myFightingLayer = self:getParent()
        self.fightingLead = nil
    
        local function plotCallBack_3()

            myFightingLayer.battlePathNode:setVisible(false)
            MyFightingCtrl.battleLayer.isUpDateFlag = true
        end

        local function plotCallBack_2()     -- 点击动作
            local child = self.fightingLead.Node_pointToSprite:getChildByTag(1)
            local delayTime_1 = cc.DelayTime:create(1)
            local callFunc_1 = cc.CallFunc:create(function() 
                child:setAnimation(0, "load_1", true)
            end)
            local moveTo_1 = cc.MoveTo:create(0.5, cc.p(self.fightingLead.userData.step[3].pos_2.x + 40, self.fightingLead.userData.step[3].pos_2.y - 40))
            local seq_1 = cc.Sequence:create(delayTime_1, callFunc_1, moveTo_1)

            local delayTime_2 = cc.DelayTime:create(1)
            local callFunc_2 = cc.CallFunc:create(function() 
                child:setAnimation(0, "click", true)
            end)
            local spaw_1 = cc.Spawn:create(delayTime_2, callFunc_2)

            local callFunc_3 = cc.CallFunc:create(function() 
                child:setAnimation(0, "load_1", true)
            end)
            local moveTo_3 = cc.MoveTo:create(0.5, cc.p(self.fightingLead.userData.step[4].pos_3.x + 40, self.fightingLead.userData.step[4].pos_3.y - 40))
            local seq_2 = cc.Sequence:create(spaw_1, callFunc_3, moveTo_3)

            local delayTime_4 = cc.DelayTime:create(1)
            local callFunc_4 = cc.CallFunc:create(function() 
                child:setAnimation(0, "click", true)
            end)
            local spaw_2 = cc.Spawn:create(delayTime_4, callFunc_4)

            local callFunc_5 = cc.CallFunc:create(function() 
                self.fightingLead:setVisible(false)
                child:setAnimation(0, "load_1", true)
                plotCallBack_3()
            end)
            local seq_3 = cc.Sequence:create(spaw_2, callFunc_5)

            local seqAll = cc.Sequence:create(seq_1, seq_2, seq_3)
            self.fightingLead.Node_pointToSprite:runAction(seqAll)
        end

        MyFightingCtrl.battleLayer.isUpDateFlag = false
        myFightingLayer.battlePathNode:setVisible(true)
        ManagerTask.SectionId = UserData.NewHandLead.GuideList.Fighting_1.step[2].PlotSectionID
        local PlotLayer = require("app.views.Plot.PlotLayer")
        PlotLayer:initPlotEnterAntExit(0)
        local layer = PlotLayer:create(nil, nil, plotCallBack_2)
        myFightingLayer:addChild(layer, 51)

        self.fightingLead = require("app.views.NewHandLead.NewHandLeadLayer"):create(UserData.NewHandLead.GuideList.Fighting_1)
        myFightingLayer:addChild(self.fightingLead, 52)
    end
    
    if self.camp == MyFightingConfig.ECamp.Player and self.angryCount == 6 and self.useSkill == nil and UserData.BaseInfo.myFightTaskId == 510001 then     -- 新手指引
        self.useSkill = true
        MyFightingCtrl.battleLayer.isUpDateFlag = false
        
        local myFightingLayer = self:getParent()
        
        local function plotCallBack_1()
            for i = 1, #self.skillHandTable do
                self.skillHandTable[i]:setVisible(true)
            end
            self.fightingLead.Node_pointToSprite:setPosition(UserData.NewHandLead.GuideList.Fighting_1.step[5].pos_1)
            self.fightingLead:setVisible(true)
            self.fightingLead:setTag(1)
            myFightingLayer.battlePathNode:setVisible(true)
            
            local moveTo = cc.MoveTo:create(1, UserData.NewHandLead.GuideList.Fighting_1.step[5].pos_2)
            local place = cc.Place:create(UserData.NewHandLead.GuideList.Fighting_1.step[5].pos_1) 
            local seq = cc.Sequence:create(moveTo, place)
            local rep = cc.RepeatForever:create(seq)
            self.fightingLead.Node_pointToSprite:runAction(rep)
        end

        ManagerTask.SectionId = UserData.NewHandLead.GuideList.Fighting_1.step[4].PlotSectionID
        local PlotLayer = require("app.views.Plot.PlotLayer")
        PlotLayer:initPlotEnterAntExit(0)
        local layer = PlotLayer:create(nil, nil, plotCallBack_1)
        myFightingLayer:addChild(layer, 31)
        
    end
    
    
    
    if  self.isPoisoningFlag ==  true then --中毒的
        self.hp = self.hp - self.PoisoningValue
    end
    
   --设置血量 UI最上面那最大的
    local hpPercent = self.hpBar:getPercent()
    local target = self.hp/self.maxHp*100
    self.hpBar:setPercent(hpPercent + (target-hpPercent) * dt * 5 )
    --self.hpText:setString(string.format("%d/%d", self.hp,self.maxHp))
    if self.epNum ~= nil then
        self.epNum:setString(tostring(self.angryCount))
    end
    
    local skill = nil
    if self.mySkillIndex ~= 4 then
        skill = self.mySkills[self.mySkillIndex]
    end

    if skill==nil then
        return
    end
    skill:update(dt)
    self:autoReleaseGodSkillForEnemy() --敌人自动释放神将技能
    if skill:canUse()  then
        skill:use(self.mySkillIndex) 
        if self.mySkillIndex <= 3 then
            self.angryCount = self.angryCount + 1 --怒气 +1
        end
       
        if  self.angryCount >  20 then  --我设置最多只能三个
        	self.angryCount = 20 
        end
        
        self.mySkillIndex = self.mySkillIndex + 1
        if self.camp == MyFightingConfig.ECamp.Player then
           
        end
        if self.mySkillIndex >  (self.skillsMaxCount - 1 ) then
            self.mySkillIndex = 1
        end
    end 
  
    self.coutSkillTime = self.coutSkillTime + dt
    if  self.coutSkillTime >= self.maxTime then
        self.coutSkillTime = 0
        self:autoReleaseBigSkill() --自动释放大招
    end
   
end

-- 掉血冒数字
function MyFlyRole:showReduceHpNum(t,num)
    local pngPath = "fnt/pu.fnt"
    if t == 1 then --普通的伤害
        pngPath = "fnt/pu.fnt"
    elseif t == 2 then	--大招伤害 
        pngPath = "fnt/big.fnt"
    elseif t == 3 then  --加血的值
        pngPath = "fnt/big.fnt"
    end
    
    self.countUpHp = self.countUpHp + 1
    local pos = cc.p(self:getPosition())
    local x = (self.countUpHp%3)*40 + pos.x
    local y = 60 +(self.countUpHp%2)*20 + pos.y
    if self.camp == MyFightingConfig.ECamp.Enemy then
        x = -(self.countUpHp%3)*40 + pos.x
    end
    local str = tostring(math.floor(num))
    local label = cc.Label:createWithBMFont(pngPath, str)
    label:setAnchorPoint(cc.p(0.5,0.5))
    label:setPosition(x,y)
    MyFightingCtrl.battleLayer:addChild(label)
   
    local act1 = cc.MoveBy:create(0.5,cc.p(0,100))   
    local act2 = cc.DelayTime:create(1.0)
    local act3 = cc.FadeOut:create(0.5)
    local function callback()
        label:removeFromParent()
    end
    label:setString(math.floor(num))
    local seq = cc.Sequence:create(act1,act2,act3,cc.CallFunc:create(callback))
    label:runAction(seq)
   
    
end

--更新血量
function MyFlyRole:updateHp(hp)
    if hp==nil or hp==0 then
        return
    end
    
    hp = math.floor(hp)
   
    if hp <= 0 then
        -- 击杀点类型 1：血少于50%，普通技能释放一次增加一次击杀点 2：飞宝受一次攻击，击杀点增加一点 3攻击对方飞宝一次增加一个击杀点
        MyFightingCtrl:countKillPoint(self.camp,2)
        if self.camp == MyFightingConfig.ECamp.Enemy then
            MyFightingCtrl:countKillPoint(MyFightingConfig.ECamp.Enemy,3)
        else
            MyFightingCtrl:countKillPoint(MyFightingConfig.ECamp.Player,3)
        end
    end
 
   
    local resHp = 0 - hp --变成正的
 
    local bullets = MyFightingCtrl.playerBullets
    if self.camp == MyFightingConfig.ECamp.Enemy then
        bullets = MyFightingCtrl.enemyBullets
    end
    for key, var in pairs(bullets) do
        if var.skillType == 3 then
            resHp = var.hp - resHp
          
            if resHp <= 0  then -- 说明还有血没搞完
                var.hp = 0
            else
                var.hp = resHp
                resHp = 0
            end
          
       end
    end
    

   
    
    self.hp = self.hp - resHp
   -- self.hurtType = 0 --伤害类型，0表示有误，1表示普通伤害 2表示大招，3表示加血
    if resHp > 0  then
        self:showReduceHpNum(self.hurtType,resHp)
    end
   
    
    if self.hp<=0 then
        self.hp = 0 
    end
    
    if self.hp>self.maxHp then
        self.hp = self.maxHp
    end
end

-- 切换人物动作状态
function MyFlyRole:switchState(state, call)
    if self.state  == MyFightingConfig.ERoleState.Attack  then --如果还在战斗状态，retur掉
    	return 
    end
--   self.mySpine:stopAllActions()
    local function onSpineEvent(event)--事件回调
        if event.eventData.name == "callback" and MyFightingCtrl.gameOver == nil then
            if call  then
                call()
            end
        end
      
    end
    local  function onSpineComplete(event) --完成
        if  event.animation == "atk1" or event.animation == "atk2" then
            self.state      = MyFightingConfig.ERoleState.Stand 
        end
        self:switchState(MyFightingConfig.ERoleState.Stand) --结束后切换到站立动作
    end

    -- 注册事件
    self.mySpine:registerSpineEventHandler(onSpineComplete, 2)
    self.mySpine:registerSpineEventHandler(onSpineEvent, 3)

    if state == MyFightingConfig.ERoleState.Stand then 
        self.mySpine:setAnimation(0, "load", true)
        self.state      = MyFightingConfig.ERoleState.Stand 
    elseif state== MyFightingConfig.ERoleState.Attack then  
       
        if   self.mySkillIndex <= 3 then --普通攻击
            self.mySpine:setAnimation(0, "atk1", false)
            self.state      = MyFightingConfig.ERoleState.Attack 
        elseif  self.mySkillIndex == 4 then  -- 大招攻击
            self.mySpine:setAnimation(0, "atk2", false)
            self.state      = MyFightingConfig.ERoleState.Attack 
        end
    end


end

--上下震动的
function MyFlyRole:floatingUpDown()

	local t = 0.4
	local h = 5
	local move1 = cc.MoveBy:create(t,cc.p(0,h))
    local move2 = cc.MoveBy:create(t,cc.p(0,-h))
    local move3 = cc.MoveBy:create(t,cc.p(0,-h))
    local move4 = cc.MoveBy:create(t,cc.p(0,h))
    local seq = cc.Sequence:create(move1,move2,move3,move4)
    self:runAction(cc.RepeatForever:create(seq))
	
end

--设置爆炸
function MyFlyRole:setFlyRoleBomnb(callback)
    local SpineJson = "spine/effect/baozha_tongyong"..".json"
    local SpineAtlas = "spine/effect/baozha_tongyong"..".atlas"

    local tmpSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    tmpSpine:setAnimation(0, "death", false)
    tmpSpine:setPosition(cc.p(0,-20))
    self.mySpine:addChild(tmpSpine,1)
    tmpSpine:addAnimation(0, "death", false, 1)
    local  function onSpineComplete(event)  

    end
    -- 注册事件
    tmpSpine:registerSpineEventHandler(onSpineComplete, 2)

    local function finish()
        if callback then
            callback()
        end
        MyFightingCtrl.battleLayer.isUpDateFlag = false
        MyFightingCtrl:removeSpine(tmpSpine)
    end
    --后移下
    local move = nil
    local t = 2.0
    if self.camp == MyFightingConfig.ECamp.Player then
        move = cc.MoveBy:create(t,cc.p(-400,0))
    else
        move = cc.MoveBy:create(t,cc.p(400,0))
    end
    self:runAction(cc.Sequence:create(move,cc.CallFunc:create(finish)))

end


-- 释放敌方神将技能的
function MyFlyRole:autoReleaseGodSkillForEnemy()
	if self.camp == MyFightingConfig.ECamp.Player or #self.myGod <= 0 then
		return
	end
    if self.countEnemyGodTime >= 2 then -- 三秒计算一次是否满足条件
        if  self.angryCount >= 1 then
            local len = #self.myGod
            local randIdx = math.random(1,len)
            local god = self.myGod[randIdx] -- 获取神将
            if god.needAngry <= self.angryCount   then --要满足条件
                local skillHand = self.skillHandTable[randIdx]
                if skillHand.myCountTime >= skillHand.cdTime then
                    skillHand.myCountTime = 0 --从新计算
                    self.angryCount = self.angryCount - god.needAngry--消耗了点怒气
                    god.lineType =  math.random(1,3) -- 随机一路线
                    god:releaseSkill() --释放技能
                end
                
            end
        end
        self.countEnemyGodTime = 0
    else
        self.countEnemyGodTime = self.countEnemyGodTime + 1/60  
	end

end


--自动释放大招的技能的
function MyFlyRole:autoReleaseBigSkill()
    local targetFibble = MyFightingCtrl:getTargetRole(self.camp)
    if targetFibble.isReleaseBigSkill == true or self.isReleaseBigSkill == true then --不可以同时释放
        return
    end
   if self.killPoint >= self.killPointValue and self.state  == MyFightingConfig.ERoleState.Stand  and self.isReleaseBigSkill == false then  -- 如果检测到击杀点达到要求了
       
        self.isReleaseBigSkill = true
        self.killPoint = 0
        local idx = self.mySkillIndex
        self.mySkillIndex = 4
   
        local skill = self.mySkills[self.mySkillIndex]
        self.mySpine:stopAllActions()
        skill:use(self.mySkillIndex)
        -- 在上面update自动使用
        local function delatCb()
            self.isReleaseBigSkill = false
            self.mySkillIndex = idx
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),cc.CallFunc:create(delatCb)))
        
   end
    -- 延迟对方的技能施放
   

end

--大招的判断是否有特效
function MyFlyRole:bigDamageBombCallback()

    local targetFibble = MyFightingCtrl:getTargetRole(self.camp)
    local targetFibblePos = cc.p(targetFibble:getPosition())
    
    local aniSpine = nil
    local aniParticle = nil
    -- 是有骨骼动画的特效
    if self.fourthSkillData.bombEffect ~= "0" then
        local SpineJson = self.fourthSkillData.bombEffect..".json"
        local SpineAtlas = self.fourthSkillData.bombEffect..".atlas"
        
        aniSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        aniSpine:setAnimation(0, "blast", false)
        aniSpine:setPosition(0,0)
    end
    
    --是有粒子的特效
    if self.fourthSkillData.bombEffectParticle ~= "0" then
        aniParticle = cc.ParticleSystemQuad:create(self.fourthSkillData.bombEffectParticle..".plist")
    end

    -- 获取位置
    local bombPos = cc.p(0,0)
    if self.camp == MyFightingConfig.ECamp.Player then
        bombPos = cc.p(targetFibblePos.x - targetFibble.myBoombPos.x,targetFibblePos.y + targetFibble.myBoombPos.y)
    else
        bombPos = cc.p(targetFibblePos.x + targetFibble.myBoombPos.x,targetFibblePos.y + targetFibble.myBoombPos.y)
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

-- 直接伤害的计算
function MyFlyRole:damageHurtDiffCount()
    local smallAtkType = self.fourthSkillData.smallSkillType
    local fireType = self.fourthSkillData.fireType
    local targetFibble = MyFightingCtrl:getTargetRole(self.camp)
    local def = MyFightingCtrl:getCurFightingDef(self.camp)
    local skill = self.mySkills[4]
    MyFightingCtrl:setObjHaveBuff(skill.bufferIdTable,targetFibble)
    local tempAtk = skill.atk *self.fourthSkillData.hurtX/100
    local reduceHp = math.max(1,(1 - def)*tempAtk)
    -- 0/伤飞宝  1/伤敌方子弹(可选弹道)  2/伤敌方子弹及飞宝(可选弹道) 3/伤所有子弹,包括自己(可选弹道) 
    if  smallAtkType == 0 then
        targetFibble.hurtType = 2 --伤害类型，0表示有误，1表示普通伤害 2表示大招，3表示加血
        targetFibble:updateHp(-reduceHp) --扣血
    elseif smallAtkType == 1 then   
        MyFightingCtrl:skillDirectHurtBullet(skill.bufferIdTable, self.camp,tempAtk,smallAtkType,fireType,math.random(1,3))
    elseif smallAtkType == 2 then
        targetFibble.hurtType = 2 --伤害类型，0表示有误，1表示普通伤害 2表示大招，3表示加血
        targetFibble:updateHp(-reduceHp) --扣血
        MyFightingCtrl:skillDirectHurtBullet(skill.bufferIdTable,self.camp,tempAtk,smallAtkType,fireType,math.random(1,3))
    elseif smallAtkType == 3 then
        
        MyFightingCtrl:skillDirectHurtBullet(skill.bufferIdTable,self.camp,tempAtk,smallAtkType,fireType,math.random(1,3))
    end
end

-- --默认的处理
function MyFlyRole:bigAtkAction0()

    local  skillId = self.fourthSkillData.id   --技能ID
    local targetRole = MyFightingCtrl:getTargetRole(self.camp)
    local zord = targetRole:getLocalZOrder()
    self:setLocalZOrder(zord + 1) 
    if zord <=0 then
        zord = 1
    end
    local function callback()
        -- 显示爆炸
       self:setLocalZOrder(zord - 1) 
       self:bigDamageBombCallback()
       self:damageHurtDiffCount(skillId)

    end
    self.state  = MyFightingConfig.ERoleState.Stand
    self:switchState(MyFightingConfig.ERoleState.Attack,callback) --播放飞宝大招效果显示
end

-- 风火轮哪种
function MyFlyRole:bigAtkAction1()
	local targetRole = MyFightingCtrl:getTargetRole(self.camp)
    local myPosX = self:getPositionX()
    local targetPosX = targetRole:getPositionX()
    local t1 = 0.5
    local t2 = 0.2
    local offx = 50
    if self.camp == MyFightingConfig.ECamp.Enemy then
    	offx = -50
    end
  
    local move1 = cc.MoveBy:create(t1,cc.p(targetPosX - myPosX,0))
    local moveBy1 = cc.MoveBy:create(t2,cc.p(-offx,0))
    local moveBy2 = cc.MoveBy:create(t2,cc.p(offx,0))
    local moveBy3 = cc.MoveBy:create(t2,cc.p(-offx,0))
    local moveBy4 = cc.MoveBy:create(t2,cc.p(offx,0))
    local move2 = cc.MoveTo:create(t1 ,cc.p(0,0))
    local zord = targetRole:getLocalZOrder()
    if zord <=0 then
        zord = 1
    end
    self:setLocalZOrder(zord + 1) 
   
    local function callback()
        
      
        self:setLocalZOrder(zord - 1) 
        -- 显示爆炸
        self:bigDamageBombCallback()
        self:damageHurtDiffCount()
    end
    local seq =cc.Sequence:create(move1,moveBy1,moveBy2,moveBy3,moveBy4,move2)
    self.mySpine:runAction(seq)
    self.state  = MyFightingConfig.ERoleState.Stand
    self:switchState(MyFightingConfig.ERoleState.Attack,callback)
    
end
--九齿逊金耙哪种 
function MyFlyRole:bigAtkAction2()
    local targetRole = MyFightingCtrl:getTargetRole(self.camp)
    local myPosX = self:getPositionX()
    local targetPosX = targetRole:getPositionX()
    local offsetX = targetPosX - myPosX
    local len = -100
    if self.camp == MyFightingConfig.ECamp.Enemy then
        len = 100
    end
    self.mySpine:setPositionX(offsetX + len)
    local zord = targetRole:getLocalZOrder()
    if zord <=0 then
        zord = 1
    end
    self:setLocalZOrder(zord + 1) 
   
    local function callback()
       
        self.mySpine:setPosition(0,0)
        self:setLocalZOrder(zord - 1) 
        -- 显示爆炸
        self:bigDamageBombCallback()
        self:damageHurtDiffCount()
      
    end
    
    self.state  = MyFightingConfig.ERoleState.Stand
    self:switchState(MyFightingConfig.ERoleState.Attack,callback) --结束后切换到站立动作
    
    
end


--设置buff 效果到身上  
function MyFlyRole:setBufferAnimation(buffId)
    local buffdata =  FightStaticData.buffer[buffId]
    if buffdata == nil then
    	return
    end
    
    if buffdata.targetType == 1  then -- 11 子弹生效 2 飞宝生效 3 子弹与飞宝一起生产
    	return
    end
    
    
    local aniSpine = nil
    local aniParticle = nil
    local aniParticle2 = nil
    -- 是有骨骼动画的特效
    if buffdata.fibbleSpine ~= "" then
        local SpineJson = FightStaticData.Path[tonumber(buffdata.fibbleSpine)].path..".json"
        local SpineAtlas =  FightStaticData.Path[tonumber(buffdata.fibbleSpine)].path..".atlas"
        aniSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        aniSpine:setAnimation(0, "blast", true)
        aniSpine:setPosition(0,0)
    end
    --是有粒子的特效
    if buffdata.fibbleParticle ~= "" then
        
        aniParticle = cc.ParticleSystemQuad:create(FightStaticData.Path[tonumber(buffdata.fibbleParticle)].path..".plist")
    end
    if buffdata.fibbleParticle2 ~= "" then
        aniParticle2 = cc.ParticleSystemQuad:create(FightStaticData.Path[tonumber(buffdata.fibbleParticle2)].path..".plist")
    end
    -- 获取位置
    local bombPos = cc.p(0,0)
    -- 添加到层
    
    if aniSpine then
        aniSpine:setPosition(bombPos)
        self:addChild(aniSpine,20)
    end
    if aniParticle then
        local pos =  stringEx:split(buffdata.fibbleParticlePos1,"|")
        if buffdata.fibbleParticlePos1 == "" then
            pos = {0,0}
        end
        aniParticle:setPosition(cc.p(tonumber(pos[1]),tonumber(pos[2])) )
        self:addChild(aniParticle,20)
    end
    if aniParticle2 then
        local pos =  stringEx:split(buffdata.fibbleParticlePos2,"|")
        if buffdata.fibbleParticlePos2 == "" then
            pos = {0,0}
        end
        
        aniParticle2:setPosition(cc.p(tonumber(pos[1]),tonumber(pos[2])) )
        self:addChild(aniParticle2,20)
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
    table.insert(self.haveBuffTable,buffId)
    
    local function callback()
        if aniSpine then
            MyFightingCtrl:removeSpine(aniSpine)
        end
        if aniParticle then
            aniParticle:removeFromParent()
        end
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
        
        elseif buffdata.buffType == 5  then -- 麻痹
            self.isNumbFlag    = false  -- 是否麻痹  
            for key, var in pairs(self.mySkills) do
                var.numbValue = 0
            end
        end
    end
    
    local seq = cc.Sequence:create(cc.DelayTime:create(buffdata.buffKeepTime2/10000),cc.CallFunc:create(callback))
    self:runAction(seq)

end 

--传入一个buffer ID ，判断是否需要增加这个buffer效果
function MyFlyRole:setBuffer(buffId)
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
    end
    
end


-- 检查BUFF
function MyFlyRole:checkBuffer()
    for key, buffId in pairs(self.haveBuffTable) do
        local buffData = FightStaticData.buffer[buffId]
        if buffData.buffType == 1 then --中毒
            MyFightingCtrl:setPoisoning(self,buffId)
        elseif buffData.buffType == 2 then--减速
            MyFightingCtrl:setSlowDown(self,buffId)
        elseif buffData.buffType == 3 then--加速
            MyFightingCtrl:setSpeedUp(self,buffId)
        elseif buffData.buffType == 4 then--虚弱 ，飞宝没有被虚弱的可能
              
        elseif buffData.buffType == 5 then--麻痹，飞宝和子弹有 飞宝的话是设置CD冷却，子弹是减速
          
    	end
    end	
end



return MyFlyRole