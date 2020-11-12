local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local ItemManager =  require("src.app.views.ItemManager")
local publicTipLayer = require("app/views/public/publicTipLayer")
local GodwillManager = require("app.views.Godwill.GodwillManager")

local goodsNode = require("app.views.public.goodsNode")
local FlyMakeMatLayer = require("app.views.public.FlyMakeMatLayer")
        
local GodwillInfoLayer = class("GodwillInfoLayer", function()
    return ccui.Layout:create()
end)

function GodwillInfoLayer:create()
    local view = GodwillInfoLayer.new()
    view:init()
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

function GodwillInfoLayer:ctor()
                                                                           --是否是选择的 道具不足的时候使用元宝
end

function GodwillInfoLayer:onEnter()
    EventMgr:registListener(EventType.OnGodLevelUp, self, self.OnGodLevelUp)                     -- 服务端返回神将提升星级请求
    EventMgr:registListener(EventType.OnGodStarUp, self, self.OnGodStarUp)                       -- 服务端返回神将提升星级请求
    
    
    local name = nil
    local curGuideName = UserData.NewHandLead:getCurrentGuideName()
    if curGuideName == "GodWillLead_levelup" or curGuideName == "GodWillLead_starUp" then
        name = curGuideName
    end

    if name ~= nil and UserData.NewHandLead.GuideList[name] ~= nil then
        if UserData.NewHandLead:getGuideState(name) == 0 and UserData.NewHandLead.GuideList[name].curStep == 2 then
            UserData.NewHandLead.GuideList[name].curStep = 3
            if self.Node_newHand ~= nil then 
                UserData.NewHandLead:addHandTo(self.Node_newHand)
                self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[name].step[3].handPos)
            end
        end
    end

end

function GodwillInfoLayer:onExit()
    EventMgr:unregistListener(EventType.OnGodLevelUp, self, self.OnGodLevelUp)                     -- 服务端返回神将提升星级请求
    EventMgr:unregistListener(EventType.OnGodStarUp, self, self.OnGodStarUp)                       -- 服务端返回神将提升星级请求
    
end

function GodwillInfoLayer:createItemExtra(itemID,parent)
    local function touchEvent(sender, eventType)
        if eventType == cc.EventCode.ENDED then           
            local goodsNum = UserData.Bag.items[sender:getTag()]
            local flyMakeMatLayer = FlyMakeMatLayer:create(sender:getTag())
            self:addChild(flyMakeMatLayer)
        end
    end

    local itemWnd = goodsNode:create(itemID)
    itemWnd:btnEvent(touchEvent)
    parent:addChild(itemWnd)
    itemWnd:setVisible(true)
    return itemWnd
end

--初始化
function GodwillInfoLayer:init()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    local rootNode = cc.CSLoader:createNode("csb/GodwillInfoLayer.csb")
    self:addChild(rootNode)
    self.Panel_mark = rootNode:getChildByName("Panel_mark")
    self.Panel_left = rootNode:getChildByName("Panel_left")
    self.Panel_right = rootNode:getChildByName("Panel_right")
    
    --左侧界面
    self.left_window_list = {
        Node_god_anim = self.Panel_left:getChildByName("Node_god_anim"),
        Text_level = self.Panel_left:getChildByName("Text_level"),
        Text_name = self.Panel_left:getChildByName("Text_name"),
        Text_fight_value = self.Panel_left:getChildByName("Text_fight_value"),
        Image_star = {},
    }
    local Panel_star = self.Panel_left:getChildByName("Panel_star")
    for i=1,5 do
        self.left_window_list.Image_star[i] = Panel_star:getChildByName("Image_star_" .. tostring(i))
    end

    self.Button_property_tab = self.Panel_left:getChildByName("Button_property_tab")
    self.Button_levelup_tab = self.Panel_left:getChildByName("Button_levelup_tab")
    self.Button_starup_tab = self.Panel_left:getChildByName("Button_starup_tab")
    
    
    --右侧界面
    local Panel_skill = self.Panel_right:getChildByName("Panel_skill")
    local Panel_level_up = self.Panel_right:getChildByName("Panel_level_up")
    local Panel_star_up = self.Panel_right:getChildByName("Panel_star_up")
    self.Panel_skill = Panel_skill
    self.Panel_level_up = Panel_level_up
    self.Panel_star_up = Panel_star_up
   
    -- Panel_skill
    local image_nengliang = Panel_skill:getChildByName("Image_nengliang")
    local Image_nengliang_number = image_nengliang:getChildByName("Image_number")
    local image_weili = Panel_skill:getChildByName("Image_weili")
    local Image_weili_number = image_weili:getChildByName("Image_number")
    local image_sudu = Panel_skill:getChildByName("Image_sudu")
    local Image_sudu_number = image_sudu:getChildByName("Image_number")
    local image_cd = Panel_skill:getChildByName("Image_cd")
    local Image_cd_number = image_cd:getChildByName("Image_number")
    self.Panel_skill_window_list = { 
--        Image_skill_icon = Panel_skill:getChildByName("Image_skill_icon"),
--        Text_skill_name = Panel_skill:getChildByName("Text_skill_name"),
--        Text_need_energy = Panel_skill:getChildByName("Text_need_energy"),
--        Text_level = Panel_skill:getChildByName("Text_level"),
--        Image_quality = Panel_skill:getChildByName("Image_quality"),
        Text_descrip = Panel_skill:getChildByName("Text_descrip"),
        ScrollView_property = Panel_skill:getChildByName("ScrollView_property"),
        Skill_Node = Panel_skill:getChildByName("Node_1"),
        nengliang = Image_nengliang_number:getChildByName("Text_number"),
        weili = Image_weili_number:getChildByName("Text_number"),
        sudu = Image_sudu_number:getChildByName("Text_number"),
        cd = Image_cd_number:getChildByName("Text_number"),
        skill_des = Panel_skill:getChildByName("Text_skill_des"),
    }
    self.Panel_skill_window_list.ScrollView_property:setVisible(false)

    -- Panel_star_up
    self.Panel_star_up_window_list = { 
--        Text_mode = Panel_star_up:getChildByName("Text_mode"),
--        Text_effect = Panel_star_up:getChildByName("Text_effect"),
        Button_star_up = Panel_star_up:getChildByName("Button_star_up"),
        Image_item = {},
        Text_item_num = {},
        Node_Tips = {},        
    }
    local Panel_item = Panel_star_up:getChildByName("Panel_item")
    for i=1,4 do
        local Image_item_bg = Panel_item:getChildByName("Image_item_bg_" .. tostring(i))
        self.Panel_star_up_window_list.Image_item[i] = Image_item_bg:getChildByName("Image_item")

        self.Panel_star_up_window_list.Text_item_num[i] = Panel_item:getChildByName("Text_item_num_" .. tostring(i)) 
        
        self.Panel_star_up_window_list.Node_Tips[i] = Panel_item:getChildByName("Node_Tips" ..tostring(i))
    end

    local Image_item_bg_1 = Panel_level_up:getChildByName("Image_item_bg_1")
--    local Image_item_bg_2 = Panel_level_up:getChildByName("Image_item_bg_2")
--    local Panel_levelup_pre = Panel_level_up:getChildByName("Panel_levelup_pre")
--    local Panel_levelup_after = Panel_level_up:getChildByName("Panel_levelup_after")
--    local Image_head_bg_pre = Panel_levelup_pre:getChildByName("Image_head_bg")
--    local Image_head_bg_after = Panel_levelup_after:getChildByName("Image_head_bg")
    
    -- Panel_level_up
    local image_nengliang_level = Panel_level_up:getChildByName("Image_nengliang")
    local Image_nengliang_number_level = image_nengliang_level:getChildByName("Image_number")
    local image_weili_level = Panel_level_up:getChildByName("Image_weili")
    local Image_weili_number_level = image_weili_level:getChildByName("Image_number")
    local image_sudu_level = Panel_level_up:getChildByName("Image_sudu")
    local Image_sudu_number_level = image_sudu_level:getChildByName("Image_number")
    local image_cd_level = Panel_level_up:getChildByName("Image_cd")
    local Image_cd_number_level = image_cd_level:getChildByName("Image_number")
    self.Panel_level_up_window_list = { 
        Image_item_need = Image_item_bg_1:getChildByName("Image_item_need"),
        Text_items_num = Image_item_bg_1:getChildByName("Text_items_num"),
       -- Text_item_name = Panel_level_up:getChildByName("Text_item_name"),
        
     --   Image_coin_need = Image_item_bg_2:getChildByName("Image_coin_need"),
        Text_coin_need = Panel_level_up:getChildByName("Text_coin_need"),

        Button_level_up = Panel_level_up:getChildByName("Button_level_up"),

--        Panel_levelup_pre = {
--            Text_attack = Panel_levelup_pre:getChildByName("Text_attack"),
--            Text_hp = Panel_levelup_pre:getChildByName("Text_hp"),
--            Image_head = Image_head_bg_pre:getChildByName("Image_head"),
--            Text_level = Image_head_bg_pre:getChildByName("Text_level"),
--        },
--
--        Panel_levelup_after = {
--            Text_attack = Panel_levelup_after:getChildByName("Text_attack"),
--            Text_attack_added = Panel_levelup_after:getChildByName("Text_attack_added"),
        --            Text_hp = Panel_levelup_after:getChildByName("Text_hp"),
        --            Text_hp_added = Panel_levelup_after:getChildByName("Text_hp_added"),
        --            Image_head = Image_head_bg_after:getChildByName("Image_head"),
        --            Text_level = Image_head_bg_after:getChildByName("Text_level"),
        --        },

        Skill_Node_Pre = Panel_level_up:getChildByName("Node_skill_pre"),
        Skill_Node_after = Panel_level_up:getChildByName("Node_skill_after"),
        nengliang = Image_nengliang_number_level:getChildByName("Text_number"),
        addnengliang = Image_nengliang_number_level:getChildByName("Text_add"),
        weili = Image_weili_number_level:getChildByName("Text_number"),
        addweili = Image_weili_number_level:getChildByName("Text_add"),
        sudu = Image_sudu_number_level:getChildByName("Text_number"),
        addsudu = Image_sudu_number_level:getChildByName("Text_add"),
        cd = Image_cd_number_level:getChildByName("Text_number"),
        addcd = Image_cd_number_level:getChildByName("Text_add"),
        image_buy = Panel_level_up:getChildByName("Image_buy"),
        Text_cost = Panel_level_up:getChildByName("Text_Cost"),
        Node_Tips = Panel_level_up:getChildByName("Node_Tips"),

    }

    
    
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local senderName = sender:getName()
            cclog("GodwillInfoLayer onEventTouchButton,name = "  .. senderName)
            if senderName == "Button_close" then
                
                local name = nil
                local curGuideName = UserData.NewHandLead:getCurrentGuideName()
                if curGuideName == "GodWillLead_levelup" or curGuideName == "GodWillLead_starUp" then
                    name = curGuideName
                end
            
                if name ~= nil and UserData.NewHandLead.GuideList[name] ~= nil then
                    if UserData.NewHandLead:getGuideState(name) == 0 then
                        UserData.NewHandLead.GuideList[name].curStep = 1
                        local SceneManager = require("app.views.SceneManager")
                        local layer = SceneManager:getGameLayer("GodwillListLayer")
                        layer:showNewGuide()
                    end
                    
                end
                
                self:removeFromParent()
                
            elseif senderName == "Button_level_up" then
                if self.godwillID ~= nil and self.godwillID > 0 then
                    UserData.Godwill:sendGodLevelUp(self.godwillID)

                    local name = "GodWillLead_levelup"
                    local guideState = UserData.NewHandLead:getGuideState(name)
                    if guideState == 0 then
                        if UserData.NewHandLead.GuideList[name].curStep == 4 then
                            UserData.NewHandLead.GuideList[name].curStep = 5
                            if self.Node_newHand ~= nil then 
                                self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[name].step[5].handPos)
                            end
                            UserData.NewHandLead:CompleteGuide(name)
                        end
                    end
                end
            elseif senderName == "Button_star_up" then
                if self.godwillID ~= nil and self.godwillID > 0 then
                    UserData.Godwill:sendGodStarUp(self.godwillID)
                
                
                    local name = "GodWillLead_starUp"
                    
                    if UserData.NewHandLead.GuideList[name] ~= nil then
                        local guideState = UserData.NewHandLead:getGuideState(name)
                        if guideState == 0 then
                            if UserData.NewHandLead.GuideList[name].curStep == 4 then
                                UserData.NewHandLead.GuideList[name].curStep = 5
                                if self.Node_newHand ~= nil then 
                                    self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[name].step[5].handPos)
                                end
                                UserData.NewHandLead:CompleteGuide(name)
                            end
                        end
                    end
                end
            elseif senderName == "Button_property_tab" or senderName == "Button_levelup_tab" or senderName == "Button_starup_tab" then
                self:switchToTab(senderName)
            end
        end
    end
    self.Button_close = rootNode:getChildByName("Button_close")
    self.Button_close:addTouchEventListener(onEventTouchButton)
    self.Button_close:setPressedActionEnabled(true)
    self.Button_close:setTouchEnabled(true)

    self.Button_property_tab:addTouchEventListener(onEventTouchButton)
    self.Button_property_tab:setPressedActionEnabled(true)
    self.Button_property_tab:setTouchEnabled(true)
    self.Button_levelup_tab:addTouchEventListener(onEventTouchButton)
    self.Button_levelup_tab:setPressedActionEnabled(true)
    self.Button_levelup_tab:setTouchEnabled(true)
    self.Button_starup_tab:addTouchEventListener(onEventTouchButton)
    self.Button_starup_tab:setPressedActionEnabled(true)
    self.Button_starup_tab:setTouchEnabled(true)
    

    self.Panel_level_up_window_list.Button_level_up:addTouchEventListener(onEventTouchButton)
    self.Panel_level_up_window_list.Button_level_up:setPressedActionEnabled(true)

    self.Panel_star_up_window_list.Button_star_up:addTouchEventListener(onEventTouchButton)
    self.Panel_star_up_window_list.Button_star_up:setPressedActionEnabled(true)
    
    self.publicTipLayer = publicTipLayer:create()
    
    self.Node_newHand = rootNode:getChildByName("Node_newHand")
end

function GodwillInfoLayer:initGodProperty()
    
    local godwillStaticData = GodwillManager:getGodwillStaticData(self.godwillID)
    local godwillInfo = UserData.Godwill.godList[self.godwillID ]
    local fibbleUPStaticData = GodwillManager:getGodwillFibbleUPStaticData(godwillInfo.id,godwillInfo.star)
    
--    self.Panel_skill_window_list.Image_skill_icon:loadTexture(godwillStaticData.icon)   
--    self.Panel_skill_window_list.Text_skill_name:setString(godwillStaticData.skillName)
--    self.Panel_skill_window_list.Text_need_energy:setString("怒气消耗:" .. tostring(godwillStaticData.needAngry)) 
--    self.Panel_skill_window_list.Text_level:setString("修炼等级:" .. tostring(godwillInfo.level) .. "/" .. tostring(fibbleUPStaticData.preLv))
    self.Panel_skill_window_list.Text_descrip:setString(godwillStaticData.des)
    
    self.Panel_skill_window_list.ScrollView_property:setVisible(false)    
    --self.Panel_skill_window_list.Image_quality:setVisible(false)  
    
    local skillNode = cc.CSLoader:createNode("csb/SkillNode.csb")
    local skillNodePanel = skillNode:getChildByName("Panel")
    local skillBtn = skillNodePanel:getChildByName("skillBtn")    
    local skillName = skillBtn:getChildByName("skillNameText")
    local skill_bg = skillBtn:getChildByName("skill_bg")
    local skillLevel = skill_bg:getChildByName("skillLevelText")   
    local selectSkill = skillNodePanel:getChildByName("selectSkill")  
    self.Panel_skill_window_list.Skill_Node:addChild(skillNode)
    
    local sData  = FightStaticData.flyingObjectSkill[godwillStaticData.skillID]
    skillName:setString(sData.name)
    skillLevel:setString(string.format("Lv%d",godwillInfo.level))
    skillBtn:loadTextures(sData.icon, sData.icon,sData.icon) --设置底图
    local temp = PlayerDetails:getGodDetatils(self.godwillID)
    self.Panel_skill_window_list.nengliang:setString(string.format("%d",temp.God_Hp))
    self.Panel_skill_window_list.weili:setString(string.format("%d",temp.God_Atk))
    self.Panel_skill_window_list.sudu:setString(string.format("%d",sData.speed))
    self.Panel_skill_window_list.cd:setString(string.format("%d",sData.cdTime))
    self.Panel_skill_window_list.skill_des:setString(sData.des)
    selectSkill:setVisible(false)
    
end

function GodwillInfoLayer:initLevelUpUI()
    local godwillStaticData = GodwillManager:getGodwillStaticData(self.godwillID)
    local godwillInfo = UserData.Godwill.godList[self.godwillID ]
    local fibbleUPStaticData = GodwillManager:getGodwillFibbleUPStaticData(godwillInfo.id,godwillInfo.star)
    
    local levelupItemID = GodwillManager:getGodwillLevelUpNeedItems(godwillInfo.star)
    local itemStaticData = StaticData.Item[levelupItemID]
    if itemStaticData ~= nil then
        self.Panel_level_up_window_list.Image_item_need:loadTexture(itemStaticData.ItemIcon)
        self:createItemExtra(levelupItemID,self.Panel_level_up_window_list.Node_Tips)
      --  self.Panel_level_up_window_list.Text_item_name:setString(itemStaticData.ItemName)
    end
   -- self.Panel_level_up_window_list.Text_item_name:setVisible(false)
    local itemNum = ItemManager:getItemNum(levelupItemID)
    self.Panel_level_up_window_list.Text_items_num:setString( tostring(itemNum) .. "/" .. tostring(godwillInfo.level*10))
    local color = itemNum >= godwillInfo.level*10 and cc.c4b(0,255,0,255) or cc.c4b(255,0,0,255)
    self.Panel_level_up_window_list.Text_items_num:setTextColor(color)
    
    --self.Panel_level_up_window_list.Image_coin_need:loadTexture("ui/public/public_other_26.png")
    self.Panel_level_up_window_list.Text_coin_need:setString(tostring(godwillInfo.level*10))

    local grade = godwillStaticData.grade  -- 品阶
    -- hp = (50*grade+30*star+hp) * (level+10)/20
    -- atk = (50*grade+30*star+atk) * (level+10)/40
    local curHP = math.ceil( (50*grade + 30*godwillInfo.star + godwillStaticData.hp) * (godwillInfo.level+10)/20 )
    local curATK = math.ceil( (50*grade + 30*godwillInfo.star + godwillStaticData.atk) * (godwillInfo.level+10)/40 )
    --    self.Panel_level_up_window_list.Panel_levelup_pre.Text_attack:setString("威力:" .. tostring(curHP)) 
    --    self.Panel_level_up_window_list.Panel_levelup_pre.Text_hp:setString("血量:" .. tostring(curATK)) 
    --    self.Panel_level_up_window_list.Panel_levelup_pre.Image_head:loadTexture(fibbleUPStaticData.icon)
    --    self.Panel_level_up_window_list.Panel_levelup_pre.Text_level:setString(tostring(godwillInfo.level))
--    
--    local nextHP = math.ceil( (50*grade + 30*godwillInfo.star + godwillStaticData.hp) * (godwillInfo.level+1+10)/20 )
--    local nextATK = math.ceil( (50*grade + 30*godwillInfo.star + godwillStaticData.atk) * (godwillInfo.level+1+10)/40 )        
--    self.Panel_level_up_window_list.Panel_levelup_after.Text_attack:setString("威力:" .. tostring(nextHP)) 
--    self.Panel_level_up_window_list.Panel_levelup_after.Text_attack_added:setString("+" .. tostring(nextHP - curHP))
--    self.Panel_level_up_window_list.Panel_levelup_after.Text_hp:setString("血量:" .. tostring(nextATK))
--    self.Panel_level_up_window_list.Panel_levelup_after.Text_hp_added:setString("+" .. tostring(nextATK - curATK))
--    self.Panel_level_up_window_list.Panel_levelup_after.Image_head:loadTexture(fibbleUPStaticData.icon)
--    self.Panel_level_up_window_list.Panel_levelup_after.Text_level:setString(tostring(godwillInfo.level+1))

    local skillNode = cc.CSLoader:createNode("csb/SkillNode.csb")
    local skillNodePanel = skillNode:getChildByName("Panel")
    local skillBtn = skillNodePanel:getChildByName("skillBtn")    
    local skillName = skillBtn:getChildByName("skillNameText")
    local skill_bg = skillBtn:getChildByName("skill_bg")
    local skillLevel = skill_bg:getChildByName("skillLevelText")   
    local selectSkill = skillNodePanel:getChildByName("selectSkill")  
   
    local skillNode1 = cc.CSLoader:createNode("csb/SkillNode.csb")
    local skillNodePanel = skillNode1:getChildByName("Panel")
    local skillBtn1 = skillNodePanel:getChildByName("skillBtn")    
    local skillName1 = skillBtn1:getChildByName("skillNameText")
    local skill_bg1 = skillBtn1:getChildByName("skill_bg")
    local skillLevel1 = skill_bg1:getChildByName("skillLevelText")   
    local selectSkill1 = skillNodePanel:getChildByName("selectSkill")  
    
    self.Panel_level_up_window_list.Skill_Node_after:addChild(skillNode1)
    self.Panel_level_up_window_list.Skill_Node_Pre:addChild(skillNode)
    local sData  = FightStaticData.flyingObjectSkill[godwillStaticData.skillID]
    skillName:setString(sData.name)
    skillLevel:setString(string.format("Lv%d",godwillInfo.level))
    skillBtn:loadTextures(sData.icon, sData.icon,sData.icon) --设置底图
    skillBtn1:loadTextures(sData.icon, sData.icon,sData.icon) --设置底图
    skillLevel1:setString(string.format("Lv%d",godwillInfo.level + 1))
    skillLevel1:setColor(cc.c3b(255,255,0))
    
    local temp = PlayerDetails:getGodDetatils(self.godwillID)
    self.Panel_level_up_window_list.nengliang:setString(string.format("%d",temp.God_Hp))
    self.Panel_level_up_window_list.weili:setString(string.format("%d",temp.God_Atk))
    self.Panel_level_up_window_list.sudu:setString(string.format("%d",sData.speed))
    self.Panel_level_up_window_list.cd:setString(string.format("%d",sData.cdTime))    
    
    self.Panel_level_up_window_list.addnengliang:setString(string.format("%d",temp.God_Hp_Next - temp.God_Hp))
    self.Panel_level_up_window_list.addweili:setString(string.format("%d",temp.God_Atk_Next - temp.God_Atk))
    self.Panel_level_up_window_list.addsudu:setString("0")
    self.Panel_level_up_window_list.addcd:setString("0")
    
    self.Panel_level_up_window_list.image_buy:setVisible(false)
    self.Panel_level_up_window_list.Text_cost:setVisible(false)    
    skillName:setVisible(false)
    skillName1:setVisible(false)
    selectSkill:setVisible(false)
    selectSkill1:setVisible(false)
    
    -- 对字体进行描边
    local Text_LevelUP =  self.Panel_level_up_window_list.Button_level_up:getChildByName("Text_3")    
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_LevelUP)        

end

function GodwillInfoLayer:initStarUpUI()

    local godwillStaticData = GodwillManager:getGodwillStaticData(self.godwillID)
    local godwillInfo = UserData.Godwill.godList[self.godwillID ]
    local fibbleUPStaticData = GodwillManager:getGodwillFibbleUPStaticData(godwillInfo.id,godwillInfo.star)
    
   -- self.Panel_star_up_window_list.Text_mode:setString(godwillStaticData.dess)  -- 以燎原之火分2弹道攻击对方1
 --   self.Panel_star_up_window_list.Text_effect:setString(fibbleUPStaticData.godwillSkill) -- "效果:碰撞效果,降低20%损耗，命中效果,威力增加50%")

    local items = GodwillManager:getGodwillStarUpNeedItems(godwillInfo.id,godwillInfo.star + 1)
    for i=1,4 do
        local itemID = items[i].id
        local itemCount = items[i].count
        local itemStaticInfo = StaticData.Item[itemID]
        if itemStaticInfo ~= nil then
            local itemNum = ItemManager:getItemNum(itemID)
            self.Panel_star_up_window_list.Image_item[i]:loadTexture(itemStaticInfo.ItemIcon)
            self.Panel_star_up_window_list.Text_item_num[i]:setString(tostring(itemNum) .. "/" .. tostring(itemCount))
            local color = itemNum >= itemCount and cc.c4b(0,255,0,255) or cc.c4b(255,0,0,255)            
            self.Panel_star_up_window_list.Text_item_num[i]:setTextColor(color) 
            self:createItemExtra(itemID,self.Panel_star_up_window_list.Node_Tips[i])
            cclog("itemid = %d, itemnum = %d, itmecount = %d",itemID,itemNum,itemCount)
        end
        
    end
    
    -- 对字体进行描边
    local Text_StarUP =  self.Panel_star_up_window_list.Button_star_up:getChildByName("Text_1")    
    local outLineLable = require("app.views.public.outLineLable")
    outLineLable:setTtfConfig(24,2)
    outLineLable:setTexOutLine(Text_StarUP)    

end

function GodwillInfoLayer:initPanelLeft()
    local godwillStaticData = GodwillManager:getGodwillStaticData(self.godwillID)
    local godwillInfo = UserData.Godwill.godList[self.godwillID ]
    local fibbleUPStaticData = GodwillManager:getGodwillFibbleUPStaticData(godwillInfo.id,godwillInfo.star)
    
    local name = GodwillManager:getGodwillName(godwillInfo.id,godwillInfo.star)
    local grade = godwillStaticData.grade  -- 品阶
    
    GodwillManager:addGodwillAnimToUI(self.left_window_list.Node_god_anim,godwillInfo.id)
    self.left_window_list.Text_level:setString(godwillInfo.level)
    self.left_window_list.Text_name:setString(name)
    self.left_window_list.Text_fight_value:setString(tostring(godwillInfo.fight))
    for i=1,5 do
        local starIcon = "ui/godwill/godwill_new/levelup/icon_star_gray.png"
        if godwillInfo.star >= i then
            starIcon = "ui/godwill/godwill_new/levelup/icon_star_normal.png"
        end
        self.left_window_list.Image_star[i]:loadTexture(starIcon)
    end

end

function GodwillInfoLayer:initUI(id)
    self.godwillID = id

    local godwillStaticData = GodwillManager:getGodwillStaticData(id)
    if godwillStaticData == nil then
        cclog("have not find godwill with id = %d" ,id )
        return
    end
    local godwill = UserData.Godwill
    local godwillInfo = UserData.Godwill.godList[id]
    if godwillInfo.unlocked == 0 then
        cclog("godwill with id = %d is locked ",id )
        return
    end

    self:initPanelLeft()

    self:switchToTab("Button_property_tab")

end


function  GodwillInfoLayer:OnGodLevelUp(event)
    local eventParam = event._usedata
    local byRes = eventParam.byRes
    local nGodID = eventParam.nGodID
    local nLevel = eventParam.nLevel

    if byRes == 0 then  --0:成功,1:神将不存在,2:材料不足,3:神将等级上限，4:神将星级上限 5:金币不足
        if self.godwillID == nGodID then
            self:initPanelLeft()
            self:initLevelUpUI()
            publicTipLayer:setTextAction("神将等级升级成功！")
    end
    else
        if byRes == 2 then 
            publicTipLayer:setTextAction("材料不足！")
        elseif byRes == 3 then 
            publicTipLayer:setTextAction("神将等级达到上限,请提高星级来解锁等级！")
        elseif byRes == 4 then 
            publicTipLayer:setTextAction("神将星级级达到上限！")
        elseif byRes == 5 then 
            publicTipLayer:setTextAction("金币不足！")
        end
    end
end

function  GodwillInfoLayer:OnGodStarUp(event)
    local eventParam = event._usedata
    local byRes = eventParam.byRes
    local nGodID = eventParam.nGodID
    local byStar = eventParam.byStar
    if byRes == 0 then  -- 0:成功,1:神将ID错误,2:材料不足,3:星级上限,4:等级太低
        if self.godwillID == nGodID then
            self:initPanelLeft()
            self:initStarUpUI()
            publicTipLayer:setTextAction("神将星级升级成功！")
    end
    else   
        if byRes == 2 then 
            publicTipLayer:setTextAction("材料不足！")
        elseif byRes == 3 then 
            publicTipLayer:setTextAction("神将星级级达到上限！")
        elseif byRes == 4 then 
            publicTipLayer:setTextAction("等级太低！")
        end
    end
end


function GodwillInfoLayer:switchToTab(btnName)
    self.Button_property_tab:loadTextureNormal("ui/godwill/godwill_new/levelup/btn_normal_123_47.png")
    self.Button_levelup_tab:loadTextureNormal("ui/godwill/godwill_new/levelup/btn_normal_123_47.png")
    self.Button_starup_tab:loadTextureNormal("ui/godwill/godwill_new/levelup/btn_normal_123_47.png")

    self.Panel_skill:setVisible(false)
    self.Panel_level_up:setVisible(false)
    self.Panel_star_up:setVisible(false)

    if btnName == "Button_property_tab" then
        self.Button_property_tab:loadTextureNormal("ui/godwill/godwill_new/levelup/btn_select_123_47.png")
        self:initGodProperty()
        self.Panel_skill:setVisible(true)
        local curGuideName = UserData.NewHandLead:getCurrentGuideName()
        if curGuideName == "GodWillLead_levelup" or curGuideName == "GodWillLead_starUp" then
            if UserData.NewHandLead.GuideList[curGuideName] ~= nil then
                local guideState = UserData.NewHandLead:getGuideState(curGuideName)
                if guideState == 0 then
                    UserData.NewHandLead.GuideList[curGuideName].curStep = 3
                    if self.Node_newHand ~= nil then 
                        self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[curGuideName].step[3].handPos)
                    end
                end
            end
        end
    elseif btnName == "Button_levelup_tab" then
        self.Button_levelup_tab:loadTextureNormal("ui/godwill/godwill_new/levelup/btn_select_123_47.png")
        self:initLevelUpUI()
        self.Panel_level_up:setVisible(true)
        
        local curGuideName = UserData.NewHandLead:getCurrentGuideName()
        if curGuideName == "GodWillLead_levelup" then
            local guideState = UserData.NewHandLead:getGuideState(curGuideName)
            if guideState == 0 then
                if UserData.NewHandLead.GuideList[curGuideName].curStep == 3 then
                    UserData.NewHandLead.GuideList[curGuideName].curStep = 4
                    if self.Node_newHand ~= nil then 
                        self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[curGuideName].step[4].handPos)
                    end
                end
            end
        elseif curGuideName == "GodWillLead_starUp" then
            if UserData.NewHandLead.GuideList[curGuideName] ~= nil then
                local guideState = UserData.NewHandLead:getGuideState(curGuideName)
                if guideState == 0 then
                    --if UserData.NewHandLead.GuideList[curGuideName].curStep == 3 then
                        if self.Node_newHand ~= nil then 
                            self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[curGuideName].step[3].handPos)
                        end
                        UserData.NewHandLead.GuideList[curGuideName].curStep = 3
                    --end
                end
            end
        end
        
        
    elseif btnName == "Button_starup_tab" then
        self.Button_starup_tab:loadTextureNormal("ui/godwill/godwill_new/levelup/btn_select_123_47.png")
        self:initStarUpUI()   
        self.Panel_star_up:setVisible(true) 
        
        local curGuideName = UserData.NewHandLead:getCurrentGuideName()
        if curGuideName == "GodWillLead_levelup" then
            local guideState = UserData.NewHandLead:getGuideState(curGuideName)
            if guideState == 0 then
                --if UserData.NewHandLead.GuideList[curGuideName].curStep == 3 then
                    if self.Node_newHand ~= nil then 
                        self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[curGuideName].step[3].handPos)
                    end
                    UserData.NewHandLead.GuideList[curGuideName].curStep = 3
                --end
            end
        elseif curGuideName == "GodWillLead_starUp" then
            if UserData.NewHandLead.GuideList[curGuideName] ~= nil then
                local guideState = UserData.NewHandLead:getGuideState(curGuideName)
                if guideState == 0 then
                    if UserData.NewHandLead.GuideList[curGuideName].curStep == 3 then
                        UserData.NewHandLead.GuideList[curGuideName].curStep = 4  
                        if self.Node_newHand ~= nil then 
                            self.Node_newHand:setPosition(UserData.NewHandLead.GuideList[curGuideName].step[4].handPos)
                        end
                    end
                end
            end
        end
        
    end
end



-- 公共的特效
--透明度
function GodwillInfoLayer:fadeAtion(t,opt)
    local act = cc.FadeTo:create(t,opt)
    return act 
end
--缩放
function GodwillInfoLayer:scaAction(t,sca)
    local act = cc.ScaleTo:create(t,sca)
    return act 
end


-- 物品框的
function GodwillInfoLayer:kuangEffect(node)

    local parent = node:getParent()
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


-- 神将强化的 图片放大和粒子飞过去
function GodwillInfoLayer:qianghua_feixingEffect(node)
    local parent = node:getParent()
    local pos = cc.p(0, 0)
    
    local function delCallback(sender)
        sender:removeFromParent()
    end
    
    local guangquan = cc.Sprite:create("fibbleMakeEffect/ui_feibaolianzhig_002.png") 
    guangquan:setPosition(pos)
    parent:addChild(guangquan)
    local fade1 = self:fadeAtion(0.1,255)
    local fade2 = self:fadeAtion(0.1,0)
    local sca1 = self:scaAction(0.1,2)
    local sca2 = self:scaAction(0.1,4)
    local spa1 = cc.Spawn:create(fade1,sca1)
    local spa2 = cc.Spawn:create(fade2,sca2)
    guangquan:runAction(cc.Sequence:create(spa1,spa2,cc.CallFunc:create(delCallback)))
    
    
    -- 粒子效果
    local emitter = cc.ParticleSystemQuad:create("fibbleMakeEffect/ui_p_feibaolianzhi_04.plist")
    emitter:setPosition(pos)
    parent:addChild(emitter)

    local function callback(sender)
        sender:removeFromParent()
      
    end
    local move = cc.MoveBy:create(0.1,cc.p(50,0))
    emitter:runAction(cc.Sequence:create(move,cc.CallFunc:create(callback)))
    
end
--粒子feifuoq 
function GodwillInfoLayer:qianghua_fangda()
	
	
end

return GodwillInfoLayer