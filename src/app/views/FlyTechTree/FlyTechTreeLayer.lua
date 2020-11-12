local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local PublicTipLayer = require("app/views/public/publicTipLayer")
local YesCancelLayer = require("app.views.public.YesCancelLayer")
local TimeFormat = require("common.TimeFormat")
local FlyFunction = require("app/views/FlyTechTree/FlyFunction")
local FlyMainUILayer = require("app/views/FlyTechTree/FlyMainUILayer")
local FlyRefiningLayer = require("app.views.FlyTechTree.FlyRefiningLayer")
local stringEx =  require("common.stringEx")
-- 科技树的

local FlyTechTreeLayer = class("FlyTechTreeLayer", function()
    return ccui.Layout:create()
end)

function FlyTechTreeLayer:create()
    local view = FlyTechTreeLayer.new()
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

function FlyTechTreeLayer:ctor()
                                                                            
end

function FlyTechTreeLayer:onEnter()

    EventMgr:registListener(EventType.OnCreateFibble, self, self.OnCreateFibble)                          -- 服务端返回飞宝打造请求
    EventMgr:registListener(EventType.OnFibbleUp, self, self.OnFibbleUp)                                  -- 服务端返回炼造飞宝请求
    EventMgr:registListener(EventType.OnSelectFibble, self, self.OnSelectFibble)                          -- 服务端返回选择飞宝

end

function FlyTechTreeLayer:onExit()
    self.FibbleTables = nil
    EventMgr:unregistListener(EventType.OnCreateFibble, self, self.OnCreateFibble)                         -- 服务端返回飞宝打造请求
    EventMgr:unregistListener(EventType.OnFibbleUp, self, self.OnFibbleUp)                                 -- 服务端返回炼造飞宝请求
    EventMgr:unregistListener(EventType.OnSelectFibble, self, self.OnSelectFibble)                         -- 服务端返回选择飞宝
end



function FlyTechTreeLayer:OnCreateFibble(event)
	
    self:changeStateForButton()
	
end

function FlyTechTreeLayer:OnFibbleUp(event)

    self:changeStateForButton()

end

function FlyTechTreeLayer:OnSelectFibble(event)
    self:changeStateForButton()
end


function FlyTechTreeLayer:changeStateForButton()
    for fibbleId, Button in pairs(self.FibbleTables) do
        local t = UserData.Fibble.fibbleTable[fibbleId]
        local Image_flyicon = Button:getChildByName("Image_flyicon") --飞宝图标
        local Image_tipicon = Button:getChildByName("Image_tipicon") -- 图上图标
        Image_tipicon:setVisible(false)
        local Text_name = Button:getChildByName("Text_name") -- 飞宝名字
     
        
        local image_type = Button:getChildByName("image_type") -- 那个类别的，仙，人，妖
        local image_type_frame = Button:getChildByName("image_type_frame")
        local fightTitle = Button:getChildByName("fightTitle")
        local type =  FightStaticData.flyingObject[fibbleId].type
        image_type:setTexture(self.typeImage[type])  -- 设置那个类别的
        image_type:setVisible(true)

        local star = 0
        if t then
            star = t[1].byStar
        end
        
        local fibbleData = FlyFunction:findFibbleUpForSameIdAndStar(fibbleId,star)
        Image_flyicon:setTexture(fibbleData.icon)
        Image_flyicon:setScale(0.9)
        Image_tipicon:setVisible(false)

        local isHaveFlag = FlyFunction:checkFibbleIsHave(fibbleId)  -- 是否已经拥有了
        local isBrightFlag = FlyFunction:checkFibbleEnable(fibbleId)  --是否可以点亮了
        local isCreateFlag = FlyFunction:checkFibbleCreate(fibbleId) --是否可以创建了
        fightTitle:setVisible(false)
        image_type_frame:setTexture(self.typeImageFrame[type])
        Button:loadTextures("ui/FlyTechTree/tree_imFrame.png", "ui/FlyTechTree/tree_imFrame.png", "ui/FlyTechTree/tree_imFrame.png")

        FlyFunction:setButtonGray(Button) --先全部置灰色
        if isHaveFlag == true then -- 如果已经创建拥有了,点亮图标,外侧框线,点亮向下框线
            FlyFunction:setButtonNarmal(Button)
            
            local t = UserData.Fibble.fibbleTable[fibbleId]
            local isStrengFlag = FlyFunction:checkFibbleStreng(fibbleId,star) --传人是飞宝ID和星级

            if isStrengFlag == true then
                Image_tipicon:loadTexture("ui/FlyTechTree/tree_canRefine.png") --显示叹号
                Image_tipicon:setVisible(true)
            end
            if fibbleId == UserData.BaseInfo.nFibbleId then --如果是选择上阵的法宝，显示状态
--                Image_tipicon:setVisible(true)
--                Image_tipicon:loadTexture("ui/FlyTechTree/tree_fight.png") --显示战斗
                fightTitle:setVisible(true)
                image_type_frame:setTexture("ui/FlyTechTree/fightFrame.png")
                Button:loadTextures("ui/FlyTechTree/tree_nowFrame.png", "ui/FlyTechTree/tree_nowFrame.png", "ui/FlyTechTree/tree_nowFrame.png")
            end

        end

        local treePos = 1
        
        for k, var in pairs(FightStaticData.fibbleTree) do
            if var.fibbleID == fibbleId  then
       	     	treePos = k
       	   end
        end
       local itemTree  = FightStaticData.fibbleTree[treePos]
        local RouteTable = stringEx:split(FightStaticData.fibbleTree[treePos].Route,"|")--获取本节点的前置ID
        if isBrightFlag == true then -- 可以点亮，不显示外侧框线,不点亮向下框线
            FlyFunction:setButtonNarmal(Button)
            if itemTree.Route ~= "" then
                for key, var in pairs(RouteTable) do
                    local rt = stringEx:split(var,"_")
                    local isHaveed = FlyFunction:checkFibbleIsHave(FightStaticData.fibbleTree[tonumber(rt[2])].fibbleID)
                    if isHaveed then
                        local arrKey = "arr_"..var
                        local arrow = self.Panel:getChildByName(arrKey)
                        arrow:setColor(cc.c3b(255,255,255))    
                    end
                end
            end
        end


        if isCreateFlag == true then  --是否可以制造
            FlyFunction:setButtonNarmal(Button)
            Image_tipicon:loadTexture("ui/FlyTechTree/tree_canMake.png") --显示加号
            Image_tipicon:setVisible(true)
        end
        
        
    end
end

--初始化   
function FlyTechTreeLayer:init()

    self.FibbleTables = {}
    self.typeImage = {"ui/FlyTechTree/tree_machinery.png","ui/FlyTechTree/tree_immortal.png","ui/FlyTechTree/tree_wild.png"} -- 1，机械。2仙，3兽
    self.typeImageFrame = {"ui/FlyTechTree/tree_machineryFrame.png","ui/FlyTechTree/tree_immortalFame.png","ui/FlyTechTree/tree_wildFrame.png"} -- 1，机械。2仙，3兽

    --背景的CSB
    local treeUiLayer = cc.CSLoader:createNode("csb/FlyTechTree_ui_Layer.csb")
    treeUiLayer:setAnchorPoint(cc.p(0.5,0.5))
    treeUiLayer:setPosition(display.center)
    self:addChild( treeUiLayer)

    self.treeScrollView =  treeUiLayer:getChildByName("treeScrollView")
--    self.treeScrollView:setInnerContainerSize(cc.size(1280, 366)) 
    self.listView =  treeUiLayer:getChildByName("listView")
    
    local backMainSceneBtn =  treeUiLayer:getChildByName("btnClose")
    
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            if sender == backMainSceneBtn then
                self:removeFromParent()

                if UserData.NewHandLead:getGuideState("FlyRefining") == 0 or
                    UserData.NewHandLead:getGuideState("FlySkillChange") == 0 or
                    UserData.NewHandLead:getGuideState("FlyGodChange") == 0 or
                    UserData.NewHandLead:getGuideState("FlyFighting") == 0 then
                     
                    local ManagerTask =  require("app.views.Task.ManagerTask")
                    if ManagerTask:isTaskHaveComplete(UserData.NewHandLead.GuideList.FlyRefining.TaskID) and UserData.NewHandLead:isPreGuideCompleted("FlyRefining") then
                        local SceneManager = require("app.views.SceneManager")
                        local TownInterfaceLayer = SceneManager:getGameLayer("TownInterfaceLayer")
                        if TownInterfaceLayer ~= nil then
                            TownInterfaceLayer:showNewHand("FlyRefining")
                        end
                     end
                end
            end
        
        end
    end    

    backMainSceneBtn:addTouchEventListener(onEventTouchButton)
    backMainSceneBtn:setPressedActionEnabled(true)
    
    --显示科技树的CSB
    self.uiLayer_Tree   = cc.CSLoader:createNode("csb/FlyTypeTree.csb") --大的科技树布局
    self.uiLayer_Tree:setAnchorPoint(cc.p(0.5,0.5))
    local innerWidth = self.treeScrollView:getContentSize().width
    local innerHeight = self.treeScrollView:getContentSize().height
    self.uiLayer_Tree:setPosition(cc.p(innerWidth/2,innerHeight/3 + 23))
    self.treeScrollView:addChild(self.uiLayer_Tree)
    self.Panel          = self.uiLayer_Tree:getChildByName("Panel")                    -- Panel


    --创建上面的科技树
    self:creatTreeNode()
    --创建变异的科技树
   -- self:creatSpecialFlyNode()
    
    if UserData.NewHandLead:getGuideState("FlyFighting") == 0 then
        self.handTo = self.uiLayer_Tree:getChildByName("handTo")
        self.handTo:setPosition(cc.p(display.cx - 40, display.cy + 40))
        
        local SpineJson = "spine/ui/ui_shouzhi.json"
        local SpineAtlas = "spine/ui/ui_shouzhi.atlas"

        local skeletonNode = sp.SkeletonAnimation:create(SpineJson, SpineAtlas, 1.0)
        skeletonNode:setAnimation(0, "click", true)
        skeletonNode:setPosition(0,0)
        self.handTo:addChild(skeletonNode)
        self.handTo:setLocalZOrder(100)
        
        ManagerTask.SectionId = UserData.NewHandLead.GuideList.FlyRefining.step[3].PlotSectionID
        local PlotLayer = require("app.views.Plot.PlotLayer")
        PlotLayer:initPlotEnterAntExit(0)
        local layer = PlotLayer:create()
        self:addChild(layer)
    end
end

function FlyTechTreeLayer:removeHand()
    if self.handTo ~= nil then
        self.handTo:removeFromParent()
    end
end
function FlyTechTreeLayer:setHandPosition(pos)
    self.handTo:setPosition(pos)
end

-- 创建科技树的

function FlyTechTreeLayer:creatTreeNode()

    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local tag = sender:getTag()
            local isHave = FlyFunction:checkFibbleIsHave(tag)
            if isHave == true then
                local flyMainUILayer = FlyMainUILayer:create(tag)
                self:addChild(flyMainUILayer)
                return
            end
            
            local isMake = FlyFunction:checkFibbleEnable(tag)
            if isMake == true then 
                local flyRefiningLayer = FlyRefiningLayer:create(tag, isMake)
                self:addChild(flyRefiningLayer)
            end
        end
    end    
    local nodeIdTabel = FightStaticData.fibbleTree
    
    for key, itemTree in pairs(nodeIdTabel) do
        local fibbleId =  itemTree.fibbleID
        print(fibbleId)
        local t = UserData.Fibble.fibbleTable[fibbleId]
        local strKey  = "fly_"..tostring(key)
       
        local nodeItem = self.Panel:getChildByName(strKey)
        nodeItem:setVisible(false)
		local treeNode = cc.CSLoader:createNode("csb/FlyTechTree_flyNode.csb")
        treeNode:setAnchorPoint(cc.p(0.5,0.5))
        treeNode:setPosition(cc.p(nodeItem:getPosition()))
        self.uiLayer_Tree:addChild(treeNode)
        local Button =  treeNode:getChildByName("Button_1")
        Button:setSwallowTouches(false)
        Button:setTag(fibbleId)
        Button:addTouchEventListener(onEventTouchButton)
        local Image_flyicon = Button:getChildByName("Image_flyicon") --飞宝图标
        local Image_tipicon = Button:getChildByName("Image_tipicon") -- 图上图标
        local Text_name = Button:getChildByName("Text_name") -- 飞宝名字
       
        
        local image_type = Button:getChildByName("image_type") -- 那个类别的，仙，人，妖
        local image_type_frame = Button:getChildByName("image_type_frame")
        local fightTitle = Button:getChildByName("fightTitle")
        local type =  FightStaticData.flyingObject[fibbleId].type
        image_type:setTexture(self.typeImage[type])  -- 设置那个类别的
        image_type:setVisible(true)
        fightTitle:setVisible(false)
        image_type_frame:setTexture(self.typeImageFrame[type])
        
        local star = 0
        if t then
            star = t[1].byStar
        end
        
        local fibbleData = FlyFunction:findFibbleUpForSameIdAndStar(fibbleId,star)
        Image_flyicon:setTexture(fibbleData.icon)
        Image_flyicon:setScale(0.9)
        Image_tipicon:setVisible(false)
       
        self.FibbleTables[fibbleId] = Button
        Text_name:setString(FightStaticData.flyingObject[fibbleId].name)
        
        local isHaveFlag = FlyFunction:checkFibbleIsHave(fibbleId)  -- 是否已经拥有了
        local isBrightFlag = FlyFunction:checkFibbleEnable(fibbleId)  --是否可以点亮了
        local isCreateFlag = FlyFunction:checkFibbleCreate(fibbleId) --是否可以创建了
       
        FlyFunction:setButtonGray(Button) --先全部置灰色
        
        if isHaveFlag == true then -- 如果已经创建拥有了,点亮图标,外侧框线,点亮向下框线
            FlyFunction:setButtonNarmal(Button)
         
          
            local isStrengFlag = FlyFunction:checkFibbleStreng(fibbleId,star) --传人是飞宝ID和星级
            if isStrengFlag == true then
                Image_tipicon:loadTexture("ui/FlyTechTree/tree_canRefine.png") --显示叹号
                Image_tipicon:setVisible(true)
            end
            if fibbleId == UserData.BaseInfo.nFibbleId then --如果是选择上阵的法宝，显示状态
--                Image_tipicon:setVisible(true)
--                Image_tipicon:loadTexture("ui/FlyTechTree/tree_fight.png") --显示战斗
                fightTitle:setVisible(true)
                image_type_frame:setTexture("ui/FlyTechTree/fightFrame.png")
                Button:loadTextures("ui/FlyTechTree/tree_nowFrame.png", "ui/FlyTechTree/tree_nowFrame.png", "ui/FlyTechTree/tree_nowFrame.png")
            end
            
        end
        

        local RouteTable = stringEx:split(itemTree.Route,"|")--获取本节点的前置ID
        if isBrightFlag == true then -- 可以点亮，不显示外侧框线,不点亮向下框线
            FlyFunction:setButtonNarmal(Button)
            if itemTree.Route ~= "" then
                for key, var in pairs(RouteTable) do
                    local rt = stringEx:split(var,"_")
                    local isHaveed = FlyFunction:checkFibbleIsHave(FightStaticData.fibbleTree[tonumber(rt[2])].fibbleID)
                    if isHaveed then
                        local arrKey = "arr_"..var
                        local arrow = self.Panel:getChildByName(arrKey)
                        arrow:setColor(cc.c3b(255,255,255))    
                    end
                end
            end
        end
        
        if isCreateFlag == true then  --是否可以制造
            FlyFunction:setButtonNarmal(Button)
            Image_tipicon:loadTexture("ui/FlyTechTree/tree_canMake.png") --显示加号
            Image_tipicon:setVisible(true)
        end
	end
end



--  创建变异的飞宝
function FlyTechTreeLayer:creatSpecialFlyNode()
    local function listViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_START then
            print("select child index = ",sender:getCurSelectedIndex())
        end
    end

    local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            print("SCROLL_TO_BOTTOM")
        elseif evenType ==  ccui.ScrollviewEventType.scrollToTop then
            print("SCROLL_TO_TOP")
        end
    end
	

	
	
    local specialTable = {}
    local i  =  1
    --  获取 特殊的飞宝的
    for key, item in pairs(FightStaticData.flyingObject) do
   	    if key > 104000 then
   	    	specialTable[i] = item
   	    	i = i + 1
   	    end
    end
    -- 排序的
    table.sort(specialTable,function(a,b) 
        return a.id < b.id
    end)
    
    
    local function onEventTouchButton(sender,eventType)
        if  eventType == cc.EventCode.ENDED then
            local tag = sender:getTag()
            print(tag)
        end
    end    
	
    for key, var in pairs(specialTable) do
        local fibbleId = var.id
        -- 查找节点
        local treeNode = cc.CSLoader:createNode("csb/FlyTechTree_flyNode.csb")--  获取一个node
        treeNode:setAnchorPoint(cc.p(0.5,0.5))
        local Button =  treeNode:getChildByName("Button_1") 
        Button:setSwallowTouches(false)
        Button:setTag(fibbleId)--设置Tag
        
        Button:addTouchEventListener(onEventTouchButton)--回调
        
        local default_layout = ccui.Layout:create() --创建一个layout
        default_layout:setTouchEnabled(false)
        local bSize = Button:getContentSize()
        default_layout:setContentSize(bSize)
        default_layout:addChild(treeNode)
        treeNode:setPosition(cc.p(bSize.width / 2.0 , bSize.height / 2.0))
       
        default_layout:setAnchorPoint(0.5,0.5)
        self.listView:addChild(default_layout)
        Button:setSwallowTouches(false)
        
        local Image_flyicon = Button:getChildByName("Image_flyicon")
        local Image_tipicon = Button:getChildByName("Image_tipicon")
        local Text_name = Button:getChildByName("Text_name")
        
        local image_type = Button:getChildByName("image_type") -- 那个类别的，仙，人，妖
        local image_type_frame = Button:getChildByName("image_type_frame")
        local type =  FightStaticData.flyingObject[fibbleId].type
        image_type:setTexture(self.typeImage[type])
        image_type:setVisible(true)
--        image_type_frame:setTexture(self.typeImageFrame[type])
        Image_flyicon:setTexture("ui/FlyTechTree/tree_fly.png")
        Image_flyicon:setScale(0.9)
       
      
        Image_tipicon:setVisible(false)
        
        Text_name:setString(var.name)
        FlyFunction:setButtonGray(Button)
        self.FibbleTables[var.id] = Button
        
    
       
        
        local isHaveFlag = FlyFunction:checkFibbleIsHave(fibbleId)  -- 是否已经拥有了
        local isBrightFlag = FlyFunction:checkFibbleEnable(fibbleId)  --是否可以点亮了
        local isCreateFlag = FlyFunction:checkFibbleCreate(fibbleId) --是否可以创建了

        FlyFunction:setButtonGray(Button) --先全部置灰色
        if isHaveFlag == true then -- 如果已经创建拥有了,点亮图标,外侧框线,点亮向下框线
            FlyFunction:setButtonNarmal(Button)
           
            local t = UserData.Fibble.fibbleTable[fibbleId]
            local isStrengFlag = FlyFunction:checkFibbleStreng(fibbleId,t[1].byStar) --传人是飞宝ID和星级
            if isStrengFlag == true then
                Image_tipicon:loadTexture("ui/FlyTechTree/tree_canRefine.png") --显示叹号
                Image_tipicon:setVisible(true)
            end
            if fibbleId == UserData.BaseInfo.nFibbleId then --如果是选择上阵的法宝，显示状态
--                Image_tipicon:setVisible(true)
--                Image_tipicon:loadTexture("ui/FlyTechTree/tree_fight.png") --显示战斗
                image_type_frame:setTexture("ui/FlyTechTree/fightFrame.png")
                Button:loadTextures("ui/FlyTechTree/tree_nowFrame.png", "ui/FlyTechTree/tree_nowFrame.png", "ui/FlyTechTree/tree_nowFrame.png")
            end

        end

        if isBrightFlag == true then -- 可以点亮，不显示外侧框线,不点亮向下框线
            FlyFunction:setButtonNarmal(Button)
--            Button:loadTextures("ui/FlyTechTree/tree_imFrame.png", "ui/FlyTechTree/tree_imFrame.png", "ui/FlyTechTree/tree_imFrame.png") --设置底图
        end
        if isCreateFlag == true then  --是否可以制造
            FlyFunction:setButtonNarmal(Button)
            Image_tipicon:loadTexture("ui/FlyTechTree/tree_canMake.png") --显示加号
            Image_tipicon:setVisible(true)
        end

        
    end
	
	
end



return FlyTechTreeLayer
