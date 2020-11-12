local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local TimeFormat = require("common.TimeFormat")
local FlyFunction = require("app/views/FlyTechTree/FlyFunction")
local PlayerDetails = require("app.views.public.PlayerDetails")
--总览

local FlyAllViewLayer = class("FlyAllViewLayer", function()
    return cc.Layer:create()
end)

function FlyAllViewLayer:create(flyTechId)
    local view = FlyAllViewLayer.new()
    view:init(flyTechId)
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

function FlyAllViewLayer:ctor()

end

function FlyAllViewLayer:onEnter()
    EventMgr:registListener(EventType.OnSelectFibble, self, self.onSelectFibble) 
end

function FlyAllViewLayer:onExit()
    EventMgr:unregistListener(EventType.OnSelectFibble, self, self.onSelectFibble) 
end



--初始化
function FlyAllViewLayer:init(flyTechId)  
    
    local flyingObject = FightStaticData.flyingObject
    local csb = cc.CSLoader:createNode("csb/Fly_allview_Layer.csb")
    self:addChild(csb)
    self.publicTipLayer = PublicTipLayer:create()
    self:addChild(self.publicTipLayer)
    self.flyTechId = flyTechId
    
    local function touchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then
            if sender == self.fightFlyBtn then
                UserData.Fibble:sendSelectFibble(self.flyTechId)
            end
        end
    end    
    
    local panel = csb:getChildByName("Panel")
    self.panel = panel
    self.fibbleSkillData = UserData.Fibble.fibbleTable[self.flyTechId]
    FlyFunction.tempMySkillIdTable = {self.fibbleSkillData[1].nSkillId1,self.fibbleSkillData[1].nSkillId2,self.fibbleSkillData[1].nSkillId3} -- 暂时带有的技能的ID存储
    self.skillDownNodeTable  = {} --存储下面的所有技能节点的
    self.skillNodePosTable= {} -- 记录坐标点的节点
    -- 获取对应的坐标
    local selectSkillPanel = panel:getChildByName("flySkillPanel")
    for i = 1, 4 do
        local strKey = "skill_"..tostring(i)
        local tmp =  selectSkillPanel:getChildByName(strKey)
        self.skillNodePosTable[i] = tmp
    end
    local text_skill = selectSkillPanel:getChildByName("Text_Skill")
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(20,2)
    outLineLable:setTexOutLine(text_skill)
    self:createDownSkillNode() --  创建技能的节点
    self:getGodPanel(self.panel)
  
    self.flyTech = panel:getChildByName("flyTech")                          -- 飞宝
    self.flyTech:setVisible(false)
    local flySkillPanel = panel:getChildByName("flySkillPanel")
    local flySkillFrame = flySkillPanel:getChildByName("flySkillFrame")
    self.fightFlyBtn = panel:getChildByName("Button_fight")--flySkillFrame:getChildByName("fightFlyBtn")          -- 出站按钮     
    self.fightFlyBtn:addTouchEventListener(touchEvent)
    self.fightFlyBtn:setPressedActionEnabled(true)
    

    
    local flyData_1 = panel:getChildByName("flyData_1")
    self.flyData_2 = panel:getChildByName("flyData_2")
    local imagename = flyData_1:getChildByName("Image_name")
    local imagename1 = imagename:getChildByName("Image_name") 
    self.nameText = imagename1:getChildByName("Text_name")
    self.nameText:setString(flyingObject[self.flyTechId].name)   -- 设置飞宝名字
    
    local imageType = flyData_1:getChildByName("Image_typeText")
    local imagename2 = imageType:getChildByName("Image_name") 
    self.flyType = imagename2:getChildByName("Text_type")
    local type = ""
    if flyingObject[self.flyTechId].type == 1 then
    	type = "机械"
    elseif flyingObject[self.flyTechId].type == 1 then
        type = "仙侠"
    else
        type = "兽妖"
    end
    self.flyType:setString(type)   -- 设置飞宝类型
    
    self:setFlyDetail(flyTechId)
    
    local SpineJson = flyingObject[self.flyTechId].mSpineName .. ".json"
    local SpineAtlas = flyingObject[self.flyTechId].mSpineName..".atlas"
    self.mySpine = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    self.mySpine:setAnimation(0, "load", true)
     self.fightFlyBtn:setLocalZOrder(1)
    self.mySpine:setPosition(cc.p(self.flyTech:getPosition()))
    panel:addChild(self.mySpine,0)
    
    local t = 0.4
    local h = 5
    local move1 = cc.MoveBy:create(t,cc.p(0,h))
    local move2 = cc.MoveBy:create(t,cc.p(0,-h))
    local move3 = cc.MoveBy:create(t,cc.p(0,-h))
    local move4 = cc.MoveBy:create(t,cc.p(0,h))
    local seq = cc.Sequence:create(move1,move2,move3,move4)
    self.mySpine:runAction(cc.RepeatForever:create(seq))
    
    self.spineNode = self.panel:getChildByName("spineNode") 
    local SpineJson = "spine/ui/ui_feibaochuzhan_gx_01.json"
    local SpineAtlas = "spine/ui/ui_feibaochuzhan_gx_01.atlas"

    local spineNode = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
    spineNode:setAnimation(0, "load", true)
    spineNode:setPosition(0,0)
    self.spineNode:addChild(spineNode)
end

function FlyAllViewLayer:onSelectFibble(event)
    local userdata = event._usedata
    if userdata == 0 then
        self.publicTipLayer:setTextAction("已出战")
    elseif userdata == 1 then
        self.publicTipLayer:setTextAction("无法出战")
    end
end





function FlyAllViewLayer:createDownSkillNode()

    --清空表
    for key, var in pairs(self.skillDownNodeTable) do
        var:removeFromParent()
    end
    if   self.skillNode then
        self.skillNode:removeFromParent()
    end
   
    self.skillDownNodeTable = {}
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
--            self:moveDownToUpNodeToDest(sender)
            local popUpSkillLayer = require("app/views/FlyTechTree/popUpSkillLayer")
            local popLyaer = popUpSkillLayer:create(self.flyTechId,self)
            self:addChild(popLyaer)
        end
    end    

    local selectSkillPanel = self.panel:getChildByName("flySkillPanel")
    for i = 1, #FlyFunction.tempMySkillIdTable do
        local skillNode = cc.CSLoader:createNode("csb/SkillNode.csb")
        local skillId = FlyFunction.tempMySkillIdTable[i]
        local skill_bg = skillNode:getChildByName("skill_bg")
        local skillNodePanel = skillNode:getChildByName("Panel")
        local skillBtn = skillNodePanel:getChildByName("skillBtn")
        local skillName = skillBtn:getChildByName("skillNameText")
     
        local skillLevel = ccui.Helper:seekWidgetByName(skillNodePanel ,"skillLevelText") 
        local sData  = FightStaticData.flyingObjectSkill[skillId]
        skillName:setString(sData.name)
        skillLevel:setString(string.format("Lv%d",UserData.Fibble.skillTable[skillId].level))
        skillBtn.id = skillId -- 记录ID
        skillBtn:loadTextures(sData.icon, sData.icon,sData.icon) --设置底图
        skillBtn:addTouchEventListener(onEventTouchButton) -- 按钮通知事件
        skillNode:setPosition( cc.p(self.skillNodePosTable[i]:getPosition()))
        selectSkillPanel:addChild(skillNode)
        self.skillDownNodeTable[skillId] = skillNode --这个是记录节点的保存起来

    end
       
    self.skillNode = cc.CSLoader:createNode("csb/SkillNode.csb")
    local skillId =  self.fibbleSkillData[1].nSkillId4
    local skill_bg = self.skillNode:getChildByName("skill_bg")
    local skillNodePanel = self.skillNode:getChildByName("Panel")
    local skillBtn = skillNodePanel:getChildByName("skillBtn")
    local skillName = skillBtn:getChildByName("skillNameText")

    local skillLevel = ccui.Helper:seekWidgetByName(skillNodePanel ,"skillLevelText") 
    local sData  = FightStaticData.flyingObjectSkill[skillId]
    skillName:setString(sData.name)
    skillLevel:setString(string.format("Lv%d",UserData.Fibble.skillTable[skillId].level))
    skillBtn.id = skillId -- 记录ID
    skillBtn:loadTextures(sData.icon, sData.icon,sData.icon) --设置底图
    skillBtn:addTouchEventListener(onEventTouchButton) -- 按钮通知事件
    self.skillNode:setPosition( cc.p(self.skillNodePosTable[4]:getPosition()))
    selectSkillPanel:addChild(self.skillNode)
  

   
end



-- 获取神将的panel
function FlyAllViewLayer:getGodPanel(panel)
    self.selectGodPanel = panel:getChildByName("selectRolePanel")
    self.nodePosTable = {}
    self.godDownNodeTable = {}
    for  i =1, 5 do
        local keyStr = "role_"..tostring(i)
        local tempPosNode = self.selectGodPanel:getChildByName(keyStr)
        tempPosNode:setVisible(false)
        self.nodePosTable[i] = tempPosNode
    end
    local text_God = self.selectGodPanel:getChildByName("Text_god")
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(20,2)
    outLineLable:setTexOutLine(text_God)
    
    self.starImage = {"ui/FlyUI/xing1.png","ui/FlyUI/xing2.png","ui/FlyUI/xing3.png","ui/FlyUI/xing4.png","ui/FlyUI/xing5.png"}
    FlyFunction:getFlyGodIdTable(self.flyTechId)  --获取对应的神将ID
    self:createDownGodNode()
   
end

--创建节点
function FlyAllViewLayer:createOneNode(godId)
    local godNode = cc.CSLoader:createNode("csb/GodWillNode.csb")
    local godPanel = godNode:getChildByName("Panel")
    local godNodeBtn = godPanel:getChildByName("godWillBtn")
    local god_bg =  godPanel:getChildByName("god_bg")
    local godLevel =  god_bg:getChildByName("levelText")
    local godStar = godPanel:getChildByName("Image_star")
    local godFrame = godPanel:getChildByName("godFrame")
    local name_bg = godPanel:getChildByName("name_bg")
    local godName = name_bg:getChildByName("GodName")
    godNodeBtn:loadTextures("items/godWill/411001.png", "items/godWill/411001.png","items/godWill/411001.png") --设置底图
    if godId == 0 then
        godName:setString("")
        godNodeBtn:setOpacity(0)
        godLevel:setVisible(false)
        godStar:setVisible(false)
        god_bg:setVisible(false)
        name_bg:setVisible(false)
    else
        local godData = FightStaticData.godwill[godId]
        local userGodData = UserData.Godwill.godList[godId]
        local fibbleUpData = FlyFunction:findFibbleUpForSameIdAndStar(godId,userGodData.star)
        godNodeBtn:loadTextures(fibbleUpData.icon, fibbleUpData.icon,fibbleUpData.icon) --设置底图
        godName:setString(fibbleUpData.name)
        godLevel:setString(string.format("Lv%d",userGodData.level)) --设置等级
        godStar:loadTexture(self.starImage[userGodData.star]) --设置星级
        if userGodData.star == 0 then
            godStar:setVisible(false)
        end
    end

    godNodeBtn.id = godId

    return godNode,godNodeBtn

end


function FlyAllViewLayer:createDownGodNode()

    --清空表
    for key, var in pairs(self.godDownNodeTable) do
        var:removeFromParent()
    end
    self.godDownNodeTable = {}
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local popUpGodLayer = require("app.views.FlyTechTree.popUpGodLayer")
            local popLyaer = popUpGodLayer:create(self.flyTechId,self)
            self:addChild(popLyaer)
        end
    end    
   
    
    for i = 1, #FlyFunction.tempMyGodIdTable do
        local godId = FlyFunction.tempMyGodIdTable[i]
        local godNode,godBtn = self:createOneNode(godId) --获取节点

        godBtn:addTouchEventListener(onEventTouchButton) -- 按钮通知事件
        self.selectGodPanel:addChild(godNode)

        godNode:setPosition( cc.p(self.nodePosTable[i]:getPosition()))

        self.godDownNodeTable[i] = godNode --这个是记录节点的保存起来

    end

end

-- 设置飞宝基本信息
function FlyAllViewLayer:setFlyDetail(flyTechId)

    local function getTextChild(parent)
        local Image_number = parent:getChildByName("Image_number")
        local Text_number = Image_number:getChildByName("Text_number")
        return Text_number
    end
    
    local star = UserData.Fibble.fibbleTable[flyTechId][1].byStar
    local flyCurStar = PlayerDetails:getFiyingObjectDetatils(flyTechId, star)

    local levelText = self.flyData_2:getChildByName("levelText")
    local Text_1 = levelText:getChildByName("Text_1")
    Text_1:setString(tostring(UserData.BaseInfo.userLevel))
    
    local Image_energyText = self.flyData_2:getChildByName("Image_energyText")
    local Text_number_1 = getTextChild(Image_energyText)
    Text_number_1:setString(tostring(flyCurStar.flyingObject_Hp))
    
    local Image_sclenceHurtText = self.flyData_2:getChildByName("Image_sclenceHurtText")
    local Text_number_2 = getTextChild(Image_sclenceHurtText)
    Text_number_2:setString(string.format("%0.1f%%", (flyCurStar.bonus_MechHurt * 100)))
    
    local Image_godHurtText = self.flyData_2:getChildByName("Image_godHurtText")
    local Text_number_3 = getTextChild(Image_godHurtText)
    Text_number_3:setString(string.format("%0.1f%%", (flyCurStar.bonus_FairyHurt * 100)))
    
    local Image_wildHurtText = self.flyData_2:getChildByName("Image_wildHurtText")
    local Text_number_4 = getTextChild(Image_wildHurtText)
    Text_number_4:setString(string.format("%0.1f%%", (flyCurStar.bonus_DemonHurt * 100)))
    
    local Image_skillEnergyText = self.flyData_2:getChildByName("Image_skillEnergyText")
    local Text_number_5 = getTextChild(Image_skillEnergyText)
    Text_number_5:setString(string.format("%0.1f%%", (flyCurStar.bonus_SkillHp * 100)))
    
    local Image_skillPowerText = self.flyData_2:getChildByName("Image_skillPowerText")
    local Text_number_6 = getTextChild(Image_skillPowerText)
    Text_number_6:setString(string.format("%0.1f%%", (flyCurStar.bonus_SkillAtk * 100)))

    
end



return FlyAllViewLayer