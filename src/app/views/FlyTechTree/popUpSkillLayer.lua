local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local TimeFormat = require("common.TimeFormat")
local FlyFunction = require("app/views/FlyTechTree/FlyFunction")

--技能
local popUpSkillLayer = class("popUpSkillLayer", function()
    return ccui.Layout:create()
end)

function popUpSkillLayer:create(nFibbleId,pl)
    local view = popUpSkillLayer.new()
    view:init(nFibbleId,pl)
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

function popUpSkillLayer:ctor()

end

function popUpSkillLayer:onEnter()



end

function popUpSkillLayer:onExit()
  self.skillNodeTable = nil
end



--初始化
function popUpSkillLayer:init(nFibbleId,pl)
    self.nFibbleId  = nFibbleId
    self.pl = pl
   
    self.fibbleSkillData = UserData.Fibble.fibbleTable[self.nFibbleId]
    self.skillNodeTable = {} --存储上面的所有技能节点的
    self.skillDownNodeTable  = {} --存储在下面的节点的
    FlyFunction.tempMySkillIdTable = {self.fibbleSkillData[1].nSkillId1,self.fibbleSkillData[1].nSkillId2,self.fibbleSkillData[1].nSkillId3} -- 暂时带有的技能的ID存储
    self.fibbleNodePosTable= {}
    
    local flySkill_Layer = cc.CSLoader:createNode("csb/Select_flySkill_Layer.csb")
    flySkill_Layer:setAnchorPoint(cc.p(0.5,0.5))
    flySkill_Layer:setPosition(display.center)
    flySkill_Layer:setPositionY(display.center.y  - (display.center.y - 576/2))
    self:addChild(flySkill_Layer)
    local panel = flySkill_Layer:getChildByName("Panel")
    self.panel = panel
    local image_bg = panel:getChildByName("Image_bg")
    self.scrollView = image_bg:getChildByName("skillScrollView")
    self.flySkillPanel = panel:getChildByName("flySkillPanel")
    local closeBtn = image_bg:getChildByName("Button_5")
   
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then

            if #FlyFunction.tempMySkillIdTable < 3 then
                PublicTipLayer:setTextAction("技能数量未满足")
            else
                self:removeFromParent()      
                UserData.Fibble:sendChangeSkillSite(nFibbleId,FlyFunction.tempMySkillIdTable[1],FlyFunction.tempMySkillIdTable[2],FlyFunction.tempMySkillIdTable[3]) --发送请求消息
            end

        end
    end    
   
    closeBtn:addTouchEventListener(onEventTouchButton) -- 按钮通知事件
    closeBtn:setPressedActionEnabled(true)
    
    -- 获取技能坐标
    for  i =1, 4 do
        local keyStr = "skill_"..tostring(i)
        local tempPosNode = self.flySkillPanel:getChildByName(keyStr)
       
        self.fibbleNodePosTable[i] = tempPosNode
        
        local pos = cc.p(tempPosNode:getPosition())
        local cvrPos = tempPosNode:convertToWorldSpace(pos)

    end
   
    self:createScrollNode()
    self:createDownSkillNode()
    
end

function popUpSkillLayer:createScrollNode()
	
    local mySkillTable = {}
   --提取出来
    for key, var in pairs(UserData.Fibble.skillTable) do
        if key ~= self.fibbleSkillData[1].nSkillId4 and FightStaticData.flyingObjectSkill[key].BaseSkill == 0 then
	  		local t = {}
	  		t.skillId = key
	  		t.skillLevel = var.level
            table.insert(mySkillTable,t)
	  	end	
    end
   -- 排序
    table.sort(mySkillTable,function(a,b) 
        return a.skillLevel > b.skillLevel
    end)
   	local nums = #mySkillTable
   	local srollSize = cc.size(600,360)
   	local nodeSize  = cc.size(100,120)
    local verticalNum = 5
    local lineNum   = math.ceil(nums/verticalNum) --向上取整
   
    if lineNum > 3 then -- 计算要多大的滚动高度
        srollSize = cc.size(600,lineNum *120)
    end
    
    self.scrollView:setInnerContainerSize(srollSize)
    
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
           
            self:moveUpToDownNodeToDest(sender)
           
        end
    end    

    
    local v = 0 -- 竖
    local h = 0 -- 横
    for i =1 , nums do
        local skillNode = cc.CSLoader:createNode("csb/SkillNode.csb")
        local skillNodePanel = skillNode:getChildByName("Panel")
        local skillBtn = skillNodePanel:getChildByName("skillBtn")
        local skill_bg = skillNodePanel:getChildByName("skill_bg")
        local skillName = skillBtn:getChildByName("skillNameText")
       
        local skillLevel = ccui.Helper:seekWidgetByName(skillNodePanel ,"skillLevelText") 
        skillBtn:addTouchEventListener(onEventTouchButton) -- 按钮通知事件
        self.scrollView:addChild(skillNode)
        v = (i-1)%verticalNum 
        h = math.ceil(i/verticalNum)
        skillNode:setPosition(cc.p(50+nodeSize.width/2 + nodeSize.width * v,srollSize.height + nodeSize.height/2 - ( nodeSize.height * h )))
        
        local skillId = mySkillTable[i].skillId
        local skillLv =  mySkillTable[i].skillLevel
        self.skillNodeTable[skillId] = skillBtn --这个是记录按钮保存起来
        local sData  = FightStaticData.flyingObjectSkill[skillId]
        skillName:setString(sData.name)
        skillLevel:setString(string.format("Lv%d",UserData.Fibble.skillTable[skillId].level))
        skillBtn:loadTextures(sData.icon, sData.icon,sData.icon) --设置底图
        
        skillBtn.id = skillId
        FlyFunction:setSkillNoSelect(skillBtn)
        if skillId == self.fibbleSkillData[1].nSkillId1 or skillId == self.fibbleSkillData[1].nSkillId2 or skillId == self.fibbleSkillData[1].nSkillId3  then
            FlyFunction:setSkillSelect(skillBtn)
        end
        
    end
	
    local nFibbleId = self.nFibbleId
	
    -- 添加背景触摸事件，方便取消整个layer
--    local listenner = cc.EventListenerTouchOneByOne:create()
--    listenner:setSwallowTouches(true)
--    listenner:registerScriptHandler(function(touch, event)
--            return true
--    end,cc.Handler.EVENT_TOUCH_BEGAN )
--
--    listenner:registerScriptHandler(function(touch, event)
--        --        do some thing here
--        local location = touch:getLocation()
--        location = self.scrollView:convertToWorldSpace(location)
--       
--        local scrollPos = cc.p(self.scrollView:getPosition())
--       
--        scrollPos =  self.scrollView:getParent():convertToWorldSpace(scrollPos)
--        local  f = cc.rectContainsPoint(cc.rect(scrollPos.x - 400/2,scrollPos.y - 350/2,400,350),location)
--        if f == false then
--
--            if #FlyFunction.tempMySkillIdTable < 3 then
--                PublicTipLayer:setTextAction("技能数量未满足")
--            else
--                self:removeFromParent()      
--                UserData.Fibble:sendChangeSkillSite(nFibbleId,FlyFunction.tempMySkillIdTable[1],FlyFunction.tempMySkillIdTable[2],FlyFunction.tempMySkillIdTable[3]) --发送请求消息
--            end
--        end
--        
--       
--
--    end,cc.Handler.EVENT_TOUCH_ENDED )
--
--    local eventDispatcher = self:getEventDispatcher()
--    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.scrollView)
	
	
end



function popUpSkillLayer:createDownSkillNode()
   
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
            self:moveDownToUpNodeToDest(sender)
        end
    end    

  
    for i = 1, #FlyFunction.tempMySkillIdTable do
        local skillNode = cc.CSLoader:createNode("csb/SkillNode.csb")
        local skillId = FlyFunction.tempMySkillIdTable[i]
        
        local skillNodePanel = skillNode:getChildByName("Panel")
        local skillBtn = skillNodePanel:getChildByName("skillBtn")
        local skillName = skillBtn:getChildByName("skillNameText")
        
        local skillLevel = ccui.Helper:seekWidgetByName(skillNodePanel ,"skillLevelText") 
        local sData  = FightStaticData.flyingObjectSkill[skillId]
        skillName:setString(sData.name)
        skillBtn.id = skillId -- 记录ID
        
        skillLevel:setString(string.format("Lv%d",UserData.Fibble.skillTable[skillId].level))
        skillBtn:loadTextures(sData.icon, sData.icon,sData.icon) --设置底图
        
        skillBtn:addTouchEventListener(onEventTouchButton) -- 按钮通知事件
        skillNode:setPosition( cc.p(self.fibbleNodePosTable[i]:getPosition()))
        self.flySkillPanel:addChild(skillNode)
        self.skillDownNodeTable[skillId] = skillNode --这个是记录节点的保存起来
        
	end
	
	
	local skillId = self.fibbleSkillData[1].nSkillId4
    self.skillNode = cc.CSLoader:createNode("csb/SkillNode.csb")
    local skillNodePanel = self.skillNode:getChildByName("Panel")
    local skillBtn = skillNodePanel:getChildByName("skillBtn")
    local skillName = skillBtn:getChildByName("skillNameText")
        
    local skillLevel = ccui.Helper:seekWidgetByName(skillNodePanel ,"skillLevelText") 
    local sData  = FightStaticData.flyingObjectSkill[skillId]
    skillName:setString(sData.name)
    skillBtn.id = skillId -- 记录ID
    skillLevel:setString(string.format("Lv%d",UserData.Fibble.skillTable[skillId].level))
    skillBtn:loadTextures(sData.icon, sData.icon,sData.icon) --设置底图
    self.skillNode:setPosition( cc.p(self.fibbleNodePosTable[4]:getPosition()))
    self.flySkillPanel:addChild(self.skillNode)
    
	
	
end


-- 创建节点移动 下面的移动到上面的

function popUpSkillLayer:moveDownToUpNodeToDest(nBtn)
	
    local skillId  = nBtn.id
	nBtn:setTouchEnabled(false)
	
    local copyNode = nBtn:clone() -- 复制
    
    local skillName = copyNode:getChildByName("skillNameText")
 
--    local skillNodePanel = copyNode:getChildByName("Panel")
--  
--    local skillLevel = skillNodePanel:getChildByName("skillLevelText")
    
    skillName:setVisible(false)
--    skillLevel:setVisible(false)
    local startPos = nBtn:convertToWorldSpace(cc.p(nBtn:getPosition()))
    local endPos  = cc.p(0,0)
    
    local targetBtn = self.skillNodeTable[skillId]
    endPos = targetBtn:convertToWorldSpace(cc.p(targetBtn:getPosition()))
    
    local size = copyNode:getContentSize()
    startPos = cc.p(startPos.x - size.width/4,startPos.y - size.height/4)
    endPos = cc.p(endPos.x - size.width/4,endPos.y - size.height/4)
    copyNode:setPosition(startPos)
    self:addChild(copyNode,10)
    
    -- 先刷新创建
    FlyFunction:tableRemoveForId(FlyFunction.tempMySkillIdTable,nBtn.id) 
    self:createDownSkillNode()
    if self.pl then --回调
        self.pl:createDownSkillNode()
    end
    -- 移动完后回调
    local function callback()
        copyNode:removeFromParent() 
      
        FlyFunction:setSkillNoSelect(targetBtn) --变成没选择的状态
        
    end
    
    local move = cc.MoveTo:create(0.2,endPos)
    local seq = cc.Sequence:create(move,cc.CallFunc:create(callback))
    copyNode:runAction(seq)
    
	
end



-- 上面滚动层的移动下来
function popUpSkillLayer:moveUpToDownNodeToDest(nBtn)

    if #FlyFunction.tempMySkillIdTable >=3 then
   	  return
    end

    local skillId  = nBtn.id
    FlyFunction:setSkillSelect(nBtn) --设置选择了状态

    local copyNode = nBtn:clone() -- 复制

    local skillName = copyNode:getChildByName("skillNameText")
--    local skillNodePanel = copyNode:getChildByName("Panel")
--
--    local skillLevel = skillNodePanel:getChildByName("skillLevelText")
    skillName:setVisible(false)
--    skillLevel:setVisible(false)
    
    local startPos = nBtn:convertToWorldSpace(cc.p(nBtn:getPosition()))
    local endPos  = cc.p(0,0)

    local num = #FlyFunction.tempMySkillIdTable + 1

    local firstNode = self.fibbleNodePosTable[1]   
    local firstCovPos = firstNode:convertToWorldSpace(cc.p(firstNode:getPosition()))
    local curNode = self.fibbleNodePosTable[num]  
    local p1 = cc.p(firstNode:getPosition())
    local p2 = cc.p(curNode:getPosition())
    
    local size = copyNode:getContentSize()
    startPos = cc.p(startPos.x - size.width/4,startPos.y - size.height/4)
    endPos = cc.p(firstCovPos.x + p2.x - p1.x + size.width/4,firstCovPos.y)
    
    copyNode:setPosition(startPos)
    copyNode:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(copyNode,10)

    -- 移动完后回调
    local function callback()
        copyNode:removeFromParent() 
        table.insert(FlyFunction.tempMySkillIdTable,nBtn.id) --增加一个ID
        self:createDownSkillNode() --创建下面的技能节点

        if self.pl then --回调
            self.pl:createDownSkillNode()
        end
        
    end

    local moveBy = cc.MoveBy:create(0.2,cc.p(endPos.x- startPos.x,endPos.y - startPos.y))
    local seq = cc.Sequence:create(moveBy,cc.CallFunc:create(callback))
    copyNode:runAction(seq)
end


return popUpSkillLayer