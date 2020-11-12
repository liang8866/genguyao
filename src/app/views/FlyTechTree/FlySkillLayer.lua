local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local publicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local TimeFormat = require("common.TimeFormat")
local SkillTipsNode  =  require("app.views.public.SkillTipsNode")

local ENUM_NENGLIANG = 1
local ENUM_WEILI = 2
local ENUM_SUDU = 3
local ENUM_CD = 4

--技能
local allRemain = 0
local nextRemain = 0
local FlySkillLayer = class("FlySkillLayer", function()
    return ccui.Layout:create()
end)

function FlySkillLayer:create(selectedSkillID)
    local view = FlySkillLayer.new()
    view:init(selectedSkillID)
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

function FlySkillLayer:ctor()
    self.currentSelectSkillID = 0
    self.lastSelectSkillID = 0
    self.nextRemain = 0  -- 恢复下一点技能点所需要的秒数
    self.allRemain = 0   -- 恢复全部技能点所需要的秒数
    self.scheduleUpdate = nil
end

function FlySkillLayer:onEnter()
    EventMgr:registListener(EventType.OnSkillUp, self, self.OnSkillUp)                     -- 服务端返回提升技能等级请求
    EventMgr:registListener(EventType.OnPropertyChange, self, self.refreshSkillPoint)      -- 刷新技能点数
    EventMgr:registListener(EventType.OnBuyFibbleSkillPoint, self, self.OnBuyFibbleSkillPoint)  --购买技能点返回
    
    local name = "FlySkillLead"
    local ManagerTask = require("app.views.Task.ManagerTask")
    if ManagerTask:isTaskHaveComplete(UserData.NewHandLead.GuideList.FlySkillLead.TaskID) then
        if UserData.NewHandLead:getGuideState(name) == 0 then
            UserData.NewHandLead.GuideList[name].curStep = 2
            if self.Node_newHand_inView ~= nil then 
                UserData.NewHandLead:addHandTo(self.Node_newHand_inView)
                local fibbleID = UserData.BaseInfo.nFibbleId
                local curUseFibbleFirstSkillID = UserData.Fibble.fibbleTable[fibbleID][1].nSkillId1

                if self.wnd_list.itemList[curUseFibbleFirstSkillID].parent ~= nil then
                    local posX,posY = self.wnd_list.itemList[curUseFibbleFirstSkillID].parent:getPosition()
                    self.Node_newHand_inView:setPosition(cc.p(posX+50,posY-50))
                end
            end
        end
    end
    
end

function FlySkillLayer:onExit()
    EventMgr:unregistListener(EventType.OnSkillUp, self, self.OnSkillUp)                     -- 服务端返回提升技能等级请求
    EventMgr:unregistListener(EventType.OnPropertyChange, self, self.refreshSkillPoint)      -- 刷新技能点数
    
    if self.scheduleUpdate and type(self.scheduleUpdate) == "number" then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdate)
        self.scheduleUpdate = nil
    end
end



--初始化
function FlySkillLayer:init(selectedSkillID)
    local flySkill_root = cc.CSLoader:createNode("csb/Fly_Skill_Layer.csb")
    
    self:addChild(flySkill_root)
    self.flySkill_root = flySkill_root
    local Panel = flySkill_root:getChildByName("Panel")
    self.Panel = Panel
    self.Panel_bg = flySkill_root:getChildByName("Panel_bg")
    
    local exitBtn = flySkill_root:getChildByName("exitBtn")
    self.Node_newHand = flySkill_root:getChildByName("Node_newHand")
     
    local function onEventTouchButton(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            if self.scheduleUpdate and type(self.scheduleUpdate) == "number" then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdate)
                self.scheduleUpdate = nil
            end
            
            local name = "FlySkillLead"
            if UserData.NewHandLead:getGuideState(name) == 0 and UserData.NewHandLead:getCurrentGuideName() == name then
                if  UserData.NewHandLead.GuideList[name].curStep == 5 then
                    UserData.NewHandLead.GuideList[name].curStep = 6
                    UserData.NewHandLead:CompleteGuide(name)
                    UserData.NewHandLead:closeCurrentGuide()
                    if self.Node_newHand ~= nil then 
                        self.Node_newHand:setVisible(false)
                    end
                    local SceneManager = require("app.views.SceneManager")
                    SceneManager:removeChildLayer("NewHandLeadLayer")
                else
                    --返回初始指引状态
                    UserData.NewHandLead.GuideList[name].curStep = 1
                    
                end
            end
            
            self:removeFromParent()
            if UserData.NewHandLead.GuideList[name].curStep == 1  and UserData.NewHandLead:getCurrentGuideName() == name  then
                local SceneManager = require("app.views.SceneManager")
                local layer = SceneManager:getGameLayer("TownInterfaceLayer")
                if layer ~= nil then
                    if layer.main_ui_layer ~= nil and layer.main_ui_layer.bottomBar ~= nil then
                        layer.main_ui_layer.bottomBar:showNewHand("FlySkillLead")
                    end
                end
            end
        end
    end
    
    exitBtn:setTouchEnabled(true)
    exitBtn:addTouchEventListener(onEventTouchButton)
    exitBtn:setPressedActionEnabled(true)
     
    self.wnd_list = {}
    self.right_Info = {}
    self.right_levelUp = {}
    
    self.wnd_list.ScrollView_skill_list = Panel:getChildByName("ScrollView_skill_list")
    self.wnd_list.ScrollView_skill_list:setTouchEnabled(true)

    if self.wnd_list.skillItem_mode == nil then
        local Panel_item_clone = Panel:getChildByName("Panel_item_clone")
        Panel_item_clone:setVisible(false)
        self.wnd_list.skillItem_mode = Panel_item_clone
    end
    
    -- 升级操作界面
    self:initLevelupUI(Panel)
    
    --技能属性界面
    self:initInfoUI(Panel)
    
    --初始化列表及数据
    if #UserData.Fibble.skillOrderList > 0 then
        self:initSkillList()
        local fibbleID = UserData.BaseInfo.nFibbleId
        local curUseFibbleFirstSkillID = UserData.Fibble.fibbleTable[fibbleID][1].nSkillId1
        local selectID =  selectedSkillID ~= nil and selectedSkillID or curUseFibbleFirstSkillID
        self:selectSkill(selectID)
        if selectID ~= nil then
            local dataNum = table.nums(UserData.Fibble.skillOrderList)
            for i=1,dataNum do
                if selectID == UserData.Fibble.skillOrderList[i].id then
                    local itemSize = self.wnd_list.skillItem_mode:getContentSize()
                    local szScrollView = self.wnd_list.ScrollView_skill_list:getInnerContainerSize()
                    local szScrollView1 = self.wnd_list.ScrollView_skill_list:getContentSize()
                    local currentHeight = itemSize.height * math.ceil(i/3)
                    local panel = self.wnd_list.ScrollView_skill_list:getInnerContainer()
                    cclog("currentHeight = " .. tostring(currentHeight))
                    
                    if currentHeight+130 > szScrollView1.height then
                        local cur = (currentHeight+130)
                        cur = cur > szScrollView.height and szScrollView.height or cur
                        self.wnd_list.ScrollView_skill_list:jumpToPercentVertical(cur/szScrollView.height*100)
                    end
                    break
                end
            end
        end
    end
    
    self.publicTipLayer = publicTipLayer:create()
    
    self.right_levelUp.Panel_right:setVisible(false)
    self.right_Info.Panel_right_pre:setVisible(true)
    
    
    
end

function FlySkillLayer:initLevelupUI(Panel)
    local Panel_right = Panel:getChildByName("Panel_right") 
    self.right_levelUp.Panel_right = Panel_right
    self.right_levelUp.Text_skill_point = Panel_right:getChildByName("Text_skill_point")
    self.right_levelUp.Text_time_count = Panel_right:getChildByName("Text_time_count")
    self.right_levelUp.Text_level_up_need = Panel_right:getChildByName("Text_level_up_need")
    self.right_levelUp.Image_level_up_need = Panel_right:getChildByName("Image_level_up_need")

    local Image_nengliang = Panel_right:getChildByName("Image_nengliang")
    local Image_weili = Panel_right:getChildByName("Image_weili")
    local Image_sudu = Panel_right:getChildByName("Image_sudu")
    local Image_cd = Panel_right:getChildByName("Image_cd")
    --[[
    local ENUM_NENGLIANG = 1
    local ENUM_WEILI = 2
    local ENUM_SUDU = 3
    local ENUM_CD = 4
    ]]
    local Image_number_table = {
        [1] = Image_nengliang:getChildByName("Image_number"),
        [2] = Image_weili:getChildByName("Image_number"),
        [3] = Image_sudu:getChildByName("Image_number"),
        [4] = Image_cd:getChildByName("Image_number"),
    } 

    self.right_levelUp.levelup_value = {}
    for i=1,4 do
        self.right_levelUp.levelup_value[i] = {}
        self.right_levelUp.levelup_value[i].Text_number = Image_number_table[i]:getChildByName("Text_number")
        self.right_levelUp.levelup_value[i].Text_add = Image_number_table[i]:getChildByName("Text_add")
        self.right_levelUp.levelup_value[i].Image_jiantou = Image_number_table[i]:getChildByName("Image_jiantou")
    end

    self.right_levelUp.FileNode_skill_before = Panel_right:getChildByName("FileNode_skill_before")
    self.right_levelUp.FileNode_skill_after = Panel_right:getChildByName("FileNode_skill_after")

    local Button_skill_level_up = Panel_right:getChildByName("Button_skill_level_up")
    local function onSkillLevelUpButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("onSkillLevelUpButtonClicked ended = " .. sender:getName())
            --技能升级按钮
            local nSkillId = self.currentSelectSkillID
            cclog("onSkillLevelUpButtonClicked nSkillId = " .. tostring(nSkillId))
            if nSkillId > 0 then
                UserData.Fibble:sendSkillUp(nSkillId)
            end


            local name = "FlySkillLead"
            if UserData.NewHandLead:getGuideState(name) == 0 and UserData.NewHandLead.GuideList[name].curStep == 4 then
                UserData.NewHandLead.GuideList[name].curStep = 5
                if self.Node_newHand ~= nil then 
                    self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[name].step[5].handPos)
                end
            end
            
        end
    end
    Button_skill_level_up:addTouchEventListener(onSkillLevelUpButtonClicked)
    Button_skill_level_up:setPressedActionEnabled(true)
    self.Button_skill_level_up = Button_skill_level_up

    local Button_addskill = Panel_right:getChildByName("Button_addskill")
    local function onAddskilButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            --购买技能点按钮
            local buySkillStr = StaticData.SystemParam["BuySkillPoint"].StrValue
            local tb = string.split(buySkillStr,"-")
            local function onYes()
                UserData.Fibble:sendBuyFibbleSkillPoint()
            end
            YesCancelLayer:create(string.format("花费%s元宝，购买%s点技能点?", tb[1],tb[2]), onYes)
        end
    end
    Button_addskill:addTouchEventListener(onAddskilButtonClicked)
    Button_addskill:setPressedActionEnabled(true)
    self.right_levelUp.Button_addskill = Button_addskill
    
    self.right_levelUp.Button_addskill:setVisible(UserData.BaseInfo.bySkillPoints <= 0)
 
    
    local Button_back = Panel_right:getChildByName("Button_back")
    local function onBackButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            self.right_levelUp.Panel_right:setVisible(false)
            if self.scheduleUpdate then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdate)
                self.scheduleUpdate = nil
            end
            self.right_Info.Panel_right_pre:setVisible(true)
            self:refreshInfoUI(self.currentSelectSkillID)

            local name = "FlySkillLead"
            if UserData.NewHandLead:getGuideState(name) == 0 and UserData.NewHandLead.GuideList[name].curStep == 4 then
                UserData.NewHandLead.GuideList[name].curStep = 3
                if self.Node_newHand ~= nil then 
                    self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[name].step[3].handPos)
                end
            end
        end
    end
    Button_back:addTouchEventListener(onBackButtonClicked)
    Button_back:setPressedActionEnabled(true)
    self.Button_back = Button_back
    
    -- 对字体进行描边
    local Text_LevelUP = Button_skill_level_up:getChildByName("Text_24_0")   
    local Text_Back = Button_back:getChildByName("Text_24")    
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_LevelUP)
    outLineLable:setTexOutLine(Text_Back)       
end

function FlySkillLayer:initInfoUI(Panel)
    local Panel_right_pre = Panel:getChildByName("Panel_right_pre")  
    self.right_Info.Panel_right_pre = Panel_right_pre
    local Image_skill_bg = Panel_right_pre:getChildByName("Image_skill_bg")
    local flySkillBg = Image_skill_bg:getChildByName("flySkillBg")
    self.right_Info.Image_skill_icon = Image_skill_bg:getChildByName("Image_skill_icon")   
    self.right_Info.skillType = Image_skill_bg:getChildByName("skillType")
    self.right_Info.skillNameText = Image_skill_bg:getChildByName("skillNameText")
    self.right_Info.skillLevelText = flySkillBg:getChildByName("skillLevelText")

    local Image_sudu = Panel_right_pre:getChildByName("Image_sudu") 
    local Image_nengliang = Panel_right_pre:getChildByName("Image_nengliang") 
    local Image_weili = Panel_right_pre:getChildByName("Image_weili") 
    local Image_cd = Panel_right_pre:getChildByName("Image_cd") 

    local Image_number_table2 = {
        [1] = Image_nengliang:getChildByName("Image_number"),
        [2] = Image_weili:getChildByName("Image_number"),
        [3] = Image_sudu:getChildByName("Image_number"),
        [4] = Image_cd:getChildByName("Image_number"),
    } 

    self.right_Info.baseInf_value = {}
    for i=1,4 do
        self.right_Info.baseInf_value[i] = {}
        self.right_Info.baseInf_value[i].Text_number = Image_number_table2[i]:getChildByName("Text_number")
    end
    
    local ScrollView_info = Panel_right_pre:getChildByName("ScrollView_info") 
    self.right_Info.ScrollView_info = ScrollView_info
    self.right_Info.Image_jianjie = ScrollView_info:getChildByName("Image_jianjie") 
    self.right_Info.Text_jianjie = ScrollView_info:getChildByName("Text_jianjie")
    self.right_Info.Image_ExtraEffect = ScrollView_info:getChildByName("Image_ExtraEffect")
    self.right_Info.Text_extra_effect = ScrollView_info:getChildByName("Text_extra_effect") 

    local Button_To_level_up = Panel_right_pre:getChildByName("Button_To_level_up") 
    local function onToLEvelUpButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            --local nSkillId = self.currentSelectSkillID
            self.right_levelUp.Panel_right:setVisible(true)
            self.right_Info.Panel_right_pre:setVisible(false)
            self:refreshLevelupUI(self.currentSelectSkillID)

            local name = "FlySkillLead"
            if UserData.NewHandLead:getGuideState(name) == 0 and UserData.NewHandLead.GuideList[name].curStep == 3 then
                UserData.NewHandLead.GuideList[name].curStep = 4
                if self.Node_newHand ~= nil then 
                    self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[name].step[4].handPos)
                end
            end
        end
    end
    Button_To_level_up:addTouchEventListener(onToLEvelUpButtonClicked)
    Button_To_level_up:setPressedActionEnabled(true)
    
    -- 对字体进行描边
    local Text_LevelUP = Button_To_level_up:getChildByName("Text_1")    
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_LevelUP)       
end

function FlySkillLayer:refreshInfoUI(skillID)
    local sData  = FightStaticData.flyingObjectSkill[skillID]
    local skillInfo = UserData.Fibble:getSkillInfo(skillID)
    if skillInfo == nil or sData == nil then
        return
    end
    local PlayerDetails = require("app.views.public.PlayerDetails")
    local skillWithoutFly = PlayerDetails:getSkillDetatilsWithoutFlyObject(skillID)
    local baseInfo = {
        [1] = {number = skillWithoutFly.Skill_Hp},
        [2] = {number = skillWithoutFly.Skill_Atk},
        [3] = {number = skillWithoutFly.speed},
        [4] = {number = skillWithoutFly.cdTime},        
    }
    
    self.right_Info.Image_skill_icon:loadTexture(sData.icon,0)  
    
    local propertyType =  sData.propertyType
    propertyType = propertyType < 1 and 1 or propertyType
    propertyType = propertyType > 3 and 3 or propertyType
    local strType = {"机械系","神仙系","神兽系"}
    self.right_Info.skillType:setString(strType[propertyType])
    self.right_Info.skillNameText:setString(skillInfo.name)
    self.right_Info.skillLevelText:setString(string.format("Lv%d",skillInfo.level))
    self.right_Info.skillLevelText:setColor(cc.c3b(255,255,0))
    
    for i=1,4 do
        local numStr = tostring(baseInfo[i].number)
        if i==4 then
            numStr = tostring(baseInfo[i].number/10000) .. "秒"
        end
        self.right_Info.baseInf_value[i].Text_number:setString(numStr)
    end
    
   -- self.right_Info.ScrollView_info:setCon
    local size1 = self.right_Info.Image_jianjie:getContentSize()
    local size2 = self.right_Info.Image_ExtraEffect:getContentSize()
    self.right_Info.Text_jianjie:setString(sData.des)
    local effectStr = PlayerDetails:getSkillBufferDes(skillID)
    self.right_Info.Text_extra_effect:setString(effectStr)
    self.right_Info.Image_ExtraEffect:setVisible(effectStr ~= "")
    self.right_Info.Text_extra_effect:setVisible(effectStr ~= "")
    

end

function FlySkillLayer:refreshLevelupUI(skillID)
    local sData  = FightStaticData.flyingObjectSkill[skillID]
    local skillInfo = UserData.Fibble:getSkillInfo(skillID)
    if skillInfo == nil or sData == nil then
        return
    end
--    self:setItemInfo(skillInfo)
--    self.right_levelUp.Text_level_up_need:setString(tostring(skillInfo.level*10))
--    self.right_levelUp.Text_skill_point:setString(tostring(UserData.BaseInfo.bySkillPoints))
    
    --self.right_levelUp.Image_level_up_need = Panel_right:getChildByName("Image_level_up_need")  -- 升级技能需要的货币类型图标
    local PlayerDetails = require("app.views.public.PlayerDetails")
    local skillWithoutFly = PlayerDetails:getSkillDetatilsWithoutFlyObject(skillID)
    local baseInfo = {
        [1] = {number = skillWithoutFly.Skill_Hp,
                add = skillWithoutFly.Skill_Hp_Next - skillWithoutFly.Skill_Hp },
        [2] = {number = skillWithoutFly.Skill_Atk,
                add = skillWithoutFly.Skill_Atk_Next - skillWithoutFly.Skill_Atk },
        [3] = {number = skillWithoutFly.speed,
            add = skillWithoutFly.speed_Next- skillWithoutFly.speed },
        [4] = {number = skillWithoutFly.cdTime,
                add = skillWithoutFly.cdTime_Next- skillWithoutFly.cdTime },        
    }
    for i=1,4 do
        local numStr = tostring(baseInfo[i].number)
        if i==4 then
            numStr = tostring(baseInfo[i].number/10000) .. "秒"
        end
        
        self.right_levelUp.levelup_value[i].Text_number:setString(numStr)
        self.right_levelUp.levelup_value[i].Text_add:setString("+" .. tostring(baseInfo[i].add))
        self.right_levelUp.levelup_value[i].Image_jiantou:setVisible(baseInfo[i].add ~= 0)
        self.right_levelUp.levelup_value[i].Text_add:setVisible(baseInfo[i].add ~= 0)
    end
    
    local skillNode = self.right_levelUp.FileNode_skill_before:getChildByName("skillNode")
    if skillNode == nil then
        skillNode = cc.CSLoader:createNode("csb/SkillNode.csb")
        self.right_levelUp.FileNode_skill_before:addChild(skillNode)
        skillNode:setName("skillNode")
    end 
    local skillNode1 = self.right_levelUp.FileNode_skill_after:getChildByName("skillNode")
    if skillNode1 == nil then
        skillNode1 = cc.CSLoader:createNode("csb/SkillNode.csb")
        self.right_levelUp.FileNode_skill_after:addChild(skillNode1)
        skillNode1:setName("skillNode")
    end 
    
    local skillNodePanel = skillNode:getChildByName("Panel")
    local skillBtn = skillNodePanel:getChildByName("skillBtn")    
    local skillName = skillBtn:getChildByName("skillNameText")
    local skill_bg = skillBtn:getChildByName("skill_bg")
    local skillLevel = skill_bg:getChildByName("skillLevelText")   
    local selectSkill = skillNodePanel:getChildByName("selectSkill")  

    local skillNodePanel1 = skillNode1:getChildByName("Panel")
    local skillBtn1 = skillNodePanel1:getChildByName("skillBtn")    
    local skillName1 = skillBtn1:getChildByName("skillNameText")
    local skill_bg1 = skillBtn1:getChildByName("skill_bg")
    local skillLevel1 = skill_bg1:getChildByName("skillLevelText")   
    local selectSkill1 = skillNodePanel1:getChildByName("selectSkill")  
    
    
    skillName:setString(skillInfo.name)
    skillName1:setString(skillInfo.name)
    
    skillLevel:setString(string.format("Lv%d",skillInfo.level))
    skillLevel1:setString(string.format("Lv%d",skillInfo.level + 1))
    
    --skillBtn:set
    skillBtn:loadTextures(sData.icon, sData.icon,sData.icon) --设置底图
    skillBtn1:loadTextures(sData.icon, sData.icon,sData.icon) --设置底图
    
    skillLevel:setColor(cc.c3b(255,255,0))
    skillLevel1:setColor(cc.c3b(255,255,0))
    
    selectSkill:setVisible(false)
    selectSkill1:setVisible(false)
    
    
    self:updateRemainTime()
    if self.scheduleUpdate and type(self.scheduleUpdate) == "number" then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdate)
        self.scheduleUpdate = nil
    end
    self.scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) 
        self:updateUI(dt)
    end, 1 ,false)
    

end

function FlySkillLayer:updateRemainTime()
    -- 恢复满最大技能点数
    local MaxPoints = StaticData.SystemParam['BaseSkillPoints'].IntValue 
    local baseInfo = UserData.BaseInfo
    -- 最近一次技能点回复时间(服务器有计算离线时间)，此时间一定会小于时间恢复间隔，
    local duration = TimeFormat:getSecondsInter(UserData.BaseInfo.sRecoverSkillPoints)
    
    self.nextRemain = 0  -- 恢复下一点技能点所需要的秒数
    self.allRemain = 0   -- 恢复全部技能点所需要的秒数
    
    if UserData.BaseInfo.bySkillPoints < MaxPoints then  --技能点还未恢复满
        local secNums = StaticData.SystemParam["RecoverSkillPoints"].IntValue/1000
        self.allRemain = (MaxPoints - UserData.BaseInfo.bySkillPoints) * secNums - duration
        allRemain = self.allRemain
        self.allRemain = self.allRemain < 0  and 0 or self.allRemain
        
        self.nextRemain = self.allRemain == 0 and 0 or (secNums - duration)
        nextRemain = self.nextRemain
        self.nextRemain = self.nextRemain < 0  and 0 or self.nextRemain
        self.nextRemain = self.nextRemain > secNums  and secNums or self.nextRemain
    end
    
    allRemain = self.allRemain
    nextRemain = self.nextRemain
    
    self.right_levelUp.Button_addskill:setVisible(UserData.BaseInfo.bySkillPoints <= 0)

    if self.allRemain == 0 then
        self.right_levelUp.Text_time_count:setString("(已满)")
        
        self.right_levelUp.Text_skill_point:setString(tostring(MaxPoints))
    end
end

function FlySkillLayer:initSkillList()
    if self.wnd_list.ScrollView_skill_list:getChildrenCount() > 0 then
        self.wnd_list.ScrollView_skill_list:removeAllChildren()
    end
    
    self.Node_newHand_inView = cc.Node:create()
    self.wnd_list.ScrollView_skill_list:addChild(self.Node_newHand_inView,10)
    
    local curUsedSkillList = {}
    local curnFibbleId = UserData.BaseInfo.nFibbleId
    if curnFibbleId > 0 and UserData.Fibble.fibbleTable[curnFibbleId] ~= nil and  UserData.Fibble.fibbleTable[curnFibbleId][1] ~= nil then
        curUsedSkillList[UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId1] = UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId1
        curUsedSkillList[UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId2] = UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId2
        curUsedSkillList[UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId3] = UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId3
        curUsedSkillList[UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId4] = UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId4
    end
    
    local dataNum = table.nums(UserData.Fibble.skillOrderList)
    local szScrollView = self.wnd_list.ScrollView_skill_list:getContentSize()
    local itemSize = self.wnd_list.skillItem_mode:getContentSize()
    local SCROLL_ITEM_SIZE = itemSize  --单个滚动item的尺寸
    local seperate_num = 3
    local totalHeight = SCROLL_ITEM_SIZE.height * math.ceil(dataNum/seperate_num)
    totalHeight = (totalHeight < szScrollView.height) and szScrollView.height or totalHeight
    self.wnd_list.ScrollView_skill_list:setInnerContainerSize(cc.size(szScrollView.width,totalHeight))
    self.wnd_list.itemList = {}
    for i=1, dataNum do
        local skillID = UserData.Fibble.skillOrderList[i].id
        local skillInfo = UserData.Fibble:getSkillInfo(skillID)
        local isUsed = curUsedSkillList[skillID] ~= nil
        self.wnd_list.itemList[skillID] = {}
        local itemNew = self:createSkillItem(skillInfo,isUsed)
        if itemNew ~= nil then
        
            itemNew:setName("skill_" .. tostring(skillInfo.id))
            
            
            self:setItemInfo(skillInfo,isUsed)
            
            local posx = (i-1)%seperate_num * SCROLL_ITEM_SIZE.width
            local posy = totalHeight - math.floor((i-1)/seperate_num) *SCROLL_ITEM_SIZE.height
            itemNew:setPosition(posx + SCROLL_ITEM_SIZE.width/2 ,posy - SCROLL_ITEM_SIZE.height/2 )
            
            itemNew:setBackGroundColorType(0) -- ccui.LayoutBackGroundColorType.NONE)
--            itemNew:setBackGroundColor(cc.c3b(128, 0+i*10, 128))
--            itemNew:setBackGroundColorOpacity(64)
        end    
    end

end


function FlySkillLayer:createSkillItem(skillInfo,isUsed)
    if self.wnd_list.skillItem_mode == nil then
        cclog("createSkillItem(skillInfo) ... skillItem_mode is nil")
    end
    
    local skill_item = self.wnd_list.skillItem_mode:clone()
    local function onItemClicked(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local senderName = sender:getName()
            cclog("FlySkillLayer onItemClicked,name = "  .. senderName)
            local id = string.sub(senderName,string.len("skill_")+1,string.len(senderName))
            cclog("FlySkillLayer onItemClicked,skill_id = "  .. id)
            self:selectSkill(tonumber(id))

            local name = "FlySkillLead"
            if UserData.NewHandLead:getGuideState(name) == 0 and UserData.NewHandLead.GuideList[name].curStep == 2 then
                UserData.NewHandLead.GuideList[name].curStep = 3
                if self.Node_newHand_inView ~= nil then 
                    self.Node_newHand_inView:removeFromParent()
                    self.Node_newHand_inView = nil
                end
                if self.Node_newHand ~= nil then 
                    UserData.NewHandLead:addHandTo(self.Node_newHand)
                    self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[name].step[3].handPos)
                end
            end
            
        end
    end
    skill_item:setTouchEnabled(true)
    skill_item:setVisible(true)
    skill_item:setAnchorPoint(cc.p(0.5,0.5))
    skill_item:addTouchEventListener(onItemClicked)
    
    local Image_skill_bg = skill_item:getChildByName("Image_skill_bg")
    Image_skill_bg:loadTexture("items/skill/SkillFrame.png",0)
    local Image_skill_icon = Image_skill_bg:getChildByName("Image_skill_icon")
    local skillIconPath = FightStaticData.flyingObjectSkill[skillInfo.id].icon
    if Image_skill_icon ~= nil then
        Image_skill_icon:loadTexture(skillIconPath,0)
    end
    self.wnd_list.ScrollView_skill_list:addChild(skill_item)
    --Image_skill_icon:ignoreContentAdaptWithSize(false)
    Image_skill_icon:setContentSize(cc.size(75, 75))
    local Image_can_level_up = Image_skill_bg:getChildByName("Image_can_level_up")
    local skillNameText = Image_skill_bg:getChildByName("skillNameText")
    local skill_bg_level = Image_skill_bg:getChildByName("skill_bg_level")
    local skillLevelText = skill_bg_level:getChildByName("skillLevelText")
    
    local Image_select = Image_skill_bg:getChildByName("Image_select")
    Image_select:setVisible(false)
    cclog("skillInfo.id = " .. tostring(skillInfo.id))
    
    self.wnd_list.itemList[skillInfo.id].parent = skill_item
    self.wnd_list.itemList[skillInfo.id].Image_skill_icon = Image_skill_icon
    self.wnd_list.itemList[skillInfo.id].skillNameText = skillNameText
    self.wnd_list.itemList[skillInfo.id].skillLevelText = skillLevelText
    self.wnd_list.itemList[skillInfo.id].Image_can_level_up = Image_can_level_up
    self.wnd_list.itemList[skillInfo.id].Image_select = Image_select
    
    self.wnd_list.itemList[skillInfo.id].Image_Used = Image_skill_bg:getChildByName("Image_Used")
    self.wnd_list.itemList[skillInfo.id].Image_Used:setVisible(isUsed)
    return skill_item
end



function FlySkillLayer:setItemInfo(skillInfo)
    local itemlist = self.wnd_list.itemList
    if self.wnd_list.itemList[skillInfo.id] == nil or self.wnd_list.itemList[skillInfo.id].skillNameText == nil or self.wnd_list.itemList[skillInfo.id].skillLevelText == nil then
        return
    end
   
    self.wnd_list.itemList[skillInfo.id].skillNameText:setString(skillInfo.name)
    self.wnd_list.itemList[skillInfo.id].skillLevelText:setString("Lv" .. tostring(skillInfo.level))
    
    local canLevelUp = self:getSkillLevelUpState(skillInfo)
    self.wnd_list.itemList[skillInfo.id].Image_can_level_up:setVisible(canLevelUp)
    --if canLevelUp then
        --self.wnd_list.itemList[skillInfo.id].Image_can_level_up:stopAllActions()
        
    --local moveto1 = cc.MoveTo:create(0.5, cc.p(85,75-2))
    --local moveto2 = cc.MoveTo:create(0.5, cc.p(85,75+2))
    --self.wnd_list.itemList[skillInfo.id].Image_can_level_up:runAction(cc.RepeatForever:create(cc.Sequence:create(moveto1,moveto2)))
    --end
end

function FlySkillLayer:selectSkill(skillID)
    self.lastSelectSkillID = self.currentSelectSkillID
    self.currentSelectSkillID = skillID

    local skillInfo = UserData.Fibble:getSkillInfo(skillID)
    self:setItemInfo(skillInfo)
    self.right_levelUp.Text_level_up_need:setString(tostring(skillInfo.level*10))
    self.right_levelUp.Text_skill_point:setString(tostring(UserData.BaseInfo.bySkillPoints))
    
    
    self:updateSelectMark(skillID)
    
    if self.right_levelUp.Panel_right:isVisible() then
        self:refreshLevelupUI(skillID)
    end
    if self.right_Info.Panel_right_pre:isVisible() then
        self:refreshInfoUI(skillID)
    end
    
end


function FlySkillLayer:updateSelectMark(skillID)
    
    if self.lastSelectSkillID > 0 then
        self.wnd_list.itemList[self.lastSelectSkillID].Image_select:setVisible(false)
    end
    self.wnd_list.itemList[skillID].Image_select:setVisible(true)
    self.lastSelectSkillID = skillID

end

function FlySkillLayer:OnSkillUp(event)
    local eventParam = event._usedata
    local byRes = eventParam.res
    local nSkillId = eventParam.nSkillId
    local nLevel = eventParam.nSkillLevel
    
    if byRes == 0 then  -- 0:成功,1:技能ID错误，2：技能等级上限,3:技能点不够 4:金币不足
        self:selectSkill(nSkillId)
        publicTipLayer:setTextAction("飞宝技能等级升级成功！")
        self:updateRemainTime()
        self:UpdateAllSkillUpdateState()
    else
        if byRes == 2 then 
            publicTipLayer:setTextAction("技能等级达到上限！")
        elseif byRes == 3 then 
            publicTipLayer:setTextAction("技能点不够！")
        elseif byRes == 4 then 
            publicTipLayer:setTextAction("金币不足！")
        end
    end

end

function FlySkillLayer:updateUI(dt)
    if self.allRemain == 0 then
        return
    end
    
    local baseInfo = UserData.BaseInfo
    self.allRemain = self.allRemain - dt
    self.nextRemain = self.nextRemain - dt

    allRemain = self.allRemain
    nextRemain = self.nextRemain
    
    local secNums = StaticData.SystemParam["RecoverSkillPoints"].IntValue/1000
    if self.nextRemain < 0 then
        self.nextRemain = self.allRemain % (secNums)
    end
    nextRemain = self.nextRemain
    local MaxPoints = StaticData.SystemParam['BaseSkillPoints'].IntValue 
    if self.allRemain <= 0 or baseInfo.bySkillPoints >= MaxPoints then
        self.right_levelUp.Text_time_count:setString("(已满)")
        self.right_levelUp.Text_skill_point:setString(tostring(MaxPoints))
    else
        local nh, nm, ns = self:getHMS(math.floor(self.nextRemain))
        --local ah, am, as = self:getHMS(math.floor(self.allRemain))

        self.right_levelUp.Text_time_count:setString(string.format("(%02d:%02d)",nm,ns))
        
        if nm == 0 and ns < 2 then
            self.right_levelUp.Text_skill_point:setString(tostring(UserData.BaseInfo.bySkillPoints))
            self.right_levelUp.Button_addskill:setVisible(UserData.BaseInfo.bySkillPoints <= 0)
            
        end
    end

end

-- 获取时分秒
function FlySkillLayer:getHMS(s)

    local h = math.modf(s/60/60)
    s = s - h * 60 * 60
    local m = math.modf(s/60)
    s = s - m * 60 

    return h, m, s
end

function FlySkillLayer:refreshSkillPoint()
    self.right_levelUp.Text_skill_point:setString(tostring(UserData.BaseInfo.bySkillPoints))
    local baseInfo = UserData.BaseInfo
    self:updateRemainTime()
end

function FlySkillLayer:getSkillLevelUpState(skillInfo)
    return UserData.BaseInfo.bySkillPoints > 0 and  UserData.BaseInfo.userGold > skillInfo.level*10 and UserData.BaseInfo.userLevel > skillInfo.level
end

function FlySkillLayer:getSelectWndPositionBySkillID(skillID)
    if self.wnd_list.itemList[skillID].parent ~= nil then
        local posX,posY = self.wnd_list.itemList[skillID].parent:getPosition()
        --local parentPosX,parentPosY = self.wnd_list.ScrollView_skill_list:getPosition()
        --return posX + parentPosX ,posY + parentPosY
        return posX,posY
    end
    return nil
end

function FlySkillLayer:UpdateAllSkillUpdateState()

    --当前飞宝使用的技能
    local curUsedSkillList = {}
    local curnFibbleId = UserData.BaseInfo.nFibbleId
    if curnFibbleId > 0 and UserData.Fibble.fibbleTable[curnFibbleId] ~= nil and  UserData.Fibble.fibbleTable[curnFibbleId][1] ~= nil then
        curUsedSkillList[UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId1] = UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId1
        curUsedSkillList[UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId2] = UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId2
        curUsedSkillList[UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId3] = UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId3
        curUsedSkillList[UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId4] = UserData.Fibble.fibbleTable[curnFibbleId][1].nSkillId4
    end

    for key ,value in pairs(self.wnd_list.itemList) do
        local skillID = tonumber(key)
        local isUsed = curUsedSkillList[skillID] ~= nil
        local skillInfo = UserData.Fibble:getSkillInfo(skillID)
        local canLevelUp = self:getSkillLevelUpState(skillInfo)
        self.wnd_list.itemList[skillInfo.id].Image_can_level_up:setVisible(canLevelUp)
    end
end

function FlySkillLayer:OnBuyFibbleSkillPoint(event)
    local byRes = event._usedata
    if byRes == 0 then
        --此处不需要刷新，技能点改变会刷新
        publicTipLayer:setTextAction("技能点购买成功")
        self:UpdateAllSkillUpdateState()
    elseif byRes == 1 then
        --print("不符合购买条件")
    elseif byRes == 2 then
        YesCancelLayer:create("元宝不足，是否充值?",function()
            --显示充值界面
        end)
    end
end


return FlySkillLayer