local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local TimeFormat = require("common.TimeFormat")
local FlyFunction = require("app.views.FlyTechTree.FlyFunction")
local FlyMakeMatLayer = require("app.views.public.FlyMakeMatLayer")
local goodsNode = require("app.views.public.goodsNode")

--制造或者炼制
local FlyRefiningLayer = class("FlyRefiningLayer", function()
    return cc.Layer:create()
end)

function FlyRefiningLayer:create(flyTechId, isMake)
    local view = FlyRefiningLayer.new()
    view:init(flyTechId, isMake)
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

function FlyRefiningLayer:ctor()

end

function FlyRefiningLayer:onEnter()

    EventMgr:registListener(EventType.OnFibbleUp, self, self.onFibbleUp) 
    EventMgr:registListener(EventType.OnCreateFibble, self, self.onCreateFibble) 
end

function FlyRefiningLayer:onExit()
    EventMgr:unregistListener(EventType.OnFibbleUp, self, self.onFibbleUp) 
    EventMgr:unregistListener(EventType.OnCreateFibble, self, self.onCreateFibble) 
end



--初始化
function FlyRefiningLayer:init(flyTechId, isMake)

    local flyingObject = FightStaticData.flyingObject
    local csb = cc.CSLoader:createNode("csb/Fly_refining_Layer.csb")
    self:addChild(csb)
    self.publicTipLayer = PublicTipLayer:create()
    self:addChild(self.publicTipLayer)
    
    self.goodsTable = {} -- 保存节点
    self.linesTable = {} -- 保存线
    self.isMake = isMake
    
    self.flyTechId = flyTechId
    
    local function BtnEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            if sender == self.makeBtn then
                if isMake ~= true then
                    if self.UpCondition[1] == true and self.UpCondition[2] == true and self.UpCondition[3] == true and self.UpCondition[4] == true then
                        UserData.Fibble:sendFibbleUp(self.flyTechId)
                    else 
                        self.publicTipLayer:setTextAction("材料不足")
                    end
                else
                    if self.UpCondition[1] == true and self.UpCondition[2] == true and self.UpCondition[3] == true and self.UpCondition[4] == true then
                        UserData.Fibble:sendCreateFibble(self.flyTechId)
                    else 
                        self.publicTipLayer:setTextAction("材料不足")
                    end
                end
            elseif sender == self.exitBtn then
                self:removeFromParent()
            end
        end
    end
    
    self.bgPanel = csb:getChildByName("bgPanel")
    self.panel = csb:getChildByName("Panel")
    self.flyTech = self.panel:getChildByName("flyTech")                                   -- 飞宝
    self.makeBtn = ccui.Helper:seekWidgetByName(self.panel, "makeBtn")                    -- 制造按钮
    self.refineOrMake = self.makeBtn:getChildByName("refineOrMake") 
    self.makeBtn:addTouchEventListener(BtnEvent)
    self.makeBtn:setPressedActionEnabled(true)
    
    local linePanel= csb:getChildByName("lineAndDotPanel")
    for i =4, 7 do
        local line =  linePanel:getChildByName(string.format("line_%d",i))  
        table.insert(self.linesTable,line)
     
    end
    
    
    --按钮字体描边
    local titleText = self.makeBtn:getChildByName("titleText")  
    
    local flyData_1 = self.panel:getChildByName("flyData_1")
    self.nameText = flyData_1:getChildByName("nameText")
    self.nameText:setString(flyingObject[self.flyTechId].name)   -- 设置飞宝名字
    
    self.flyData_2 = self.panel:getChildByName("flyData_2")
    
    self.bg = self.bgPanel:getChildByName("bg")
    self.exitBtn = self.bgPanel:getChildByName("exitBtn")
    self.exitBtn:addTouchEventListener(BtnEvent)
    
    if isMake == true then
        self.bg:setVisible(true)
        self.exitBtn:setVisible(true)
--        self.refineOrMake:setTexture("ui/FlyUI/makefly.png")
--        local titleText = self.makeBtn:getChildByName("titleText")
        titleText:setString("制 造")
        self.exitBtn:setPressedActionEnabled(true)
        self.bgPanel:setVisible(true)
        self.bgPanel:setTouchEnabled(true)
    end
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(titleText)  
    
    self.UpCondition = {}                                                                   -- 升级条件
    
    local fibStar = nil
    if UserData.Fibble.fibbleTable[self.flyTechId] == nil then                           -- 飞宝星级
        fibStar = 0
    else
        fibStar = UserData.Fibble.fibbleTable[self.flyTechId][1].byStar
    end
    self.makeGoodsTable = FlyFunction:finFibbleNeedMaterial(self.flyTechId, fibStar)        -- 飞宝炼制需要的材料table表
    self.makeGoods = {}
    self:setMakeGoods()

    local SpineJson = flyingObject[self.flyTechId].mSpineName .. ".json"
    local SpineAtlas = flyingObject[self.flyTechId].mSpineName .. ".atlas"
    self.mySpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    self.mySpine:setAnimation(0, "load", true)

    self.mySpine:setPosition(0,0)
    self.flyTech:addChild(self.mySpine)

    local t = 0.4
    local h = 5
    local move1 = cc.MoveBy:create(t,cc.p(0,h))
    local move2 = cc.MoveBy:create(t,cc.p(0,-h))
    local move3 = cc.MoveBy:create(t,cc.p(0,-h))
    local move4 = cc.MoveBy:create(t,cc.p(0,h))
    local seq = cc.Sequence:create(move1,move2,move3,move4)
    self.flyTech:runAction(cc.RepeatForever:create(seq))
    
    self:setFlyDetail(flyTechId, isMake)
    
    local function onSkillButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("onSkillButtonClicked ended skillID = " .. sender:getTag())
            local layer = require("app.views.FlyTechTree.FlySkillLayer"):create(sender:getTag())
            if layer ~= nil then
                local SceneManager = require("app.views.SceneManager")
                SceneManager:addToGameScene(layer,10)
            end
        end
    end
   
    local fData = FightStaticData.flyingObject[flyTechId]
   
    for i = 1, 4 do
        local str = string.format("Button_%d", i)
        local btn = ccui.Helper:seekWidgetByName(self.panel, str)
--        local flyingObjectSkill = FightStaticData.flyingObjectSkill[UserData.Fibble.fibbleTable[flyTechId][1][string.format("nSkillId%d", i)]]   
     
        local skillId = fData[string.format("skillID%d", i)]
        local flyingObjectSkill = FightStaticData.flyingObjectSkill[skillId]
     
        if i ~= 4 then
            btn:loadTextures(flyingObjectSkill.icon, flyingObjectSkill.icon, flyingObjectSkill.icon)
            btn:setPressedActionEnabled(true)
        else
            btn:loadTexture(flyingObjectSkill.icon)
        end
        btn:setTag(flyingObjectSkill.id)
        btn:setTouchEnabled(true)
        btn:addTouchEventListener(onSkillButtonClicked)
    end
    if ManagerTask:isTaskHaveComplete(UserData.NewHandLead.GuideList.FlyRefining.TaskID) and UserData.NewHandLead:isPreGuideCompleted("FlyRefining") and flyTechId == 101002 then
        if UserData.NewHandLead:getGuideState("FlyRefining") == 0  then
            local data = {name = "FlyRefining", order = 20, beginStep = 4}
            UserData.NewHandLead:startNewGuide(data)
        end 
    end
    
   
    
end

-- 设置材料按钮
function FlyRefiningLayer:setMakeGoods()

    local function touchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            print(sender:getTag())
            local goodsNum = UserData.Bag.items[sender:getTag()]
            if goodsNum == nil then
                goodsNum = 0
            end
            local flyMakeMatLayer = FlyMakeMatLayer:create(sender:getTag())
            self:addChild(flyMakeMatLayer)
        end
    end
    local Image_leftbg = self.panel:getChildByName("Image_leftbg")
    for i = 1 , 4 do
        local btnStr = string.format("btn_%d", i)
        local goodsId = self.makeGoodsTable[i].id
        self.makeGoods[btnStr] = Image_leftbg:getChildByName(string.format("makeGoodsBtn_%d", i))
        local goodBtn = Image_leftbg:getChildByName(string.format("makeGoodsBtn_%d", i))
        local goods = goodsNode:create(goodsId)
        local child = self.makeGoods[btnStr]:getChildByTag(1)
        if child ~= nil then
            child:removeFromParent()
        end
        self.makeGoods[btnStr]:addChild(goods)
        goods:setTag(1)
        goods:btnEvent(touchEvent)
        goods:setPosition(-47.5, -45)
        
        self.goodsTable[i] = goods --记录节点
       
        local goodsCount = self.makeGoods[btnStr]:getChildByName(string.format("goodsCount_%d", i))
        local goodsNum = UserData.Bag.items[goodsId]
        if goodsNum == nil then
            goodsNum = 0
        end
        goodsCount:setString(string.format("%d/%d", goodsNum, self.makeGoodsTable[i].num))
        if goodsNum >= self.makeGoodsTable[i].num then
            goodsCount:setColor(cc.c3b(31, 226, 83))
        else
            goodsCount:setColor(cc.c3b(255, 0, 0))
        end
        goodsCount:setLocalZOrder(100)
        if goodsNum >= self.makeGoodsTable[i].num then
            self.UpCondition[i] = true
        else
            self.UpCondition[i] = false
        end 
    end

end

function FlyRefiningLayer:setFlyDetail(flyTechId, isMake)
    local levelText = self.flyData_2:getChildByName("levelText")
    levelText:setString(string.format("LV：%d",  UserData.BaseInfo.userLevel))
    local t = UserData.Fibble.fibbleTable[flyTechId]
    local star = 0
    if t then
        star = t[1].byStar
  
    end
    local flyCurStar = PlayerDetails:getFiyingObjectDetatils(flyTechId, star)
    local flyUpStar = PlayerDetails:getFiyingObjectDetatils(flyTechId, star + 1)
    local energyNum = self.flyData_2:getChildByName("energyNum")
    energyNum:setString(tostring(flyCurStar.flyingObject_Hp))
    local energyAddText = self.flyData_2:getChildByName("energyAddText")
    energyAddText:setString(tostring(flyUpStar.flyingObject_Hp - flyCurStar.flyingObject_Hp))

    local sclenceHurtNum = self.flyData_2:getChildByName("sclenceHurtNum")
    sclenceHurtNum:setString(string.format("%0.1f%%", (flyCurStar.bonus_MechHurt * 100)))
    local sclenceAddHurtText = self.flyData_2:getChildByName("sclenceAddHurtText")
    sclenceAddHurtText:setString(string.format("%0.1f%%", ((flyUpStar.bonus_MechHurt - flyCurStar.bonus_MechHurt) * 100)))
    
    local godHurtNum = self.flyData_2:getChildByName("godHurtNum")
    godHurtNum:setString(string.format("%0.1f%%", (flyCurStar.bonus_FairyHurt * 100)))
    local godHurtAddText = self.flyData_2:getChildByName("godHurtAddText")
    godHurtAddText:setString(string.format("%0.1f%%", (flyUpStar.bonus_FairyHurt - flyCurStar.bonus_FairyHurt) * 100))
    
    local wildHurtNum = self.flyData_2:getChildByName("wildHurtNum")
    wildHurtNum:setString(string.format("%0.1f%%", (flyCurStar.bonus_DemonHurt * 100)))
    local wildHurtAddText = self.flyData_2:getChildByName("wildHurtAddText")
    wildHurtAddText:setString(string.format("%0.1f%%", (flyUpStar.bonus_DemonHurt - flyCurStar.bonus_DemonHurt) * 100))
    
    local skillEnergyNum = self.flyData_2:getChildByName("skillEnergyNum")
    skillEnergyNum:setString(string.format("%0.1f%%", (flyCurStar.bonus_SkillHp * 100)))
    local skillEnergyAddText = self.flyData_2:getChildByName("skillEnergyAddText")
    skillEnergyAddText:setString(string.format("%0.1f%%", (flyUpStar.bonus_SkillHp - flyCurStar.bonus_SkillHp) * 100))
    
    local skillPowerNum = self.flyData_2:getChildByName("skillPowerNum")
    skillPowerNum:setString(string.format("%0.1f%%", (flyCurStar.bonus_SkillAtk * 100)))
    local skillPowerAddText = self.flyData_2:getChildByName("skillPowerAddText")
    skillPowerAddText:setString(string.format("%0.1f%%", (flyUpStar.bonus_SkillAtk - flyCurStar.bonus_SkillAtk) * 100))
end

function FlyRefiningLayer:onFibbleUp(event)
    local userdata = event._usedata
    if userdata == 0 then
        self.publicTipLayer:setTextAction("炼制成功")
        local fibStar = UserData.Fibble.fibbleTable[self.flyTechId][1].byStar
        self.makeGoodsTable = FlyFunction:finFibbleNeedMaterial(self.flyTechId, fibStar)
        self:setFlyDetail(self.flyTechId)
        self:setMakeGoods()
        -- 显示特效
        self:createMakeEffect()
        
    elseif userdata == 1 then
    
    elseif userdata == 2 then
        self.publicTipLayer:setTextAction("材料不足")
    elseif userdata == 3 then
        self.publicTipLayer:setTextAction("飞宝等级已达上限")
    end
end

function FlyRefiningLayer:onCreateFibble(event)
    local userdata = event._usedata
    if userdata == 0 then
        self.publicTipLayer:setTextAction("打造成功")
        
        FlyRefiningPrompt.flybbleTatle[self.flyTechId].type = 1
        FlyRefiningPrompt.flybbleTatle[self.flyTechId].isPrompt = false
        for i = 1, #FightStaticData.fibbleTree do
            local fibbleID = FightStaticData.fibbleTree[i].fibbleID
            if FlyRefiningPrompt.flybbleTatle[fibbleID] == nil then
                if FlyFunction:checkFibbleEnable(fibbleID) == true then
                    FlyRefiningPrompt.flybbleTatle[fibbleID] = {type = 0, isPrompt = false}
                end
            end
        end
        EventMgr:dispatch(EventType.OnFlyPrompt)
        
        -- 显示特效
        self:createMakeEffect()
       
        
    elseif userdata == 1 then
        self.publicTipLayer:setTextAction("飞宝ID错误")
    elseif userdata == 2 then
        self.publicTipLayer:setTextAction("已打造过")
    elseif userdata == 3 then
        self.publicTipLayer:setTextAction("等级不足")
    elseif userdata == 4 then
        self.publicTipLayer:setTextAction("材料不足")
    end
end


-- 公共的特效
--透明度
function FlyRefiningLayer:fadeAtion(t,opt)
	local act = cc.FadeTo:create(t,opt)
	return act 
end
--缩放
function FlyRefiningLayer:scaAction(t,sca)
    local act = cc.ScaleTo:create(t,sca)
    return act 
end
-- 创建callback
function FlyRefiningLayer:callbackAction(callback)
	local cb = cc.CallFunc:create(callback)
	return cb
end



function FlyRefiningLayer:createMakeEffect()
    
    self:kuangEffect(self.goodsTable[1])
    self:kuangEffect(self.goodsTable[3])
    self:kuangEffect(self.goodsTable[4])
    self:guangdianEffect(self.goodsTable[1],1)
    self:guangdianEffect(self.goodsTable[3],2)
    self:guangdianEffect(self.goodsTable[4],3)
  
    local function callBack1()
        self:kuangEffect(self.goodsTable[2])
    end
    
    local function callBack2()
        self:xuanwoParticle(self.goodsTable[2])--发散的粒子
        self:fansanTupian(self.goodsTable[2])
    end
    


    local delay1 = cc.DelayTime:create(1.0)
    local call1 = cc.CallFunc:create(callBack1)
    local delay2 = cc.DelayTime:create(0.6)
    local call2 = cc.CallFunc:create(callBack2)

    
    self:runAction(cc.Sequence:create(delay1,call1,delay2,call2))

end
-- 飞宝炼制特效

-- 物品框的
function FlyRefiningLayer:kuangEffect(goods)
	
    local parent = goods:getParent()
    local pos = cc.p(0, 0)
   
    local kuang = cc.Sprite:create("fibbleMakeEffect/ui_feibaolianzhig_huangkuang.png")	
    kuang:setPosition(pos)
	kuang:setOpacity(0)
    parent:addChild(kuang)
	local fade1 = self:fadeAtion(0.1,255)
    local fade2 = self:fadeAtion(0.1,0)
    local sca1 = self:scaAction(0.1,1.2)
    local sca2 = self:scaAction(0.1,2)
    local seq1 = cc.Sequence:create(fade1,fade2)
    
    local function delCallback(sender)
        sender:removeFromParent()
    end
    local seq2 = cc.Sequence:create(sca1,sca2,self:callbackAction(delCallback))
    kuang:runAction(seq1)
    kuang:runAction(seq2)
    --骨骼的
    local pathName = "fibbleMakeEffect/ui_feibaolianzhi_liuguang"
    local SpineJson = pathName..".json"
    local SpineAtlas = pathName..".atlas"
    local mySpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    mySpine:setAnimation(0, "load", false)
    mySpine:setPosition(pos)
    parent:addChild(mySpine)
     
     -- 粒子效果
    local emitter = cc.ParticleSystemQuad:create("fibbleMakeEffect/ui_p_feibaolianzhi_03.plist")
    emitter:setPosition(pos)
    parent:addChild(emitter)

     local  function onSpineComplete(event)
         MyFightingCtrl:removeSpine(mySpine)
         emitter:removeFromParent()
     end
    mySpine:registerSpineEventHandler(onSpineComplete, 2)
    
end

-- 光点移动

function FlyRefiningLayer:guangdianEffect(goods,indx)
    local parent = goods:getParent()
    local pos = cc.p(0, 0)
    local x = 0
    local y = 0
    local dian = cc.Sprite:create("fibbleMakeEffect/ui_feibaolianzhi_guang_dian.png")
    if indx == 1 then
        pos = cc.p(4, 0)
    	y = - 100
    elseif indx == 2 then
        pos = cc.p(4, 0)
        y = 100	
    elseif indx == 3 then
        pos = cc.p(0, -4)
        x = -100
        dian:setRotation(90)
    end
    
    dian:setPosition(pos)
    parent:addChild(dian,-3)
    
    local move = cc.MoveBy:create(0.7,cc.p(x,y))
    local function callback(sender)
        sender:removeFromParent()
    end
    dian:runAction(cc.Sequence:create(move,cc.CallFunc:create(callback)))
    
    
end

-- 漩涡粒子播放

function FlyRefiningLayer:xuanwoParticle(goods)
    local parent = goods:getParent()
    local pos = cc.p(0, 0)
    local emitter = cc.ParticleSystemQuad:create("fibbleMakeEffect/ui_p_feibaolianzhi_02.plist")
    emitter:setPosition(pos)
    parent:addChild(emitter)
	
    local function callback(sender)
        sender:removeFromParent()
        self:lanseDian(goods)
    end
    emitter:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(callback)))
    
end


-- 发散图片 和 漩涡粒子同时播放
function FlyRefiningLayer:fansanTupian(goods)
    local parent = goods:getParent()
    local pos = cc.p(0, 0)
    local tupian = cc.Sprite:create("fibbleMakeEffect/ui_feibaolianzhi_fashe002.png")
    tupian:setPosition(pos)
    parent:addChild(tupian)
    
    tupian:setOpacity(0)
    tupian:setScale(5)
    
    local fade1 = self:fadeAtion(0.25,255)
    local sca1 = self:scaAction(0.25,0)
    local spa = cc.Spawn:create(fade1,sca1)
    
    local function callback(sender)
        sender:removeFromParent()
    end
    
    local seq = cc.Sequence:create(spa,cc.CallFunc:create(callback))
    tupian:runAction(seq)    
    
    
end


--  中心点放大特效,漩涡粒子效果播放完后的
function FlyRefiningLayer:lanseDian(goods)
	
    local parent = goods:getParent()
    local pos = cc.p(0, 0)
    
    local liandian = cc.Sprite:create("fibbleMakeEffect/ui_feibaolianzhig_002.png")
    liandian:setPosition(pos)
    parent:addChild(liandian)
    liandian:setScale(0)
    local sca1 = self:scaAction(0.1,3)
    local sca2 = self:scaAction(0.2,6)
    local fade1 = self:scaAction(0.2,0)
    local spa = cc.Spawn:create(sca2,fade1)
    
    local function callback(sender)
        sender:removeFromParent()
        -- 播放飞行粒子
        self:feixingLizi(goods)
    end

    local seq = cc.Sequence:create(sca1,spa,cc.CallFunc:create(callback))
    liandian:runAction(seq)    
end


-- 中心特效播放完后，播放飞行粒子

function FlyRefiningLayer:feixingLizi(goods)
    local parent = goods:getParent()
    local pos = cc.p(0, 0)
    local emitter = cc.ParticleSystemQuad:create("fibbleMakeEffect/ui_p_feibaolianzhi_04.plist")
    emitter:setPosition(pos)
    parent:addChild(emitter)

    local function callback(sender)
        sender:removeFromParent()
        self:feibaoEffect()
    end
    local move = cc.MoveBy:create(0.1,cc.p(-50,0))
    emitter:runAction(cc.Sequence:create(move,cc.CallFunc:create(callback)))
    
end

--到播放飞宝身上的特效 

function FlyRefiningLayer:feibaoEffect()
--	self.mySpine
--	self.flyTech
    local pos = cc.p(0,0)
    local function callback1(sender)
        sender:removeFromParent()
     
    end
    
    
    local function callback2(sender)
        sender:removeFromParent()
        if self.isMake ==  true then
            self:removeFromParent()
        end

    end
    local SpineJson = FightStaticData.flyingObject[self.flyTechId].mSpineName .. ".json"
    local SpineAtlas = FightStaticData.flyingObject[self.flyTechId].mSpineName .. ".atlas"
    local tempSpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    tempSpine:setPosition(0,0)
    tempSpine:setAnimation(0, "load", true)
    self.flyTech:addChild(tempSpine,3)
    tempSpine:setScale(0.01)
    tempSpine:setOpacity(150)
    
    
    local spineSca1 = self:scaAction(0.1,1)
    local spineFade1 = self:fadeAtion(0.1,150)
    local spineSca2 = self:scaAction(0.08,1.5)
    local spineFade2 = self:fadeAtion(0.08,0)
    local spineSpa1 = cc.Spawn:create(spineSca1,spineFade1)
    local spineSpa2 = cc.Spawn:create(spineSca2,spineFade2)
    local spineSeq = cc.Sequence:create(cc.DelayTime:create(0.01),spineSpa1,spineSpa2,cc.CallFunc:create(callback1))
    tempSpine:runAction(spineSeq)
    
    -- 爆炸粒子
    local emitter = cc.ParticleSystemQuad:create("fibbleMakeEffect/ui_p_feibaolianzhi_01.plist")
    emitter:setPosition(pos)
    self.flyTech:addChild(emitter,5)

  
    emitter:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(callback1)))
    
   -- 光效 ui_feibaolianzhi_001
    local  sprite = cc.Sprite:create("fibbleMakeEffect/ui_feibaolianzhi_001.png")
    sprite:setPosition(pos)
    self.flyTech:addChild(sprite)
    sprite:setScale(0)
    sprite:setOpacity(0)
    local sca1 = self:scaAction(0.1,3.0)
    local sca2 = self:scaAction(0.5,3.5)
    local fade = self:fadeAtion(0.1,255)
    
    local spa = cc.Spawn:create(sca1,fade)
    local seq = cc.Sequence:create(spa,sca2,cc.CallFunc:create(callback2))
    sprite:runAction(seq)
    
   


end


return FlyRefiningLayer