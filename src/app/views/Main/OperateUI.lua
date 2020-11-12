
local isMove = false

local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local FlyFunction = require("app.views.FlyTechTree.FlyFunction")
local PublicTipLayer = require("app.views.public.publicTipLayer")

local OperateUI = class("OperateUI", function()
    return cc.Node:create()
end)

function OperateUI:create()
    local node = OperateUI.new()
    node:init()
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            node:onEnter() 
        elseif eventType == "exit" then
            node:onExit() 
        end  
    end  
    node:registerScriptHandler(onEventHandler)
    return node
end

function OperateUI:ctor()
end

function OperateUI:onEnter()
    EventMgr:registListener(EventType.OnFlyPrompt, self, self.onFlyPrompt)
    EventMgr:registListener(EventType.OnSkillPrompt, self, self.onSkillPrompt)
end

function OperateUI:onExit()
    EventMgr:unregistListener(EventType.OnFlyPrompt, self, self.onFlyPrompt)
    EventMgr:unregistListener(EventType.OnSkillPrompt, self, self.onSkillPrompt)
end

function OperateUI:init()
    isMove = false
    
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    self:setPosition(cc.p(visibleSize.width/2,0))
    
    local node =  cc.CSLoader:createNode("csb/OperateUI.csb")
    self:addChild(node)
    self.node_root = node
    
    self.Panel_root = node:getChildByName("Panel_root")
    self.Panel_root:setPosition(0,-110)
    
    local Image_bg =  self.Panel_root:getChildByName("Image_bg")
    self.Image_bg = Image_bg
    
    local updown = Image_bg:getChildByName("Image_updown")
    self.Image_updown = updown
    self.Image_updown:loadTexture("ui/oprateUI/operateUI_3.png")
    self.Image_updown:setPosition(420,121)
    local Panel_updown_button = Image_bg:getChildByName("Panel_updown_button")
    
    local Node_buttons = self.Panel_root:getChildByName("Node_buttons")
    
    local function onButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("onButtonClicked ended = " .. sender:getName())
            
            self:onFunctionButtonClicked(sender:getName())
            
        end
    end
    self.buttons = Node_buttons:getChildren()
    for i=1,#self.buttons do
        self.buttons[i]:setPressedActionEnabled(true)
        self.buttons[i]:addTouchEventListener(onButtonClicked)
    end
    
    self.buttons[6]:setVisible(false)
    self.buttons[7]:setVisible(false)
    
    local function onUpDownButtonClicked(sender,eventType)
        if eventType == cc.EventCode.ENDED then
            cclog("onUpDownButtonClicked name = " .. sender:getName())
            if isMove then
                return
            end
            local rootPos = nil
            local upDownState = self:getUpDownState()
            if upDownState then
                self.Image_updown:loadTexture("ui/oprateUI/operateUI_3.png")
                self.Image_updown:setPosition(420,125)
                rootPos = cc.p(0,-110)
            else
                self.Image_updown:loadTexture("ui/oprateUI/operateUI_4.png")
                self.Image_updown:setPosition(420,121)
                rootPos = cc.p(0,0)
            end
            cclog("upDownState end= " .. tostring(upDownState))
            local move = cc.MoveTo:create(0.1,rootPos)
            local callback = function()
                isMove = false
            end
            local seq = cc.Sequence:create(move, cc.CallFunc:create(callback))
            self.Panel_root:runAction(seq)
            
        end
    end
    Panel_updown_button:setTouchEnabled(true)
    Panel_updown_button:addTouchEventListener(onUpDownButtonClicked)
    

    self.Node_newHand = self.Panel_root:getChildByName("Node_newHand")
    
    self.publicTipLayer = PublicTipLayer:create()
    self:addChild(self.publicTipLayer)
    ---- 一下是提示系统代码
    local promptMark = self.buttons[2]:getChildByName("promptMark")     -- 技能升级提示
    if UserData.BaseInfo.bySkillPoints ~= 20 then
        promptMark:setVisible(false)
    else
        promptMark:setVisible(true)
    end
    
    
    for key, val in pairs(FlyRefiningPrompt.flybbleTatle) do            -- 飞宝炼制提示
        if FlyRefiningPrompt.flybbleTatle[key].isPrompt == true then
            promptMark = self.buttons[1]:getChildByName("promptMark")
            promptMark:setVisible(true)
            return
        end
    end
    -----------
end

function OperateUI:getUpDownState()
    local posX,posY = self.Panel_root:getPosition()
	return posY >= 0  -- true:显示 false:未显示
end

function OperateUI:setUpDownStateToDown()
    local upDownState = self:getUpDownState()
    if not upDownState then 
        return
    end
    
    if self.Image_updown ~= nil then
        self.Image_updown:loadTexture("ui/oprateUI/operateUI_3.png")
        self.Image_updown:setPosition(420,125)
    end
    if self.Panel_root ~= nil then  
        local rootPos = cc.p(0,-110)
        local move = cc.MoveTo:create(0.3,rootPos)
        local callback = function()
            isMove = false
        end
        local seq = cc.Sequence:create(move, cc.CallFunc:create(callback))
        self.Panel_root:runAction(seq)
    end
end

function OperateUI:setUpDownStateToUP()
    local upDownState = self:getUpDownState()
    if upDownState then 
        return
    end

    if self.Image_updown ~= nil then
        self.Image_updown:loadTexture("ui/oprateUI/operateUI_4.png")
        self.Image_updown:setPosition(420,121)
    end
    if self.Panel_root ~= nil then  
        self.Panel_root:setPosition(0,0)
    end
end

function OperateUI:onFunctionButtonClicked(senderName)
    local layer = nil
    local publicTipLayer = require("app/views/public/publicTipLayer")
    if senderName == "Button_1" then  -- 飞宝
        local haveOpen,closeStr = self:isHaveOpen("FlyRefining") 
        if haveOpen then
            layer = require("app.views.FlyTechTree.FlyTechTreeLayer"):create()
            self.Node_newHand:removeAllChildren()
        else
            publicTipLayer:setTextAction(closeStr)
        end
--        layer = require("app.views.myStartScene"):create()
    elseif senderName == "Button_2" then -- 技能
        local haveOpen,closeStr = self:isHaveOpen("FlySkillLead") 
        if haveOpen then
            layer = require("app.views.FlyTechTree.FlySkillLayer"):create()
            self.Node_newHand:removeAllChildren()
        else
            publicTipLayer:setTextAction(closeStr)
        end
    elseif senderName == "Button_3" then -- 神将
        local haveOpen,closeStr = self:isHaveOpen("GodWillLead_levelup") 
        if haveOpen then
            layer = require("app.views.Godwill.GodwillListLayer"):create()
            self.Node_newHand:removeAllChildren()
        else
            publicTipLayer:setTextAction(closeStr)
        end
        
    elseif senderName == "Button_4" then -- 任务
        layer = require("app.views.Task.TaskDetailInfoLayer"):create()
    elseif senderName == "Button_5" then -- 背包
        layer = require("app.views.Bag.MyBagLayer"):create()
    elseif senderName == "Button_6" then -- 好友
        layer = require("app.views.Main.FriendLayer"):create()
    elseif senderName == "Button_7" then -- 设置
    
    end
    if layer ~= nil then
        local SceneManager = require("app.views.SceneManager")
        if senderName ~= "Button_1" then
            SceneManager:addToGameScene(layer,21)
        else
            SceneManager:addToGameScene(layer,10)
        end
        
    end
    -- local shoplayer = require("app.views.Shop.ShopLayer"):create('SHOP')
    --                self:addChild(shoplayer, 10001)
end

function OperateUI:showNewHand(guideName)
    local pos = nil
    if "FlySkillLead" == guideName or 
        "FlyRefining" == guideName or 
        "GodWillLead_levelup" == guideName or 
        "GodWillLead_starUp" == guideName then
        if UserData.NewHandLead.GuideList[guideName] ~= nil then
            pos = UserData.NewHandLead.GuideList[guideName].step[1].handPos
        end
	end
	
    if self.Node_newHand ~= nil and pos ~= nil then
        self.Node_newHand:removeAllChildren()
        UserData.NewHandLead:addHandTo(self.Node_newHand)
        self.Node_newHand:setPosition(pos)
        UserData.NewHandLead.GuideList[guideName].curStep = 1
	end
	
end

function OperateUI:isHaveOpen(guideName)
    local isOpen = false
    local closeStr = ""
    if UserData.NewHandLead.GuideList[guideName] ~= nil then
        local taskID = UserData.NewHandLead.GuideList[guideName].TaskID
        
        local preTask = StaticData.Task[taskID].PreTaskID
        if guideName == "FlyRefining" then
            preTask = taskID
        end
        if preTask ~= nil and preTask > 0 then
            local ManagerTask = require("app.views.Task.ManagerTask")
            
            isOpen = ManagerTask:isTaskHaveComplete(preTask)
            
            closeStr = "完成任务[" .. StaticData.Task[preTask].TaskName .. "]之后开启此功能。"
        end
    end
    return isOpen,closeStr
end

function OperateUI:onFlyPrompt()

    local promptShow = false
    local promptMark = self.buttons[1]:getChildByName("promptMark")

    for key, val in pairs(FlyRefiningPrompt.flybbleTatle) do
        if FlyRefiningPrompt.flybbleTatle[key].isPrompt == false then           -- 表示还没有提示
            if FlyRefiningPrompt.flybbleTatle[key].type == 0 then               -- 表示已经点亮，还没有制造
                if FlyFunction:checkFibbleCreate(key) == true then              -- 检测是否能打造
                    self.publicTipLayer:setTextAction("有可打造的飞宝啦，快去看看")
                    FlyRefiningPrompt.flybbleTatle[key].isPrompt = true
                    promptMark:setVisible(true)
                    return
                end
            elseif FlyRefiningPrompt.flybbleTatle[key].type == 1 then           -- 表示已经拥有
                if FlyFunction:checkFibbleStreng(key, UserData.Fibble.fibbleTable[key][1].byStar) == true then
                    self.publicTipLayer:setTextAction("有可炼制的飞宝啦，快去看看")
                    FlyRefiningPrompt.flybbleTatle[key].isPrompt = true
                    promptMark:setVisible(true)
                    return
                end
            end
        elseif FlyRefiningPrompt.flybbleTatle[key].isPrompt == true then
            if promptShow == false then
                if FlyRefiningPrompt.flybbleTatle[key].type == 0 then
                    if FlyFunction:checkFibbleCreate(key) == true then
                        promptShow = true
                    end
                elseif FlyRefiningPrompt.flybbleTatle[key].type == 1 then
                    if FlyFunction:checkFibbleStreng(key, UserData.Fibble.fibbleTable[key][1].byStar) == true then
                        promptShow = true
                    end
                end
            end
        end
    end
    if promptShow == false then
        promptMark:setVisible(false)
    else
        promptMark:setVisible(true)
    end
end

function OperateUI:onSkillPrompt()
    local baseInfo = UserData.BaseInfo
    local promptMark = self.buttons[2]:getChildByName("promptMark")

    if baseInfo.bySkillPoints ~= 20 then
        promptMark:setVisible(false)
    else
        self.publicTipLayer:setTextAction("你的技能点已经满了，快去升级技能吧")
        promptMark:setVisible(true)
    end
    
--	for key, val in pairs(UserData.Fibble.skillTable) do
--	   if UserData.Fibble.skillTable[key].level < baseInfo.userLevel and UserData.Fibble.skillTable[key].level * 10 <= baseInfo.userGold then
--            self.publicTipLayer:setTextAction("有可升级的技能，快去升级吧")
--	       promptMark:setVisible(true)
--	       return
--	   end
--	end
end

return OperateUI