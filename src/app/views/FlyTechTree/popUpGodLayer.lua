local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local TimeFormat = require("common.TimeFormat")
local GodwillManager = require("app.views.Godwill.GodwillManager")
local FlyFunction = require("app/views/FlyTechTree/FlyFunction")
--技能

local popUpGodLayer = class("popUpGodLayer", function()
    return ccui.Layout:create()
end)

function popUpGodLayer:create(nFibbleId,pl)
    local view = popUpGodLayer.new()
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

function popUpGodLayer:ctor()

end

function popUpGodLayer:onEnter()



end

function popUpGodLayer:onExit()

end



--初始化
function popUpGodLayer:init(nFibbleId,pl)
    self.nFibbleId  = nFibbleId
    self.pl = pl
    self.godDownNodeTable = {}
    self.godUpNodeTable= {}
    
    self.starImage = {"ui/FlyUI/xing1.png","ui/FlyUI/xing2.png","ui/FlyUI/xing3.png","ui/FlyUI/xing4.png","ui/FlyUI/xing5.png"}
    local godLayer = cc.CSLoader:createNode("csb/Select_godWill_Layer.csb")
    godLayer:setAnchorPoint(cc.p(0.5,0.5))
    godLayer:setPosition(display.center)
    godLayer:setPositionY(display.center.y -(display.center.y - 576/2))
    self:addChild(godLayer)
    local panel = godLayer:getChildByName("Panel")
    self.panel = panel
    local image_bg = panel:getChildByName("Image_bg")
    self.scrollView = image_bg:getChildByName("scrollView")
    self.selelctRolePanel = panel:getChildByName("selectRolePanel")
   
    local closeBtn = image_bg:getChildByName("Button_close")
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            self:removeFromParent()  
            local t = FlyFunction.tempMyGodIdTable
            UserData.Fibble:sendChangeGodSite(nFibbleId,t[1],t[2],t[3],t[4],t[5])
        end
    end    

    closeBtn:addTouchEventListener(onEventTouchButton) -- 按钮通知事件
    closeBtn:setPressedActionEnabled(true)
   
   
   self.nodePosTable = {} --保存节点坐标节点
    -- 获取技能坐标
    for  i =1, 5 do
        local keyStr = "role_"..tostring(i)
        local tempPosNode = self.selelctRolePanel:getChildByName(keyStr)
        tempPosNode:setVisible(false)
        self.nodePosTable[i] = tempPosNode
        local pos = cc.p(tempPosNode:getPosition())
        local cvrPos = tempPosNode:convertToWorldSpace(pos)
    
    end

    self:createScrollNode()
    self:createDownGodNode()
end


--创建节点
function popUpGodLayer:createOneNode(godId)
    local godNode = cc.CSLoader:createNode("csb/GodWillNode.csb")
    local godPanel = godNode:getChildByName("Panel")
    local godNodeBtn = godPanel:getChildByName("godWillBtn")
    local god_bg =  godPanel:getChildByName("god_bg")
    local godLevel =  god_bg:getChildByName("levelText")
    local godStar = godPanel:getChildByName("Image_star")
    local godFrame = godPanel:getChildByName("godFrame")
    local name_bg = godPanel:getChildByName("name_bg")
    local godName = name_bg:getChildByName("GodName")
    godNodeBtn:setSwallowTouches(false)
    if godId == 0 then
        godNodeBtn:setOpacity(0)
        godLevel:setVisible(false)
        godStar:setVisible(false)
        god_bg:setVisible(false)
        name_bg:setVisible(false)
        godName:setString("")
    else
        local godData = FightStaticData.godwill[godId]
        local userGodData = UserData.Godwill.godList[godId]
       
        local fibbleUpData = FlyFunction:findFibbleUpForSameIdAndStar(godId,userGodData.star)
        godNodeBtn:loadTextures(fibbleUpData.icon, fibbleUpData.icon,fibbleUpData.icon) --设置底图
      
        godLevel:setString(string.format("Lv%d",userGodData.level)) --设置等级
        godStar:loadTexture(self.starImage[userGodData.star]) --设置星级
        if userGodData.star == 0 then
            godStar:setVisible(false)
        end
        godName:setString(fibbleUpData.name)
    end

    godNodeBtn.id = godId

    return godNode,godNodeBtn
   
end


function popUpGodLayer:createScrollNode()
    
    local godList = GodwillManager:getGodwillUnlockedList()
   
    local nums = #godList
    local srollSize = cc.size(600,360)
    local nodeSize  = cc.size(100,120)
    local verticalNum = 5 -- 一行有多少个
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
        
        local godId = godList[i].id
        local godNode,godBtn = self:createOneNode(godId) --获取节点
        
        godBtn:addTouchEventListener(onEventTouchButton) -- 按钮通知事件
        self.scrollView:addChild(godNode)
        v = (i-1)%verticalNum 
        h = math.ceil(i/verticalNum)
        godNode:setPosition(cc.p(50+nodeSize.width/2 + nodeSize.width * v,srollSize.height + nodeSize.height/2 - ( nodeSize.height * h )))
        local t = UserData.Fibble.fibbleTable[self.nFibbleId]
        
        self.godUpNodeTable[godId] = godBtn -- 这里记录的是
        
        if godId == t[1].nGodId1 or godId == t[1].nGodId2 or godId == t[1].nGodId3  or godId == t[1].nGodId4 or godId == t[1].nGodId5 then
            FlyFunction:setGodSelect(godBtn)
        end

    end

    local nFibbleId = self.nFibbleId





end

--下面行的显示
function popUpGodLayer:createDownGodNode()

    --清空表
    for key, var in pairs(self.godDownNodeTable) do
        var:removeFromParent()
      
    end
    self.godDownNodeTable = {}
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then

            if sender.id ~= 0 then
                self:moveDownToUpNodeToDest(sender)
            end
        end
    end    

  
    for i = 1, #FlyFunction.tempMyGodIdTable do
        local godId = FlyFunction.tempMyGodIdTable[i]
        local godNode,godBtn = self:createOneNode(godId) --获取节点
        godBtn.indx = i --第几个
        godBtn:addTouchEventListener(onEventTouchButton) -- 按钮通知事件
        self.selelctRolePanel:addChild(godNode)

        godNode:setPosition( cc.p(self.nodePosTable[i]:getPosition()))
      
        self.godDownNodeTable[i] = godNode --这个是记录节点的保存起来

    end

end





-- 创建节点移动 下面的移动到上面的

function popUpGodLayer:moveDownToUpNodeToDest(nBtn)

    local godId  = nBtn.id
    nBtn:setTouchEnabled(false)

    local copyNode = nBtn:clone() -- 复制

  
    local startPos = nBtn:convertToWorldSpace(cc.p(nBtn:getPosition()))
    local endPos  = cc.p(0,0)

    local targetBtn = self.godUpNodeTable[godId]
    endPos = targetBtn:convertToWorldSpace(cc.p(targetBtn:getPosition()))

    local size = copyNode:getContentSize()
    startPos = cc.p(startPos.x - size.width/4,startPos.y - size.height/4)
    endPos = cc.p(endPos.x - size.width/4,endPos.y - size.height/4)
    copyNode:setPosition(startPos)
    self:addChild(copyNode,10)
   
   
    FlyFunction.tempMyGodIdTable[nBtn.indx] = 0 -- 置为0
    self:createDownGodNode() --重新创建了
    if self.pl then --回调
        self.pl:createDownGodNode()
    end
    
    -- 移动完后回调
    local function callback()
        copyNode:removeFromParent() 

        FlyFunction:setGodNoSelect(targetBtn) --变成没选择的状态

    end

    local move = cc.MoveTo:create(0.2,endPos)
    local seq = cc.Sequence:create(move,cc.CallFunc:create(callback))
    copyNode:runAction(seq)


end



-- 上面滚动层的移动下来
function popUpGodLayer:moveUpToDownNodeToDest(nBtn)
    local godId  = nBtn.id
   
    local indx = 1
    -- 添加进去
    local isMove = false
    for i =1, 5 do
        if FlyFunction.tempMyGodIdTable[i] == 0 then
            FlyFunction.tempMyGodIdTable[i] = godId
            indx = i
            isMove = true
            break
        end
    end
    
    if isMove == false then -- 如果下面的技能满了的话不可以点击
    	return
    end  
      
    local copyNode = nBtn:clone() -- 复制

    local startPos = nBtn:convertToWorldSpace(cc.p(nBtn:getPosition()))
    local endPos  = cc.p(0,0)
    
    local firstNode = self.nodePosTable[1]   
    local firstCovPos = firstNode:convertToWorldSpace(cc.p(firstNode:getPosition()))
    local curNode = self.nodePosTable[indx]  
    local p1 = cc.p(firstNode:getPosition())
    local p2 = cc.p(curNode:getPosition())
    local size = copyNode:getContentSize()
    endPos = cc.p(firstCovPos.x + p2.x - p1.x + size.width/4,firstCovPos.y)
    
    copyNode:setPosition(startPos)
    copyNode:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(copyNode,10)
   
    
    FlyFunction:setGodSelect(nBtn) --设置选择了状态
    
    -- 移动完后回调
    local function callback()
        copyNode:removeFromParent() 
        
        self:createDownGodNode() --创建下面的技能节点
        if self.pl then --回调
            self.pl:createDownGodNode()
        end
    end
    local move = cc.MoveTo:create(0.2,endPos)
--    local move = cc.MoveBy:create(0.2,cc.p(endPos.x- startPos.x,endPos.y - startPos.y))
    local seq = cc.Sequence:create(move,cc.CallFunc:create(callback))
    copyNode:runAction(seq)
end






return popUpGodLayer